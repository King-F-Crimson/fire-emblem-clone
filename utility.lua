-- Copy everything, including nested tables.
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Print everything, including nested tables.
function table_print (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
        for key, value in pairs (tt) do
            io.write(string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                io.write(string.format("[%s] => table\n", tostring (key)));
                io.write(string.rep (" ", indent+4)) -- indent it
                io.write("(\n");
                table_print (value, indent + 7, done)
                io.write(string.rep (" ", indent+4)) -- indent it
                io.write(")\n");
            else
                io.write(string.format("[%s] => %s\n",
                        tostring (key), tostring(value)))
            end
        end
    else
        io.write(tt .. "\n")
    end
end

-- Print everything, but non recursively.
function print_all(table)
    for k, v in pairs(table) do print(k, v) end
end

-- Check if table is empty.
function is_empty(table)
    for _ in pairs(table) do
        return false
    end
    return true
end

-- Reverse table.
function reverse_table(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end