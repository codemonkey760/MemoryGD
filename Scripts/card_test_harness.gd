extends Spatial

var Card = preload("res://Scenes/Card.tscn")
var CardClass = load("res://Scripts/card.gd")

var cards = {}
var seconds_showing = 0.0
var flipping = false
var showing = false

func _ready():
	var card = Card.instance()
	card.card_name = 'card1'
	card.card_type = CardClass.CardType['TYPE_BLUE']
	card.rotation_rate_degrees = 180.0
	card.connect('hidden', self, '_card_hidden')
	card.connect('showing', self, '_card_showing')
	card.set_name('card1')
	self.add_child(card, true)
	
	cards['card1'] = card

func _process(delta):
	if not flipping and not showing and seconds_showing <= 0.0:
		cards['card1'].show()
		flipping = true
		
	if not flipping and showing and seconds_showing >= 2.0:
		cards['card1'].hide()
		flipping = true
		
	if not flipping and showing:
		seconds_showing += delta
		
	if not flipping and not showing:
		seconds_showing -= delta

func _card_hidden(card_name):
	flipping = false
	showing = false
	
func _card_showing(card_name):
	flipping = false
	showing = true
