local Field = require('Field')
local lookup = require('lookup')


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
    Field:new("position"),
    Field:new("drop_position"),
    Field:new{name="pickup_position", requires_type="inserter"},
    Field:new{name="associated_player", value=function(entity)
        return (
            entity.type == 'character'
            and ((entity.type.associated_player and entity.type.associated_player.name) or '**none**')
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
            if #flags then
                return flags
            else
                return "**none**"
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
            attrs = table.concat(attrs, ", ")
            if #attrs then
                return attrs
            else
                return "**none**"
            end
        end
    },

    Field:new{
        name="recipe", requires_type={"assembling-machine", "furnace"},
        value=function(entity)
            local recipe = entity.get_recipe()
            return recipe and recipe.name or "**none**"
        end
    },

    Field:new{name="force", value=function(entity) if entity.force then return entity.force.name end end},
    Field:new{name="amount", requires_type="resource"},
    Field:new{name="initial_amount", requires_type="resource"},
    Field:new{name="signal_state", requires_type="rail-signal", lookup=lookup.signal_state},
    Field:new{name="chain_signal_state", requires_type="rail-chain-signal", lookup=lookup.chain_signal_state},
}

return entity_fields
