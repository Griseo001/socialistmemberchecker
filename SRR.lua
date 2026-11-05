local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local UserInputService = game:GetService("UserInputService")

local GROUP_ID = 408126707
local HEAD_ROLE = "Head of State"
local EXTRA_ROLES = {"head of state", "cs general"} -- always whitelisted (lowercase)
local FRIEND_NAME = "TCO_TACEMPIRE"
local localPlayer = Players.LocalPlayer

local GROUP_ICON = "rbxthumb://type=GroupIcon&id=" .. GROUP_ID .. "&w=150&h=150"

local GOLD = Color3.fromRGB(255, 200, 0)
local MEMBER_COLOR = Color3.fromRGB(200, 200, 200)
local GUEST_COLOR = Color3.fromRGB(120, 120, 120)
local OUTLINE_COLOR = Color3.fromRGB(110, 110, 110)
local PANEL_COLOR = Color3.fromRGB(58, 58, 58)
local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)
local RED = Color3.fromRGB(230, 0, 0)

-- Group name and whitelisted ranks (CS roles, Head of State, CS General)
local GROUP_NAME = "Socialist Red Republic TCO"
local WHITELISTED_RANKS = {}

local function hasCS(roleName)
	return string.find(" " .. string.lower(roleName) .. " ", "%f[%a]cs%f[%A]") ~= nil
end

do
	local success, info = pcall(function()
		return GroupService:GetGroupInfoAsync(GROUP_ID)
	end)
	if success and info then
		if info.Name then
			GROUP_NAME = info.Name
		end
		if info.Roles then
			for _, role in ipairs(info.Roles) do
				if hasCS(role.Name) or table.find(EXTRA_ROLES, string.lower(role.Name)) then
					WHITELISTED_RANKS[role.Rank] = true
				end
			end
		end
	else
		warn("Could not load group info, nobody will be whitelisted")
	end
end

local function isWhitelisted(player)
	local success, rank = pcall(function()
		return player:GetRankInGroup(GROUP_ID)
	end)
	return success and rank > 0 and WHITELISTED_RANKS[rank] == true
end

if not isWhitelisted(localPlayer) then
	local denyGui = Instance.new("ScreenGui")
	denyGui.Name = "AccessDenied"
	denyGui.ResetOnSpawn = false
	denyGui.IgnoreGuiInset = true
	denyGui.Parent = localPlayer:WaitForChild("PlayerGui")

	local denyLabel = Instance.new("TextLabel")
	denyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	denyLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
	denyLabel.Size = UDim2.new(0, 600, 0, 80)
	denyLabel.BackgroundColor3 = BLACK
	denyLabel.BackgroundTransparency = 0.3
	denyLabel.BorderSizePixel = 0
	denyLabel.Font = Enum.Font.Roboto
	denyLabel.TextScaled = true
	denyLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
	denyLabel.Text = "JOIN SRR TO ACCESS THE SCRIPT"
	denyLabel.Parent = denyGui

	return
end

----------------------------------------------------------------
-- UI (flat dark panel, white borders, tab buttons)
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "GroupInfo"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

local function styleBox(obj)
	obj.BackgroundColor3 = PANEL_COLOR
	obj.BackgroundTransparency = 0
	obj.BorderSizePixel = 2
	obj.BorderColor3 = WHITE
	obj.BorderMode = Enum.BorderMode.Inset
end

local function styleText(obj, size)
	obj.Font = Enum.Font.Arial
	obj.TextColor3 = WHITE
	obj.TextSize = size
end

local NORMAL_WIDTH = 520
local WIDE_WIDTH = 800
local expanded = false
local hideTags = false -- "disable shown rank" setting

local window = Instance.new("Frame")
window.Name = "Window"
window.AnchorPoint = Vector2.new(1, 0)
window.Position = UDim2.new(1, -10, 0, 50)
window.Size = UDim2.new(0, NORMAL_WIDTH, 0, 384)
window.BackgroundTransparency = 1
window.Parent = gui

-- Small button to reopen the window after pressing X
local openButton = Instance.new("TextButton")
openButton.Name = "OpenWindow"
openButton.AnchorPoint = Vector2.new(1, 0)
openButton.Position = window.Position
openButton.Size = UDim2.new(0, 100, 0, 36)
styleBox(openButton)
styleText(openButton, 22)
openButton.Text = "open"
openButton.Visible = false
openButton.Parent = gui

