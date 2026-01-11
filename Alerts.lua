WhisperLogs = false
RedirectToMon = true
AlertNoise = false

-- Network Settings
peripheral.find("modem", rednet.open)
if not rednet.isOpen() then
    error("No modem found!")
end

print("LogShower v01")

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
        print("LogShower v01")
        print("----------------")
    end
end


while true do
    local id, message = rednet.receive(logs_dan)
    print(("%d: %s"):format(id, message) .. "[end]")
end
