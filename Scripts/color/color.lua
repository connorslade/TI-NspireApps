-- COLOR for TI-Nspire
-- By Connor Slade

local size = {212, 212}
local per = 1

local x = 0
local y = 0
local ss = { "Z", "Y", "X" }
local xs = 1
local ys = 2
local zs = 3

-- Set Background Color
function setBG(gc, r, g, b)
    gc:setColorRGB(r, g, b) 
    gc:fillRect(0, 0, 318, 212)
end

-- Re Draw X / Y text
function reDrawText(gc, x, y, pre)
    gc:setColorRGB(30, 30, 30) 
    gc:fillRect(213, 0, 105, 212)
    gc:setColorRGB(255, 255, 255) 
    gc:drawString("R = " .. x, 225, 0)
    gc:drawString("G = " .. y, 225, 30)
    gc:drawString("B = " .. pre, 225, 60)
    gc:drawString("Per = " .. per, 225, 90)
    gc:drawString("COLOR! V2.2", 220, 165)
    gc:drawString("By: Connor S", 220, 190)
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
function defineXY(xyz, x, y, z)
    local lowerStr = xyz:lower()
    if lowerStr == "x" then return x end
    if lowerStr == "y" then return y end
    if lowerStr == "z" then return z end
    return 255
end

-- Draw Color!
function reDrawColor(gc, xs, ys, zs)
    for i = 0,size[1]/per do
        for j = 0,size[2]/per do
            local ni = i*per
            local nj = j*per
            gc:setColorRGB(defineXY(xs, ni, nj, 255), defineXY(ys, ni, nj, 255), defineXY(zs, ni, nj, 255)) 
            gc:fillRect(ni, nj, per, per)
        end
    end
end

-- On Paint Function
function on.paint(gc)
    setBG(gc, 0, 0, 0)
    reDrawColor(gc, ss[xs], ss[ys], ss[zs])
    reDrawText(gc, ss[xs], ss[ys], ss[zs])

end


function on.charIn(char)
    if char == "+" then per = safeInc(per, 213) end
    if char == "-" then per = safeDec(per, 1) end
    
    if char == "1" then xs = safeDec(xs, 1) end
    if char == "4" then xs = 1 end
    if char == "7" then xs = safeInc(xs, 3) end
    
    if char == "2" then ys = safeDec(ys, 1) end
    if char == "5" then ys = 2 end
    if char == "8" then ys = safeInc(ys, 3) end
    
    if char == "3" then zs = safeDec(zs, 1) end
    if char == "6" then zs = 3 end
    if char == "9" then zs = safeInc(zs, 3) end
    platform.window:invalidate()
end
