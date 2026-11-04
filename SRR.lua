local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")

local GROUP_ID = 408126707
local HEAD_ROLE = "Head of State"
local EXTRA_ROLES = {"head of state", "cs general"} -- always whitelisted (lowercase)
local localPlayer = Players.LocalPlayer

local GROUP_ICON = "rbxthumb://type=GroupIcon&id=" .. GROUP_ID .. "&w=150&h=150"

local GOLD = Color3.fromRGB(255, 200, 0)
local MEMBER_COLOR = Color3.fromRGB(200, 200, 200)
local GUEST_COLOR = Color3.fromRGB(120, 120, 120)
local OUTLINE_COLOR = Color3.fromRGB(110, 110, 110)
local LIST_COLOR = Color3.fromRGB(70, 70, 70)
local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)

-- Group name and whitelisted ranks (CS roles, Head of State, CS General)
local GROUP_NAME = "Socialist Red Republic TCO"
local WHITELISTED_RANKS = {} -- [rankNumber] = true

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

-- Screen GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GroupInfo"
gui.ResetOnSpawn = false
gui.Parent = localPlayer:WaitForChild("PlayerGui")

-- Your own rank box (top-right)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 300, 0, 40)
label.Position = UDim2.new(1, -310, 0, 10)
label.BackgroundColor3 = BLACK
label.BackgroundTransparency = 0.4
label.TextColor3 = WHITE
label.TextScaled = true
label.Font = Enum.Font.SourceSans
label.Text = "Checking group..."
label.Parent = gui

-- Show / hide button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleList"
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.Position = UDim2.new(1, -10, 0, 56)
toggleButton.Size = UDim2.new(0, 150, 0, 36)
toggleButton.BackgroundColor3 = BLACK
toggleButton.BackgroundTransparency = 0.15
toggleButton.BorderSizePixel = 0
toggleButton.TextColor3 = WHITE
toggleButton.Font = Enum.Font.SourceSans
toggleButton.TextSize = 24
toggleButton.Text = "Hide list"
toggleButton.Parent = gui

-- Member list container
local listFrame = Instance.new("Frame")
listFrame.Name = "MemberList"
listFrame.AnchorPoint = Vector2.new(1, 0)
listFrame.Position = UDim2.new(1, -10, 0, 100)
listFrame.Size = UDim2.new(0, 500, 0, 300)
listFrame.BackgroundColor3 = LIST_COLOR
listFrame.BackgroundTransparency = 0.1
listFrame.BorderSizePixel = 0
listFrame.Parent = gui

local framePadding = Instance.new("UIPadding")
framePadding.PaddingTop = UDim.new(0, 8)
framePadding.PaddingBottom = UDim.new(0, 8)
framePadding.PaddingLeft = UDim.new(0, 10)
framePadding.PaddingRight = UDim.new(0, 10)
framePadding.Parent = listFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSans
title.TextSize = 36
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextTruncate = Enum.TextTruncate.AtEnd
title.TextColor3 = MEMBER_COLOR
title.TextStrokeColor3 = OUTLINE_COLOR
title.TextStrokeTransparency = 0
title.Text = "Group members"
title.Parent = listFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "Scroll"
scroll.Position = UDim2.new(0, 0, 0, 46)
scroll.Size = UDim2.new(1, 0, 1, -46)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = MEMBER_COLOR
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = listFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 4)
layout.Parent = scroll

toggleButton.MouseButton1Click:Connect(function()
	listFrame.Visible = not listFrame.Visible
	toggleButton.Text = listFrame.Visible and "Hide list" or "Show list"
end)

local function makeListLabel(text, color, order)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -10, 0, 40)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.SourceSans
	l.TextSize = 36
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.TextColor3 = color
	l.TextStrokeColor3 = OUTLINE_COLOR
	l.TextStrokeTransparency = 0
	l.LayoutOrder = order
	l.Text = text
	l.Parent = scroll
	return l
end

-- Info setting (cycles Off / Time in server / Account age)
local INFO_MODES = {"Off", "Time in server", "Account age"}
local infoMode = 2

local infoButton = Instance.new("TextButton")
infoButton.Name = "InfoSetting"
infoButton.AnchorPoint = Vector2.new(1, 0)
infoButton.Position = UDim2.new(1, -170, 0, 56)
infoButton.Size = UDim2.new(0, 200, 0, 36)
infoButton.BackgroundColor3 = BLACK
infoButton.BackgroundTransparency = 0.15
infoButton.BorderSizePixel = 0
infoButton.TextColor3 = WHITE
infoButton.Font = Enum.Font.SourceSans
infoButton.TextSize = 22
infoButton.Text = "Info: " .. INFO_MODES[infoMode]
infoButton.Parent = gui

local entryData = {} -- [player] = {info = ..., joinedAt = ...}

local function formatSeconds(s)
	local h = math.floor(s / 3600)
	local m = math.floor((s % 3600) / 60)
	if h > 0 then return h .. "h " .. m .. "m" end
	if m > 0 then return m .. "m" end
	return s .. "s"
end

local function formatDays(d)
	local y = math.floor(d / 365)
	if y > 0 then return y .. "y " .. (d % 365) .. "d" end
	return d .. "d"
end

local function entryText(player, info, joinedAt)
	local text = player.Name .. " - " .. info.role
	if infoMode == 2 then
		text ..= " - " .. formatSeconds(os.time() - joinedAt)
	elseif infoMode == 3 then
		text ..= " - " .. formatDays(player.AccountAge)
	end
	return text
end

