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
    # Descobre os nomes únicos de vídeo dinamicamente
    video_names = sorted(set(data['Video']))
    video_order = {name: i for i, name in enumerate(video_names)}
    sorted_keys = sorted(ue_data.keys(), key=lambda x: (x[0], video_order.get(x[1], 99)))
    for (ue, video), value in [(k, ue_data[k]) for k in sorted_keys]:
        result['UE'].append(ue)
        result['Video'].append(video)
        result['Value'].append(value)
    return result

def get_video_names(data_sem, data_com):
    """Extrai os nomes únicos de vídeos dos dados"""
    videos = set()
    for video in data_sem.get('Video', []):
        videos.add(video)
    for video in data_com.get('Video', []):
        videos.add(video)
    return sorted(list(videos))

def create_comparison_plot_matplotlib(sem_sdn_file, com_sdn_file, output_file, title, ylabel):
    """Cria gráfico comparativo usando matplotlib - agrupa por UE com 4 barras (dinâmico)"""
    data_sem = read_csv(sem_sdn_file)
    data_com = read_csv(com_sdn_file)
    
    if not data_sem['UE'] and not data_com['UE']:
        print(f"  Sem dados para: {title}")
        return
    
    # Agrega dados por UE
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)
    
    # Descobre os nomes dos vídeos dinamicamente
    video_names = get_video_names(data_sem, data_com)
    if len(video_names) < 2:
        video_names = video_names + ['video2'] if len(video_names) == 1 else ['video1', 'video2']
    
    video1_name = video_names[0]
    video2_name = video_names[1] if len(video_names) > 1 else 'video2'
    
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
        ue_entry = {'ue': ue, 'v1_sem': 0, 'v1_com': 0, 'v2_sem': 0, 'v2_com': 0}
        for i in range(len(data_sem['UE'])):
            if data_sem['UE'][i] == ue:
                if data_sem['Video'][i] == video1_name:
                    ue_entry['v1_sem'] = data_sem['Value'][i]
                else:
                    ue_entry['v2_sem'] = data_sem['Value'][i]
        for i in range(len(data_com['UE'])):
            if data_com['UE'][i] == ue:
                if data_com['Video'][i] == video1_name:
                    ue_entry['v1_com'] = data_com['Value'][i]
                else:
                    ue_entry['v2_com'] = data_com['Value'][i]
        plot_data.append(ue_entry)
        positions.append(current_x)
        current_x += group_spacing
    
    positions = np.array(positions)
    
    # Cria 4 barras por UE com nomes dinâmicos
    v1_sem = [d['v1_sem'] for d in plot_data]
    v1_com = [d['v1_com'] for d in plot_data]
    v2_sem = [d['v2_sem'] for d in plot_data]
    v2_com = [d['v2_com'] for d in plot_data]
    
    # Barras agrupadas com cores distintas e nomes dinâmicos
    bars1 = ax.bar(positions - 1.5*bar_width, v1_sem, bar_width, 
                   label=f'{video1_name.capitalize()} - SEM SDN', color='#2980b9', edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(positions - 0.5*bar_width, v1_com, bar_width, 
                   label=f'{video1_name.capitalize()} - COM SDN', color='#85c1e9', edgecolor='black', linewidth=0.5)
    bars3 = ax.bar(positions + 0.5*bar_width, v2_sem, bar_width, 
                   label=f'{video2_name.capitalize()} - SEM SDN', color='#c0392b', edgecolor='black', linewidth=0.5)
    bars4 = ax.bar(positions + 1.5*bar_width, v2_com, bar_width, 
                   label=f'{video2_name.capitalize()} - COM SDN', color='#f1948a', edgecolor='black', linewidth=0.5)
    
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
