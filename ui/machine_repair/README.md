# Montagem geométrica — implementação e validação

## Como testar

Abra `examples/shape_assembly_demo.tscn` no Godot e execute com F6.
A demonstração abre o reparo do trapézio e fornece somente os itens necessários.
Depois de concluir ou fechar, os botões superiores permitem testar quadrado, retângulo, paralelogramo e trapézio.
Esse fornecimento de itens existe apenas no exemplo: no cenário principal, use os itens produzidos/coletados normalmente.

Para compra, desbloqueio, consumo opcional por ciclo e coleta automática, consulte
[a documentação das máquinas](../../entities/machines/README.md).

- Mouse1 no inventário: retira uma peça para a mesa; também é possível arrastá-la do inventário.
- Mouse1 sobre a geometria na mesa: pegar, arrastar e soltar.
- R enquanto segura: girar pelo incremento configurado na peça.
- Esc ou Fechar: cancelar e devolver todos os itens reservados.
- Dois triângulos retângulos formam o quadrado; o segundo precisa de 180° (duas rotações).
- Dois quadrados formam o retângulo.
- O último encaixe válido dispara o reparo automaticamente, sem botão de confirmação.
- Sem dinheiro suficiente, a montagem concluída aguarda o saldo; cancelar continua devolvendo as peças.
- A máquina de triângulos inicia funcionando, não possui receita de reparo e ignora tentativas de quebra.

A action nova é `rotate_piece`, vinculada ao R físico. `interact`, WASD e `ui_cancel` continuam usando o Input Map existente.
O personagem fica parado e não aciona interações de mundo enquanto o reparo está aberto.

## Arquitetura

`ShapePieceData` define o polígono relativo ao pivô, identidade da forma, ícone, cor e passo de rotação.
O vínculo opcional com `ItemData` só é usado pelo adaptador de inventário.

`ShapeSlotData` configura a peça aceita, posição e rotação esperadas, tolerâncias, posição/ângulo iniciais,
obrigatoriedade e permissão para retirar a peça.

`AssemblyDefinition` reúne os encaixes, tamanho da mesa, título e instruções.
As receitas são arquivos `.tres`; não há seleção de comportamento por nome da máquina.

`ShapePiece` é o objeto geométrico manipulável. `ShapeSlot`, implementado no caminho existente
`repair_slot.gd`, valida a transformação. A peça deve usar o mesmo Resource canônico configurado no encaixe:
não basta compartilhar nome ou `shape_id`. Isso também evita aceitar geometria diferente com o mesmo identificador.

`ShapeAssemblyBoard` controla entrada, retirada, rotação, snap e conclusão. Não acessa máquinas,
dinheiro, inventário ou HUD. A cena `shape_assembly_board.tscn` pode ser instanciada fora do reparo.
A conclusão exige todos os encaixes obrigatórios válidos e emite `assembly_completed` uma vez por sessão.
Uma receita vazia ou inválida não conclui automaticamente.

`MachineRepairUI` é o adaptador: fornece peças mediante reserva de inventário, reembolsa cancelamentos,
valida o saldo e emite `repair_completed`. `MachineNode` escuta esse sinal e chama seu comportamento
existente de conserto: estado, animação, produção e áudio. A cobrança ocorre uma única vez.
Peças soltas adicionais são devolvidas ao concluir uma receita com encaixes opcionais.

O tabuleiro aplica snap somente a um encaixe compatível dentro das duas tolerâncias.
Não existe fallback para um encaixe distante ou preenchimento automático por clique.
Soltar fora da mesa restaura a transformação anterior; peças encaixadas podem ser retiradas antes
da conclusão quando `allow_removal` permitir.

## Criar uma nova montagem ou forma

1. Crie um Resource `ShapePieceData` em `data/items/`, ou reutilize um existente.
   Configure `polygon` ao redor do pivô, `shape_id`, ícone e passo de rotação.
   Para triângulos equiláteros de um hexágono, por exemplo, use geometria correspondente e passo de 60°.
   Em uma máquina, configure também `inventory_item`.
