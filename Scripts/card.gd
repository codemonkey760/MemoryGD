extends Spatial
class_name Card

var RedItem = preload("res://Materials/red_item.tres")
var GreenItem = preload("res://Materials/green_item.tres")
var BlueItem = preload("res://Materials/blue_item.tres")

enum CardType {TYPE_RED, TYPE_GREEN, TYPE_BLUE}
enum FlipState {HIDDEN, UNHIDING, SHOWING, HIDING}
const DEFAULT_ROTATION_RATE_DEGREES = 720.0

export(CardType) var card_type = CardType.TYPE_RED setget set_type, get_type
export(float) var rotation_rate_degrees = DEFAULT_ROTATION_RATE_DEGREES
export(String) var card_name 
var current_orientation = 0
var current_flip_state = FlipState.HIDDEN
var TypeMaterialMapping = {
	CardType.TYPE_RED: RedItem,
	CardType.TYPE_GREEN: GreenItem,
	CardType.TYPE_BLUE: BlueItem
}

signal hidden(card_name)
signal showing(card_name)
signal mouse_enter(card_name)
signal mouse_exit(card_name)
signal mouse_click(card_name, event)

func _ready():
	var pick_shape = get_node("PickShape")
	assert(pick_shape != null)
	
	pick_shape.connect("mouse_entered", self, "_on_mouse_enter")
	pick_shape.connect("mouse_exited", self, "_on_mouse_exit")
	pick_shape.connect("input_event", self, "_on_input_event")

func show():
	assert(current_flip_state == FlipState.HIDDEN)
	if current_flip_state != FlipState.HIDDEN:
		push_error('Invalid card flip state transition')
		return
		
	current_flip_state = FlipState.UNHIDING

func hide():
	assert(current_flip_state == FlipState.SHOWING)
	if current_flip_state != FlipState.SHOWING:
		push_error('Invalid card flip state transition')
		return
		
	current_flip_state = FlipState.HIDING
	
func get_type():
	return card_type
	
func set_type(new_type):
	card_type = new_type
	var material = TypeMaterialMapping[card_type]
	
	var item_side_mesh = get_node("ItemSide")
	(item_side_mesh as MeshInstance).set_surface_material(0, material)
	
func is_hidden():
	return current_flip_state == FlipState.HIDDEN
	
func is_showing():
	return current_flip_state == FlipState.SHOWING
	
func is_flipping():
	return current_flip_state == FlipState.HIDING || current_flip_state == FlipState.UNHIDING
	
func _on_mouse_enter():
	emit_signal("mouse_enter", card_name)
	
func _on_mouse_exit():
	emit_signal("mouse_exit", card_name)
	
func _on_input_event(camera, event, click_position, click_normal, shade_idx):
	var mouse_event = event as InputEventMouseButton
	if null == mouse_event:
		return
		
	if not mouse_event.is_pressed():
		return
		
	emit_signal("mouse_click", card_name, event)

func _process(delta):
	if current_flip_state == FlipState.UNHIDING:
		_unhiding(delta)
	elif current_flip_state == FlipState.HIDING:
		_hiding(delta)

func _unhiding(delta):
	var theta = delta * rotation_rate_degrees
	
	if (180.0 - current_orientation) < theta:
		transform.basis = Basis(Vector3(1, 0, 0), deg2rad(180.0))
		current_orientation = 180.0
		current_flip_state = FlipState.SHOWING
		emit_signal("showing", card_name)
	else:
		current_orientation += theta
		transform.basis = transform.basis.rotated(Vector3(1, 0, 0), deg2rad(theta))

func _hiding(delta):
	var theta = delta * rotation_rate_degrees
	
	if current_orientation < theta:
		transform.basis = Basis(Vector3(1, 0, 0), 0.0)
		current_orientation = 0
		current_flip_state = FlipState.HIDDEN
		emit_signal("hidden", card_name)
	else:
		current_orientation -= theta
		transform.basis = transform.basis.rotated(Vector3(1,0,0), deg2rad(-theta))
