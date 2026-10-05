; extends

(pipe_table) @table
; (pipe_table_cell) @table_cell

(atx_heading
  heading_content: (_) @header.inner) @header.outer

(fenced_code_block (code_fence_content) @code_block.inner) @code_block.outer
