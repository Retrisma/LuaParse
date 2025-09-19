block = function(stmts) return stmts end

stmt = {
    Assn = function(ident, val) return { "Assn", ident, val } end,
    ITE = function(if_blocks, else_block_option) return { "ITE", if_blocks, else_block_option } end
}

exp = {
    Nil = function() return { "Nil" } end,
    Etc = function() return { "Etc" } end,
    CBool = function(bool) return { "CBool", bool } end,
    CNum = function(num) return { "CNum", num } end,
    CStr = function(str) return { "CStr", str } end,
    Binop = function(binop) return binop end,
    Unop = function(unop) return unop end,
    CFun = function(args, block) return { "CFun", args, block } end,
    FCall = function(exp, args) return { "FCall", exp, args } end
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

reserved_words = {
    "and", "break", "do", "else", "elseif",
    "end", "false", "for", "function", "goto", "if",
    "in", "local", "nil", "not", "or",
    "repeat", "return", "then", "true",
    "until", "while"
}

reserved_symbols = {
    "+", "-", "*", "/",
    "&", "~", "|",
    "%", "^", "#", "=",
    "<", ">",
    "(", ")", "{", "}", "[", "]",
    ";", ":", ",", ".",
    "<<", ">>", "//", "..", "...",
    "==", "~=", "<=", ">=", "::",
}

