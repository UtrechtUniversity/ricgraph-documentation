-- This script replaces the '.md' in links to '.html'.
-- We need this, because on a website we only have html files.
function Link(el)
  if el.target:match('%.md$') then
    el.target = el.target:gsub('%.md$', '.html')
  end
  return el
end

