local up = peripheral.wrap("left")
local down = peripheral.wrap("right")

rednet.open("back")
term.clear()
term.setCursorPos(1,1)
print("Lift Controls V0.1")
print ("My ID: ",os.getComputerID())

while true do
    local event, ID, Message, Protocol = os.pullEvent("rednet_message")
    if Protocol == "LiftControls" then
        print(Message)
        if Message == "Lift:Up" then
            rednet.send(ID,"Going Up")
            redstone.setOutput("left", true)
            sleep(0.2)
            redstone.setOutput("left", false)
        elseif Message == "Lift:Down" then
            rednet.send(ID,"Going Down")
            redstone.setOutput("right", true)
            sleep(0.2)
            redstone.setOutput("right", false)
        end
    end
end
