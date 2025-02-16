local Webhook = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
local Reactor = peripheral.find("draconic_reactor")
local MaxTemp = 7500
print("Running Draconic Reactor Protector v0.1")
print("By JenBoi")

while true do
    local Info = Reactor.getReactorInfo()
    local Temp = Info.temperature
    
    if Temp > 7500 then        
        local message = "Temp too high! " .. Temp .."C"
        local user = "Reactor Overload Protection"
        local data = "{\"content\":" .. "\"" .. message .. "\", \"username\":\"" .. user .."\" }"

        local headers = { ["Content-Type"] = "application/json", ["Source"] = "Minecraft/Computercraft/JenBoi" }
        local request, message = http.post(Webhook,data,headers)

        if request then
            print("Message Sent")
        else
            print("Message NOT sent")
        end
    end
    sleep(60)
end
