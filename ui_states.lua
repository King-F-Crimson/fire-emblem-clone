require("utility")

browsing = {}
moving = {}
menu_control = {}
attacking = {}

function browsing.process_feedback(ui, feedback)
    -- Select a tile which could contain controllable unit to select it.
    -- Later could also be enemy unit to toggle area, or special tile to get information.
    if feedback.action == "select" then
        local unit = ui.world:get_unit(feedback.data.tile_x, feedback.data.tile_y)
        -- Check if unit is not nil.
        if unit then
            -- If unit is player unit and has not moved, select it.
            if unit.data.team == ui.game.current_turn and not unit.data.moved then
                ui.selected_unit = unit
                ui.selected_unit.hidden = true

                moving.enter(ui)
            -- If it's an enemy unit then toggle it in marked_units
            -- to mark it's possible attack position.
            elseif unit.data.team ~= ui.game.current_turn then
                if ui.marked_units[unit] then
                    ui.marked_units[unit] = nil
                else
                    ui.marked_units[unit] = true
                end

                -- Regenerate danger area.
                ui:generate_danger_area()
            end
        -- If there's no unit, then open a menu to end the turn.
        else
            menu_control.enter(ui, "turn")
        end
    end
end

function browsing.enter(ui)
    if ui.selected_unit then
        ui.selected_unit.hidden = false
    end
    ui.selected_unit = nil

    ui.plan_tile_x, ui.plan_tile_y = nil

    ui.menu = nil
    ui.active_input = "cursor"

    ui.state = browsing
end

function moving.process_feedback(ui, feedback)
    -- Select a tile where the selected unit would be moved to.
    if feedback.action == "select" then
        -- Check if cursor is in movement area and there's no other unit in the tile, or the unit stays in its initial position.
        if ui:is_in_area("move", feedback.data.tile_x, feedback.data.tile_y) and
            (ui.world:get_unit(feedback.data.tile_x, feedback.data.tile_y) == nil or
            ui.world:get_unit(feedback.data.tile_x, feedback.data.tile_y) == ui.selected_unit) then
            -- Set planned position.
            ui.plan_tile_x, ui.plan_tile_y = feedback.data.tile_x, feedback.data.tile_y

            menu_control.enter(ui, "action")
        end
    end

    if feedback.action == "cancel" then
        -- Revert cursor position to original unit position.
        ui.cursor:move_to(ui.selected_unit.tile_x, ui.selected_unit.tile_y)

        browsing.enter(ui)
    end
end

function moving.enter(ui)
    ui.plan_tile_x, ui.plan_tile_y = nil

    ui.menu = nil
    ui.active_input = "cursor"

    ui:create_area("move")

    ui.state = moving
end

function menu_control.process_feedback(ui, feedback)
    if feedback.action == "wait" then
        -- Construct command to move unit for world.
        local command = { action = "move_unit" }
        command.data = { unit = ui.selected_unit, tile_x = ui.plan_tile_x, tile_y = ui.plan_tile_y }
        ui.world:receive_command(command)

        browsing.enter(ui)
    end

    if feedback.action == "attack" then
        -- Make attack unselectable when selected unit has no weapon.
        print(ui.selected_unit.data.weapons)
        if not is_empty(ui.selected_unit.data.weapons) then
            attacking.enter(ui)
        end
    end

    if feedback.action == "cancel" then
        -- Return to previous state based on the menu type.
        if ui.menu.menu_type == "action" then
            moving.enter(ui)
        elseif ui.menu.menu_type == "turn" then
            browsing.enter(ui)
        end
    end

    if feedback.action == "end_turn" then
        ui.game:new_turn()

        browsing.enter(ui)
    end
end

function menu_control.enter(ui, menu_type)
    ui.areas.move = nil

    ui:create_menu(menu_type)
    ui.active_input = "menu"

    ui.state = menu_control
end

function attacking.process_feedback(ui, feedback)
    -- Attack position.
    if feedback.action == "select" then
        if ui:is_in_area("attack", feedback.data.tile_x, feedback.data.tile_y) then
            -- Push command to world to move then attack.
            local move_command = { action = "move_unit" }
            move_command.data = { unit = ui.selected_unit, tile_x = ui.plan_tile_x, tile_y = ui.plan_tile_y }
            ui.world:receive_command(move_command)

            local attack_command = { action = "attack" }
            attack_command.data = { unit = ui.selected_unit, tile_x = feedback.data.tile_x, tile_y = feedback.data.tile_y }
            ui.world:receive_command(attack_command)

            -- Put cursor in the attacking unit position.
            ui.cursor:move_to(ui.plan_tile_x, ui.plan_tile_y)

            -- Revert to browsing state.
            browsing.enter(ui)
        end
    end

    if feedback.action == "cancel" then
        -- Move cursor position to planned movement position.
        ui.cursor:move_to(ui.plan_tile_x, ui.plan_tile_y)

        -- Set state to action menu control.
        menu_control.enter(ui, "action")
    end
end

function attacking.enter(ui)
    ui.menu = nil
    ui.active_input = "cursor"

    ui:create_area("attack")

    ui.state = attacking
end