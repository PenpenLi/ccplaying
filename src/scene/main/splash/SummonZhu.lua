local SummonZhu = class("SummonZhu", require("scene.main.gamble.SummonHero"))

function SummonZhu:exit()
    if self.data.endFunc then
        self.data.endFunc()
    end
    self:removeFromParent()
    self = nil
end

function SummonZhu:playHeroSound()
end

return SummonZhu


