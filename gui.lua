require("mod-gui")
techdata = require("techdata")

local InfoFrame = {}
InfoFrame.__meta = { __index = InfoFrame }


function InfoFrame:new(opts, caption)
    if type(opts) ~= 'table' then return self:new{name=opts, caption=caption } end
    assert(opts.name)

    local result = {
        name = opts.name,
        caption = opts.caption or {"ModDeveloperTools." .. opts.name .. "_caption"}
    }
    setmetatable(result, self.__meta)
    return result
end


function InfoFrame:new_subclass(t)
    local result = t or {}
    result.__meta = { __index = result }
    setmetatable(result, self.__meta)
    return result
end


function InfoFrame:get(player)
    return mod_gui.get_frame_flow(player)[self.name]
end


function InfoFrame:destroy(player)
    local f = mod_gui.get_frame_flow(player)[self.name]
    if f then f.destroy() end
end


function InfoFrame:create(player, object)
    local flow = mod_gui.get_frame_flow(player)
    local frame = flow[self.name]

    -- Destroy existing frame, if present.
    if frame then
        frame.destroy()
    end

    frame = flow.add {
        type = "frame", name = self.name, caption = self.caption, direction = "vertical",
        ignored_by_interaction = true,
    }

    frame.add { type="label", name = "Title", style="large_caption_label" }

    local subflow = frame.add { name="Subflow", type="flow", direction="vertical", style="slot_table_spacing_vertical_flow"}
    for _, field in pairs(self.fields) do
        field:create_gui(subflow)
    end

    return self:update_frame(frame, object)
end


function InfoFrame:update(player, object)
    -- Probably not a proper fix but it'll do for now.
    local f = self:get(player)
    if f then
        return self:update_frame(self:get(player), object)
    end
    return self:create(player, object)
end


function InfoFrame:update_frame(frame, object)
    if not object then
        frame.visible = false
        return
    end
    frame.visible = true
    frame.Title.caption = self.get_title(object)
    local subflow = frame.Subflow
    for _, field in pairs(self.fields) do
        field:update_gui(subflow, object)
    end
end


local EntityFrame = InfoFrame:new_subclass{
    fields = require('entity_fields'),
    --get_title = function(object) return object.localised_name end,
    get_title = function(object) return {"", "[entity=" .. object.name .. "]", object.localised_name} end,
}

local ItemFrame = InfoFrame:new_subclass{
    fields = require('item_fields'),
    get_title = function(object) return {"", "[item=" .. object.name .. "]", object.prototype.localised_name} end,
}


local gui = {
    InfoFrame = InfoFrame,
    EntityFrame = EntityFrame,
    ItemFrame = ItemFrame
}

return gui
