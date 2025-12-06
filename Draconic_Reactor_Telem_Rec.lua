-- Monitor Functions (inspired by induction.lua)
local mon

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
        return false
    end

    resetMon()
    return true
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
        return string.format("%.2fG", num / 1000000000)
    elseif (num >= 1000000) then
        return string.format("%.2fM", num / 1000000)
    elseif (num >= 1000) then
        return string.format("%.2fK", num / 1000)
    elseif (num >= 1) then
        return string.format("%.2f", num)
    elseif (num >= .001) then
        return string.format("%.2fm", num * 1000)
    elseif (num >= .000001) then
        return string.format("%.2fu", num * 1000000)
    else
        return string.format("%.2f", 0)
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

-- Draw a horizontal bar graph
local function drawBar(x, y, width, percent, label, barColor, bgColor)
    if (mon == nil) then
        return
    end
    
    -- Draw label
    drawText(label, x, y, colors.black, colors.white)
    
    -- Draw bar background
    mon.setCursorPos(x, y + 1)
    mon.setBackgroundColor(bgColor or colors.gray)
    mon.write(string.rep(" ", width))
    
    -- Draw filled portion
    local fillWidth = math.floor((percent / 100) * width)
    if fillWidth > 0 then
        mon.setCursorPos(x, y + 1)
        mon.setBackgroundColor(barColor)
        mon.write(string.rep(" ", fillWidth))
    end
    
    -- Draw percentage text on top of bar with bar color background
    local percentText = string.format("%.1f%%", percent)
    local percentX = x + math.floor((width - string.len(percentText)) / 2)
    mon.setCursorPos(percentX, y + 1)
    
    -- Use bar color if filled enough to reach the text, otherwise use background color
    if fillWidth >= (percentX - x + string.len(percentText)) then
        mon.setBackgroundColor(barColor)
    else
        mon.setBackgroundColor(bgColor or colors.gray)
    end
    
    mon.setTextColor(colors.white)
    mon.write(percentText)
    
    mon.setBackgroundColor(colors.black)
end

