extends Control
class_name ShapeAssemblyBoard

signal piece_slotted(slot_index: int, item: ItemData)
signal piece_unslotted(slot_index: int, item: ItemData)
signal board_changed()

enum ShapeType {
	SQUARE,      # 2 Triângulos -> 1 Quadrado (Área = L²)
	RECTANGLE,   # 2 Quadrados -> 1 Retângulo (Área = B × H)
	TRIANGLE,    # Máquina primária / calibragem
	GENERIC      # Lista genérica de peças
}

var shape_type: ShapeType = ShapeType.GENERIC
var required_items: Array[ItemData] = []
var slotted_items: Dictionary = {} # slot_index: int -> ItemData
var hovered_slot: int = -1

# Texturas das formas
var tex_triangle: Texture2D = preload("res://Assets2D/part_triangle_small-removebg-preview.png")
var tex_square: Texture2D = preload("res://Assets2D/part_square_small-removebg-preview.png")
var tex_rectangle: Texture2D = preload("res://Assets2D/part_rectangle_small-removebg-preview.png")

# Dimensões da prancheta geométrica
var pulse_time: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(460, 210)

func _process(delta: float) -> void:
	if is_fully_assembled():
		pulse_time += delta * 4.0
		queue_redraw()

func setup_square(req_items: Array[ItemData]) -> void:
	shape_type = ShapeType.SQUARE
	required_items = req_items
	slotted_items.clear()
	hovered_slot = -1
	queue_redraw()

func setup_rectangle(req_items: Array[ItemData]) -> void:
	shape_type = ShapeType.RECTANGLE
	required_items = req_items
	slotted_items.clear()
	hovered_slot = -1
	queue_redraw()

func setup_triangle(req_items: Array[ItemData]) -> void:
	shape_type = ShapeType.TRIANGLE
	required_items = req_items
	slotted_items.clear()
	hovered_slot = -1
	queue_redraw()

func setup_generic(req_items: Array[ItemData]) -> void:
	shape_type = ShapeType.GENERIC
	required_items = req_items
	slotted_items.clear()
	hovered_slot = -1
	queue_redraw()

func get_total_slots() -> int:
	match shape_type:
		ShapeType.SQUARE:
			return 2
		ShapeType.RECTANGLE:
			return 2
		ShapeType.TRIANGLE:
			return max(1, required_items.size())
		ShapeType.GENERIC:
			return required_items.size()
	return 0

func get_filled_count() -> int:
	return slotted_items.size()

func is_fully_assembled() -> bool:
	var total = get_total_slots()
	if total == 0:
		return true
	return slotted_items.size() >= total

func is_slot_free(slot_idx: int) -> bool:
	return not slotted_items.has(slot_idx)

func get_required_item_for_slot(slot_idx: int) -> ItemData:
	if slot_idx >= 0 and slot_idx < required_items.size():
		return required_items[slot_idx]
	return null

func slot_accepts_item(slot_idx: int, item: ItemData) -> bool:
	if not is_slot_free(slot_idx):
		return false
	var req = get_required_item_for_slot(slot_idx)
	if req == null:
		return true
	return req == item

func find_first_free_slot(item: ItemData) -> int:
	var total = get_total_slots()
	for i in range(total):
		if slot_accepts_item(i, item):
			return i
	return -1

func slot_item(slot_idx: int, item: ItemData) -> bool:
	if not is_slot_free(slot_idx):
		return false
	slotted_items[slot_idx] = item
	hovered_slot = -1
	queue_redraw()
	piece_slotted.emit(slot_idx, item)
	board_changed.emit()
	return true

func unslot_item(slot_idx: int) -> ItemData:
	if not slotted_items.has(slot_idx):
		return null
	var removed = slotted_items[slot_idx]
	slotted_items.erase(slot_idx)
	hovered_slot = -1
	queue_redraw()
	piece_unslotted.emit(slot_idx, removed)
	board_changed.emit()
	return removed

