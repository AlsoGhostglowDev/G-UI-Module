local uiTab = {}
local helper = require 'ui/helper'

-- should contain: { .. {groupName, x, y, curSelected} .. }
uiTab.groups = {}
-- should contain: { .. {group, tag} .. }
uiTab.boxes = {}
-- should contain: {group, string}
uiTab.curSelected = {}
-- should contain: {group, string}
uiTab.curHovered = {}
-- should contain: { .. {group, attachedSprite's tag, offsetX, offsetY } .. }
uiTab.attachedSprites = {}
-- should contain: { .. {tag, txt, func, alwaysUpdate, section, group} .. }
uiTab.stats = {}

local function getTag(boxName, type) 
    local suffix = 'UiText'
    if type:lower() == 'bg' then suffix = 'UiBG' end
    return boxName .. suffix
end

local function indexOfGroup(grp)
    for index, v in ipairs(uiTab.groups) do
        if v[1] == grp then return index end
    end
    return -1
end

local function getGroupCurSelected(grp)
    return uiTab.groups[indexOfGroup(grp)][4]
end

local function setGroupCurSelected(grp, val)
    uiTab.groups[indexOfGroup(grp)][4] = val
end

local function setBoxProperty(boxName, type, property, value)
    setProperty(getTag(boxName, type) .. '.' .. property, value)
end

local function getBoxProperty(boxName, type, property)
    return getProperty(getTag(boxName, type) .. '.' .. property)
end

local function groupExists(grp)
    for _, n in ipairs(uiTab.getGroupNames()) do
        if n == grp then
            return true
        end
    end
    return false
end

local function getFromAttachedSprite(spr)
    for _, sprData in ipairs(uiTab.attachedSprites) do
        if sprData[2] == spr then
            return sprData
        end
    end
end

local function setupBox(group, boxName)     
    if groupExists(group) and boxName ~= '' and boxName ~= nil then
        local grpProp = uiTab.getGroupProperties(group)
        local grpLength = #(uiTab.getGroupMembers(group) or {})
        makeLuaSprite(boxName ..'UiBG', nil, grpProp[2] + (grpLength * 120), grpProp[3])
        makeGraphic(boxName ..'UiBG', 120, 24, 'FFFFFF')
        setObjectCamera(boxName ..'UiBG', 'other')
        addLuaSprite(boxName ..'UiBG')

        makeLuaText(boxName ..'UiText', boxName, 0, grpProp[2] + (grpLength * 120) + 2, grpProp[3] + 2)
        setTextSize(boxName ..'UiText', 20)
        setTextBorder(boxName ..'UiText', 0)
        setObjectCamera(boxName ..'UiText', 'other')
        addLuaText(boxName ..'UiText')

        scaleObject(group .. 'UiBG', (grpLength + 1) * 120, ((grpLength + 1) * 120) * 1.25)
        table.insert(uiTab.boxes, {group, boxName})

        for _, statData in ipairs(uiTab.stats) do
            setProperty(statData[1] ..'.fieldWidth', getProperty(group .. 'UiBG.scale.x') - (getFromAttachedSprite(statData[1])[3]))
        end

        return boxName
    end
    debugPrint('ERROR (uiTab): '.. scriptName ..': Cannot setup box: "'.. boxName ..'"!, [EXCEPTION: Group "'.. group ..'" doesn\'t exist!]', 'red')
    return nil
end

------------------ MODULE FUNCTIONS ------------------ 

function uiTab.makeBox(group, boxName)
    if setupBox(group, boxName) then
        return true
    end
    return false
end

function uiTab.makeGroup(groupName, x, y)
    table.insert(uiTab.groups, {groupName, x, y})
    makeLuaSprite(groupName .. 'UiBG', x, 24)
    makeGraphic(groupName .. 'UiBG', 1, 1, '000000')
    setProperty(groupName .. 'UiBG.alpha', 0.6)
    setObjectCamera(groupName .. 'UiBG', 'other')
    addLuaSprite(groupName .. 'UiBG')
end

function uiTab.addAttachedSprite(tag, group, offsetX, offsetY)
    if groupExists(group) then
        table.insert(uiTab.attachedSprites, {group, tag, (offsetX or 0), (offsetY or 0)})
    end
end

-- returns { .. list of all group names .. }
function uiTab.getGroupNames()
    local ret = {}
    for i, d in ipairs(uiTab.groups) do
        table.insert(ret, d[1])
    end
    return ret
end

-- returns {x, y}
function uiTab.getGroupProperties(grp) 
    local ret = {}
    for i, d in ipairs(uiTab.groups) do
        if grp == d[1] then
            ret = d
        end
    end
    return ret
end

-- returns { .. the tag for all the group's members .. }
function uiTab.getGroupMembers(group) 
    local ret = {}
    for i, d in ipairs(uiTab.boxes) do
        if d[1] == group then
            table.insert(ret, d[2])
        end
    end
    return ret
end

--[[
    Usage:

    -- This prints each one of the group's member name
    forEachMembers('foo', function(index, member)
        debugPrint('Index '.. index ..': '.. member)
    end)
]]
function uiTab.forEachMembers(group, f)
    for i, member in ipairs(uiTab.getGroupMembers(group)) do
        f(i, member)
    end
end

function uiTab.makeStatusText(tag, text, func, alwaysUpdate, group, selection, x, y)
    if groupExists(group) then
        tag = 'STAT_'..tag
        makeLuaText(tag, text:format(func()), getProperty(group .. 'UiBG.scale.x') - (x or 0))
        setObjectCamera(tag, 'other')
        addLuaText(tag)
        setTextSize(tag, 20)
        setTextAlignment(tag, 'left')
        setTextBorder(tag, 0)
        table.insert(uiTab.stats, {tag, text, func, alwaysUpdate, selection, group})
        uiTab.addAttachedSprite(tag, group, (x or 0), (y or 0))

        uiTab.reloadObjs()
    end
end

function uiTab.reloadObjs()
    for i, grp in ipairs(uiTab.groups) do
        for _, statData in ipairs(uiTab.stats) do
            if statData[6] == grp[1] then
                setProperty(statData[1]..'.visible', statData[5] == getGroupCurSelected(grp[1]))
            end
        end
    end
end

function uiTab.update()
    uiTab.curHovered = {}
    for i, data in ipairs(uiTab.boxes) do
        local group, name = data[1], data[2]
        local grpProps = uiTab.getGroupProperties(group)

        if helper.mouseOverlaps(name .. 'UiBG', 'camOther') then
            uiTab.curHovered = {group, name}
            callMethod('callOnLuas', {'onBoxHover', {name, group}})
            if mouseClicked('left') then
                if getGroupCurSelected(group) ~= name then
                    setGroupCurSelected(group, name)
                else
                    setGroupCurSelected(group, nil)
                end
                callMethod('callOnLuas', {'onBoxClick', {name, group}})

                uiTab.reloadObjs()
            elseif mouseClicked('right') then
                callMethod('callOnLuas', {'onBoxClickRight', {name, group}})
            elseif mousePressed('left') then
                for _, v in ipairs(uiTab.groups) do
                    if v[1] == group then
                        v[2] = v[2] + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaX') * 0.885)
                        v[3] = v[3] + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaY') * 0.885)
                    end
                end
            end
        end

        uiTab.forEachMembers(group, function(i, bn)
            setBoxProperty(bn, 'bg', 'x', grpProps[2] + (120 * i))
            setBoxProperty(bn, 'bg', 'y', grpProps[3])
            setBoxProperty(bn, 'txt', 'x', getBoxProperty(bn, 'bg', 'x') + ((getBoxProperty(bn, 'bg', 'width') - getBoxProperty(bn, 'text', 'width')) / 2))
            setBoxProperty(bn, 'txt', 'y', grpProps[3])
        end)

        setBoxProperty(name, 'bg', 'color', 0x000000)
        setBoxProperty(name, 'bg', 'alpha', 0.85)
        setBoxProperty(name, 'txt', 'color', 0xFFFFFF)

        setProperty(group .. 'UiBG.x', grpProps[2] + 120)
        setProperty(group .. 'UiBG.y', grpProps[3] + 24)

        if (uiTab.curHovered[1] == group and uiTab.curHovered[2] == name) then
            setBoxProperty(name, 'bg', 'color', 0x888888)
            setBoxProperty(name, 'bg', 'alpha', 0.8)
            setBoxProperty(name, 'txt', 'color', 0x000000)
        end

        if (getGroupCurSelected(group) == name) then
            setBoxProperty(name, 'bg', 'color', 0xFFFFFF)
            setBoxProperty(name, 'bg', 'alpha', 1)
            setBoxProperty(name, 'txt', 'color', 0x000000)
        end
    end

    for _, data in ipairs(uiTab.attachedSprites) do
        local grp, spr, offsetX, offsetY = data[1], data[2], data[3], data[4]
        setProperty(spr .. '.x', getProperty(grp .. 'UiBG.x') + offsetX)
        setProperty(spr .. '.y', getProperty(grp .. 'UiBG.y') + offsetY)
    end

    for _, grp in ipairs(uiTab.groups) do
        for _, statData in ipairs(uiTab.stats) do
            if statData[4] and statData[5] == getGroupCurSelected(grp[1]) and statData[6] == grp[1] then
                setTextString(statData[1], statData[2]:format(statData[3]()))
            end
        end
    end
end

return uiTab