local function drawDashboard(data)
    if not mon then return end
    
    mon.clear()
    
    -- Title
    local title = "Draconic Reactor Monitor"
    local monWidth = mon.getSize()
    local titleX = math.floor((monWidth - string.len(title)) / 2)
    drawText(title, titleX, 1, colors.black, colors.white)
    drawText(string.rep("-", string.len(title)), titleX, 2, colors.black, colors.white)
    
    -- Calculate box widths for side-by-side layout
    local halfWidth = math.floor(monWidth / 2) - 1
    local leftX = 1
    local rightX = halfWidth + 2
    
    -- Row 1: Temperature & Field (Left) | RF Flow (Right)
    -- Temperature & Field Box (Left)
    drawBox({halfWidth, 6}, leftX, 3, colors.orange)
    local tempTitle = "Temperature & Field"
    local tempTitleX = leftX + math.floor((halfWidth - string.len(tempTitle)) / 2)
    drawText(" " .. tempTitle .. " ", tempTitleX, 4, colors.black, colors.orange)
    
    local temp = data.temperature or 0
    local tempColor = colors.white
    if temp > 8000 then
        tempColor = colors.red
    elseif temp > 6000 then
        tempColor = colors.yellow
    end
    drawText("Temp: " .. format(temp) .. "C", leftX + 3, 6, colors.black, tempColor)
    
    local fieldStrength = data.fieldStrength or 0
    local maxFieldStrength = data.maxFieldStrength or 1
    local fieldPercent = (fieldStrength / maxFieldStrength) * 100
    local fieldColor = colors.white
    if fieldPercent < 10 then
        fieldColor = colors.red
    elseif fieldPercent < 30 then
        fieldColor = colors.yellow
    end
    drawText("Field: " .. format(fieldStrength) .. " / " .. format(maxFieldStrength), leftX + 3, 7, colors.black, fieldColor)
    
    -- RF Flow Box (Right)
    drawBox({halfWidth, 6}, rightX, 3, colors.lime)
    local rfTitle = "RF Flow"
    local rfTitleX = rightX + math.floor((halfWidth - string.len(rfTitle)) / 2)
    drawText(" " .. rfTitle .. " ", rfTitleX, 4, colors.black, colors.lime)
    
    drawText("In: " .. format(data.rfIn or 0) .. "RF/t", rightX + 3, 6, colors.black, colors.green)
    drawText("Out: " .. format(data.rfOut or 0) .. "RF/t", rightX + 3, 7, colors.black, colors.red)
    
    -- Row 2: Fuel Conversion & Energy Saturation (Full width)
    drawBox({monWidth-2, 7}, 1, 10, colors.purple)
    local combinedTitle = "Fuel Conversion & Energy Saturation"
    local combinedTitleX = math.floor((monWidth - string.len(combinedTitle)) / 2)
    drawText(" " .. combinedTitle .. " ", combinedTitleX, 11, colors.black, colors.purple)
    
    -- Fuel Conversion (Left side)
    local fuelConv = data.fuelConversion or 0
    local maxFuelConv = data.maxFuelConversion or 1
    local fuelPercent = (fuelConv / maxFuelConv) * 100
    drawText("Fuel Rate: " .. format(fuelConv) .. " / " .. format(maxFuelConv), 4, 13, colors.black, colors.white)
    
    -- Energy Saturation (Right side)
    local energySat = data.energySaturation or 0
    local maxEnergySat = data.maxEnergySaturation or 1
    local energyPercent = (energySat / maxEnergySat) * 100
    
    -- Energy Saturation on second line (full width centered)
    drawText("Energy Sat: " .. format(energySat) .. " / " .. format(maxEnergySat), 4, 15, colors.black, colors.white)
    
    -- Bar Graphs Section (with padding line above)
    local barWidth = monWidth - 4
    local barX = 3
    
    -- Field Strength Bar
    drawBar(barX, 19, barWidth, fieldPercent, "Field Strength", colors.orange, colors.gray)
    
    -- Energy Saturation Bar
    drawBar(barX, 22, barWidth, energyPercent, "Energy Saturation", colors.blue, colors.gray)
    
    -- Fuel Conversion Bar
    drawBar(barX, 25, barWidth, fuelPercent, "Fuel Conversion", colors.purple, colors.gray)
    
    -- Status (at bottom with padding)
    local statusColor = colors.green
    local statusText = data.status or "UNKNOWN"
    if statusText == "stopping" or statusText == "offline" then
        statusColor = colors.red
    elseif statusText == "warming_up" or statusText == "cooling" then
        statusColor = colors.yellow
    end
    
    drawText("Status: " .. statusText:upper(), 3, 28, colors.black, statusColor)
end

-- Open rednet on a modem (adjust side as needed)
local modem = peripheral.find("modem")
if modem then
    rednet.open(peripheral.getName(modem))
else
    error("No modem found!")
end

-- Initialize monitor
local hasMonitor = initMon()

print("Waiting for telemetry data...")
if hasMonitor then
    print("Monitor initialized successfully!")
else
    print("No monitor found - will use terminal only")
end

while true do
    local senderId, message, protocol = rednet.receive()
    
    -- Check if message is a table
    if type(message) == "table" then
        -- Terminal output
        term.clear()
        term.setCursorPos(1, 1)
        
        print("=== Telemetry Received ===")
        print("From: " .. senderId)
        print("Timestamp: " .. (message.timestamp or "N/A"))
        print("")
        
        -- Flatten the data structure for easier access
        local flatData = {}
        if message.reactor then
            for key, value in pairs(message.reactor) do
                flatData[key] = value
                print("  " .. key .. ": " .. tostring(value))
            end
        end
        if message.flux then
            flatData.rfIn = message.flux.rfIn
            flatData.rfOut = message.flux.rfOut
            print("  RF In: " .. tostring(message.flux.rfIn))
            print("  RF Out: " .. tostring(message.flux.rfOut))
        end
        
        print("")
        print("Waiting for next message...")
        
        -- Update monitor dashboard
        if hasMonitor then
            drawDashboard(flatData)
        end
    end
end