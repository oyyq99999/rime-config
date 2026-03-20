local kRejected = 0
local kAccepted = 1
local kNoop = 2

local function select_candidate(ctx, candidate, idx)
    if candidate == nil then return kNoop end

    -- 获取候选词的“真身”
    -- 这样即使是被 emoji 滤镜包装过的词，也能拿到原始的 fuma 注释
    local genuine = candidate:get_genuine()

    if genuine.comment ~= nil and string.match(genuine.comment, '^;%w%w?$') ~= nil then
        local fuma_len = string.len(genuine.comment) - 1

        if idx == nil then
            ctx:confirm_current_selection()
        else
            ctx:select(idx)
        end

        -- 此时即使上屏的是 😄，剩下的辅码输入也会被正确清理
        ctx:pop_input(fuma_len)

        if ctx.composition:has_finished_composition() then
            ctx:commit()
        end
        return kAccepted
    end
    return kNoop
end

local function fuma_selector(key_event, env)
    local page_size = (env.engine.schema.config:get_string('menu/page_size') + 0) // 1 % 10
    local ctx = env.engine.context
    if key_event:shift() or key_event:ctrl() or key_event:alt() or key_event:super() or key_event:release() then
        return kNoop
    end
    if not ctx:has_menu() or not ctx:is_composing() then
        return kNoop
    end

    local key_pressed = key_event:repr()
    if key_pressed == 'space' then
        local candidate = ctx:get_selected_candidate()
        if select_candidate(ctx, candidate, nil) == kAccepted then return kAccepted end
    end

    if key_pressed >= '1' and key_pressed <= tostring(page_size) then
        local composition = ctx.composition
        local seg = composition:back()
        local highlighted_idx = seg.selected_index
        local page_start = (highlighted_idx // page_size) * page_size
        local selected_idx = page_start + (key_pressed - '1')
        local candidate = seg:get_candidate_at(selected_idx)
        if select_candidate(ctx, candidate, selected_idx) == kAccepted then return kAccepted end
    end
    return kNoop
end

return fuma_selector
