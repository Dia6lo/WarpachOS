local component = require("component")

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

return MiningLaserController