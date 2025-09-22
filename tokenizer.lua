---@class Token { "name", value }

function construct_literal(tbl)
    out = {}
    for k,v in pairs(tbl) do
        out[k] = ""
        for c in string.gmatch(v, ".") do
            out[k] = out[k] .. "%" .. c
        end
    end
    return out
end

reserved_symbols_literal = construct_literal(reserved_symbols)

token = {
    TSym = function(symbol) return { "TSym", symbol } end,
    TId = function(ident) return { "TId", ident } end,
    TNum = function(num) return { "TNum", num } end
}

table.insert(grammar_levels, token)

whitespace_regex = "^([ \f\n\r\t\v]+)"
identifier_regex = "^([a-zA-Z_]%w*)"
number_regex = "^(%d*%.?%d+)"

function match_reserved_symbols(str)
    for i,v in ipairs(reserved_symbols_literal) do
        if string.match(str, "^" .. v) then
            return reserved_symbols[i]
        end
    end

    return nil
end

function tokenize(input)
    local token_stream = {}

    local function iter()
        -- clear whitespace from the front of the string
        input = string.gsub(input, whitespace_regex, "")

        -- match number-like strings
        local scratch = string.match(input, number_regex)
        if scratch then
            table.insert(token_stream, token.TNum(tonumber(scratch)))
            input = string.gsub(input, number_regex, "")
            return
        end

        -- match reserved symbols
        scratch = match_reserved_symbols(input)
        if scratch then
            table.insert(token_stream, token.TSym(scratch))
            input = string.sub(input, #scratch + 1)
            return
        end

        -- match word-like strings
        scratch = string.match(input, identifier_regex)
        if scratch then
            if table.has(reserved_words, scratch) then
                table.insert(token_stream, token.TSym(scratch))
            else
                table.insert(token_stream, token.TId(scratch))
            end
            input = string.gsub(input, identifier_regex, "")
            return
        end

        -- TODO: match string literal
    end

    while string.len(input) > 0 do
        iter()
    end

    return token_stream
end