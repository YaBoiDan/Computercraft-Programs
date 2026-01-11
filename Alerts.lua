WhisperLogs = false

peripheral.find("modem", rednet.open)
print("LogShower v01")

while true do
    local id, message = rednet.receive(logs_dan)
    print(("%d: %s"):format(id, message))
    print("---end---")
end
