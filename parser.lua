---@param token_type "TId"|"TNum"|"TSym"
---@return Parser
function parse_any(token_type)
    return new_parser(function(stream)
        if #stream == 0 then
            return failure("no more input")
        end

        local head = table.peek(stream)

        if head[1] == token_type then
            return success(table.pop(stream)[2], stream)
        else
            return failure("not a " .. token_type)
        end
    end)
end

---@type Parser
parse_any_ident = parse_any("TId")

---@type Parser
parse_any_number = parse_any("TNum")

---@type Parser
parse_any_symbol = parse_any("TSym")

---@param symbol string
---@return Parser
parse_symbol = function(symbol)
    return new_parser(function(stream)
        if #stream == 0 then
            return failure("no more input")
        end

        local head = table.peek(stream)

        if head[1] == "TSym" and head[2] == symbol then
            return success(table.pop(stream)[2], stream)
        else
            return failure("not a " .. symbol)
        end
    end)
end

parse_exp, parse_exp_ref = create_parser_forwarded_to_ref()

local function ret_binop(symbol, binop_def)
    return parse_symbol(symbol) >> return_p(function(x, y) return exp.Binop(binop_def(x, y)) end)
end

local function ret_unop(symbol, unop_def)
    return parse_symbol(symbol) >> return_p(function(x) return exp.Unop(unop_def(x)) end)
end

local function ret_fcall()
end

local parse_binop = choice {
    ret_binop("+", binop.Add),
    ret_binop("-", binop.Sub),
    ret_binop("*", binop.Mul),
    ret_binop("/", binop.Div),
}

local parse_unop = choice {
    ret_unop("#", unop.Len),
    ret_unop("~", unop.Not),
    ret_unop("-", unop.Neg)
}

local parse_term = choice {
    parse_symbol("nil") ~ exp.Nil,
    parse_symbol("true") ~ exp.CBool,
    parse_symbol("false") ~ exp.CBool,
    parse_symbol("...") ~ exp.Etc,
    parse_any_number ~ exp.CNum,
    parse_symbol("function") >> between_parens(sep(parse_any_ident, parse_symbol(","))) ~ exp.CFun,
    -- unbound left recursion, need to rework chainl1 to handle it
    -- parse_exp & between_parens(sep(parse_exp, parse_symbol(","))) ~ exp.FCall,
    between_parens(parse_exp),
}

local and_unop = prefix1(parse_term, parse_unop)
local and_binop = chainl1(and_unop, parse_binop)

parse_exp_ref.value = and_binop