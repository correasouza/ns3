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

# =====================================================
# 1. CONFIGURAÇÕES INICIAIS - Define parâmetros globais
# =====================================================
set -e  # Para execução em caso de erro (exit on error)

# Gera timestamp único para cada execução (ex: 20251213_0049)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="results_lte_sdn_$TIMESTAMP"  # Diretório único por execução
NS3_DIR="/usr/ns-3-dev"                  # Caminho do ns-3 instalado
NUM_ENBS=2                               # Número de torres LTE (eNodeBs)
NUM_UES=6                                # Número de dispositivos móveis (UEs)
SIM_TIME=60                              # Duração da simulação em segundos
VIDEO1="st_highway_cif.st"               # Vídeo 1: highway (menos complexo)
VIDEO2="football.st"                     # Vídeo 2: futebol (mais complexo)

# Exibe configuração no terminal para validação
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

# =====================================================
# 2. CRIAÇÃO DE ESTRUTURA DE DIRETÓRIOS
# =====================================================
mkdir -p "$OUTPUT_DIR"           # Diretório principal dos resultados
mkdir -p "$OUTPUT_DIR/graphs"    # Gráficos individuais por métrica
mkdir -p "$OUTPUT_DIR/comparison" # Gráficos comparativos SDN vs SEM SDN

cd "$NS3_DIR"  # Entra no diretório do ns-3 para executar simulações

# =====================================================
# 3. VERIFICAÇÃO DE ARQUIVOS DE VÍDEO (EvalVid traces)
# =====================================================
# Verifica se o vídeo highway existe, senão copia do contrib/evalvid
if [ ! -f "$VIDEO1" ]; then
    echo "AVISO: Arquivo $VIDEO1 não encontrado, copiando de contrib/evalvid..."
    cp contrib/evalvid/st_highway_cif.st . 2>/dev/null || echo "Arquivo não disponível"
fi

# Verifica vídeo football (pode não existir em todas as instalações)
if [ ! -f "$VIDEO2" ]; then
    echo "AVISO: Arquivo $VIDEO2 não encontrado"
fi

# =====================================================
# 4. CENÁRIO 1: SEM SDN (switch como comutador normal)
# =====================================================
echo "============================================================"
echo "CENÁRIO 1: SEM SDN (switch como comutador normal)"
echo "============================================================"
echo ""

# Executa simulação ns-3 com SDN DESATIVADO
# Parâmetros passados via linha de comando para o script C++ evalvid_lte_aval_x2
./ns3 run "evalvid_lte_aval_x2 \
    --numEnbs=$NUM_ENBS \
    --numUes=$NUM_UES \
    --simTime=$SIM_TIME \
    --enableSdn=false \      # SDN DESATIVADO - switch learning comum
    --outputDir=$OUTPUT_DIR \
    --video1=$VIDEO1 \
    --video2=$VIDEO2" 2>&1 | tee "$OUTPUT_DIR/log_SEM_SDN.txt"
    # ^^^ Salva log completo (stdout + stderr) no arquivo

# =====================================================
# 5. CENÁRIO 2: COM SDN (priorização de vídeo ativada)
# =====================================================
echo ""
echo "============================================================"
echo "CENÁRIO 2: COM SDN (priorização de vídeo ativada)"
echo "============================================================"
echo ""

# Executa MESMA simulação com SDN ATIVADO
./ns3 run "evalvid_lte_aval_x2 \
    --numEnbs=$NUM_ENBS \
    --numUes=$NUM_UES \
    --simTime=$SIM_TIME \
    --enableSdn=true \       # SDN ATIVADO - regras OpenFlow de priorização
    --outputDir=$OUTPUT_DIR \
    --video1=$VIDEO1 \
    --video2=$VIDEO2" 2>&1 | tee "$OUTPUT_DIR/log_COM_SDN.txt"

# =====================================================
# 6. GERAÇÃO DE GRÁFICOS PNG COMPARATIVOS
# =====================================================
echo ""
echo "============================================================"
echo "Gerando gráficos PNG comparativos..."
echo "============================================================"
echo ""

# Chama script Python externo (se existir) para gerar gráficos
python3 /usr/ns-3-dev/generate_png_graphs.py "$OUTPUT_DIR"

# =====================================================
# 7. CRIAÇÃO DE SCRIPT PYTHON EMBARCADO (BACKUP)
# =====================================================
# Se o script externo falhar, cria um script Python autônomo
cat > "$OUTPUT_DIR/generate_graphs.py" << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
"""
Script para geração de gráficos comparativos - Avaliação LTE + SDN
"""

import os
import sys
import csv

# =====================================================
# 7.1 IMPORTAÇÃO CONDICIONAL DE MATPLOTLIB
# =====================================================
# Tenta importar matplotlib, se não disponível usa gnuplot
try:
    import matplotlib
    matplotlib.use('Agg')  # Backend sem interface gráfica
    import matplotlib.pyplot as plt
    import numpy as np
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False
    print("matplotlib não disponível, usando gnuplot...")

