local uiTab = {}
local helper = require 'ui.helper'

-- should contain: { .. {groupName, x, y, curSelected, width} .. }
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

local function setupBox(group, boxName) 
    if uiTab.groupExists(group) and boxName ~= '' and boxName ~= nil then
        local grpProp = uiTab.getGroupProperties(group)
        local grpLength = #(uiTab.getGroupMembers(group) or {})
        makeLuaSprite(boxName ..'UiBG', nil, grpProp[2] + (grpLength * 120), grpProp[3])
        makeGraphic(boxName ..'UiBG', (grpProp[5] / (grpLength+1)), 24, 'FFFFFF')
        setObjectCamera(boxName ..'UiBG', 'other')
        addLuaSprite(boxName ..'UiBG')

        makeLuaText(boxName ..'UiText', boxName, (grpProp[5] / (grpLength+1)), 0, 0)
        setTextSize(boxName ..'UiText', 20)
        setTextBorder(boxName ..'UiText', 0)
        setObjectCamera(boxName ..'UiText', 'other')
        addLuaText(boxName ..'UiText')

        for _, boxData in ipairs(uiTab.boxes) do
            if boxData[1] == group then
                makeGraphic(boxData[2] ..'UiBG', (grpProp[5] / (grpLength+1)), 24, 'FFFFFF')
            end
        end

        makeGraphic(group .. 'UiBG', grpProp[5], ((grpLength + 1) * 60) * 1.25, '000000')
        table.insert(uiTab.boxes, {group, boxName})

        for _, statData in ipairs(uiTab.stats) do
            if statData[6] == group then
                setProperty(statData[1] ..'.fieldWidth', getProperty(group .. 'UiBG.width') - (uiTab.getFromAttachedSprite(statData[1])[3]))
            end
        end

        return boxName
    else
        debugPrint('ERROR (uiTab): '.. scriptName ..': Cannot setup box: "'.. boxName ..'"!, [EXCEPTION: Group "'.. group ..'" doesn\'t exist!]', 'red')
    end
    debugPrint('CRITICAL ERROR (ui.tab): Uncomplete Operation on setupBox', 'red')
    return nil
end

---------------- HELPER FUNCTIONS -------------------

function uiTab.getFromAttachedSprite(spr)
    for _, sprData in ipairs(uiTab.attachedSprites) do
        if sprData[2] == spr then
            return sprData
        end
    end
end

function uiTab.indexOfGroup(grp)
    for index, v in ipairs(uiTab.groups) do
        if v[1] == grp then return index end
    end
    return -1
end

function uiTab.getGroupCurSelected(grp)
    return uiTab.groups[uiTab.indexOfGroup(grp)][4]
end

function uiTab.setGroupCurSelected(grp, val)
    uiTab.groups[uiTab.indexOfGroup(grp)][4] = val
end

------------------ MODULE FUNCTIONS ------------------ 

function uiTab.makeBox(group, boxName)
    setupBox(group, boxName)
end

function uiTab.makeGroup(groupName, x, y, width)
    if not uiTab.groupExists(groupName) then
        table.insert(uiTab.groups, {groupName, x - 120, y, nil, (width or 120)})
        makeLuaSprite(groupName .. 'UiBG', x, 24)
        makeGraphic(groupName .. 'UiBG', 1, 1, '000000')
        setProperty(groupName .. 'UiBG.alpha', 0.6)
        setObjectCamera(groupName .. 'UiBG', 'other')
        addLuaSprite(groupName .. 'UiBG')

        scaleObject(groupName .. 'UiBG', 0, 0)
        return
    end
    debugPrint('ERROR (uiTab): '.. scriptName ..': Cannot make group: "'.. groupName ..'"!, [EXCEPTION: Group "'.. groupName ..'" already exists, cannot override!]', 'red')
end

function uiTab.addAttachedSprite(tag, group, offsetX, offsetY)
    if uiTab.groupExists(group) then
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

function uiTab.groupExists(grp)
    for _, n in ipairs(uiTab.getGroupNames()) do
        if n == grp then
            return true
        end
    end
    return false
end

-- returns {grpName, x, y}
function uiTab.getGroupProperties(grp)
    if uiTab.groupExists(grp) then
        local ret = {}
        for i, d in ipairs(uiTab.groups) do
            if grp == d[1] then
                ret = d
            end
        end
        return ret
    end
    debugPrint('ERROR (uiTab): '.. scriptName ..': Cannot get group '.. grp ..'\'s property! [EXCEPTION: Group "'.. grp ..'" doesn\'t exist; did you add it first?]', 'red')
    return nil
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
    if uiTab.groupExists(group) then
        tag = 'STAT_'..tag
        makeLuaText(tag, text:format(func()), getProperty(group .. 'UiBG.width') - (x or 0))
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
                setProperty(statData[1]..'.visible', statData[5] == uiTab.getGroupCurSelected(grp[1]))
            end
        end
    end
