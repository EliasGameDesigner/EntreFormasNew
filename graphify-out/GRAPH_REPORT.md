# Graph Report - FaculProNew  (2026-11-12)

## Corpus Check
- 242 files · ~2,182,559 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1376 nodes · 3178 edges · 35 communities detected
- Extraction: 72% EXTRACTED · 28% INFERRED · 0% AMBIGUOUS · INFERRED: 880 edges (avg confidence: 0.8)
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
1. `is_empty()` - 77 edges
2. `translate()` - 47 edges
3. `clear()` - 38 edges
4. `DialogueManager` - 37 edges
5. `search()` - 30 edges
6. `run()` - 30 edges
7. `_resolve()` - 25 edges
8. `get_setting()` - 25 edges
9. `get_line()` - 23 edges
10. `run()` - 22 edges

## Surprising Connections (you probably didn't know these)
- `_clear_highlighting_cache()` --calls--> `clear()`  [INFERRED]
  addons/dialogue_manager/components/code_edit_syntax_highlighter.gd → ui/machine_repair/shape_assembly_board.gd
- `start()` --calls--> `_on_resource_gathered()`  [INFERRED]
  addons/dialogue_manager/views/debugger_view.gd → entities/resources/resource_spawn_point.gd
- `stop()` --calls--> `stop_ambient()`  [INFERRED]
  addons/dialogue_manager/views/debugger_view.gd → core/audio_manager.gd
- `is_valid()` --calls--> `is_empty()`  [INFERRED]
  data/items/shape_piece_data.gd → entities/player/player_hands.gd
- `_process()` --calls--> `move()`  [INFERRED]
  addons/2d_controls_toolkit/SideScrollingControler2D.gd → entities/player/player_movement.gd