2. Crie um `AssemblyDefinition` em `data/machines/`, mantendo a organização atual.
   Adicione subresources `ShapeSlotData` à lista `slots`.
   Cada encaixe referencia a peça canônica e define sua posição/rotação de solução, tolerâncias e posição inicial.
   Use coordenadas locais em pixels dentro de `board_size`. Não sobreponha as posições iniciais.
3. Para uso independente, instancie `ui/machine_repair/shape_assembly_board.tscn`,
   atribua `definition` pelo Inspector e mantenha `populate_on_ready = true`.
   Conecte `assembly_completed` à consequência desejada (porta, tutorial etc.).
   Também é possível chamar `setup(recipe)` para reiniciar.
4. Para uma máquina, atribua o Resource a `MachineData.repair_assembly` e habilite `can_break`.
   A cena genérica já exporta `repair_ui_scene` e conecta o sinal de reparo.
   Máquinas herdadas reutilizam essa integração sem novo script.
5. Ajuste as posições e tolerâncias no Inspector e teste a receita na mesma cena de tabuleiro.
   A lógica principal não precisa mudar para adicionar outras formas.

## Componentes antigos substituídos

Foram substituídos no lugar: o enum de formas e os métodos `setup_square/rectangle/triangle/generic`,
o desenho específico de cada máquina, o encaixe automático/fallback, o antigo `RepairSlot` de inventário,
o botão de confirmar reparo, as condições baseadas no texto do nome da máquina e o caminho
`attempt_repair/_can_afford_repair/_consume_repair_resources`, que contornava a montagem.

`MachineData.required_items` e `repair_image` foram substituídos pela receita.
Inventário, preços dos itens, custo de compra da máquina, tarefas, loja, coleta, produção,
áudio e animações continuam usando seus componentes existentes.

Nenhum arquivo foi movido ou removido fisicamente. Os quatro scripts existentes da montagem foram reescritos,
e o script de slot manteve seu caminho/UID, agora com a classe `ShapeSlot`.
A busca final não encontrou consumidores das APIs antigas no código/cenas/Resources.

## Arquivos criados

- `data/items/shape_piece_data.gd`, `shape_triangle.tres`, `shape_square.tres`.
- `data/machines/assembly_definition.gd`, `shape_slot_data.gd`,
  `assembly_square.tres`, `assembly_rectangle.tres`.
- `ui/machine_repair/shape_piece.gd`, `shape_assembly_board.tscn`.
- `examples/shape_assembly_demo.gd`, `shape_assembly_demo.tscn`.
- `examples/shape_assembly_test.gd`, `shape_assembly_test.tscn`.
- Este documento e os arquivos `.gd.uid` gerados pelo Godot para os novos scripts.

## Arquivos modificados

Mudanças de comportamento/configuração:

- `ui/machine_repair/shape_assembly_board.gd`, `repair_slot.gd`,
  `inventory_drag_item.gd`, `machine_repair_ui.gd`, `ui_reparar_maquina.tscn`.
- `data/machines/machine_data.gd`, `maquinaQuadrados.tres`,
  `maquinaRetangulos.tres`, `maquinaTriangulos.tres`.
- `entities/machines/machine_node.gd`, `maquina_generica.tscn`.
- `entities/player/interactble_player.gd`.
- `project.godot`: rotação e resolução de referência 1152 × 720 para a interface.

Correções técnicas de carregamento, sem alteração de comportamento:
remoção de BOM UTF-8 que causava `Expected '['` no scanner de Resources e correção de UIDs
externos para os UIDs reais dos assets/scripts já presentes.

- `core/interaction/interactable.tscn`.
- `data/items/itemMadeira.tres`, `itemPedra.tres`, `itemQuadrado.tres`,
  `itemRetangulo.tres`, `itemTriangulo.tres`.
