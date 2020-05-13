extends Resource

class_name MapTile

enum TILE_TYPE { EARTH, SEA }

export(Texture) var texture
export(Array, TILE_TYPE) var sides
export(Array, Vector2) var edges
