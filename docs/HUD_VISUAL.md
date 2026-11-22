# HUD: caderno e painel do expediente

O estoque do balcão aparece em uma página de caderno com couro, papel e detalhes
de latão. Cada forma liberada tem o ícone da peça produzida e sua quantidade.
As moedas aparecem abaixo do estoque. O campo “Nas mãos” mostra separadamente
a peça ou o molde carregado, sem somar esse objeto às entregas depositadas.

O painel superior usa uma placa de madeira e metal com ciclo, cronômetro,
entregas e pedidos perdidos. Durante a preparação, indica que o atendimento
deve ser iniciado no balcão. O texto fixo de controles no rodapé foi removido.
As instruções da tela inicial e das interfaces de montagem continuam disponíveis.

## Fonte

`assets/fonts/m5x7.ttf` é uma cópia do novo arquivo fornecido pelo usuário.
O projeto define `gui/theme/custom_font` e o tema da bancada usa a mesma fonte.
Isso inclui HUD, notificações, balões, botões e textos do cenário. A fonte possui
os acentos portugueses verificados nos testes. A importação desativa antialiasing
e posicionamento subpixel para manter a aparência pixelada. Foram ajustados os
tamanhos do painel superior, textos da bancada e balão do cliente para legibilidade.

O primeiro ciclo também possui o [tutorial contextual do Art](ART_TUTORIAL.md).

Referência para a configuração global: [documentação do Godot](https://docs.godotengine.org/en/latest/tutorials/ui/gui_skinning.html).

## Arte

Fundos gerados com a habilidade imagegen, sem texto incorporado. Todos os textos,
ícones e contadores são elementos nativos do Godot sobre as imagens.

- `assets/textures/ui/counter_notebook_v1.png`: página do caderno.
- `assets/textures/ui/shift_plaque_v1.png`: placa do expediente, com recorte por AtlasTexture.

Prompt final do caderno:

> Use case: stylized-concept. Asset type: transparent HUD background, a single OPEN NOTEBOOK PAGE for a rustic steampunk pixel-art crafting game. Portrait aspect ratio about 2:3. ONE blank cream warm parchment page on a slim dark brown worn leather backing, short visible binding stitches or rings along LEFT edge, a few stacked page edges at bottom and right, small brass corner tabs, slightly irregular worn paper corners, subtle restrained paper grain. Viewed perfectly flat orthographic top-down so UI rows can be aligned over it. Large clean EMPTY writable area, no ruled lines, NO text, lettering, numbers, icons, illustrations, writing or symbols anywhere. NOT a two-page spread: show only one readable page of the open notebook. Crisp chunky deliberate pixel art and warm wood/leather/brass palette matching a cozy medieval mechanical workshop inspired by Graveyard Keeper. Good readability for dark text over the pale paper, no strong stains or shadows in the center. Tight framing with small transparent margins, entire notebook visible, actual transparent background, no floor and no cast shadow.

Prompt final da placa:

> Transparent game HUD asset: one wide horizontal blank dark walnut wood plaque framed in worn dark iron and small antique brass corner rivets. Width to height ratio 4:1. Straight front orthographic view. Cozy medieval mechanical workshop pixel art inspired by Graveyard Keeper, restrained highlights, chunky pixel edges. Entire center is empty dark matte wood, readable with cream UI text over it. NO words, letters, numbers, clock, icons or ornaments inside. Narrow frame, minimal decoration. Entire plaque visible with very small transparent margins. Actual transparent background, no scene, no floor, no cast shadow.

## Validação

`examples/notebook_hud_test.tscn` verifica quantidades, dinheiro, desbloqueios,
separação de itens carregados, fonte global, limites do viewport e ausência do
rodapé. Na execução gráfica salva `docs/images/notebook_hud.png` e
`docs/images/notebook_hud_preparation.png`. O argumento `-- --small` força uma
janela de 1152 × 720 para revisão visual.

Também foram executadas as cenas de regressão dos quatro ciclos, preparação,
bancada livre e balão do cliente, sem falhas nas verificações.
