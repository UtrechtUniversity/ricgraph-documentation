-- This script makes sure the images in the .md files
-- will scale correctly in the pdf file to be generated.
function RawInline(el)
  if el.format == "html" then
    local src = el.text:match('src="([^"]+)"')
    local width = el.text:match('width="([^"]+)"')
    if src then
      return pandoc.Image("", src, "", {width = width})
    end
  end
  return el
end


