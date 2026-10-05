# Máquinas, produção e progressão até o trapézio

## Jogar no cenário principal

Execute `world/cenario.tscn` (F5). Há dois pontos fixos de compra, representados por
máquinas translúcidas abaixo da fileira original:

1. Conserte a máquina de retângulos para desbloquear a compra do paralelogramo.
2. Aproxime-se do ponto do paralelogramo e use Mouse1 para comprar por $300.
3. A máquina comprada começa funcionando. Depois que ela quebrar, conclua seu reparo:
   isso desbloqueia a compra do trapézio.
4. Compre a máquina de trapézios por $500 no outro ponto.
5. Venda produtos na loja existente para obter dinheiro.

Comprar não conta como consertar. Um desbloqueio continua válido se a máquina pré-requisito
quebrar novamente. Compra e histórico de reparos são válidos durante a sessão;
não foi acrescentado um sistema de salvamento.

| Máquina nova | Reparo | Compra | Produção | Venda | Quebra |
|---|---|---:|---:|---:|---|
| Paralelogramo | 2 triângulos retângulos | $300 | 12 s | $45 | 10% a cada 30 s |
| Trapézio | 1 quadrado + 2 triângulos retângulos | $500 | 18 s | $80 | 10% a cada 30 s |

O reparo das novas máquinas não cobra dinheiro; consome as peças montadas.
Os sprites/animações das máquinas existentes foram reutilizados. Os produtos novos têm ícones SVG
simples em `assets/textures/ui/part_parallelogram.svg` e `part_trapezoid.svg`.

## Consumo opcional por ciclo

Selecione uma instância de máquina no Inspector e habilite
**Consume Production Materials** (`consume_production_materials`).
O padrão é **false** para todas as máquinas.

Para as máquinas compradas, abra a cena herdada
`maquina_paralelogramos.tscn` ou `maquina_trapezios.tscn` e configure o parâmetro no nó raiz.
O ponto de compra instancia essa cena, preservando a configuração.

Com o consumo habilitado:

- Quadrado: 2 triângulos para cada quadrado produzido.
- Retângulo: 2 quadrados para cada retângulo produzido.
- Paralelogramo: 2 triângulos para cada paralelogramo produzido.
- Trapézio: 1 quadrado e 2 triângulos para cada trapézio produzido.

Os materiais saem do inventário **no início de cada ciclo**. O débito é atômico:
uma receita incompleta não retira nada, e duas máquinas não podem gastar as mesmas peças.
Sem materiais, o timer de produção aguarda; a animação e o áudio de trabalho pausam.
Alterações no inventário fazem as máquinas que aguardam tentarem iniciar novamente.

Ao terminar, o ciclo gera exatamente um item físico. Se houver materiais, inicia outro ciclo.
Uma quebra, parada explícita ou remoção da máquina devolve os materiais do ciclo interrompido,
sem devolver materiais de produtos já concluídos. O ciclo interrompido reinicia do zero após o reparo.
Não existe prioridade ou fila de produção: entre máquinas concorrentes, a primeira a conseguir
reservar a receita inicia seu ciclo.

A receita de produção é independente do puzzle de reparo:
`MachineData.production_recipe` aponta para um Resource `ProductionRecipe`.
Cada entrada de `materials` representa uma unidade; repita um ItemData para exigir várias.
O modo com consumo exige uma receita válida. A máquina básica de triângulos continua gratuita,
sem receita de entrada, e não quebra.

As encomendas, quantidades a entregar, prazos e UI de gerenciamento ficam para uma etapa futura.

## Coleta automática

`PhysicalItem` agora usa uma `PickupArea`, que recolhe o item quando um corpo do grupo
`player` entra em seu alcance. O personagem existente foi adicionado a esse grupo.
O raio padrão é 64 pixels, configurável em `pickup_radius`; a colisão do personagem
também participa da detecção.

Não é preciso clicar, inclusive quando a máquina produz ao lado de um jogador parado.
Um item só pode ser coletado uma vez. Itens físicos não expõem mais um `Interactable`,
portanto não disputam Mouse1 com máquinas, loja ou tarefas.

Árvores e pedras mantêm sua interação de extração. Esta mudança automatiza a coleta
dos itens já soltos no chão, conforme o escopo alinhado.

## Montagens e novas configurações

As duas receitas novas usam o mesmo `ShapeAssemblyBoard`, `ShapePiece` e `ShapeSlot`,
sem scripts específicos para cada forma:

