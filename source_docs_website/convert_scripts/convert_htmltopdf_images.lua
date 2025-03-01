function RawInline(elem)
  if elem.format == "html" then
    local src = elem.text:match('src="([^"]+)"')
    local width = elem.text:match('width="([^"]+)"')
    if src then
      return pandoc.Image("", src, "", {width = width})
    end
  end
  return elem
end


