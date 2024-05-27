
--- Transforms a table of tables into a possibly Markdown-formatted table
---@param tbl table The table to be sorted
---@param sorted boolean? If true, the resulting table will be very naïvely sorted.
---@param html boolean? If true, the output will be formatted as a HTML table.
---@return table lines Table of strings containing the lines of the table. Just iterate and print.
function FormatTable(tbl, sorted, html)

    local before = html  and "<tr><td>"   or "|"
    local between = html and "</td><td>"  or "|"
    local after  = html  and "</td></tr>" or "|"

    local width = {} -- Stores the width of each column.
    local maxIndex = 0 -- Stores the highest number of columns seen for a row
    local lines = {} -- Will store the actual output

    -- First we iterate the lines of the table to figure out the metadata
    for _, line in ipairs(tbl) do
        if type(line) ~= "table" then -- We accidentally put a non-table as a row
            line = {line}
        end
        for index, entry in ipairs(line) do
            maxIndex = math.max(index, maxIndex) -- To know the actual number of cells each row will have
            local asString = string.format("%s", entry) -- Because #foo means something different for a table, and we're making strings
            width[index] = math.max(width[index] or 0, #asString)  -- To know the width of each column, based on the widest entry
        end
    end

    -- Pre-build the formatting string, as it's the same for all lines
    local formatRow = before
    for i = 1, maxIndex do
        if i ~= maxIndex then
            formatRow = formatRow .. " %-" .. width[i] .."s " .. between
        else
            formatRow = formatRow .. " %-" .. width[i] .."s " .. after
        end
    end
    local formatHeader = "<tr><th>"
    if html then
        for i = 1, maxIndex do
            if i ~= maxIndex then
                formatHeader = formatHeader .. " %-" .. width[i] .."s </th><th>"
            else
                formatHeader = formatHeader .. " %-" .. width[i] .."s </th></tr>"
            end
        end
    end

    for i, line in ipairs(tbl) do
        if type(line) ~= "table" then -- We accidentally put a non-table as a row
            line = {line}
        end
        while #line < maxIndex do -- In case not all lines are the same length, we don't want the formatting to choke!
            table.insert(line, "")
        end

        if not html or i ~= 1 then
            table.insert(lines, string.format(formatRow, table.unpack(line)))
        else
            table.insert(lines, string.format(formatHeader, table.unpack(line)))
        end

        if i == 1 and not html then
            local divider = "|"
            for j = 1, maxIndex do
                divider = divider .. string.rep("-", width[j] + 2) .. "|"  -- Width+2 because we are adding spaces around the data
            end
            table.insert(lines, divider)
        end
    end

    if sorted then
        local divider

        -- We don't want to sort the header and divider.
        local header = table.remove(lines, 1)
        if not html then
            divider = table.remove(lines, 1)
        end

        table.sort(lines) -- Yep, sorts with the | prefix and everything ¯\_(ツ)_/¯
        
        -- Don't forget to add them back in!
        if not html then
            table.insert(lines, 1, divider)
        end
        table.insert(lines, 1, header)
    end

    return lines
end