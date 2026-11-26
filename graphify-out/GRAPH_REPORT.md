# Graph Report - FaculProNew  (2026-11-25)

## Corpus Check
- 274 files · ~2,955,475 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1533 nodes · 3602 edges · 35 communities detected
- Extraction: 72% EXTRACTED · 28% INFERRED · 0% AMBIGUOUS · INFERRED: 1018 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]

## God Nodes (most connected - your core abstractions)
1. `is_empty()` - 81 edges
2. `translate()` - 47 edges
3. `clear()` - 42 edges
4. `DialogueManager` - 37 edges
5. `run()` - 31 edges
6. `search()` - 30 edges
7. `get_setting()` - 27 edges
8. `_resolve()` - 25 edges
9. `get_line()` - 23 edges
10. `show_notification()` - 23 edges

## Surprising Connections (you probably didn't know these)
- `_clear_highlighting_cache()` --calls--> `clear()`  [INFERRED]
  addons/dialogue_manager/components/code_edit_syntax_highlighter.gd → ui/machine_repair/shape_assembly_board.gd
- `_on_text_edit_text_changed()` --calls--> `clear()`  [INFERRED]
  addons/dialogue_manager/components/search_and_replace.gd → ui/machine_repair/shape_assembly_board.gd
- `start()` --calls--> `_on_resource_gathered()`  [INFERRED]
  addons/dialogue_manager/views/debugger_view.gd → entities/resources/resource_spawn_point.gd
- `is_valid()` --calls--> `is_empty()`  [INFERRED]
  data/items/shape_piece_data.gd → entities/player/player_hands.gd
- `_draw()` --calls--> `_draw()`  [INFERRED]
  ui/machine_repair/free_mold_board.gd → world/factory_layout.gd

## Communities

