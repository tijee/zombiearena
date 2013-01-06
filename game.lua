Game = Core.class(Sprite)

local ROW_COUNT = 9
local COLUMN_COUNT = 9
local ZOMBIES_COUNT = 3
local NEW_ZOMBIE_PROBABILITY = 0.3

local mouseDown = false

function Game:init()
	self:setPosition((application:getLogicalWidth() - COLUMN_COUNT * SQUARE_SIZE) / 2, (application:getLogicalHeight() - ROW_COUNT * SQUARE_SIZE) / 2)
	
	-- create squares
	for row = 0, ROW_COUNT - 1 do
		for column = 0, COLUMN_COUNT - 1 do
			local square = Square.new(row, column)
			square:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, square)
			square:addEventListener(Event.MOUSE_UP, self.onMouseUp, square)
			square:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, square)
			self:addChild(square)
		end
	end
	
	-- create zombies
	self.zombiesCount = 0
	self.zombies = {}
	for i = 1, ZOMBIES_COUNT do
		self:createZombie()
	end
	self.newZombieProbability = NEW_ZOMBIE_PROBABILITY
	
	-- create player
	self.player = Player.new()
	self.player:setSquare(math.floor(COLUMN_COUNT / 2), math.floor(ROW_COUNT / 2))
	self:addChild(self.player)
	
	self.playerTurn = true
end

function Game:onMouseDown(event)
	if not game.playerTurn then
		return
	end

	mouseDown = true
	if self:hitTestPoint(event.x, event.y) and game:playerCanMoveTo(self) then
		event:stopPropagation()
		if game.pressedSquare ~= nil then
			game.pressedSquare:setPressed(false)
			game.pressedSquare = nil
		end
		self:setPressed(true)
		game.pressedSquare = self
	end
end

function Game:onMouseUp(event)
	event:stopPropagation()
	mouseDown = false
	if game.pressedSquare ~= nil then
		game.player:setSquare(game.pressedSquare.row, game.pressedSquare.column)
		game.pressedSquare:setPressed(false)
		game.pressedSquare = nil
		game:playZombies()
	end
end

function Game:onMouseMove(event)
	if mouseDown then
		if game.pressedSquare ~= nil then
			game.pressedSquare:setPressed(false)
			game.pressedSquare = nil
		end
		if self:hitTestPoint(event.x, event.y) and game:playerCanMoveTo(self) then
			self:setPressed(true)
			game.pressedSquare = self
			event:stopPropagation()
		end
	end
end

function Game:playerCanMoveTo(square)
	return square:isAdjacent(self.player.row, self.player.column) and self:getZombies(square.row, square.column)[1] == nil
end

function Game:randomZombieSquare()
	local side = math.random(0, 3)
	local row
	local column
	if side == 0 then
		-- top
		row = 0
		column = math.random(0, COLUMN_COUNT - 1)
	elseif side == 1 then
		-- left
		row = math.random(0, ROW_COUNT - 1)
		column = 0
	elseif side == 2 then
		-- bottom
		row = ROW_COUNT - 1
		column = math.random(0, COLUMN_COUNT - 1)
	else
		-- right
		row = math.random(0, ROW_COUNT - 1)
		column = COLUMN_COUNT - 1
	end
	return row, column
end

function Game:createZombie()
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

function Game:getZombies(row, column)
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

function Game:playZombies()
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
		
		if game:getZombies(game.player.row, game.player.column)[1] ~= nil then
			-- player died in a horrible way!
			local textfield = TextField.new(nil, "Game over")
			textfield:setPosition((game:getWidth() - textfield:getWidth()) / 2, (game:getHeight() - textfield:getHeight()) / 2)
			game:addChild(textfield)
			return
		end
		
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
		
		game.playerTurn = true
	end
	
	timer:addEventListener(Event.TIMER, onTimer)
	timer:start()
end