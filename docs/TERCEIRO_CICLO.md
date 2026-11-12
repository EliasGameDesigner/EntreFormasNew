# Terceiro ciclo

O ciclo 3 libera o paralelogramo e sua máquina no mesmo mapa. Dura 240 segundos, com paciência de 120 segundos por peça e recompensa de $45 por peça. Esses valores podem ser ajustados no FirstCycle pelo Inspector. Os três ciclos somam 11 minutos.

Na bancada livre, dois triângulos unidos pela lateral vertical formam o paralelogramo. O quadrado usa a diagonal. O guia é opcional. Os moldes, produtos no chão, moedas e pilhas do balcão permanecem entre ciclos. Reiniciar limpa a sessão e bloqueia as máquinas seguintes.

O primeiro pedido do terceiro ciclo solicita um paralelogramo. Os seguintes alternam triângulo, quadrado, retângulo e paralelogramo, com uma ou duas peças. A entrega continua usando as pilhas do balcão e Mouse1.

Sprites novos em assets/textures/items/concepts/parallelogram_part_v1.png e parallelogram_mold_v1.png, gerados com a ferramenta integrada image_gen usando os sprites do quadrado como referência. AtlasTexture recorta a margem transparente. A máquina usa a animação de paralelogramos existente.

Teste integrado em examples/third_cycle_test.tscn cobre desbloqueio, montagem livre, carregar/largar/recuperar molde e produto, fabricação, pilhas, entrega, pedidos anteriores e reinício.

## Prompts dos sprites

### Peça

Use case: stylized-concept. Asset type: transparent game item sprite. Create ONE centered parallelogram mechanical metal part for a rustic steampunk pixel art factory matching the reference square part: weathered iron gray, warm brass bolt holes at all four corners, light orange rust speckles, crisp chunky pixel shading, dark outline, top-down face with very slight visible bottom thickness. Exact front-face silhouette is a parallelogram with horizontal top and bottom and sloping sides: normalized corners (0.50,0.15),(0.90,0.15),(0.50,0.75),(0.10,0.75). This is formed by TWO right isosceles triangles joined along a vertical leg, so horizontal width and height of each triangle are equal. Strong readable silhouette. ONE object ONLY, no lettering, no background, no ground shadow, transparent canvas. Reference images indicate materials and style only. Save a PNG.

### Molde

Create ONE transparent pixel art game sprite of a mechanical casting MOLD for a parallelogram. Match the reference square mold's weathered gray iron, brass fasteners, rusty patches, deep hollow cavity, four raised locating metal pegs. Parallelogram silhouette with horizontal top/bottom and sloping sides. Single isolated top-down object slight front thickness, dark outline, chunky crisp pixels. Corners approximately top-left(50%,20%),top-right(90%,20%),bottom-right(50%,80%),bottom-left(10%,80%). All four corners brass bolts, hollow dark recessed parallelogram cavity with FOUR locating pegs inside so distinguishable from finished part. No floor, no glow, no lettering. Transparent background.
