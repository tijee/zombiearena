SQUARE_SIZE = 32

application:setKeepAwake(true)

game = Game.new()
stage:addChild(game)

local function onNewGame(target, event)
	if target:hitTestPoint(event.x, event.y) then
		stage:removeChild(game)
		game = Game.new()
		stage:addChild(game)
	end
end

local newGameButton = Bitmap.new(Texture.new("img/test_button.jpg"))
newGameButton:setPosition((application:getLogicalWidth() - newGameButton:getWidth()) / 2, application:getLogicalHeight() - newGameButton:getHeight() - 30)
newGameButton:addEventListener(Event.MOUSE_DOWN, onNewGame, newGameButton)
stage:addChild(newGameButton)