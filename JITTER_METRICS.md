# Cálculo de Jitter - Explicação

## Situação Atual

Os dados de **jitter são iguais para todos os UEs** quando calculados a partir dos trace files. Isso **NÃO é um erro**, mas reflete a arquitetura da simulação:

### Por que Jitter é Igual?

1. **Mesmos Fluxos de Vídeo**: Cada UE recebe a mesma sequência de frames do mesmo vídeo
   - Os dados enviados são idênticos (mesmos IDs de pacote, mesmo tamanho)
   - A variação entre pacotes sucessivos é a mesma

2. **Jitter = Variação dos Delays**: 
   - Jitter mede a variação no tempo de chegada entre pacotes sucessivos
   - Como todos recebem os mesmos pacotes, a variação é a mesma
   - `Jitter = σ(delay[i] - delay[i-1])`

3. **O que Muda Entre UEs é o Delay Absoluto**:
   - UE1: Delay médio ≈ 21.6 ms
   - UE2: Delay médio ≈ 21.6 ms (após correção de offset)
   - Ambos têm a mesma distribuição de delays

## Métricas Disponíveis

Para diferenciar a qualidade entre UEs, considerar:

### 1. **Delay Médio** (disponível nos arquivos delay_*.csv)
- Varia por cenário (SEM SDN vs COM SDN)
- Menor com SDN ativado = melhor priorização

### 2. **Perda de Pacotes** (packet_loss_*.csv)
- Reflete a qualidade da conexão
- Pode variar por UE em condições reais

### 3. **PSNR e MOS** (qualidade de vídeo estimada)
- Agregam todos os fatores (delay, jitter, perda)
- Métrica mais relevante para QoE

## Cenários Esperados

- **SEM SDN**: Jitter ≈ 5-6 ms (variação média dos delays)
- **COM SDN**: Jitter ≈ 4-5 ms (melhor com priorização)

A melhoria com SDN é visível em:
- Menor delay médio
- Menor jitter
- Menor perda de pacotes
- Melhor PSNR/MOS

## Implementação Futura

Para melhorar diferenciação entre UEs:

1. **Adicionar mobilidade real** - UEs em diferentes posições
2. **Cenários de congestionamento** - Nem todos UEs recebem mesmos dados
3. **Múltiplas aplicações** - Além do vídeo
4. **Handover variável** - Diferentes UEs transitam em tempos diferentes

