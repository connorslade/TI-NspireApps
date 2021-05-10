-- Life (Conways Game Of Life)
-- By Connor Slade

-- Some Config Options
local version  = '2.1'
local timerPeroid = 0.1
local cellSize = 26
local gridSize = {12, 8}
local offset = {3, 2}

-- Dont Mess with this
local loaded = false
local cells = {}
local startCells = {}
local mouseDown = false
local mouseToggleType = false
local lastCell = {-1, -1}
local timerRunning = false
local gen = 0

-- Draw Cell Grid
function drawGrid(gc)
    for i in pairs(cells) do
        for j in pairs(cells[i]) do
            local value = cells[i][j]
            local x = j*cellSize-cellSize+offset[1]
            local y = i*cellSize-cellSize+offset[2]
            if value then
                gc:setColorRGB(255, 255, 255)
                gc:fillRect(x, y, cellSize, cellSize)
            end
            gc:setColorRGB(150, 150, 150)
            gc:drawRect(x, y, cellSize, cellSize)
            gc:setColorRGB(200, 200, 200)
            gc:drawString(gen, 35, 4)
            trTextAlign(gc, "Connor S")
        end
    end
    if timerRunning then
        gc:setColorRGB(0, 240, 45) 
        gc:fillPolygon({8, 5, 25, 15, 8, 25})
    else
        gc:setColorRGB(240, 0, 0)
        gc:fillRect(8, 5, 5, 20)
        gc:fillRect(16, 5, 5, 20)
    end
end

-- Simulate Each cell of the grid
function simulateGrid()
    if gen == 0 then startCells = cells end
    local newCells = genBlankCells(gridSize[1], gridSize[2])
    
    for y = 0, gridSize[2] - 1 do
        for x = 0, gridSize[1] - 1 do
            neighbors = 0
            for y1 = y - 1, y + 1 do
                for x1 = x - 1, x + 1 do
                    if (not (x1==x and y1==y) and x1 >= 0 and x1 < gridSize[1] and y1 >= 0 and y1 < gridSize[2]) then
                        if cells[y1+1][x1+1] then
                            neighbors = neighbors + 1
                        end
                    end
                end
            end
            
            newCells[y+1][x+1] = false
            if cells[y+1][x+1] then 
                if neighbors == 2 or neighbors == 3 then
                    newCells[y+1][x+1] = true
                end
            else
                if neighbors == 3 then
                    newCells[y+1][x+1] = true
                end
            end
        end
    end
    cells = newCells
    gen = gen + 1
    platform.window:invalidate()
end

-- Toggle state of a cell based off of pixel on the screen
function toggleCellByPx(mx, my, value)
    if my <= #cells and my > 0 and mx <= #cells[1] and mx > 0 then
        if value == nil then
            cells[my][mx] = not cells[my][mx]
        else
            cells[my][mx] = value 
        end
        platform.window:invalidate()
        return cells[my][mx]
    end
    return false
end

-- Fill the cel array with DEATH
function genBlankCells(x, y)
    local working = {}
    for i = 1,y do
        working[i] = {}
        for j = 1,x do
            working[i][j] = false
        end
    end
    return working
end

-- Align And show text at Top Right of screen
function trTextAlign(gc, str, padding, paddingY)
    padding = padding or 5
    paddingY = paddingY or 3
    local x = platform.window:width() - gc:getStringWidth(str) - padding
    local y = 0 + paddingY
    gc:drawString(str, x, y)
end

-- Randomize cell Life
function randomizeCellState()
    startCells = cells
    for i in pairs(cells) do
        for j in pairs(cells[i]) do
            cells[i][j] = math.random() > 0.5
        end
    end
    platform.window:invalidate()
end

-- Invert Cell State
function invertCells()
    startCells = cells
    for i in pairs(cells) do
        for j in pairs(cells[i]) do
            cells[i][j] = not cells[i][j]
        end
    end
    platform.window:invalidate()   
end

-- Load Preset Data - {{x, y}, {x, y}...}
function loadPreset(presetData)
    local working = genBlankCells(gridSize[1], gridSize[2])
    for i in ipairs(presetData) do
        local data = presetData[i]
        working[data[2]][data[1]] = true
    end
    cells = working
    platform.window:invalidate()
end

-- Increment / Decrement value with a max and min value
function safeCng(value, inc, min, max)
    local working = value
    value = value + inc
    if value >= max then return max end
    if value <= min then return min end
    return value
end

-- Change World size by Inc (x and y)
function changeWorldSize(inc) -- 156, 104
    startCells = cells
    gridSize[1] = safeCng(gridSize[1], inc, 104, 156)
    gridSize[2] = safeCng(gridSize[2], inc, 104, 156)
    cells = genBlankCells(gridSize[1], gridSize[2])
    platform.window:invalidate()
end

function changeCellSize(inc)
    cellSize = safeCng(cellSize, inc, 2, 206)
    platform.window:invalidate()
end

