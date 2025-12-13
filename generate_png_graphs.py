#!/usr/bin/env python3
"""
Gerador de gráficos PNG para avaliação LTE + SDN
Gera gráficos comparativos entre cenários SEM SDN e COM SDN
"""

import os
import sys
import csv
import matplotlib
matplotlib.use('Agg')  # Backend para geração de arquivos sem display
import matplotlib.pyplot as plt
import numpy as np

def read_csv(filepath):
    """Lê arquivo CSV e retorna dados organizados"""
    data = {'UE': [], 'Video': [], 'Value': []}
    if not os.path.exists(filepath):
        print(f"  AVISO: Arquivo não encontrado: {filepath}")
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
    """Agrega valores por UE - ordena por UE e depois por vídeo (highway primeiro, football depois)"""
    ue_data = {}
    for i in range(len(data['UE'])):
        ue = data['UE'][i]
        video = data['Video'][i]
        value = data['Value'][i]
        key = (ue, video)
        if key not in ue_data:
            ue_data[key] = 0
        ue_data[key] = max(ue_data[key], value)  # Usa o maior valor
    
    result = {'UE': [], 'Video': [], 'Value': []}
    # Ordena por UE primeiro, depois por vídeo (highway=0, football=1 para highway vir primeiro)
    video_order = {'highway': 0, 'football': 1}
    sorted_keys = sorted(ue_data.keys(), key=lambda x: (x[0], video_order.get(x[1], 2)))
    for (ue, video), value in [(k, ue_data[k]) for k in sorted_keys]:
        result['UE'].append(ue)
        result['Video'].append(video)
        result['Value'].append(value)
    return result

def create_comparison_bar_chart(data_sem, data_com, output_file, title, ylabel, colors=None):
    """Cria gráfico de barras comparativo - agrupa por UE mostrando ambos vídeos"""
    
    # Agrega dados por UE
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)
    
    if not data_sem['UE'] or not data_com['UE']:
        print(f"  AVISO: Sem dados suficientes para: {title}")
        return
    
    # Organiza dados por UE para agrupamento correto
    ues = sorted(set(data_sem['UE']))
    n_ues = len(ues)
    
    fig, ax = plt.subplots(figsize=(16, 8))
    
    # Largura das barras e posicionamento
    bar_width = 0.18
    group_spacing = 1.0  # Espaço entre grupos de UE
    
    # Posições x para cada UE
    positions = []
    current_x = 0
    
    # Coleta dados organizados por UE
    plot_data = []
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
    
    # Barras agrupadas
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
    
    # Ajusta margens
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Gráfico gerado: {output_file}")

