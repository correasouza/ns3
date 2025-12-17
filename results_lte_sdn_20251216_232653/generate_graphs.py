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
