tool
extends Sprite

enum shelfVariantTypes  {WoodEmpty = 0, WoodBoxes = 1, WoodBooks = 2, WoodBooks2 = 3, MetalEmpty = 4, MetalBoxes = 5}

export(shelfVariantTypes) var shelfVariant = shelfVariantTypes.WoodEmpty


func _ready():
	setupSprite()
	
func setupSprite():
	self.frame = shelfVariant

