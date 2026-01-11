print("Chest Mon v01")
print("Place chest at the rear")
rednet.open("top")

Location = "Dan Bee Dim"
Protocol = "logs_dan"

while true do
    local Chest = peripheral.wrap("back")
    local Slots = Chest.size()
    local LastSlotMax = Chest.getItemLimit(Slots)
    local itemDetail = Chest.getItemDetail(Slots)
    local LastSlotAmount = itemDetail and itemDetail.count or 0
    print(LastSlotAmount .. "/" .. LastSlotMax)

    if (LastSlotAmount == LastSlotMax) then
        print("Transfer chest is full, go check it out!")
        rednet.broadcast("Transfer chest is full in " .. Location .. "!", Protocol)
    else
        print("Chest is fine bro, keep going!")
    end

    sleep(300)
end
