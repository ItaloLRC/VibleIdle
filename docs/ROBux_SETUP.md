# Configuração da loja de Robux

A loja e a integração estão prontas para receber os IDs. Como solicitado, este
build continua com COMMERCE_ENABLED=false e IDs0: os cards mostram os
preços sugeridos e UNAVAILABLE. Nenhuma compra real é aberta nesse estado.
Desde0.70.0, Studio/local usam MEMORY; publicado usa DATASTORE automaticamente,
nos namespaces LIVE_DATASTORE_NAME e LIVE_COMMERCE_RECEIPTS_NAME. Isso não ativa
a loja. Veja também LAUNCH_READINESS.md para validar persistência em ambiente privado.

Crie os itens na mesma experiência publicada, no Creator Hub:

| Chave em COMMERCE_IDS | Tipo | Preço base sugerido | Benefício |
| --- | --- | ---: | --- |
| money_hour | Developer Product | 10 Robux | 2x dinheiro por1 hora real |
| chips_hour | Developer Product | 15 Robux | 2x novos Chips ao prestigiar por1 hora real |
| agent | Developer Product | 20 Robux | +1 agente nesta rodada |
| forever | Game Pass | 100 Robux | 2x dinheiro e2x Chips permanentemente |

Configure os preços no Creator Hub e copie os IDs para
src/server/ServerConfig.luau, nas chaves acima. O código não altera o preço
cadastrado no Roblox: a UI consulta GetProductInfoAsync no cliente e mostra o
preço real disponível para aquele jogador. O preço final é o da confirmação
nativa do Roblox. Sem cotação válida, o botão não abre a compra.

Para ativar posteriormente:

1. Preencha os quatro IDs reais, positivos e distintos, da própria experiência.
2. Confira o DATASTORE resolvido no servidor publicado. Os padrões0.70.0 são
   VibeIdle_Profiles_v1 e VibeIdle_ReceiptArchive_v1; Studio/local permanecem em
   MEMORY. Nunca use o store de NeuralIdle. Se já houver
   jogadores persistentes, mantenha o namespace de perfis existente para não
   trocar o progresso deles por um perfil vazio.
3. Ajuste COMMERCE_ENABLED=true. Em uma experiência publicada fora do Studio,
   o servidor libera apenas as ofertas com ID válido. Studio, MEMORY, IDs0,
   IDs duplicados ou experiência sem GameId continuam sem compras reais.
4. Confira UI/cotações, cancelamento, entrega confirmada, reentrada e salvamento
   antes de abrir a monetização ao público. Este harness não publicou a
   experiência, criou itens na conta nem efetuou compras reais.

Regras implementadas:

- Recomprar um boost soma1 hora à duração restante; o relógio continua offline.
  Um boost temporário e o passe permanente continuam em2x, sem multiplicar4x.
- Dinheiro dobra no pagamento confirmado de Enter/SELL. Valores não pagos pelo
  limite de dinheiro não aumentam lifetimeEarned.
- Chips dobram somente sobre os novos Chips base disponíveis no prestígio.
  bonusChips separa os extras já recebidos; expiração/reativação não libera
  Chips antigos novamente.20.800 Chips base permitem até41.600 com bônus pagos,
  com a mesma curva/cap de lifetime e os mesmos custos da árvore/crafting.
- O agente de20 Robux é um escritor normal desta rodada e reseta no prestígio,
  conforme o card informa. Se o recibo chegar com8 agentes, vira crédito salvo.
  USE CREDIT adiciona um agente quando houver espaço; créditos não usados ficam.
- Consumíveis são entregues apenas por ProcessReceipt. Benefício e comprovante
  pendente são salvos juntos no perfil com lease. Só depois o recibo é arquivado
  permanentemente e reconhecido ao Roblox. Falhas mantêm o recibo pendente;
  duplicatas nunca somam benefício duas vezes. CHECK finaliza comprovantes já
  conhecidos/consulta o passe, sem abrir nem repetir uma compra paga.
- O passe é verificado no servidor por UserOwnsGamePassAsync no ingresso e após
  o evento de compra. Fechar o prompt de um produto não entrega itens.
- Não remova IDs de produtos que já venderam enquanto houver recibos pendentes.
  Não apague/troque o namespace de recibos: ele mantém a deduplicação permanente.

Referências primárias usadas na implementação:
[Developer Products](https://create.roblox.com/docs/production/monetization/developer-products),
[ProcessReceipt e MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService#ProcessReceipt),
[Player data and purchasing](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing),
[Passes](https://create.roblox.com/docs/production/monetization/passes),
[Regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing).

Testes locais usam serviços e DataStores simulados. A verificação não estabelece
entrega/fluxo real do Marketplace, renderização/foco nativos, mixagem, desempenho
de dispositivos ou publicação. Luau type checking e QA nativo continuam pendentes.
