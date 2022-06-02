floors = { "Mine", "Middle", "Top" }

Elevator = {currFloor = nil, currElevatorFloor = nil}
function Elevator:new (currFloor, currElevatorFloor)
    self.currFloor = currFloor
    self.currElevatorFloor = currElevatorFloor
end

function Elevator:init ()
    local currFloor = unserialize('currFloor')
    if currFloor == nil then
        -- Prompt user for currFloor input
        print("Current floor (the one you are standing on) has not been set! Please enter from the following:")
        promptFloor(floors)
    end
    local currElevatorFloor = unserialize('currElevatorFloor')
end


function promptFloor(floors)
    for i, v in pairs(floors) do
        write("["..i.."]"..v.." ")
    end
    print("")
end

function readInput(floors)
    local input = read()
    local valid = false
    for i, v in pairs(floors) do
        if (i == tonumber(input)) then
            valid = true
        end
    end
    if valid then
        return tonumber(i)
    else
        return nil
    end
end


function serialize(data, name)
	if not fs.exists('/data') then
		fs.makeDir('/data')
	end
	local f = fs.open('/data/'..name, 'w')
	f.write(textutils.serialize(data))
	f.close()
end

function unserialize(name)
    -- Returns nil if there is no data
	if fs.exists('/data/'..name) then
		local f = fs.open('/data/'..name, 'r')
		data = textutils.unserialize(f.readAll())
		f.close()
	end
	return data
end