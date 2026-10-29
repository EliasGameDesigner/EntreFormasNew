# Clientes da fábrica

Quatro sprites transparentes gerados com a ferramenta nativa ImageGen, usando `assets/textures/characters/character_idle.png` como referência. Cada cliente possui repouso frontal e quatro quadros de caminhada lateral. Na chegada anda para a esquerda, na saída para a direita, e volta ao repouso frontal ao parar no balcão.

| Arquivo | Aparência |
| --- | --- |
| artisan.png | Artesã de avental e blusa verde-azulada |
| elder.png | Artesão grisalho de colete vinho |
| merchant.png | Comerciante de jaqueta azul |
| farmer.png | Agricultora com tranças e lenço ocre |

PNGs originais preservados em `assets/textures/characters/customers/`. Os recursos `data/customers/*.tres` recortam as margens transparentes sem modificar os arquivos. O script `entities/props/customer_sprite.gd` normaliza a altura para 80 pixels (parâmetro `display_height`), aplica filtro nearest e o shader de recorte de alpha do jogador.

A cada pedido novo, o cliente recebe uma aparência de um saco embaralhado de quatro opções. Todas aparecem antes da próxima rodada do sorteio, e a primeira da nova rodada não pode repetir a última anterior. O gerador aleatório visual é independente do gerador usado pelos pedidos. A saída preserva o visual de quem chegou. Roupas não recebem mais a antiga modulação de cor HSV.

## Verificação

- `examples/customer_visual_test.tscn`: 109 verificações sem falhas em headless. Cobre cinco grupos de clientes, repetição entre grupos, altura, atualizações do HUD, chegada, repouso, saída, fim e reinício da rodada.
- `examples/customer_walk_test.tscn`: 64 verificações sem falhas. Verifica os quatro clientes, avanço por distância, repetição dos quadros, alinhamento do canvas, parada sem deslocamento, orientação e retorno ao idle.
- `examples/first_cycle_test.tscn`: 99 verificações sem falhas no modo headless.
- Prévia: `docs/images/customer_variants.png`; captura no mapa: `docs/images/customer_in_factory.png`.

## Prompts de geração

Referência comum: `assets/textures/characters/character_idle.png`. Fundo transparente ativado em todas as chamadas. Prompt base:

> ONE single full-body customer NPC sprite for a top-down workshop RPG. Match reference player's pixel-art rendering, dark pixel outlines, muted earthy colors, large head and compact adult body proportions, front-facing view with slightly overhead camera. Standing idle BOTH boots flat on same baseline, arms relaxed, not walking. Same scale and detail level as reference. No tools in hands. Entire body centered with transparent padding. Transparent alpha background, no floor, shadows, glow, text or labels. Only ONE character, NOT a sheet or multiple poses. 

Complementos por variante:

1. Variant: adult woman artisan with warm brown skin, dark curly hair tied in a low bun, muted teal work blouse, tan waist apron, dark brown trousers and boots, small copper belt buckle. Friendly neutral expression. Distinct from the reference man, no cap.

2. Variant: older male craftsman with fair weathered skin, full short gray beard, bald crown with gray side hair, muted burgundy vest over beige long-sleeved shirt, charcoal brown trousers, sturdy brown boots, brass belt buckle. Friendly neutral expression. No cap, no apron. Same small game sprite proportions as reference.

3. Variant: adult male merchant with dark brown skin, short black hair, small neat moustache, dusty indigo-blue short jacket over ochre shirt, dark olive trousers and brown boots, leather belt and brass buckle. Bare head, no cap or apron, hands empty. Friendly neutral expression. Same compact proportions and style as reference.

4. Variant: adult woman farmer with fair lightly freckled skin, auburn hair in two short braids, a muted ochre headscarf tied back, cream blouse under moss-green sleeveless tunic, dark brown trousers and sturdy brown boots, simple leather belt. Friendly neutral expression, hands empty, no apron. Same compact adult proportions as reference.

