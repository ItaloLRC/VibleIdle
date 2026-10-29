# Medir o comportamento dos jogadores — 0.71.0

As métricas passam a existir a partir deste build. A migração não inventa o
histórico anterior. Os totais ficam no mesmo perfil salvo do jogador e continuam
após prestígio. Studio/MEMORY continuam temporários; publicado usa o DataStore
VibeIdle já configurado. Não foi feita publicação nem coleta real nesta tarefa.

## O que é registrado

| Campo em `totals` | Significado |
| --- | --- |
| `sessions`, `onlineSeconds` | Entradas com perfil carregado e segundos conectado, incluindo menu/AFK |
| `focusedSecondsReported` | Estimativa de tempo com a janela elegível/focada, relatada pelo cliente; não prova atividade humana |
| `sellButtonReported`, `sellEnterReported` | Ativações elegíveis de SELL e Enter, incluindo tentativas vazias/ocupadas |
| `sales`, `saleRejected` | Vendas confirmadas e pedidos de venda rejeitados pelo servidor |
| `tokensSold`, `moneyEarned` | Tokens vendidos e dinheiro efetivamente pago em vendas confirmadas |
| `skillGood`, `skillGreat`, `skillMiss` | Resultados manuais consumidos pelo servidor; Normal é erro |
| `skillRejected`, `autoChecks` | Pedidos manuais recusados e verificações automáticas, separados dos acertos manuais |
| `upgradePurchases` | Transações bem-sucedidas por `upgrade_compute`, `add_layer`, `upgrade_tokens` |
| `upgradeLevels` | Quantos níveis/agentes foram comprados; compra5x soma uma transação e cinco níveis |
| `skills`, `crafts` | Desbloqueios por ID de skill e crafts por ID da carta |
| `visitors`, `fragmentsCollected`, `prestiges` | Coletas únicas, fragmentos realmente concedidos e prestígios confirmados |
| `tutorialDismissed` | Primeira conclusão ou opção de pular; não diferencia essas duas escolhas |
| `robuxPrompts` | Diálogos nativos abertos por SKU |
| `robuxCanceled`, `robuxUnavailable` | Cancelamentos e indisponibilidades/erros de abertura por SKU |
| `robuxDelivered` | Produtos concedidos pelo recibo e primeira descoberta de posse do passe |
| `firstRobux` | Contexto da primeira concessão/posse premium observada desde esta versão |
| `recent` | Últimos24 eventos de upgrade/skill/craft/prestígio/premium/tutorial/saída |

Chaves ausentes nos mapas significam zero. Os totais têm teto de1e15; não são
saldo nem mudam a economia. Tempo é contado no relógio do servidor, sem tempo
offline. Relatos de foco e cliques são estimativas: chegam em lotes de15s,
podem perder os últimos segundos no fechamento e não devem ser usados como
prova de ação ou segurança. Pulsos repetidos/rápidos são rejeitados e os deltas
são limitados. Vendas, grades, upgrades e entregas vêm dos caminhos do servidor.

## Em que momento compram Robux

Os eventos `robux_prompt`, `robux_delivered`, `robux_cancel`, `robux_unavailable`
e `pass_owned` incluem SKU, timestamp Unix UTC, segundos nesta sessão, tempo
total conectado, número da sessão, estágio econômico, agentes, nível do Token
value, contexto, prestígios, dinheiro e Chips. O primeiro contexto premium fica
guardado em `firstRobux` mesmo quando sai da lista `recent`.

Abrir ou fechar um diálogo não é compra. Produtos contam uma vez na aplicação
do benefício, junto do comprovante salvo; repetir recibo, CHECK, sync ou retry
não soma novamente. `pass_owned` significa posse verificada no servidor e pode
ser descoberta de uma compra antiga. Entrega após reentrada registra o momento
da entrega nesta sessão, não uma data de compra presumida. Não estimamos Robux
gastos pelos preços sugeridos; use a monetização oficial do Roblox para receita.

## Consultar um jogador

Durante Play, selecione o contexto **Server** da Command Bar do Studio. Troque o
ID pelo UserId real positivo do jogador:

```lua
local report = game:GetService("ServerStorage")
    :WaitForChild("VibeIdleAnalyticsReport"):Invoke(123456789)
print(game:GetService("HttpService"):JSONEncode(report))
```

