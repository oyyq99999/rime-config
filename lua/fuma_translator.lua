local fuma_translator = {}

local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then return true end
    end
    return false
end

local function compare(c1, c2, odd)
    -- local l1 = utf8.len(c1.text)
    -- local l2 = utf8.len(c2.text)

    -- 通过判断 comment 是否带有 ';' 来识别辅码词条，而不是判断 type
    local is_fuma1 = (c1.comment and string.match(c1.comment, '^;%w%w?$')) and true or false
    local is_fuma2 = (c2.comment and string.match(c2.comment, '^;%w%w?$')) and true or false

    -- local type_order = {'sentence', 'user_phrase', 'phrase', 'completion'}
    -- local t1 = c1.type
    -- local t2 = c2.type
    local q1 = c1.quality
    local q2 = c2.quality
    -- local o1 = nil
    -- local o2 = nil

    -- for i = 1, #type_order do
    --     if t1 == type_order[i] then o1 = i end
    --     if t2 == type_order[i] then o2 = i end
    -- end

    if odd == 1 then
        if is_fuma1 and not is_fuma2 then return true end
        if is_fuma2 and not is_fuma1 then return false end
        -- if is_fuma1 and is_fuma2 then
            -- if l1 ~= l2 then return l1 > l2 end
            -- return q1 > q2
        -- end
    end

    -- if t1 == 'completion' then return false end
    -- if t2 == 'completion' then return true end
    -- if l1 ~= l2 then return l1 > l2 end

    -- if o1 ~= nil and o2 ~= nil then
    --     if o1 ~= o2 then return o1 < o2 end
    --     return q1 > q2
    -- end

    -- if o1 == nil then return false end
    -- if o2 == nil then return true end
    return q1 > q2
end

function fuma_translator.init(env)
    env.pinyin = Component.Translator(env.engine, "", "script_translator@translator")
    env.wubi = Component.Translator(env.engine, "", "table_translator@fuma")
end

function fuma_translator.fini(env)
    -- 清理引用（可选）
    env.pinyin = nil
    env.wubi = nil
end

function fuma_translator.func(input, seg, env)
    local len = string.len(input)
    local odd = len & 1
    local texts = {}
    local candidates = {}
    local result = nil

    if (len >= 3) then
        local p = string.sub(input, 1, len - 2 + odd)
        local w = string.sub(input, len - 1 + odd, len)

        result = env.pinyin:query(p, seg)
        local fuma = env.wubi:query(w, seg)
        local fuma_candidates = {}

        if (fuma ~= nil) then
            for f in fuma:iter() do
                fuma_candidates[#fuma_candidates + 1] = f.text
            end
        end

        if result ~= nil then
            for r in result:iter() do
                local t = r.text
                for fi = 1, #fuma_candidates do
                    local ft = fuma_candidates[fi]
                    if string.find(t, ft) ~= nil and not contains(texts, t) then
                        texts[#texts + 1] = t
                        -- 绝对不要修改 r.type！保持它原生的 'phrase' 状态，引擎才会记录和删除
                        r.comment = ';' .. w
                        r.preedit = r.preedit .. ';' .. w .. ' '
                        candidates[#candidates + 1] = r
                        break
                    end
                end
            end
        end
    end

    result = env.pinyin:query(input, seg)
    if (result ~= nil) then
        for r in result:iter() do
            local t = r.text
            if not contains(texts, t) then
                texts[#texts + 1] = t
                candidates[#candidates + 1] = r
            end
        end
    end

    table.sort(candidates, function(c1, c2) return compare(c1, c2, odd) end)

    for i = 1, #candidates do
        yield(candidates[i])
    end
end

return fuma_translator
