--
-- Created by IntelliJ IDEA.
-- User: Daniel
-- Date: 10/24/2018
-- Time: 8:22 PM
-- To change this template use File | Settings | File Templates.
--

local function invert_table(t)
    local result = {}
    for k, v in pairs(t) do
        if result[v] then
            result[v] = result[v] .. "; " .. k
        else
            result[v] = k
        end
    end
    return result
end

local lookup = {
    entity_prototype_flags = {
        "not-rotatable",
        "placeable-neutral",
        "placeable-player",
        "placeable-enemy",
        "placeable-off-grid",
        "player-creation",
        "building-direction-8-way",
        "filter-directions",
        "fast-replaceable-no-build-while-moving",
        "breaths-air",
        "not-repairable",
        "not-on-map",
        "not-deconstructable",
        "not-blueprintable",
        "hide-from-bonus-gui",
        "hide-alt-info",
        "fast-replaceable-no-cross-type-while-moving",
        "no-gap-fill-while-building",
        "not-flammable",
    },
    directions = invert_table(defines.direction),
    entity_attribute_functions = {"has_command", "is_crafting", "is_opened", "is_opening", "is_closed", "is_closing"},
    entity_attribute_values = {"active", "destructible", "minable", "rotatable", "operable", "armed"},
    signal_state = invert_table(defines.signal_state),
    chain_signal_state = invert_table(defines.chain_signal_state),
    item_attribute_values = {
        "is_blueprint", "is_blueprint_book", "is_module", "is_tool", "is_mining_tool", "is_armor", "is_repair_tool",
        "is_item_with_label", "is_item_with_inventory", "is_item_with_entity_data", "is_selection_tool",
        "is_item_with_tags", "is_deconstruction_item"
    },
    item_prototype_attribute_values = { "stackable", "can_be_mod_opened" },
    item_prototype_flags = { "goes-to-main-inventory", "goes-to-quickbar", "hidden" }
}

return lookup
