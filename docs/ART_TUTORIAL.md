# Art, a cartola: tutorial do primeiro ciclo

Art é literalmente uma cartola viva de dois olhos, sem corpo. Seu retrato em
pixel art acompanha falas formais e didáticas, em uma caixa de diálogo de papel.
A fonte usada é a m5x7 fornecida pelo usuário.

## Fluxo

Na preparação inicial, Art se apresenta e indica como andar, interagir e começar
o atendimento no balcão. Durante o primeiro ciclo, ele ensina:

1. Ler os ícones e quantidades do balão do cliente.
2. Pegar o molde triangular ilimitado na bancada.
3. Inserir o molde na máquina correspondente; cada fabricação consome um molde.
4. Aguardar a produção e recolher a peça na saída.
5. Carregar uma peça por vez e depositá-la no balcão.
6. Repetir a fabricação até completar a entrega automática.
7. Montar o molde quadrado a partir de dois triângulos, com duplo clique para girar
   e receita como guia opcional.
8. Pegar o molde montado na lista e fabricar/entregar quadrados.

As dicas acompanham as ações reais, incluindo a recuperação de moldes largados.
O tutorial conclui após observar a montagem do quadrado e entregas completas de
triângulos e quadrados. Pedidos expirados não contam como lições concluídas;
Art acompanha o tipo do novo pedido para orientar o jogador novamente.

Não há pausa, bloqueio de movimento ou alteração dos prazos. O botão **Dispensar**
oculta a fala; **Art: mostrar dica** reabre a orientação atual. Na bancada, o
painel fica no canto superior direito da área de montagem, deixando a lista,
as receitas e o fechamento acessíveis. O balão do cliente evita cobrir a dica.

A ajuda termina com o primeiro ciclo e reinicia em uma nova sessão. Para
desativá-la pelo editor, desmarque **enabled** no nó **ArtTutorial** da cena
`world/first_cycle.tscn`.

## Implementação

- `core/art_tutorial.gd`: observa as ações e escolhe a próxima orientação.
- `ui/hud/art_tutorial_ui.gd`: retrato, fala, objetivo e botões.
- `FirstCycle`: sinais de nova sessão, depósito e entrega concluída.
- `MachineNode`: sinais de fabricação iniciada e produto criado.
- A bancada e as mãos continuam com a lógica existente; o tutorial não altera
  estoque, receitas ou transporte.

## Arte

Sprite final: `assets/textures/characters/art_top_hat_v1.png`.
Gerado com a ferramenta integrada imagegen, preservando o fundo transparente.
O sprite é usado como retrato do instrutor no HUD.

Prompt final:

> Use case: stylized-concept. Asset type: transparent PNG character sprite for a 2D pixel-art medieval mechanical workshop game. Subject: Art, a LIVING TOP HAT tutor, literally just one elegant top hat with TWO expressive friendly eyes on the front of the crown. No human, no body, no arms, no legs, no mouth. Formal, wise, kind schoolteacher personality. Dark charcoal felt, warm brown subtle highlights, antique burgundy hatband with one small aged brass clasp. Eyes are warm cream with dark pupils, clearly visible and readable at small game-sprite scale. Full hat with brim completely visible, centered with very little transparent margin, mostly frontal slightly top-down three-quarter view. Crisp authentic hand-placed chunky pixel art, limited palette, dark brown outline and restrained shading, matching Graveyard Keeper-style characters and rustic iron/brass machines. The hat must read as a high quality SMALL GAME SPRITE rather than a realistic illustration: approximately 64x64 logical pixel detail enlarged cleanly. ONE single standalone hat sprite ONLY, no sheet, no text, no backdrop, no ground, no props, no glow, no drop shadow. Actual transparent background.

## Validação

`examples/art_tutorial_test.tscn`: 60 verificações do fluxo real de moldes,
produção, coleta física, depósitos, entregas, recuperação, posição na bancada,
dispensa/reabertura, relógio, fim do ciclo e reinício. Execução gráfica revisada
em 1152 × 720, com capturas:

- `docs/images/art_tutorial_welcome.png`
- `docs/images/art_tutorial.png`
- `docs/images/art_tutorial_workbench.png`

Também passaram as verificações de HUD (34), quatro ciclos (99, 39, 28 e 92),
preparação (38), bancada (28), balão do cliente (21) e transporte (40).
O teste do quarto ciclo passa a aproximar-se da saída da máquina pelo lado:
o deslocamento aleatório do produto podia colocar a aproximação inferior
fora da parede sul, invalidando corretamente a coleta.
