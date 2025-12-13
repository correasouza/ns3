#!/usr/bin/env python3
"""
Gerador de gráficos simples para avaliação LTE + SDN
Usa texto formatado caso matplotlib não esteja disponível
"""

import os
import sys

def read_csv(filepath):
    """Lê arquivo CSV e retorna dados"""
    data = []
    if not os.path.exists(filepath):
        return data
    with open(filepath, 'r') as f:
        lines = f.readlines()
        for line in lines[1:]:  # Skip header
            parts = line.strip().split(',')
            if len(parts) >= 3:
                data.append({
                    'UE': parts[0],
                    'Video': parts[1],
                    'Value': float(parts[2])
                })
    return data

def create_text_chart(title, data_sem, data_com, ylabel, output_file):
    """Cria gráfico em modo texto"""
    with open(output_file, 'w') as f:
        f.write(f"\n{'='*60}\n")
        f.write(f"  {title}\n")
        f.write(f"{'='*60}\n\n")
        
        f.write(f"{'UE/Video':<20} {'SEM SDN':<15} {'COM SDN':<15} {'Diff':<10}\n")
        f.write(f"{'-'*60}\n")
        
        for i in range(len(data_sem)):
            sem = data_sem[i] if i < len(data_sem) else {'UE': '?', 'Video': '?', 'Value': 0}
            com = data_com[i] if i < len(data_com) else {'UE': '?', 'Video': '?', 'Value': 0}
            label = f"UE{sem['UE']} ({sem['Video']})"
            diff = ((com['Value'] - sem['Value']) / sem['Value'] * 100) if sem['Value'] != 0 else 0
            f.write(f"{label:<20} {sem['Value']:<15.3f} {com['Value']:<15.3f} {diff:>+8.1f}%\n")
        
        f.write(f"\n{ylabel}\n")
    print(f"  Gráfico texto gerado: {output_file}")

def main():
    base_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
    graphs_dir = os.path.join(base_dir, 'graphs')
    comparison_dir = os.path.join(base_dir, 'comparison')
    
    os.makedirs(comparison_dir, exist_ok=True)
    
    print("\nGerando gráficos em modo texto...\n")
    
    # Delay
    data_sem = read_csv(f"{graphs_dir}/delay_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/delay_COM_SDN.csv")
    create_text_chart("Comparação de Delay", data_sem, data_com, "Delay (ms)", 
                      f"{comparison_dir}/delay_comparison.txt")
    
    # Throughput
    data_sem = read_csv(f"{graphs_dir}/throughput_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/throughput_COM_SDN.csv")
    create_text_chart("Comparação de Throughput", data_sem, data_com, "Throughput (Mbps)",
                      f"{comparison_dir}/throughput_comparison.txt")
    
    # PSNR
    data_sem = read_csv(f"{graphs_dir}/psnr_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/psnr_COM_SDN.csv")
    create_text_chart("Comparação de PSNR", data_sem, data_com, "PSNR (dB)",
                      f"{comparison_dir}/psnr_comparison.txt")
    
    # Jitter
    data_sem = read_csv(f"{graphs_dir}/jitter_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/jitter_COM_SDN.csv")
    create_text_chart("Comparação de Jitter", data_sem, data_com, "Jitter (ms)",
                      f"{comparison_dir}/jitter_comparison.txt")
    
    # Packet Loss
    data_sem = read_csv(f"{graphs_dir}/packet_loss_SEM_SDN.csv")
    data_com = read_csv(f"{graphs_dir}/packet_loss_COM_SDN.csv")
    create_text_chart("Comparação de Perda de Pacotes", data_sem, data_com, "Perda (%)",
                      f"{comparison_dir}/packet_loss_comparison.txt")
    
    print("\nGráficos gerados com sucesso!")

if __name__ == "__main__":
    main()
