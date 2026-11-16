# Piso e layout da fábrica

Piso gerado pela ferramenta nativa ImageGen em `assets/textures/props/factory_floor_tiles_v2.png`. Folha 1254 × 1254 com quatro quadrantes de 627 × 627, disponíveis no TileSet editável `data/world/factory_floor_tileset.tres`. Cada tile é exibido com 64 px no mapa (26 × 18 tiles). A revisão clareia a madeira, suaviza o ruído e reduz as tábuas à metade da escala inicial, sem alterar as dimensões da fábrica. O PNG v1 foi preservado.

A cena `world/factory_layout.tscn` usa `factory_layout.gd` (@tool) para mostrar o piso também no editor, distribuir as variações deterministicamente e desenhar paredes de madeira com ferragens. Área de 1664 × 1152 px: produção à esquerda, atendimento à direita, divisória com corredor inferior. As máquinas futuras permanecem na parte inferior da produção para desbloqueios posteriores.

Entrada centralizada na parede direita; marcador `CustomerEntrance` define a origem/destino dos clientes. Balcão alinhado à trajetória horizontal. Câmera segue o jogador, limitada aos novos contornos. Piso e colisões antigos são desativados somente na cena `first_cycle.tscn`, preservando o cenário original. Paredes novas possuem colisão; a soleira externa impede que o jogador saia da fábrica.

Validação: `factory_layout_test.tscn` cobre piso, colisões, passagem, alinhamento e chegada de cliente (12 verificações). `first_cycle_test.tscn` verifica produção e entregas percorrendo o novo corredor (99 verificações). Prévia em `docs/images/factory_layout.png`.

## Prompt de geração

Game-ready pixel-art FLOOR TILESET sprite sheet for a cozy rustic mechanical workshop RPG. Exactly 4 square seamless floor tiles arranged in a strict 2 by 2 grid, filling a square image edge to edge, equal-size quadrants, NO gaps, NO margins, NO labels. Each quadrant is a subtle variant of the same warm medium-dark aged walnut wooden plank floor, viewed perfectly TOP DOWN orthographic, no perspective. Horizontal thick planks, dark narrow seams at exactly the same evenly spaced heights in every tile, staggered vertical board joints, restrained grain, small iron nail heads. Each tile has four equal-width horizontal rows of boards, seamless repeat left/right and top/bottom, all variants interchangeable edges. Muted brown palette, restrained contrast so characters and machines stand out. Crisp deliberate pixel art, chunky dark outlines and clusters, matching rustic wood/iron/brass factory sprites. NO furniture, objects, metal frames, exterior borders, lighting gradients, shadows, bevel around tile perimeter, grass or background. Entire canvas opaque floor texture. Do not draw a grid over the artwork.


## Paredes e exterior — spritesheets

Arte criada com a ferramenta integrada image_gen. Arquivos finais em assets/textures/props/factory_wall_tiles_v1.png, exterior_terrain_tiles_v1.png e exterior_props_v1.png. Cada folha mede 1254 × 1254 e contém quatro quadrantes de 627 × 627.

A folha de paredes contém um segmento horizontal, um vertical, uma junção e a soleira de pedra. factory_layout.gd recorta esses quadrantes para cobrir os retângulos das paredes em segmentos de até 64 unidades, com 28 unidades de espessura no perímetro e na divisória. Os TileSets factory_wall_tileset.tres e exterior_terrain_tileset.tres em data/world disponibilizam os recortes para reutilização no editor.

O antigo fundo escuro foi substituído por um terreno que combina as duas variações de grama com as duas de terra. world/exterior_terrain.gdshader compõe as texturas com transições irregulares ao redor da fundação e um caminho de terra alinhado à entrada. Os sprites de vegetação, arbusto, pedras e toco são distribuídos deterministicamente fora da fábrica.

A câmera ganhou 96 unidades adicionais de margem por lado para apresentar o entorno. A prévia geral está em docs/images/factory_layout.png e a de jogo em docs/images/factory_exterior_gameplay.png. Os testes factory_layout_test e first_cycle_test passaram, verificando colisões, passagem, chegada de clientes, produção e entregas.

### Prompt das paredes

