-- This script adjusts the path to pdf (and other) files in md files 
-- in the 'docs' directory.
-- E.g., the md file refers to 'publications/xxx.pdf'.
-- This script prepends 'docs/' to that path, so it will be found when
-- clicked in 'ricgraph_fulldocumentation.pdf'.
-- Similar for mp4 files.
-- For md files, we go the corresponding html file. 
-- Note that all these (resulting) files are assumed to be present, 
-- which they will be after creating the documentation website.
-- -------------------------------------------------------------------------
-- Rik D.T. Janssen, original version April, 2025.
-- -------------------------------------------------------------------------

function Link(el)
  if el.target:match("^%a+://")  -- Not a web URL (e.g., http:// or https://)
    or el.target:match("^/")     -- Not an absolute path (e.g. /assets/file.pdf)
    or el.target:match("^docs/") then  -- Prevent duplicate "docs/" prefixes
    return el
  end

  if el.target:match('.+/[^/]+%.pdf$') then
    -- For pdf, it is necessary to return the full link.
    el.target = "https://docs.ricgraph.eu/docs/" .. el.target
    return el
  end

  if el.target:match('.+/[^/]+%.mp4$') then
    -- For all others, we do it for safety.
    el.target = "https://docs.ricgraph.eu/docs/" .. el.target
    return el
  end


  if el.target:match('.+/[^/]+%.md$') then
    -- For all others, we do it for safety.
    el.target = "https://docs.ricgraph.eu/docs/" .. el.target
    el.target = el.target:gsub('%.md$', '.html')
    return el
  end
  return el
end

