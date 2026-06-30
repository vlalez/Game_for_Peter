class_name WordData
extends Resource
## A single word the child must spell: the text, its illustration, and an
## optional spoken pronunciation. One .tres per word lives in resources/words/.

@export var word: String = ""
@export var image: Texture2D
@export var pronunciation: AudioStream
