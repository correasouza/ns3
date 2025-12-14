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
RUN apt-get update && apt-get install -y locales \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# ==============================================================================
# Dependências básicas do sistema
# ==============================================================================
RUN apt-get update && apt-get install -y \
    build-essential \
    g++ \
    gcc \
    make \
    cmake \
    ninja-build \
    ccache \
    git \
    git-core \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-venv \
    libsqlite3-dev \
    libgsl-dev \
    libxml2-dev \
    libgtk-3-dev \
    libboost-all-dev \
    libpcap-dev \
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
    doxygen \
    graphviz \
    gdb \
    valgrind \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev \
    tcpdump \
    wireshark-common \
    tshark \
    vim \
    nano \
    dos2unix \
    sed \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências para EvalVid (avaliação de qualidade de vídeo)
# ==============================================================================
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libavfilter-dev \
    x264 \
    libx264-dev \
    gnuplot \
    gnuplot-x11 \
    imagemagick \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências para OFSwitch13 (OpenFlow 1.3 / SDN)
# ==============================================================================
RUN apt-get update && apt-get install -y \
    libpcap-dev \
    libxerces-c-dev \
    libnetfilter-queue-dev \
    libevent-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Dependências Python para NS-3 e scripts
# ==============================================================================
RUN pip3 install --upgrade pip \
    && pip3 install \
    cppyy==2.4.2 \
    cmake-build-extension \
    setuptools \
    setuptools_scm \
    numpy \
    pandas \
    matplotlib \
    scipy \
    pyyaml \
    jupyter \
    jupyterlab \
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
    libeigen3-dev \
    && rm -rf /var/lib/apt/lists/*

# ==============================================================================
# Criação do diretório de trabalho
# ==============================================================================
WORKDIR /usr/ns-3-dev

# Copia todo o código fonte do projeto
COPY . /usr/ns-3-dev/

# ==============================================================================
# CRÍTICO: Converter line endings de CRLF (Windows) para LF (Unix)
# Isso resolve o erro: /usr/bin/env: 'python3\r': No such file or directory
# ==============================================================================
RUN find /usr/ns-3-dev -type f -name "ns3" -exec sed -i 's/\r$//' {} \; \
    && find /usr/ns-3-dev -type f -name "*.py" -exec sed -i 's/\r$//' {} \; \
    && find /usr/ns-3-dev -type f -name "*.sh" -exec sed -i 's/\r$//' {} \; \
    && chmod +x /usr/ns-3-dev/ns3

# ==============================================================================
# Compilação do BOFUSS (ofsoftswitch13) para OFSwitch13
# ==============================================================================
RUN if [ -d "/usr/ns-3-dev/contrib/ofswitch13" ]; then \
    echo "Compilando BOFUSS (ofsoftswitch13)..." \
    && cd /tmp \
    && git clone https://github.com/ljerezchaves/ofsoftswitch13.git bofuss \
    && cd bofuss \
    && autoreconf -i \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && rm -rf /tmp/bofuss; \
    fi

# ==============================================================================
# Configuração e compilação do NS-3
# ==============================================================================
RUN cd /usr/ns-3-dev \
    && (./ns3 clean 2>/dev/null || true) \
    && ./ns3 configure \
        --enable-examples \
        --enable-tests \
        --enable-python-bindings \
        -d optimized \
    && ./ns3 build -j$(nproc)

# ==============================================================================
# Variáveis de ambiente
# ==============================================================================
ENV NS3_HOME=/usr/ns-3-dev
ENV PATH="/usr/ns-3-dev:${PATH}"
ENV LD_LIBRARY_PATH="/usr/ns-3-dev/build/lib"
ENV PYTHONPATH="/usr/ns-3-dev/build/bindings/python"

# ==============================================================================
# Script de entrada
# ==============================================================================
RUN printf '#!/bin/bash\n\
echo "================================================="\n\
echo "  NS-3 Network Simulator - Docker Container"\n\
echo "================================================="\n\
echo ""\n\
echo "NS-3 Home: $NS3_HOME"\n\
echo ""\n\
echo "Comandos uteis:"\n\
echo "  ./ns3 run <programa>     - Executa uma simulacao"\n\
echo "  ./ns3 build              - Compila o projeto"\n\
echo "  ./ns3 configure --help   - Opcoes de configuracao"\n\
echo ""\n\
echo "Exemplos disponiveis em: examples/"\n\
echo "Scratch disponivel em: scratch/"\n\
echo ""\n\
exec "$@"\n' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]

# ==============================================================================
# Portas expostas (para simulações com comunicação de rede)
# ==============================================================================
EXPOSE 8080 6633 6653

# ==============================================================================
# Volume para resultados de simulação
# ==============================================================================
VOLUME ["/usr/ns-3-dev/results"]

# ==============================================================================
# Healthcheck
# ==============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD cd /usr/ns-3-dev && ./ns3 show version || exit 1
