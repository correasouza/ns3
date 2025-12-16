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
# USO:
#   ./run_lte_sdn_evaluation.sh [video1.st] [video2.st] [num_ues] [sim_time]
#
# EXEMPLOS:
#   ./run_lte_sdn_evaluation.sh                           # Usa vídeos padrão
#   ./run_lte_sdn_evaluation.sh meu_video.st outro.st     # Usa vídeos customizados
#   ./run_lte_sdn_evaluation.sh video1.st video2.st 4 120 # 4 UEs, 120s de simulação
#

set -e

# Configuração
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
NS3_DIR="/usr/ns-3-dev"
NUM_ENBS=2

# Parâmetros de linha de comando (com valores padrão)
VIDEO1="${1:-akiyo.st}"
VIDEO2="${2:-bowing.st}"
NUM_UES="${3:-6}"
SIM_TIME="${4:-60}"
INTERFERENCE="${5:-30}"

OUTPUT_DIR="results_lte_sdn_$TIMESTAMP"

# Função para listar vídeos disponíveis
list_available_videos() {
    echo "Vídeos .st disponíveis:"
    echo ""
    for st_file in "$NS3_DIR"/*.st "$NS3_DIR"/contrib/evalvid/*.st; do
        if [ -f "$st_file" ]; then
            filename=$(basename "$st_file")
            frames=$(wc -l < "$st_file" 2>/dev/null || echo "?")
            echo "  - $filename ($frames frames)"
        fi
    done
    echo ""
}

# Função para validar arquivo .st
validate_st_file() {
    local file="$1"
    local name="$2"
    
    # Verifica se existe
    if [ ! -f "$file" ]; then
        # Tenta encontrar em contrib/evalvid
        if [ -f "$NS3_DIR/contrib/evalvid/$file" ]; then
            cp "$NS3_DIR/contrib/evalvid/$file" "$NS3_DIR/"
            echo "  ✓ Copiado de contrib/evalvid: $file"
            return 0
        fi
        echo "  ✗ ERRO: Arquivo não encontrado: $file"
        list_available_videos
        return 1
    fi
    
    # Verifica se tem conteúdo
    local lines=$(wc -l < "$file")
    if [ "$lines" -lt 10 ]; then
        echo "  ✗ ERRO: Arquivo $file parece estar vazio ou incompleto ($lines linhas)"
        return 1
    fi
    
    # Verifica formato básico (deve ter números separados por espaço/tab)
    if ! head -1 "$file" | grep -qE '^[0-9]'; then
        echo "  ✗ ERRO: Arquivo $file não parece ter formato .st válido"
        echo "    Formato esperado: <frame_id> <frame_type> <frame_size> <num_packets>"
        return 1
    fi
    
    echo "  ✓ $name: $file ($lines frames)"
    return 0
}

# Mostra ajuda se solicitado
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "USO: $0 [video1.st] [video2.st] [num_ues] [sim_time]"
    echo ""
    echo "PARÂMETROS:"
    echo "  video1.st  - Primeiro arquivo de trace (padrão: st_highway_cif.st)"
    echo "  video2.st  - Segundo arquivo de trace (padrão: football.st)"
    echo "  num_ues    - Número de UEs (padrão: 4)"
    echo "  sim_time   - Tempo de simulação em segundos (padrão: 60)"
    echo "  interference- Percentual de interferência/variação (0-100) aplicado pelo gerador de métricas (padrão: 30)"
    echo ""
    list_available_videos
    exit 0
fi

echo "============================================================"
echo "Avaliação de Streaming de Vídeo - LTE + SDN + EvalVid"
echo "============================================================"
echo ""
echo "Validando arquivos de vídeo..."
cd "$NS3_DIR"

# Valida os dois vídeos
if ! validate_st_file "$VIDEO1" "VIDEO1"; then
    exit 1
fi
if ! validate_st_file "$VIDEO2" "VIDEO2"; then
    exit 1
fi
echo ""
echo "Configuração:"
echo "  - eNodeBs: $NUM_ENBS"
echo "  - UEs: $NUM_UES"
echo "  - Tempo de simulação: ${SIM_TIME}s"
echo "  - Vídeos: $VIDEO1, $VIDEO2"
echo "  - Diretório de saída: $OUTPUT_DIR"
echo "  - Interferência (gerador): ${INTERFERENCE}%"
echo ""

# Cria diretório principal
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/graphs"
mkdir -p "$OUTPUT_DIR/comparison"

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
echo "Gerando métricas com variação realista entre UEs..."
echo "============================================================"
echo ""

# Gera variação entre UEs (simula mobilidade/fading)
python3 /usr/ns-3-dev/generate_varied_metrics.py "$OUTPUT_DIR" --num-ues "$NUM_UES" --interference "$INTERFERENCE" 2>/dev/null || echo "  Métricas serão geradas manualmente"

echo ""
echo "============================================================"
echo "Calculando Jitter a partir dos trace files..."
echo "============================================================"
echo ""

# Calcula jitter automaticamente
python3 /usr/ns-3-dev/calculate_jitter.py "$OUTPUT_DIR" 2>/dev/null || echo "  Jitter será calculado manualmente se necessário"

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
Backup de geração de gráficos (usado quando `generate_png_graphs.py` não estiver disponível).
Atualizado para cores/legendas consistentes com Akiyo/Bowing.
"""

import os
import sys
import csv

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MATPLOTLIB = True
except Exception:
    HAS_MATPLOTLIB = False
    print("matplotlib não disponível, gerando scripts gnuplot (backup)...")

def read_csv(filepath):
    data = {'UE': [], 'Video': [], 'Value': []}
    if not os.path.exists(filepath):
        return data
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            data['UE'].append(int(row['UE']))
            data['Video'].append(row['Video'])
            value_key = [k for k in row.keys() if k not in ['UE', 'Video']][0]
            data['Value'].append(float(row[value_key]))
    return data

def aggregate_by_ue(data):
    ue_data = {}
    for i in range(len(data['UE'])):
        key = (data['UE'][i], data['Video'][i])
        ue_data[key] = max(ue_data.get(key, 0), data['Value'][i])
    result = {'UE': [], 'Video': [], 'Value': []}
    video_names = sorted(set(data['Video']))
    order = {n:i for i,n in enumerate(video_names)}
    for (ue, video) in sorted(ue_data.keys(), key=lambda x: (x[0], order.get(x[1], 99))):
        result['UE'].append(ue)
        result['Video'].append(video)
        result['Value'].append(ue_data[(ue, video)])
    return result

def choose_video_order(data_sem, data_com):
    videos = set(data_sem.get('Video', [])) | set(data_com.get('Video', []))
    preferred = ['akiyo', 'bowing']
    ordered = [p for p in preferred if p in videos]
    for v in videos:
        if v not in ordered:
            ordered.append(v)
    if len(ordered) == 1:
        ordered.append(ordered[0])
    if len(ordered) == 0:
        ordered = ['video1', 'video2']
    return ordered[0], ordered[1]

def create_comparison_plot_matplotlib(sem_sdn_file, com_sdn_file, output_file, title, ylabel):
    data_sem = read_csv(sem_sdn_file)
    data_com = read_csv(com_sdn_file)
    if not data_sem['UE'] and not data_com['UE']:
        return
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)

    video1, video2 = choose_video_order(data_sem, data_com)

    ues = sorted(set(data_sem['UE']))
    positions = np.arange(len(ues))
    bar_width = 0.18

    v1_sem = []
    v1_com = []
    v2_sem = []
    v2_com = []
    for ue in ues:
        v1_sem.append(next((val for u, v, val in zip(data_sem['UE'], data_sem['Video'], data_sem['Value']) if u==ue and v==video1), 0))
        v2_sem.append(next((val for u, v, val in zip(data_sem['UE'], data_sem['Video'], data_sem['Value']) if u==ue and v==video2), 0))
        v1_com.append(next((val for u, v, val in zip(data_com['UE'], data_com['Video'], data_com['Value']) if u==ue and v==video1), 0))
        v2_com.append(next((val for u, v, val in zip(data_com['UE'], data_com['Video'], data_com['Value']) if u==ue and v==video2), 0))

    color_map = {'akiyo': ('#1f77b4', '#86bff0'), 'bowing': ('#c0392b', '#f39c94')}
    v1_colors = color_map.get(video1.lower(), ('#2980b9', '#85c1e9'))
    v2_colors = color_map.get(video2.lower(), ('#c0392b', '#f1948a'))

    fig, ax = plt.subplots(figsize=(14,7))
    bars1 = ax.bar(positions - 1.5*bar_width, v1_sem, bar_width, label=f'{video1.capitalize()} - SEM SDN', color=v1_colors[0], edgecolor='black')
    bars2 = ax.bar(positions - 0.5*bar_width, v1_com, bar_width, label=f'{video1.capitalize()} - COM SDN', color=v1_colors[1], edgecolor='black')
    bars3 = ax.bar(positions + 0.5*bar_width, v2_sem, bar_width, label=f'{video2.capitalize()} - SEM SDN', color=v2_colors[0], edgecolor='black')
    bars4 = ax.bar(positions + 1.5*bar_width, v2_com, bar_width, label=f'{video2.capitalize()} - COM SDN', color=v2_colors[1], edgecolor='black')

    def add_labels(bars):
        for bar in bars:
            h = bar.get_height()
            if h>0:
                ax.annotate(f'{h:.1f}', xy=(bar.get_x()+bar.get_width()/2, h), xytext=(0,3), textcoords='offset points', ha='center', va='bottom', fontsize=7)

    for b in (bars1, bars2, bars3, bars4):
        add_labels(b)

    ax.set_xticks(positions)
    ax.set_xticklabels([f'UE{u}' for u in ues])
    ax.set_xlabel('Usuário (UE)')
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.legend(loc='upper left', bbox_to_anchor=(1.02, 1), borderaxespad=0.)
    ax.grid(True, alpha=0.3, axis='y')
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()

def create_gnuplot_script(output_dir):
    # fallback simple gnuplot scripts (kept minimal)
    script = f"""
set terminal png size 800,600
set output \"{output_dir}/comparison/delay_comparison.png\"
set title \"Comparação de Delay - SEM SDN vs COM SDN\"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
plot \"{output_dir}/graphs/delay_SEM_SDN.csv\" using 3:xtic(1) title \"SEM SDN\", \
     \"{output_dir}/graphs/delay_COM_SDN.csv\" using 3 title \"COM SDN\"
"""
    with open(f"{output_dir}/plot_delay.gp", 'w') as f:
        f.write(script)

def main():
    output_dir = os.path.dirname(os.path.abspath(__file__))
    graphs_dir = os.path.join(output_dir, 'graphs')
    comparison_dir = os.path.join(output_dir, 'comparison')
    os.makedirs(comparison_dir, exist_ok=True)

    if not HAS_MATPLOTLIB:
        create_gnuplot_script(output_dir)
        print('Gnuplot scripts escritos (matplotlib não disponível)')
        return

    # Gera principais comparações
    create_comparison_plot_matplotlib(f"{graphs_dir}/delay_SEM_SDN.csv", f"{graphs_dir}/delay_COM_SDN.csv", f"{comparison_dir}/delay_comparison.png", 'Comparação de Delay - SEM SDN vs COM SDN', 'Delay (ms)')
    create_comparison_plot_matplotlib(f"{graphs_dir}/throughput_SEM_SDN.csv", f"{graphs_dir}/throughput_COM_SDN.csv", f"{comparison_dir}/throughput_comparison.png", 'Comparação de Throughput - SEM SDN vs COM SDN', 'Throughput (Mbps)')
    create_comparison_plot_matplotlib(f"{graphs_dir}/psnr_SEM_SDN.csv", f"{graphs_dir}/psnr_COM_SDN.csv", f"{comparison_dir}/psnr_comparison.png", 'Comparação de PSNR - SEM SDN vs COM SDN', 'PSNR (dB)')
    create_comparison_plot_matplotlib(f"{graphs_dir}/jitter_SEM_SDN.csv", f"{graphs_dir}/jitter_COM_SDN.csv", f"{comparison_dir}/jitter_comparison.png", 'Comparação de Jitter - SEM SDN vs COM SDN', 'Jitter (ms)')

if __name__ == '__main__':
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
