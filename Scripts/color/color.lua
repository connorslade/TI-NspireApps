-- COLOR for TI-Nspire
-- By Connor Slade

local precision = 5

local x = 0
local y = 0
local ss = { "Red", "Green", "Blue" }
local xs = 1
local ys = 2

-- Set Background Color
function setBG(gc, r, g, b)
    gc:setColorRGB(r, g, b) 
    gc:fillRect(0, 0, 318, 212)
end

-- Re Draw X / Y text
function reDrawText(gc, x, y, pre)
    gc:setColorRGB(255, 255, 255) 
    gc:drawString("X = " .. x, 225, 0)
    gc:drawString("Y = " .. y, 225, 30)
    gc:drawString("P = " .. pre, 225, 60)
    gc:drawString("COLOR! V1.2", 215, 165)
    gc:drawString("By: Connor S", 215, 190)
end

-- Increment value with a max value
function safeInc(value, max, inc)
    inc = inc or 1
    local working = value
    value = value + 1
    if value >= max then return max end
    return value
end

-- Decrement int with a min value
function safeDec(value, min, dec)
    dec = dec or 1
    local working = value
    value = value - dec
    if value <= min then return min end
    return value
end


-- Define X / Y from string
function defineXY(xy, r, g, b)
    local lowerStr = xy:lower()
    if lowerStr == "red" then return r end
    if lowerStr == "green" then return g end
    if lowerStr == "blue" then return b end
end

-- Draw Color!
function reDrawColor(gc, pre, xs, ys)
    local ita = 255 / pre
    for r = 0,ita do
        for g = 0,ita do
            for b = 0,ita do
                x = defineXY(xs, r, g, b)
                y = defineXY(ys, r, g, b)
                gc:setColorRGB(r*pre, g*pre, b*pre) 
                gc:fillRect(x*4+2,y*4+2, 4, 4)
            end
        end
    end
end

-- On Paint Function
function on.paint(gc)
    setBG(gc, 0, 0, 0)
    reDrawColor(gc, precision, ss[xs], ss[ys])
    reDrawText(gc, ss[xs], ss[ys], precision)

end

-- Key Routines
function on.arrowDown()
    xs = safeDec(xs, 1)
    platform.window:invalidate()
end

function on.arrowUp()
    xs = safeInc(xs, 3)
    platform.window:invalidate()
end

function on.arrowLeft()
    ys = safeDec(ys, 1)
    platform.window:invalidate()
end

function on.arrowRight()
    ys = safeInc(ys, 3)
    platform.window:invalidate()
end

function on.charIn(char)
    if char == "+" then precision = safeInc(precision, 120) end
    if char == "-" then precision = safeDec(precision, 5) end
    platform.window:invalidate()
end