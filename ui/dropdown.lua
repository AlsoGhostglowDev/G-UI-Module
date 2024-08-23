local dropdown = {}
local tab = require 'ui.tab'
local helper = require 'ui.helper'

-- should contain: { .. {dropdownTag, group, section} .. }
dropdown.dropdowns = {}
-- should contain: { .. dropdownTag .. }
dropdown.standalones = {}
-- should contain: { .. {dropdownTag, optionTag, func} .. }
dropdown.options = {}
-- should contain: { .. dropdownTag .. }
dropdown.openDropdowns = {}

local function indexForDropdown(dropdown, tbl)
    if tbl ~= nil then
        if tbl == dropdown.dropdowns then
            for index, data in ipairs(tbl) do
                if data[2] == dropdown then return index end 
            end
        end
        for index, data in ipairs(tbl) do
            if data == dropdown then return index end 
        end
    end
    return -1
end

local function checkIfOpen(tag)
    if dropdown.openDropdowns ~= nil and #dropdown.openDropdowns >= 1 then
        for _, dropTag in ipairs(dropdown.openDropdowns) do
            if dropTag == tag then return true end 
        end
        return false
    end
end

local function getOptionList(tag)
    local ret = {}
    for _, data in ipairs(dropdown.options) do
        if data[1] == tag then
            table.insert(ret, data[2])
        end
    end

    return ret
end

function dropdown.makeDropdown(tag, standalone, display, group, section, x, y, width)
    helper.makeButton(tag, 'Drop', display, function(lmb)
        if standalone then
            if lmb == 'left' then
                if not checkIfOpen(tag) then 
                    table.insert(dropdown.openDropdowns, tag)
                    debugPrint('Opened Standalone dropdown: '.. tag)
                end
            elseif lmb == 'right' then
                if checkIfOpen(tag) then 
                    table.remove(dropdown.openDropdowns, indexForDropdown(tag, dropdown.openDropdowns))
                    debugPrint('Closed Standalone dropdown: '.. tag)
                end
            end
        else
            if lmb == 'left' then
                if checkIfOpen(tag) then 
                    table.remove(dropdown.openDropdowns, indexForDropdown(tag, dropdown.openDropdowns))
                    debugPrint('Closed dropdown: '.. tag)
                else
                    table.insert(dropdown.openDropdowns, tag)
                    debugPrint('Opened dropdown: '.. tag)
                end
            end
        end
    end, x, y, width)

    makeLuaSprite(tag .. 'UiDropIndBG')
    makeGraphic(tag .. 'UiDropIndBG', 24, 24, '808080')
    setObjectCamera(tag .. 'UiDropIndBG', 'other')
    addLuaSprite(tag .. 'UiDropIndBG')
    helper.makeUIText(tag, 'DropInd', '▼', 0, 0)
    setTextBorder(tag ..'UiDropIndTxt', 1.5, 'FFFFFF')
    setProperty(tag ..'UiDropIndTxt.color', 0x000000)

    if not standalone then
        tab.addAttachedSprite(tag .. 'UiDropBG', group, x, y)
    end

    table.insert(standalone and dropdown.standalones or dropdown.dropdowns, standalone and tag or {tag, group, section})
end

function dropdown.addOption(dropTag, option, display, func)
    helper.makeButton(option, 'DropOpt', display, function()
        cancelTween(option ..'UiDropOptFadeTwn')
        setProperty(option ..'UiDropOptBG.alpha', 1)
        doTweenAlpha(option ..'UiDropOptFadeTwn', option .. 'UiDropOptBG', 0.6, 1, 'expoOut')

        if checkIfOpen(dropTag) then
            func()
        end
    end, 0, 0, getProperty(dropTag .. 'UiDropBG.width'))
    setProperty(option ..'UiDropOptBG.alpha', 0.6)

    table.insert(dropdown.options, {dropTag, option, func})
end