-- Run once on program start
function on.activate()
    platform.window:setBackgroundColor(0x0000000)
    if not loaded then
        cells = genBlankCells(gridSize[1], gridSize[2])
        loaded = true
    end
    menu = {
        {"State",
            {"Step [SPACE]", simulateGrid},
            {"Toggle [ENTER]", on.enterKey}
        },
        {"Cells",
            {"Clear [ESC]", on.escapeKey},
            {"Reset [DEL]", on.backspaceKey},
            "-",
            {"Random [R]", randomizeCellState},
            {"Invert [I]", invertCells}
        },
        {"World",
            {"Size + [+]", function() changeWorldSize(1) end},
            {"Size - [-]", function() changeWorldSize(-1) end},
            "-",
            {"Cell Size + [×]", function() changeCellSize(1) end},
            {"Cell Size - [÷]", function() changeCellSize(-1) end}
        },
        {"Preset", 
            {"Glider", function() loadPreset({{1, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}}) end},
            {"LWSS", function() loadPreset({{2, 4}, {5, 4}, {6, 5}, {2, 6}, {6, 6}, {3, 7}, {4, 7}, {5, 7}, {6, 7}}) end},
            "-",
            {"Very long clock", function()loadPreset({{1,4},{2,5},{2,6},{3,3},{3,4},{4,5},{4,6},{4,7},{5,2},{5,3},{5,4},{6,5},{6,6},{6,7},{6,8},{7,1},{7,2},{7,3},{7,4},{8,5},{8,6},{8,7},{9,2},{9,3},{9,4},{10,5},{10,6},{11,3},{11,4},{12,5}})end},
            {"Octagon 2", function() loadPreset({{6, 1}, {7, 1}, {5, 2}, {8, 2}, {4, 3}, {9, 3}, {3, 4}, {10, 4}, {3, 5}, {10, 5}, {4, 6}, {9, 6}, {5, 7}, {8, 7}, {6, 8}, {7, 8}}) end},
            "-",
            {"Still Life", function()loadPreset({{1,2},{2,1},{2,3},{3,1},{3,3},{4,2},{1,6},{1,7},{2,6},{2,7},{8,1},{7,2},{9,2},{8,3},{9,3},{10,4},{10,5},{11,4},{11,6},{12,5},{6,5},{5,6},{7,6},{5,7},{7,7},{6,8}})end},
            {"Boat on griddle", function() loadPreset({{4, 1}, {4, 2}, {2, 2}, {6, 3}, {1, 3}, {3, 6}, {1, 4}, {2, 4}, {3, 4}, {4, 4}, {5, 4}, {6, 4}, {4, 6}, {4, 6}, {2, 7}, {4, 7}, {3, 8}}) end},
        },
        {"Info", 
            {"By - Connor Slade", function()end},
            {"Created - 5/10/2021", function()end},
            {"Version - "..version, function()end}
            
        }
    }
    toolpalette.register(menu)
end

-- On Paint Function
function on.paint(gc)
    drawGrid(gc)
end

-- Simulate Grid on timer Tick
function on.timer()
    simulateGrid()
end

-- On mouse Down
function on.mouseDown(x, y)
    local mx = math.ceil((x - offset[1]) / cellSize) or o
    local my = math.ceil((y - offset[2]) / cellSize) or 0
    cursor.set("pencil")
    mouseDown = true
    mouseToggleType = toggleCellByPx(mx, my)
    lastCell[1] = mx
    lastCell[2] = my
    platform.window:invalidate()
end

-- On mouse up
function on.mouseUp(x, y)
    cursor.set("default")
    mouseDown = false
    platform.window:invalidate()
end

-- Set Cell states whare mouse moved
function on.mouseMove(x, y)
    local mx = math.ceil((x - offset[1]) / cellSize) or o
    local my = math.ceil((y - offset[2]) / cellSize) or 0
    if mouseDown and not (mx == lastCell[1] and my == lastCell[2]) then
        toggleCellByPx(mx, my, mouseToggleType)
        lastCell[1] = mx
        lastCell[2] = my
    end
end

-- Take Keyboard Input
function on.charIn(char)
    if char == " " then
        simulateGrid()
    elseif char == "r" then
        randomizeCellState()
    elseif char == "i" then
        invertCells()
    elseif char == "+" then
        changeWorldSize(1)
    elseif char == "-" then
        changeWorldSize(-1)
    elseif char == "*" then
        changeCellSize(1)
    elseif char == "/" then
        changeCellSize(-1)
    end
end

-- On Enter Key = Toggle Timer
function on.enterKey()
    if timerRunning then
        timer.stop()
    else
        timer.start(timerPeroid)
    end
    timerRunning = not timerRunning
    platform.window:invalidate()
end

-- On Esc = Clear Grid
function on.escapeKey()
    startCells = cells
    cells = genBlankCells(gridSize[1], gridSize[2])
    timer.stop()
    timerRunning = false
    gen = 0
    platform.window:invalidate()
end

-- On Backspace = Rollback Grid to pre simulation
function on.backspaceKey()
    cells = startCells
    timer.stop()
    timerRunning = false
    gen = 0
    platform.window:invalidate()
end
