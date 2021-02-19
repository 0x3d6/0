local gamemon = term

if ccemux then
  gamemon.setTextScale = function() end
else
  if peripheral.find("top") then
    gamemon = peripheral.wrap("top")
  end
end



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
local function sym(a,fr)
  local function obc()
    local _, y = m.getCursorPos()
    if y < 4 or y > 7 then
      w = function(a) end
    else
      w = m.write
    end
  end
  local function l()
    local x, y = m.getCursorPos()
    m.setCursorPos(x-(x-3)%4,y+1)
    obc()
  end
  local function l2()
    l()
  end
  obc()
  if a == 1 then
    stc(c.red)
    sbg(c.white)
    w("\159\131")
    sbg(c.red)
    stc(c.white)
    w(" ")
    l2()
    w("\159\129")
    stc(c.red)
    sbg(c.white)
    w("\145")
  elseif a == 2 then
    stc(c.yellow)
    sbg(c.black)
    w("\151\131")
    stc(c.black)
    sbg(c.yellow)
    w("\148")
    l2()
    w("\130\131\129")
  elseif a == 3 then
    sbg(c.white)
    stc(c.cyan)
    w("\130")
    stc(c.white)
    sbg(c.cyan)
    w("\156\155")
    l2()
    sbg(c.white)
    stc(colors.brown)
    w("\152\129")
    stc(c.cyan)
    w("\138")
  elseif a == 4 then
    sbg(c.yellow)
    stc(c.white)
    w("\151 ")
    stc(c.yellow)
    sbg(c.white)
    w("\148")
    l2()
    w("\142")
    sbg(c.orange)
    w("\143")
    sbg(c.white)
    w("\141")
  elseif a == 5 then
    sbg(colors.orange)
    stc(c.brown)
    w("\140")
    sbg(c.lightGray)
    stc(c.orange)
    w("\131")
    sbg(c.orange)
    stc(c.brown)
    w("\140")
    l2()
    w("   ")
  elseif a == 6 then
    sbg(c.white)
    stc(c.green)
    w("\130\153\144")
    l2()
    stc(c.red)
    w("\138\133")
    stc(c.green)
    sbg(c.red)
    w("\131")
  elseif a == 7 then
    sbg(c.yellow)
    stc(c.white)
    w("\135\131")
    stc(c.green)
    w("\139")
    l2()
    sbg(c.white)
    stc(c.yellow)
    w("\139\143\135")
  elseif a == 8 then
    sbg(colors.purple)
    stc(colors.white)
    w("\159")
    sbg(c.magenta)
    stc(c.green)
    w("\143")
    sbg(c.green)
    stc(c.white)
    w("\137")
    l2()
    sbg(c.magenta)
    stc(c.purple)
    w("\153\153")
    sbg(c.white)
    w("\129")
  else
    sbg(c.white)
    stc(c.red)
    w("???")
    l2()
    sbg(c.red)
    stc(c.white)
    w(a)
  end
  w = m.write
end--[[
m2.setTextScale(.5)
m2.setBackgroundColor(colors.white)
m2.clear()
m2.setCursorPos(19,1)
m2.setTextColor(colors.black)
m2.write(" \24 \24 \24 \24 \24 \24 \24 \24 \24 \24")
m2.setCursorPos(19,2)
m2.write(" Drop items here to  ")
m2.setCursorPos(19,3)
m2.write(" bet them. You can")
m2.setCursorPos(19,4)
m2.write(" add items to your")
m2.setCursorPos(19,5)
m2.write(" bet until the reels")
m2.setCursorPos(19,6)
m2.write(" begin spinning.")
m2.setCursorPos(19,7)
m2.write(" Accepted items:")
m2.setCursorPos(19,8)
m2.write(" \7 Iron ingot")
m2.setCursorPos(1,37)
m2.setBackgroundColor(colors.red)
m2.setTextColor(colors.white)
m2.write(string.rep(" ",70))
m2.setCursorPos(1,38)
m2.write("Please stay behind this line when someone else is playing")]]
--m.setTextScale(.5)
local function drawBorders()
  gamemon.setBackgroundColor(colors.white)
  gamemon.clear()
  gamemon.setBackgroundColor(colors.lightGray)
  gamemon.setCursorPos(1,2)
  gamemon.setTextColor(colors.black)
  gamemon.write((" "):rep(14))
  gamemon.setCursorPos(3,3)
  gamemon.clearLine()
  gamemon.setCursorPos(1,8)
  gamemon.write((" "):rep(14))
  gamemon.setCursorPos(1,9)
  gamemon.clearLine()
  gamemon.setBackgroundColor(colors.gray)
  gamemon.setCursorPos(1,1)
  gamemon.clearLine()
  for i=2,10 do
    gamemon.setCursorPos(1,i)
    gamemon.write(" ")
    gamemon.setCursorPos(15,i)
    gamemon.write(" ")
  end
  gamemon.clearLine()
end
local function clearReels()
for i=4,7 do
  gamemon.setCursorPos(2,i)
  sbg(colors.white)
  stc(c.lightGray)
  w("\149   |   |   ")
  stc(c.white)
  sbg(c.lightGray)
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
      sym(r1[i],0)
    else
    m.setCursorPos(4*i-1,5+f)
    sym(r1[i],0)
    m.setCursorPos(4*i-1,5+f+3)
    sym(r2[i],0)
    end
  end
  os.sleep(.08)
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