### Community 0 - "Community 0"
Cohesion: 0.02
Nodes (140): check(), run(), check(), deposit(), fabricate(), ground(), pickup(), run() (+132 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (126): BaseDialogueTestScene, get_files_with_errors(), move_file_path(), DMPlugin, DMSettings, build_menu(), _on_files_list_file_double_clicked(), _on_menu_button_pressed() (+118 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (87): start(), stop(), queue_updating_dependencies(), show_notification(), Interactable, _process(), interaction_progress(signal), interaction_started(signal) (+79 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (86): _clear_highlighting_cache(), _get_line_syntax_highlighting(), _highlight_expression(), _highlight_goto(), add_error(), add_reference_to_cue(), build_line_tree(), compile() (+78 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (89): is_valid(), has_resolve_method_failed(), is_supported(), resolve_color_property(), resolve_method(), resolve_property(), resolve_vector2_property(), resolve_vector3_property() (+81 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (13): Container, DialogueLabel, DialogueManagerRuntime, DialogueLine, DialogueManager, DialogueManagerRuntime, DialogueResponse, DialogueManagerRuntime (+5 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (14): AssemblyDefinition, ItemData, check(), MachineData, get_requirements(), ProductionRecipe, Resource, _on_resource_gathered() (+6 more)

### Community 7 - "Community 7"
Cohesion: 0.05
Nodes (39): CharacterBody2D, to_data(), action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable3D, DialogueManagerRuntime (+31 more)

### Community 8 - "Community 8"
Cohesion: 0.05
Nodes (59): _draw(), _match_remaining(), _matches(), _remove_piece(), set_hint(), mold_assembled(signal), try_snap(), close_ui() (+51 more)

### Community 9 - "Community 9"
Cohesion: 0.04
Nodes (53): apply_theme(), _on_banner_image_gui_input(), _on_buy_my_game_pressed(), _on_examples_pressed(), _on_new_button_pressed(), _on_quick_open_pressed(), new_button_pressed(signal), quick_open_button_pressed(signal) (+45 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (62): _add_character_name_completions(), _add_jump_completions(), _add_mutation_completions(), check_active_cue(), _confirm_code_completion(), delete_current_line(), _drop_data(), _find_definition_in_script() (+54 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (41): _get_speed(), _mutate_inline_mutations(), _mutate_remaining_mutations(), _process(), _should_auto_pause(), finished_typing(signal), skipped_typing(signal), spoke(signal) (+33 more)

### Community 12 - "Community 12"
Cohesion: 0.06
Nodes (46): available(), _choose_step(), dismiss(), _ground_item(), hint(), _on_assembly(), _on_delivery(), _on_deposit() (+38 more)

### Community 13 - "Community 13"
Cohesion: 0.06
Nodes (37): _icon(), _label(), _ready(), _separator(), add_errors_to_file(), add_file(), get_dependent_paths_for_reimport(), _get_dialogue_files_in_filesystem() (+29 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (23): Button, _on_download_button_pressed(), _on_http_request_request_completed(), _on_notes_button_pressed(), _ready(), failed(signal), updated(signal), setup() (+15 more)

### Community 15 - "Community 15"
Cohesion: 0.1
Nodes (26): BaseControler2D, get_direction(), get_speed(), move(), ChangeSpriteDirection(signal), hit_ceiling(signal), EditorPlugin, SideScrollingControler2D (+18 more)

### Community 16 - "Community 16"
Cohesion: 0.11
Nodes (20): Control, workshop_active(), _ready(), button(), card(), label(), cancel(), check() (+12 more)

### Community 17 - "Community 17"
Cohesion: 0.12
Nodes (25): apply_filter(), apply_theme(), _on_list_item_clicked(), _on_menu_button_about_to_popup(), _on_menu_button_id_pressed(), _on_theme_changed(), _ready(), select_cue() (+17 more)

### Community 18 - "Community 18"
Cohesion: 0.16
Nodes (10): _apply_visual(), next_appearance(), _process(), _ready(), _show_walk_frame(), start_walking(), stop_walking(), check() (+2 more)

### Community 19 - "Community 19"
Cohesion: 0.31
Nodes (8): _add_exterior_props(), _add_wall_collision(), _draw(), _draw_cutaway_wall(), _draw_wall(), _draw_wall_post(), _draw_wall_tile(), _ready()

### Community 20 - "Community 20"
Cohesion: 0.22
Nodes (3): Area2D, DialogueActionable2D, DialogueManagerRuntime

### Community 21 - "Community 21"
Cohesion: 0.22
Nodes (3): Area3D, DialogueActionable3D, DialogueManagerRuntime

### Community 22 - "Community 22"
Cohesion: 0.32
Nodes (5): action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable2D

### Community 23 - "Community 23"
Cohesion: 0.29
Nodes (3): DialogueManagerRuntime, DialogueMarker2D, Marker2D

### Community 24 - "Community 24"
Cohesion: 0.29
Nodes (3): DialogueManagerRuntime, DialogueMarker3D, Marker3D

### Community 25 - "Community 25"
Cohesion: 0.38
Nodes (4): DMWaiter, clear_all(), _input(), waited(signal)

### Community 26 - "Community 26"
Cohesion: 0.4
Nodes (3): all(), find_for_character(), DialogueMarker2D

### Community 27 - "Community 27"
Cohesion: 0.4
Nodes (3): all(), find_for_character(), DialogueMarker3D

### Community 28 - "Community 28"
Cohesion: 0.5
Nodes (3): DMInspectorPlugin, _is_dialogue_resource_property(), _parse_property()

### Community 29 - "Community 29"
Cohesion: 0.4
Nodes (1): DMPreviewGenerator

### Community 30 - "Community 30"
Cohesion: 0.5
Nodes (1): DMTreeLine

### Community 31 - "Community 31"
Cohesion: 0.67
Nodes (1): DMResolvedTagData

### Community 32 - "Community 32"
Cohesion: 0.67
Nodes (1): DMError

### Community 33 - "Community 33"
Cohesion: 1.0
Nodes (1): DMCompilerRegEx

### Community 34 - "Community 34"
Cohesion: 1.0
Nodes (1): DMCompilerResult

## Knowledge Gaps
- **87 isolated node(s):** `hit_ceiling(signal)`, `SideScrollingControler2D`, `sprint_start(signal)`, `sprint_end(signal)`, `jump_start(signal)` (+82 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 29`** (5 nodes): `preview_generator.gd`, `DMPreviewGenerator`, `_generate()`, `_generate_small_preview_automatically()`, `_handles()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (4 nodes): `tree_line.gd`, `DMTreeLine`, `_init()`, `_to_string()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (3 nodes): `resolved_tag_data.gd`, `DMResolvedTagData`, `_init()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (3 nodes): `error.gd`, `DMError`, `_init()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (2 nodes): `compiler_regex.gd`, `DMCompilerRegEx`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (2 nodes): `compiler_result.gd`, `DMCompilerResult`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `is_empty()` connect `Community 7` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 6`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 16`, `Community 18`, `Community 22`?**
  _High betweenness centrality (0.221) - this node is a cross-community bridge._
- **Why does `clear()` connect `Community 0` to `Community 1`, `Community 2`, `Community 3`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 17`?**
  _High betweenness centrality (0.134) - this node is a cross-community bridge._
- **Why does `translate()` connect `Community 4` to `Community 1`, `Community 3`, `Community 5`, `Community 9`, `Community 11`, `Community 14`, `Community 17`?**
  _High betweenness centrality (0.078) - this node is a cross-community bridge._
- **Are the 77 inferred relationships involving `is_empty()` (e.g. with `translate()` and `_on_breaked()`) actually correct?**
  _`is_empty()` has 77 INFERRED edges - model-reasoned connections that need verification._
- **Are the 33 inferred relationships involving `translate()` (e.g. with `_setup_session()` and `refresh()`) actually correct?**
  _`translate()` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 40 inferred relationships involving `clear()` (e.g. with `build_line_tree()` and `_get_state_shortcuts()`) actually correct?**
  _`clear()` has 40 INFERRED edges - model-reasoned connections that need verification._
- **What connects `hit_ceiling(signal)`, `SideScrollingControler2D`, `sprint_start(signal)` to the rest of the system?**
  _87 weakly-connected nodes found - possible documentation gaps or missing edges._