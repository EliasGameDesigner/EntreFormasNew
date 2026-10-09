# Graph Report - FaculProNew  (2026-10-04)

## Corpus Check
- 166 files · ~168,861 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1118 nodes · 2386 edges · 34 communities detected
- Extraction: 76% EXTRACTED · 24% INFERRED · 0% AMBIGUOUS · INFERRED: 573 edges (avg confidence: 0.8)
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

## God Nodes (most connected - your core abstractions)
1. `translate()` - 47 edges
2. `DialogueManager` - 37 edges
3. `search()` - 30 edges
4. `clear()` - 30 edges
5. `_resolve()` - 25 edges
6. `get_setting()` - 25 edges
7. `get_line()` - 22 edges
8. `get_user_value()` - 20 edges
9. `open_file()` - 18 edges
10. `add_item()` - 18 edges

## Surprising Connections (you probably didn't know these)
- `_clear_highlighting_cache()` --calls--> `clear()`  [INFERRED]
  addons/dialogue_manager/components/code_edit_syntax_highlighter.gd → ui/machine_repair/shape_assembly_board.gd
- `_get_game_states()` --calls--> `is_valid()`  [INFERRED]
  addons/dialogue_manager/dialogue_manager.gd → data/machines/production_recipe.gd
- `_get_game_states()` --calls--> `is_valid()`  [INFERRED]
  addons/dialogue_manager/dialogue_manager.gd → data/machines/assembly_definition.gd
- `_warn_about_state_name_collisions()` --calls--> `is_valid()`  [INFERRED]
  addons/dialogue_manager/dialogue_manager.gd → data/machines/production_recipe.gd
- `_warn_about_state_name_collisions()` --calls--> `is_valid()`  [INFERRED]
  addons/dialogue_manager/dialogue_manager.gd → data/machines/assembly_definition.gd

## Communities

