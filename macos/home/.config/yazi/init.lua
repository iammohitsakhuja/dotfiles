require("full-border"):setup {
    type = ui.Border.ROUNDED,
}


function Linemode:size_and_mtime()
    local time = math.floor(self._file.cha.mtime or 0)
    if time == 0 then
        time = ""
    elseif os.date("%Y", time) == os.date("%Y") then
        time = os.date("%d %b %H:%M", time)
    else
        time = os.date("%d %b %Y %H:%M", time)
    end

    local size = self._file:size()
    local size_str = size and ya.readable_size(size) or "-"

    return string.format("%-8s %s", size_str, time)
end
