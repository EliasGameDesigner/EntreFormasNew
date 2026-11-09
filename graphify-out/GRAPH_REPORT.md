# Graph Report - FaculProNew  (2026-11-08)

## Corpus Check
- 229 files · ~1,649,186 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1353 nodes · 3097 edges · 34 communities detected
- Extraction: 73% EXTRACTED · 27% INFERRED · 0% AMBIGUOUS · INFERRED: 846 edges (avg confidence: 0.8)
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
1. `is_empty()` - 75 edges
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
- `_on_text_edit_text_changed()` --calls--> `clear()`  [INFERRED]
  addons/dialogue_manager/components/search_and_replace.gd → ui/machine_repair/shape_assembly_board.gd
- `start()` --calls--> `_on_resource_gathered()`  [INFERRED]
  addons/dialogue_manager/views/debugger_view.gd → entities/resources/resource_spawn_point.gd
- `stop()` --calls--> `stop_ambient()`  [INFERRED]
  addons/dialogue_manager/views/debugger_view.gd → core/audio_manager.gd
- `is_valid()` --calls--> `is_empty()`  [INFERRED]
  data/items/shape_piece_data.gd → entities/player/player_hands.gd

## Communities

### Community 0 - "Community 0"
Cohesion: 0.03
Nodes (129): BaseDialogueTestScene, get_cursor(), move_file_path(), DMExportPlugin, DMPlugin, DMSettings, build_menu(), _on_files_list_file_double_clicked() (+121 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (75): play_ambient(), stop_ambient(), _ready(), _refresh(), update_pose(), _apply_visual(), next_appearance(), _process() (+67 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (83): start(), stop(), queue_updating_dependencies(), show_notification(), Interactable, _process(), interaction_progress(signal), interaction_started(signal) (+75 more)

### Community 3 - "Community 3"
Cohesion: 0.04
Nodes (97): is_valid(), has_resolve_method_failed(), is_supported(), resolve_color_property(), resolve_method(), resolve_property(), resolve_vector2_property(), resolve_vector3_property() (+89 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (83): _clear_highlighting_cache(), _get_line_syntax_highlighting(), _highlight_expression(), _highlight_goto(), add_error(), add_reference_to_cue(), build_line_tree(), compile() (+75 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (19): CanvasLayer, _get_cs_chain_members(), Container, callv_dotnet(), DialogueLabel, DialogueManagerRuntime, DialogueLine, DialogueManager (+11 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (38): play_sfx(), CharacterBody2D, to_data(), DialogueManagerRuntime, DialogueStateContext, DMCompiledLine, blocked(), check() (+30 more)

### Community 7 - "Community 7"
Cohesion: 0.05
Nodes (41): _get_speed(), _mutate_inline_mutations(), _mutate_remaining_mutations(), _process(), _should_auto_pause(), finished_typing(signal), skipped_typing(signal), spoke(signal) (+33 more)

### Community 8 - "Community 8"
Cohesion: 0.06
Nodes (10): AssemblyDefinition, ItemData, check(), MachineData, get_requirements(), ProductionRecipe, Resource, is_valid() (+2 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (45): apply_theme(), _capture(), _on_breaked(), _on_started(), _on_stopped(), _setup_session(), add_line(), _get_resource_and_id() (+37 more)

### Community 10 - "Community 10"
Cohesion: 0.06
Nodes (47): _matches(), _remove_piece(), set_hint(), mold_assembled(signal), try_snap(), close_ui(), _exit_tree(), _finish_repair() (+39 more)

### Community 11 - "Community 11"
Cohesion: 0.07
Nodes (53): _add_character_name_completions(), _add_jump_completions(), _add_mutation_completions(), check_active_cue(), _confirm_code_completion(), delete_current_line(), _drop_data(), _find_definition_in_script() (+45 more)

### Community 12 - "Community 12"
Cohesion: 0.1
Nodes (44): check(), click_at(), physics_frames(), prepare_mold(), quantity(), run(), screenshot(), snap_current_step() (+36 more)

### Community 13 - "Community 13"
Cohesion: 0.06
Nodes (36): add_errors_to_file(), add_file(), get_dependent_paths_for_reimport(), _get_dialogue_files_in_filesystem(), get_file_data(), get_files(), get_files_with_dependency(), get_files_with_errors() (+28 more)

### Community 14 - "Community 14"
Cohesion: 0.09
Nodes (24): Button, Control, _on_download_button_pressed(), _on_http_request_request_completed(), _on_notes_button_pressed(), _ready(), failed(signal), updated(signal) (+16 more)

### Community 15 - "Community 15"
Cohesion: 0.1
Nodes (26): BaseControler2D, get_direction(), get_speed(), move(), ChangeSpriteDirection(signal), hit_ceiling(signal), EditorPlugin, SideScrollingControler2D (+18 more)

### Community 16 - "Community 16"
Cohesion: 0.12
Nodes (25): apply_filter(), apply_theme(), _on_list_item_clicked(), _on_menu_button_about_to_popup(), _on_menu_button_id_pressed(), _on_theme_changed(), _ready(), select_cue() (+17 more)

### Community 17 - "Community 17"
Cohesion: 0.33
Nodes (8): _on_banner_image_gui_input(), _on_buy_my_game_pressed(), _on_examples_pressed(), _on_new_button_pressed(), _on_quick_open_pressed(), new_button_pressed(signal), quick_open_button_pressed(signal), CenterContainer

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
- **86 isolated node(s):** `hit_ceiling(signal)`, `SideScrollingControler2D`, `sprint_start(signal)`, `sprint_end(signal)`, `jump_start(signal)` (+81 more)
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

- **Why does `is_empty()` connect `Community 6` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 20`, `Community 21`?**
  _High betweenness centrality (0.212) - this node is a cross-community bridge._
- **Why does `clear()` connect `Community 12` to `Community 0`, `Community 1`, `Community 2`, `Community 3`, `Community 4`, `Community 5`, `Community 7`, `Community 9`, `Community 10`, `Community 11`, `Community 13`, `Community 16`?**
  _High betweenness centrality (0.156) - this node is a cross-community bridge._
- **Why does `translate()` connect `Community 3` to `Community 0`, `Community 4`, `Community 5`, `Community 7`, `Community 9`, `Community 13`, `Community 14`, `Community 16`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Are the 71 inferred relationships involving `is_empty()` (e.g. with `translate()` and `_on_breaked()`) actually correct?**
  _`is_empty()` has 71 INFERRED edges - model-reasoned connections that need verification._
- **Are the 33 inferred relationships involving `translate()` (e.g. with `_setup_session()` and `refresh()`) actually correct?**
  _`translate()` has 33 INFERRED edges - model-reasoned connections that need verification._
- **Are the 36 inferred relationships involving `clear()` (e.g. with `build_line_tree()` and `_get_state_shortcuts()`) actually correct?**
  _`clear()` has 36 INFERRED edges - model-reasoned connections that need verification._
- **Are the 20 inferred relationships involving `search()` (e.g. with `build_line_tree()` and `parse_cue_line()`) actually correct?**
  _`search()` has 20 INFERRED edges - model-reasoned connections that need verification._