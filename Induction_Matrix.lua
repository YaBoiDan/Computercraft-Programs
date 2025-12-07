-- Heavily inspired by some code from existing Extreme reactors script - https://pastebin.com/raw/b17hfTqe

local updateInterval = 5 -- seconds between updates

local function resetMon()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setTextScale(0.5)
    mon.setCursorPos(1,1)
end

local function initMon()
    mon = peripheral.find("monitor")

    if mon == nil then
        print("No monitor found")
        exit()
    end

    resetMon()
end

local function drawText(text, x1, y1, backColor, textColor)
    if (mon == nil) then
        return
    end
    local x, y = mon.getCursorPos()
    mon.setCursorPos(x1, y1)
    mon.setBackgroundColor(backColor)
    mon.setTextColor(textColor)
    mon.write(text)
    mon.setTextColor(colors.white)
    mon.setBackgroundColor(colors.black)
    mon.setCursorPos(x,y)
end

local function format(num)
    if (num >= 1000000000) then
        return string.format("%.2f G", num / 1000000000)
    elseif (num >= 1000000) then
        return string.format("%.2f M", num / 1000000)
    elseif (num >= 1000) then
        return string.format("%.2f K", num / 1000)
    elseif (num >= 1) then
        return string.format("%.2f ", num)
    elseif (num >= .001) then
        return string.format("%.2f m", num * 1000)
    elseif (num >= .000001) then
        return string.format("%.2f u", num * 1000000)
    else
        return string.format("%.2f ", 0)
    end
end

-- Draw a box with no fill
local function drawBox(size, xoff, yoff, color)
    if (mon == nil) then
        return
    end
    local x,y = mon.getCursorPos()
    mon.setBackgroundColor(color)
    local horizLine = string.rep(" ", size[1])
    mon.setCursorPos(xoff + 1, yoff + 1)
    mon.write(horizLine)
    mon.setCursorPos(xoff + 1, yoff + size[2])
    mon.write(horizLine)

    -- Draw vertical lines
    for i=0, size[2] - 1 do
        mon.setCursorPos(xoff + 1, yoff + i + 1)
        mon.write(" ")
        mon.setCursorPos(xoff + size[1], yoff + i +1)
        mon.write(" ")
    end
    mon.setCursorPos(x,y)
    mon.setBackgroundColor(colors.black)
end

-- Main starts here
induction = peripheral.find("inductionPort")
term.clear()
term.setCursorPos(1,1)
initMon() -- Monitor Setup

-- check if induction matrix is formed
if not induction.isFormed() then
    print("Induction port is not formed into a multiblock structure.")
    return
end

while true do
    -- Get Providers and Installed Cells
    local providers = induction.getInstalledProviders()
    local cells = induction.getInstalledCells()

    -- get stored energy
    local energyStored = induction.getEnergy()
    local maxEnergyStored = induction.getMaxEnergy()
    local energyPercentage = induction.getEnergyFilledPercentage() 
    print("Energy Stored: " .. format(energyStored) .. "RF" .. " / " .. format(maxEnergyStored) .. "RF")
    print("Energy Filled Percentage: " .. string.format("%.2f", energyPercentage * 100) .. "%")

    -- get input/output rates
    local energyInputRate = induction.getLastInput()
    local energyOutputRate = induction.getLastOutput()

    -- Display on Monitor
    if (mon) then
        -- General
        mon.clear()
        -- Center title
        local title = "Induction Matrix Status"
        local titleX = math.floor((mon.getSize() - string.len(title)) / 2)
        drawText(title, titleX, 1, colors.black, colors.white)
        drawText(string.rep("-", string.len(title)), titleX, 2, colors.black, colors.white) 

        -- Display energy information
        --drawBox({mon.getSize()/2-2,7}, 1, 3, colors.white) -- drawBox(size, xoff, yoff, color) -- Monitor half size box, minus 2 for padding (1 either side)
        drawBox({mon.getSize()-2,8}, 1, 3, colors.orange) -- drawBox(size, xoff, yoff, color) -- Monitor size box, minus 2 for padding (1 either side)
        drawText(" " .. "Energy Information" .. " ", math.floor((mon.getSize()/2 - string.len("Energy Information")) / 2), 4, colors.black, colors.orange) -- This height is always the yoff + 1

        drawText("Stored: " .. format(energyStored) .. "RF" .. " / " .. format(maxEnergyStored) .. "RF", 4, 6, colors.black, colors.orange)
        drawText("Filled: " .. string.format("%.2f", energyPercentage * 100) .. "%", 4, 7, colors.black, colors.orange)
        drawText("Input: " .. format(energyInputRate) .. "RF/t", 4, 8, colors.black, colors.green)
        drawText("Output: " .. format(energyOutputRate) .. "RF/t", 4, 9, colors.black, colors.red)

        -- Structure
        -- Draw a box around the structure info 
        -- ?NOTE: Need to automatically force box one line in, and function out padding of title dynamically.  Or make left aligned +1 or two instead?
        StructureBoxSize = {30,6}
        drawBox(StructureBoxSize, 1, 12, colors.blue) -- drawBox(size, xoff, yoff, color)
        -- Title must me in the middle of the top line of the box and be padded with spaces
        TileLocation = math.floor((StructureBoxSize[1] - string.len("Structure Info")) / 2)
        drawText(" " .. "Structure Info" .. " ", TileLocation, 13, colors.black, colors.blue) -- This height is always the yoff + 1
        drawText("Providers Installed: " .. providers, 4, 15, colors.black, colors.white)
        drawText("Cells Installed: " .. cells, 4, 16, colors.black, colors.white)

        sleep(updateInterval)
    end
end