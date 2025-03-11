-- This script replaces the '.md' in links to nothing.
-- In the pdf to be generated, we use internal pdf links.
function Link(el)
  if el.target:match('%.md$') then
    el.target = el.target:gsub('%.md$', '')
  end
  return el
end

