
-- List of hostname-protocol pairs, single string, separated by ":"
local HOSTNAME
local PROTOCOLS

local MODEM
local MessageHandler

-- UTILITY

local function save_table(t, path)
    local file = fs.open(path,"w")
    file.write(textutils.serialize(t))
    file.close()
end

local function load_table(path)
    local file = fs.open(path,"r")
    local data = file.readAll()
    file.close()
    return textutils.unserialize(data)
end

function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then return true end
    end
    return false
end

function string.split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do table.insert(result, match) end
    return result
end


-- SERVER

local function mainLoop(nIteration)
    print('Iteration '..nIteration)
    local senderID, message, protocol = rednet.receive(nil, 5)

    if not table.contains(PROTOCOLS, protocol) then
        printError('Received message under unsupported protocol "'..protocol..'" — ignoring.')
        return
    end
    print('Message from #'..senderID..' protocol: "'..protocol..'"')
    local response = MessageHandler(senderID, message, protocol)

    print('Sending response to #'..senderID)
    rednet.send(senderID, response, protocol)
end

-- Setup the server
-- - fnMessageHandler: The function to that handles incoming messages.
-- It should take in 3 arguments: the sender's ID, the message itself and
-- the protocol it was sent under.
-- - strHostname: The hostname for the server
-- - lsProtocols: A list of protocols for the server
local function setup(fnMessageHandler, strHostname, lsProtocols)
    HOSTNAME = strHostname
    PROTOCOLS = lsProtocols
    MessageHandler = fnMessageHandler
end

-- Start the server
-- - strPreferredModem: The modedem to run the server out of, if none is
-- specified, the first available one will be opened and used.
local function start(strPreferredModem)
    for i=1, #PROTOCOLS do
        print("-> Hosting "..HOSTNAME..":"..PROTOCOLS[i])
        rednet.host(PROTOCOLS[i], HOSTNAME)
    end

    if strPreferredModem then MODEM = peripheral.wrap(strPreferredModem)
    else MODEM = peripheral.find("modem")[1] end
    print("Starting server from modem: "..peripheral.getName(MODEM))
    rednet.open(MODEM)

    local iterationCount = 0
    while true do
        mainLoop(iterationCount)
        iterationCount = iterationCount + 1
    end
end

-- Stops the server
-- [ DOESN'T WORK FOR NOW ]
local function stop()
    for i=1, #PROTOCOLS do
        rednet.unhost(PROTOCOLS[i])
    end
    rednet.close(MODEM)
end


return {
    setup = setup,
    start = start,
    stop = stop
}