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
    { "nil", exp.Nil() },
    { "{}", exp.CTbl({}) },
    { "{ 5 }", exp.CTbl({ tbl_field.TFNone(exp.CNum(5))}) },
    { "{ 5, 6; }", exp.CTbl({ tbl_field.TFNone(exp.CNum(5)); tbl_field.TFNone(exp.CNum(5)) }) },
    { "{ a = 5; [3] = 6 }", exp.CTbl({ tbl_field.TFId({"a", exp.CNum(5)}); tbl_field.TFExp({exp.CNum(3), exp.CNum(6)})}) }
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
            print("Expected: ", print_tree(test[2]))
            print("Given: ", print_tree(ast.head))
        else
            print("Passed: ", test[1])
        end
    end
end

run_tests(parse_exp, parse_exp_tests)