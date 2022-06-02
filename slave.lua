floors = nil

function listen ()
    while true do
        _, msg = rednet.receive()
        print(msg)
    end
end

function send ()
    while true do
        getFloors()
        print("Please enter a floor...")
        promptFloor()
        local input = read()
        local valid = false
        for i, v in pairs(floors) do
            if (i == tonumber(input)) then
                valid = true
            end
        end
        if valid then
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

rednet.open('left')
parallel.waitForAll(listen, send)