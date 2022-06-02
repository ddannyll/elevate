function listen ()
    while true do
        msg=rednet.receive()
        print(msg)
    end
end

function send ()
    while true do
        input = read()
        msg = {action="req", floor=2}
        rednet.broadcast(msg)
    end
end

rednet.open('left')
parallel.waitForAll(listen, send)