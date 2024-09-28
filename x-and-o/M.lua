local M = {}

local json = require("json")

local defaultLocation = system.DocumentsDirectory

function M.load_table (filename, location)
    local loc = location or system.DocumentsDirectory
    local path = system.pathForFile(filename, loc)
    local file, errorString = io.open(path, "r")
    if not file then
        print("File error: " .. errorString)
    else
        local contents = file:read("*a")
        local data = json.decode(contents)
        io.close(file)
        return data
    end
 end
 
function M.save_table (t, filename, location)
    local loc = location or defaultLocation
    local path = system.pathForFile(filename, loc)
    local file, errorString = io.open(path, "w")
    if not file then
        print("File error: " .. errorString)
        return false
    else
        file:write(json.encode(t))
        io.close(file)
        return true
    end
end

return M