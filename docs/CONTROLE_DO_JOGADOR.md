# Componentes do jogador

O script antigo `interactble_player.gd` foi substituído por quatro scripts em `entities/player/`. O UID foi preservado no novo `player.gd`. A cena `player.tscn` não contém mais o nó desativado `TopDownControler2D`; os arquivos do plugin continuam instalados.

| Nó / script | Responsabilidade |
| --- | --- |
| CharacterBody2D / player.gd | Coordena o passo físico e a apresentação; bloqueia movimento e interação enquanto existe um modal. |
| Movement / player_movement.gd | Entrada direcional, prioridade da última tecla, velocidade, colisões e deslocamento sem diagonais. |
| Animation / player_animation.gd | Idle e caminhada, direção, pose com molde, escala dos sprites, respiração e som dos passos. |
| Interaction / player_interaction.gd | Detecta objetos próximos pelos sinais de InteractionRange, mostra a indicação e aciona a interação. |

Para alterar a velocidade no Inspector, abra `entities/player/player.tscn`, selecione **Movement** e ajuste **Speed** (padrão: 180 px/s). Há uma única configuração padrão; foi removida a duplicação de velocidade na raiz de `first_cycle.tscn`.

Somente `player.gd` executa `_physics_process`: chama `movement.move()` e depois `animation.update_animation()`. Os componentes não executam outro passo físico independente. Isso mantém a ordem explícita e permite suspender o jogador inteiro usando `set_physics_process(false)` na raiz.

O componente Movement recebe `_input` para registrar a ordem das teclas. O coordenador encaminha `_unhandled_input` para Interaction apenas quando os controles estão liberados. Os sinais `area_entered` e `area_exited` da área de interação estão ligados diretamente ao componente Interaction.

Testes atualizados: movimento (43 verificações), animações (54), ciclo completo (99) e arte/coleta do triângulo. Sem falhas. A velocidade de 180, os quatro sentidos, a prioridade da última tecla e o bloqueio por modal foram preservados.

## Câmera e interpolação

A interpolação de física está habilitada no projeto e explicitamente ativada no jogador. A câmera acompanha os passos de física, usando essa mesma interpolação, com a suavização independente desativada. A cena principal desativa a interpolação por herança para os demais objetos, incluindo as peças arrastadas na bancada e os clientes movidos por tween. Assim o ajuste fica concentrado no jogador e na câmera.

O teste de renderização com física temporariamente em 10 Hz registrou 90 posições distintas em 90 quadros, sem recuos durante movimento constante. Os testes de movimentação e bancada verificam as configurações e a exibição das formas liberadas mais apenas o próximo desbloqueio.

Referência técnica — [interpolação de física no Godot](https://docs.godotengine.org/en/stable/tutorials/physics/interpolation/using_physics_interpolation.html).

## Transições de animação

As imagens de caminhada e idle usam resoluções diferentes, compensadas pela escala do AnimatedSprite2D. Ao trocar de animação, player_animation.gd reinicia apenas o histórico de interpolação do sprite após aplicar a nova textura, escala e posição. Isso evita que a textura nova apareça com uma escala intermediária da animação anterior, enquanto o movimento do jogador e da câmera continua interpolado.

O teste gráfico examples/worker_transition_test.tscn renderiza 96 amostras em um SubViewport transparente, com física temporariamente em 10 Hz, cobrindo andar, parar, mudar de direção e entrar/sair da pose de carregar. Antes da correção a altura chegou a 168 pixels. Após o ajuste ficou entre 79 e 82 pixels, sem falhas.
