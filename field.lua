local Field = {
    label_style="description_label",
    value_style="description_value_label",
    error_style="invalid_label"
}
Field.__meta = { __index = Field }
--setmetatable(Field, Field.__meta)


function Field._always_true() return true end


function Field:_generate_getter(k)
    return loadstring("return function(o) return o." .. k .. " end")()
end

--[[
Handles formatting and display of a field.

Field("name") is equivalent to Field{name="name"})

Options can include:
name    Name of field.  The only required option.
label   Localized name of field.  Defaults to the same 'name' if omitted.
use_prototype  If true, this field is on the prototype rather than the object.
visible function(object, field_definition) that returns true if the field should be displayed.
value   function(object, field_definition) that returns the field's value.
skip_pcall  If true, don't use pcall when evaluating visible/value
hide_on_error   If true and the value function raises an error, hide this field instead of displaying **Error**
lookup  If set, the returned value is something to be looked up in this table.


If `visible` is omitted, the field is always visible unless `value` states otherwise.
If `value` is omitted, the value is object[name]
If `value` is a function that returns nil, the field is hidden.
]]
function Field:new(source, label)
    if type(source) ~= 'table' then
        return self:new({name=source, label=label})
    end

    assert(source.name)

    -- Shouldn't need to deepcopy, so this is faster.
    local opts = {
        name = source.name,
        label = source.label or source.name,
        gui_name = source.gui_name or ("Field_" .. source.name),
        visible = source.visible or self._always_true,
        value = source.value,
        use_prototype = source.use_prototype or false,
        skip_pcall = source.skip_pcall or false,
        hide_on_error = source.hide_on_error or false,
    }

    if not opts.value then
        if opts.lookup then
            opts.value = function(o)
                local v = o[name]
                if v == nil then return end
                return v .. " (" .. (opts.lookup[v] or "**undefined**") .. ")"
            end
        else
            opts.value = self:_generate_getter(source.name)
        end
    end

    if source.requires_type then

        if type(source.requires_type) == 'table' then
            opts.requires_type = {}
            for _,k in pairs(source.requires_type) do
                opts.requires_type[k] = true
            end
        else
            opts.requires_type = {[source.requires_type] = true}
        end
    end

    setmetatable(opts, self.__meta)
    return opts
end

function Field:create_gui(parent)
    local flow = parent.add{type="flow", direction="horizontal", name=self.gui_name, style="slot_table_spacing_horizontal_flow" }
    local label
--    flow.style.top_padding = 0
--    flow.style.bottom_padding = 0
    label = flow.add{name="FieldName", type="label", caption={"", self.label, ": "}, style=self.label_style }
--    label.style.top_padding = 0
--    label.style.bottom_padding = 0
    label = flow.add{name="FieldValue", type="label", caption="**Not Initialized**", style=self.error_style }
--    label.style.top_padding = 0
--    label.style.bottom_padding = 0
    return flow
end


function Field:_get_gui_value(object)
    if not self.visible(object, self) then return nil end
    return self.value(object, self)
end


function Field:update_gui(parent, object)
    if self.use_prototype then
        object = object.prototype
    end

    local flow = parent[self.gui_name]
    if not flow then
        flow = self:create_gui(parent)
    end
    local ok, caption, style_override
    if self.requires_type and not self.requires_type[object.type] then
        ok = true
        caption = nil
    else
        if self.skip_pcall then
            ok = true
            caption, style_override = self:_get_gui_value(object)
        else
            ok, caption, style_override = pcall(self._get_gui_value, self, object)
            if self.hide_on_error and not ok then
                caption = nil
                ok = true
            end
        end
    end

    if not ok then
        flow.visible = true
        flow.FieldValue.style = self.error_style
        flow.FieldValue.caption = "**Error**"
    elseif caption == nil then
        flow.visible = false
    else
        flow.visible = true
        flow.FieldValue.style = style_override or self.value_style
        flow.FieldValue.caption = caption
    end
end


function Field:destroy_gui(parent)
    if parent[self.gui_name] then parent[self.gui_name].destroy() end
end


return Field