end

function uiTab.update()
    uiTab.curHovered = {nil, nil}
    helper.update()
    for i, boxData in ipairs(uiTab.boxes) do
        local group, name = boxData[1], boxData[2]
        local grpProps = uiTab.getGroupProperties(group)

        if helper.mouseOverlaps(name .. 'UiBG', 'camOther') and getProperty(name ..'UiBG.visible') then
            uiTab.curHovered = {group, name}
            callMethod('callOnLuas', {'onBoxHover', {name, group}})
            if mouseClicked('left') then
                uiTab.setGroupCurSelected(group, name)
                callMethod('callOnLuas', {'onBoxClick', {name, group}})

                scaleObject(group .. 'UiBG', 1, 1)
                for _, statData in ipairs(uiTab.stats) do
                    if statData[6] == group and statData[5] == name then
                        if statData[4] then setTextString(statData[1], statData[2]:format(statData[3]())) end
                        if getProperty(statData[1] .. '.height') + (uiTab.getFromAttachedSprite(statData[1])[3] + 5) > getProperty(group .. 'UiBG.height') then
                            setGraphicSize(group .. 'UiBG', getProperty(group ..'UiBG.width'), getProperty(statData[1] .. '.height') + uiTab.getFromAttachedSprite(statData[1])[3] + 5)
                        end
                    end
                end
            elseif mouseClicked('right') then
                uiTab.setGroupCurSelected(group, nil)
                callMethod('callOnLuas', {'onBoxClickRight', {name, group}})

                scaleObject(group .. 'UiBG', 0, 0)
            elseif mousePressed('left') then
                for _, v in ipairs(uiTab.groups) do
                    if v[1] == group then
                        v[2] = v[2] + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaX') * 0.88)
                        v[3] = v[3] + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaY') * 0.88)
                    end
                end
            end

            uiTab.reloadObjs()
        end

        local grpLength = #uiTab.getGroupMembers(group)
        uiTab.forEachMembers(group, function(i, bn)
            helper.setBoxProperty(bn, 'bg', 'x', grpProps[2] + ((grpProps[5] / grpLength) * i))
            helper.setBoxProperty(bn, 'bg', 'y', grpProps[3])
            helper.setBoxProperty(bn, 'txt', 'x', helper.getBoxProperty(bn, 'bg', 'x') + ((helper.getBoxProperty(bn, 'bg', 'width') - helper.getBoxProperty(bn, 'text', 'width')) / 2))
            helper.setBoxProperty(bn, 'txt', 'y', grpProps[3])
        end)

        helper.setBoxProperty(name, 'bg', 'color', 0x000000)
        helper.setBoxProperty(name, 'bg', 'alpha', 0.85)
        helper.setBoxProperty(name, 'txt', 'color', 0xFFFFFF)

        setProperty(group .. 'UiBG.x', grpProps[2] + (grpProps[5] / grpLength))
        setProperty(group .. 'UiBG.y', grpProps[3] + 24)

        if (uiTab.curHovered[1] == group and uiTab.curHovered[2] == name) then
            helper.setBoxProperty(name, 'bg', 'color', 0x888888)
            helper.setBoxProperty(name, 'bg', 'alpha', 0.8)
            helper.setBoxProperty(name, 'txt', 'color', 0x000000)
        end

        if (uiTab.getGroupCurSelected(group) == name) then
            helper.setBoxProperty(name, 'bg', 'color', 0xFFFFFF)
            helper.setBoxProperty(name, 'bg', 'alpha', 1)
            helper.setBoxProperty(name, 'txt', 'color', 0x000000)
        end
    end

    for _, sprData in ipairs(uiTab.attachedSprites) do
        local grp, spr, offsetX, offsetY = sprData[1], sprData[2], sprData[3], sprData[4]
        setProperty(spr .. '.x', getProperty(grp .. 'UiBG.x') + offsetX)
        setProperty(spr .. '.y', getProperty(grp .. 'UiBG.y') + offsetY)
    end

    for _, grp in ipairs(uiTab.groups) do
        for _, statData in ipairs(uiTab.stats) do
            if statData[4] and statData[5] == uiTab.getGroupCurSelected(grp[1]) and statData[6] == grp[1] then
                setTextString(statData[1], statData[2]:format(statData[3]()))
            end
        end
    end
end

return uiTab