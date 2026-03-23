local kRejected = 0
local kAccepted = 1
local kNoop = 2

local function punct_after_digit(key_event, env)
    if key_event:shift() or key_event:ctrl() or key_event:alt() or key_event:super() then
        return kNoop
    end

    if key_event:release() then
        return kNoop
    end

    local ctx = env.engine.context
    if ctx:is_composing() or ctx:get_option("ascii_mode") then -- 有未上屏的编码，英文模式
        return kNoop
    end

    local key_pressed = key_event.keycode
    local chars = {
        [47] = "/"
    }
    if chars[key_pressed] then
        local last_ch = ctx.commit_history:back()
        if last_ch and last_ch.text:match("%d$") then
            env.engine:commit_text(chars[key_pressed])
            ctx:clear()
            return kAccepted
        end
    end
    return kNoop
end

return punct_after_digit