-- Tabs row (5 tabs, each 20% of the window width)
local TAB_COUNT = 5
local function makeTab(text, index)
	local b = Instance.new("TextButton")
	b.Position = UDim2.new((index - 1) / TAB_COUNT, 0, 0, 0)
	b.Size = UDim2.new(1 / TAB_COUNT, 0, 0, 40)
	styleBox(b)
	styleText(b, 22)
	b.TextScaled = true
	b.Text = text
	b.Parent = window
	local c = Instance.new("UITextSizeConstraint")
	c.MaxTextSize = 24
	c.MinTextSize = 10
	c.Parent = b
	return b
end

local rankTab = makeTab("your rank", 1)
local membersTab = makeTab("members", 2)
local tacsTab = makeTab("tacs", 3)
local infoTab = makeTab("info", 4)
local settingsTab = makeTab("Settings", 5)

-- Title row + expand button + red X
local titleLabel = Instance.new("TextLabel")
titleLabel.Position = UDim2.new(0, 0, 0, 40)
titleLabel.Size = UDim2.new(1, -96, 0, 44)
styleBox(titleLabel)
styleText(titleLabel, 24)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
titleLabel.Text = " Your rank"
titleLabel.Parent = window

local expandButton = Instance.new("TextButton")
expandButton.Name = "ExpandWidth"
expandButton.Position = UDim2.new(1, -96, 0, 40)
expandButton.Size = UDim2.new(0, 48, 0, 44)
styleBox(expandButton)
styleText(expandButton, 26)
expandButton.Text = "<>"
expandButton.Parent = window

expandButton.MouseButton1Click:Connect(function()
	expanded = not expanded
	window.Size = UDim2.new(0, expanded and WIDE_WIDTH or NORMAL_WIDTH, 0, 384)
	expandButton.Text = expanded and "><" or "<>"
end)

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseOrDrag"
closeButton.Position = UDim2.new(1, -48, 0, 40)
closeButton.Size = UDim2.new(0, 48, 0, 44)
closeButton.BackgroundTransparency = 1
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.Arial
closeButton.TextSize = 48
closeButton.TextColor3 = RED
closeButton.TextStrokeColor3 = BLACK
closeButton.TextStrokeTransparency = 0
closeButton.Text = "X"
closeButton.Parent = window

-- The X: click it to close, hold and drag it to move the window
local dragging = false
local dragMoved = false
local dragStart, startPos

closeButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragMoved = false
		dragStart = input.Position
		startPos = window.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then
			dragMoved = true
		end
		if dragMoved then
			window.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch) then
		dragging = false
		if not dragMoved then
			openButton.Position = window.Position
			window.Visible = false
			openButton.Visible = true
		end
	end
end)

openButton.MouseButton1Click:Connect(function()
	window.Visible = true
	openButton.Visible = false
end)

-- Content area
local content = Instance.new("Frame")
content.Position = UDim2.new(0, 0, 0, 84)
content.Size = UDim2.new(1, 0, 0, 300)
styleBox(content)
content.Parent = window

local function makePage()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = content
	return p
end

local function makeScroll(parent)
	local s = Instance.new("ScrollingFrame")
	s.Position = UDim2.new(0, 6, 0, 6)
	s.Size = UDim2.new(1, -12, 1, -12)
	s.BackgroundTransparency = 1
	s.BorderSizePixel = 0
	s.ScrollBarThickness = 6
	s.ScrollBarImageColor3 = WHITE
	s.ScrollingDirection = Enum.ScrollingDirection.Y
	s.CanvasSize = UDim2.new(0, 0, 0, 0)
	s.AutomaticCanvasSize = Enum.AutomaticSize.Y
	s.Parent = parent
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 4)
	l.Parent = s
	return s
end

local rankPage = makePage()
local membersPage = makePage()
local tacsPage = makePage()
local settingsPage = makePage()

-- Your rank page: credit box on top, rank below it
local creditBox = Instance.new("TextLabel")
creditBox.Position = UDim2.new(0, 6, 0, 6)
creditBox.Size = UDim2.new(1, -12, 0, 40)
styleBox(creditBox)
styleText(creditBox, 22)
creditBox.TextScaled = true
creditBox.Text = "(Made by Nationalflagofgerman)"
creditBox.Parent = rankPage
local creditConstraint = Instance.new("UITextSizeConstraint")
creditConstraint.MaxTextSize = 24
creditConstraint.Parent = creditBox

