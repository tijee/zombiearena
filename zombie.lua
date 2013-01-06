Zombie = Core.class(Character)

local texture = Texture.new("img/test_zombie.png")
local textureDestroyed = Texture.new("img/test_zombie_destroyed.png")

function Zombie:init()
	self.destroyed = false
	self.bitmap = Bitmap.new(texture)
	self:addChild(self.bitmap)
end

function Zombie:moveToward(row, column)
	if self.row < row then
		self.row = self.row + 1
	elseif self.row > row then
		self.row = self.row - 1
	end
	if self.column < column then
		self.column = self.column + 1
	elseif self.column > column then
		self.column = self.column - 1
	end
	self:setSquare(self.row, self.column)
end

function Zombie:setDestroyed()
	self.destroyed = true
	self.bitmap:setTexture(textureDestroyed)
end