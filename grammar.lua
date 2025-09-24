block = {
    Block = function(stmts) return { "Block", stmts } end
}

option = {
    Some = function(val) return { "Some", val } end,
    None = function() return { "None" } end
}

stmt = {
    Pass = function() return { "Pass" } end,
    Assn = function(ident, val) return { "Assn", ident, val } end,
    Do = function(block) return { "Do", block } end,
    While = function(exp, block) return { "While", exp, block } end,
    Repeat = function(block, exp) return { "Repeat", block, exp } end,
    ITE = function(if_exp, then_block, else_if_blocks, else_block_option) return { "ITE", if_exp, then_block, else_if_blocks, else_block_option } end,
    Goto = function(label) return { "Goto", label } end,
    Label = function(label) return { "Label", label } end,
    Break = function() return { "Break" } end,
    Return = function(exps) return { "Return", exps } end
}

tbl_field = {
    TFExp = function(exp1, exp2) return { "TFExp", exp1, exp2 } end,
    TFId = function(id, exp) return { "TFId", id, exp } end,
    TFNone = function(exp) return { "TFNone", exp } end
}

exp = {
    Nil = function() return { "Nil" } end,
    Etc = function() return { "Etc" } end,
    CBool = function(bool) return { "CBool", bool } end,
    CNum = function(num) return { "CNum", num } end,
    CStr = function(str) return { "CStr", str } end,
    CVar = function(id) return { "CVar", id } end,
    CTbl = function(fields) return { "CTbl", fields } end,
    Binop = function(binop) return binop end,
    Unop = function(unop) return unop end,
    CFun = function(args, block) return { "CFun", args, block } end,
    FCall = function(exp, args) return { "FCall", exp, args } end,
    MCall = function(exp, id, args) return { "MCall", exp, id, args } end,
    Proj = function(p_exp, exp) return { "Proj", p_exp, exp } end
}

binop = {
    Add = function(exp1, exp2) return { "Add", exp1, exp2 } end,
    Sub = function(exp1, exp2) return { "Sub", exp1, exp2 } end,
    Mul = function(exp1, exp2) return { "Mul", exp1, exp2 } end,
    Div = function(exp1, exp2) return { "Div", exp1, exp2 } end,
    And = function(exp1, exp2) return { "And", exp1, exp2 } end,
}

unop = {
    Len = function(exp) return { "Len", exp } end,
    Not = function(exp) return { "Not", exp } end,
    Neg = function(exp) return { "Neg", exp } end
}

grammar_levels = { block, option, stmt, tbl_field, exp, binop, unop }

reserved_words = {
    "and", "break", "do", "else", "elseif",
    "end", "false", "for", "function", "goto", "if",
    "in", "local", "nil", "not", "or",
    "repeat", "return", "then", "true",
    "until", "while"
}

reserved_symbols = {
    "...",
    "<<", ">>", "//", "..",
    "==", "~=", "<=", ">=", "::",
    "+", "-", "*", "/",
    "&", "~", "|",
    "%", "^", "#", "=",
    "<", ">",
    "(", ")", "{", "}", "[", "]",
    ";", ":", ",", ".",
}

