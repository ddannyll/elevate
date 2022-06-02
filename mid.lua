floors = { "Mine", "Middle", "Top" }

currFloor = 2
currElevatorFloor = 3

topPistonRed = "back"
botPistonRed = "bottom"

rednet.open("back")
red = peripheral.wrap("bottom")


function setPistons(from)
    print("setpistons "..from)
    if currFloor == #floors or currFloor == 1 then
        return
    end
    if from == "bot" then
        print('setpistons bot')
        red.setOutput(topPistonRed, true)
        red.setOutput(botPistonRed, false)
    elseif from == "top" then
        print('setpistons top')
        red.setOutput(topPistonRed, false)
        red.setOutput(botPistonRed, true)
    else
        print('setpistons clear')
        red.setOutput(topPistonRed, false)
        red.setOutput(botPistonRed, false)
    end
end


function receive()
    while true do
        local _, msg, _ = rednet.receive()
        print("msg:"..msg)
        targetFloor = tonumber(string.sub(msg, 2,2))
        if targetFloor == currFloor then
            if currFloor < currElevatorFloor then
                setPistons("top")
            else
                setPistons("bot")
            end
        else
            setPistons("none")
        end
        currElevatorFloor = targetFloor
    end
end


function send()
    while true do
        print("Please choose a floor...")
        for i, v in pairs(floors) do
            write("["..i.."]"..v.." ")
        end
        print("")
        local input = read()
        if input == "-"then
            print(currElevatorFloor)
        else
            local valid = false
            for i, v in pairs(floors) do
                if (i == tonumber(input)) then
                    valid = true
                end
            end
            if valid then
                if tonumber(input) == currFloor then
                    if currFloor < currElevatorFloor then
                        setPistons("top")
                    else
                        setPistons("bot")
                    end
                else
                    rednet.broadcast(currElevatorFloor..input)
                end
                currElevatorFloor = tonumber(input)
                print("currElevatorFloor ",currElevatorFloor)
            else
               print("invalid selection")
            end
        end
    end
end

parallel.waitForAll(send, receive)