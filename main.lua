VERSION = "1.0.0"

local strings = import("strings")
local micro = import("micro")
local shell = import("micro/shell")
local config = import("micro/config")
local buffer = import("micro/buffer")

local function ag(bp, args)
    if #args < 1 then
        micro.InfoBar():Error("Need something to search for!")
        return
    end

    local cmd = string.format("bash -c \"ag -Q -U --silent '%s' | fzf --reverse\"", args[1])
    local output, err = shell.RunInteractiveShell(cmd, false, true)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end

    local file, line = string.match(output, "(.+):(%d+)")
    if file then
        local buf, err = buffer.NewBufferFromFile(file)
        if err == nil then
            bp:OpenBuffer(buf)
        end
        if line then
            bp.Cursor.Y = tonumber(line) - 1
        end
    end
end

local function fzf(bp)
    local output, err = shell.RunInteractiveShell("bash -c \"fzf --reverse\"", false, true)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end

    output = strings.TrimSpace(output)
    if output ~= "" then
        local buf, err = buffer.NewBufferFromFile(output)
        if err == nil then
            bp:OpenBuffer(buf)
        end
    end
end

function init()
    config.MakeCommand("ag", ag, config.NoComplete)
    config.MakeCommand("fzf", fzf, config.NoComplete)
    config.TryBindKey("Ctrl-Alt-o", "command:fzf", true)
end
