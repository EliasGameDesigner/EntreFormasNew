# Menus e textos por proximidade

## Menu inicial

**F5** abre `ui/menus/main_menu.tscn`, com a fonte m5x7, Art e as formas já
existentes. **Jogar** abre `world/play.tscn`: o mapa original entra na preparação,
sem cronômetro e sem uma segunda tela inicial. Antes da primeira lição, montagem
e produção ficam bloqueadas: siga o marcador até o balcão e escolha **Iniciar
tutorial**. A preparação livre com produção continua disponível entre os ciclos
seguintes. **Sair do jogo** fecha a aplicação.

`world/play.tscn` herda `world/first_cycle.tscn` e ativa a propriedade
`enter_preparation_on_ready`. A cena base continua disponível para testes e
execução direta no editor. F11 alterna tela cheia/janela no menu inicial.

## Pausa

Durante a preparação ou atendimento, use **Esc** ou **Pausar [Esc]**, no canto
superior direito. Opções:

- **Continuar**: retoma o estado anterior. Esc também retoma.
- **Voltar ao menu inicial**: encerra a sessão atual e mostra o menu inicial.
  Clicar em Jogar novamente limpa estoque, pontuação e progresso do tutorial.
- **Sair do jogo**: fecha a aplicação.

A pausa usa `SceneTree.paused`, congelando movimento, física, animações, produção,
chegada dos clientes e prazos. Apenas o controlador do menu permanece processando
para permitir continuar ou sair. Não há salvamento de sessão.

Com a bancada ou o atendimento modal abertos, Esc primeiro fecha essa interface.
O próximo Esc abre a pausa. O botão superior fica oculto nesses modais para não
cobrir seus controles de fechamento.

## Textos das máquinas

O componente `ui/world/nearby_label.gd` está em `NearbyLabel`, na cena base
`entities/machines/maquina_generica.tscn`, herdada pelas cinco máquinas.
Ele controla somente a visibilidade de `StatusLabel`, sem alterar fabricação ou
interação. Máquinas bloqueadas também explicam o desbloqueio quando abordadas.

No Inspector do componente:

- `show_distance`: distância de exibição em pixels do mundo; padrão **160**.
- `exit_margin`: margem adicional para ocultar após afastamento; padrão **24**.

A margem evita que o texto pisque no limite do alcance. Sem jogador ou com uma
interface modal aberta, o componente oculta o texto. O nome da bancada e os
balões dos clientes mantêm seu comportamento anterior.

## Validação

`examples/menus_proximity_test.tscn`: **40 verificações**, incluindo transições
reais entre menu e jogo, preparação, pausa e retomada, congelamento de cronômetros
e movimento, Esc com bancada aberta, proximidade e margem, máquinas bloqueadas
e reinício de sessão. Revisão gráfica em **1152 × 720**:

- `docs/images/main_menu.png`
- `docs/images/pause_menu.png`
- `docs/images/nearby_machine_label.png`

Regressões: primeiro ciclo (99), preparação (38), indicador de interação (20),
quarto ciclo (92) e tutorial do Art (60), todas sem falhas nas verificações.
