-- Morse Code - 5/15/2021
-- By Connor Slade

-- Some Config Options
local version = "1.0.0"
local text = "Hello World :P"
local speed = 0.3
local presets = {"SOS", "Nose", "Hello World"}
local morseCode = {
    ["A"] = ".-",
    ["B"] = "-...",
    ["C"] = "-.-.",
    ["D"] = "-..",
    ["E"] = ".",
    ["F"] = "..-",
    ["G"] = "--.",
    ["H"] = "....",
    ["I"] = "..",
    ["J"] = ".---",
    ["K"] = "-.-",
    ["L"] = ".-.",
    ["M"] = "--",
    ["N"] = "-.",
    ["O"] = "---",
    ["P"] = ".--.",
    ["Q"] = "--.-",
    ["R"] = ".-",
    ["S"] = "...",
    ["T"] = "-",
    ["U"] = "..-",
    ["V"] = "...-",
    ["W"] = ".--",
    ["X"] = "-..",
    ["Y"] = "-.--",
    ["Z"] = "--.",
    ["0"] = "-----",
    ["1"] = ".----",
    ["2"] = "..---",
    ["3"] = "...--",
    ["4"] = "....-",
    ["5"] = "....",
    ["6"] = "-....",
    ["7"] = "--...",
    ["8"] = "---..",
    ["9"] = "----",
    ["."] = ".-.-.-",
    [","] = "--..--",
    ["?"] = "..--..",
    ["'"] = ".----.",
    ["!"] = "-.-.--",
    ["/"] = "-..-",
    ["("] = "-.--.",
    [")"] = "-.--.-",
    ["&"] = ".-...",
    [":"] = "---...",
    [";"] = "-.-.-.",
    ["="] = "-...",
    ["+"] = ".-.-.",
    ["-"] = "-....-",
    ["_"] = "..--.-",
    ['"'] = ".-..-.",
    ["$"] = "...-..-",
    ["@"] = ".--.-",
    ["¿"] = "..-.-",
    ["¡"] = "--..."
}

-- Dont Change This
local time = 1
local timeWait = 1
local textIndex = 1
local charIndex = 1
local toFlash = {}
local nextChar = false
local running = false
local windowSize = {
    platform.window:width(),
    platform.window:height()
}

--- Convert a String to a Table
---@param str string
function stringToArray(str)
    local t = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        table.insert(t, char)
    end
    return t
end

--- Safly Change value with min and max
---@param value number
---@param inc number
---@param min number
---@param max number
function safeCng(value, inc, min, max)
    value = value + inc
    if value >= max then
        return max
    end
    if value <= min then
        return min
    end
    return value
end

--- Does... Nothing!
function nullFunc()
end

--- Align text to Left, Right, Top or bottom (Or all)
---@param gc any
---@param text string
---@param l boolean
---@param r boolean
---@param t boolean
---@param b boolean
---@param padding tabel
function alignText(gc, text, l, r, t, b, padding)
    local xy = {0, 0}
    padding = padding or {0, 0}
    if r then xy[1] = windowSize[1] - gc:getStringWidth(text) end
    if l and r then xy[1] = windowSize[1]/2 - gc:getStringWidth(text)/2 end
    if b then xy[2] = windowSize[2] - gc:getStringHeight(text) end
    if t and b then xy[2] = windowSize[2]/2 - gc:getStringHeight(text)/2 end
    gc:drawString(text, xy[1] + padding[1], xy[2] + padding[2])
end

