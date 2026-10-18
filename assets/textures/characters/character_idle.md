# Idle do trabalhador

Arquivo: `character_idle.png`, criado pela ferramenta integrada de geração de imagens com `character_walk_carry_v2.png` como referência.

Três colunas: frente, costas e direita. Duas linhas: mãos livres e segurando molde. Esquerda usa espelhamento. As seis poses têm os dois pés apoiados e substituem os quadros de caminhada usados anteriormente no idle.

Os recortes estão em `entities/player/worker_frames.tres`. A escala de idle é 0.19, com os pés na coordenada local y=36 do personagem. O shader `sprite_alpha.gdshader` anima uma respiração suave de menos de um pixel de altura no mundo, mantendo a base dos pés fixa. O controlador desativa a respiração ao caminhar. O molde continua sendo desenhado separadamente.

Verificação: 54 checks em `worker_animation_test.tscn` e 99 checks em `first_cycle_test.tscn`, sem falhas. Prévia: `docs/images/worker_idle.png`.

## Prompt

Create SIX neutral STANDING STILL idle sprites of the reference game worker, in a THREE COLUMN TWO ROW sheet. Same olive cap brown hair beige shirt suspenders ochre trousers brown boots and pixel-art style. Top row: facing front, facing back, facing right profile, arms relaxed. Bottom row: facing front, facing back, facing right profile with both elbows bent hands holding an INVISIBLE small object at waist height. No object drawn. CRITICAL: ALL six figures standing still with BOTH BOOTS FLAT ON THE SAME GROUND BASELINE, both straight legs supporting weight, feet close together, NO raised knee, NO lifted foot, NO walking stride. Full body identical height and proportions across all six. Evenly spaced with generous margins. Transparent alpha background, no background glow or ground shadows, no text or labels. Preserve character identity exactly. These are REST poses, not walk cycle frames.
