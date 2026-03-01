local Logger = {}
local log_override = false

function Logger:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Logger:write(...)
    if self.enabled or log_override then
        local arg = {...}
        local file = io.open("_" .. self.file_name .. ".jar.log", "a")
        if not file then
            out("Unable to create/open log file")
            return
        end
        local t = os.date("[%Y-%m-%d][%H:%M:%S] ")
        file:write(t)
        for _, v in pairs(arg) do
            if type(v) == "string" then
                file:write(v)
            else
                file:write(tostring(v))
            end
            file:write(" ")
        end
        file:write("\n")
        file:close()
    end
end

core:add_static_object("jar_logger", Logger)