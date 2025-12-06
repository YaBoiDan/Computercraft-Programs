
-- Draconic Reactor Telemetry System
-- Monitors reactor stats and RF flow through flux gates
-- Sends data to remote host

local reactor = peripheral.find("draconic_reactor")
local fluxGates = {peripheral.find("flow_gate")}

local RECEIVER_ID = 9  -- Computer ID to send data to
local UPDATE_INTERVAL = 1  -- Seconds between updates
local INPUT_GATE_INDEX = 2  -- 1 for first gate (_0), 2 for second gate (_1), this is the order you clicked the modem for input. 

if not reactor then
    error("Draconic Reactor not found!")
end

if #fluxGates < 2 then
    error("Need at least 2 flux gates connected!")
end

-- Assign input/output based on configuration
local fluxGateIn = fluxGates[INPUT_GATE_INDEX]
local fluxGateOut = fluxGates[INPUT_GATE_INDEX == 1 and 2 or 1]

print("Input Gate: " .. peripheral.getName(fluxGateIn))
print("Output Gate: " .. peripheral.getName(fluxGateOut))

-- Open rednet on modem
local modem = peripheral.find("modem")
if modem then
    rednet.open(peripheral.getName(modem))
end

-- Function to get reactor info
local function getReactorData()
    local info = reactor.getReactorInfo()
    return {
        status = info.status,
        temperature = info.temperature,
        fieldStrength = info.fieldStrength,
        maxFieldStrength = info.maxFieldStrength,
        energySaturation = info.energySaturation,
        maxEnergySaturation = info.maxEnergySaturation,
        fuelConversion = info.fuelConversion,
        maxFuelConversion = info.maxFuelConversion
    }
end

-- Function to get flux gate flow rates
local function getFluxGateData()
    return {
        rfIn = fluxGateIn.getFlow(),
        rfOut = fluxGateOut.getFlow()
    }
end

-- Main monitoring loop
print("Draconic Reactor Telemetry Online")
print("Sending to Computer ID: " .. RECEIVER_ID)

while true do
    local success, reactorData = pcall(getReactorData)
    local fluxData = getFluxGateData()
    
    if success then
        local telemetry = {
            reactor = reactorData,
            flux = fluxData,
            timestamp = os.epoch("utc")
        }
        
        rednet.send(RECEIVER_ID, telemetry)
        
        -- print(string.format("Temp: %d | Field: %.1f%% | RF In: %d | RF Out: %d",
        --     reactorData.temperature,
        --     (reactorData.fieldStrength / reactorData.maxFieldStrength) * 100,
        --     fluxData.rfIn,
        --     fluxData.rfOut
        -- ))
    else
        print("Error reading reactor: " .. tostring(reactorData))
    end
    
    sleep(UPDATE_INTERVAL)
end