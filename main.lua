VERSION = "1.0.0"

local micro = import("micro")
local shell = import("micro/shell")
local config = import("micro/config")
local buffer = import("micro/buffer")

local function agOutput(output, args)
    local file, line = string.match(output, "(.+):(%d+)")
    if file then
        local bp = args[1]
        local buf, err = buffer.NewBufferFromFile(file)
        if err == nil then
            bp:OpenBuffer(buf)
        end
        if line then
		    bp.Cursor.Y = tonumber(line) - 1
        end
    end
end

local function ag(bp, args)  
    local cmd = string.format("bash -c \"ag -i '%s' | fzf\"", args[1])
    local output, err = shell.RunInteractiveShell(cmd, false, true)
    if err ~= nil then
        micro.InfoBar():Error(err)
    else
        agOutput(output, {bp})
    end
end

function init()
    config.MakeCommand("ag", ag, config.NoComplete)
end
