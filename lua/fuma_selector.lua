local fuma_selector = {}
local config = nil
local page_size = nil
local kRejected = 0
local kAccepted = 1
local kNoop = 2

local function select_candidate(ctx, candidate, idx)
    if candidate ~= nil and string.match(candidate.comment, '^;%w%w?$') ~= nil then
        local fuma_len = string.len(candidate.comment) - 1
        if idx == nil then
            ctx:confirm_current_selection()
        else
            ctx:select(idx)
        end
        ctx:pop_input(fuma_len)
        if ctx.composition:has_finished_composition() then
            ctx:commit()
        end
        return kAccepted
    end
    return kNoop
end

function fuma_selector.init(env)
    config = env.engine.schema.config
    page_size = (config:get_string('menu/page_size') + 0) // 1 % 10
end

function fuma_selector.fini(env)
end

function fuma_selector.func(key_event, env)
    local ctx = env.engine.context
    if key_event:shift() or key_event:ctrl() or key_event:alt() or key_event:super() or key_event:release() then
        return kNoop
    end
    if not ctx:has_menu() or not ctx:is_composing() then
        return kNoop
    end
    local segment = ctx.composition:back()
    local key_pressed = key_event:repr()
    if key_pressed == 'space' then
        local candidate = ctx:get_selected_candidate()
        if select_candidate(ctx, candidate, nil) == kAccepted then return kAccepted end
    end
    if key_pressed >= '1' and key_pressed <= tostring(page_size) then
        local composition = ctx.composition
        local highlighted_idx = composition:back().selected_index
        local page_start = (highlighted_idx // page_size) * page_size
        local selected_idx = page_start + (key_pressed - 1)
        local candidate = composition:back():get_candidate_at(selected_idx)
        if select_candidate(ctx, candidate, selected_idx) == kAccepted then return kAccepted end
    end
    return kNoop
end

return fuma_selector