local rankLabel = Instance.new("TextLabel")
rankLabel.Position = UDim2.new(0, 0, 0, 52)
rankLabel.Size = UDim2.new(1, 0, 1, -52)
rankLabel.BackgroundTransparency = 1
styleText(rankLabel, 48)
rankLabel.TextScaled = true
rankLabel.Text = "Checking group..."
rankLabel.Parent = rankPage
local rankConstraint = Instance.new("UITextSizeConstraint")
rankConstraint.MaxTextSize = 56
rankConstraint.Parent = rankLabel

local scroll = makeScroll(membersPage)
local tacsScroll = makeScroll(tacsPage)

-- Settings page: disable shown rank toggle
local hideButton = Instance.new("TextButton")
hideButton.Name = "DisableShownRank"
hideButton.Position = UDim2.new(0, 6, 0, 6)
hideButton.Size = UDim2.new(1, -12, 0, 44)
styleBox(hideButton)
styleText(hideButton, 24)
hideButton.Text = "disable shown rank: OFF"
hideButton.Parent = settingsPage

-- Tab switching
local pages = {
	{page = rankPage, tab = rankTab, title = " Your rank"},
	{page = membersPage, tab = membersTab, title = " Group members in server"},
	{page = tacsPage, tab = tacsTab, title = " Tacs Member"},
	{page = settingsPage, tab = settingsTab, title = " Settings"},
}

local function showPage(index)
	for i, p in ipairs(pages) do
		p.page.Visible = (i == index)
		p.tab.BackgroundColor3 = (i == index) and Color3.fromRGB(90, 90, 90) or PANEL_COLOR
	end
	titleLabel.Text = pages[index].title
end

for i, p in ipairs(pages) do
	p.tab.MouseButton1Click:Connect(function()
		showPage(i)
	end)
end
showPage(2)

----------------------------------------------------------------
-- Members list
----------------------------------------------------------------
local function makeListLabel(text, color, order)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -10, 0, 34)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Arial
	l.TextSize = 26
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.TextColor3 = color
	l.LayoutOrder = order
	l.Text = text
	l.Parent = scroll
	return l
end

-- Info setting (toggles Off / Account age)
local INFO_MODES = {"Off", "Account age"}
local infoMode = 2
infoTab.Text = "info: " .. INFO_MODES[infoMode]

local entryData = {}

local function formatDays(d)
	local y = math.floor(d / 365)
	if y > 0 then return y .. "y " .. (d % 365) .. "d" end
	return d .. "d"
end

local function entryText(player, info)
	local text = player.Name .. " - " .. info.role
	if infoMode == 2 then
		text ..= " - " .. formatDays(player.AccountAge)
	end
	return text
end

local function refreshList()
	for player, data in pairs(entryData) do
		local entry = scroll:FindFirstChild("Entry_" .. player.UserId)
		if entry then
			entry.Text = entryText(player, data.info)
		end
	end
end

infoTab.MouseButton1Click:Connect(function()
	infoMode = infoMode % #INFO_MODES + 1
	infoTab.Text = "info: " .. INFO_MODES[infoMode]
	refreshList()
end)

----------------------------------------------------------------
-- Group info + overhead tags
----------------------------------------------------------------
local function getGroupInfo(player)
	local success, result = pcall(function()
		return {
			inGroup = player:IsInGroup(GROUP_ID),
			rank = player:GetRankInGroup(GROUP_ID),
			role = player:GetRoleInGroup(GROUP_ID),
		}
	end)
	if success then
		return result
	end
	warn("Group check failed for " .. player.Name .. ": " .. tostring(result))
	return nil
end

local function getColor(info)
	if not info.inGroup then
		return GUEST_COLOR
	end
	if string.lower(info.role) == string.lower(HEAD_ROLE) then
		return GOLD
	end
	return MEMBER_COLOR
end

local function addOutline(textLabel)
	local stroke = Instance.new("UIStroke")
	stroke.Color = OUTLINE_COLOR
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	stroke.Parent = textLabel
end

