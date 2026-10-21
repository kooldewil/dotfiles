-- Lets the `hs` CLI talk to Hammerspoon (reload, debugging).
require("hs.ipc")

-- Hyper+M or Cmd+middle-click: jump the cursor to the centre of the next
-- display and focus its frontmost window. Warping avoids crossing the top edge
-- of a full-screen display, which reveals the menu bar and leaves it stuck there.
local function jumpToNextScreen()
  local screen = hs.mouse.getCurrentScreen():next()
  hs.mouse.absolutePosition(hs.geometry.rectMidPoint(screen:fullFrame()))
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:screen() == screen then
      win:focus()
      return
    end
  end
end

hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "m", jumpToNextScreen)

-- Global so the tap isn't garbage-collected.
middleClickTap = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
  local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
  if button == 2 and event:getFlags():containExactly({ "cmd" }) then
    jumpToNextScreen()
    return true
  end
  return false
end)
middleClickTap:start()
