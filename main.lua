require("lldebugger").start()

require"tools"
require"grammar"
require"parser_library"
require"tokenizer"
require"parser"

local test = io.open("test", "r"):read("a")

node_titles = calc_node_titles()

local token_stream = tokenize(test)
print_tree(token_stream)
print()

token_stream = table.reverse(token_stream)

local out = parse_stmt % token_stream
print_tree(out.head or out.reason)