### Community 0 - "Community 0"
Cohesion: 0.03
Nodes (81): BaseDialogueTestScene, apply_filter(), _on_menu_button_id_pressed(), _on_breaked(), add_errors_to_file(), add_file(), get_dependent_paths_for_reimport(), _get_dialogue_files_in_filesystem() (+73 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (91): has_resolve_method_failed(), is_supported(), resolve_color_property(), resolve_method(), resolve_property(), resolve_vector2_property(), resolve_vector3_property(), resolve_vector4_property() (+83 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (66): play_ambient(), stop_ambient(), stop(), DialogueManagerRuntime, DialogueStateContext, start_interaction(), add_item(), get_all_items() (+58 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (13): Container, DialogueLabel, DialogueManagerRuntime, DialogueLine, DialogueManager, DialogueManagerRuntime, DialogueResponse, DialogueManagerRuntime (+5 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (75): get_cursor(), build_menu(), _on_files_list_file_double_clicked(), _on_menu_button_pressed(), _on_menu_id_pressed(), _on_new_dialog_file_selected(), _on_open_dialog_file_selected(), _on_quick_open_dialog_confirmed() (+67 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (67): add_error(), add_reference_to_cue(), build_line_tree(), compile(), extract_condition(), extract_import_path_and_name(), extract_mutation(), extract_static_line_id() (+59 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (22): AssemblyDefinition, CharacterBody2D, Interactable, _process(), interaction_progress(signal), interaction_started(signal), interaction_stopped(signal), stop_interaction() (+14 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (55): is_valid(), play_sfx(), CanvasLayer, _send_current_scene_to_debugger(), dialogue_started(signal), _start_balloon(), _on_money_changed(), _on_update_inventory_ui() (+47 more)

### Community 8 - "Community 8"
Cohesion: 0.07
Nodes (56): _add_character_name_completions(), _add_jump_completions(), _add_mutation_completions(), check_active_cue(), _confirm_code_completion(), delete_current_line(), _drop_data(), _find_definition_in_script() (+48 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (41): _get_speed(), _mutate_inline_mutations(), _mutate_remaining_mutations(), _process(), _should_auto_pause(), finished_typing(signal), skipped_typing(signal), spoke(signal) (+33 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (34): apply_theme(), _on_banner_image_gui_input(), _on_buy_my_game_pressed(), _on_examples_pressed(), _on_new_button_pressed(), _on_quick_open_pressed(), new_button_pressed(signal), quick_open_button_pressed(signal) (+26 more)

### Community 11 - "Community 11"
Cohesion: 0.09
Nodes (24): Button, Control, _on_download_button_pressed(), _on_http_request_request_completed(), _on_notes_button_pressed(), _ready(), failed(signal), updated(signal) (+16 more)

### Community 12 - "Community 12"
Cohesion: 0.1
Nodes (26): BaseControler2D, get_direction(), get_speed(), move(), ChangeSpriteDirection(signal), hit_ceiling(signal), EditorPlugin, SideScrollingControler2D (+18 more)

### Community 13 - "Community 13"
Cohesion: 0.1
Nodes (20): _capture(), _on_started(), _on_stopped(), _setup_session(), add_line(), create_state_items(), _get_resource_and_id(), _on_clear_button_pressed() (+12 more)

### Community 14 - "Community 14"
Cohesion: 0.14
Nodes (22): apply_theme(), _on_list_item_clicked(), _on_menu_button_about_to_popup(), _on_theme_changed(), _ready(), select_cue(), cue_selected(signal), apply_filter() (+14 more)

### Community 15 - "Community 15"
Cohesion: 0.14
Nodes (17): _clear_highlighting_cache(), _get_line_syntax_highlighting(), _highlight_expression(), _highlight_goto(), extract_mutation(), extract_translatable_string(), get_line_type(), get_static_line_id() (+9 more)

### Community 16 - "Community 16"
Cohesion: 0.22
Nodes (15): get_files(), find_in_files(), find_in_line(), get_selection_key(), _on_input_text_submitted(), _on_match_case_button_toggled(), _on_replace_all_button_pressed(), _on_replace_input_text_changed() (+7 more)

### Community 17 - "Community 17"
Cohesion: 0.36
Nodes (9): is_unlocked(), _on_interaction_started(), _on_money_changed(), _process(), _ready(), refresh_display(), machine_purchased(signal), try_purchase() (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.22
Nodes (3): Area2D, DialogueActionable2D, DialogueManagerRuntime

### Community 19 - "Community 19"
Cohesion: 0.22
Nodes (3): Area3D, DialogueActionable3D, DialogueManagerRuntime

### Community 20 - "Community 20"
Cohesion: 0.32
Nodes (5): action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable2D

### Community 21 - "Community 21"
Cohesion: 0.32
Nodes (5): action(), _on_dialogue_ended(), actioned(signal), dialogue_ended(signal), DialogueActionable3D

### Community 22 - "Community 22"
Cohesion: 0.29
Nodes (3): DialogueManagerRuntime, DialogueMarker2D, Marker2D

### Community 23 - "Community 23"
Cohesion: 0.29
Nodes (3): DialogueManagerRuntime, DialogueMarker3D, Marker3D

### Community 24 - "Community 24"
Cohesion: 0.38
Nodes (4): DMWaiter, clear_all(), _input(), waited(signal)

### Community 25 - "Community 25"
Cohesion: 0.4
Nodes (3): all(), find_for_character(), DialogueMarker2D

### Community 26 - "Community 26"
Cohesion: 0.4
Nodes (3): all(), find_for_character(), DialogueMarker3D

### Community 27 - "Community 27"
Cohesion: 0.5
Nodes (3): DMInspectorPlugin, _is_dialogue_resource_property(), _parse_property()

### Community 28 - "Community 28"
Cohesion: 0.4
Nodes (1): DMPreviewGenerator

### Community 29 - "Community 29"
Cohesion: 0.5
Nodes (1): DMTreeLine

### Community 30 - "Community 30"
Cohesion: 0.67
Nodes (1): DMResolvedTagData

### Community 31 - "Community 31"
Cohesion: 0.67
Nodes (1): DMError

### Community 32 - "Community 32"
Cohesion: 1.0
Nodes (1): DMCompilerRegEx

### Community 33 - "Community 33"
Cohesion: 1.0
Nodes (1): DMCompilerResult

## Knowledge Gaps
- **85 isolated node(s):** `hit_ceiling(signal)`, `SideScrollingControler2D`, `sprint_start(signal)`, `sprint_end(signal)`, `jump_start(signal)` (+80 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 28`** (5 nodes): `preview_generator.gd`, `DMPreviewGenerator`, `_generate()`, `_generate_small_preview_automatically()`, `_handles()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 29`** (4 nodes): `tree_line.gd`, `DMTreeLine`, `_init()`, `_to_string()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 30`** (3 nodes): `resolved_tag_data.gd`, `DMResolvedTagData`, `_init()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (3 nodes): `error.gd`, `DMError`, `_init()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (2 nodes): `compiler_regex.gd`, `DMCompilerRegEx`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 33`** (2 nodes): `compiler_result.gd`, `DMCompilerResult`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `clear()` connect `Community 0` to `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 13`, `Community 14`, `Community 15`, `Community 16`?**
  _High betweenness centrality (0.196) - this node is a cross-community bridge._
- **Why does `translate()` connect `Community 1` to `Community 0`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 9`, `Community 10`, `Community 11`, `Community 13`, `Community 14`?**
  _High betweenness centrality (0.162) - this node is a cross-community bridge._
- **Why does `search()` connect `Community 5` to `Community 8`, `Community 0`, `Community 15`?**
  _High betweenness centrality (0.087) - this node is a cross-community bridge._
- **Are the 33 inferred relationships involving `translate()` (e.g. with `_setup_session()` and `refresh()`) actually correct?**
  _`translate()` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 20 inferred relationships involving `search()` (e.g. with `build_line_tree()` and `parse_cue_line()`) actually correct?**
  _`search()` has 20 INFERRED edges - model-reasoned connections that need verification._
- **Are the 28 inferred relationships involving `clear()` (e.g. with `build_line_tree()` and `_get_state_shortcuts()`) actually correct?**
  _`clear()` has 28 INFERRED edges - model-reasoned connections that need verification._
- **Are the 5 inferred relationships involving `_resolve()` (e.g. with `is_supported()` and `resolve_method()`) actually correct?**
  _`_resolve()` has 5 INFERRED edges - model-reasoned connections that need verification._