Use case: stylized-concept. Asset type: game-ready WALL TILESET sprite sheet, 1024x1024 square. Exactly FOUR opaque square wall textures in a strict 2x2 equal grid, each fills its entire quadrant edge-to-edge, NO gutters, margins, labels or decorative border. Muted rustic medieval/steampunk workshop, deliberate chunky pixel art clusters, Graveyard Keeper inspired atmosphere, matching reference factory's warm worn oak and dark iron but restrained contrast. TOP LEFT: horizontal repeatable wall segment, thick weathered warm brown timber cap along top, gray/beige rough stone wall face below, dark foundation bottom, one narrow iron strap and brass nail; seamless left/right. TOP RIGHT: the same wall seen as a north-south segment from overhead, stone sides and a vertical central timber beam, seamless top/bottom. BOTTOM LEFT: square junction block where warm oak beams meet at right angle over beige gray stone, small dark iron corner brace. BOTTOM RIGHT: worn beige-gray stone paving threshold, flat top-down squared slabs, no wood. Orthographic top-down RPG tiles, no perspective vanishing point, no furnishings, no ground outside the four tiles. Crisp pixel style, midtone materials with readable big forms, no tiny noisy detail, no text or grid lines. Input reference is style/material only.

### Prompt do terreno

Use case: stylized-concept. Asset type: TERRAIN TILESET sprite sheet for a rustic top-down pixel art RPG. Square 1024x1024 sheet, exactly FOUR opaque seamless square terrain textures in a precise 2x2 equal grid. Each quadrant fills edge-to-edge with no margins, gaps, border, labels or grid lines. TOP LEFT: muted olive-green short meadow grass, small restrained dark and light clustered blades, uniform medium value. TOP RIGHT: second matching olive/sage meadow grass variant with a few tiny dry blades, same interchangeable edges. BOTTOM LEFT: warm medium brown compact earth with a few small pebbles, subtle clustered pixel detail, seamless all four edges. BOTTOM RIGHT: matching warm compact dirt with slightly more small weathered gray-beige stones and gravel, seamless all four edges. Same daylight and pixel cluster scale throughout, cozy weathered Graveyard Keeper inspired rural workshop surroundings. Pure orthographic top-down flat terrain, moderate contrast, colors slightly desaturated to avoid competing with characters and machines, crisp chunky pixels, no grass tufts sticking out of tile, no furniture, buildings, object shadows, text, lighting gradient, vignette, or drawn boundaries between quadrants.

### Prompt dos elementos externos

Use case: stylized-concept. Asset type: transparent environmental PROP SPRITE SHEET for a rustic top-down pixel art RPG. Exactly FOUR distinct small props in equal quadrants of a square 1024x1024 canvas, each centered safely inside its quadrant with ample transparent separation. TOP LEFT: low tuft of muted olive/sage grass with 5-7 chunky blades. TOP RIGHT: small rounded leafy olive-green rural shrub, low and compact. BOTTOM LEFT: a small cluster of three weathered gray/beige stones, slight moss. BOTTOM RIGHT: short old warm-brown cut tree stump with visible rings and two exposed roots. Same elevated top-down RPG camera as reference rustic wood/iron counter, crisp chunky pixel clusters, restrained natural earth palette, clear dark outlines, light upper left, Graveyard Keeper inspired countryside. These are small dressing props, not trees or buildings. No ground base disk, no floor, no drop shadows, no text, labels, borders or grid. Actual transparent background throughout.

## Revisão do interior

O exterior fica oculto por padrão na fábrica. FactoryLayout tem o parâmetro Show Exterior desativado e um fundo preto atrás do piso. As folhas de terreno e decoração e sua composição continuam disponíveis para cenas externas futuras. O parâmetro pode ser alternado no Inspector.

As paredes passaram a ter 64 unidades de espessura visual. Cada quadrante do spritesheet é desenhado com escala uniforme em células de 64 × 64. As últimas células e as peças estreitas do batente são recortadas em vez de esticadas. Junções usam a mesma escala. A câmera voltou à margem anterior, com limites 960, -1792, 2784 e -512.

A validação factory_layout_test contém 15 verificações, incluindo exterior oculto por padrão, fundo preto e reativação opcional dos sprites externos. first_cycle_test passou com 99 verificações. Prévia atual em docs/images/factory_layout.png.

## Perspectiva das paredes por orientação

A parede superior expõe a face completa de pedra sob a travessa de madeira. Laterais, divisória e borda inferior usam um corte pelo topo, com faixa de madeira de 18 unidades sobre base escura de 28. Os encontros e pontas recebem pequenos apoios de 32 × 28 unidades. A entrada lateral usa uma soleira rasa e batentes curtos com os mesmos apoios.

A composição reaproveita os recortes do spritesheet existente, separando a face frontal dos trechos vistos pelo topo. Prévia na escala de jogo em docs/images/wall_perspective_gameplay.png. Os testes de layout e circulação passaram com 15 e 99 verificações, respectivamente.
