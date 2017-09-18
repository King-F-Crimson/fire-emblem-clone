require("utility")

function generate_path(destination_tile, movement_tiles)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    local path = {}

    local current_tile = destination_tile

    while current_tile.come_from ~= "origin" do
        table.insert(path, current_tile)

        current_tile = movement_tiles[key(current_tile.come_from.x, current_tile.come_from.y)]
    end

    -- Insert the final tile, which is the origin tile.
    table.insert(path, current_tile)

    return reverse_table(path)
end