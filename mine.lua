local MiningLaserController = require('miner/MiningLaserController')
local Table = require('miner/Table')
local component = require("component")
local event = require("event")
local term = require("term")

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