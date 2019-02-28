local Field = require('field')
local lookup = require('lookup')
local techdata = require('techdata')

local function protoname(k)
    function fn(entity)
        return entity.prototype[k] and entity.prototype[k].name or nil
    end
    return fn
end

local entity_fields = {
    Field:new("name"),
    Field:new("type"),
    Field:new{name="ghost_name", requires_type={"tile-ghost", "entity-ghost"}},
    Field:new{name="ghost_type", requires_type={"tile-ghost", "entity-ghost"}},
    Field:new{
        name="direction",
        value=function(entity)
            local dir = entity.direction
            if entity.supports_direction then
                return dir .. " (" .. lookup.directions[dir] .. ")"
            else
                return dir .. " (not supported)"
            end
        end
    },
    Field:new{
        name="orientation",
        value=function(entity)
            return (not entity.supports_direction) and entity.orientation or nil
        end
    },
    Field:new{name="cliff_orientation", requires_type="cliff"},
    Field:new{name="group", value=protoname('group')},
    Field:new{name="subgroup", value=protoname('subgroup')},
    Field:new{name="order", use_prototype=true},
    Field:new{name="fast_replaceable_group", use_prototype=true},
    Field:new("position"),
    Field:new("drop_position"),
    Field:new{name="pickup_position", requires_type="inserter"},
    Field:new{name="belt_speed", value=function(entity)
        local s = entity.prototype.belt_speed
        if s ~= nil then
            return s .. "  (" .. (s*480) .. " Items/s)"
        end
    end},
    Field:new{name="associated_player", value=function(entity)
        return (
            entity.type == 'character'
            and ((entity.type.associated_player and entity.type.associated_player.name) or '-none-')
            or nil
        ) end
    },
    Field:new{
        name="splitter_filter",
        value=function(entity)
            return (entity.type == 'splitter' and entity.splitter_filter and entity.splitter_filter.name) or nil
        end
    },
    Field:new{name="splitter_input_priority", requires_type="splitter"},
    Field:new{name="splitter_output_priority", requires_type="splitter"},
    Field:new{
        name="flags", label="Flags",
        value=function(entity)
            local flags = {}
            local k
            for i=1, #lookup.entity_prototype_flags do
                k = lookup.entity_prototype_flags[i]
                if entity.has_flag(k) then table.insert(flags, k) end
            end
            flags = table.concat(flags, ", ")
            if #flags > 0 then
                return flags
            else
                return "-none-"
            end
        end
    },

    Field:new{
        name="attributes", label="Attributes",
        value=function(entity)
            local attrs = {}
            local k
            for i=1, #lookup.entity_attribute_values do
                k = lookup.entity_attribute_values[i]
                local ok, result = pcall(function() return entity[k] end)
                if ok and result then table.insert(attrs, k) end
            end
            for i=1, #lookup.entity_attribute_functions do
                k = lookup.entity_attribute_functions[i]
                local ok, result = pcall(function() return entity[k]() end)
                if ok and result then table.insert(attrs, k) end
            end
            if #attrs > 0 then
                return table.concat(attrs, ", ")
            else
                return "-none-"
            end
        end
    },

    Field:new {
        name = "collision_mask", value = function(entity)
            local m = entity.prototype.collision_mask
            if not m then
                return "-none-"
            end
            local attrs = {}
            for k, v in pairs(m) do
                if v then
                    attrs[1 + #attrs] = k
                end
            end
            if #attrs > 0 then
                return table.concat(attrs, ", ")
            else
                return "-none-"
            end
        end
    },

    Field:new{
        name="recipe", requires_type={"assembling-machine", "furnace"},
        value=function(entity)
            local recipe = entity.get_recipe()
            return recipe and recipe.name or "-none-"
        end
    },

    Field:new{
        name="connected_rail", requires_type={"straight-rail", "curved-rail"},
        value=function(entity)
            local output = {}
            local neighbor
            for first_letter, rail_direction in pairs({
                F = defines.rail_direction.front,
                B = defines.rail_direction.back
            }) do
                output_line = {}
                for second_letter, rail_connection_direction in pairs({
                    L = defines.rail_connection_direction.left,
                    S = defines.rail_connection_direction.straight,
                    R = defines.rail_connection_direction.right
                }) do
                    neighbor = entity.get_connected_rail{rail_direction=rail_direction, rail_connection_direction=rail_connection_direction }
                    if neighbor then
                        table.insert(output, first_letter .. second_letter .. "=" .. neighbor.unit_number)
                    end
                end
            end
            if #output then
                return table.concat(output, ", ")
            end
        end
    },

    Field:new{name="force", value=function(entity) if entity.force then return entity.force.name end end},
    Field:new{name="unit_number"},
    Field:new{name="amount", requires_type="resource"},
    Field:new{name="initial_amount", requires_type="resource"},
    Field:new{name="signal_state", requires_type="rail-signal", lookup=lookup.signal_state},
    Field:new{name="chain_signal_state", requires_type="rail-chain-signal", lookup=lookup.chain_signal_state},
    Field:new{name="technology", label="Technology", value=function(entity) return techdata.entities[entity.name] end},
}

return entity_fields
