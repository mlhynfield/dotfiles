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
		if af.x ~= bf.x then return af.x < bf.x end
		if af.y ~= bf.y then return af.y < bf.y end
		return a:id() < b:id()
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

-- Messages: Ctrl+[1-9] → pinned conversations
local messagesBundleID = "com.apple.MobileSMS"
local messagesModal = hs.hotkey.modal.new()

for i = 1, 9 do
	messagesModal:bind({ "ctrl" }, tostring(i), function()
		local app = hs.application.get(messagesBundleID)
		if app then
			hs.eventtap.keyStroke({ "cmd" }, tostring(i), 0, app)
		end
	end)
end

-- Enable the modal only while Messages is frontmost
messagesWatcher = hs.application.watcher.new(function(_, eventType, app)
	if eventType == hs.application.watcher.activated then
		if app:bundleID() == messagesBundleID then
			messagesModal:enter()
		else
			messagesModal:exit()
		end
	end
end)
messagesWatcher:start()

-- Handle the case where Messages is already frontmost on config load
local current = hs.application.frontmostApplication()
if current and current:bundleID() == messagesBundleID then
	messagesModal:enter()
end