def create_video_comparison_chart(data_sem, data_com, output_file, title, ylabel):
    """Cria gráfico comparando métricas por tipo de vídeo"""
    
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)
    
    if not data_sem['UE']:
        return
    
    # Agrupa por tipo de vídeo
    videos = {}
    for i in range(len(data_sem['Video'])):
        video = data_sem['Video'][i]
        if video not in videos:
            videos[video] = {'sem': [], 'com': []}
        videos[video]['sem'].append(data_sem['Value'][i])
        if i < len(data_com['Value']):
            videos[video]['com'].append(data_com['Value'][i])
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    video_names = list(videos.keys())
    x = np.arange(len(video_names))
    width = 0.35
    
    sem_means = [np.mean(videos[v]['sem']) for v in video_names]
    com_means = [np.mean(videos[v]['com']) for v in video_names]
    sem_std = [np.std(videos[v]['sem']) for v in video_names]
    com_std = [np.std(videos[v]['com']) for v in video_names]
    
    bars1 = ax.bar(x - width/2, sem_means, width, yerr=sem_std, label='SEM SDN',
                   color='#3498db', capsize=5, edgecolor='black', linewidth=0.5)
    bars2 = ax.bar(x + width/2, com_means, width, yerr=com_std, label='COM SDN',
                   color='#e74c3c', capsize=5, edgecolor='black', linewidth=0.5)
    
    ax.set_xlabel('Tipo de Vídeo', fontsize=11)
    ax.set_ylabel(ylabel, fontsize=11)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels([v.capitalize() for v in video_names], fontsize=10)
    ax.legend(loc='upper right', fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Gráfico gerado: {output_file}")

def create_ue_video_comparison(data_sem, data_com, output_file, title, ylabel):
    """Cria gráfico comparando Highway vs Football para cada UE"""
    
    data_sem = aggregate_by_ue(data_sem)
    data_com = aggregate_by_ue(data_com)
    
    if not data_sem['UE']:
        return
    
    # Organiza dados por UE
    ues = sorted(set(data_sem['UE']))
    
    fig, ax = plt.subplots(figsize=(14, 7))
    
    x = np.arange(len(ues))
    width = 0.2
    
    # Coleta valores por UE e vídeo
    hw_sem = []
    hw_com = []
    fb_sem = []
    fb_com = []
    
    for ue in ues:
        for i, (u, v, val) in enumerate(zip(data_sem['UE'], data_sem['Video'], data_sem['Value'])):
            if u == ue:
                if v == 'highway':
                    hw_sem.append(val)
                else:
                    fb_sem.append(val)
        for i, (u, v, val) in enumerate(zip(data_com['UE'], data_com['Video'], data_com['Value'])):
            if u == ue:
                if v == 'highway':
                    hw_com.append(val)
                else:
                    fb_com.append(val)
    
    # Barras agrupadas: 4 barras por UE
    bars1 = ax.bar(x - 1.5*width, hw_sem, width, label='Highway SEM SDN', color='#3498db', edgecolor='black')
    bars2 = ax.bar(x - 0.5*width, hw_com, width, label='Highway COM SDN', color='#85c1e9', edgecolor='black')
    bars3 = ax.bar(x + 0.5*width, fb_sem, width, label='Football SEM SDN', color='#e74c3c', edgecolor='black')
    bars4 = ax.bar(x + 1.5*width, fb_com, width, label='Football COM SDN', color='#f1948a', edgecolor='black')
    
    ax.set_xlabel('Usuário (UE)', fontsize=11)
    ax.set_ylabel(ylabel, fontsize=11)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels([f'UE{ue}' for ue in ues], fontsize=10)
    ax.legend(loc='upper right', fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Gráfico gerado: {output_file}")

def create_summary_dashboard(base_dir, output_file):
    """Cria dashboard resumido com todas as métricas"""
    
    graphs_dir = os.path.join(base_dir, 'graphs')
    
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle('Dashboard - Avaliação LTE + SDN\nComparação SEM SDN vs COM SDN', 
                 fontsize=14, fontweight='bold')
    
    metrics = [
        ('delay', 'Delay', 'Delay (ms)', axes[0, 0]),
        ('throughput', 'Throughput', 'Throughput (Mbps)', axes[0, 1]),
        ('psnr', 'PSNR', 'PSNR (dB)', axes[0, 2]),
        ('jitter', 'Jitter', 'Jitter (ms)', axes[1, 0]),
        ('packet_loss', 'Perda de Pacotes', 'Perda (%)', axes[1, 1]),
    ]
    
    for metric_file, metric_name, ylabel, ax in metrics:
        data_sem = read_csv(f"{graphs_dir}/{metric_file}_SEM_SDN.csv")
        data_com = read_csv(f"{graphs_dir}/{metric_file}_COM_SDN.csv")
        
        data_sem = aggregate_by_ue(data_sem)
        data_com = aggregate_by_ue(data_com)
        
        if data_sem['UE']:
            n = len(data_sem['UE'])
            x = np.arange(n)
            width = 0.35
            
            ax.bar(x - width/2, data_sem['Value'], width, label='SEM SDN', color='#3498db')
            ax.bar(x + width/2, data_com['Value'], width, label='COM SDN', color='#e74c3c')
            
            labels = [f"UE{ue}" for ue in data_sem['UE']]
            ax.set_xticks(x)
            ax.set_xticklabels(labels, fontsize=8)
            ax.set_ylabel(ylabel, fontsize=9)
            ax.set_title(metric_name, fontsize=10, fontweight='bold')
            ax.legend(fontsize=8)
            ax.grid(True, alpha=0.3, axis='y')
    
    # Último subplot: legenda de vídeos
    ax_legend = axes[1, 2]
    ax_legend.axis('off')
    ax_legend.text(0.5, 0.7, 'Legenda de Vídeos:', fontsize=12, fontweight='bold',
                  ha='center', transform=ax_legend.transAxes)
    ax_legend.text(0.5, 0.5, '• Highway: Cenas de estrada\n  (baixa complexidade)',
                  fontsize=10, ha='center', transform=ax_legend.transAxes)
    ax_legend.text(0.5, 0.3, '• Football: Cenas de esporte\n  (alta complexidade)',
                  fontsize=10, ha='center', transform=ax_legend.transAxes)
    
    # Ajusta layout deixando espaço para o título (top=0.92 reserva 8% no topo)
    plt.tight_layout(rect=[0, 0, 1, 0.92])
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ Dashboard gerado: {output_file}")

def create_individual_chart(data, output_file, title, ylabel, scenario):
    """Cria gráfico individual para um cenário"""
    
    data = aggregate_by_ue(data)
    
    if not data['UE']:
        return
    
    fig, ax = plt.subplots(figsize=(10, 6))
    
    n = len(data['UE'])
    x = np.arange(n)
    
    # Cores por tipo de vídeo
    colors = ['#3498db' if v == 'highway' else '#e74c3c' for v in data['Video']]
    
    bars = ax.bar(x, data['Value'], color=colors, edgecolor='black', linewidth=0.5)
    
    # Adiciona valores nas barras
    for bar in bars:
        height = bar.get_height()
        if height > 0:
            ax.annotate(f'{height:.2f}',
                       xy=(bar.get_x() + bar.get_width() / 2, height),
                       xytext=(0, 3),
                       textcoords="offset points",
                       ha='center', va='bottom', fontsize=9)
    
    labels = [f"UE{ue}\n({video})" for ue, video in zip(data['UE'], data['Video'])]
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_xlabel('Usuário (UE) / Tipo de Vídeo', fontsize=11)
    ax.set_ylabel(ylabel, fontsize=11)
    ax.set_title(f"{title} - {scenario}", fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    # Legenda de cores
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor='#3498db', label='Highway'),
                       Patch(facecolor='#e74c3c', label='Football')]
    ax.legend(handles=legend_elements, loc='upper right')
    
    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"  ✓ {os.path.basename(output_file)}")

