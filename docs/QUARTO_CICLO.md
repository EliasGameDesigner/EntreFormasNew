# Ciclo 4 — Trapézio

O ciclo 4 dura 240 segundos e libera a máquina de trapézios no mesmo mapa. O primeiro cliente pede um trapézio, e os próximos alternam triângulo, quadrado, retângulo, paralelogramo e trapézio. A paciência padrão é 180 segundos por trapézio e a recompensa é $70 por peça, configuráveis no Inspector em FirstCycle. Os quatro ciclos somam 15 minutos.

A receita existente usa um quadrado e dois triângulos. A bancada livre agora reconhece todas as peças de uma receita, usando a última peça posicionada como referência. O teste examples/fourth_cycle_test.tscn cobre as quatro rotações e os três componentes possíveis como última peça, além de transporte, máquina, pilhas, entrega e reinício.

Sprites gerados pela ferramenta integrada image_gen usando o quadrado como referência. Os arquivos finais são assets/textures/items/concepts/trapezoid_part_v1.png e trapezoid_mold_v1.png. Os recursos AtlasTexture em data/items/trapezoid_part_texture.tres e trapezoid_mold_texture.tres recortam as margens transparentes. A máquina utiliza sua animação existente.

## Prompt da peça

Use case: stylized-concept. Asset type: transparent game sprite. ONE finished mechanical trapezoid part, weathered gray iron face, brass bolt holes at four corners, orange rust speckles, chunky crisp pixel art and dark outline, top-down with slight front thickness. Match reference square part materials and pixel style. Exact symmetric trapezoid silhouette: top edge one unit wide, bottom edge THREE units wide, height one unit. The two sloping sides are 45 degrees, matching a central square plus a right isosceles triangle on each side. Horizontal top and bottom. Wide low silhouette, NO perspective distortion. Central inset iron face, four gold brass bolt holes. ONE isolated object, no text, no ground/shadow/glow, actual transparent background, generous transparent margin.

## Prompt do molde

Use case: stylized-concept. Asset type: transparent game sprite. ONE mechanical casting MOLD for a trapezoid. Match reference square mold: weathered gray iron, brass fasteners at four corners, deep dark hollow cavity and FOUR raised silver locating pegs inside, rusty patches, crisp chunky pixel art, dark outline. Exact symmetric trapezoid front silhouette: horizontal top edge one unit, bottom edge THREE units, height one unit, two 45 degree sloped sides. Top-down with only slight front thickness. Wide low silhouette. The mold must look hollow with locating pegs to distinguish it from finished metal part. ONE object ONLY, no text or shadow/glow, actual transparent background, transparent margins.

