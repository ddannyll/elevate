
-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
-- Elevator Object
-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.

Elevator = {floors=nil, currFloor=nil, prevDirection=nil, redFace=nil, modemFace=nil}

function Elevator:init()
    if not fs.exists('/data/elevatorData') then
        -- No elevator data, prompt user for setup
        print("Setup is required!")
        print("Please enter floor names, starting from the bottom.")
        print("When complete, enter '-'")

        -- Setup for floor / floor names
        local floors = {}
        local floorName = read()
        while floorName ~= '-' do
            table.insert(floors, floorName)
            floorName = read()
        end

        -- Setup for currfloor
        print("Please send the elevator up to the top floor.")
        print("When complete, enter '-")
        local input = read()
        while input ~= '-' do
            input = read()
        end

        -- Setup for redstone controller

        print("Please enter the redstone output face to activate elevator")
        local redFace = read()
        local faces = {left=true, right=true, up=true, bottom=true, front=true, back=true}
        while faces[redFace] == nil do
            print("Please enter a valid face! [left, right, up, bottom, front, back]")
            redFace = read()
        end

        -- modem setup
        print("Please enter the face for the modem")
        local modemFace = read()
        local modemFaceWrap = peripheral.wrap(modemFace)
        while modemFaceWrap == nil and modemFaceWrap.transmit == nil do
            print("Could not find modem. Please enter the face for the modem.")
            modemFace = read()
            modemFaceWrap = peripheral.wrap(modemFace)
        end

        -- Combine data and searlize to file
        local data = {floors=floors, currFloor=#floors, prevDirection='up', redFace=redFace, modemFace=modemFace}
        local newFile = fs.open("/data/elevatorData", "w")
        newFile.write(textutils.serializeJSON(data))
        newFile.close()
    end

    -- Set object attributes from file
    print("Persistant data found! Reading data...")
    local f = fs.open("/data/elevatorData", "r")
    local data = textutils.unserializeJSON(f.readAll())
    self.floors = data.floors
    self.currFloor = data.currFloor
    self.prevDirection = data.prevDirection
    self.redFace = data.redFace
    self.modemFace = data.modemFace
    f.close()
end

function Elevator:sendTo(floor)
    local direction = 'up'
    if self.currFloor > floor then
        direction = 'down'
    end

    msg = {action="set", floor=floor, direction=direction}
    rednet.broadcast(textutils.serializeJSON(msg))
    
    if direction == self.prevDirection then
        sleep(0.1)
        redstone.setOutput(self.redFace, true)
        sleep(0.1)
        redstone.setOutput(self.redFace, false)
        sleep(0.1)
        redstone.setOutput(self.redFace, true)
        sleep(0.1)
        redstone.setOutput(self.redFace, false)
        sleep(0.1)
    else
        sleep(0.1)
        redstone.setOutput(self.redFace, true)
        sleep(0.1)
        redstone.setOutput(self.redFace, false)
        sleep(0.1)
    end
    self.prevDirection = direction
end

-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
-- Main
-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
function main()
    rednet.open(Elevator.modemFace)
    while true do
        local _, msg = rednet.receive()
        msg = textutils.unserializeJSON(msg)
        if msg.action == 'req' then
            Elevator:sendTo(msg.floor)
        end
    end
end

-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
-- Helper Functions
-- .-.-.-..-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.-.
function readValidFloor(floors)
    local input = read()
    for i, v in pairs(floors) do
        if (i == tonumber(input)) then
            return tonumber(input)
        end
    end
    return nil
end
function promptFloor(floors)
    for i, v in pairs(floors) do
        write("["..i.."]"..v.." ")
    end
    print("")
end


Elevator:init()

main()