--- Add a ... to a string if its too long
---@param gc any
---@param string string
---@param real string
function dotString(gc, string, real)
    if gc:getStringWidth(string) <= windowSize[1] - gc:getStringWidth("..."..real) then
        return string
    end
    for i = 1,#string do
        string = string:sub(1, #string - 1)
        if gc:getStringWidth(string) < windowSize[1] - gc:getStringWidth("..."..real) then
            return string.."..."
        end
    end
    return ""
end

--- Round a Number
---@param num number
---@param dps number
function round(num, dps)
  local mult = 10^(dps or 0)
  return math.floor(num * mult + 0.5) / mult
end



--- Toggle if morse code is being shown
---@param value boolean
function toggleRunning(value)
    if value == nil then
        value = not running
    end
    if value then
        timer.start(speed)
        running = true
        return
    end
    platform.window:setBackgroundColor(0x0000000)
    timer.stop(speed)
    time = 1
    timeWait = 1
    textIndex = 1
    charIndex = 1
    nextChar = false
    running = false
end

--- Change Timer Speed
---@param inc number
function changeSpeed(inc)
    speed = safeCng(speed, inc, 0.1, 1)
    timer.start(speed)
    menu[2][2][1] = "Speed = " .. tostring(speed)
    toolpalette.register(menu)
end

--- Loads a preset
---@param preset string
function loadPreset(preset)
    text = preset
    toFlash = stringToArray(preset)
    platform.window:invalidate()
end

function on.activate()
    platform.window:setBackgroundColor(0x0000000)
    toFlash = stringToArray(text)
    
    menu = {
        {"State",
            {"Start", function() toggleRunning(true) end},
            {"Stop", function() toggleRunning(false) end},
            {"Tick", simTick}
        },
        {"Speed",
            {"Speed = " .. tostring(speed), nullFunc},
            {"+", function() changeSpeed(0.1) end},
            {"-", function() changeSpeed(-0.1) end}
        },
        {"Presets"
        },
        {"Info",
            {"By: Connor Slade", nullFunc},
            {"Created: 5/15/2021", nullFunc},
            {"Version: "..version, nullFunc}
        }
    }
    
    for i in ipairs(presets) do
        menu[3][i + 1] = {presets[i], function() loadPreset(presets[i]) end}
    end

    toolpalette.register(menu)
end

function on.paint(gc)
    if not running then
        gc:setColorRGB(240, 0, 0)
        gc:fillRect(8, 5, 5, 20)
        gc:fillRect(16, 5, 5, 20)
        gc:setColorRGB(0xffffff)
        gc:setFont("sansserif", "r", 9)
        local speed = tostring(round(speed / 0.3, 1)) .. "x "
        alignText(gc, dotString(gc, " Text: " .. text, speed), true, false, false, true)
        alignText(gc, "Connor S", false, true, true, false)
        gc:setColorRGB(26, 150, 255)
        alignText(gc, speed, false, true, false, true)
        return
    end
    gc:setColorRGB(0, 240, 45)
    gc:fillPolygon({8, 5, 25, 15, 8, 25})
end

--- Simulate One tick
function simTick()
    time = time + 1

    if timeWait > time - 1 then return end

    if textIndex > #toFlash then
        platform.window:setBackgroundColor(0x000000)
        toggleRunning(false)
        platform.window:invalidate()
        return
    end

    local textChar = string.upper(toFlash[textIndex])
    local color = 0xffffff

    if nextChar then
        platform.window:setBackgroundColor(0x000000)
        timeWait = time
        nextChar = false
        platform.window:invalidate()
        return
    end

    if textChar == " " then
        timeWait = time + 6
        textIndex = textIndex + 1
        return
    end
    
    local currentChar = stringToArray(morseCode[textChar])[charIndex]
    charIndex = charIndex + 1
    nextChar = true

    if currentChar == "-" then timeWait = time + 2
    elseif currentChar == "." then timeWait = time
    elseif currentChar == nil then
        timeWait = time
        color = 0x000000
    end

    if charIndex > #morseCode[string.upper(toFlash[textIndex])] then
        charIndex = 0
        textIndex = textIndex + 1
    end

    platform.window:setBackgroundColor(color)
    platform.window:invalidate()
end

function on.timer()
    if running then simTick() end
end

function on.resize(width, height)
    windowSize = {width, height}
end

function on.charIn(char)
    text = text..char
    toFlash = stringToArray(text)
    platform.window:invalidate()
end

function on.backspaceKey()
    text = text:sub(1, #text-1)
    toFlash = stringToArray(text)
    platform.window:invalidate()
end

-- Keybord Shortcuts

function on.enterKey()
    toggleRunning()
end

function on.arrowUp()
    changeSpeed(0.1)
end

function on.arrowDown()
    changeSpeed(-0.1)
end