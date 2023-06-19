local ls = require('luasnip')
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.conditions")
local conds_expand = require("luasnip.extras.conditions.expand")

local same = function(index)
	return f(function(arg)
		return arg[1]
	end, { index })
end
require('luasnip.session.snippet_collection').clear_snippets("dart")
print("HELLO FRIEND")



--
-- -- Using LSP
-- local lsp = vim.lsp
-- local params = lsp.util.make_position_params()
-- local result = lsp.buf_request_sync(0, "textDocument/definition", params, 1000)
-- local class_node = result[1].result[1]
-- local param1_node = class_node:descendant_for_named("field_declaration", "param1")
-- local param2_node = class_node:descendant_for_named("field_declaration", "param2")
-- local param1_value = param1_node:descendant_for_named("string"):text()
-- local param2_value = param2_node:descendant_for_named("string"):text()
--

local ts_utils = require("nvim-treesitter.ts_utils")
local ts_locals = require "nvim-treesitter.locals"
local get_node_text = vim.treesitter.get_node_text


local function get_parameters(args)
	-- local cursor_node = ts_utils.get_node_at_cursor()
	-- local scope = ts_utils.get_scope_tree(cursor_noe, 0)
	-- Using Tree-sitter
	local ts = require("nvim-treesitter")
	local bufnr = vim.api.nvim_get_current_buf()
	local x = {}
	local node = ts_utils.get_node_at_cursor()
	while node ~= nil and node:type() ~= "class_definition" do
		node = node:parent()
	end
	if node == nil then
		error("No class_definition node")
	end
	local class_name = get_node_text(node:field("name")[1], bufnr)
	local root_node = node:tree():root()

	local query_pattern = [[
		(class_declaration
			(name) @class_name
			(field_declaration
				(identifier) @param_name
				(string) @param_value
			)
		)
	]]
	local parser = vim.treesitter.get_parser(bufnr, "dart", nil)
	local query = vim.treesitter.query.parse("dart", query_pattern)
	for _, captured_node, metadata in query:iter_captures(root_node, bufnr) do
		-- local function_name = get_node_text(node,bufnr)

		print('Found function:', vim.inspect(captured_node))
		table.insert(x, t(captured_node))
	end



	-- local decleration_node
	-- vim.tresitter.query.parse(
	-- 	"dart",
	-- 	"((class_declaration (identifier) @class_name) @class_declaration)",
	-- 	function(match)
	-- 		decleration_node = match.captures[1]
	-- 	end
	-- )
	table.insert(x, t(class_name))
	table.insert(x, t("DIDRUN"))




	return sn(nil, x)
end

local function get_first_single_child(node, child_type)
	local children = node:iter_children()
	for child in children do
		if child:type() == child_type then
			return child
		end
		if child:child_count() > 0 then
			local y = get_first_single_child(child, child_type)
			if y ~= nil then
				return y
			end
		end
	end
	return nil
end
local function node_has(node, has)
	if type(has) == 'table' then
		local valid = true
		for _, value in ipairs(has) do
			valid = valid and node_has(node, value)
		end
		return valid
	end
	local children = node:iter_children()

	for child in children do
		if child:type() == has then
			return true
		end
	end
	return false
end
local function get_multi_child(node, child_type, filter_with_nodes)
	--filter_with_nodes to check that is has children of a certain type(s)
	-- table or string, TODO: do proper doc for this
	local children = node:iter_children()
	local x = {}
	for child in children do
		if child:type() == child_type then
			if filter_with_nodes then
				if node_has(child, filter_with_nodes) then
					table.insert(x, child)
				end
			else
				table.insert(x, child)
			end
		end
		if child:child_count() > 0 then
			local y = get_multi_child(child, child_type)
			for _, z in ipairs(y) do
				table.insert(x, z)
			end
		end
	end
	return x
end

