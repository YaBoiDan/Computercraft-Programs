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

print("LogShower v01")
print("----------------")

while true do
    local id, message = rednet.receive(logs_dan)
    -- Extract the type from the message, the value before the first semicolon
    type = string.match(message, "^(.-);") or "NONE"
    data = string.gsub(message, "^(.-);", "")
    print(("%d: [%s] %s"):format(id, type, data) .. "[end]")
    if chat then
        if type == "INFO" then
            toast_colour = "&2&l"
        elseif type == "WARN" then
            toast_colour = "&e&l"
        elseif type == "ERROR" then
            toast_colour = "&4&l"
        else
            toast_colour = "&7&l"
        end
        chat.sendToastToPlayer(data, "Log Message", Whisper_Player, (toast_colour .. type))
    end
    
end