Jogador nesta instância: retorna `totals`, diferenças da sessão em `session`,
`sessionSeconds`, `sessionId`, build e eventos descartados. Jogador fora desta
instância: em DATASTORE retorna `scope="last_saved"` e o último perfil salvo,
que pode estar atrasado em relação a outro servidor. Em MEMORY só é possível
consultar quem está carregado. IDs inválidos/perfis indisponíveis retornam `error`.
O relatório não adquire lease nem grava dados; o tempo da sessão atual apenas
é atualizado pelo mesmo contabilizador normal.

Esse BindableFunction fica no ServerStorage, sem RemoteEvent de administração
e sem acesso pelo cliente. Não o exponha em um remote público. Em testes com
UserIds fictícios negativos, use os resumos do Output.
O histórico de métricas não é enviado nos snapshots de gameplay; use este
relatório do servidor para os valores reais, inclusive durante o desenvolvimento.

Exemplo de leitura:

```lua
local a = report.totals
print("Minutos totais:", a.onlineSeconds / 60)
print("Cliques SELL relatados:", a.sellButtonReported)
print("Vendas confirmadas:", a.sales)
local attempts = a.skillGood + a.skillGreat + a.skillMiss
print("Acertos (%):", attempts > 0 and 100 * (a.skillGood + a.skillGreat) / attempts or 0)
print("Níveis de Token value:", a.upgradeLevels.upgrade_compute or 0)
```

## Gráficos no Creator Hub

`SEND_ANALYTICS=true` habilita eventos nativos somente em servidores publicados,
fora do Studio. No Creator Hub da experiência, use Analytics/Explore para os
custom events. O Roblox agrega esses dados; os gráficos podem levar até24h
para aparecer. [Documentação oficial de custom events](https://create.roblox.com/docs/production/analytics/custom-events).

| Evento | Value / filtro CustomField01 |
| --- | --- |
| `CoreAction` | Quantidade; filtre `sales`, `skillGood`, `skillGreat`, `skillMiss`, upgrades ou fases premium/SKU |
| `UpgradeLevels` | Níveis comprados por tipo de upgrade |
| `OnlineSeconds` | Segundos conectado |
| `FocusedSecondsReported` | Segundos estimados por página |
| `SellInputReported` | Cliques `button` e comandos `enter` relatados |
| `PageSeenReported` | Página observada no pulso; visitas muito rápidas podem não aparecer |
| `RobuxSessionSeconds` | Soma do tempo de sessão ao abrir/receber premium, por fase/SKU |

`CustomField02` é o estágio econômico; `CustomField03` é a versão do build.
Use **soma de Value**, não número de chamadas: os eventos são agregados em
lotes. Para tempo médio até uma compra/entrega, divida a soma de
RobuxSessionSeconds pelo total CoreAction da mesma fase/SKU. Não use a média
por lote como média por compra. As métricas individuais completas ficam nos
relatórios; UserIds e sessionIds não viram custom fields de alta cardinalidade.

Envio a cada15s, até4 chamadas por lote, orçamento8/min por jogador com burst4,
fila de64 chaves e uma tentativa adicional limitada em falhas. FIFO evita
inanição de eventos menos frequentes. Contadores do perfil continuam mesmo se
a API falhar ou a fila descartar eventos. Analytics nativo é best effort, não
livro financeiro nem garantia de entrega exatamente uma vez. Os limites foram
conferidos na [documentação oficial de tipos/limites](https://create.roblox.com/docs/production/analytics/event-types)
e [custom fields](https://create.roblox.com/docs/production/analytics/custom-fields).

## Logs e configuração

`ANALYTICS_LOGS=true` imprime resumos JSON `[VibeIdle:analytics]` no servidor a
cada60s e na saída. Incluem UserId, sessionId, totais e diferenças da sessão,
além de contexto recente. Não há log/tarefa por clique, chamadas HTTP externas,
chat, textos digitados, nome, IP ou localização. Os logs do servidor não são um
arquivo histórico permanente; os totais persistidos e o Analytics são as formas
de consulta durável, sujeitas ao autosave e à entrega de eventos.

Desligar SEND_ANALYTICS afeta o envio nativo; ANALYTICS_LOGS afeta o Output.
Os contadores continuam no perfil. Comércio segue desabilitado/IDs0 até sua
configuração independente. Teste relatórios, save/reentrada, quedas de rede,
painéis reais e cancelamento/recuperação de recibos em experiência privada antes
de usar as métricas em decisões. Nenhum desses serviços reais foi acionado aqui.