# -------------------------------------------------------------
# HIT TESTING
# -------------------------------------------------------------
func get_slot_at_position(pos: Vector2) -> int:
	match shape_type:
		ShapeType.SQUARE:
			var sq_size = 170.0
			var ox = (size.x - sq_size) / 2.0
			var oy = (size.y - sq_size) / 2.0
			var rect = Rect2(ox, oy, sq_size, sq_size)
			if rect.has_point(pos):
				var rx = pos.x - ox
				var ry = pos.y - oy
				# Diagonal de (0,0) a (sq_size, sq_size): ry >= rx é o triângulo inferior-esquerdo
				return 0 if ry >= rx else 1
			return -1

		ShapeType.RECTANGLE:
			var rw = 250.0
			var rh = 125.0
			var ox = (size.x - rw) / 2.0
			var oy = (size.y - rh) / 2.0
			var rect = Rect2(ox, oy, rw, rh)
			if rect.has_point(pos):
				var rx = pos.x - ox
				return 0 if rx < (rw / 2.0) else 1
			return -1

		ShapeType.TRIANGLE:
			var tw = 160.0
			var th = 140.0
			var ox = (size.x - tw) / 2.0
			var oy = (size.y - th) / 2.0
			var rect = Rect2(ox, oy, tw, th)
			if rect.has_point(pos):
				return 0
			return -1

		ShapeType.GENERIC:
			var total = required_items.size()
			if total == 0:
				return -1
			var slot_w = 70.0
			var total_w = total * slot_w + (total - 1) * 16.0
			var start_x = (size.x - total_w) / 2.0
			var cy = (size.y - slot_w) / 2.0
			for i in range(total):
				var r = Rect2(start_x + i * (slot_w + 16.0), cy, slot_w, slot_w)
				if r.has_point(pos):
					return i
			return -1
	return -1

# -------------------------------------------------------------
# DRAG AND DROP
# -------------------------------------------------------------
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not (data is Dictionary and data.get("type") == "inventory_item"):
		hovered_slot = -1
		queue_redraw()
		return false

	var incoming_item: ItemData = data.get("item_data")
	if incoming_item == null:
		hovered_slot = -1
		queue_redraw()
		return false

	var target = get_slot_at_position(at_position)
	if target >= 0:
		if slot_accepts_item(target, incoming_item):
			if hovered_slot != target:
				hovered_slot = target
				queue_redraw()
			return true
		# Se o slot exato está ocupado, mas o outro aceita
		var alternate = 1 if target == 0 else 0
		if get_total_slots() == 2 and slot_accepts_item(alternate, incoming_item):
			if hovered_slot != alternate:
				hovered_slot = alternate
				queue_redraw()
			return true

	# Se caiu na prancheta geral, aceita se tiver slot livre compatível
	var fallback = find_first_free_slot(incoming_item)
	if fallback >= 0:
		if hovered_slot != fallback:
			hovered_slot = fallback
			queue_redraw()
		return true

	hovered_slot = -1
	queue_redraw()
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var incoming_item: ItemData = data.get("item_data")
	if incoming_item == null:
		return

	var target = get_slot_at_position(at_position)
	if target >= 0 and slot_accepts_item(target, incoming_item):
		slot_item(target, incoming_item)
		return

	# Tenta o outro slot se for montagem de 2 peças
	if get_total_slots() == 2:
		var alt = 1 if target == 0 else 0
		if slot_accepts_item(alt, incoming_item):
			slot_item(alt, incoming_item)
			return

	# Fallback para qualquer slot livre
	var free_slot = find_first_free_slot(incoming_item)
	if free_slot >= 0:
		slot_item(free_slot, incoming_item)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		hovered_slot = -1
		queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_slot = get_slot_at_position(event.position)
		if clicked_slot >= 0 and slotted_items.has(clicked_slot):
			unslot_item(clicked_slot)
			accept_event()

# -------------------------------------------------------------
# DRAWING (BLUEPRINT & GEOMETRIC ASSEMBLY)
# -------------------------------------------------------------
func _draw() -> void:
	# Fundo da prancheta técnica
	var board_bg = Rect2(Vector2.ZERO, size)
	draw_rect(board_bg, Color(0.05, 0.08, 0.13, 0.95), true)
	
	# Grid sutil de engenharia
	var grid_step = 20.0
	var col_grid = Color(0.18, 0.35, 0.55, 0.1)
	var x = 0.0
	while x <= size.x:
		draw_line(Vector2(x, 0), Vector2(x, size.y), col_grid, 1.0)
		x += grid_step
	var y = 0.0
	while y <= size.y:
		draw_line(Vector2(0, y), Vector2(size.x, y), col_grid, 1.0)
		y += grid_step

	# Moldura externa da prancheta
	draw_rect(board_bg, Color(0.25, 0.4, 0.6, 0.5), false, 2.0)

	match shape_type:
		ShapeType.SQUARE:
			_draw_square_puzzle()
		ShapeType.RECTANGLE:
			_draw_rectangle_puzzle()
		ShapeType.TRIANGLE:
			_draw_triangle_puzzle()
		ShapeType.GENERIC:
			_draw_generic_slots()

