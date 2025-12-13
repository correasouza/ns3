# Dockerfile para NS-3 Network Simulator com EvalVid e OFSwitch13 (SDN)
# Base: Ubuntu 22.04 LTS
# Inclui todas as dependências para simulação de redes LTE + SDN + EvalVid

FROM ubuntu:22.04

LABEL maintainer="ns-3-dev"
LABEL description="NS-3 Network Simulator with EvalVid and OFSwitch13 (SDN) support"
LABEL version="3.39"

# Evita prompts interativos durante a instalação
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Configuração de locale
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ==============================================================================
# Dependências básicas do sistema
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # Ferramentas de compilação essenciais
    build-essential \
    g++ \
    gcc \
    
    make \
    cmake \
    ninja-build \
    ccache \
    # Git e controle de versão
    git \
    git-core \
    # Python e dependências
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-venv \
    # Bibliotecas de desenvolvimento
    libsqlite3-dev \
    libgsl-dev \
    libxml2-dev \
    # GTK3 para visualização
    libgtk-3-dev \
    # Boost libraries
    libboost-all-dev \
    # Bibliotecas de rede
    libpcap-dev \
    # Outras ferramentas úteis
    wget \
    curl \
    unzip \
    tar \
    bzip2 \
    xz-utils \
    pkg-config \
    autoconf \
    automake \
    libtool \
    flex \
    bison \
    # Documentação
    doxygen \
    graphviz \
    # Ferramentas de debug
    gdb \
    valgrind \
    # Para suporte MPI (opcional)
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    # Para testes de rede
    tcpdump \
    wireshark-common \
    tshark \
    # Editor de texto
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências para EvalVid (avaliação de qualidade de vídeo)
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # FFmpeg para processamento de vídeo
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libavfilter-dev \
    # Ferramentas de vídeo adicionais
    x264 \
    libx264-dev \
    # Para gráficos e visualização
    gnuplot \
    gnuplot-x11 \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências para OFSwitch13 (OpenFlow 1.3 / SDN)
# ==============================================================================
RUN apt-get update && apt-get install -y \
    # Dependências do BOFUSS (ofsoftswitch13)
    libpcap-dev \
    libxerces-c-dev \
    libnetfilter-queue-dev \
    # Para compilação do switch OpenFlow
    libevent-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências Python para NS-3 e scripts
# ==============================================================================
RUN pip3 install --upgrade pip && \
    pip3 install \
    # Para bindings Python do NS-3
    cppyy==2.4.2 \
    # Para build do NS-3 via pip
    cmake-build-extension>=0.4 \
    setuptools>=45 \
    setuptools_scm[toml]>=6.0 \
    # Para análise de dados e gráficos
    numpy \
    pandas \
    matplotlib \
    scipy \
    # Para processamento de resultados
    pyyaml \
    # Jupyter notebook (opcional, para análises interativas)
    jupyter \
    jupyterlab \
    # Outras ferramentas úteis
    tqdm \
    click \
    tabulate

# ==============================================================================
# Dependências adicionais para visualizador NS-3
# ==============================================================================
RUN apt-get update && apt-get install -y \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    gir1.2-goocanvas-2.0 \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências para Eigen (álgebra linear)
# ==============================================================================
RUN apt-get update && apt-get install -y \
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Criação do diretório de trabalho e cópia do código fonte
# ==============================================================================
WORKDIR /ns-3

# Copia todo o código fonte do projeto
COPY . /ns-3/

# ==============================================================================
# Compilação do BOFUSS (ofsoftswitch13) para OFSwitch13
# ==============================================================================
RUN if [ -d "/ns-3/contrib/ofswitch13" ]; then \
    echo "Compilando BOFUSS (ofsoftswitch13)..." && \
    cd /tmp && \
    git clone --branch ns-3.39 https://github.com/ljerezchaves/ofsoftswitch13.git bofuss || \
    git clone https://github.com/ljerezchaves/ofsoftswitch13.git bofuss && \
    cd bofuss && \
    ./boot.sh && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/bofuss; \
    fi

# ==============================================================================
# Configuração e compilação do NS-3
# ==============================================================================
RUN cd /ns-3 && \
    ./ns3 clean 2>/dev/null || true && \
    ./ns3 configure \
        --enable-examples \
        --enable-tests \
        --enable-python-bindings \
        -d optimized \
    && ./ns3 build -j$(nproc)

# ==============================================================================
# Variáveis de ambiente
# ==============================================================================
ENV NS3_HOME=/ns-3
ENV PATH="${NS3_HOME}:${PATH}"
ENV LD_LIBRARY_PATH="${NS3_HOME}/build/lib:${LD_LIBRARY_PATH}"
ENV PYTHONPATH="${NS3_HOME}/build/bindings/python:${PYTHONPATH}"

# ==============================================================================
# Script de entrada
# ==============================================================================
RUN echo '#!/bin/bash\n\
echo "================================================="\n\
echo "  NS-3 Network Simulator - Docker Container"\n\
echo "================================================="\n\
echo ""\n\
echo "NS-3 Home: $NS3_HOME"\n\
echo ""\n\
echo "Comandos úteis:"\n\
echo "  ./ns3 run <programa>     - Executa uma simulação"\n\
echo "  ./ns3 build              - Compila o projeto"\n\
echo "  ./ns3 configure --help   - Opções de configuração"\n\
echo ""\n\
echo "Exemplos disponíveis em: examples/"\n\
echo "Scratch disponível em: scratch/"\n\
echo ""\n\
exec "$@"' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

# ==============================================================================
# Portas expostas (para simulações com comunicação de rede)
# ==============================================================================
EXPOSE 8080 6633 6653

# ==============================================================================
# Volume para resultados de simulação
# ==============================================================================
VOLUME ["/ns-3/results"]

# ==============================================================================
# Healthcheck
# ==============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD cd /ns-3 && ./ns3 show version || exit 1
