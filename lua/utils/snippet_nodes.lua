local ls = require("luasnip")

---@alias Node table
---@alias Snippet table
---@alias SnippetNode table
---@alias Indexer table
---@alias KeyIndexer { key: string }
---@alias AbsoluteIndexer { absolute_insert_position: integer[] }
---@alias NodeRef KeyIndexer|AbsoluteIndexer
---@alias NodeOpt { key:string, node_ext_opts:table, merge_node_ext_opts:boolean, node_callbacks:fun(node:Node, event_args?:table):table }

---@type fun(context:string|{ trig:string, name:string, desc:string }, nodes:Node[], node_opts?:NodeOpt):Snippet
local s = ls.snippet
---@type fun(jump_index?:integer, nodes:Node|Node[], node_opts?:NodeOpt):SnippetNode
local sn = ls.snippet_node
---@type fun(text:string|string[], node_opts?:NodeOpt):Node
local t = ls.text_node
---@type fun(jump_index?:integer, text?:string|string[], node_opts?:NodeOpt):Node
local i = ls.insert_node
---@type fun(fn:(fun(argnode_text:string[][], parent:(NodeRef)[], user_args:{user_args:string[]}):string|string[]), argnode_references?:NodeRef|(NodeRef)[], node_opts?:NodeOpt):Node
local f = ls.function_node
---@type fun(jump_index?:integer, choices:Node[]|Node, node_opts?:NodeOpt|{restoreNode:boolean}):Node
local c = ls.choice_node
---@type fun(jump_index?:integer, fun:(fun(args:string[], parent:(NodeRef)[], old_state:table, user_args:{user_args:string[]}):SnippetNode), node_references?:NodeRef|(NodeRef)[], node_opts?:NodeOpt):SnippetNode
local d = ls.dynamic_node
---@type fun(jump_index?:integer, nodes:Node|Node[], indentstring:string, node_opts?:NodeOpt):SnippetNode
local isn = ls.indent_snippet_node
---@type fun(jump_index?:integer, key:NodeRef, indentstring:string, node_opts?:NodeOpt):Node
local r = ls.restore_node
local events = require("luasnip.util.events")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet

---@alias LSFormatOpts { delimiters: string, indent_string: string, trim_empty: boolean, dedent: boolean, repeat_duplicates: boolean }
---@alias LSFormat fun(format:string, nodes:Node[], opts?:LSFormatOpts):Node[]
---@type LSFormat
local _fmt = require("luasnip.extras.fmt").fmt
---@type LSFormat
local _fmta = require("luasnip.extras.fmt").fmta

---@type fun(...:integer[]):AbsoluteIndexer
local ai = require("luasnip.nodes.absolute_indexer")

---@type fun(key:string):KeyIndexer
local k = require("luasnip.nodes.key_indexer").new_key

---Indent one level right the parent node
---@param jump_index? integer
---@param nodes Node|Node[]
---@return SnippetNode
local function indent(jump_index, nodes)
  return isn(jump_index, nodes, "$PARENT_INDENT\t")
end

---Custom fmt with two space as indent
---@type LSFormat
local function fmt(format, nodes, options)
  options = options or {}
  if options.indent_string == nil then
    options.indent_string = "  "
  end
  return _fmt(format, nodes, options)
end

---Custom fmta with two space as indent
---@type LSFormat
local function fmta(format, nodes, options)
  options = options or {}
  if options.indent_string == nil then
    options.indent_string = "  "
  end
  return _fmta(format, nodes, options)
end

return {
  s = s,
  sn = sn,
  t = t,
  i = i,
  f = f,
  c = c,
  d = d,
  isn = isn,
  r = r,
  events = events,
  extras = extras,
  l = l,
  rep = rep,
  p = p,
  m = m,
  n = n,
  dl = dl,
  conds = conds,
  postfix = postfix,
  types = types,
  parse = parse,
  ms = ms,
  indent = indent,
  ai = ai,
  k = k,
  fmt = fmt,
  fmta = fmta,
}
