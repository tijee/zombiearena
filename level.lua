Level = Core.class(Sprite)

local ZOMBIES_COUNT = 3
local NEW_ZOMBIE_PROBABILITY = 0.3

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
	self.zombiesCount = 0
	self.zombies = {}
	for i = 1, ZOMBIES_COUNT do
		self:createZombie()
	end
	self.newZombieProbability = NEW_ZOMBIE_PROBABILITY
	
	-- player
	self.player = Player.new()
	self.player:setSquare(math.floor(columnCount / 2), math.floor(rowCount / 2))
	self:addChild(self.player)
	
	self.playerTurn = true
end

function Level:onMouseDown(event)
	if not level.playerTurn then
		return
	end

	mouseDown = true
	if self:hitTestPoint(event.x, event.y) and level:playerCanMoveTo(self) then
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
		if self:hitTestPoint(event.x, event.y) and level:playerCanMoveTo(self) then
			self:setPressed(true)
			level.pressedSquare = self
			event:stopPropagation()
		end
	end
end

function Level:playerCanMoveTo(square)
	return square:isAdjacent(self.player.row, self.player.column) and self:getZombies(square.row, square.column)[1] == nil
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

function Level:createZombie()
	local zombie = Zombie.new()
	local row, column
	repeat
		row, column = self:randomZombieSquare()
	until self:getZombies(row, column)[1] == nil
	zombie:setSquare(row, column)
	self:addChild(zombie)
	self.zombiesCount = self.zombiesCount + 1
	self.zombies[self.zombiesCount] = zombie
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
	self.playerTurn = false
	
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
		
		level.playerTurn = true
		
		-- create a new zombie if needed
		local remainingZombies = 0
		for i, zombie in ipairs(self.zombies) do
			if not zombie.destroyed then
				remainingZombies = remainingZombies + 1
			end
		end
		if remainingZombies == 0 or math.random() <= self.newZombieProbability then
			self:createZombie()
		end
		self.newZombieProbability = self.newZombieProbability + 0.05
	end
	
	timer:addEventListener(Event.TIMER, onTimer)
	timer:start()
end