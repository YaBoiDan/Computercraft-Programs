local Webhook = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
local Reactor = peripheral.find("draconic_reactor")
local MaxTemp = 4500
local LimitTemp  = 6000 -- This will shut it down.

term.clear()
term.setCursorPos(1,1)
print("Running Draconic Reactor Protector v0.2")
print("By JenBoi")
print("---------------------------------------")
print ("Max Temp set to: " .. MaxTemp .."C")
print ("Limit Temp set to: " .. LimitTemp .."C")
print("'Oh fuck' - Cryocrafted 14/01/2025")

while true do
    local Info = Reactor.getReactorInfo()
    local Temp = Info.temperature
    
    if Temp > MaxTemp then        
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
    
        if Temp > LimitTemp then
            Reactor.stopReactor()
            print("Reactor shut down due to critical temperature!")
            local message = "I stopped a nuclear meltdown! " .. Temp .."C"
            local data = "{\"content\":" .. "\"" .. message .. "\", \"username\":\"" .. user .."\" }"
        end
    end
    sleep(60)
end
