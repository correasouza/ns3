#!/bin/bash
#
# Script de Automação - Avaliação LTE + SDN + EvalVid
# 
# Executa dois cenários:
# 1. SEM SDN - switch como comutador normal
# 2. COM SDN - priorização de fluxo de vídeo
#
# Gera métricas QoS (Delay, Jitter, Throughput) e QoE (PSNR, MOS)
#

set -e

# Configuração
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="results_lte_sdn_$TIMESTAMP"
NS3_DIR="/usr/ns-3-dev"
NUM_ENBS=2
NUM_UES=6
SIM_TIME=60
VIDEO1="st_highway_cif.st"
VIDEO2="football.st"

echo "============================================================"
echo "Avaliação de Streaming de Vídeo - LTE + SDN + EvalVid"
echo "============================================================"
echo ""
echo "Configuração:"
echo "  - eNodeBs: $NUM_ENBS"
echo "  - UEs: $NUM_UES"
echo "  - Tempo de simulação: ${SIM_TIME}s"
echo "  - Vídeos: $VIDEO1, $VIDEO2"
echo "  - Diretório de saída: $OUTPUT_DIR"
echo ""

# Cria diretório principal
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/graphs"
mkdir -p "$OUTPUT_DIR/comparison"

cd "$NS3_DIR"

# Verifica se os arquivos de trace existem
if [ ! -f "$VIDEO1" ]; then
    echo "AVISO: Arquivo $VIDEO1 não encontrado, copiando de contrib/evalvid..."
    cp contrib/evalvid/st_highway_cif.st . 2>/dev/null || echo "Arquivo não disponível"
fi

if [ ! -f "$VIDEO2" ]; then
    echo "AVISO: Arquivo $VIDEO2 não encontrado"
fi

echo "============================================================"
echo "CENÁRIO 1: SEM SDN (switch como comutador normal)"
echo "============================================================"
echo ""

./ns3 run "evalvid_lte_aval_x2 \
    --numEnbs=$NUM_ENBS \
    --numUes=$NUM_UES \
    --simTime=$SIM_TIME \
    --enableSdn=false \
    --outputDir=$OUTPUT_DIR \
    --video1=$VIDEO1 \
    --video2=$VIDEO2" 2>&1 | tee "$OUTPUT_DIR/log_SEM_SDN.txt"

echo ""
echo "============================================================"
echo "CENÁRIO 2: COM SDN (priorização de vídeo ativada)"
echo "============================================================"
echo ""

./ns3 run "evalvid_lte_aval_x2 \
    --numEnbs=$NUM_ENBS \
    --numUes=$NUM_UES \
    --simTime=$SIM_TIME \
    --enableSdn=true \
    --outputDir=$OUTPUT_DIR \
    --video1=$VIDEO1 \
    --video2=$VIDEO2" 2>&1 | tee "$OUTPUT_DIR/log_COM_SDN.txt"

echo ""
echo "============================================================"
echo "Gerando gráficos PNG comparativos..."
echo "============================================================"
echo ""

# Gera gráficos PNG
python3 /usr/ns-3-dev/generate_png_graphs.py "$OUTPUT_DIR"

# Também gera script Python embarcado (backup)
cat > "$OUTPUT_DIR/generate_graphs.py" << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
"""
Script para geração de gráficos comparativos - Avaliação LTE + SDN
"""

import os
import sys
import csv

# Tenta importar matplotlib, se não disponível usa gnuplot
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib não disponível, usando gnuplot...")

def read_csv(filepath):
    """Lê arquivo CSV e retorna dados"""
    data = {'UE': [], 'Video': [], 'Value': []}
    if not os.path.exists(filepath):
        return data
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            data['UE'].append(int(row['UE']))
            data['Video'].append(row['Video'])
            # Pega o terceiro campo (valor)
            value_key = [k for k in row.keys() if k not in ['UE', 'Video']][0]
            data['Value'].append(float(row[value_key]))
    return data

def aggregate_by_ue(data):
    """Agrega valores por UE - ordena por UE e depois por vídeo"""
    ue_data = {}
    for i in range(len(data['UE'])):
        ue = data['UE'][i]
        video = data['Video'][i]
        value = data['Value'][i]
        key = (ue, video)
        if key not in ue_data:
            ue_data[key] = 0
        ue_data[key] = max(ue_data[key], value)
    
    result = {'UE': [], 'Video': [], 'Value': []}
    video_order = {'highway': 0, 'football': 1}
    sorted_keys = sorted(ue_data.keys(), key=lambda x: (x[0], video_order.get(x[1], 2)))
    for (ue, video), value in [(k, ue_data[k]) for k in sorted_keys]:
        result['UE'].append(ue)
        result['Video'].append(video)
        result['Value'].append(value)
    return result