local function createTag(character, text, color, showIcon)
	local head = character:WaitForChild("Head", 10)
	if not head then return end

	local old = head:FindFirstChild("RankTag")
	if old then old:Destroy() end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "RankTag"
	billboard.Size = UDim2.new(0, 300, 0, 150)
	billboard.StudsOffset = Vector3.new(0, 4.3, 0)
	billboard.AlwaysOnTop = false
	billboard.MaxDistance = 80
	billboard.Adornee = head
	billboard.Enabled = not hideTags
	billboard.Parent = head

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = 1
	container.Parent = billboard

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Vertical
	list.HorizontalAlignment = Enum.HorizontalAlignment.Center
	list.VerticalAlignment = Enum.VerticalAlignment.Bottom
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 2)
	list.Parent = container

	if showIcon then
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 70, 0, 70)
		icon.BackgroundTransparency = 1
		icon.Image = GROUP_ICON
		icon.LayoutOrder = 1
		icon.Parent = container

		local groupLabel = Instance.new("TextLabel")
		groupLabel.Size = UDim2.new(1, 0, 0, 24)
		groupLabel.BackgroundTransparency = 1
		groupLabel.TextScaled = false
		groupLabel.TextSize = 22
		groupLabel.Font = Enum.Font.Roboto
		groupLabel.Text = GROUP_NAME
		groupLabel.TextColor3 = color
		groupLabel.LayoutOrder = 2
		groupLabel.Parent = container
		addOutline(groupLabel)
	end

	local tag = Instance.new("TextLabel")
	tag.Size = UDim2.new(1, 0, 0, 44)
	tag.BackgroundTransparency = 1
	tag.TextScaled = false
	tag.TextSize = 40
	tag.Font = Enum.Font.Roboto
	tag.Text = text
	tag.TextColor3 = color
	tag.LayoutOrder = 3
	tag.Parent = container
	addOutline(tag)
end

-- Show / hide the rank, group name, and image above everyone's head
local function applyTagVisibility()
	for _, p in ipairs(Players:GetPlayers()) do
		local head = p.Character and p.Character:FindFirstChild("Head")
		local tag = head and head:FindFirstChild("RankTag")
		if tag then
			tag.Enabled = not hideTags
		end
	end
end

hideButton.MouseButton1Click:Connect(function()
	hideTags = not hideTags
	hideButton.Text = "disable shown rank: " .. (hideTags and "ON" or "OFF")
	applyTagVisibility()
end)

local function addToList(player, info)
	if not info.inGroup then return end

	local entryName = "Entry_" .. player.UserId
	if scroll:FindFirstChild(entryName) then return end

	local entry = makeListLabel("", getColor(info), 255 - info.rank)
	entry.Name = entryName
	entryData[player] = {info = info}
	entry.Text = entryText(player, info)
end

local function removeFromList(player)
	entryData[player] = nil
	local entry = scroll:FindFirstChild("Entry_" .. player.UserId)
	if entry then entry:Destroy() end
end

local function setupPlayer(player)
	local info = getGroupInfo(player)

	if player == localPlayer then
		if not info then
			rankLabel.Text = "Group check failed"
		elseif info.inGroup then
			rankLabel.Text = info.role
			rankLabel.TextColor3 = getColor(info)
		else
			rankLabel.Text = "Not in group"
		end
	end

	if not info then return end

	addToList(player, info)

	local text = info.inGroup and info.role or "Not in group"
	local color = getColor(info)
	local showIcon = info.inGroup

	if player.Character then
		task.spawn(createTag, player.Character, text, color, showIcon)
	end
	player.CharacterAdded:Connect(function(character)
		createTag(character, text, color, showIcon)
	end)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeFromList)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(setupPlayer, player)
end

----------------------------------------------------------------
-- Tacs of TCO_TACEMPIRE
----------------------------------------------------------------
local friendId

do
	local ok, id = pcall(function()
		return Players:GetUserIdFromNameAsync(FRIEND_NAME)
	end)
	if ok then
		friendId = id
	else
		warn("Could not find user " .. FRIEND_NAME .. ": " .. tostring(id))
	end
end

local function addTacsEntry(player)
	if not friendId then return end

	local isFriend = (player.UserId == friendId)
	if not isFriend then
		local ok, result = pcall(function()
			return player:IsFriendsWith(friendId)
		end)
		isFriend = ok and result
	end
	if not isFriend then return end
	if not player.Parent then return end

	local entryName = "Tacs_" .. player.UserId
	if tacsScroll:FindFirstChild(entryName) then return end

	local l = Instance.new("TextLabel")
	l.Name = entryName
	l.Size = UDim2.new(1, -10, 0, 34)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Arial
	l.TextSize = 26
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.TextColor3 = WHITE
	l.Text = player.Name .. (player.UserId == friendId and " (owner)" or "")
	l.Parent = tacsScroll
end

local function removeTacsEntry(player)
	local entry = tacsScroll:FindFirstChild("Tacs_" .. player.UserId)
	if entry then entry:Destroy() end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(addTacsEntry, player)
end)
Players.PlayerRemoving:Connect(removeTacsEntry)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(addTacsEntry, player)
end
