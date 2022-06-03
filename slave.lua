floors = nil
currFloor = nil
redIntFace = nil
topPistonRed = nil
botPistonRed = nil
modemFace = nil
monitorDirection = nil
mon = nil

redInt = nil

if not fs.exists("touchpoint") then
    shell.run("pastebin get pFHeia96 touchpoint")
end
os.loadAPI('touchpoint')


function setPistons(direction)
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
        elseif msg.action == 'changeFloor' then
            if msg.floor == currFloor then
                local f = fs.open("/data/slaveData", "r")
                local data = textutils.unserializeJSON(f.readAll())
                f.close()
                data.currFloor = msg.newFloor
                currFloor = msg.newFloor
                f = fs.open("/data/slaveData", "w")
                f.write(textutils.serializeJSON(data))
                f.close()
                sleep(5) -- sleep to avoid changeFloor overlaps
            end
        elseif msg.action == 'sendDataFloors' then
            floors = msg.floors
            local f = fs.open("/data/slaveData", "r")
            local data = textutils.unserializeJSON(f.readAll())
            f.close()
            data.floors = msg.floors
            f = fs.open("/data/slaveData", 'w')
            f.write(textutils.serializeJSON(data))
            f.close()
        end
    end
end

function send ()
    -- while true do
    --     rednet.broadcast({action='getFloors'})
    --     promptFloor()
    --     print("Please enter a floor...")
    --     local input = read()
    --     if validFloor(tonumber(input)) then
    --         rednet.broadcast({action='request', floor=tonumber(input)})
    --     else
    --         print("Invalid selection")
    --     end
    -- end
    while true do
        rednet.broadcast({action='getFloors'})
        local t = touchpoint.new(monitorDirection)
        local maxX, maxY = mon.getSize()

        for i, v in pairs(floors) do
            local str = "["..i.."]"..v
            while string.len(str) < maxX do
                str = str..' '
            end
            t:add(str, nil, 1, #floors + 1 - i, maxX, #floors + 1 - i, colors.red, colors.lime)
        end
        t:draw()
        
        local event, p1 = t:handleEvents(os.pullEvent())
        while event ~= "button_click" do
            event, p1 = t:handleEvents(os.pullEvent())
        end
        
        local chosenFloor = tonumber(string.sub(p1, 2,2))
        t:flash(p1)
        local endNumChar = string.find(p1, ']') - 1
        print(tonumber(string.sub(p1, 2, endNumChar)))
        rednet.broadcast({action='request', floor=tonumber(string.sub(p1, 2, endNumChar))})
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

-- Load persistence
if fs.exists('/data/slaveData') then
    local f = fs.open('/data/slaveData', 'r')
    local data = textutils.unserializeJSON(f.readAll())
    floors = data.floors
    currFloor = data.currFloor
    redIntFace = data.redIntFace
    topPistonRed = data.topPistonRed
    botPistonRed = data.botPistonRed
    modemFace = data.modemFace
    monitorDirection = data.monitorDirection
    f.close()
end


-- Set globals if nil
if modemFace == nil then
    print("Please enter the face for the modem")
    modemFace = read()
    while not validFace(modemFace) do
        modemFace = read()
    end
end
rednet.open(modemFace)

if currFloor == nil then
    print("Please enter the current floor (the one you are standing on)")
    rednet.broadcast({action='getFloors'})
    local _, floorData = rednet.receive()
    floors = floorData.floors
    promptFloor()
    local input = read()
    while not validFloor(tonumber(input)) do
        input = read()
    end
    currFloor = tonumber(input)
end

if currFloor ~= #floors and currFloor ~= 1 then
    if redIntFace == nil then
        print("Please enter the face for the redstone integrator")
        redIntFace = read()
        while not validFace(redIntFace) do
            redIntFace = read()
        end
    end
    redInt = peripheral.wrap(redIntFace)
    
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

if monitorDirection == nil then
    print("Please enter the face for the monitor")
    monitorDirection = read()
    while not validFace(monitorDirection) do
        monitorDirection = read()
    end
end

local f = fs.open("/data/slaveData", 'w')
f.write(textutils.serializeJSON({floors=floors, currFloor=currFloor, redIntFace=redIntFace, topPistonRed=topPistonRed, botPistonRed=botPistonRed, modemFace=modemFace, monitorDirection=monitorDirection}))
f.close()

mon = peripheral.wrap(monitorDirection)
mon.setTextScale(0.5)


parallel.waitForAll(listen, send)