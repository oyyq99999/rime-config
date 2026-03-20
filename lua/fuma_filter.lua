local function compare(c1, c2, odd, expected_len)
    local l1 = utf8.len(c1.text)
    local l2 = utf8.len(c2.text)

    -- 通过判断 comment 是否带有 ';' 来识别辅码词条，而不是判断 type
    local is_fuma1 = (c1.comment and string.match(c1.comment, '^;%w%w?$')) and true or false
    local is_fuma2 = (c2.comment and string.match(c2.comment, '^;%w%w?$')) and true or false

    local type_order = {'sentence', 'user_phrase', 'phrase', 'completion'}
    local t1 = c1.type
    local t2 = c2.type
    local o1 = nil
    local o2 = nil
    for i = 1, #type_order do
        if t1 == type_order[i] then o1 = i end
        if t2 == type_order[i] then o2 = i end
    end

    local q1 = c1.quality
    local q2 = c2.quality

    -- 单辅码时辅码优先，双辅码时同等长度辅码优先
    if odd or l1 == l2 then
        if is_fuma1 and not is_fuma2 then return true end
        if is_fuma2 and not is_fuma1 then return false end
    end

    if l1 == expected_len and l2 ~= expected_len then return true end
    if l2 == expected_len and l1 ~= expected_len then return false end

    if l1 ~= l2 then return l1 > l2 end

    if o1 ~= nil and o2 ~= nil then
        if o1 ~= o2 then return o1 < o2 end
        return q1 > q2
    end

    if o1 == nil then return false end
    if o2 == nil then return true end
    return q1 > q2
end

local fuma_filter = {
    init = function(env)
        env.wubi = Component.Translator(env.engine, "", "table_translator@fuma")
    end,
    func = function(translation, env)
        local input = env.engine.context.input
        local input_len = utf8.len(input)

        -- 有时候会需要选了一部分之后再加辅码筛选，所以得用seg来计算
        local seg = env.engine.context.composition:back()
        local seg_len = seg.length
        local odd = seg_len & 1

        local fuma_candidates = {}

        -- 只能从input获取输入码，不管是seg还是input，都是按照odd取最后的1或2位，在seg_len >= 3的时候这个没区别
        local w = string.sub(input, input_len - 1 + odd, input_len)
        if (seg_len >= 3) then
            local fuma = env.wubi:query(w, seg)
            if fuma ~= nil then
                for f in fuma:iter() do
                    fuma_candidates[#fuma_candidates + 1] = f.text
                end
            end
        end

        local candidates = {}

        if translation ~= nil then
            -- 双辅码只针对单字
            local max_len_p = 1
            if odd == 1 then
                max_len_p = (seg_len - 2 + odd) // 2
            end
            for cand in translation:iter() do
                local t = cand.text
                if utf8.len(t) <= max_len_p then
                    for fi = 1, #fuma_candidates do
                        local ft = fuma_candidates[fi]
                        if string.find(t, ft) ~= nil then
                            cand.comment = ';' .. w
                            cand.preedit = cand.preedit .. ';' .. w .. ' '
                            break
                        end
                    end
                end
                candidates[#candidates + 1] = cand
            end
        end

        local expected_len = (seg_len + 1) // 2

        table.sort(candidates, function(c1, c2) return compare(c1, c2, odd == 1, expected_len) end)

        -- 单辅码时，因为辅码优先，会导致没打完的词被排在后面，所以提几条符合预期长度的词到前面来
        if odd == 1 then
            local n = 1 -- 可以根据需要修改这个数字，比如 n = 3
            local top_list = {}

            local i = 1
            while i <= #candidates and #top_list < n do
                local cand = candidates[i]
                if utf8.len(cand.text) == expected_len and cand.type == 'user_phrase' then
                    table.insert(top_list, table.remove(candidates, i))
                else -- 删除当前元素后，不需要增加索引，因为下一个元素已经移到当前位置了
                    i = i + 1
                end
            end

            if #top_list > 0 then
                table.move(candidates, 1, #candidates, #top_list + 1, top_list)
                candidates = top_list
            end
        end

        for i = 1, #candidates do
            yield(candidates[i])
        end
    end,
    finish = function(env)
        env.wubi = nil
    end
}

return fuma_filter
