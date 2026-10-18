# Bancada: encaixe visual e interface

O triângulo agora é retângulo isósceles: ângulo reto no canto superior esquerdo e diagonal descendente. O produto usa `triangle_part_v3.png`; o molde, `triangle_mold_v2.png`. Os recortes dos recursos existentes foram atualizados, propagando a mudança ao produto, à bancada e às mãos.

`ShapePieceData.full_shape_art` permite que a arte cubra a geometria inteira. Triângulo e quadrado ativam essa opção. `ShapePiece` mapeia UVs para a textura fonte do atlas e desenha dentro do mesmo polígono utilizado pelo clique e encaixe. A imagem não é mais um emblema sobre uma forma preenchida. A geometria e as receitas permanecem as mesmas.

A bancada usa tema nativo em madeira, ferro e latão, texto claro, botões com estados de foco/hover/desabilitado e cavidades escuras com contorno claro. O tampo tem tábuas e fixadores. O tema é restrito à bancada de moldes; os demais modos mantêm sua interface.

Verificação: 102 checks do primeiro ciclo, 71 de montagem e `examples/workbench_fit_test.tscn` aprovado. Este último valida a área clicável, as duas peças encaixadas e os dois vértices compartilhados da diagonal. Capturas em `docs/images/workbench_assembly.png`, `workbench_fitted.png` e `workbench_choices.png`.

Arte gerada com a ferramenta integrada de imagens. Interface implementada com controles e desenho nativos do Godot.

## Prompt inicial da peça

Redesign this game part to fit a geometric puzzle. Preserve the reference's worn gray iron, restrained brass corner holes and rustic pixel art, BUT change silhouette to EXACT ISOSCELES RIGHT TRIANGLE: 90-degree corner at TOP LEFT, perfectly HORIZONTAL upper edge, perfectly VERTICAL left edge, equal leg lengths, straight diagonal hypotenuse from TOP RIGHT to BOTTOM LEFT. Orthographic straight top view, absolutely no perspective or extruded thickness outside this exact silhouette. Three small brass-rimmed mounting holes just inside the three vertices. Solid gray iron triangular face with modest rust. Critical exact geometry: half of an axis-aligned square, never an equilateral triangle. Single centered full object, generous transparent padding, transparent alpha outside. Hard pixel-art edges; no shadows glow text or background. Matching Graveyard Keeper-inspired workshop sprite.

## Refinamento da peça

Fix this right-triangle sprite for exact triangular clipping. Keep right angle at top left, horizontal top, vertical left, equal legs, same worn gray iron and brass pixel-art style. Critical change: MOVE ALL THREE brass holes WELL INSIDE the triangle, at normalized bounding-box positions (0.15,0.15), (0.65,0.15), (0.15,0.65). Holes must be small enough to fit fully INSIDE the diagonal line x+y=1. Make an exact clean 45-degree straight hypotenuse from upper right to lower left, without protrusions, extrusion, rounded bulky corners or thickness outside the mathematical triangle. Strict orthographic top view. All decorative details inside the silhouette. No background, fully transparent alpha, no glow, no shadow, no text. One centered sprite.

## Prompt do molde

Create the matching empty casting mold for the RIGHT TRIANGULAR mechanical part in reference1. Reference2 is the mold's style and outer block reference. Preserve reference2 rectangular dark iron mold block with brass corner bolts, but replace cavity with an ISOSCELES RIGHT TRIANGLE with right angle TOP LEFT, horizontal upper edge, vertical left edge, diagonal from top right to bottom left. Three locating steel pins inside cavity near its vertices, matching the part's holes. Empty recessed cavity, no finished part inside. Pixel art, muted rusty gray iron and brass, same chunky pixels as references, near-frontal top-down camera. Single centered mold on fully transparent alpha background, no shadow glow labels or scenery.
