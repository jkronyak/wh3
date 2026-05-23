------------------------------------------------------------------------
--- Module: Jar Logger
--- Author: AceTheGreat
--- Description: A simple logging module that writes to the game folder.
------------------------------------------------------------------------

local Logger = {}

------------------------------------------------------------------------
--- Types and Configuration
------------------------------------------------------------------------

--- @class Logger
--- @field name string - The prefix/name for the output file. Default: "test"
--- @field enabled boolean - The flag to enable/disable logging. Default: true
--- @field write_date boolean - Flag to toggle prepended date. Default: true
--- @field write_time boolean - The flag to enable/disable prepended time. Default: true
--- @field min_level LogLevel - The minimum level of logs to output. Default: DEBUG
--- @field append boolean - Flag to append to the log file rather than overwriting. Default: true


--- @enum LogLevel 
local LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, }

--- @type table<string, LogLevel>
Logger.LEVELS = LEVELS

local LEVEL_NAMES = { [1] = "DEBUG", [2] = "INFO", [3] = "WARN", [4] = "ERROR" }

------------------------------------------------------------------------
--- Core Functionality
------------------------------------------------------------------------

--- Creates a new Logger instance from the supplied configuration.
--- @param o table | nil
--- @return Logger
function Logger:new(o)
    o = o or {}

    if o.name == nil then o.name = "test" end
    if o.enabled == nil then o.enabled = true end
    if o.write_date == nil then o.write_date = true end
    if o.write_time == nil then o.write_time = true end
    if o.min_level == nil then o.min_level = Logger.LEVELS.DEBUG end
    if o.append == nil then o.append = true end

    -- When append is false, clear the file out upon logger instantiation.
    if not o.append then
        local file = io.open("_" .. o.name .. "_.jar.log", "w")
        if file then file:close() end
    end

    setmetatable(o, self)
    self.__index = self
    return o
end

--- Stringifies and writes a variable number of arguments at the specified logging level.
--- @param level LogLevel
function Logger:write(level, ...)

    if not self.enabled or level < self.min_level then return end

    local file_name = "_" .. self.name .. "_.jar.log"
    local file = io.open(file_name, "a")

    if not file then return out("Unable to create/open log file: " .. file_name) end

    local level_name = LEVEL_NAMES[level] or "UNKN"

    if self.write_date then file:write(os.date("[%Y-%m-%d]")) end
    if self.write_time then file:write(os.date("[%H:%M:%S]")) end
    file:write("[" .. level_name .. "] ")

    for _, v in ipairs({ ... }) do
        if type(v) == "string" then file:write(v)
        else file:write(tostring(v))
        end
        file:write(" ")
    end

    file:write("\n")
    file:close()
end

------------------------------------------------------------------------
--- Write Convenience Methods
------------------------------------------------------------------------

function Logger:debug(...) self:write(LEVELS.DEBUG, ...) end

function Logger:info(...) self:write(LEVELS.INFO, ...) end

function Logger:warn(...) self:write(LEVELS.WARN, ...) end

function Logger:error(...) self:write(LEVELS.ERROR, ...) end

------------------------------------------------------------------------
--- Logger State Methods
------------------------------------------------------------------------

--- @param level LogLevel
function Logger:set_level(level) self.min_level = level end

function Logger:enable() self.enabled = true end

function Logger:disable() self.enabled = false end

------------------------------------------------------------------------
--- Module Export
------------------------------------------------------------------------

core:add_static_object("jar_logger", Logger)
