# Transporte físico — protótipo do primeiro ciclo

Ativado por padrão em FirstCycle, parâmetro `physical_transport`. O modo de inventário anterior permanece disponível com esse parâmetro desativado, para comparação e regressão. Novos ciclos ainda não foram adicionados.

- Mouse1, com mãos vazias e o corpo do jogador dentro da PickupArea do objeto: pegar. Essa área de raio 64 px é independente do BodyCollision de raio 14 px usado na física. A coleta e o aviso usam a mesma verificação, sem o antigo corte fixo de 80 px entre centros. Paredes bloqueiam a seleção. A colisão sólida do jogador tem raio de 22 px, compatível com o sprite.
- Mouse1 perto da máquina: inserir o molde correspondente, consumido na fabricação.
- Mouse1 perto do balcão: depositar o produto carregado.
- Mouse1 carregando, sem máquina ou balcão ao alcance: largar molde ou produto 54 px à frente. Paredes e outros objetos na posição de destino impedem a ação. Máquina/balcão ao alcance têm prioridade; se recusarem o objeto, ele permanece nas mãos.
- Apenas um objeto pode ocupar as mãos. A bancada recusa criar outro molde enquanto estiverem ocupadas.
- Produtos produzidos aguardam no chão; não entram automaticamente no inventário.
- Moldes e produtos no chão usam RigidBody2D, sem gravidade vertical e com rotação travada. Colidem com paredes, jogador e outros objetos; o jogador aplica impulso ao encostar andando. O amortecimento reduz a velocidade após o empurrão. A física permanece desativada no modo antigo de inventário.

O balcão guarda quantidades por tipo de produto e desenha pilhas verticais separadas. Até dez camadas são desenhadas por pilha para limitar a altura; o número acima sempre informa o total real, sem limite de dez itens no estoque. Moldes não podem ser depositados.

Completar o pedido com um depósito entrega automaticamente a quantidade exigida; sobras e produtos de outros tipos permanecem. Se um pedido expirar, o estoque do balcão não é perdido. Um novo cliente cujo pedido já esteja estocado recebe a entrega após dois segundos de atendimento. Reiniciar a rodada limpa mãos, objetos no chão e balcão.

O componente `player_hands.gd` coordena a peça produzida carregada e o molde já mantido pela bancada, garantindo exclusividade. `player_interaction.gd` resolve pegar/inserir/depositar pelo contexto. `carried_mold.gd` também apresenta o produto carregado, reutilizando as poses existentes. FirstCycle mantém o estoque do balcão; ShopNode apresenta suas pilhas. O HUD distingue estoque do balcão e conteúdo das mãos.

Teste `examples/physical_transport_test.tscn`: transporte, recuperação de moldes triangular e quadrado, produto, exclusividade das mãos, máquina incorreta, colisão ao largar, entrega parcial/completa, estoque entre pedidos, expiração, modais e reinício. Captura em `docs/images/physical_transport.png`.
