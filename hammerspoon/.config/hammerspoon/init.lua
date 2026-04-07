local mods = { "cmd", "ctrl" }

hs.hotkey.bind(mods, "right", function()
	hs.window.focusedWindow():focusWindowEast()
end)

hs.hotkey.bind(mods, "left", function()
	hs.window.focusedWindow():focusWindowWest()
end)

hs.hotkey.bind(mods, "up", function()
	hs.window.focusedWindow():focusWindowNorth()
end)

hs.hotkey.bind(mods, "down", function()
	hs.window.focusedWindow():focusWindowSouth()
end)

-- Cycle through windows on current screen/space
local function cycleWindows(forward)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local currentScreen = win:screen()
	local windows = hs.fnutils.filter(hs.window.visibleWindows(), function(w)
		return w:screen() == currentScreen and w:isStandard()
	end)
	if #windows < 2 then
		return
	end
	table.sort(windows, function(a, b)
		local af, bf = a:frame(), b:frame()
		if af.x ~= bf.x then
			return af.x < bf.x
		end
		return af.y < bf.y
	end)
	for i, w in ipairs(windows) do
		if w:id() == win:id() then
			local target
			if forward then
				target = windows[i % #windows + 1]
			else
				target = windows[(i - 2) % #windows + 1]
			end
			target:focus()
			return
		end
	end
end

hs.hotkey.bind({ "cmd", "alt" }, "tab", function()
	cycleWindows(true)
end)
hs.hotkey.bind({ "cmd", "alt", "shift" }, "tab", function()
	cycleWindows(false)
end)
