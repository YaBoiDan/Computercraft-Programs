-- Variables to change
local Reactor_Name = "Dan SP Test"
local Reactor_ID = "draconic_reactor" -- This is the Home Assistant Device ID.
local URI = "https://xxxxxxxxxxxxxxxxxxxxxxxxxx.ui.nabu.casa" -- Home Assistant URI, must be external, had issues with internal IP being "Domain not permitted".
local Token = "Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
local Input_Flow_Gate_Name = "flow_gate_0"
local Output_Flow_Gate_Name = "flow_gate_1"
-- Use peripheral.getNames() to get the names of the peripherals, ensure you right click on each modem and wire them together. 

-- TODO: Add a debug mode to print the data to the console
-- TODO: Add a startup mode that lists peripherals, and confirms you can get data.
-- TODO: Allow bi-directional communication, so you can turn the reactor on and off, tweak the input and output.

term.clear()
term.setCursorPos(1,1)

print("Running Draconic Reactor Monitor v0.2")
print("By JenBoi")
local Reactor = peripheral.find("draconic_reactor")
local Input_Flow_Gate = peripheral.wrap(Input_Flow_Gate_Name)
local Output_Flow_Gate = peripheral.wrap(Output_Flow_Gate_Name)

local function printTbl(tbl)
    for i,j in pairs(tbl) do
        print(i..":"..j)
    end
end

while true do
    local ReactorInfo = Reactor.getReactorInfo()
    local ReactorData = {
        saturation = ReactorInfo.energySaturation,
        failSafe = tostring(ReactorInfo.failSafe),
        field_drain_rate = ReactorInfo.fieldDrainRate,
        field_strength = ReactorInfo.fieldStrength,
        fuel_conversion = ReactorInfo.fuelConversion,
        fuel_conversion_rate = ReactorInfo.fuelConversionRate,
        generationRate = ReactorInfo.generationRate,
        max_saturation = ReactorInfo.maxEnergySaturation,
        max_field_strength = ReactorInfo.maxFieldStrength,
        max_fuel_conversion_rate = ReactorInfo.maxFuelConversion,
        status = ReactorInfo.status,
        temperature = ReactorInfo.temperature,
        last_updated = os.date("!%Y-%m-%d %H:%M:%S"),  -- ISO timestamp
        input_energy = Input_Flow_Gate.getFlow(),
        output_energy = Output_Flow_Gate.getFlow()
    }
    
    local headers = { ["Content-Type"] = "application/json",  ["Authorization"] = Token }
    
    -- Construct the strings dynamically
    for key, value in pairs(ReactorData) do
        -- Debugging
        --print ("------")
        --print (key, value)

        local data = "{\"state\":" .. "\"" .. value .. "\" }"
        local state_url = URI .. "/api/states/sensor." .. Reactor_ID .. "_" .. key
        -- Debugging
        --print(state_url)
        --print(data)
        -- printTbl(headers)
        local request, message = http.post(state_url,data,headers)

        if request then
            print("Message Sent: " .. key)
        else
            print("Message NOT sent")
        end
    end
    print("Done updating, sleeping!")
    sleep(60)
end