def main():
    if len(sys.argv) < 2:
        # Procura o diretório de resultados mais recente
        import glob
        dirs = glob.glob('/usr/ns-3-dev/results_lte_sdn_*')
        if dirs:
            base_dir = sorted(dirs)[-1]
        else:
            print("Uso: python3 generate_png_graphs.py <diretório_resultados>")
            sys.exit(1)
    else:
        base_dir = sys.argv[1]
    
    print(f"\n{'='*60}")
    print(f"  Gerando Gráficos PNG - Avaliação LTE + SDN")
    print(f"{'='*60}")
    print(f"Diretório: {base_dir}\n")
    
    graphs_dir = os.path.join(base_dir, 'graphs')
    # Pasta principal com subpastas para QoS e QoE
    output_dir = os.path.join(base_dir, 'graficos_png')
    qos_dir = os.path.join(output_dir, 'qos')  # Delay, Jitter, Throughput, Packet Loss
    qoe_dir = os.path.join(output_dir, 'qoe')  # PSNR, MOS
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(qos_dir, exist_ok=True)
    os.makedirs(qoe_dir, exist_ok=True)
    
    # Gráficos de comparação por UE
    print("Gerando gráficos de comparação por UE...")
    
    # ========== MÉTRICAS QoS ==========
    print("\n  [QoS] Métricas de Qualidade de Serviço...")
    
    # Delay (QoS)
    data_sem = read_csv(f"{graphs_dir}/delay_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/delay_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com, 
        f"{qos_dir}/comparacao_delay.png",
        "Comparação de Delay - SEM SDN vs COM SDN", "Delay (ms)")
    
    # Throughput (QoS)
    data_sem = read_csv(f"{graphs_dir}/throughput_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/throughput_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qos_dir}/comparacao_throughput.png",
        "Comparação de Throughput - SEM SDN vs COM SDN", "Throughput (Mbps)")
    
    # Jitter (QoS)
    data_sem = read_csv(f"{graphs_dir}/jitter_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/jitter_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qos_dir}/comparacao_jitter.png",
        "Comparação de Jitter - SEM SDN vs COM SDN", "Jitter (ms)")
    
    # Packet Loss (QoS)
    data_sem = read_csv(f"{graphs_dir}/packet_loss_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/packet_loss_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qos_dir}/comparacao_perda_pacotes.png",
        "Comparação de Perda de Pacotes - SEM SDN vs COM SDN", "Perda (%)")
    
    # ========== MÉTRICAS QoE ==========
    print("\n  [QoE] Métricas de Qualidade de Experiência...")
    
    # PSNR (QoE)
    data_sem = read_csv(f"{graphs_dir}/psnr_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/psnr_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qoe_dir}/comparacao_psnr.png",
        "Comparação de PSNR - SEM SDN vs COM SDN", "PSNR (dB)")
    
    # MOS (QoE)
    data_sem = read_csv(f"{graphs_dir}/mos_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/mos_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qoe_dir}/comparacao_mos.png",
        "Comparação de MOS - SEM SDN vs COM SDN", "MOS (1-5)")
    
    # Frames Perdidos (QoE)
    data_sem = read_csv(f"{graphs_dir}/frames_lost_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/frames_lost_COM_SDN.csv")
    create_comparison_bar_chart(data_sem, data_com,
        f"{qoe_dir}/comparacao_frames_perdidos.png",
        "Comparação de Frames Perdidos - SEM SDN vs COM SDN", "Frames Perdidos")
    
    # Gráficos por tipo de vídeo
    print("\nGerando gráficos de comparação por tipo de vídeo...")
    
    # Delay por vídeo (QoS)
    data_sem = read_csv(f"{graphs_dir}/delay_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/delay_COM_SDN.csv")
    create_video_comparison_chart(data_sem, data_com,
        f"{qos_dir}/delay_por_video.png",
        "Delay Médio por Tipo de Vídeo", "Delay (ms)")
    
    # Throughput por vídeo (QoS)
    data_sem = read_csv(f"{graphs_dir}/throughput_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/throughput_COM_SDN.csv")
    create_video_comparison_chart(data_sem, data_com,
        f"{qos_dir}/throughput_por_video.png",
        "Throughput Médio por Tipo de Vídeo", "Throughput (Mbps)")
    
    # PSNR por vídeo (QoE)
    data_sem = read_csv(f"{graphs_dir}/psnr_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/psnr_COM_SDN.csv")
    create_video_comparison_chart(data_sem, data_com,
        f"{qoe_dir}/psnr_por_video.png",
        "PSNR Médio por Tipo de Vídeo", "PSNR (dB)")
    
    # MOS por vídeo (QoE)
    data_sem = read_csv(f"{graphs_dir}/mos_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/mos_COM_SDN.csv")
    create_video_comparison_chart(data_sem, data_com,
        f"{qoe_dir}/mos_por_video.png",
        "MOS Médio por Tipo de Vídeo", "MOS (1-5)")
    
    # Frames perdidos por vídeo (QoE)
    data_sem = read_csv(f"{graphs_dir}/frames_lost_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/frames_lost_COM_SDN.csv")
    create_video_comparison_chart(data_sem, data_com,
        f"{qoe_dir}/frames_perdidos_por_video.png",
        "Frames Perdidos por Tipo de Vídeo", "Frames Perdidos")
    
    # ========== GRÁFICOS DE COMPARAÇÃO UE vs VÍDEO ==========
    print("\nGerando gráficos de comparação UE vs Vídeo...")
    
    # Delay por UE (Highway vs Football)
    data_sem = read_csv(f"{graphs_dir}/delay_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/delay_COM_SDN.csv")
    create_ue_video_comparison(data_sem, data_com,
        f"{qos_dir}/delay_ue_video.png",
        "Delay por UE - Highway vs Football", "Delay (ms)")
    
    # Throughput por UE (Highway vs Football)
    data_sem = read_csv(f"{graphs_dir}/throughput_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/throughput_COM_SDN.csv")
    create_ue_video_comparison(data_sem, data_com,
        f"{qos_dir}/throughput_ue_video.png",
        "Throughput por UE - Highway vs Football", "Throughput (Mbps)")
    
    # PSNR por UE (Highway vs Football)
    data_sem = read_csv(f"{graphs_dir}/psnr_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/psnr_COM_SDN.csv")
    create_ue_video_comparison(data_sem, data_com,
        f"{qoe_dir}/psnr_ue_video.png",
        "PSNR por UE - Highway vs Football", "PSNR (dB)")
    
    # MOS por UE (Highway vs Football)
    data_sem = read_csv(f"{graphs_dir}/mos_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/mos_COM_SDN.csv")
    create_ue_video_comparison(data_sem, data_com,
        f"{qoe_dir}/mos_ue_video.png",
        "MOS por UE - Highway vs Football", "MOS (1-5)")

    # ========== GRÁFICOS INDIVIDUAIS POR CENÁRIO ==========
    print("\nGerando gráficos individuais - Cenário SEM SDN...")
    
    # Métricas QoS
    qos_metrics = [
        ('delay', 'Delay', 'Delay (ms)'),
        ('throughput', 'Throughput', 'Throughput (Mbps)'),
        ('jitter', 'Jitter', 'Jitter (ms)'),
        ('packet_loss', 'Perda de Pacotes', 'Perda (%)'),
    ]
    
    # Métricas QoE
    qoe_metrics = [
        ('psnr', 'PSNR', 'PSNR (dB)'),
        ('mos', 'MOS', 'MOS (1-5)'),
        ('frames_lost', 'Frames Perdidos', 'Frames'),
    ]
    
    # Gráficos QoS - SEM SDN
    for metric_file, metric_name, ylabel in qos_metrics:
        data = read_csv(f"{graphs_dir}/{metric_file}_SEM_SDN.csv")
        create_individual_chart(data, 
            f"{qos_dir}/{metric_file}_SEM_SDN.png",
            metric_name, ylabel, "SEM SDN")
    
    # Gráficos QoE - SEM SDN
    for metric_file, metric_name, ylabel in qoe_metrics:
        data = read_csv(f"{graphs_dir}/{metric_file}_SEM_SDN.csv")
        create_individual_chart(data, 
            f"{qoe_dir}/{metric_file}_SEM_SDN.png",
            metric_name, ylabel, "SEM SDN")
    
    print("\nGerando gráficos individuais - Cenário COM SDN...")
    
    # Gráficos QoS - COM SDN
    for metric_file, metric_name, ylabel in qos_metrics:
        data = read_csv(f"{graphs_dir}/{metric_file}_COM_SDN.csv")
        create_individual_chart(data,
            f"{qos_dir}/{metric_file}_COM_SDN.png",
            metric_name, ylabel, "COM SDN")
    
    # Gráficos QoE - COM SDN
    for metric_file, metric_name, ylabel in qoe_metrics:
        data = read_csv(f"{graphs_dir}/{metric_file}_COM_SDN.csv")
        create_individual_chart(data,
            f"{qoe_dir}/{metric_file}_COM_SDN.png",
            metric_name, ylabel, "COM SDN")
    
    # Dashboard resumido (na pasta principal)
    print("\nGerando dashboard resumido...")
    create_summary_dashboard(base_dir, f"{output_dir}/dashboard_resumo.png")
    
    print(f"\n{'='*60}")
    print(f"  Gráficos PNG gerados com sucesso!")
    print(f"  Pasta principal: {output_dir}")
    print(f"  ├── qos/   (Delay, Jitter, Throughput, Packet Loss)")
    print(f"  └── qoe/   (PSNR, MOS, Frames Perdidos)")
    print(f"{'='*60}\n")
    
    # Lista arquivos gerados organizados
    print("Arquivos gerados:")
    
    print("\n  📊 DASHBOARD:")
    for f in sorted(os.listdir(output_dir)):
        if f.endswith('.png'):
            size = os.path.getsize(os.path.join(output_dir, f))
            print(f"    • {f} ({size/1024:.1f} KB)")
    
    print("\n  📈 QoS (Qualidade de Serviço):")
    for f in sorted(os.listdir(qos_dir)):
        if f.endswith('.png'):
            size = os.path.getsize(os.path.join(qos_dir, f))
            print(f"    • qos/{f} ({size/1024:.1f} KB)")
    
    print("\n  📉 QoE (Qualidade de Experiência):")
    for f in sorted(os.listdir(qoe_dir)):
        if f.endswith('.png'):
            size = os.path.getsize(os.path.join(qoe_dir, f))
            print(f"    • qoe/{f} ({size/1024:.1f} KB)")

if __name__ == "__main__":
    main()
