
## Caminhada lateral

Novas folhas `assets/textures/characters/customers/*_walk.png`, com quatro quadros cada, geradas pela ferramenta nativa ImageGen a partir do PNG frontal de cada cliente. Originais preservados. Os recursos `data/customers/*_walk.tres` recortam e alinham os quadros pelos pés e pela cabeça, sem editar o bitmap. A esquerda usa espelhamento horizontal.

O tween da sala continua controlando a posição. O sprite avança um quadro a cada `pixels_per_frame` pixels realmente percorridos (padrão 14), e não pelo tempo parado. `walk_speed` controla o deslocamento (140 px/s; trajeto de 230 px em aproximadamente 1,64 s). A seleção de cliente interrompe o estado anterior, e a conclusão do tween restaura o idle. Prévia: `docs/images/customer_walk_frames.png`.

Prompt comum aplicado separadamente a cada um dos quatro PNGs de referência, com fundo transparente ativado:

> Create a game sprite sheet of the SAME character as this reference, preserving identity, clothing, palette, pixel-art rendering and compact body proportions. EXACTLY FOUR full-body frames in ONE horizontal row, evenly spaced in four equal cells on a wide transparent canvas. All frames STRICT SIDE PROFILE facing RIGHT. Four-phase looping walk: 1 left leg forward right leg back, 2 legs passing under body, 3 right leg forward left leg back, 4 opposite passing pose. Arms counter-swing naturally. Same head size and body height in every frame, boots on common baseline, no camera change or scaling, ample transparent space between frames. Crisp pixel outlines, earthy colors, match reference style. No text, labels, shadows, floor, extra characters, background or glow. Actual transparent alpha. Keep exact reference costume and hair; these are animation frames of one character, not variations.

