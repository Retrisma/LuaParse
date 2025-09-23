require"tools"
require"grammar"
require"parser_library"
require"tokenizer"
require"parser"

local parse_exp_tests = {
    { "2", exp.CNum(2) },
    { "-2", unop.Neg(exp.CNum(2)) },
    { "...", exp.Etc() },
    { "true", exp.CBool("true") },
    { "false", exp.CBool("false") },
    { '"hi"', exp.CStr("hi")},
    { "nil", exp.Nil() },
    { "{}", exp.CTbl({}) },
    { "{ 5 }", exp.CTbl({ tbl_field.TFNone(exp.CNum(5))}) },
    { "{ 5, 6; }", exp.CTbl({ tbl_field.TFNone(exp.CNum(5)); tbl_field.TFNone(exp.CNum(5)) }) },
    { "{ a = 5; [3] = 6 }", exp.CTbl({ tbl_field.TFId({"a", exp.CNum(5)}); tbl_field.TFExp({exp.CNum(3), exp.CNum(6)})}) },
    { "x", exp.CVar("x") },
    { 'x["g"]', exp.Proj(exp.CVar("x"), exp.CStr("g"))},
    { "x.g", exp.Proj(exp.CVar("x"), "g")},
    { "x.g.a", exp.Proj(exp.Proj(exp.CVar("x"), "g"), "a")},
    { "x[g.a]", exp.Proj(exp.CVar("x"), exp.Proj(exp.CVar("g"), "a"))},
    { "f()", exp.FCall(exp.CVar("f"), {})},
    { "f(x)", exp.FCall(exp.CVar("f"), { exp.CVar("x")})},
    { "f(x, 4, true, { a })", exp.FCall(exp.CVar("f"), { exp.CVar("x"), exp.CNum(4), exp.CBool("true"), exp.CTbl({ exp.CVar("a")})})},
    { "f(g(a))", exp.FCall{exp.CVar("f"), { exp.FCall(exp.CVar("g"), { exp.CVar("a")})}}}
}

local parse_stmt_tests = {
    { "x = 5", stmt.Assn{{exp.CVar("x")}, {exp.CNum(5)}}},
    { "x, y = 1, 2", stmt.Assn{{exp.CVar("x"), exp.CVar("y")}, {exp.CNum(1), exp.CNum(2)}}},
    { "x[3] = true", stmt.Assn{{exp.Proj(exp.CVar("x"), exp.CNum(3))}, {exp.CBool("true")}}}
}

function ast_equal(ast, reference)
    for i,v in ipairs(ast) do
        if type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
            if ast[i] ~= reference[i] then
                return false
            end
        elseif type(v) == "table" then
            local b = ast_equal(ast[i], reference[i])
            if not b then return b end
        end
    end

    return true
end

function run_tests(parser, tests)
    for _, test in pairs(tests) do
        local ast = parser % table.reverse(tokenize(test[1]))
        
        local result = ast.status == "success" and ast_equal(ast.head, test[2])

        if ast.status == "failure" then
            print(print("Test did not compile: ", test[1]))
        elseif not result then
            print("Failed Test: ", test[1])
            print("Expected: ")
            print_tree(test[2])
            print()
            print("Given: ")
            print_tree(ast.head)
            print()
        else
            print("Passed: ", test[1])
        end
    end
end

run_tests(parse_exp, parse_exp_tests)
run_tests(parse_stmt, parse_stmt_tests)