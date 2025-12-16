#!/bin/bash
# Corrige arquivos .st com timestamp 'inf' - gera timestamps baseados no framerate

if [ -z "$1" ]; then
    echo "Uso: $0 arquivo.st [fps]"
    exit 1
fi

FILE="$1"
FPS="${2:-30}"  # Default 30 fps
INTERVAL=$(echo "scale=3; 1/$FPS" | bc)

echo "Corrigindo $FILE com $FPS fps (intervalo: ${INTERVAL}s)..."

# Backup
cp "$FILE" "${FILE}.bak"

# Corrige timestamps
awk -v interval="$INTERVAL" '{
    if ($5 == "inf" || $5 == "") {
        $5 = sprintf("%.3f", (NR-1) * interval)
    }
    print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5
}' "${FILE}.bak" > "$FILE"

echo "Corrigido! Novo conteúdo:"
head -5 "$FILE"
