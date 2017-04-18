browsing = {}
moving = {}
action_menu_control = {}
attacking = {}

function browsing.process_feedback(ui, feedback)
    -- Select a tile which could contain controllable unit to select it.
    -- Later could also be enemy unit to toggle area, or special tile to get information.
    if feedback.action == "select" then
        local unit = ui.world:get_unit(feedback.data.tile_x, feedback.data.tile_y)
        -- Check if unit is not nil.
        if unit then
            ui.selected_unit = unit
            ui:create_movement_area()

            -- Change to moving unit state.
            ui.state = moving
        end
    end
end

function moving.process_feedback(ui, feedback)
    -- Select a tile where the selected unit would be moved to.
    if feedback.action == "select" then
        -- Check if cursor is in movement area.
        if ui:is_in_movement_area(feedback.data.tile_x, feedback.data.tile_y) then
            -- Set planned position.
            ui.plan_tile_x, ui.plan_tile_y = feedback.data.tile_x, feedback.data.tile_y

            -- Delete movement area.
            ui.move_area = nil

            -- Construct action menu and set it into active input.
            ui:create_action_menu(feedback.data.tile_x, feedback.data.tile_y)
            ui.active_input = "action_menu"

            -- Set state to action menu control.
            ui.state = action_menu_control
        end
    end

    if feedback.action == "cancel" then
        -- Revert cursor position to original unit position.
        ui.cursor.tile_x, ui.cursor.tile_y = ui.selected_unit.tile_x, ui.selected_unit.tile_y

        -- Deselect unit.
        ui.selected_unit = nil

        -- Delete movement area.
        ui.move_area = nil

        ui.state = browsing
    end
end

function action_menu_control.process_feedback(ui, feedback)
    if feedback.action == "wait" then
        -- Construct command to move unit for world.
        local command = { action = "move_unit" }
        command.data = { unit = ui.selected_unit, tile_x = ui.plan_tile_x, tile_y = ui.plan_tile_y }
        ui.world:receive_command(command)

        -- Cleanup.
        ui.action_menu = nil
        ui.selected_unit = nil

        -- Setup for browsing.
        ui.active_input = "cursor"
        ui.state = browsing
    end

    if feedback.action == "attack" then
        -- Cleanup.
        ui.active_input = "cursor"
        ui.action_menu = nil

        -- Setup for attacking.
        ui.state = attacking
    end

    if feedback.action == "cancel" then
        -- Unset planned position.
        ui.plan_tile_x, ui.plan_tile_y = nil

        -- Delete action menu.
        ui.action_menu = nil

        -- Create movement area.
        ui:create_movement_area()

        -- Set cursor to the active input
        ui.active_input = "cursor"
        ui.state = moving
    end
end

function attacking.process_feedback(ui, feedback)
    -- Attack position.
    if feedback.action == "select" then
        -- Push command to world to move then attack.
        local move_command = { action = "move_unit" }
        move_command.data = { unit = ui.selected_unit, tile_x = ui.plan_tile_x, tile_y = ui.plan_tile_y }
        ui.world:receive_command(move_command)

        local attack_command = { action = "attack" }
        attack_command.data = { attacking_unit = ui.selected_unit, target_tile_x = feedback.data.tile_x, target_tile_y = feedback.data.tile_y }
        ui.world:receive_command(attack_command)

        -- Revert to moving state.
        ui.state = moving
    end

    if feedback.action == "cancel" then
        -- Construct action menu and set it into active input.
        ui:create_action_menu(feedback.data.tile_x, feedback.data.tile_y)
        ui.active_input = "action_menu"

        -- Set state to action menu control.
        ui.state = action_menu_control
    end
end