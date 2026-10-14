# Primeiro ciclo de atendimento

Execute o projeto com **F5** (cena principal `world/first_cycle.tscn`).
A cena principal herda `world/cenario.tscn`: é o **mapa original da fábrica**,
com seus objetos, tapetes e disposição. Não há uma arena separada nem troca de
mapa ao atender clientes. Os espaços das máquinas futuras permanecem no ambiente.

O jogo inicia em **tela cheia**; **F11** alterna entre tela cheia e janela.
A câmera acompanha o jogador pelo mapa, inclusive no percurso até o balcão.
O personagem usa a escala original e as máquinas escala 0,8, ficando visualmente
aproximadamente 1,5–2 vezes mais altas. Colisão e alcance de interação são ajustados
separadamente da arte para permitir circular e coletar peças.

## Como jogar

1. Clique em **Abrir a loja**. O relógio começa após essa ação.
2. Ande com **WASD** até a **Bancada de Moldes**, à esquerda das máquinas.
   Aproxime-se e use **Mouse1** para abrir as opções.
3. **Pegar Triângulo** fornece um molde triangular: essa base é ilimitada.
   **Montar Quadrado** abre o quebra-cabeça com dois moldes triangulares.
4. Arraste com **Mouse1**, gire com **R**. Ao concluir, o molde aparece nas
   mãos do personagem e no HUD. Só é possível carregar um molde por vez.
5. Leve-o à máquina da mesma forma e use **Mouse1** para inserir. O molde é
   consumido ao iniciar o ciclo; a máquina fabrica uma unidade após seu
   `production_time` (triângulo: 4 s; quadrado: 7 s).
6. Durante a fabricação, você pode ir preparar outro molde. Colete o produto
   automaticamente por proximidade na saída da máquina.
7. Leve os produtos ao balcão para entregar. Moldes não contam como produtos
   e nunca entram no estoque usado para cumprir pedidos.

**Esc/Fechar** cancela a preparação inteira, inclusive etapas intermediárias,
sem gastar produtos ou moedas. Na bancada, **Descartar molde carregado** libera
as mãos para preparar outro tipo. Uma máquina ocupada ou incompatível não aceita
nem consome o molde. Não existe produção automática em sequência.

O jogador fica parado durante a montagem, mas os dois cronômetros continuam.
O estoque fica à esquerda, o pedido à direita e o relógio no centro. O HUD também
mostra qual molde está nas mãos, permanecendo visível durante a montagem.

## Parâmetro dos moldes

Abra `world/first_cycle.tscn`, selecione **MoldWorkbench** e altere **Mold Mode**
(`mold_mode`) no Inspector:

| Valor | Comportamento |
|---|---|
| `1` — Sempre montar desde o triângulo | **Ativo por padrão.** Todo molde composto exige refazer sua cadeia de montagem. |
| `0` — Desbloquear molde pronto após montar | A primeira montagem bem-sucedida de uma forma libera novas cópias prontas na bancada, sem repetir o quebra-cabeça. Cada cópia ainda precisa ser carregada e é consumida na máquina. |

O molde triangular está sempre disponível nos dois modos. Para o quadrado,
a receita usa dois moldes triangulares. Para o retângulo, são dois moldes
quadrados: no modo padrão, o jogador monta **quadrado, quadrado, retângulo**.
Não são usados triângulos ou quadrados do estoque de produtos como ingredientes.
No modo de desbloqueio, moldes intermediários já conhecidos podem ser pegos prontos.
A descoberta é mantida durante a sessão e reinicia ao clicar em Jogar novamente;
não há salvamento persistente. Trocar o parâmetro vale para as próximas preparações.

`available_shapes` limita as opções da bancada às formas do ciclo. A primeira
rodada mantém triângulo e quadrado. O molde de retângulo já tem receita, cadeia
recursiva e compatibilidade com sua máquina, mas continua bloqueado para a
progressão posterior. Habilitar uma nova forma requer também liberar sua máquina.

## Regras e parâmetros

O nó `FirstCycle` da cena expõe no Inspector:

| Parâmetro | Inicial | Significado |
|---|---:|---|
| `round_duration` | 180 s | Duração desta primeira rodada |
| `triangle_patience` | 50 s | Prazo de um pedido de até 2 triângulos |
| `square_patience` | 110 s | Prazo de um pedido de até 2 quadrados |
| `arrival_delay` | 3 s | Intervalo entre clientes |
| `triangle_reward` | 10 | Pontos/moedas por triângulo entregue |
| `square_reward` | 30 | Pontos/moedas por quadrado entregue |

Há um cliente ativo. O primeiro pede 2 triângulos e o segundo 2 quadrados;
depois alternam-se as formas, com 1–3 unidades. Pedidos de 3 unidades recebem
1,5 vez o prazo base. O prazo nunca ultrapassa o tempo restante da rodada.
Pedidos vencidos não pagam e não encerram a rodada. Um pedido pendente no fim
conta como não atendido. O resultado mostra entregas, perdas e pontuação.
**Jogar novamente** limpa estoque, produtos no chão, pontuação e sequência.

As máquinas expõem `requires_mold` (ativo nesta cena), `manual_production`,
`manual_available` e `production_time`. O consumo de moldes é obrigatório neste
fluxo; `consume_production_materials` continua sendo exclusivo do modo automático
antigo. Encerrar a rodada cancela a preparação na bancada e as fabricações em
andamento; o molde já inserido não retorna e nenhum produto incompleto é gerado.

Não há produção passiva, quebras aleatórias ou compra de máquinas neste ciclo.
Retângulos, paralelogramos e trapézios ficam sinalizados para ciclos futuros,
sem interações de compra/conserto. As atividades antigas da floresta e manutenção
ficam inativas neste modo, mantendo seus objetos no cenário. Restaurar a fábrica
com moedas continua como possibilidade futura, sem implementação nesta etapa.
O cliente usa provisoriamente a arte do personagem e uma animação simples de chegada/saída.

## Escopo

Esta entrega implementa **somente a primeira rodada de 3 minutos**. A progressão
de quatro rodadas e a meta de pelo menos 10 minutos pertencem à próxima etapa,
após testar o ritmo da montagem e do atendimento. Não há salvamento de sessão.

## Validação

Execute as cenas de teste com Godot em modo headless:

```
godot --headless --path . --scene res://examples/first_cycle_test.tscn
godot --headless --path . --scene res://examples/shape_assembly_test.tscn
godot --headless --path . --scene res://examples/production_chain_test.tscn
```

O teste do ciclo percorre bancada, transporte, inserção e fabricação com coleta,
entrega por interação real, consumo único, rejeição de molde incompatível,
montagem recursiva de retângulos, os dois modos do parâmetro, cancelamento,
encerramento simultâneo a um encaixe, reinício, bloqueios e câmera. Também
verifica que o HUD não cobre a bancada. Em execução gráfica, testa F11.
Para capturas, execute-o com renderização e `-- --screenshots` (`*.tmp.png`).