# -------------------------------------------------------------
# MONTAGEM DO QUADRADO (2 Triângulos)
# -------------------------------------------------------------
func _draw_square_puzzle() -> void:
	var sq_size = 170.0
	var ox = (size.x - sq_size) / 2.0
	var oy = (size.y - sq_size) / 2.0

	var p_tl = Vector2(ox, oy)
	var p_bl = Vector2(ox, oy + sq_size)
	var p_br = Vector2(ox + sq_size, oy + sq_size)
	var p_tr = Vector2(ox + sq_size, oy)

	var pts_slot0 = PackedVector2Array([p_tl, p_bl, p_br]) # Triângulo Inferior-Esquerdo
	var pts_slot1 = PackedVector2Array([p_tl, p_tr, p_br]) # Triângulo Superior-Direito

	var c_0 = (p_tl + p_bl + p_br) / 3.0
	var c_1 = (p_tl + p_tr + p_br) / 3.0

	# --- SLOT 0: Triângulo Inferior Esquerdo ---
	_draw_triangle_slot(0, pts_slot0, c_0, "Triângulo 1", true)

	# --- SLOT 1: Triângulo Superior Direito ---
	_draw_triangle_slot(1, pts_slot1, c_1, "Triângulo 2", false)

	# Linha diagonal divisória
	var seam_color = Color(0.3, 0.55, 0.8, 0.7)
	var seam_width = 2.0
	if is_fully_assembled():
		seam_color = Color(1.0, 0.9, 0.45, 0.95)
		seam_width = 3.0
	draw_line(p_tl, p_br, seam_color, seam_width)

	# Moldura externa do Quadrado
	var square_rect = Rect2(ox, oy, sq_size, sq_size)
	if is_fully_assembled():
		# Brilho dourado pulsante
		var pulse = (sin(pulse_time) + 1.0) * 0.5
		var gold_glow = Color(1.0, 0.85 + pulse * 0.15, 0.2, 0.9)
		draw_rect(square_rect, gold_glow, false, 4.0)
		_draw_corner_brackets(square_rect, gold_glow)
		
		# Selo central de conclusão
		var label_font = ThemeDB.fallback_font
		var label_text = "✨ QUADRADO MONTADO COM SUCESSO! (A = L²) ✨"
		var t_pos = Vector2((size.x - 300) / 2.0, oy + sq_size + 16.0)
		draw_string(label_font, t_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, 300, 11, Color(1.0, 0.9, 0.3))
	else:
		draw_rect(square_rect, Color(0.35, 0.5, 0.7, 0.8), false, 2.0)
		_draw_corner_brackets(square_rect, Color(0.35, 0.5, 0.7, 0.8))

func _draw_triangle_slot(slot_idx: int, pts: PackedVector2Array, centroid: Vector2, label: String, _is_lower: bool) -> void:
	var is_filled = slotted_items.has(slot_idx)
	var is_hover = (hovered_slot == slot_idx)

	var fill_color = Color(0.1, 0.16, 0.26, 0.4)
	var border_color = Color(0.3, 0.5, 0.75, 0.7)
	var border_width = 2.0

	if is_hover:
		fill_color = Color(0.15, 0.75, 0.4, 0.55)
		border_color = Color(0.3, 1.0, 0.55, 1.0)
		border_width = 3.0
	elif is_filled:
		fill_color = Color(0.72, 0.48, 0.2, 0.92) # Bronze/cobre
		border_color = Color(1.0, 0.85, 0.45, 1.0)
		border_width = 2.5

	# Preenche o polígono triangular
	draw_colored_polygon(pts, fill_color)

	# Borda do triângulo
	for i in range(3):
		var p1 = pts[i]
		var p2 = pts[(i + 1) % 3]
		draw_line(p1, p2, border_color, border_width)

	# Desenho do ícone / texto
	var icon_size = Vector2(40, 40)
	var icon_rect = Rect2(centroid - icon_size / 2.0, icon_size)

	if is_filled:
		# Triângulo metálico colocado
		if tex_triangle:
			draw_texture_rect(tex_triangle, icon_rect, false, Color(1, 1, 1, 1))
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-30, 26), "✔ Encaixado", HORIZONTAL_ALIGNMENT_CENTER, 60, 10, Color(1, 1, 0.8))
	elif is_hover:
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-40, 4), "Solte Aqui!", HORIZONTAL_ALIGNMENT_CENTER, 80, 12, Color(0.4, 1.0, 0.6))
	else:
		# Fantasma translúcido do triângulo
		if tex_triangle:
			draw_texture_rect(tex_triangle, icon_rect, false, Color(1, 1, 1, 0.35))
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-40, 24), label, HORIZONTAL_ALIGNMENT_CENTER, 80, 10, Color(0.7, 0.85, 1.0, 0.7))

