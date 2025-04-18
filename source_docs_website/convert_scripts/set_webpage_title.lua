-- This script sets the webpage title to the <h1> heading,
-- that is the '#' in the md file. It ensures that <title> has
-- a useful value, i.e. "Read more..." instead of "read-more".
-- -------------------------------------------------------------------------
-- Rik D.T. Janssen, original version April, 2025.
-- -------------------------------------------------------------------------

function Pandoc(doc)
  -- Find the first heading in the document
  local first_h1 = nil
  for _, block in ipairs(doc.blocks) do
    if block.t == "Header" and block.level == 1 then
      first_h1 = block
      break
    end
  end

  -- Set pagetitle meta value
  if first_h1 then
    local title = pandoc.utils.stringify(first_h1.content)
    doc.meta.pagetitle = pandoc.MetaInlines(title)
  end
  
  return doc
end

