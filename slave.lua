floors = nil
currFloor = nil
redIntFace = nil
topPistonRed = nil
botPistonRed = nil
modemFace = nil

redInt = nil

function setPistons(direction)
    print("setpistons "..direction)
    if currFloor == #floors or currFloor == 1 then
        return
    end
    if direction == "up" then
        redInt.setOutput(topPistonRed, true)
        redInt.setOutput(botPistonRed, false)
    elseif direction == "down" then
        redInt.setOutput(topPistonRed, false)
        redInt.setOutput(botPistonRed, true)
    else
        print('setpistons clear')
        redInt.setOutput(topPistonRed, false)
        redInt.setOutput(botPistonRed, false)
    end
end

function listen ()
    while true do
        _, msg = rednet.receive()
        if msg.action == 'send' then
            if msg.floor == currFloor then
                setPistons(msg.direction)
            else
                setPistons('none')
            end
        end
    end
end

function send ()
    while true do
        getFloors()
        print("Please enter a floor...")
        promptFloor()
        local input = read()
        if validFloor(tonumber(input)) then
            rednet.broadcast({action='request', floor=tonumber(input)})
        else
            print("Invalid selection")
        end
    end
end

function getFloors()
    if floors == nil then
        rednet.broadcast({action='getFloors'})
        _, msg = rednet.receive()
        while msg.action ~= "sendDataFloors" do
            rednet.broadcast({action='getFloors'})
            _, msg = rednet.receive()
        end
        floors = msg.floors
    end
end

function promptFloor()
    for i, v in pairs(floors) do
        write("["..i.."]"..v.." ")
    end
    print("")
end

function validFloor(floor)
    for i, v in pairs(floors) do
        if (i == floor) then
            return true
        end
    end
    return false
end

function validFace(face)
    local faces = {left=true, right=true, up=true, bottom=true, front=true, back=true}
    if faces[face] == nil then
        return false
    end
    return true
end

-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
-- MAIN CODE
-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
if modemFace == nil then
    print("Please enter the face for the modem")
    modemFace = read()
    while not validFace(modemFace) do
        modemFace = read()
    end
end

rednet.open(modemFace)
redInt = peripheral.wrap(redIntFace)

if currFloor == nil then
    print("Please enter the current floor (the one you are standing on)")
    getFloors()
    promptFloor()
    local input = read()
    while not validFloor(tonumber(input)) do
        input = read()
    end
    currFloor = tonumber(input)
end

if currFloor ~= #floors or currFloor ~= 1 then
    if redIntFace == nil then
        print("Please enter the face for the redstone integrator")
        redIntFace = read()
        while not validFace(redIntFace) do
            redIntFace = read()
        end
    end
    
    if topPistonRed == nil then
        print("Please enter the face for top piston redstone")
        topPistonRed = read()
        while not validFace(topPistonRed) do
            topPistonRed = read()
        end
    end
    
    if botPistonRed == nil then
        print("Please enter the face for bottom piston redstone")
        botPistonRed = read()
        while not validFace(botPistonRed) do
            botPistonRed = read()
        end
    end
end
parallel.waitForAll(listen, send)