- `data/machines/assembly_parallelogram.tres`.
- `data/machines/assembly_trapezoid.tres`.

No paralelogramo, o segundo triângulo usa 180°. No trapézio, o triângulo esquerdo usa 180°
e o direito usa 270°. Mouse1 arrasta, R gira e Esc cancela. O último encaixe válido repara
automaticamente a máquina.

O quadrado geométrico passou de lado 100 para 120 pixels, compatível com os catetos
dos triângulos existentes. A receita do retângulo teve as posições ajustadas para manter
as duas peças encostadas. Isso permite montar o trapézio sem frestas nem sobreposição.

Para testar só os puzzles sem esperar dinheiro/desbloqueios, abra
`examples/shape_assembly_demo.tscn` e execute F6. A demonstração abre o trapézio
e fornece os materiais somente nesse exemplo. Feche o reparo para escolher qualquer
uma das quatro montagens nos botões. `initial_machine` permite alterar a montagem inicial.

Para adicionar outro ponto de compra, instancie `machine_purchase_point.tscn` e configure:

- `machine_scene`: cena herdada da máquina.
- `machine_data`: os dados usados pela máquina e o custo da compra.
- `unlock_after_repair`: dados da máquina cujo reparo desbloqueia a compra; vazio libera desde o início.

O pré-requisito procura máquinas do grupo `machines` com `was_repaired = true` e o mesmo
Resource de item produzido. Não se baseia em texto de nomes. A compra desativa a área
de interação do marcador e cria a máquina funcionando na mesma transformação.

## Arquivos envolvidos

Criados:

- `data/machines/production_recipe.gd` e `production_square/rectangle/parallelogram/trapezoid.tres`.
- `data/machines/assembly_parallelogram.tres`, `assembly_trapezoid.tres`.
- `data/machines/maquinaParalelogramos.tres`, `maquinaTrapezios.tres`.
- `data/items/itemParalelogramo.tres`, `itemTrapezio.tres`.
- `entities/machines/maquina_paralelogramos.tscn`, `maquina_trapezios.tscn`.
- `entities/machines/machine_purchase_point.gd`, `machine_purchase_point.tscn`.
- Os dois SVGs dos produtos, este documento, `examples/production_chain_test.gd/.tscn`
  e os metadados de importação/UID gerados pelo Godot.

Modificados:

- `core/inventory_manager.gd`: transações atômicas de reserva/devolução.
- `data/machines/machine_data.gd`, `maquinaQuadrados.tres`, `maquinaRetangulos.tres`:
  configuração independente de produção.
- `entities/machines/machine_node.gd`, `maquina_generica.tscn`: ciclos, espera, reembolso,
  histórico/sinal de reparo e identificação visual de estado.
- `entities/resources/physical_item.gd/.tscn`, `entities/player/player.tscn`: coleta automática.
- `data/items/shape_square.tres`, `data/machines/assembly_rectangle.tres`: medidas compatíveis.
- `world/cenario.tscn`: dois pontos de compra.
- `examples/shape_assembly_demo.gd` e a documentação da montagem.
- Artefatos do Graphify.

Nenhuma pasta foi reorganizada, nenhuma Input Action foi adicionada e nenhuma encomenda foi implementada.

## Validação

No Godot 4.7 stable:

```text
godot --headless --path . --scene res://examples/shape_assembly_test.tscn
godot --headless --path . --scene res://examples/production_chain_test.tscn
```

- Suíte anterior: **71 verificações, 0 falhas**.
- Nova suíte: **70 verificações, 0 falhas**.
- Consumo por ciclo, receitas incompletas/mistas, disputa entre máquinas, cancelamento e reembolso,
  conclusão com Timer real, produção gratuita, preços e pré-requisitos de compra.
- Novos puzzles: validação de ângulo, arrasto/rotação/snap, conserto automático,
  união geométrica sem frestas/sobreposição e silhueta convexa.
- Coleta: colisões reais com o personagem, distância, item gerado junto ao jogador,
  filtragem de outros corpos e proteção contra coleta duplicada.
- Cenário principal e demonstração inspecionados visualmente pelo MCP do Godot, sem erros de execução.
- O bridge temporário do MCP foi removido após a inspeção.

O Graphify foi consultado antes das alterações e atualizado com `graphify update .`.
A montagem permanece genérica; as novas dependências ficam nos Resources, no adaptador de máquina,
nas transações de inventário e no ponto de compra. As relações inferidas do grafo foram
confirmadas nos arquivos reais.