# =====================================================
# 7.2 FUNÇÃO PARA LER ARQUIVOS CSV DE MÉTRICAS
# =====================================================
def read_csv(filepath):
    """Lê arquivo CSV e retorna dados estruturados"""
    data = {'UE': [], 'Video': [], 'Value': []}
    if not os.path.exists(filepath):
        return data  # Retorna vazio se arquivo não existir
    
    with open(filepath, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            data['UE'].append(int(row['UE']))
            data['Video'].append(row['Video'])
            # Pega o terceiro campo (valor numérico da métrica)
            value_key = [k for k in row.keys() if k not in ['UE', 'Video']][0]
            data['Value'].append(float(row[value_key]))
    return data

# =====================================================
# 7.3 FUNÇÃO PRINCIPAL DE GERAÇÃO DE GRÁFICOS
# =====================================================
def create_comparison_plot_matplotlib(sem_sdn_file, com_sdn_file, output_file, title, ylabel):
    """Cria gráfico de barras comparativo usando matplotlib"""
    data_sem = read_csv(sem_sdn_file)  # Lê dados SEM SDN
    data_com = read_csv(com_sdn_file)  # Lê dados COM SDN
    
    if not data_sem['UE'] and not data_com['UE']:
        print(f"  Sem dados para: {title}")
        return
    
    # Cria figura com tamanho otimizado
    fig, ax = plt.subplots(figsize=(10, 6))
    
    x = np.arange(len(data_sem['UE']))  # Posições das barras
    width = 0.35                         # Largura das barras
    
    # Gráfico de barras agrupadas (SEM SDN vs COM SDN)
    bars1 = ax.bar(x - width/2, data_sem['Value'], width, 
                   label='SEM SDN', color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, data_com['Value'], width, 
                   label='COM SDN', color='coral', alpha=0.8)
    
    # Configurações do gráfico
    ax.set_xlabel('UE')
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_xticks(x)
    ax.set_xticklabels([f'UE{u}\n({v})' for u, v in zip(data_sem['UE'], data_sem['Video'])])
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150)  # Salva em alta resolução
    plt.close()
    print(f"  Gráfico gerado: {output_file}")

# =====================================================
# 7.4 FALLBACK PARA GNUPLOT (se matplotlib indisponível)
# =====================================================
def create_gnuplot_script(output_dir):
    """Cria scripts gnuplot para geração de gráficos"""
    
    # Exemplo para Delay (outros métricas seguem mesmo padrão)
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
    # Repete para throughput, PSNR, jitter, packet_loss...

# =====================================================
# 7.5 FUNÇÃO MAIN DO PYTHON
# =====================================================
def main():
    output_dir = os.path.dirname(os.path.abspath(__file__))
    graphs_dir = os.path.join(output_dir, 'graphs')
    comparison_dir = os.path.join(output_dir, 'comparison')
    
    os.makedirs(comparison_dir, exist_ok=True)
    
    if HAS_MATPLOTLIB:
        print("Gerando gráficos com matplotlib...")
        
        # Gera 5 gráficos comparativos automaticamente
        metrics = [
            ('delay', 'Delay (ms)'),
            ('throughput', 'Throughput (Mbps)'),
            ('psnr', 'PSNR (dB)'),
            ('jitter', 'Jitter (ms)'),
            ('packet_loss', 'Perda de Pacotes (%)')
        ]
        
        for metric, ylabel in metrics:
            create_comparison_plot_matplotlib(
                f"{graphs_dir}/{metric}_SEM_SDN.csv",
                f"{graphs_dir}/{metric}_COM_SDN.csv",
                f"{comparison_dir}/{metric}_comparison.png",
                f"Comparação de {metric.capitalize()} - SEM SDN vs COM SDN",
                ylabel
            )
    else:
        print("Gerando scripts gnuplot...")
        create_gnuplot_script(output_dir)
        print("Execute os scripts .gp com gnuplot para gerar os gráficos")

if __name__ == "__main__":
    main()
PYTHON_SCRIPT

# Executa o script Python gerado (com tratamento de erro)
python3 "$OUTPUT_DIR/generate_graphs.py" 2>/dev/null || echo "Gráficos serão gerados manualmente"

# =====================================================
# 8. GERAÇÃO DO RELATÓRIO FINAL AUTOMATIZADO
# =====================================================
cat > "$OUTPUT_DIR/RELATORIO_FINAL.txt" << EOF
================================================================================
RELATÓRIO FINAL - AVALIAÇÃO DE STREAMING DE VÍDEO SOBRE LTE + SDN
================================================================================

Data: $(date)
Diretório: $OUTPUT_DIR

# [RESTO DO RELATÓRIO COMPLETO - estrutura detalhada de cenários, métricas,
#  análise qualitativa dos vídeos e conclusões esperadas...]
EOF

# =====================================================
# 9. MENSAGENS FINAIS E INSTRUÇÕES
# =====================================================
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
