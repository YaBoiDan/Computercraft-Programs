WhisperLogs = true
RedirectToMon = true
AlertNoise = false
Whisper_Player = "AutomationNerd"

-- Network Settings
peripheral.find("modem", rednet.open)
if not rednet.isOpen() then
    error("No modem found!")
end

-- ChatSettings
local toast_tbl = {
    ["INFO"] = "&2&l",
    ["WARN"] = "&e&l",
    ["ERROR"] = "&4&l",
    ["NONE"] = "&7&l"
}

if WhisperLogs then
    chat = peripheral.find("chat_box")
    if not chat then
        error("No chat box found!")
    else
        print("Chat box found, enabling log whispers.")
    end
end

-- Monitor Setup
local mon = nil
local mon_tbl = {
    ["INFO"] = colors.blue,
    ["WARN"] = colors.yellow,
    ["ERROR"] = colors.red,
    ["NONE"] = colors.white
}

if RedirectToMon then
    mon = peripheral.find("monitor")
    if mon then
        mon.clear()
        mon.setTextScale(0.5)
        mon.setCursorPos(1,1)
        print("Monitor found, redirecting output.")
        term.redirect(mon)
    end
end

-- Functions

function setSevColourToast(type)
    toast_colour = toast_tbl[type] or "&7&l"
    return toast_colour
end

function setSevColourMon(type)
    return mon_tbl[type] or colors.white
end

print("LogShower v01")
print("----------------")

while true do
    local id, message = rednet.receive(logs_dan)
    -- Extract the type from the message, the value before the first semicolon
    type = string.match(message, "^(.-);" or "NONE")
    data = string.gsub(message, "^(.-);","")
    
    local typeColor = setSevColourMon(type)
    toast_colour = setSevColourToast(type)
    
    -- Print with colored type only
    local output = mon or term
    output.setTextColor(colors.white)
    output.write(string.format("%d: [", id))
    output.setTextColor(typeColor)
    output.write(type)
    output.setTextColor(colors.white)
    output.write(string.format("] %s[end]", data))
    print("")  -- Add line break
    
    if chat then
        chat.sendToastToPlayer(data, "Log Message", Whisper_Player, (toast_colour .. type))
    end
    
end
