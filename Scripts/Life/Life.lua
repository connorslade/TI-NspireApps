-- Life (Conways Game Of Life)
-- By Connor Slade

-- Some Config Options
local timerPeroid = 0.1
local cellSize = 26
local gridSize = {12, 8}
local offset = {3, 2}

-- Dont Mess with this
local cells = {}
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

function trTextAlign(gc, str, padding, paddingY)
    padding = padding or 5
    paddingY = paddingY or 3
    local x = platform.window:width() - gc:getStringWidth(str) - padding
    local y = 0 + paddingY
    gc:drawString(str, x, y)
end

function randomizeCellState()
    for i in pairs(cells) do
        for j in pairs(cells[i]) do
            cells[i][j] = math.random() > 0.5
        end
    end
    platform.window:invalidate()
end

function loadPreset(presetData)
    local working = genBlankCells(gridSize[1], gridSize[2])
    for i in ipairs(presetData) do
        local data = presetData[i]
        working[data[2]][data[1]] = true
    end
    cells = working
    platform.window:invalidate()
end

-- Run once on program start
function on.activate()
    platform.window:setBackgroundColor(0x0000000)
    cells = genBlankCells(gridSize[1], gridSize[2])
    menu = {
        {"State", 
            {"Step", simulateGrid},
            {"Toggle", on.enterKey}
        },
        {"Cells",
            {"Reset", on.backspaceKey},
            {"Random", randomizeCellState}
        },
        {"Preset", 
            {"Glider", function() loadPreset({{1, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}}) end},
            {"LWSS", function() loadPreset({{2, 4}, {5, 4}, {6, 5}, {2, 6}, {6, 6}, {3, 7}, {4, 7}, {5, 7}, {6, 7}}) end},
            "-",
            {"Very long clock", function()loadPreset({{1,4},{2,5},{2,6},{3,3},{3,4},{4,5},{4,6},{4,7},{5,2},{5,3},{5,4},{6,5},{6,6},{6,7},{6,8},{7,1},{7,2},{7,3},{7,4},{8,5},{8,6},{8,7},{9,2},{9,3},{9,4},{10,5},{10,6},{11,3},{11,4},{12,5}})end},
            "-",
            {"Boat on griddle", function() loadPreset({{4, 1}, {4, 2}, {2, 2}, {6, 3}, {1, 3}, {3, 6}, {1, 4}, {2, 4}, {3, 4}, {4, 4}, {5, 4}, {6, 4}, {4, 6}, {4, 6}, {2, 7}, {4, 7}, {3, 8}}) end},
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

-- On Backspace = Clear Grid
function on.backspaceKey()
    cells = genBlankCells(gridSize[1], gridSize[2])
    timer.stop()
    timerRunning = false
    gen = 0
    platform.window:invalidate()
end
