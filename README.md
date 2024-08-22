# G-UI Module
A Lua module made for Psych Engine (tested in 0.7.3 only)

## What does this module add?
> This module simply only adds nice looking interactive UI to your game for you to show info, etc.
> 
> ### Example:
> ![image](https://github.com/user-attachments/assets/e21cfdd5-3984-46c6-b33b-1b0619757fae)

## Features:
- [X] Mouse-interactive GUI
- [X] Move-able GUI with Mouse drag
- [ ] Multiple Group Support
- [ ] Checkbox
- [ ] Drop-down List
- [ ] Text Input

## How do I add it to my game?
> To actually access the module in-game, you must first put it alongside the other main folders where the <kbd>exe</kbd> is.
> ![image](https://github.com/user-attachments/assets/1b39ed1a-039b-448f-8428-bcdcec5d4b0c)

> First, import the module by using the <kbd>require</kbd> function. With this function, you can access the all module's various functions
> ```lua
> local tab = require 'ui.tab' 
> ```

> [!IMPORTANT]
> To update the GUI elements, make sure to call <kbd>update()</kbd> as shown
> ```lua
> local tab = require 'ui.tab'
>
> function onUpdatePost(elapsed)
>     tab.update()
> end
> ```

> To make a new tab, use the <kbd>makeGroup</kbd> function <br>
> `makeGroup(name:string, x:number, y:number)`
> ```lua
> local tab = require 'ui.tab'
>
> function onCreatePost()
>     tab.makeGroup('test', 100, 100)
> end
>
> function onUpdatePost(elapsed)
>     tab.update()
> end
> ```
> <sup><i><b>*</b> Multiple group is not yet fully supported</i></sup>

> To make a new section for the tab, use <kbd>makeBox</kbd> <br>
> `makeBox(group:string, sectionName:string)`
> ```lua
> local tab = require 'ui.tab'
>
> function onCreatePost()
>     tab.makeGroup('test', 100, 100)
>     tab.makeBox('test', 'Song')
>     tab.makeBox('test', 'Extra')
> end
> 
> function onUpdatePost(elapsed)
>     tab.update()
> end
> ```

> To make one of the section display something, use <kbd>makeStatusText</kbd> <br>
> `makeStatusText(tag:string, displayText:string, valueFunction:function->any, group:string, section:string, x:number, y:number)`
> ```lua
> local tab = require 'ui.tab'
>
> function onCreatePost()
>     tab.makeGroup('test', 100, 100)
>     tab.makeBox('test', 'Song')
>     tab.makeBox('test', 'Extra')
>
>     tab.makeStatusText('songName', 'Song Name: %s', function() return songName end, false, 'debug', 'Song', 10, 10)
>     tab.makeStatusText('curStep', 'Current Step: %s', function() return curStep end, true, 'debug', 'Song', 10, 40)
>     tab.makeStatusText('curBeat', 'Current Beat: %s', function() return curBeat end, true, 'debug', 'Song', 10, 60)
>     tab.makeStatusText('curSect', 'Current Section: %s', function() return curSection end, true, 'debug', 'Song', 10, 80)
> end
>
> function onUpdatePost(elapsed)
>     tab.update()
> end
> ```