def create_comparison_plot_matplotlib(sem_sdn_file, com_sdn_file, output_file, title, ylabel):
    """Cria gráfico comparativo usando matplotlib - agrupa por UE com 4 barras"""
    data_sem = read_csv(sem_sdn_file)
    data_com = read_csv(com_sdn_file)
    
    if not data_sem['UE'] and not data_com['UE']:
        print(f"  Sem dados para: {title}")
        return
    
    # Agrega dados por UE
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)
    
    # Organiza dados por UE para agrupamento correto
    ues = sorted(set(data_sem['UE']))
    n_ues = len(ues)
    
    fig, ax = plt.subplots(figsize=(14, 7))
    
    # Largura das barras e posicionamento
    bar_width = 0.18
    group_spacing = 1.0
    
    # Coleta dados organizados por UE
    plot_data = []
    positions = []
    current_x = 0
    
    for ue in ues:
        ue_entry = {'ue': ue, 'hw_sem': 0, 'hw_com': 0, 'fb_sem': 0, 'fb_com': 0}
        for i in range(len(data_sem['UE'])):
            if data_sem['UE'][i] == ue:
                if data_sem['Video'][i] == 'highway':
                    ue_entry['hw_sem'] = data_sem['Value'][i]
                else:
                    ue_entry['fb_sem'] = data_sem['Value'][i]
        for i in range(len(data_com['UE'])):
            if data_com['UE'][i] == ue:
                if data_com['Video'][i] == 'highway':
                    ue_entry['hw_com'] = data_com['Value'][i]
                else:
                    ue_entry['fb_com'] = data_com['Value'][i]
        plot_data.append(ue_entry)
        positions.append(current_x)
        current_x += group_spacing
    
    positions = np.array(positions)
    
    # Cria 4 barras por UE: Highway SEM, Highway COM, Football SEM, Football COM
    hw_sem = [d['hw_sem'] for d in plot_data]
    hw_com = [d['hw_com'] for d in plot_data]
    fb_sem = [d['fb_sem'] for d in plot_data]
    fb_com = [d['fb_com'] for d in plot_data]
    
    # Barras agrupadas com cores distintas
    bars1 = ax.bar(positions - 1.5*bar_width, hw_sem, bar_width, 
                   label='Highway - SEM SDN', color='#2980b9', edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(positions - 0.5*bar_width, hw_com, bar_width, 
                   label='Highway - COM SDN', color='#85c1e9', edgecolor='black', linewidth=0.5)
    bars3 = ax.bar(positions + 0.5*bar_width, fb_sem, bar_width, 
                   label='Football - SEM SDN', color='#c0392b', edgecolor='black', linewidth=0.5)
    bars4 = ax.bar(positions + 1.5*bar_width, fb_com, bar_width, 
                   label='Football - COM SDN', color='#f1948a', edgecolor='black', linewidth=0.5)
    
    # Adiciona valores nas barras
    def add_labels(bars):
        for bar in bars:
            height = bar.get_height()
            if height > 0:
                ax.annotate(f'{height:.1f}',
                           xy=(bar.get_x() + bar.get_width() / 2, height),
                           xytext=(0, 3),
                           textcoords="offset points",
                           ha='center', va='bottom', fontsize=7, rotation=45)
    
    add_labels(bars1)
    add_labels(bars2)
    add_labels(bars3)
    add_labels(bars4)
    
    ax.set_xlabel('Usuário (UE)', fontsize=12)
    ax.set_ylabel(ylabel, fontsize=12)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xticks(positions)
    ax.set_xticklabels([f'UE{ue}' for ue in ues], fontsize=10)
    ax.legend(loc='upper right', fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  Gráfico gerado: {output_file}")

def create_gnuplot_script(output_dir):
    """Cria scripts gnuplot para geração de gráficos"""
    
    # Script para Delay
    script = f'''
set terminal png size 800,600
set output "{output_dir}/comparison/delay_comparison.png"
set title "Comparação de Delay - SEM SDN vs COM SDN"
set xlabel "UE"
set ylabel "Delay (ms)"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0
set grid y
plot "{output_dir}/graphs/delay_SEM_SDN.csv" using 3:xtic(1) title "SEM SDN" lc rgb "steelblue", \\
     "{output_dir}/graphs/delay_COM_SDN.csv" using 3 title "COM SDN" lc rgb "coral"
'''
    with open(f"{output_dir}/plot_delay.gp", 'w') as f:
        f.write(script)
    
    # Script para Throughput
    script = f'''
set terminal png size 800,600
set output "{output_dir}/comparison/throughput_comparison.png"
set title "Comparação de Throughput - SEM SDN vs COM SDN"
set xlabel "UE"
set ylabel "Throughput (Mbps)"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0
set grid y
plot "{output_dir}/graphs/throughput_SEM_SDN.csv" using 3:xtic(1) title "SEM SDN" lc rgb "steelblue", \\
     "{output_dir}/graphs/throughput_COM_SDN.csv" using 3 title "COM SDN" lc rgb "coral"
'''
    with open(f"{output_dir}/plot_throughput.gp", 'w') as f:
        f.write(script)
    
    # Script para PSNR
    script = f'''
set terminal png size 800,600
set output "{output_dir}/comparison/psnr_comparison.png"
set title "Comparação de PSNR - SEM SDN vs COM SDN"
set xlabel "UE"
set ylabel "PSNR (dB)"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9
set xtic rotate by -45 scale 0
set grid y
plot "{output_dir}/graphs/psnr_SEM_SDN.csv" using 3:xtic(1) title "SEM SDN" lc rgb "steelblue", \\
     "{output_dir}/graphs/psnr_COM_SDN.csv" using 3 title "COM SDN" lc rgb "coral"
'''
    with open(f"{output_dir}/plot_psnr.gp", 'w') as f:
        f.write(script)

def main():
    output_dir = os.path.dirname(os.path.abspath(__file__))
    graphs_dir = os.path.join(output_dir, 'graphs')
    comparison_dir = os.path.join(output_dir, 'comparison')
    
    os.makedirs(comparison_dir, exist_ok=True)
    
    if HAS_MATPLOTLIB:
        print("Gerando gráficos com matplotlib...")
        
        # Delay
        create_comparison_plot_matplotlib(
            f"{graphs_dir}/delay_SEM_SDN.csv",
            f"{graphs_dir}/delay_COM_SDN.csv",
            f"{comparison_dir}/delay_comparison.png",
            "Comparação de Delay - SEM SDN vs COM SDN",
            "Delay (ms)"
        )
        
        # Throughput
        create_comparison_plot_matplotlib(
            f"{graphs_dir}/throughput_SEM_SDN.csv",
            f"{graphs_dir}/throughput_COM_SDN.csv",
            f"{comparison_dir}/throughput_comparison.png",
            "Comparação de Throughput - SEM SDN vs COM SDN",
            "Throughput (Mbps)"
        )
        
        # PSNR
        create_comparison_plot_matplotlib(
            f"{graphs_dir}/psnr_SEM_SDN.csv",
            f"{graphs_dir}/psnr_COM_SDN.csv",
            f"{comparison_dir}/psnr_comparison.png",
            "Comparação de PSNR - SEM SDN vs COM SDN",
            "PSNR (dB)"
        )
        
        # Jitter
        create_comparison_plot_matplotlib(
            f"{graphs_dir}/jitter_SEM_SDN.csv",
            f"{graphs_dir}/jitter_COM_SDN.csv",
            f"{comparison_dir}/jitter_comparison.png",
            "Comparação de Jitter - SEM SDN vs COM SDN",
            "Jitter (ms)"
        )
        
        # Packet Loss
        create_comparison_plot_matplotlib(
            f"{graphs_dir}/packet_loss_SEM_SDN.csv",
            f"{graphs_dir}/packet_loss_COM_SDN.csv",
            f"{comparison_dir}/packet_loss_comparison.png",
            "Comparação de Perda de Pacotes - SEM SDN vs COM SDN",
            "Perda de Pacotes (%)"
        )
    else:
        print("Gerando scripts gnuplot...")
        create_gnuplot_script(output_dir)
        print("Execute os scripts .gp com gnuplot para gerar os gráficos")

if __name__ == "__main__":
    main()
PYTHON_SCRIPT

# Executa geração de gráficos
python3 "$OUTPUT_DIR/generate_graphs.py" 2>/dev/null || echo "Gráficos serão gerados manualmente"

# Gera relatório final
cat > "$OUTPUT_DIR/RELATORIO_FINAL.txt" << EOF
================================================================================
RELATÓRIO FINAL - AVALIAÇÃO DE STREAMING DE VÍDEO SOBRE LTE + SDN
================================================================================

Data: $(date)
Diretório: $OUTPUT_DIR

================================================================================
1. CONFIGURAÇÃO DO CENÁRIO
================================================================================

Infraestrutura de Rede:
  - 2 eNodeBs (multi-cell) com handover X2 ativado
  - 4 UEs móveis transitando entre as torres (30 km/h)
  - 1 Switch SDN (ofswitch13)
  - 1 Servidor de vídeo remoto (remoteHost)

Vídeos Utilizados:
  - highway (st_highway_cif.st): Cenas de estrada - movimento moderado
  - football (football.st): Cenas de esporte - alta movimentação

Tempo de Simulação: ${SIM_TIME} segundos

================================================================================
2. CENÁRIOS AVALIADOS
================================================================================

CENÁRIO 1 - SEM SDN:
  - Switch atua como comutador normal (learning controller)
  - Sem priorização de tráfego
  - Todos os fluxos tratados igualmente

CENÁRIO 2 - COM SDN:
  - Aplicação de regras OpenFlow para priorização
  - Tráfego de vídeo (UDP portas 8000-8010) com alta prioridade
  - Redução de latência para fluxos priorizados

================================================================================
3. MÉTRICAS COLETADAS
================================================================================

QoS (Quality of Service):
  - Delay (atraso fim-a-fim)
  - Jitter (variação do atraso)
  - Throughput (vazão)
  - Packet Loss (perda de pacotes)

QoE (Quality of Experience):
  - PSNR (Peak Signal-to-Noise Ratio) - estimado
  - MOS (Mean Opinion Score) - estimado
  - Frames perdidos

================================================================================
4. ESTRUTURA DE ARQUIVOS
================================================================================

$OUTPUT_DIR/
├── metrics/
│   ├── QoS_SEM_SDN.txt          # Métricas QoS sem SDN
│   ├── QoS_COM_SDN.txt          # Métricas QoS com SDN
│   ├── QoE_SEM_SDN.txt          # Métricas QoE sem SDN
│   ├── QoE_COM_SDN.txt          # Métricas QoE com SDN
│   ├── RESUMO_SEM_SDN.txt       # Resumo cenário sem SDN
│   ├── RESUMO_COM_SDN.txt       # Resumo cenário com SDN
│   └── flowmonitor_*.xml        # Dados detalhados FlowMonitor
├── graphs/
│   ├── delay_*.csv              # Dados de delay por cenário
│   ├── throughput_*.csv         # Dados de throughput por cenário
│   ├── psnr_*.csv               # Dados de PSNR por cenário
│   ├── jitter_*.csv             # Dados de jitter por cenário
│   └── packet_loss_*.csv        # Dados de perda por cenário
├── comparison/
│   ├── delay_comparison.png     # Gráfico comparativo delay
│   ├── throughput_comparison.png # Gráfico comparativo throughput
│   └── psnr_comparison.png      # Gráfico comparativo PSNR
├── traces/
│   └── sd_*/rd_*                # Traces EvalVid por UE
└── log_*.txt                    # Logs das simulações

================================================================================
5. ANÁLISE: DIFERENÇAS ENTRE OS VÍDEOS
================================================================================

Os resultados para vídeos diferentes (highway vs football) são DIFERENTES devido a:

1. CARACTERÍSTICAS DO CONTEÚDO:
   - Highway: Cenas mais estáticas, menor complexidade temporal
   - Football: Alta movimentação, muitas mudanças entre frames
   
2. TAXA DE BITS:
   - Football possui GOP mais complexo, gerando pacotes maiores
   - Maior sensibilidade à perda de pacotes (frames I críticos)

3. IMPACTO DA PERDA:
   - Em football, perda de frame I afeta mais frames subsequentes
   - Highway se recupera mais rapidamente de perdas

4. REQUISITOS DE BANDA:
   - Football demanda mais throughput para mesma qualidade
   - Highway mantém qualidade com menor vazão

================================================================================
6. CONCLUSÕES ESPERADAS
================================================================================

Com SDN ATIVADO espera-se:
  - Redução do delay médio (priorização de vídeo)
  - Menor variação de jitter
  - PSNR mais elevado (menor degradação)
  - MOS melhorado
  - Menor perda de pacotes para fluxos de vídeo

Diferenças entre vídeos:
  - Football deve apresentar mais sensibilidade às condições de rede
  - Highway deve ter métricas mais estáveis

================================================================================
EOF

echo ""
echo "============================================================"
echo "Simulação concluída!"
echo "============================================================"
echo ""
echo "Resultados salvos em: $OUTPUT_DIR"
echo ""
echo "Arquivos gerados:"
echo "  - $OUTPUT_DIR/RELATORIO_FINAL.txt"
echo "  - $OUTPUT_DIR/metrics/  (métricas QoS e QoE)"
echo "  - $OUTPUT_DIR/graphs/   (dados para gráficos)"
echo "  - $OUTPUT_DIR/comparison/ (gráficos comparativos)"
echo ""
echo "Para visualizar o relatório:"
echo "  cat $OUTPUT_DIR/RELATORIO_FINAL.txt"
echo ""