# -------------------------------------------------------------
# MONTAGEM DO RETÂNGULO (2 Quadrados)
# -------------------------------------------------------------
func _draw_rectangle_puzzle() -> void:
	var rw = 250.0
	var rh = 125.0
	var ox = (size.x - rw) / 2.0
	var oy = (size.y - rh) / 2.0

	var half_w = rw / 2.0
	var rect_0 = Rect2(ox, oy, half_w, rh)
	var rect_1 = Rect2(ox + half_w, oy, half_w, rh)

	# Desenha Slot 0 (Quadrado Esquerdo)
	_draw_square_half_slot(0, rect_0, "Quadrado 1 (Esq)")

	# Desenha Slot 1 (Quadrado Direito)
	_draw_square_half_slot(1, rect_1, "Quadrado 2 (Dir)")

	# Linha divisória vertical
	var seam_color = Color(0.3, 0.55, 0.8, 0.7)
	var seam_width = 2.0
	if is_fully_assembled():
		seam_color = Color(1.0, 0.9, 0.45, 0.95)
		seam_width = 3.0
	draw_line(Vector2(ox + half_w, oy), Vector2(ox + half_w, oy + rh), seam_color, seam_width)

	# Moldura externa do Retângulo
	var full_rect = Rect2(ox, oy, rw, rh)
	if is_fully_assembled():
		var pulse = (sin(pulse_time) + 1.0) * 0.5
		var gold_glow = Color(1.0, 0.85 + pulse * 0.15, 0.2, 0.9)
		draw_rect(full_rect, gold_glow, false, 4.0)
		_draw_corner_brackets(full_rect, gold_glow)

		var label_font = ThemeDB.fallback_font
		var label_text = "✨ RETÂNGULO MONTADO COM SUCESSO! (A = B × H) ✨"
		var t_pos = Vector2((size.x - 320) / 2.0, oy + rh + 16.0)
		draw_string(label_font, t_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, 320, 11, Color(1.0, 0.9, 0.3))
	else:
		draw_rect(full_rect, Color(0.35, 0.5, 0.7, 0.8), false, 2.0)
		_draw_corner_brackets(full_rect, Color(0.35, 0.5, 0.7, 0.8))

func _draw_square_half_slot(slot_idx: int, r: Rect2, label: String) -> void:
	var is_filled = slotted_items.has(slot_idx)
	var is_hover = (hovered_slot == slot_idx)

	var fill_color = Color(0.1, 0.16, 0.26, 0.4)
	var border_color = Color(0.3, 0.5, 0.75, 0.7)
	var border_width = 2.0

	if is_hover:
		fill_color = Color(0.15, 0.75, 0.4, 0.55)
		border_color = Color(0.3, 1.0, 0.55, 1.0)
		border_width = 3.0
	elif is_filled:
		fill_color = Color(0.72, 0.48, 0.2, 0.92)
		border_color = Color(1.0, 0.85, 0.45, 1.0)
		border_width = 2.5

	draw_rect(r, fill_color, true)
	draw_rect(r, border_color, false, border_width)

	var centroid = r.get_center()
	var icon_size = Vector2(44, 44)
	var icon_rect = Rect2(centroid - icon_size / 2.0, icon_size)

	if is_filled:
		if tex_square:
			draw_texture_rect(tex_square, icon_rect, false, Color(1, 1, 1, 1))
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-35, 28), "✔ Encaixado", HORIZONTAL_ALIGNMENT_CENTER, 70, 10, Color(1, 1, 0.8))
	elif is_hover:
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-40, 4), "Solte Aqui!", HORIZONTAL_ALIGNMENT_CENTER, 80, 12, Color(0.4, 1.0, 0.6))
	else:
		if tex_square:
			draw_texture_rect(tex_square, icon_rect, false, Color(1, 1, 1, 0.35))
		var font = ThemeDB.fallback_font
		draw_string(font, centroid + Vector2(-45, 28), label, HORIZONTAL_ALIGNMENT_CENTER, 90, 10, Color(0.7, 0.85, 1.0, 0.7))

