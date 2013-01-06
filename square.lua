Square = Core.class(Sprite)

local texture = Texture.new("img/test_square.png")
local texturePressed = Texture.new("img/test_square_pressed.png")

function Square:init(row, column)
	self.row = row
	self.column = column
	self.bitmap = Bitmap.new(texture)
	self:setPosition(SQUARE_SIZE * column, SQUARE_SIZE * row)
	self:addChild(self.bitmap)
end

function Square:setPressed(pressed)
	if pressed then
		self.bitmap:setTexture(texturePressed)
	else
		self.bitmap:setTexture(texture)
	end
end

function Square:isAdjacent(row, column)
	local deltaRow = math.abs(self.row - row)
	local deltaColumn = math.abs(self.column - column)
	return deltaRow <= 1 and deltaColumn <= 1
end