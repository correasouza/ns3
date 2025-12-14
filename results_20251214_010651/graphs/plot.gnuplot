set terminal pngcairo enhanced font 'Arial,11' size 1600,1200
set output 'metrics_graph.png'
set multiplot layout 2,3 title "EvalVid + NS-3 LTE - Análise de Qualidade de Vídeo" font ',14'

# Colunas: 1=Sim, 2=NumUEs, 3=PSNR, 4=Throughput, 5=Loss, 6=Delay, 7=Jitter

# Função para calcular margens automáticas
stats 'consolidated_metrics.dat' u 3 nooutput name 'PSNR_'
stats 'consolidated_metrics.dat' u 4 nooutput name 'TPUT_'
stats 'consolidated_metrics.dat' u 5 nooutput name 'LOSS_'
stats 'consolidated_metrics.dat' u 6 nooutput name 'DELAY_'
stats 'consolidated_metrics.dat' u 7 nooutput name 'JITTER_'

# 1. PSNR vs UEs
set title "PSNR vs Número de UEs" font ',12'
set xlabel "Número de UEs"
set ylabel "PSNR (dB)"
set grid
set key top right
psnr_min = (PSNR_min == PSNR_max) ? PSNR_min - 5 : PSNR_min - 1
psnr_max = (PSNR_min == PSNR_max) ? PSNR_max + 5 : PSNR_max + 1
set yrange [psnr_min:psnr_max]
plot 'consolidated_metrics.dat' u 2:3 w linespoints lw 2 pt 7 ps 1.2 lc rgb "#2E86AB" title 'PSNR'
set yrange [*:*]

# 2. Throughput vs UEs
set title "Throughput vs Número de UEs" font ',12'
set xlabel "Número de UEs"
set ylabel "Throughput (Mbps)"
set grid
tput_min = (TPUT_min == TPUT_max) ? TPUT_min * 0.9 : TPUT_min * 0.95
tput_max = (TPUT_min == TPUT_max) ? TPUT_max * 1.1 : TPUT_max * 1.05
set yrange [tput_min:tput_max]
plot 'consolidated_metrics.dat' u 2:4 w linespoints lw 2 pt 9 ps 1.2 lc rgb "#A23B72" title 'Throughput'
set yrange [*:*]

# 3. Perda vs UEs
set title "Perda de Pacotes vs Número de UEs" font ',12'
set xlabel "Número de UEs"
set ylabel "Perda (%)"
set grid
loss_min = 0
loss_max = (LOSS_max < 1) ? 5 : LOSS_max * 1.2
set yrange [loss_min:loss_max]
plot 'consolidated_metrics.dat' u 2:5 w linespoints lw 2 pt 5 ps 1.2 lc rgb "#F18F01" title 'Perda'
set yrange [*:*]

# 4. Delay vs UEs
set title "Atraso vs Número de UEs" font ',12'
set xlabel "Número de UEs"
set ylabel "Delay (ms)"
set grid
delay_min = 0
delay_max = (DELAY_max < 1) ? 10 : DELAY_max * 1.2
set yrange [delay_min:delay_max]
plot 'consolidated_metrics.dat' u 2:6 w linespoints lw 2 pt 11 ps 1.2 lc rgb "#C73E1D" title 'Delay'
set yrange [*:*]

# 5. Jitter vs UEs
set title "Jitter vs Número de UEs" font ',12'
set xlabel "Número de UEs"
set ylabel "Jitter (ms)"
set grid
jitter_min = 0
jitter_max = (JITTER_max < 0.1) ? 2 : JITTER_max * 1.5
set yrange [jitter_min:jitter_max]
plot 'consolidated_metrics.dat' u 2:7 w linespoints lw 2 pt 13 ps 1.2 lc rgb "#3B1F2B" title 'Jitter'
set yrange [*:*]

# 6. PSNR vs Throughput
set title "PSNR vs Throughput" font ',12'
set xlabel "Throughput (Mbps)"
set ylabel "PSNR (dB)"
set grid
set yrange [psnr_min:psnr_max]
plot 'consolidated_metrics.dat' u 4:3 w points pt 7 ps 2 lc rgb "#21A179" title 'Correlação'

unset multiplot
