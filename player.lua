Player = Core.class(Character)

local texture = Texture.new("img/test_player.png")

function Player:init()
	self:addChild(Bitmap.new(texture))
end