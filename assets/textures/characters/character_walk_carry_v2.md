# Personagem: caminhada e transporte

Arte criada com a ferramenta integrada de geração de imagens, usando o personagem original como referência.

Arquivo: `character_walk_carry_v2.png`.

Quatro poses por linha; ordem das linhas:
1. Caminhando para baixo.
2. Caminhando para cima.
3. Caminhando para a direita.
4. Carregando um molde invisível, para baixo.
5. Carregando um molde invisível, para cima.
6. Carregando um molde invisível, para a direita.

Para a esquerda, espelhar a direção direita. O molde deve ser uma imagem separada, posicionada nas mãos conforme a direção; na vista de costas, desenhá-lo atrás do corpo. Isso permite reutilizar as animações com todas as formas.

Integrado no personagem em `entities/player/player.tscn`. Os recortes explícitos e as margens de `worker_frames.tres` alinham os pés sem depender de células uniformes. A caminhada lateral usa `character_side_v3.png`, com alternância entre passada aberta e passagem. As duas texturas têm resoluções diferentes; o controlador normaliza a escala na tela.

Há seis animações de caminhada e seis poses paradas. Parar preserva a última direção, inclusive enquanto carrega. `carried_mold.gd` posiciona o molde nas mãos e o coloca atrás do corpo na vista de costas. `sprite_alpha.gdshader` descarta halos semitransparentes da arte gerada; as texturas originais permanecem intactas.

Validação: `examples/worker_animation_test.tscn` verifica direções, espelhamento, poses paradas, transporte e consumo do molde; `examples/first_cycle_test.tscn` cobre o fluxo completo de produção. A cena de animações também gera uma prévia quando executada com renderização.

## Prompt final

Correct this sprite atlas for actual game use. REMOVE ALL background including black and brown glow: fully transparent alpha everywhere outside the character silhouettes. No glow, no floor, no shadows. Retain the exact character clothing and pixel-art design. Re-layout the 24 sprites on a precise FOUR columns by SIX rows uniform grid across the ENTIRE canvas, without the enormous side margins. Center each character in its cell with consistent feet baseline. Each row MUST have FOUR DIFFERENT walk-cycle poses: frame1 left leg forward and right back, frame2 feet together passing upright, frame3 right leg forward and left back, frame4 feet passing with opposite knee raised. Especially profile rows 3 and 6: do NOT repeat the same spread-leg pose in every frame, frames2 and4 MUST have feet nearly together. Rows1/2/3 normal walking down/up/right, rows4/5/6 carrying an invisible mold walking down/up/right with elbows bent and both hands extended, leave the object completely absent. No text or grid lines. Crisp pixel edges, consistent size all frames. This must be a transparent game asset.
