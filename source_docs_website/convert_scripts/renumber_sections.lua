-- This script renumbers section headings in GitHub Markdown files.
-- It will:
-- Markdown # -> Unnumber H1 headings (no prefix)
-- Markdown ## ->: Number H2 as 1, 2, etc. (independent counter)
-- Markdown ### ->: Number H3 as 1.1, 1.2, etc. (resetting per H2 section)
-- Markdown #### ->: Number H4 as 1.1.1, 1.1.2, etc. (resetting per H3 subsec)
-- The \u{2002} below is an unicode 'en space'.
-- -------------------------------------------------------------------------
-- Rik D.T. Janssen, original version April, 2025.
-- -------------------------------------------------------------------------

local h2_count = 0
local h3_count = 0
local h4_count = 0

function Header(el)
  if el.level == 1 then
    -- Reset all counters for new top-level section
    h2_count = 0
    h3_count = 0
    h4_count = 0
    el.classes:insert('unnumbered')
    return el

  elseif el.level == 2 then
    -- Increment H2 counter and reset H3/H4
    h2_count = h2_count + 1
    h3_count = 0
    h4_count = 0
    -- local num = pandoc.Str(tostring(h2_count) .. " ")
    local num = pandoc.Str(tostring(h2_count) .. "\u{2002}")
    table.insert(el.content, 1, num)
    el.classes:insert('unnumbered')
    return el

  elseif el.level == 3 then
    -- Increment H3 counter and reset H4
    h3_count = h3_count + 1
    h4_count = 0
    -- local num = pandoc.Str(tostring(h2_count) .. "." .. tostring(h3_count) .. " ")
    local num = pandoc.Str(tostring(h2_count) .. "." .. tostring(h3_count) .. "\u{2002}")
    table.insert(el.content, 1, num)
    el.classes:insert('unnumbered')
    return el

  elseif el.level == 4 then
    -- Increment H4 counter
    h4_count = h4_count + 1
    -- local num = pandoc.Str(tostring(h2_count) .. "." .. tostring(h3_count) .. "." .. tostring(h4_count) .. " ")
    local num = pandoc.Str(tostring(h2_count) .. "." .. tostring(h3_count) .. "." .. tostring(h4_count) .. "\u{2002}")
    table.insert(el.content, 1, num)
    el.classes:insert('unnumbered')
    return el
  end
end