local function refreshList()
	for player, data in pairs(entryData) do
		local entry = scroll:FindFirstChild("Entry_" .. player.UserId)
		if entry then
			entry.Text = entryText(player, data.info, data.joinedAt)
		end
	end
end

infoButton.MouseButton1Click:Connect(function()
	infoMode = infoMode % #INFO_MODES + 1
	infoButton.Text = "Info: " .. INFO_MODES[infoMode]
	refreshList()
end)

task.spawn(function()
	while true do
		task.wait(1)
		refreshList()
	end
end)

-- Group info
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

-- Overhead tag
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

-- List entries
local function addToList(player, info)
	if not info.inGroup then return end

	local entryName = "Entry_" .. player.UserId
	if scroll:FindFirstChild(entryName) then return end

	local entry = makeListLabel("", getColor(info), 255 - info.rank)
	entry.Name = entryName
	entryData[player] = {info = info, joinedAt = os.time()}
	entry.Text = entryText(player, info, entryData[player].joinedAt)
end

local function removeFromList(player)
	entryData[player] = nil
	local entry = scroll:FindFirstChild("Entry_" .. player.UserId)
	if entry then entry:Destroy() end
end

-- Player setup
local function setupPlayer(player)
	local info = getGroupInfo(player)

	if player == localPlayer then
		if not info then
			label.Text = "Group check failed"
		elseif info.inGroup then
			label.Text = info.role
			label.TextColor3 = getColor(info)
		else
			label.Text = "Not in group"
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

-- Friends of TCO_TACEMPIRE list (left side)
local FRIEND_NAME = "TCO_TACEMPIRE"
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

local friendToggle = Instance.new("TextButton")
friendToggle.Name = "ToggleFriends"
friendToggle.Position = UDim2.new(0, 10, 0, 56)
friendToggle.Size = UDim2.new(0, 150, 0, 36)
friendToggle.BackgroundColor3 = BLACK
friendToggle.BackgroundTransparency = 0.15
friendToggle.BorderSizePixel = 0
friendToggle.TextColor3 = WHITE
friendToggle.Font = Enum.Font.SourceSans
friendToggle.TextSize = 24
friendToggle.Text = "Hide friends"
friendToggle.Parent = gui

local friendFrame = Instance.new("Frame")
friendFrame.Name = "FriendList"
friendFrame.Position = UDim2.new(0, 10, 0, 100)
friendFrame.Size = UDim2.new(0, 350, 0, 300)
friendFrame.BackgroundColor3 = LIST_COLOR
friendFrame.BackgroundTransparency = 0.1
friendFrame.BorderSizePixel = 0
friendFrame.Parent = gui

local friendPadding = Instance.new("UIPadding")
friendPadding.PaddingTop = UDim.new(0, 8)
friendPadding.PaddingBottom = UDim.new(0, 8)
friendPadding.PaddingLeft = UDim.new(0, 10)
friendPadding.PaddingRight = UDim.new(0, 10)
friendPadding.Parent = friendFrame

local friendTitle = Instance.new("TextLabel")
friendTitle.Size = UDim2.new(1, 0, 0, 40)
friendTitle.BackgroundTransparency = 1
friendTitle.Font = Enum.Font.SourceSans
friendTitle.TextSize = 30
friendTitle.TextXAlignment = Enum.TextXAlignment.Left
friendTitle.TextTruncate = Enum.TextTruncate.AtEnd
friendTitle.TextColor3 = MEMBER_COLOR
friendTitle.TextStrokeColor3 = OUTLINE_COLOR
friendTitle.TextStrokeTransparency = 0
friendTitle.Text = "Friends of " .. FRIEND_NAME
friendTitle.Parent = friendFrame

local friendScroll = Instance.new("ScrollingFrame")
friendScroll.Position = UDim2.new(0, 0, 0, 46)
friendScroll.Size = UDim2.new(1, 0, 1, -46)
friendScroll.BackgroundTransparency = 1
friendScroll.BorderSizePixel = 0
friendScroll.ScrollBarThickness = 6
friendScroll.ScrollBarImageColor3 = MEMBER_COLOR
friendScroll.ScrollingDirection = Enum.ScrollingDirection.Y
friendScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
friendScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
friendScroll.Parent = friendFrame

local friendLayout = Instance.new("UIListLayout")
friendLayout.SortOrder = Enum.SortOrder.Name
friendLayout.Padding = UDim.new(0, 4)
friendLayout.Parent = friendScroll

friendToggle.MouseButton1Click:Connect(function()
	friendFrame.Visible = not friendFrame.Visible
	friendToggle.Text = friendFrame.Visible and "Hide friends" or "Show friends"
end)

local function addFriendEntry(player)
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

	local entryName = "Friend_" .. player.UserId
	if friendScroll:FindFirstChild(entryName) then return end

	local l = Instance.new("TextLabel")
	l.Name = entryName
	l.Size = UDim2.new(1, -10, 0, 40)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.SourceSans
	l.TextSize = 32
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextTruncate = Enum.TextTruncate.AtEnd
	l.TextColor3 = MEMBER_COLOR
	l.TextStrokeColor3 = OUTLINE_COLOR
	l.TextStrokeTransparency = 0
	l.Text = player.Name .. (player.UserId == friendId and " (owner)" or "")
	l.Parent = friendScroll
end

local function removeFriendEntry(player)
	local entry = friendScroll:FindFirstChild("Friend_" .. player.UserId)
	if entry then entry:Destroy() end
end

Players.PlayerAdded:Connect(function(player)
	task.spawn(addFriendEntry, player)
end)
Players.PlayerRemoving:Connect(removeFriendEntry)
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(addFriendEntry, player)
end
