-- Device Info for TI-nspire
-- By Connor Slade

-- Config
platform.apiLevel = '2.7'
local programVersion = '1.2.3'
local fontSize = 12 -- 6 to 255 Defult 12
local keyColor = {255, 255, 255} -- Key Text Color {r, g, b}
local valueColor = {125, 125, 255} -- Value Text Color {r, g, b}

-- Set Background Color
function setBG(gc, r, g, b)
    gc:setColorRGB(r, g, b) 
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())
    gc:setColorRGB(255, 255, 255)
end

-- Draw Kay Value Pairs
function drawKeyValue(gc, keyValue, x, y)
    local key = keyValue[1]..": "
    local value = keyValue[2] or ""
    local totalString = key or "" .. keyValue[2] or ""
    if gc:getStringWidth(totalString) > getXYdisplaySize(gc, true) then
        value = dotString(gc, totalString, value)
    end
    gc:setColorRGB(keyColor[1], keyColor[2], keyColor[3])
    gc:drawString(key, x, y)
    gc:setColorRGB(valueColor[1], valueColor[2], valueColor[3])
    gc:drawString(value, x + gc:getStringWidth(key), y)
end

-- Draw text in the center of the screen
function drawCenterText(gc, text, y)
    local x = platform.window:width()/2 - gc:getStringWidth(text)/2
    gc:drawString(text, x, y)
end

-- Get meaning of Platform id
function getPlatformFromId(id)
    local platforms = {{3, "TI-Nspire™ handheld"}, {7, "TI-Nspire™ App"}}
    for i in pairs(platforms) do
        if platforms[i][1] == id then return "["..id.."] "..platforms[i][2] end
    end
    return "["..id.."] Unknown... U livn in da future?"
end

-- Get display size in diffrent formats
function getXYdisplaySize(gc, x, y)
    local w = platform.window:width()
    local h = platform.window:height()

    if x and y then return w .. ", " .. h end
    if x then return w end
    if y then return h end
end

-- Shorten and add a '...' to a string if its too big to fit on screen
function dotString(gc, string, real)
    local working = string
    for i = 1,#working do
        working = working:sub(1, #working - 1)
        real = real:sub(1, #real - 1)
        if gc:getStringWidth(working) < platform.window:width() - gc:getStringWidth(" ...") then
            return real.."..."
        end
    end
    return "Fail"
end

-- Capitalize the first char of a string
function capString(str)
    local working = tostring(str):lower()
    local first = working:sub(1, 1):upper()
    working = first..working:sub(2)
    return working
end

-- On Paint Function
function on.paint(gc)
    -- Define the items to be put on display
    local items = {
        {"Local", locale.name()},
        {"APILevel", platform.apiLevel},
        {"Platform", getPlatformFromId(platform.hw())},
        {"IsColor", capString(platform.isColorDisplay())},
        {"DisplaySize", getXYdisplaySize(gc, true, true)},
        {"DevID", platform.getDeviceID() or "None - Emulated?"},
        {"ClipBoard", clipboard.getText()},
        {"DeviceInfo", programVersion}
    }

    -- Draw Title
    setBG(gc, 0, 0, 0)
    cursor.hide()
    gc:setFont("sansserif", "b", 12)
    drawCenterText(gc, "▶ Device Info ◀", 0)
    
    gc:setFont("sansserif", "r", 9)
    drawCenterText(gc, "Connor Slade", 18)
    
    -- Draw Info
    gc:setFont("sansserif", "r", fontSize)
    for i in pairs(items) do
        drawKeyValue(gc, {items[i][1], items[i][2]}, 5, i*fontSize*1.7+20)
    end
end

-- Define Events
function on.enterKey()
    platform.window:invalidate()
end
