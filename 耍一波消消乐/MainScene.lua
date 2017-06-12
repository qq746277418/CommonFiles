require("app.views.getVecP")
local RuleLayer = import(".xxl.RuleLayer")
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
	cc.SpriteFrameCache:getInstance():addSpriteFrames("Item.plist")

	local background = display.newSprite("GameBackground.png",display.cx,display.cy)
        :addTo(self)

    -- 添加背景粒子特效
    local particle = cc.ParticleSystemQuad:create("gameBack.plist")
    self:addChild(particle)

    local ruleLayer = RuleLayer.new()
    self:addChild(ruleLayer)
end

return MainScene
