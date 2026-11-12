# Segundo ciclo: retângulos

O primeiro ciclo mantém seus 180 segundos, com triângulos e quadrados. Ao terminar, a tela de intervalo oferece **Continuar para o ciclo 2** ou **Recomeçar do ciclo 1**. O segundo ciclo dura 240 segundos e libera a bancada e a máquina de retângulos no mesmo mapa. O primeiro cliente pede um retângulo; os seguintes alternam retângulo, triângulo e quadrado, com quantidades de 1 a 2. Retângulos têm paciência-base de 150 segundos por unidade e recompensa de 50 moedas por unidade.

O molde do retângulo exige três montagens: dois moldes quadrados a partir de triângulos e depois a união desses quadrados. Ele é carregado até a máquina, consumido na produção, e o produto aparece no chão com física. Mouse1 continua sendo a ação para pegar, largar, inserir e depositar. Apenas um objeto pode ocupar as mãos. As pilhas no balcão passam a incluir retângulos.

Na transição são preservados o estoque do balcão, os objetos no chão, o objeto carregado, as moedas e os totais de atendimento. A montagem aberta é cancelada e máquinas param no encerramento de cada ciclo. O segundo encerramento mostra o resultado acumulado e permite recomeçar; reiniciar limpa o estado e bloqueia retângulos novamente.

Parâmetros em `FirstCycle`: `round_duration`, `second_cycle_duration`, `rectangle_patience`, `rectangle_reward`, além dos parâmetros anteriores. `rectangle_machine` aponta para a máquina existente `MaquinaGenerica2`. O estado de interação e o visual de bloqueio agora são controlados pela progressão.

A velocidade padrão em `Movement → Speed` foi ajustada para **210 px/s**, mantendo quatro direções e a prioridade da última tecla. O retângulo produzido usa tamanho de 40 px no mundo, consistente com as demais peças.

Teste dedicado: `examples/second_cycle_test.tscn`, incluindo transição, conservação do estoque, montagem completa, produção, coleta, transporte, pilha, entrega, variedade de pedidos, término e reinício.