# -------------------------------------------------------------
# MÁQUINA DE TRIÂNGULOS (Primária)
# -------------------------------------------------------------
func _draw_triangle_puzzle() -> void:
	var tw = 160.0
	var th = 140.0
	var ox = (size.x - tw) / 2.0
	var oy = (size.y - th) / 2.0

	var p_top = Vector2(ox + tw / 2.0, oy)
	var p_bl = Vector2(ox, oy + th)
	var p_br = Vector2(ox + tw, oy + th)
	var pts = PackedVector2Array([p_top, p_bl, p_br])
	var centroid = (p_top + p_bl + p_br) / 3.0

	draw_colored_polygon(pts, Color(0.12, 0.2, 0.3, 0.6))
	draw_line(p_top, p_bl, Color(0.4, 0.7, 1.0, 0.9), 2.5)
	draw_line(p_bl, p_br, Color(0.4, 0.7, 1.0, 0.9), 2.5)
	draw_line(p_br, p_top, Color(0.4, 0.7, 1.0, 0.9), 2.5)

	var icon_size = Vector2(60, 60)
	if tex_triangle:
		draw_texture_rect(tex_triangle, Rect2(centroid - icon_size / 2.0, icon_size), false, Color(1, 1, 1, 1))

	var font = ThemeDB.fallback_font
	draw_string(font, Vector2((size.x - 300) / 2.0, oy + th + 20.0), "⭐ MÁQUINA GERADORA PRIMÁRIA PRONTA ⭐", HORIZONTAL_ALIGNMENT_CENTER, 300, 11, Color(0.4, 1.0, 0.6))

# -------------------------------------------------------------
# SLOTS GENÉRICOS (Fallback para outras máquinas)
# -------------------------------------------------------------
func _draw_generic_slots() -> void:
	var total = required_items.size()
	if total == 0:
		var font = ThemeDB.fallback_font
		draw_string(font, Vector2((size.x - 300) / 2.0, size.y / 2.0), "Esta máquina não necessita de peças sobressalentes.", HORIZONTAL_ALIGNMENT_CENTER, 300, 12, Color(0.8, 0.9, 1.0))
		return

	var slot_w = 70.0
	var total_w = total * slot_w + (total - 1) * 16.0
	var start_x = (size.x - total_w) / 2.0
	var cy = (size.y - slot_w) / 2.0

	for i in range(total):
		var r = Rect2(start_x + i * (slot_w + 16.0), cy, slot_w, slot_w)
		var is_filled = slotted_items.has(i)
		var is_hover = (hovered_slot == i)

		var fill_col = Color(0.12, 0.16, 0.25, 0.7)
		var border_col = Color(0.35, 0.5, 0.7, 0.8)
		if is_hover:
			fill_col = Color(0.15, 0.75, 0.4, 0.55)
			border_col = Color(0.3, 1.0, 0.55, 1.0)
		elif is_filled:
			fill_col = Color(0.72, 0.48, 0.2, 0.92)
			border_col = Color(1.0, 0.85, 0.45, 1.0)

		draw_rect(r, fill_col, true)
		draw_rect(r, border_col, false, 2.0)

		var req_item = required_items[i]
		var c = r.get_center()
		var icon_rect = Rect2(c - Vector2(22, 22), Vector2(44, 44))
		if is_filled:
			var it = slotted_items[i]
			if it and it.icon:
				draw_texture_rect(it.icon, icon_rect, false, Color(1, 1, 1, 1))
		else:
			if req_item and req_item.icon:
				draw_texture_rect(req_item.icon, icon_rect, false, Color(1, 1, 1, 0.35))

# -------------------------------------------------------------
# DETALHES VISUAIS (Cantoneiras / Rebites de Engenharia)
# -------------------------------------------------------------
func _draw_corner_brackets(r: Rect2, color: Color) -> void:
	var b_len = 10.0
	# Canto TL
	draw_line(r.position, r.position + Vector2(b_len, 0), color, 3.0)
	draw_line(r.position, r.position + Vector2(0, b_len), color, 3.0)
	# Canto TR
	var tr = Vector2(r.end.x, r.position.y)
	draw_line(tr, tr + Vector2(-b_len, 0), color, 3.0)
	draw_line(tr, tr + Vector2(0, b_len), color, 3.0)
	# Canto BL
	var bl = Vector2(r.position.x, r.end.y)
	draw_line(bl, bl + Vector2(b_len, 0), color, 3.0)
	draw_line(bl, bl + Vector2(0, -b_len), color, 3.0)
	# Canto BR
	draw_line(r.end, r.end + Vector2(-b_len, 0), color, 3.0)
	draw_line(r.end, r.end + Vector2(0, -b_len), color, 3.0)
