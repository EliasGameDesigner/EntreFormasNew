# Peça e molde quadrados

Criados com a ferramenta integrada de geração de imagens a partir da família triangular aprovada. Integrados ao produto, ícones de montagem, mãos do personagem e seleção da bancada. Peça com quatro furos e molde com quatro pinos e cavidade quadrada.

Arquivos: `square_part_v1.png` e `square_mold_v1.png`. Recortes: `data/items/square_part_texture.tres` e `square_mold_texture.tres`. Tamanho máximo da peça no mundo: 40 pixels, como o triângulo.

Verificação visual: `docs/images/square_in_game.png`. Teste `examples/square_art_test.tscn` monta o molde, confere os recursos, escala e coleta. Primeiro ciclo: 99 verificações sem falhas.

## Prompt da peça

Create a SQUARE variant of the reference mechanical triangular plate, for the same pixel-art game item family. ONE standalone square cast-iron component, front-facing square silhouette with equal sides, horizontal top and bottom edges, NOT a diamond. Match reference exactly in material, chunky pixel size, outline, shading, rust wear and muted palette: warm gray iron, small brown wear marks, dark lower thickness, restrained brass. Four brass-rimmed mounting holes, one in each corner, and a solid recessed SQUARE center panel. It must read as a manufactured square plate, not a mold or frame with empty opening. Graveyard Keeper-inspired rustic workshop game sprite. Near frontal slightly top-down view, top-left light. Simple legible at 40-64 pixels. One centered object with ample padding, transparent alpha background, no backdrop, glow, ground shadow, text or other objects. Match the reference's pixel-art rendering, not smooth illustration.

## Prompt do molde

Create ONE EMPTY SQUARE casting mold game sprite. Reference1 is the existing triangular mold: preserve its overall outer block, palette, worn iron, corner brass fasteners, chunky pixel-art style and perspective. Change its TRIANGULAR inner cavity to a SQUARE inner cavity with four small upright steel cylindrical pins, one near each inner corner. Reference2 is the finished square component this mold produces; the four pins correspond to its four holes. Output is the mold ONLY: thick dark cast-iron rectangular block with broad rim, visibly deep empty square cavity, four protruding pins; no finished plate sitting inside. Match reference1 simple legible silhouette, nearly frontal slight top-down angle, upper-left lighting, dark lower thickness, gray iron and sparse brown rust and muted brass. Graveyard Keeper-inspired rustic workshop pixel art. Distinguish from the finished part through deeper darker cavity and visible pins. Single centered object with padding, transparent alpha background everywhere outside silhouette, no glow, floor, shadow, labels, text, scenery or extra props.
