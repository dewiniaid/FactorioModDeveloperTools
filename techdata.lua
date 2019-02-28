-- Compute what recipes unlock which items (and which entities...)

local item_techs = {}
local entity_techs = {}
local cache = {
    items = item_techs,
    entities = entity_techs
}
local initialized = false


local function stringify(t)
    result = {}
    for name, _ in pairs(t) do
        result[#result + 1] = name
    end
    return table.concat(result, ", ")
end


function initialize_tech_data()
    if initialized then return end
    local meta = {
        __index = function(t, k)
            t[k] = {}
            return t[k]
        end
    }
    setmetatable(item_techs, meta)
    setmetatable(entity_techs, meta)

    local recipes = game.recipe_prototypes
    local items = game.item_prototypes

    -- Find techs that unlock items.
    for techname, proto in pairs(game.technology_prototypes) do
        for _, mod in pairs(proto.effects) do
            if mod.type == "give-item" then
                item_techs[mod.item][techname .. "(give-item:" .. (mod.count or 1) .. ")"] = true
            elseif mod.type == "unlock-recipe" then
                local recipe = recipes[mod.recipe]
                if recipe then
                    for _, product in pairs(recipe.products) do
                        if product.type == 'item' then
                            item_techs[product.name][techname] = true
                        end
                    end
                end
            end
        end
    end

    -- Techs don't unlock entities, but they unlock items that can be placed.  Figure this out.
    -- Stringify items while we're going through this pass of the table.
    for itemname, techs in pairs(item_techs) do
        local proto = items[itemname]
        if proto.place_result then
            local entity = proto.place_result
            local t = entity_techs[entity.name]
            local suffix = (entity.items_to_place_this and #entity.items_to_place_this > 1)
            for techname, _ in pairs(techs) do
                if suffix then
                    t[techname .. "(" .. itemname .. ")"] = true
                else
                    t[techname] = true
                end
            end
        end
        item_techs[itemname] = stringify(techs)
    end

    -- Stringify entity techs
    for k, v in pairs(entity_techs) do
        entity_techs[k] = stringify(v)
    end

    -- Remove no-longer-needed metatables
    setmetatable(item_techs, nil)
    setmetatable(entity_techs, nil)

    initialized = true
end


local function make_lazy_table(key)
    local t = {}
    local function fn(t, k)
        initialize_tech_data()
        setmetatable(t, {__index = cache[key]})
    end
    setmetatable(t, {__index = fn})
    return t
end


local techdata = {
    items = make_lazy_table('items'),
    entities = make_lazy_table('entities')
}


return techdata


