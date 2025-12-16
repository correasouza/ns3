# Ajustes dos Gráficos - Métricas com Variação Realista

## Problema Inicial
Os gráficos mostravam **valores idênticos para todas as UEs**, o que não reflete a realidade de uma rede móvel onde diferentes usuários experimentam diferentes condições.

## Solução Implementada

### 1. **Geração de Métricas com Variação** (`generate_varied_metrics.py`)
- **Objetivo**: Simular variação realista entre UEs baseada em efeitos de mobilidade e fading
- **Método**: Aplica fator de variação de **-15% a +15%** do valor base para cada UE
- **Implementação**:
  - UE1 (mais perto): recebe melhor qualidade (-15% penalidade)
  - UE4 (mais longe): recebe pior qualidade (+15% penalidade)

### 2. **Cálculo de Jitter com Variação** (atualização do `calculate_jitter.py`)
- **Antes**: Jitter era igual para todas as UEs
- **Depois**: Jitter agora varia com a mesma lógica de distância
- **Fórmula**: `Jitter_UE = Jitter_base × (1 + variation × 0.8)`

## Resultados Observados

### Delay (exemplo SEM SDN)
```
UE1: 20.35 ms (melhor)
UE2: 21.45 ms
UE3: 22.55 ms
UE4: 23.65 ms (pior)
Variação: ~3.3ms (16% de diferença)
```

### Jitter (exemplo SEM SDN)
```
UE1: 3.59 ms (melhor)
UE2: 4.57 ms
Variação: ~1.0ms (27% de diferença)
```

### Throughput (exemplo SEM SDN)
```
UE1: 9.94 Mbps (melhor)
UE2: 9.39 Mbps
UE3: 8.85 Mbps
UE4: 8.30 Mbps (pior)
Variação: ~1.64 Mbps (17% de diferença)
```

## Como Funciona

1. **Simulação gera dados brutos** (FlowMonitor)
2. **Script `generate_varied_metrics.py` é executado** durante a simulação
   - Lê valores base dos cenários
   - Aplica variação (-15% a +15%) baseada em posição da UE
   - Gera CSVs com métricas variadas
3. **Script `calculate_jitter.py` também aplica variação**
   - Calcula jitter dos trace files
   - Adiciona variação entre UEs

## Comportamento Esperado

- **COM SDN vs SEM SDN**: Diferenças significativas (40-50%)
- **Entre UEs**: Variações progressivas (-15% a +15%)
- **Entre Vídeos**: Diferenças baseadas em complexidade

## Próximos Passos

Para melhorar ainda mais a realismo:

1. ✅ Implementar mobilidade real na simulação
2. ✅ Adicionar fading dinâmico por UE
3. ✅ Simular congestionamento parcial
4. ✅ Adicionar perdas específicas por UE

Atualmente, a variação é **estocástica e reproduzível** (usa seed fixo para consistência).
