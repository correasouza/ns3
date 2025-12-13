# NS-3 LTE + SDN + EvalVid - Simulação de Streaming de Vídeo

[![NS-3](https://img.shields.io/badge/NS--3-v3.39-blue.svg)](https://www.nsnam.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-GPLv2-green.svg)](LICENSE)

## 📋 Índice

1. [Visão Geral](#-visão-geral)
2. [Arquitetura do Projeto](#-arquitetura-do-projeto)
3. [Requisitos](#-requisitos)
4. [Instalação com Docker](#-instalação-com-docker)
5. [Instalação Manual](#-instalação-manual)
6. [Scripts de Automação](#-scripts-de-automação)
7. [Executando Simulações](#-executando-simulações)
8. [Estrutura de Resultados](#-estrutura-de-resultados)
9. [Métricas Coletadas](#-métricas-coletadas)
10. [Documentação NS-3](#-documentação-ns-3)

---

## 🎯 Visão Geral

Este projeto implementa uma **simulação de streaming de vídeo sobre redes LTE com suporte a SDN (Software-Defined Networking)** utilizando o simulador NS-3. O objetivo é avaliar o impacto da priorização de tráfego de vídeo através de regras OpenFlow 1.3.

### Principais Características

- **Rede LTE Multi-cell** com handover X2 entre eNodeBs
- **Switch SDN** com OpenFlow 1.3 (OFSwitch13)
- **Avaliação de QoS e QoE** com EvalVid
- **Comparação automática** entre cenários COM e SEM SDN
- **Geração automática de gráficos** comparativos
- **Suporte completo a Docker** para reprodutibilidade

### Cenário de Simulação

```
   [UE1]---+                                    +---[VideoServer]
   [UE2]---+--[eNB1]--+             +--[SDN Switch]--+
   [UE3]---+          |             |                |
   [UE4]---+--[eNB2]--+--[PGW/SGW]--+                +---[Controller]
                      |
                    (X2)
```

---

## 🏗 Arquitetura do Projeto

```
ns-3-dev/
├── contrib/
│   ├── evalvid/              # Módulo EvalVid para avaliação de vídeo
│   └── ofswitch13/           # Módulo OpenFlow 1.3 para SDN
├── scratch/
│   ├── evalvid_lte_aval_x2.cc    # Simulação principal
│   └── lte-sdn-evalvid/          # Simulação LTE+SDN+EvalVid
│       ├── main.cc               # Código principal
│       ├── video-qos-controller.cc/h  # Controlador SDN
│       └── CMakeLists.txt
├── run_lte_sdn_evaluation.sh     # Script de avaliação comparativa
├── script_automação.sh           # Script de automação completa
├── generate_png_graphs.py        # Gerador de gráficos PNG
├── Dockerfile                    # Container Docker
├── docker-compose.yml            # Orquestração Docker
└── results_lte_sdn_*/            # Diretórios de resultados
```

---

## 📦 Requisitos

### Requisitos de Sistema

- **SO**: Ubuntu 20.04+ / Debian 11+ (ou Docker)
- **RAM**: Mínimo 4GB (recomendado 8GB)
- **CPU**: Multi-core recomendado
- **Disco**: ~5GB para instalação completa

### Dependências Principais

| Componente | Versão Mínima |
|------------|---------------|
| GCC/G++ | 9.0+ |
| CMake | 3.10+ |
| Python | 3.6+ |
| FFmpeg | 4.0+ |
| Gnuplot | 5.0+ |

---

## 🐳 Instalação com Docker

### Método Recomendado (Docker Compose)

```bash
# Clonar o repositório
git clone <repository-url>
cd ns-3-dev

# Construir a imagem
docker-compose build

# Iniciar o container
docker-compose up -d

# Acessar o terminal
docker-compose exec ns3 bash
```

### Método Alternativo (Docker direto)

```bash
# Construir a imagem
docker build -t ns3-lte-sdn-evalvid .

# Executar o container
docker run -it --name ns3-sim \
  -v $(pwd)/results:/ns-3/results \
  -v $(pwd)/scratch:/ns-3/scratch \
  ns3-lte-sdn-evalvid
```

### Comandos Docker Úteis

```bash
# Parar o container
docker-compose down

# Ver logs
docker-compose logs -f ns3

# Executar comando específico
docker-compose exec ns3 ./ns3 run "scratch/evalvid_lte_aval_x2"

# Iniciar Jupyter Notebook (opcional)
docker-compose --profile jupyter up -d
# Acessar em: http://localhost:8889 (token: ns3)
```

---

## 🔧 Instalação Manual

### 1. Instalar Dependências (Ubuntu/Debian)

```bash
# Dependências básicas
sudo apt-get update
sudo apt-get install -y build-essential g++ cmake ninja-build ccache \
    git python3 python3-pip python3-dev \
    libsqlite3-dev libgsl-dev libxml2-dev libgtk-3-dev libboost-all-dev

# Dependências EvalVid
sudo apt-get install -y ffmpeg libavcodec-dev libavformat-dev x264 gnuplot

# Dependências OFSwitch13/SDN
sudo apt-get install -y libpcap-dev libxerces-c-dev libevent-dev libssl-dev

# Dependências Python
pip3 install cppyy==2.4.2 numpy pandas matplotlib scipy
```

### 2. Compilar o BOFUSS (ofsoftswitch13)

```bash
cd /tmp
git clone https://github.com/ljerezchaves/ofsoftswitch13.git bofuss
cd bofuss
./boot.sh
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install
sudo ldconfig
```

### 3. Compilar o NS-3

```bash
cd ns-3-dev

# Configurar
./ns3 configure --enable-examples --enable-tests -d optimized

# Compilar
./ns3 build -j$(nproc)
```

---

## 🚀 Scripts de Automação

### Script 1: `run_lte_sdn_evaluation.sh`

**Propósito**: Executa avaliação comparativa entre cenários COM e SEM SDN.

```bash
./run_lte_sdn_evaluation.sh
```

#### O que faz:

1. **Cenário 1 (SEM SDN)**: Executa simulação com switch como comutador normal
2. **Cenário 2 (COM SDN)**: Executa simulação com priorização de vídeo via OpenFlow
3. **Coleta métricas**: QoS (Delay, Jitter, Throughput, Packet Loss) e QoE (PSNR, MOS)
4. **Gera gráficos**: Comparativos em PNG usando matplotlib/gnuplot
5. **Cria relatório**: `RELATORIO_FINAL.txt` com análise completa

#### Parâmetros Configuráveis (no script):

```bash
NUM_ENBS=2           # Número de eNodeBs
NUM_UES=6            # Número de UEs (3-6)
SIM_TIME=60          # Tempo de simulação em segundos
VIDEO1="st_highway_cif.st"   # Vídeo 1 (cenas de estrada)
VIDEO2="football.st"         # Vídeo 2 (cenas de esporte)
```

#### Saída:

```
results_lte_sdn_YYYYMMDD_HHMMSS/
├── log_SEM_SDN.txt           # Log cenário sem SDN
├── log_COM_SDN.txt           # Log cenário com SDN
├── RELATORIO_FINAL.txt       # Relatório completo
├── metrics/
│   ├── QoS_SEM_SDN.txt       # Métricas QoS
│   ├── QoS_COM_SDN.txt
│   ├── QoE_SEM_SDN.txt       # Métricas QoE
│   └── QoE_COM_SDN.txt
├── graphs/
│   ├── delay_*.csv           # Dados de delay
│   ├── throughput_*.csv      # Dados de throughput
│   └── psnr_*.csv            # Dados de PSNR
└── comparison/
    ├── delay_comparison.png      # Gráfico comparativo
    ├── throughput_comparison.png
    ├── psnr_comparison.png
    └── jitter_comparison.png
```

---

### Script 2: `script_automação.sh`

**Propósito**: Pipeline completo de avaliação de qualidade de vídeo com variação de parâmetros.

```bash
./script_automação.sh
```

#### Etapas do Pipeline:

| Etapa | Descrição |
|-------|-----------|
| 1️⃣ | **Pré-processamento**: Codifica vídeo para M4V, cria HINT track, gera trace |
| 2️⃣ | **PSNR Referência**: Calcula PSNR de referência (vídeo original vs codificado) |
| 3️⃣ | **Simulações NS-3**: Executa N simulações variando número de UEs |
| 4️⃣ | **Reconstrução**: Reconstrói vídeos recebidos usando EvalVid |
| 5️⃣ | **Métricas**: Calcula PSNR, Throughput, Loss, Delay, Jitter |
| 6️⃣ | **Gráficos**: Gera gráficos com Gnuplot |
| 7️⃣ | **Relatório**: Gera relatório consolidado |

#### Parâmetros Configuráveis:

```bash
VIDEO_INPUT="${NS3_DIR}/videos/football.y4m"  # Vídeo de entrada
NUM_SIMULATIONS=5    # Número de simulações
PARAM_START=5        # UEs inicial
PARAM_STEP=2         # Incremento de UEs por simulação
```

#### Saída:

```
results_YYYYMMDD_HHMMSS/
├── videos/
│   ├── football.m4v          # Vídeo codificado
│   ├── football.mp4          # Vídeo com HINT track
│   └── reconstructed/        # Vídeos reconstruídos
├── traces/
│   └── st_football.st        # Trace EvalVid
├── simulations/
│   └── sim_N/                # Dados de cada simulação
├── metrics/
│   ├── consolidated_metrics.dat  # Métricas consolidadas
│   └── ref_psnr.txt              # PSNR de referência
├── graphs/
│   └── metrics_graph.png     # Gráfico multi-painel
└── RELATORIO.txt             # Relatório final
```

---

## 🎮 Executando Simulações

### Execução Básica

```bash
# Compilar (se necessário)
./ns3 build

# Executar simulação LTE+SDN+EvalVid
./ns3 run "evalvid_lte_aval_x2 --numUes=4 --simTime=60 --enableSdn=true"
```

### Parâmetros da Simulação

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `--numEnbs` | int | 2 | Número de eNodeBs |
| `--numUes` | int | 4 | Número de UEs (3-6) |
| `--simTime` | double | 60.0 | Tempo de simulação (segundos) |
| `--enableSdn` | bool | true | Ativa priorização SDN |
| `--verbose` | bool | false | Logs detalhados |
| `--trace` | bool | false | Gera traces pcap |
| `--video1` | string | st_highway_cif.st | Arquivo trace vídeo 1 |
| `--video2` | string | football.st | Arquivo trace vídeo 2 |
| `--outputPrefix` | string | sdn | Prefixo arquivos saída |

### Exemplos de Uso

```bash
# Cenário SEM SDN
./ns3 run "evalvid_lte_aval_x2 --enableSdn=false --numUes=6"

# Cenário COM SDN e logs detalhados
./ns3 run "evalvid_lte_aval_x2 --enableSdn=true --verbose=true"

# Simulação longa com traces
./ns3 run "evalvid_lte_aval_x2 --simTime=120 --trace=true"
```

---

## 📊 Estrutura de Resultados

### Arquivos de Saída

| Arquivo | Descrição |
|---------|-----------|
| `sd_a01_lte_ue*` | Trace de pacotes enviados (sender) |
| `rd_a01_lte_ue*` | Trace de pacotes recebidos (receiver) |
| `QoS_vazao.txt` | Throughput por fluxo |
| `QoS_perda.txt` | Perda de pacotes por fluxo |
| `QoS_delay.txt` | Delay médio por fluxo |
| `QoS_jitter.txt` | Jitter por fluxo |
| `QoS_flowmonitor.xml` | Dados completos FlowMonitor |

---

## 📈 Métricas Coletadas

### Métricas de QoS (Quality of Service)

| Métrica | Unidade | Descrição |
|---------|---------|-----------|
| **Delay** | ms | Atraso fim-a-fim médio |
| **Jitter** | ms | Variação do atraso |
| **Throughput** | Mbps | Vazão média |
| **Packet Loss** | % | Taxa de perda de pacotes |

### Métricas de QoE (Quality of Experience)

| Métrica | Unidade | Descrição |
|---------|---------|-----------|
| **PSNR** | dB | Peak Signal-to-Noise Ratio |
| **MOS** | 1-5 | Mean Opinion Score (estimado) |
| **Frames Lost** | count | Frames perdidos |

### Interpretação dos Resultados

**PSNR (dB)**:
- > 40 dB: Excelente qualidade
- 30-40 dB: Boa qualidade
- 20-30 dB: Qualidade aceitável
- < 20 dB: Qualidade ruim

**Impacto Esperado do SDN**:
- ✅ Redução do delay médio
- ✅ Menor variação de jitter
- ✅ PSNR mais elevado
- ✅ Menor perda de pacotes para vídeo

---

## 📚 Documentação NS-3

### Links Úteis

- [Site oficial NS-3](https://www.nsnam.org)
- [Documentação](https://www.nsnam.org/documentation/)
- [API Doxygen](https://www.nsnam.org/doxygen/index.html)
- [Wiki](https://www.nsnam.org/wiki/)
- [OFSwitch13](http://www.lrc.ic.unicamp.br/ofswitch13/)
- [EvalVid](http://www.tkn.tu-berlin.de/research/evalvid/)

### Comandos NS-3 Úteis

```bash
# Configurar build
./ns3 configure --enable-examples --enable-tests -d optimized

# Compilar
./ns3 build -j$(nproc)

# Listar programas disponíveis
./ns3 show targets

# Ver versão
./ns3 show version

# Executar testes
./ns3 run test-runner
```

---

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, siga as diretrizes em [CONTRIBUTING.md](CONTRIBUTING.md).

## 📄 Licença

Este projeto está licenciado sob a GPLv2 - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

## 📞 Suporte

Para dúvidas e problemas:
- Abra uma [Issue](../../issues) no repositório
- Consulte a [Wiki do NS-3](https://www.nsnam.org/wiki/)
- Lista de discussão: [ns-3-users](https://groups.google.com/g/ns-3-users)
