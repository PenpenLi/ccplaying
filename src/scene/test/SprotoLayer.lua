local SprotoLayer = class("SprotoLayer", BaseLayer)
local parser = require("tool.lib.sprotoparser")
local core = require("sproto.core")

function SprotoLayer:ctor()
local sp = parser.parse [[
.foobar {
    .nest {
        a 1 : string
        b 3 : boolean
        c 5 : integer
    }
    a 0 : string
    b 1 : integer
    c 2 : boolean
    d 3 : nest

    e 4 : *string
    f 5 : *integer
    g 6 : *boolean
    h 7 : foobar
}
]]

sp = core.newproto(sp)

local st = core.querytype(sp, "foobar")

local obj = {
    a = "hello",
    b = 1000000,
    c = true,
    d = {
        a = "world",
        -- skip b
        c = -1,
    },
    e = { "ABC", "def" },
    f = { -3, -2, -1, 0 , 1, 2},
    g = { true, false, true },
    h = { b = 100 },
--  h = {
--      { b = 100 },
--      {},
--      { b = -100, c= false },
--      { b = 0, e = { "test" } },
--  },
}

-- local sp2 = parser.parse [[
-- .Person {
--     name 0 : string
--     age 1 : integer
--     marital 2 : boolean 
-- }
-- ]]

local sp2 = parser.parse [[
 .Parent {
    .Person {
        name 0 : string
        age 1 : integer
        marital 2 : boolean 
    }
    name 0 : string
    age 1 : integer
    children 3 : *Person
}     
]]


sp2 = core.newproto(sp2)

-- local obj2 = {
--     name = "Alice",
--     age = 13,
--     marital = false
-- }

local obj2 = {
    name = "Bob",
    age = 40,
    children = {
        { name = "Alice",  age = 13, marital = false },
    }
}

local st2 = core.querytype(sp2, "Parent")
-- local st2 = core.querytype(sp2, "Person")

local code2 = core.encode(st2, obj2)
parser.dump(code2)
 
local resultObj = core.decode(st2, code2)
CCLog("---->", vardump(obj2))
CCLog("---->", vardump(resultObj))
-- local code = core.encode(st, obj)
-- parser.dump(code)
-- print("\n")
-- local pack = core.pack(code)
-- parser.dump(pack)
-- print("\n")
-- local unpa = core.unpack(pack)
-- parser.dump(unpa)
-- print("\n")


end

function SprotoLayer:onCleanup()
    if self.data.deaccelerateScrollingEntryID ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.data.deaccelerateScrollingEntryID)
        self.data.deaccelerateScrollingEntryID = nil
    end
end

return SprotoLayer