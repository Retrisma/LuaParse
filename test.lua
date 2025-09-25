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
    { "{ 5, 6; }", exp.CTbl({ tbl_field.TFNone(exp.CNum(5)); tbl_field.TFNone(exp.CNum(6)) }) },
    { "{ a = 5; [3] = 6 }", exp.CTbl({ tbl_field.TFId("a", exp.CNum(5)); tbl_field.TFExp(exp.CNum(3), exp.CNum(6))}) },
    { "x", exp.CVar("x") },
    { 'x["g"]', exp.Proj(exp.CVar("x"), exp.CStr("g"))},
    { "x.g", exp.Proj(exp.CVar("x"), "g")},
    { "x.g.a", exp.Proj(exp.Proj(exp.CVar("x"), "g"), "a")},
    { "x[g.a]", exp.Proj(exp.CVar("x"), exp.Proj(exp.CVar("g"), "a"))},
    { "f()", exp.FCall(exp.CVar("f"), {})},
    { "f(x)", exp.FCall(exp.CVar("f"), { exp.CVar("x")})},
    { "f:m()", exp.MCall(exp.CVar("f"), "m", {})},
    { "f(x, 4, true, { a })", exp.FCall(exp.CVar("f"), { exp.CVar("x"), exp.CNum(4), exp.CBool("true"), exp.CTbl({ exp.CVar("a")})})},
    { "f(g(a))", exp.FCall(exp.CVar("f"), { exp.FCall(exp.CVar("g"), { exp.CVar("a")}) })}
}

local parse_stmt_tests = {
    { "x = 5", stmt.Assn({exp.CVar("x")}, {exp.CNum(5)}) },
    { "x, y = 1, 2", stmt.Assn({exp.CVar("x"), exp.CVar("y")}, {exp.CNum(1), exp.CNum(2)}) },
    { "x[3] = true", stmt.Assn({exp.Proj(exp.CVar("x"), exp.CNum(3))}, {exp.CBool("true")}) },
    { "do x = 5 y = 6 end", stmt.Do(block.Block{stmt.Assn({exp.CVar("x")}, {exp.CNum(5)}), stmt.Assn({exp.CVar("y")}, {exp.CNum(6)}) })},
    { "while true do x = 5 end", stmt.While(exp.CBool("true"), block.Block{ stmt.Assn({exp.CVar("x")}, {exp.CNum(5)}) })},
    { "while y do end", stmt.While(exp.CVar("y"), block.Block{ })},
    { "while x do while y do x = 5 end end", stmt.While(exp.CVar("x"), block.Block{stmt.While(exp.CVar("y"), block.Block{ stmt.Assn({exp.CVar("x")}, {exp.CNum(5)}) })})},
    { "repeat x = 5 until true", stmt.Repeat(block.Block{ stmt.Assn({exp.CVar("x")}, {exp.CNum(5)}) }, exp.CBool("true"))},
    { "::label::", stmt.Label("label")},
    { "goto label", stmt.Goto("label")},
    { "return", stmt.Return{}},
    { "return 5", stmt.Return{ exp.CNum(5)}},
    { "return 5, x, true", stmt.Return{ exp.CNum(5), exp.CVar("x"), exp.CBool("true")}},
    { "break", stmt.Break()},
    { "if true then return end", stmt.ITE(exp.CBool("true"), block.Block{stmt.Return{}}, {}, option.None())},
    { "if true then return elseif nil then break elseif 4 then goto label else x = 5 end",
        stmt.ITE(exp.CBool("true"), block.Block{stmt.Return{}}, {{exp.Nil(), block.Block{stmt.Break()}}; {exp.CNum(4), block.Block{ stmt.Goto("label") }}}, option.Some(block.Block{stmt.Assn({exp.CVar("x")}, {exp.CNum(5)})}))},
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