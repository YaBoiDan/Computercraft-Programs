WhisperLogs = false
RedirectToMon = true

peripheral.find("modem", rednet.open)
if not rednet.isOpen() then
    error("No modem found!")
end

if RedirectToMon then
    mon = peripheral.find("monitor")
    if mon then
        term.redirect(mon)
    end
end

print("LogShower v01")

while true do
    local id, message = rednet.receive(logs_dan)
    print(("%d: %s"):format(id, message))
    print("---end---")
end
