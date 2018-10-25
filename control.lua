--local Field = require("field")
--local lookup = require("lookup")
local gui = require("gui")
local selected_entity_frame = gui.EntityFrame:new("MDTSelectedEntity")
local cursor_stack_frame = gui.ItemFrame:new("MDTCursorStack")

local entity_events = {
    defines.events.on_selected_entity_changed,
    defines.events.on_player_rotated_entity,
    defines.events.on_entity_damaged,
    defines.events.on_entity_died,
    defines.events.on_entity_renamed,
    defines.events.on_entity_settings_pasted,
    defines.events.on_forces_merged,
    defines.events.on_land_mine_armed,
    defines.events.on_trigger_created_entity,
}


function table.is_empty(t)
    for _, _ in pairs(t) do
        return false
    end
    return true
end


local function entity_updated(entity)
    local player
    local selected
    for index,_ in pairs(global.entity_watchers) do
        player = game.players[index]
        selected = player.selected
        if not entity or entity == selected then
            selected_entity_frame:update(player, selected)
        end
    end
end


local function enable_events()
    script.on_event(entity_events, function(event) entity_updated(event.entity) end)
    script.on_event(defines.events.on_selected_entity_changed, function(event)
        if not global.entity_watchers[event.player_index] then return end
        local player = game.players[event.player_index]
        selected_entity_frame:update(player, player.selected)
--        local player = game.players[event.player_index]
--        local frame = mod_gui.get_frame_flow(player).MDTSelectedEntityWindow
--        update_entity_window(frame, player.selected)
    end)
    script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
        if not global.entity_watchers[event.player_index] then return end
        local player = game.players[event.player_index]
        local stack = player.cursor_stack
        cursor_stack_frame:update(player, stack.valid and stack.valid_for_read and stack or nil)
    end)

    log("[ModDeveloperTools] Now listening for entity events.")
end


local function disable_events()
    script.on_event(entity_events, nil)
    script.on_event(defines.events.on_player_cursor_stack_changed, nil)
    log("[ModDeveloperTools] No longer listening for entity events.")
end


local function toggle_debug(player, toggle)
    local watchers = global.entity_watchers
    local prev = watchers[player.index] or false
    if toggle == nil then toggle = not prev end
    if toggle ~= prev then
        if toggle then
            if table.is_empty(watchers) then
                enable_events()
            end
            watchers[player.index] = true
            selected_entity_frame:create(player, player.selected)
            cursor_stack_frame:create(
                player,
                player.cursor_stack.valid and player.cursor_stack.valid_for_read and player.cursor_stack
            )
        else
            selected_entity_frame:destroy(player)
            cursor_stack_frame:destroy(player)
            watchers[player.index] = nil
            if table.is_empty(global.entity_watchers) then
                disable_events()
            end
        end
    end

    return prev
end


-- Catch our keybinding
script.on_event("ModDeveloperTools-toggle", function(event)
    toggle_debug(game.players[event.player_index])
end)


-- Housekeeping

-- Initialize globals on init.
script.on_init(function()
    global.entity_watchers = {}
    global.offline_entity_watchers = {}
    for _,player in pairs(game.players) do
        toggle_debug(player, true)  -- Default windows to visible, since this is a debugging mod.
    end
end)

-- When players are removed, forget about them as watchers.
script.on_event(defines.events.on_player_removed, function(event)
    global.entity_watchers[event.player_index] = nil
    if table.is_empty(global.entity_watchers) then
        disable_events()
    end
end)

-- When players leave the game, save their 'watching' state and then unsubscribe them to save work.
script.on_event(defines.events.on_player_left_game, function(event)
    local index = event.player_index
    global.offline_entity_watchers[index] = toggle_debug(game.players[index], false)
end)

-- When players join the game, restore their previous watching state.
script.on_event(defines.events.on_player_joined_game, function(event)
    local index = event.player_index
    toggle_debug(game.players[index], offline_entity_watchers[index] ~= false)
    global.offline_entity_watchers[index] = nil
end)
