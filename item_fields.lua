local Field = require('Field')
local lookup = require('lookup')


local item_fields = {
    Field:new("name"),
    Field:new("type"),
    Field:new("count"),
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
    Field:new{
        name="attributes", label="Attributes",
        value=function(entity)
            local attrs = {}
            local k
            for i=1, #lookup.item_attribute_values do
                k = lookup.item_attribute_values[i]
                local ok, result = pcall(function() return entity[k] end)
                if ok and result then table.insert(attrs, k) end
            end
--            for i=1, #lookup.item_attribute_functions do
--                k = lookup.item_attribute_functions[i]
--                local ok, result = pcall(function() return entity[k]() end)
--                if ok and result then table.insert(attrs, k) end
--            end
            attrs = table.concat(attrs, ", ")
            if #attrs then
                return attrs
            else
                return "**none**"
            end
        end
    },
}

return item_fields
