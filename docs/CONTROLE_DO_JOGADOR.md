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
