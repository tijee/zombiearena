Character = Core.class(Sprite)

function Character:setSquare(row, column)
	self.row = row
	self.column = column
	self:setPosition(column * SQUARE_SIZE, row * SQUARE_SIZE)
end