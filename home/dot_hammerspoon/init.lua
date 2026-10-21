-- Hyper+M: jump the cursor to the centre of the next display and focus its
-- frontmost window. Warping avoids crossing the top edge of a full-screen
-- display, which reveals the menu bar and leaves it stuck there.
hs.hotkey.bind({ "ctrl", "alt", "shift", "cmd" }, "m", function()
  local screen = hs.mouse.getCurrentScreen():next()
  hs.mouse.absolutePosition(hs.geometry.rectMidPoint(screen:fullFrame()))
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:screen() == screen then
      win:focus()
      return
    end
  end
end)
