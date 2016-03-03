local ColorLabel = class("ColorLabel", function()
    return cc.Node:create()
end)

--[[
    str中每段内容以[r,g,b]颜色值开头，以[=]结束
    str = "[255,255,255]aaa[=][0,255,255]b[=]"

    size字体大小 --可为nil
    width每行显示的个数 --可为nil
    isnormal是否正常字体(描边) --可为nil
]]
function ColorLabel:ctor(str, size, width, isNormal)
    self.size = size
    self.width = width
    self.isNormal = isNormal
    self.anchorPointX = 0.5
    self.anchorPointY = 0.5

    self:setString(str)
end

function ColorLabel:setString(str)
    local contentTab = self:getContentTab(str)
    local rgbTabs = self:getRGBTab(str)

    local contentIdxTabs = self:getContentIdxTab(contentTab)
    if self.width then
        contentIdxTabs = self:changeContentIdxTab(contentIdxTabs)
    end

    self:addLabel(self:getText(contentTab), rgbTabs, contentIdxTabs)
end

function ColorLabel:getContentTab(str)
    local contentTab = {}
    for v in string.gfind(str, "%b]=") do 
        table.insert(contentTab, string.sub(v, 2, string.len(v) - 2))
    end
    return contentTab
end

function ColorLabel:getRGBTab(str)
    local rgbTabs = {}
    for w in string.gfind(str, "%b[]") do 
        if  string.sub(w,2,2) ~= "=" then --把rgb值表取出来 --[0,0,0]
            local rgbTab = {}
            local rgbs = string.sub(w, 2, string.len(w) - 1) --去掉中括号 --0,0,0
            for rgb in string.gmatch(rgbs, "%d+") do -- 把3个值分别取出来 --0 0 0
                table.insert(rgbTab, rgb)
            end
            table.insert(rgbTabs, rgbTab)
        end
    end
    return rgbTabs
end

function ColorLabel:getText(contentTab)
    local text = ""
    for k,v in pairs(contentTab) do
        text = text..v
    end
    return text
end

-- 将每段内容的第一个和最后一个的位置记下
--[[
    内容： {"aaa", "b", "ccccc"}
    位置表： {{1, 3}, {4, 4}, {5, 9}} 
]]-- 
function ColorLabel:getContentIdxTab(contentTab)
    local contentIdxTabs = {}
    local beginIdx = 1 -- 记录每段的起始index
    for k,v in pairs(contentTab) do
        local len = utf8.len(v)
        local idxTab = {}
        idxTab[1] = beginIdx
        idxTab[2] = beginIdx + len - 1
        table.insert(contentIdxTabs, idxTab)
        beginIdx = beginIdx + len
    end
    return contentIdxTabs
end

-- 改变每段内容的位置表，主要针对需要换行时换行符\n对每段内容位置的影响
--[[
    \n占一个位置
    内容： {"aa\na", "b\n", "ccccc"}
    位置表： {{1, 4}, {5, 6}, {7, 11}} 
]]-- 
function ColorLabel:changeContentIdxTab(contentIdxTabs)
    local tempContentIdxTabs = Common.copyTab(contentIdxTabs)
    local i = self.width
    for k,v in pairs(tempContentIdxTabs) do
        while (v[1] <= i) and (i <= v[2]) do
            contentIdxTabs[k][2] = contentIdxTabs[k][2] + 1
            for k1,v1 in pairs(contentIdxTabs) do
                if k1 > k then
                    v1[1] = v1[1] + 1
                    v1[2] = v1[2] + 1
                end
            end
            i = i + self.width
        end
    end
    return contentIdxTabs
end

function ColorLabel:addLabel(text, rgbTabs, contentIdxTabs)
    local row, content
    if self.width then
        row, content = Common.StringLinefeed(text, self.width)
    else
        content = text
    end
    if self.label then
        -- 直接self.label:setString(content)的话字与字会错位
        self.label:removeFromParent()
        self.label = nil
    end
    if self.isNormal then
        self.label = self:setFont(content)
    else
        self.label = self:setFont(content, nil, 1)
    end
    self.label:setAnchorPoint(self.anchorPointX, self.anchorPointY)
    for k,v in pairs(rgbTabs) do
        local idxTab = contentIdxTabs[k]
        for i=idxTab[1] - 1,(idxTab[2] - 1) do
            local sprite = self.label:getLetter(i)
            if sprite then
                sprite:setColor(cc.c3b(v[1], v[2], v[3]))
            end
        end
    end
    self:addChild(self.label)
end

function ColorLabel:setAnchorPoint(x, y)
    self.label:setAnchorPoint(x, y)
    self.anchorPointX = x
    self.anchorPointY = y
end

function ColorLabel:setAdditionalKerning(value)
    self.label:setAdditionalKerning(value)
end

function ColorLabel:getContentSize()
    return self.label:getContentSize()
end

function ColorLabel:setSystemFont()
    self.isSystemFont = true
end

function ColorLabel:setFont(text, color, outline)
    if not self.isSystemFont then
        return Common.finalFont(text, 1, 1, self.size, color, outline)
    else
        return Common.systemFont(text, 1, 1, self.size, color, outline)
    end
end

return ColorLabel