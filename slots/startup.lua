local reelsMonitor = term

if ccemux then
  reelsMonitor.setTextScale = function() end
else
  if peripheral.find("top") then
    reelsMonitor = peripheral.wrap("top")
  end
end

local symbols = require("config")
local symbolsList = {}
local symbolCount = 0

local function checkBlitSanity(blitLine)
  assert(#blitLine == 3, "Symbol lines must have 3 arguments for term.blit")

  for idx, symbolText in pairs(blitLine) do
    assert(type(symbolText) == "string", "Symbol lines must be composed of three blit valid strings")
    assert(#symbolText == 3, "Symbols must be 3 characters wide")
    if (idx > 1) then -- The first argument to blit doesn't need to be hex
      assert(symbolText:find("^[0-9a-f]+$"), "Last two blit arguments need to be hex codes")
    end
  end
end

for symbolName, symbol in pairs(symbols) do
  -- Just really quick make sure these symbols are valid (3 chars wide, 2 high)
  assert(#symbol == 2, "Symbols must be 2 lines")
  for _, blitLine in pairs(symbol) do
    checkBlitSanity(blitLine)
  end

  table.insert(symbolsList, symbolName) -- Add it to the list of symbols to use in the animation
  symbolCount = symbolCount + 1
end

assert(symbolCount > 1, "Not enough symbols") -- A game of chance would not be possible if only one symbol is defined




-- <silliness>
local m = term
if peripheral.find("top") then m = peripheral.wrap("top") end
local stc = m.setTextColor
local sbg = m.setBackgroundColor
local c = colors
local w = m.write
local s = peripheral.wrap("right")
local s2 =peripheral.wrap("left")
local modem = peripheral.wrap("bottom")
local m2 = peripheral.wrap("monitor_3131")
-- </silliness>










local function drawSymbol(symbolType,fr)
  symbolType = symbolsList[symbolType] -- this is temporary i swear

  -- Fall back to an "error" symbol if we somehow got one that doesn't exist
  local symbol = symbols[symbolType] or {
    {"???","eee","000"},
    {symbolType.sub(1,3),"000","eee"}
  }

  for idx = 1, 2 do
    local x, y = reelsMonitor.getCursorPos()

    if y >= 4 and y <= 7 then
      reelsMonitor.blit(unpack(symbol[idx])) -- Draw the three characters of this line of the cute little symbol
    end

    if idx == 1 then -- If we just drew the first line,
      reelsMonitor.setCursorPos(x-(x-3)%4,y+1) -- Go to the beginning of the next line
    end
  end

  -- We're not going to put the cursor back where it was before this call
end

--[[
m2.setTextScale(.5)
m2.setBackgroundColor(colors.white)
m2.clear()
m2.setCursorPos(1,38)
m2.write("Please stay behind this line when someone else is playing")]]

reelsMonitor.setTextScale(.5)
local function clearLineAt(y,isShort)
  local oldX, oldY = reelsMonitor.getCursorPos()
  reelsMonitor.setCursorPos(1, y)
  if isShort then
    reelsMonitor.write((" "):rep(14))
  else
    reelsMonitor.clearLine()
  end
  reelsMonitor.setCursorPos(oldX, oldY)
end
local function drawBorders()
  reelsMonitor.setBackgroundColor(colors.white)
  reelsMonitor.clear()
  reelsMonitor.setBackgroundColor(colors.lightGray)
  reelsMonitor.setTextColor(colors.black)
  clearLineAt(2, true)
  clearLineAt(3)
  clearLineAt(8, true)
  clearLineAt(9)
  reelsMonitor.setBackgroundColor(colors.gray)
  clearLineAt(1)
  for idx = 2, 10 do
    reelsMonitor.setCursorPos(1, idx)
    reelsMonitor.write(" ")
    reelsMonitor.setCursorPos(15, idx)
    reelsMonitor.write(" ")
  end
  reelsMonitor.clearLine()
end
local function clearReels()
  for idx = 4, 7 do
    reelsMonitor.setCursorPos(2, idx)
    sbg(colors.white)
    stc(colors.lightGray)
    w("\149   |   |   ")
    stc(colors.white)
    sbg(colors.lightGray)
    w("\149")
  end
end
drawBorders()
clearReels()
local function rand(fr)
  local a, b, c
  if fr >= 4 then a = final[1] else a = math.random(8) end
  if fr >= 9 then b = final[2] else b = math.random(8) end
  if fr >= 14 then c = final[3] else c = math.random(8) end
  return {a,b,c}
end
--os.sleep(5)
local function dospin()
--modem.open(os.getComputerID())
--modem.transmit(1,os.getComputerID(),"64 iron")
--local _, _, _, _, msg = os.pullEvent("modem_message")
msg = "111"
--modem.close(os.getComputerID())
final = {tonumber(msg:sub(1,1)),tonumber(msg:sub(2,2)),tonumber(msg:sub(3,3))}
r1 = rand(0)
r2 = rand(0)
for k=-5,16 do
for f=-2,0 do
  clearReels()
  --if f == 0 then r2 = {2,2,2} end
  for i=1,3 do
    if k > 5*i then
      m.setCursorPos(4*i-1,5)
      drawSymbol(r1[i],0)
    else
    m.setCursorPos(4*i-1,5+f)
    drawSymbol(r1[i],0)
    m.setCursorPos(4*i-1,5+f+3)
    drawSymbol(r2[i],0)
    end
  end
  os.sleep(.08) -- what???
end
r2 = r1
r1 = rand(k)
if k>0 and k%5 == 0 then
if ((k == 15) and (final[1] == final[2] and final[2] == final[3])) or (final[math.floor(k/5)] == 1) then
  --s2.playSound("entity.experience_orb.pickup",.5,1.2)
end
--s.playSound("entity.experience_orb.pickup",.5,.5)
else
--s.playNote("piano",1)
end
end
end
dospin()
