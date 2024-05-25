
--- Transforms a table of tables into a possibly Markdown-formatted table
---@param tbl table The table to be sorted
---@param sorted boolean? If true, the resulting table will be very naïvely sorted.
---@param skipDivider boolean? If true, a divider line is omitted. This line is required for Markdown!
---@return table lines Table of strings containing the lines of the table. Just iterate and print.
function FormatTable(tbl, sorted, skipDivider)

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
    local formatString = "|"
    for i = 1, maxIndex do
        formatString = formatString .. " %-" .. width[i] .."s |"
    end

    for i, line in ipairs(tbl) do
        if type(line) ~= "table" then -- We accidentally put a non-table as a row
            line = {line}
        end
        while #line < maxIndex do -- In case not all lines are the same length, we don't want the formatting to choke!
            table.insert(line, "")
        end

        table.insert(lines, string.format(formatString, table.unpack(line)))

        if i == 1 and not skipDivider then
            local divider = "|"
            for j = 1, maxIndex do
                divider = divider .. string.rep("-", width[j] + 2) .. "|"  -- Width+2 because we are adding spaces around the data
            end
            table.insert(lines, divider)
        end
    end

    if sorted then
        local header, divider
        if not skipDivider then
            -- We don't want to sort the header and divider.
            header = table.remove(lines, 1)
            divider = table.remove(lines, 1)
        end
        table.sort(lines) -- Yep, sorts with the | prefix and everything ¯\_(ツ)_/¯
        if not skipDivider then
            -- Don't forget to add them back in!
            table.insert(lines, 1, divider)
            table.insert(lines, 1, header)
        end
    end

    return lines
end