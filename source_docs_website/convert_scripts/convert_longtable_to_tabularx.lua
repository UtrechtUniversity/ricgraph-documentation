-- -------------------------------------------------------------------------
-- This script transforms tables in GitHub markdown files. 
-- To be used when generating a pdf from the GitHub documentation.
-- Usually, Quarto uses LaTeX "longtable" for tables. That package has several
-- advantages, such as splitting long tables to multiple pages.
-- However, its biggest disadvantage is that is does not work in
-- the LaTeX "twocolumn" environment, which I need. 
--
-- This script hacks the intermediate Pandoc code to replace
-- "longtable" by "tabularx".
--
-- A "c" column (in a LaTeX table) will be replaced by an "X" column.
-- That is, a cell text that is too long will be split in multiple lines.
-- If the table is too long to fit in one column, it will be truncated.
-- Also, variable width columns are not possible.
--
-- This script was inspired by:
-- https://github.com/jgm/pandoc/issues/1023
-- https://github.com/SichangHe/JSphere/blob/6dd9bc1cabc84644cbde6e3441251837b421031c/table_workaround_filter.lua
-- -------------------------------------------------------------------------
-- Rik D.T. Janssen, original version April 2, 2025.
-- -------------------------------------------------------------------------

function get_rows_data(rows)
  local data = ""
  for _, row in ipairs(rows) do
    for cell_idx, cell in ipairs(row.cells) do
      -- Process cell content as Blocks
      local latex = ""
      local cell_content = cell.content:walk {
            Link = 
	      function(lnk)
                latex = "\\href{" .. lnk.target .. "}{" ..
                        pandoc.utils.stringify(lnk.content) .. "}"
              end,
            Image = 
	      function(img)
                latex = "\\includegraphics{" .. img.src .. "}"
              end,
            -- Default case for any other inline element
            Inline = 
	      function(elem)
                -- Convert the element to LaTeX as plain text
                latex =  latex .. pandoc.utils.stringify(elem)
              end
            }
      data = data .. latex .. (cell_idx == #row.cells and " \\\\ \n" or " & ")
      -- Escape % as \%
      data = data:gsub("([^\\])%%", "%1\\%%")
      data = data:gsub("^%%", "\\%%")
      -- Escape _ as \_
      data = data:gsub("([^\\])_", "%1\\_")
      data = data:gsub("^_", "\\_")
      -- Escape # as \#
      data = data:gsub("([^\\])#", "%1\\#")
      data = data:gsub("^#", "\\#")
      end
    end
  return data
end


function generate_tabular(tbl)
  local col_specs = tbl.colspecs
  local col_specs_latex = ""
  for i, col_spec in ipairs(col_specs) do
    local align = col_spec[1]
    if align == "AlignLeft" then
      col_specs_latex = col_specs_latex .. "l"
    elseif align == "AlignRight" then
      col_specs_latex = col_specs_latex .. "r"
    else -- align == "AlignCenter"
      -- col_specs_latex = col_specs_latex .. "c"
      col_specs_latex = col_specs_latex .. "X"
    end
  end

  local result = pandoc.List:new({
    pandoc.RawBlock("latex", "\\begin{tabularx}{\\columnwidth}{" .. col_specs_latex .. "}"),
    pandoc.RawBlock("latex", "\\toprule"),
  })

  -- HEADER
  local header_latex = get_rows_data(tbl.head.rows)
  result = result
    .. pandoc.List:new({ pandoc.RawBlock("latex", header_latex), pandoc.RawBlock("latex", "\\midrule") })

  -- ROWS
  local rows_latex = ""
  for j, tablebody in ipairs(tbl.bodies) do
    rows_latex = get_rows_data(tablebody.body)
  end
  result = result .. pandoc.List:new({ pandoc.RawBlock("latex", rows_latex) })

  -- FOOTER
  local footer_latex = get_rows_data(tbl.foot.rows)
  result = result .. pandoc.List:new({ pandoc.RawBlock("latex", footer_latex) })

  result = result
    .. pandoc.List:new({
      pandoc.RawBlock("latex", "\\bottomrule"),
      pandoc.RawBlock("latex", "\\end{tabularx}"),
    })
  return result
end

if FORMAT:match("latex") then
  function Table(tbl)
    return generate_tabular(tbl)
  end

  function RawBlock(raw)
    if raw.format:match("html") and raw.text:match("%<table") then
      blocks = pandoc.read(raw.text, raw.format).blocks
      for i, block in ipairs(blocks) do
        if block.t == "Table" then
          return generate_tabular(block)
        end
      end
    end
  end
end