## Communities

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (96): _ready(), _refresh(), update_pose(), add_label(), check(), run(), advance_time(), _clear_order() (+88 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (119): BaseDialogueTestScene, insert_text_at_cursor(), get_files_with_errors(), move_file_path(), DMPlugin, DMSettings, prepare(), _init() (+111 more)

### Community 2 - "Community 2"
Cohesion: 0.04
Nodes (101): start(), stop(), show_notification(), interaction_stopped(signal), start_interaction(), stop_interaction(), add_item(), get_all_items() (+93 more)

### Community 3 - "Community 3"
Cohesion: 0.03
Nodes (24): CanvasLayer, Container, callv_dotnet(), DialogueLabel, DialogueManagerRuntime, DialogueLine, DialogueManager, DialogueManagerRuntime (+16 more)

### Community 4 - "Community 4"
Cohesion: 0.04
Nodes (21): Area2D, AssemblyDefinition, DialogueActionable2D, DialogueManagerRuntime, Interactable, _process(), interaction_progress(signal), interaction_started(signal) (+13 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (85): is_valid(), has_resolve_method_failed(), is_supported(), resolve_color_property(), resolve_method(), resolve_property(), resolve_vector2_property(), resolve_vector3_property() (+77 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (57): apply_filter(), apply_theme(), _on_list_item_clicked(), _on_menu_button_about_to_popup(), _on_menu_button_id_pressed(), _on_theme_changed(), _ready(), select_cue() (+49 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (67): add_error(), add_reference_to_cue(), build_line_tree(), compile(), extract_condition(), extract_import_path_and_name(), extract_mutation(), extract_static_line_id() (+59 more)

### Community 8 - "Community 8"
Cohesion: 0.07
Nodes (62): _add_character_name_completions(), _add_jump_completions(), _add_mutation_completions(), check_active_cue(), _confirm_code_completion(), delete_current_line(), _drop_data(), _find_definition_in_script() (+54 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (41): _get_speed(), _mutate_inline_mutations(), _mutate_remaining_mutations(), _process(), _should_auto_pause(), finished_typing(signal), skipped_typing(signal), spoke(signal) (+33 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (29): CharacterBody2D, DialogueManagerRuntime, DialogueStateContext, blocked(), check(), run(), Node, can_be_picked_by() (+21 more)

### Community 11 - "Community 11"
Cohesion: 0.06
Nodes (36): apply_theme(), _on_banner_image_gui_input(), _on_buy_my_game_pressed(), _on_examples_pressed(), _on_new_button_pressed(), _on_quick_open_pressed(), new_button_pressed(signal), quick_open_button_pressed(signal) (+28 more)

### Community 12 - "Community 12"
Cohesion: 0.09
Nodes (24): Button, Control, _on_download_button_pressed(), _on_http_request_request_completed(), _on_notes_button_pressed(), _ready(), failed(signal), updated(signal) (+16 more)

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (19): play_ambient(), play_sfx(), stop_ambient(), _apply_visual(), next_appearance(), _process(), _ready(), _show_walk_frame() (+11 more)

### Community 14 - "Community 14"
Cohesion: 0.1
Nodes (26): BaseControler2D, get_direction(), get_speed(), move(), ChangeSpriteDirection(signal), hit_ceiling(signal), EditorPlugin, SideScrollingControler2D (+18 more)

### Community 15 - "Community 15"
Cohesion: 0.12
Nodes (23): check(), press(), run(), SceneTree, begin_drag(), _can_drop_data(), _drop_data(), end_drag() (+15 more)

### Community 16 - "Community 16"
Cohesion: 0.1
Nodes (21): _clear_highlighting_cache(), _get_line_syntax_highlighting(), _highlight_expression(), _highlight_goto(), compile_string(), extract_mutation(), extract_translatable_string(), get_line_type() (+13 more)

### Community 17 - "Community 17"
Cohesion: 0.13
Nodes (17): _capture(), _on_breaked(), _on_started(), _on_stopped(), _setup_session(), add_line(), _get_resource_and_id(), _on_clear_button_pressed() (+9 more)

### Community 18 - "Community 18"
Cohesion: 0.22
Nodes (15): get_files(), find_in_files(), find_in_line(), get_selection_key(), _on_input_text_submitted(), _on_match_case_button_toggled(), _on_replace_all_button_pressed(), _on_replace_input_text_changed() (+7 more)

### Community 19 - "Community 19"
Cohesion: 0.18
Nodes (12): _add_wall_collision(), _draw(), _draw_beam(), _ready(), _draw(), _match_remaining(), _matches(), _remove_piece() (+4 more)

### Community 20 - "Community 20"
Cohesion: 0.22
Nodes (3): Area3D, DialogueActionable3D, DialogueManagerRuntime

### Community 21 - "Community 21"
Cohesion: 0.32
Nodes (5): action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable2D

### Community 22 - "Community 22"
Cohesion: 0.32
Nodes (5): action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable3D

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
- **86 isolated node(s):** `hit_ceiling(signal)`, `SideScrollingControler2D`, `sprint_start(signal)`, `sprint_end(signal)`, `jump_start(signal)` (+81 more)
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

- **Why does `is_empty()` connect `Community 8` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 6`, `Community 7`, `Community 9`, `Community 10`, `Community 11`, `Community 13`, `Community 15`, `Community 16`, `Community 17`, `Community 21`, `Community 22`?**
  _High betweenness centrality (0.222) - this node is a cross-community bridge._
- **Why does `clear()` connect `Community 6` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 11`, `Community 15`, `Community 16`, `Community 17`, `Community 18`?**
  _High betweenness centrality (0.162) - this node is a cross-community bridge._
- **Why does `translate()` connect `Community 5` to `Community 1`, `Community 3`, `Community 6`, `Community 7`, `Community 8`, `Community 9`, `Community 11`, `Community 12`, `Community 16`, `Community 17`?**
  _High betweenness centrality (0.097) - this node is a cross-community bridge._
- **Are the 73 inferred relationships involving `is_empty()` (e.g. with `translate()` and `_on_breaked()`) actually correct?**
  _`is_empty()` has 73 INFERRED edges - model-reasoned connections that need verification._
- **Are the 33 inferred relationships involving `translate()` (e.g. with `_setup_session()` and `refresh()`) actually correct?**
  _`translate()` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 36 inferred relationships involving `clear()` (e.g. with `build_line_tree()` and `_get_state_shortcuts()`) actually correct?**
  _`clear()` has 36 INFERRED edges - model-reasoned connections that need verification._
- **Are the 20 inferred relationships involving `search()` (e.g. with `build_line_tree()` and `parse_cue_line()`) actually correct?**
  _`search()` has 20 INFERRED edges - model-reasoned connections that need verification._