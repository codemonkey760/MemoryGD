extends Spatial
class_name Board

var CardScene = preload("res://Scenes/Card.tscn")
var CardClass = preload("res://Scripts/card.gd")

var cards = {}
var remaining_cards = {}
var size = 6

var card1 = null
var card2 = null
var allowed_misses = 36
var actual_misses = 0

func _ready():
	_buildBoard()
	
func on_card_hidden(card_name):
	pass
	
func on_card_showing(card_name):
	if card1 == null or card2 == null:
		return
		
	if card1.is_flipping() or card2.is_flipping():
		return
		
	if card1.get_type() == card2.get_type():
		remaining_cards.erase(card1.card_name)
		card1 = null
		remaining_cards.erase(card2.card_name)
		card2 = null
		
		print("You got a match!")
		
		check_for_win()
	else:
		card1.hide()
		card1 = null
		card2.hide()
		card2 = null
		
		print("Sorry, no match")
		allowed_misses -= 1
		actual_misses += 1
		print("Remaining misses: " + (allowed_misses as String))
		
		check_for_loss()

func on_card_click(card_name, event):
	if not remaining_cards.has(card_name):
		return
	
	var card = remaining_cards[card_name]
	
	if not card.is_hidden():
		return
	
	if card1 == null:
		card1 = card
	elif card2 == null:
		card2 = card
	else:
		return
		
	card.show()
	
func on_card_enter(card_name):
	pass
	
func on_card_exit(card_name):
	pass
	
func check_for_win():
	if remaining_cards.empty():
		print('Congratulations! You win!')
		
		var suffix = 's' if actual_misses != 1 else ''
		
		print('You messed up ' + (actual_misses as String) + ' time' + suffix)
		get_tree().reload_current_scene()
		
func check_for_loss():
	if allowed_misses == 0:
		print('Sorry, you lose')
		get_tree().reload_current_scene()

func _buildBoard():
	assert((size * size) % 2 == 0, 'Board dimensions should create an even number of cards')
	
	var deck = _get_deck()
	
	for i in range(size):
		for j in range(size):
			var card = CardScene.instance()
			
			var index = (i * size) + j
			var name = 'card' + (index as String)
			
			card.set_name(name)
			card.card_name = name
			card.card_type = deck.pop_front()
			card.connect('hidden', self, 'on_card_hidden')
			card.connect('showing', self, 'on_card_showing')
			card.connect('mouse_click', self, 'on_card_click')
			card.connect('mouse_enter', self, 'on_card_enter')
			card.connect('mouse_exit', self, 'on_card_exit')
			card.transform = card.transform.translated(_get_position(i,j))
			
			self.add_child(card)
			cards[card.card_name] = card
			remaining_cards[card.card_name] = card

func _get_position(i, j):
	var card_size = 1.2
	var offset = ((size * card_size) / 2.0) - 0.5
	
	var result = Vector3((i * card_size) - offset, (j * card_size) - offset, 0)
	
	return result
	
func _get_deck():
	assert(size == 6, 'Function hard coded to use size 6')
	
	var deck = []
	for i in range(0,22):
		deck.append(CardClass.CardType.TYPE_RED)
	for i in range(0,10):
		deck.append(CardClass.CardType.TYPE_GREEN)
	for i in range(0,4):
		deck.append(CardClass.CardType.TYPE_BLUE)
		
	randomize() # this is bad practice
	deck.shuffle()
	assert(deck.size() == 36, 'Deck size isnt correct')
	
	return deck 
