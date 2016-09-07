Table = {
  items = {},
  offset = 1
}

function Table:new(renderHeader, renderItem, newLine)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.renderHeader = renderHeader
  o.renderItem = renderItem
  o.newLine = newLine
  return o
end

function Table:render()
  if (self.offset > #self.items) then
    print("Invalid offset")
  end
  self.renderHeader()
  for i=self.offset,#self.items do
    self.newLine()
    self.renderItem(self.items[i], i)
  end
end

return Table