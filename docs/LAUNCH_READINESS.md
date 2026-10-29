# Revisão de lançamento — 0.71.0 / schema18

Revisão local em 27/10/2026. Nenhuma publicação, acesso a dados reais ou compra
foi feita. As verificações simulam serviços; não certificam o Roblox Studio.

## Implementado nesta revisão

- Métricas de comportamento desde0.71.0: tempo/sessões, vendas, skill checks,
  upgrades, coletas, prestígio e contexto de premium, com totais persistidos,
  logs limitados, Analytics nativo e relatório por UserId apenas no servidor.
  Cliques/foco relatados são estimativas; recibos e resultados continuam no
  servidor. Consulte PLAYER_ANALYTICS.md; dashboards reais ainda não testados.
- Tela inicial pixelada com START/CONTINUE, HOW TO PLAY, estado real da conexão
  e do salvamento. Gameplay fica pausado até entrar. RECONNECT aparece após
  espera limitada e não repete compras nem vendas.
- Tutorial com quatro máscaras cinza, área da ação livre e diálogo pixelado.
  Avança por GOOD/GREAT confirmado, venda confirmada e coleta confirmada de um
  visitante real. Não inventa tokens, visitantes ou recompensas. O círculo usa
  mais espaço durante sua lição, a loja fica oculta e o SELL é trazido à vista.
  Um visitante real muda só de posição visual para não ficar sob o diálogo;
  identidade, raridade, prazo e recompensa continuam os mesmos.
- Pular, concluir e repetir no Guide. Upgrades de Auto check/Auto sell ficam
  suspensos no tutorial para não resolver as lições sozinhos. A preferência de
  não repetir o tutorial é salva e permanece após prestígio.
- Publicado: DATASTORE automático, namespace VibeIdle_Profiles_v1, chave por
  UserId. Studio/local: MEMORY. Configuração comercial continua desativada/IDs0.
- Correção concreta: leases agora consultam o horário dentro da transformação
  UpdateAsync. Uma resposta de rede atrasada não reutiliza o horário antigo
  para gravar com sessão expirada.
- SAVE DELAYED visível. Erro no carregamento nunca vira perfil padrão que possa
  sobrescrever os dados reais; lease perdido/expirado pausa a progressão.

## O que é salvo

Dinheiro, upgrades, agentes, cartas/deck, fragmentos, Chips, skills, prestígio,
ganhos vitalícios, benefícios/comprovantes premium, tutorialDone e métricas desde
0.71.0. Schema18 migra1..17 sem inventar dinheiro/cartas/benefícios ou histórico.
Tokens não vendidos, streak,
animações, posições e ajustes locais de áudio/movimento são de sessão.

Autosave a cada60s; saída e encerramento tentam a gravação final, preservando
as proteções contra gravações/compras concorrentes. Falhas podem perder mudanças
desde o último save confirmado; não há promessa de perda zero em falhas de rede.
O menu e Guide distinguem nuvem e sessão local. Não altere nomes de stores após
receber jogadores: trocar namespace abre outro conjunto de perfis.

## Integridade verificada localmente

Economia e sorteios continuam no servidor; vendas, compras, crafting, prestígio,
coleta e buffs usam seus caminhos existentes e IDs/deduplicação. Um tutorial
não concede moeda nem abre outro caminho de pagamento. A opção tutorial_complete
aceita apenas requestId inteiro limitado e altera uma preferência cosmética.
Migração estrita, cópia, preservação em prestígio, lease atrasado/expirado,
autosave, saída/reentrada, load/save com falha, isolamento Studio e comandos
forjados têm regressões. O ciclo guiado testa respostas atrasadas e não avança
por clique sem confirmação. Máscara/diálogo/ação são conferidos em tamanhos
1280x720,360x640 e320x360; previews usam fonte aproximada.

Evidência completa: build/launch-onboarding-verification.log e task113.
Resultado:295 testes puros e243 cenários de cliente/servidor passaram, com64
fontes verificadas e build determinístico de106 instâncias/61 fontes. Após o
último ajuste de texto,8 cenários novos e a exportação foram conferidos novamente.

## Antes de abrir ao público

1. Abrir o build no Studio e conferir fonte PressStart, safe insets, diálogo,
   mouse/toque, teclado, navegação por controle, rolagem e janela curta. Conferir
   SELL também no fluxo normal em celulares, onde a loja ocupa parte da largura.
2. Publicar primeiro em experiência privada de testes e, fora do Studio, jogar,
   sair e reentrar. Conferir todos os recursos, tutorial e comportamento de uma
   segunda sessão concorrente. Nuvem real não foi exercitada nesta revisão.
3. Conferir encerramento de servidor, sessão retomada e logs de Save failed /
   Profile lease expired. Não habilitar APIs do Studio no store de produção.
4. Monetização fica indisponível até configurar/testar produtos e passe conforme
   ROBux_SETUP.md; não ativar apenas porque o salvamento está preparado.

## Próximas features úteis (ainda não implementadas)

- Preferências salvas de áudio e movimento reduzido.
- Objetivos curtos após o tutorial: primeira melhoria, primeiro craft e primeiro
  prestígio, com progresso vindo dos recibos existentes.
- Conquistas de coleção e marcos de prestígio, sem notificações repetidas.

Referências oficiais conferidas nesta revisão: [Data stores e isolamento do
Studio](https://create.roblox.com/docs/cloud-services/data-stores) e [dados de
jogadores, leases e compras](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing).
