-- 五行

local ElemType = {
    Metal = "metal",
    Wood = "wood",
    Water = "water",
    Fire = "fire",
    Earth = "earth",
}

local NumElemType = {
    [1] = ElemType.Metal,
    [2] = ElemType.Wood,
    [3] = ElemType.Water,
    [4] = ElemType.Fire,
    [5] = ElemType.Earth,
}

local ElemTypeName = {
    [ElemType.Metal] = "金",
    [ElemType.Wood] = "木",
    [ElemType.Water] = "水",
    [ElemType.Fire] = "火",
    [ElemType.Earth] = "土",
}

-- 五行相克 第一个是否克制第二个
local restraint = function(first, second)
    if type(first) == "number" then
        first = NumElemType[first]
    end

    if type(second) == "number" then
        second = NumElemType[second]
    end

    return  (first == ElemType.Metal and second == ElemType.Wood) or
        (first == ElemType.Wood  and second == ElemType.Earth) or
        (first == ElemType.Water and second == ElemType.Fire) or
        (first == ElemType.Fire  and second == ElemType.Metal) or
        (first == ElemType.Earth and second == ElemType.Water)
end

local damageRestraint = function(A, D)
    local specDamageAddition = A.specDamageAddition or 0
    local specDamageReduction = D.specDamageReduction or 0

    if ElemType.restraint(A.WX, D.WX) then
        return 0.2 + (specDamageAddition - specDamageReduction)
    elseif ElemType.restraint(D.WX, A.WX) then
        return -0.2 + (specDamageAddition - specDamageReduction)
    elseif ElemType.generate(A.WX, D.WX) then
        return 0.1
    elseif ElemType.generate(D.WX, A.WX) then
        return -0.1
    else
        return 0
    end
end

-- 五行相生, 第一个生第二个
local generate = function(first, second)
    if type(first) == "number" then
        first = NumElemType[first]
    end

    if type(second) == "number" then
        second = NumElemType[second]
    end

    return  (first == ElemType.Metal and second == ElemType.Water) or
        (first == ElemType.Wood  and second == ElemType.Fire) or
        (first == ElemType.Water and second == ElemType.Wood ) or
        (first == ElemType.Fire  and second == ElemType.Earth ) or
        (first == ElemType.Earth and second == ElemType.Metal)
end

local getElemTypeName = function(elem)
    if type(elem) == "number" then
        elem = NumElemType[elem]
    end

    return ElemTypeName[elem]
end

ElemType.restraint = restraint
ElemType.damageRestraint = damageRestraint
ElemType.generate = generate
ElemType.typeName = getElemTypeName

return ElemType
