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
ls.add_snippets("dart", {

	s("ss",
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
