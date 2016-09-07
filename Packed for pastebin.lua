local component = require("component")
local event = require("event")
local term = require("term")

MiningLaserController = {
  layerOffset = 1,
  onlyOres = true,
  silktouch = false,
}

function MiningLaserController:new(address)
  o = {}
  setmetatable(o, self)
  self.__index = self
  o.proxy = component.proxy(address)
  return o
end

function MiningLaserController:getState()
  status, isActive, energy, currentLayer, mined, total = self.proxy.state()
  return {
    status = status,
    isActive = isActive,
    energy = energy,
    currentLayer = currentLayer,
    mined = mined,
    total = total,
  }
end

function MiningLaserController:start()
  state = self:getState()
  if not state.isActive then
    self.proxy.offset(self.layerOffset)
    self.proxy.onlyOres(self.onlyOres)
    self.proxy.silktouch(self.silktouch)
    self.proxy.start()
  end
end

function MiningLaserController:stop()
  state = self:getState()
  if state.isActive then
    self.proxy.stop()
  end
end

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

function renderHeader()
  term.write("Status")
end

function newLine()
	col, row = term.getCursor()
	term.setCursor(1, row + 1)
end

function renderItem(item, index)
  state = item:getState()
  term.write(state.status .. " " .. tostring(state.isActive) .. " " .. state.energy .. " " .. state.currentLayer .. " " .. state.mined .. " " .. state.total)
end

local running = true
local miners = {}
for address,type in component.list("warpdriveMiningLaser", true) do
  table.insert(miners, MiningLaserController:new(address))
end
local table = Table:new(renderHeader, renderItem, newLine)
table.items = miners
term.clear()
for key,miner in pairs(miners) do
  miner:start()
end
while running do
  term.setCursor(1,1)
  table:render()
  newLine()
  print("Mining in progress. Press any key to stop.")
  params = { event.pull(0.1) }
  eventName = params[1]
  if eventName == "key_down" then
  	running = false
  end
end
for key,miner in pairs(miners) do
  miner:stop()
end