# Segundo ciclo: retângulos

O primeiro ciclo mantém seus 180 segundos, com triângulos e quadrados. Ao terminar, o jogador entra em preparação livre e inicia o próximo ciclo pelo botão do balcão de atendimento, quando decidir. O segundo ciclo dura 240 segundos e libera a bancada e a máquina de retângulos no mesmo mapa. O primeiro cliente pede um retângulo; os seguintes alternam retângulo, triângulo e quadrado, com quantidades de 1 a 2. Retângulos têm paciência-base de 150 segundos por unidade e recompensa de 50 moedas por unidade.

O molde do retângulo exige três montagens: dois moldes quadrados a partir de triângulos e depois a união desses quadrados. Ele é carregado até a máquina, consumido na produção, e o produto aparece no chão com física. Mouse1 continua sendo a ação para pegar, largar, inserir e depositar. Apenas um objeto pode ocupar as mãos. As pilhas no balcão passam a incluir retângulos.

Na transição são preservados o estoque do balcão, os objetos no chão, o objeto carregado, as moedas e os totais de atendimento. A montagem aberta é encerrada, devolvendo as peças soltas à bancada. As máquinas já liberadas continuam trabalhando durante o intervalo. O resultado final aparece após o quarto ciclo; recomeçar limpa o estado e retorna à preparação do ciclo 1.

Parâmetros em `FirstCycle`: `round_duration`, `second_cycle_duration`, `rectangle_patience`, `rectangle_reward`, além dos parâmetros anteriores. `rectangle_machine` aponta para a máquina existente `MaquinaGenerica2`. O estado de interação e o visual de bloqueio agora são controlados pela progressão.

A velocidade padrão em `Movement → Speed` foi ajustada para **210 px/s**, mantendo quatro direções e a prioridade da última tecla. O retângulo produzido usa tamanho de 40 px no mundo, consistente com as demais peças.

Teste dedicado: `examples/second_cycle_test.tscn`, incluindo transição, conservação do estoque, montagem completa, produção, coleta, transporte, pilha, entrega, variedade de pedidos, término e reinício.

## Preparação e início no balcão de atendimento

Na abertura, Entrar na fábrica libera a preparação sem cronômetro nem pedidos. É possível montar moldes, fabricar nas máquinas já liberadas, carregar e largar objetos e abastecer as pilhas do balcão. No balcão de atendimento, Iniciar ciclo N começa o tempo e admite o primeiro cliente. Também é possível abrir a bancada carregando um objeto durante a preparação.

Entre os ciclos ocorre a mesma preparação livre, sem tela que bloqueie a movimentação. As novas máquinas e receitas são liberadas ao iniciar o ciclo correspondente. Iniciar preserva o estoque, os moldes, o item nas mãos e a fabricação em andamento. Os produtos preparados só participam de entregas depois que houver um pedido ativo.

O estado preparing e o método workshop_active() em FirstCycle distinguem o intervalo da sessão encerrada. O teste examples/cycle_preparation_test.tscn cobre o fluxo da interface, fabricação e depósito na preparação, preservação de materiais, início dos quatro ciclos e reinício. Prévia em docs/images/cycle_preparation_counter.png.

A interação no balcão abre o painel de atendimento durante a preparação. Se o jogador estiver carregando um produto, Mouse1 o deposita primeiro. Com as mãos livres ou carregando um molde, abre as opções de iniciar o ciclo ou continuar preparando.
