Level = Core.class(Sprite)

local ZOMBIE_COUNT = 3

local level
local mouseDown = false

function Level:init(rowCount, columnCount, player)
	level = self
	self.rowCount = rowCount
	self.columnCount = columnCount
	self:setPosition((application:getLogicalWidth() - columnCount * SQUARE_SIZE) / 2, (application:getLogicalHeight() - rowCount * SQUARE_SIZE) / 2)
	
	-- squares
	for row = 0, rowCount - 1 do
		for column = 0, columnCount - 1 do
			local square = Square.new(row, column)
			square:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, square)
			square:addEventListener(Event.MOUSE_UP, self.onMouseUp, square)
			square:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, square)
			self:addChild(square)
		end
	end
	
	-- zombies
	self.zombies = {}
	for i = 1, ZOMBIE_COUNT do
		local zombie = Zombie.new()
		local row, column
		repeat
			row, column = self:randomZombieSquare()
		until self:getZombies(row, column)[1] == nil
		zombie:setSquare(row, column)
		self:addChild(zombie)
		self.zombies[i] = zombie
	end
	
	-- player
	self.player = Player.new()
	self.player:setSquare(math.floor(columnCount / 2), math.floor(rowCount / 2))
	self:addChild(self.player)
end

function Level:onMouseDown(event)
	mouseDown = true
	if self:hitTestPoint(event.x, event.y) and self:isAdjacent(level.player.row, level.player.column) then
		event:stopPropagation()
		if level.pressedSquare ~= nil then
			level.pressedSquare:setPressed(false)
			level.pressedSquare = nil
		end
		self:setPressed(true)
		level.pressedSquare = self
	end
end

function Level:onMouseUp(event)
	event:stopPropagation()
	mouseDown = false
	if level.pressedSquare ~= nil then
		level.player:setSquare(level.pressedSquare.row, level.pressedSquare.column)
		level.pressedSquare:setPressed(false)
		level.pressedSquare = nil
		level:playZombies()
	end
end

function Level:onMouseMove(event)
	if mouseDown then
		if level.pressedSquare ~= nil then
			level.pressedSquare:setPressed(false)
			level.pressedSquare = nil
		end
		if self:hitTestPoint(event.x, event.y) and self:isAdjacent(level.player.row, level.player.column) then
			self:setPressed(true)
			level.pressedSquare = self
			event:stopPropagation()
		end
	end
end

function Level:randomZombieSquare()
	local side = math.random(0, 3)
	local row
	local column
	if side == 0 then
		-- top
		row = 0
		column = math.random(0, self.columnCount - 1)
	elseif side == 1 then
		-- left
		row = math.random(0, self.rowCount - 1)
		column = 0
	elseif side == 2 then
		-- bottom
		row = self.rowCount - 1
		column = math.random(0, self.columnCount - 1)
	else
		-- right
		row = math.random(0, self.rowCount - 1)
		column = self.columnCount - 1
	end
	return row, column
end

function Level:getZombies(row, column)
	local zombies = {}
	local zombiesCount = 0
	for i, zombie in ipairs(self.zombies) do
		if zombie.row == row and zombie.column == column then
			zombiesCount = zombiesCount + 1
			zombies[zombiesCount] = zombie
		end
	end
	return zombies
end

function Level:playZombies()
	local timer = Timer.new(500, 1)
	local function onTimer(event)
		-- move zombies
		for i, zombie in ipairs(self.zombies) do
			if not zombie.destroyed then
				zombie:moveToward(self.player.row, self.player.column)
			end
		end
		-- destroy zombies
		for i, zombie in ipairs(self.zombies) do
			local zombiesOnSameSquare = self:getZombies(zombie.row, zombie.column)
			if zombiesOnSameSquare[2] ~= nil then
				-- there are more than 1 zombie on this square
				zombie:setDestroyed()
			end
		end
	end
	timer:addEventListener(Event.TIMER, onTimer)
	timer:start()
end