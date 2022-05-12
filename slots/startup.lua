require("../common")

-- Print subtitles out of bounds (would be visible if we aren't using a monitor) in case we don't have speakers
local leftSpeaker = {
  playSound = function()
    term.setTextColor(colors.purple)
    term.setCursorPos(1, 11)
    print("*Ding*!")
  end
}
local rightSpeaker = {
  playSound = function()
    term.setTextColor(colors.purple)
    term.setCursorPos(9, 11)
    print("*DING*!")
  end
}

local reelsMonitor = Display("top", .5) or (ccemux and Display(term) or panic())
if peripheral.find("left") then
  leftSpeaker = peripheral.wrap("left")
end
if peripheral.find("right") then
  rightSpeaker = peripheral.wrap("right")
end

local config = require("config")
local symbols = config.symbols
local symbolsList = {}
local symbolCount = 0

local reelResult = {"SEVEN", "SEVEN", "SEVEN"}

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
assert(config.extraSpinTime >= -4, "extraSpinTime is too low")



-- <silliness>
local modem = peripheral.wrap("bottom")
local m2 = peripheral.wrap("monitor_3131")
-- </silliness>


local function drawSymbol(symbolType)
  --symbolType = symbolsList[symbolType] -- this is temporary i swear

  -- Fall back to an "error" symbol if we somehow got one that doesn't exist
  local symbol = symbols[symbolType] or {
    {"???","eee","000"},
    {symbolType:sub(1,3),"000","eee"}
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
m2.write("Please stay behind this line when someone else is playing")
  ]]

local function drawBorders()
  reelsMonitor.setBackgroundColor(colors.white)
  reelsMonitor.clear()
  reelsMonitor.setBackgroundColor(colors.lightGray)
  reelsMonitor.setTextColor(colors.black)
  reelsMonitor.clearLineAt(2, 14)
  reelsMonitor.clearLineAt(3)
  reelsMonitor.clearLineAt(8, 14)
  reelsMonitor.clearLineAt(9)
  reelsMonitor.setBackgroundColor(colors.gray)
  reelsMonitor.clearLineAt(1)
  for y = 2, 10 do
    reelsMonitor.setCursorPos(1, y)
    reelsMonitor.write(" ")
    reelsMonitor.setCursorPos(15, y)
    reelsMonitor.write(" ")
  end
  reelsMonitor.clearLine()
end

local function clearReels()
  for y = 4, 7 do
    reelsMonitor.setCursorPos(2, y)

    reelsMonitor.setBackgroundColor(colors.white)
    reelsMonitor.setTextColor(colors.lightGray)
    reelsMonitor.write("\149   |   |   ")

    reelsMonitor.setBackgroundColor(colors.lightGray)
    reelsMonitor.setTextColor(colors.white)
    reelsMonitor.write("\149")
  end
end

drawBorders()
clearReels()

local function getRandomSymbols(animationRow)
  local symbolOutput = {}
  local landedSymbols = math.floor((animationRow + 1) / 5) -- The number of symbols that have now stopped moving

  for idx = 1, 3 do -- We need to pick a symbol for each of the three reels
    if idx > landedSymbols then
      table.insert(symbolOutput, symbolsList[math.random(symbolCount)]) -- Throw in a random symbol, we won't land on this one
    else
      table.insert(symbolOutput, reelResult[idx]) -- This is it! We need to get the symbol that we're supposed to land on
    end
  end

  return symbolOutput
end

local function animateSpin()
  local reelCache = {getRandomSymbols(0), getRandomSymbols(0)}

  for animationRow = 0 - config.extraSpinTime, 16 do -- We're looping over "rows" of symbols that slide down the screen
    for frame = 0, 2 do
      for symbolInstance = 1, 6 do -- We can have up to six symbols on the screen at once
        -- Determine which column and layer this symbol belongs to
        local column = (symbolInstance - 1) % 3 + 1
        local layer = math.floor((symbolInstance - 1) / 3) + 1

        -- And get the exact coordinates from that information
        local x = 4 * column - 1
        local y = 3 * layer + frame
        reelsMonitor.setCursorPos(x, y)

        if animationRow <= 5 * column then -- Stop animating this column when we stop on a symbol!
          drawSymbol(reelCache[layer][column])

          -- Erase the little spaces in between the symbols
          if y > 4 then
            reelsMonitor.setBackgroundColor(colors.white)
            reelsMonitor.setCursorPos(x, y - 1)
            reelsMonitor.write("   ")
          end
        end
      end
      os.sleep(.08) -- Wait for a moment before drawing the next frame
      reelsMonitor.clearLineAt(11) -- Erase the subtitles we drew if we didn't have speakers
    end
    -- Move the layer down, and then load in a new one
    reelCache[2] = reelCache[1]
    reelCache[1] = getRandomSymbols(animationRow)

    if animationRow > 0 and animationRow % 5 == 0 then -- This is the situation where one of the reels just stopped on a symbol
      if ((animationRow == 15) and (reelResult[1] == reelResult[2] and reelResult[2] == reelResult[3])) or (reelResult[math.floor(animationRow/5)] == 1) then
        rightSpeaker.playSound("entity.experience_orb.pickup",.5,1.2)
      end
      leftSpeaker.playSound("entity.experience_orb.pickup",.5,.5)
    else
      --leftSpeaker.playNote("piano",1)
    end
  end
end
animateSpin()
