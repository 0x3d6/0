function Display(networkName, textScale)
  local mon

  -- If we get passed a monitor or term object
  if type(networkName) == "table" then
    mon = networkName
  elseif peripheral.find(networkName) then
    mon = peripheral.wrap(networkName)
    mon.setTextScale(textScale or 1)
  end

  if mon then
    local monitorHelper = {}

    function monitorHelper.clearLineAt(y, length)
      local oldX, oldY = mon.getCursorPos()
      mon.setCursorPos(1, y)
      if length then
        mon.write((" "):rep(length))
      else
        mon.clearLine()
      end
      mon.setCursorPos(oldX, oldY)
    end

    return setmetatable(monitorHelper, {__index = mon})
  else
    return false
  end
end

function panic()
  print("BUMMER!!!!!")
  os.sleep(69)
  os.reboot()
end
