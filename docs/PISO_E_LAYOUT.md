# Piso e layout da fábrica

Piso gerado pela ferramenta nativa ImageGen em `assets/textures/props/factory_floor_tiles_v2.png`. Folha 1254 × 1254 com quatro quadrantes de 627 × 627, disponíveis no TileSet editável `data/world/factory_floor_tileset.tres`. Cada tile é exibido com 64 px no mapa (26 × 18 tiles). A revisão clareia a madeira, suaviza o ruído e reduz as tábuas à metade da escala inicial, sem alterar as dimensões da fábrica. O PNG v1 foi preservado.

A cena `world/factory_layout.tscn` usa `factory_layout.gd` (@tool) para mostrar o piso também no editor, distribuir as variações deterministicamente e desenhar paredes de madeira com ferragens. Área de 1664 × 1152 px: produção à esquerda, atendimento à direita, divisória com corredor inferior. As máquinas futuras permanecem na parte inferior da produção para desbloqueios posteriores.

Entrada centralizada na parede direita; marcador `CustomerEntrance` define a origem/destino dos clientes. Balcão alinhado à trajetória horizontal. Câmera segue o jogador, limitada aos novos contornos. Piso e colisões antigos são desativados somente na cena `first_cycle.tscn`, preservando o cenário original. Paredes novas possuem colisão; a soleira externa impede que o jogador saia da fábrica.

Validação: `factory_layout_test.tscn` cobre piso, colisões, passagem, alinhamento e chegada de cliente (12 verificações). `first_cycle_test.tscn` verifica produção e entregas percorrendo o novo corredor (99 verificações). Prévia em `docs/images/factory_layout.png`.

## Prompt de geração

Game-ready pixel-art FLOOR TILESET sprite sheet for a cozy rustic mechanical workshop RPG. Exactly 4 square seamless floor tiles arranged in a strict 2 by 2 grid, filling a square image edge to edge, equal-size quadrants, NO gaps, NO margins, NO labels. Each quadrant is a subtle variant of the same warm medium-dark aged walnut wooden plank floor, viewed perfectly TOP DOWN orthographic, no perspective. Horizontal thick planks, dark narrow seams at exactly the same evenly spaced heights in every tile, staggered vertical board joints, restrained grain, small iron nail heads. Each tile has four equal-width horizontal rows of boards, seamless repeat left/right and top/bottom, all variants interchangeable edges. Muted brown palette, restrained contrast so characters and machines stand out. Crisp deliberate pixel art, chunky dark outlines and clusters, matching rustic wood/iron/brass factory sprites. NO furniture, objects, metal frames, exterior borders, lighting gradients, shadows, bevel around tile perimeter, grass or background. Entire canvas opaque floor texture. Do not draw a grid over the artwork.