local function get_parameters_without_query(args)
	--we have officially given up on figuring out how to get query to work...
	local class_definition = "class_definition"
	local body = ""
	local ts = require("nvim-treesitter")
	local bufnr = vim.api.nvim_get_current_buf()
	local node = ts_utils.get_node_at_cursor()
	while node ~= nil and node:type() ~= "class_definition" do
		node = node:parent()
	end
	if node == nil then
		error("No class_definition node")
	end
	local class_name = get_node_text(node:field("name")[1], bufnr)

	local class_body = get_first_single_child(node, "class_body")
	local first_declaration = get_first_single_child(class_body, "declaration")
	local param_list = get_first_single_child(first_declaration, "formal_parameter_list")
	local parameter_nodes = get_multi_child(param_list, "identifier")
	local parameters = {}
	for _, param in ipairs(parameter_nodes) do
		table.insert(parameters, get_node_text(param, bufnr))
	end

	local parameter_definitions = get_multi_child(node, "declaration",
		{ "initialized_identifier_list", "type_identifier" })
	local parameter_types = {}
	for _, param in ipairs(parameter_definitions) do
		local name_node = get_first_single_child(param, "identifier")
		if name_node then
			local type_identifier = get_first_single_child(param, "type_identifier")
			local name_identifier = get_node_text(name_node, bufnr)
			if type_identifier then
				parameter_types[name_identifier] = get_node_text(type_identifier, bufnr)
			else
				print("No type for parameter:", name_identifier)
			end
		end
	end

	local x = {}
	table.insert(x, t(class_name .. " copyWith({"))
	for _, name in ipairs(parameters) do
		local param_type = parameter_types[name]
		if param_type then
			table.insert(x, t({ "", "\t" .. param_type .. "? " .. name .. ", " }))
		end
	end
	table.insert(x, t({ "", "})=>" .. class_name .. "(" }))
	for _, name in ipairs(parameters) do
		if parameter_types[name] then
			table.insert(x, t({ "", "\t" .. name .. " : " .. name .. " ?? this." .. name .. "," }))
		end
	end
	table.insert(x, t({ "", ");" }))
	return sn(nil, x)
end





ls.add_snippets("dart", {
	s({ trig = "copyw", name = "Generate copyWith" },
		d(1, get_parameters_without_query, {})
	),

	s({ trig = "ss", name = "setState" },
		f("setState((){{\n\t{}\n}});", { i(1) })
	),

	s({ trig = "slw", name = "StatelessWidget" },
		fmta([[
		import 'package:flutter/widgets.dart';
		
		class <> extends StatelessWidget{
		    const <>({Key? key}) : super(key: key);
			@override
			Widget build(BuildContext context) {
				return const Placeholder();
			}
		}
			]], { i(1, "Widget"), rep(1) })
	),

	s({ trig = "sfw", name = "StatefulWidget" },
		fmta([[
import 'package:flutter/widgets.dart';

class <> extends StatefulWidget {
  const <>({Key? key}) : super(key: key);

  @override
  <>State createState() =>> <>State();
}

class <>State extends State<<<>>> {
  static const padding = EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
			]], { i(1, "Widget"), rep(1), rep(1), rep(1), rep(1), rep(1) })
	),

	s({ trig = "cslw", name = "ConsumerStatelessWidget (riverpod)" },
		fmta([[
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
		
class <> extends ConsumerStatelessWidget{
    const <>({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return const Placeholder();
    }
}
			]], { i(1, "Widget"), rep(1) })
	),

	s({ trig = "csfw", name = "ConsumerStatefulWidget (riverpod)" },
		fmta([[
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class <> extends ConsumerStatefulWidget {
  const <>({Key? key}) : super(key: key);

  @override
  <>State createState() =>> <>State();
}

class <>State extends ConsumerState<<<>>> {
  static const padding = EdgeInsets.all(8.0);

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
			]], { i(1, "Widget"), rep(1), rep(1), rep(1), rep(1), rep(1) })
	),
	s({ trig = "inits", name = "initState" },
		fmta([[
		@override
		void initState() {
		    <>	
			super.initState();
		}
			]], { i(0) })
	),
	s({ trig = "for", name = "for (i=0...i++)" },
		fmta([[
		for (int <> = 0; <> << <> ; <>++) {
			<>
		}
		]], { i(1), i(2), rep(1), rep(1), i(0) })
	),

})
