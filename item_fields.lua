local Field = require('field')
local lookup = require('lookup')
local techdata = require('techdata')

local function protoname(k)
    function fn(entity)
        return entity.prototype[k] and entity.prototype[k].name or nil
    end
    return fn
end


local item_fields = {
    Field:new("name"),
    Field:new("type"),
    Field:new("count"),
    Field:new{name="stack_size", use_prototype=true},
    Field:new("health"),
    Field:new("durability"),
    Field:new{name="ammo", hide_on_error=true},
    Field:new("label"),
    Field:new{name="label_color", value=function(item)
        local c = item.label_color
        if c then
            return string.format("(r=%.2f, g=%.2f, b=%.2f, a=%.2f)", c.r, c.g, c.b, c.a)
        end
    end},
    Field:new{name="category", use_prototype=true},
    Field:new{name="tier", use_prototype=true},
    Field:new{name="speed", use_prototype=true},
    Field:new{name="attack_range", use_prototype=true},
    Field:new{name="build_distance_bonus", use_prototype=true},
    Field:new{name="item_drop_distance_bonus", use_prototype=true},
    Field:new{name="reach_distance_bonus", use_prototype=true},
    Field:new{name="item_pickup_distance_bonus", use_prototype=true},
    Field:new{name="loot_pickup_distance_bonus", use_prototype=true},
    Field:new{name="group", value=protoname('group')},
    Field:new{name="subgroup", value=protoname('subgroup')},
    Field:new{name="order", use_prototype=true},
    Field:new{name="place_result", value=protoname('place_result')},
    Field:new{name="place_as_equipment_result", value=protoname('place_as_equipment_result')},
    Field:new{name="place_as_tile_result", value=protoname('place_as_tile_result')},

    Field:new{
        name="flags", label="Flags",
        value=function(item)
            local proto = item.prototype
            local flags = {}
            local k
            for i=1, #lookup.item_prototype_flags do
                k = lookup.item_prototype_flags[i]
                if proto.has_flag(k) then table.insert(flags, k) end
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
        value=function(item)
            local attrs = {}
            local k
            for i=1, #lookup.item_attribute_values do
                k = lookup.item_attribute_values[i]
                local ok, result = pcall(function() return item[k] end)
                if ok and result then table.insert(attrs, k) end
            end
            if item.is_blueprint and item.is_blueprint_setup() then
                table.insert(attrs, "is_blueprint_setup")
            end

            attrs = table.concat(attrs, ", ")
            if #attrs > 0 then
                return attrs
            else
                return "-none-"
            end
        end
    },
    Field:new{
        name="proto_attributes", label="Prototype Attributes",
        value=function(item)
            local proto = item.prototype
            local attrs = {}
            local k
            for i=1, #lookup.item_prototype_attribute_values do
                k = lookup.item_prototype_attribute_values[i]
                local ok, result = pcall(function() return entity[k] end)
                if ok and result then table.insert(attrs, k) end
            end

            attrs = table.concat(attrs, ", ")
            if #attrs > 0 then
                return attrs
            else
                return "-none-"
            end
        end
    },
    Field:new{name="technology", label="Technology", value=function(item) return techdata.items[item.name] end},
}

return item_fields
