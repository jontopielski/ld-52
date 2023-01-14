extends Node2D

export(Texture) var arrow = null
export(Texture) var pointing_hand = null
export(Texture) var pointing_hand_pressed = null
export(Texture) var glass = null

var is_pointing_hand_pressed = false

func _ready():
	update_all_cursors()
	get_tree().connect("screen_resized", self, "update_all_cursors")

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and Input.get_current_cursor_shape() == Input.CURSOR_POINTING_HAND and !is_pointing_hand_pressed:
		update_cursor(pointing_hand_pressed, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
		is_pointing_hand_pressed = true
	elif is_pointing_hand_pressed and !Input.is_mouse_button_pressed(BUTTON_LEFT):
		update_cursor(pointing_hand, Input.CURSOR_POINTING_HAND, Vector2(4, 0))
		is_pointing_hand_pressed = false

func update_all_cursors():
	update_cursor(arrow, Input.CURSOR_ARROW)
	update_cursor(pointing_hand, Input.CURSOR_POINTING_HAND, Vector2(4, 0))

func update_cursor(cursor_sprite, cursor_shape, offset = Vector2.ZERO):
	var current_window_size = OS.window_size
	var base_window_size = get_viewport_rect().size
	var scale_multiple = min(floor(current_window_size.x / base_window_size.x), floor(current_window_size.y / base_window_size.y))

	var texture = ImageTexture.new()
	var image = cursor_sprite.get_data()
	var palette_white = PaletteManager.get_current_white_color()
	var used_rect = image.get_used_rect()
	image.lock()
	for x in range(used_rect.position.x, used_rect.position.x + used_rect.size.x):
		for y in range(used_rect.position.y, used_rect.position.y + used_rect.size.y):
			if image.get_pixel(x, y) == Color.white:
				image.set_pixel(x, y, palette_white)
	image.unlock()
	image.resize(image.get_size().x * (scale_multiple), image.get_size().y * (scale_multiple), Image.INTERPOLATE_NEAREST)
	texture.create_from_image(image)
	
	Input.set_custom_mouse_cursor(texture, cursor_shape, offset)