- `entities/machines/maquina_quadrados.tscn`, `maquina_retangulos.tscn`, `maquina_triangulos.tscn`.
- `entities/player/player.tscn`.
- `entities/props/Tapete.tscn`, `shop_node.tscn`.
- `entities/resources/physical_item.tscn`, `recurso_Arvore.tscn`, `recurso_Pedra.tscn`,
  `recurso_generico.tscn`, `resource_spawn_point.tscn`.
- `entities/tasks/tarefa_conserta_buraco.tscn`, `tarefa_generica.tscn`.
- `ui/hud/game_ui.tscn`, `world/cenario.tscn`.

Também foi limpa uma referência de metadados do terreno para um ícone de editor
do addon Better Terrain que já não existe no projeto; os tiles e sua aparência não mudaram.

Mapas atualizados: `graphify-out/graph.json`, `graph.html`, `GRAPH_REPORT.md`.
As alterações de arquivos `.import` que já existiam antes desta sessão não fazem parte da mecânica.

## Validação

Godot utilizado: 4.7 stable Mono (APIs de Godot 4).

Comando reproduzível, usando o executável Godot disponível no PATH:

```text
godot --headless --path . --scene res://examples/shape_assembly_test.tscn
```

Resultado final: **71 verificações, 0 falhas**, código de saída 0 e sem erros/avisos no log final.

A suíte cobre tipo errado, posição distante, ângulo incorreto, slot ocupado, snap exato,
offset do arrasto, retirada, slot bloqueado, soltura fora da mesa, Mouse1/R e movimento pelo viewport,
conclusão única, reset, receita vazia, encaixe opcional, volta completa de rotação,
dois ciclos de interação, reserva, cancelamento, limite de peças, saldo insuficiente,
cobrança única, conserto efetivo de quadrados/retângulos, produção física, animação,
reembolso ao remover máquina, imunidade da máquina de triângulos, venda na loja, consumo em tarefas
e inicialização do cenário principal.

O MCP do Godot foi utilizado para identificar a versão, executar a demonstração,
consultar o log e capturar/inspecionar a interface renderizada. O bridge temporário usado
para essa inspeção foi desinstalado ao terminar.

O importador/editor ainda aponta um tema personalizado ausente em um caminho externo
nas configurações pessoais do Godot. Esse problema preexistente não pertence ao projeto
e não aparece na execução final dos testes/jogo.

## Graphify

A análise inicial encontrou a montagem/UI na comunidade 7, os cartões/slot antigo na 15
e máquinas, inventário e interação conectados à comunidade 0. Os god nodes globais eram
dominados pelo addon DialogueManager; suas relações inferidas foram tratadas como orientação,
não como prova de dependência.

Após a mudança, `graphify update .` reextraiu o código/cenas/Resources sem API.
O mapa mostra os Resources de configuração separados dos componentes de interação e validação.
A fronteira concreta entre a montagem genérica e a máquina é a UI adaptadora e seus sinais.
Índices de comunidades podem mudar a cada reconstrução; use os nomes dos componentes nas consultas.

## Limitações e assets

- São puzzles por encaixes/transformações predefinidos, sem reconhecimento livre de silhuetas,
  espelhamento, escalonamento de peças ou avaliação automática de união de polígonos.
- O autor da receita deve garantir que a disposição dos slots realmente forme a silhueta desejada.
- Rotação é discreta e configurável; a validação usa o ângulo esperado, inclusive para formas simétricas.
- A conclusão bloqueia a montagem até reset. Não há persistência parcial ao fechar: as peças são devolvidas.
- Os Resources genéricos ficam nas pastas existentes de dados; o diretório de máquinas não implica
  dependência lógica do motor de montagem com `MachineNode`.
- Ícones, sprites de máquinas, personagem, tapete e sons existentes foram preservados.
  As silhuetas geométricas são polígonos simples com os ícones atuais sobrepostos como emblemas.
  Arte definitiva que acompanhe exatamente o contorno dos triângulos retângulos é uma melhoria visual futura.
