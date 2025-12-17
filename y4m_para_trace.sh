#!/bin/bash

# Script para converter arquivo y4m em arquivo trace .st
# Uso: ./y4m_to_trace.sh <arquivo.y4m>

set -e

# Diretório do script (para encontrar o mp4trace)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se foi passado um argumento
if [ $# -eq 0 ]; then
    echo -e "${RED}Erro: Nenhum arquivo especificado${NC}"
    echo "Uso: $0 <arquivo.y4m>"
    echo "Exemplo: $0 videos/ice_cif.y4m"
    exit 1
fi

INPUT_FILE="$1"

# Verifica se o arquivo existe
if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}Erro: Arquivo '$INPUT_FILE' não encontrado${NC}"
    exit 1
fi

# Verifica se é um arquivo y4m
if [[ ! "$INPUT_FILE" =~ \.y4m$ ]]; then
    echo -e "${YELLOW}Aviso: O arquivo não tem extensão .y4m${NC}"
fi

# Extrai o nome base do arquivo (sem caminho e sem extensão)
BASENAME=$(basename "$INPUT_FILE" .y4m)
DIRNAME=$(dirname "$INPUT_FILE")

# Define os arquivos de saída
MP4_FILE="${BASENAME}.mp4"
ST_FILE="${BASENAME}.st"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Conversão Y4M para Trace ST${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Arquivo de entrada: $INPUT_FILE"
echo "Arquivo MP4 intermediário: $MP4_FILE"
echo "Arquivo trace de saída: $ST_FILE"
echo ""

# Passo 1: Converte y4m para mp4
echo -e "${YELLOW}[1/3] Convertendo Y4M para MP4...${NC}"
ffmpeg -y -i "$INPUT_FILE" -c:v libx264 -profile:v baseline "$MP4_FILE"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Conversão para MP4 concluída${NC}"
else
    echo -e "${RED}✗ Erro na conversão para MP4${NC}"
    exit 1
fi
echo ""

# Passo 2: Adiciona hint track para RTP/UDP streaming
echo -e "${YELLOW}[2/3] Adicionando hint track com MP4Box...${NC}"
MP4Box -hint "$MP4_FILE"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Hint track adicionado${NC}"
else
    echo -e "${RED}✗ Erro ao adicionar hint track${NC}"
    exit 1
fi
echo ""

# Passo 3: Gera o arquivo trace .st
echo -e "${YELLOW}[3/3] Gerando arquivo trace .st...${NC}"
"${SCRIPT_DIR}/contrib/evalvid/bin/mp4trace" -f "$MP4_FILE" > "${ST_FILE}.tmp"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Arquivo trace gerado${NC}"
else
    echo -e "${RED}✗ Erro ao gerar arquivo trace${NC}"
    exit 1
fi
echo ""

# Passo 4: Corrige os timestamps (substitui 'inf' por timestamps reais)
echo -e "${YELLOW}[4/4] Corrigindo timestamps do arquivo trace...${NC}"

# Obtém o framerate do vídeo MP4
FRAMERATE=$(ffprobe -v error -select_streams v:0 -show_entries stream=r_frame_rate -of default=noprint_wrappers=1:nokey=1 "$MP4_FILE" 2>/dev/null | head -1)

# Calcula o intervalo entre frames usando awk (converte fração para decimal)
if [[ "$FRAMERATE" == *"/"* ]]; then
    NUM=$(echo "$FRAMERATE" | cut -d'/' -f1)
    DEN=$(echo "$FRAMERATE" | cut -d'/' -f2)
    FRAME_INTERVAL=$(awk "BEGIN {printf \"%.6f\", $DEN / $NUM}")
else
    FRAME_INTERVAL=$(awk "BEGIN {printf \"%.6f\", 1 / $FRAMERATE}")
fi

echo "Framerate detectado: $FRAMERATE (intervalo: ${FRAME_INTERVAL}s)"

# Processa o arquivo trace e substitui 'inf' por timestamps calculados
awk -v interval="$FRAME_INTERVAL" '
BEGIN { time = 0.0 }
{
    if ($5 == "inf") {
        printf "%s\t%s\t%s\t%s\t%.3f\n", $1, $2, $3, $4, time
    } else {
        print $0
    }
    time += interval
}
' "${ST_FILE}.tmp" > "$ST_FILE"

rm -f "${ST_FILE}.tmp"

if [ -s "$ST_FILE" ]; then
    echo -e "${GREEN}✓ Timestamps corrigidos${NC}"
else
    echo -e "${RED}✗ Erro ao corrigir timestamps${NC}"
    exit 1
fi
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Conversão concluída com sucesso!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Arquivos gerados:"
echo "  - MP4: $MP4_FILE"
echo "  - Trace: $ST_FILE"
echo ""

# Mostra informações dos arquivos gerados
echo "Tamanhos dos arquivos:"
ls -lh "$MP4_FILE" "$ST_FILE" 2>/dev/null | awk '{print "  - " $9 ": " $5}'