function dropdown.update() 
    for i, dropData in ipairs(dropdown.dropdowns) do
        local tag, group, section = dropData[1], dropData[2], dropData[3]
        setProperty(tag ..'UiDropBG.color', 0x000000)
        setProperty(tag ..'UiDropTxt.color', 0xFFFFFF)
        if helper.mouseOverlaps(tag .. 'UiDropBG', 'camOther') then
            setProperty(tag ..'UiDropBG.color', 0x808080)
            setProperty(tag ..'UiDropTxt.color', 0x000000)
        end

        if checkIfOpen(tag) then
            setProperty(tag ..'UiDropBG.color', 0xFFFFFF)
            setProperty(tag ..'UiDropTxt.color', 0x000000)
        end

        setProperty(tag ..'UiDropIndTxt.x', getProperty(tag ..'UiDropBG.x') + 4)
        setProperty(tag ..'UiDropIndTxt.y', getProperty(tag ..'UiDropBG.y'))
        setProperty(tag ..'UiDropIndBG.x', getProperty(tag ..'UiDropBG.x'))
        setProperty(tag ..'UiDropIndBG.y', getProperty(tag ..'UiDropBG.y'))

        setProperty(tag ..'UiDropBG.visible', tab.getGroupCurSelected(group) == section)
        setProperty(tag ..'UiDropTxt.visible', tab.getGroupCurSelected(group) == section)
        setProperty(tag ..'UiDropIndTxt.visible', tab.getGroupCurSelected(group) == section)
        setProperty(tag ..'UiDropIndBG.visible', tab.getGroupCurSelected(group) == section)

        for j, optTag in ipairs(getOptionList(tag)) do
            setProperty(optTag ..'UiDropOptBG.color', 0x888888)
            setProperty(optTag ..'UiDropOptTxt.color', 0xFFFFFF)
            if helper.mouseOverlaps(optTag .. 'UiDropOptBG', 'camOther') then
                setProperty(optTag ..'UiDropOptBG.color', 0xAAAAAA)
                setProperty(optTag ..'UiDropOptTxt.color', 0x000000)
            end

            setProperty(optTag ..'UiDropOptBG.visible', checkIfOpen(tag) and getProperty(tag ..'UiDropBG.visible'))
            setProperty(optTag ..'UiDropOptTxt.visible', getProperty(optTag ..'UiDropOptBG.visible'))

            setProperty(optTag ..'UiDropOptBG.x', getProperty(tag ..'UiDropBG.x'))
            setProperty(optTag ..'UiDropOptBG.y', getProperty(tag ..'UiDropBG.y') + (24 * j))
        end
    end

    for i, tag in ipairs(dropdown.standalones) do
        setProperty(tag ..'UiDropBG.color', 0x000000)
        setProperty(tag ..'UiDropTxt.color', 0xFFFFFF)
        if helper.mouseOverlaps(tag .. 'UiDropBG', 'camOther') then
            setProperty(tag ..'UiDropBG.color', 0x808080)
            setProperty(tag ..'UiDropTxt.color', 0x000000)

            if mousePressed('left') then
                setProperty(tag..'UiDropBG.x', getProperty(tag..'UiDropBG.x') + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaX') * 0.88))
                setProperty(tag..'UiDropBG.y', getProperty(tag..'UiDropBG.y') + (getPropertyFromClass('flixel.FlxG', 'mouse.deltaY') * 0.88))
            end
        end

        setProperty(tag ..'UiDropIndTxt.x', getProperty(tag ..'UiDropBG.x') + 4)
        setProperty(tag ..'UiDropIndTxt.y', getProperty(tag ..'UiDropBG.y'))
        setProperty(tag ..'UiDropIndBG.x', getProperty(tag ..'UiDropBG.x'))
        setProperty(tag ..'UiDropIndBG.y', getProperty(tag ..'UiDropBG.y'))

        if checkIfOpen(tag) then
            setProperty(tag ..'UiDropBG.color', 0xFFFFFF)
            setProperty(tag ..'UiDropTxt.color', 0x000000)
        end

        for j, optTag in ipairs(getOptionList(tag)) do
            setProperty(optTag ..'UiDropOptBG.color', 0x888888)
            setProperty(optTag ..'UiDropOptTxt.color', 0xFFFFFF)
            if helper.mouseOverlaps(optTag .. 'UiDropOptBG', 'camOther') then
                setProperty(optTag ..'UiDropOptBG.color', 0xAAAAAA)
                setProperty(optTag ..'UiDropOptTxt.color', 0x000000)
            end

            setProperty(optTag ..'UiDropOptBG.visible', checkIfOpen(tag) and getProperty(tag ..'UiDropBG.visible'))
            setProperty(optTag ..'UiDropOptTxt.visible', getProperty(optTag ..'UiDropOptBG.visible'))

            setProperty(optTag ..'UiDropOptBG.x', getProperty(tag ..'UiDropBG.x'))
            setProperty(optTag ..'UiDropOptBG.y', getProperty(tag ..'UiDropBG.y') + (24 * j))
        end
    end
end

return dropdown