local vape = {
	ActiveBinds = {},
	Categories = {},
	GUIColor = {
		Hue = 0.46,
		Sat = 0.96,
		Value = 0.52
	},
	HeldKeybinds = {},
	Loaded = false,
	Libraries = {},
	Modules = {},
	Place = game.PlaceId,
	Profile = 'default',
	RainbowSliders = {},
	Settings = {},
	SettingToggleNotifications = {},
	ThreadFix = setthreadidentity and true or false,
	ToggleNotifications = {},
	Version = '4.22',
	Windows = {}
}

local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end
local tweenService = cloneref(game:GetService('TweenService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local guiService = cloneref(game:GetService('GuiService'))
local runService = cloneref(game:GetService('RunService'))
local httpService = cloneref(game:GetService('HttpService'))

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
local notifications
local getvapeasset
local components
local clickgui
local scaledgui
local toolblur
local tooltip
local TextGUI
local scale = {Scale = 1}
local gui

local isfile = isfile or function(file)
	local success, data = pcall(function()
		return readfile(file)
	end)

	return success and data ~= nil and data ~= ''
end

local function loadJson(path)
	local success, data = pcall(function()
		return httpService:JSONDecode(readfile(path))
	end)

	return success and type(data) == 'table' and data or nil
end

local color = {}
local uipallet = {}
do
	function color.Dark(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
	end

	function color.Light(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
	end

	function vape:Color(h)
		local s = 0.74 + (0.26 * math.min(h / 0.045, 1))

		if h > 0.577 then
			s = 1 - (0.48 * math.min((h - 0.577) / 0.088, 1))
		end

		if h > 0.674 then
			s = 0.52 + (0.48 * math.min((h - 0.674) / 0.149, 1))
		end

		if h > 0.869 then
			s = 1 - (0.26 * math.min((h - 0.869) / 0.131, 1))
		end

		return h, s, 1
	end

	function vape:TextColor(h, s, v)
		if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
			return Color3.new(0.19, 0.19, 0.19)
		end

		return Color3.new(1, 1, 1)
	end
end

local function getfontbounds(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end

	return textService:GetTextBoundsAsync(fontsize)
end

do
	local vapeAssets = {
		['newvape/assets/new/add.png'] = 'rbxassetid://121642387707174',
		['newvape/assets/new/aim.png'] = 'rbxassetid://122207028123421',
		['newvape/assets/new/allowedicon.png'] = 'rbxassetid://112336790299036',
		['newvape/assets/new/allowediconmini.png'] = 'rbxassetid://90142384730147',
		['newvape/assets/new/back.png'] = 'rbxassetid://80523803497740',
		['newvape/assets/new/backmini.png'] = 'rbxassetid://85859225495272',
		['newvape/assets/new/bind.png'] = 'rbxassetid://81399857677684',
		['newvape/assets/new/bindbkg.png'] = 'rbxassetid://101996225428926',
		['newvape/assets/new/blatant.png'] = 'rbxassetid://126929923309265',
		['newvape/assets/new/blur.png'] = 'rbxassetid://79246816170155',
		['newvape/assets/new/blurnoti.png'] = 'rbxassetid://124705876663719',
		['newvape/assets/new/close.png'] = 'rbxassetid://121816018671466',
		['newvape/assets/new/closemini.png'] = 'rbxassetid://108320409341289',
		['newvape/assets/new/closetiny.png'] = 'rbxassetid://71393233149714',
		['newvape/assets/new/colorpreview.png'] = 'rbxassetid://140438628568318',
		['newvape/assets/new/combat.png'] = 'rbxassetid://94762732349053',
		['newvape/assets/new/customtheme.png'] = 'rbxassetid://91756736022800',
		['newvape/assets/new/discord.png'] = 'rbxassetid://99871463341003',
		['newvape/assets/new/downexpand.png'] = 'rbxassetid://94197751291504',
		['newvape/assets/new/downexpandslider.png'] = 'rbxassetid://90289944682645',
		['newvape/assets/new/edit.png'] = 'rbxassetid://105801951237137',
		['newvape/assets/new/editlarge.png'] = 'rbxassetid://119233876755282',
		['newvape/assets/new/expandarrow.png'] = 'rbxassetid://86360332526471',
		['newvape/assets/new/friends.png'] = 'rbxassetid://92957214042038',
		['newvape/assets/new/inventory.png'] = 'rbxassetid://93264756888499',
		['newvape/assets/new/legit_mode_icon.png'] = 'rbxassetid://102858626075156',
		['newvape/assets/new/legit_switch.png'] = 'rbxassetid://127508881124779',
		['newvape/assets/new/min.png'] = 'rbxassetid://82175054487146',
		['newvape/assets/new/noti_alert.png'] = 'rbxassetid://82356478726846',
		['newvape/assets/new/noti_info.png'] = 'rbxassetid://102614825645099',
		['newvape/assets/new/noti_warning.png'] = 'rbxassetid://119631730212167',
		['newvape/assets/new/notification.png'] = 'rbxassetid://90300780458781',
		['newvape/assets/new/npcs.png'] = 'rbxassetid://104434365485227',
		['newvape/assets/new/overlaydots.png'] = 'rbxassetid://78012624671930',
		['newvape/assets/new/overlays.png'] = 'rbxassetid://136535637407545',
		['newvape/assets/new/overlayslarge.png'] = 'rbxassetid://127574141208160',
		['newvape/assets/new/pin.png'] = 'rbxassetid://92459145800579',
		['newvape/assets/new/players.png'] = 'rbxassetid://105137446428129',
		['newvape/assets/new/profiles.png'] = 'rbxassetid://126051451865127',
		['newvape/assets/new/radar.png'] = 'rbxassetid://97983828696086',
		['newvape/assets/new/rainbow_1.png'] = 'rbxassetid://101329996188554',
		['newvape/assets/new/rainbow_2.png'] = 'rbxassetid://72739074644654',
		['newvape/assets/new/rainbow_3.png'] = 'rbxassetid://100716555253397',
		['newvape/assets/new/rainbow_4.png'] = 'rbxassetid://133424174227092',
		['newvape/assets/new/range.png'] = 'rbxassetid://107794917650053',
		['newvape/assets/new/rangeindicator.png'] = 'rbxassetid://107038094175283',
		['newvape/assets/new/render.png'] = 'rbxassetid://125472576898654',
		['newvape/assets/new/search.png'] = 'rbxassetid://115611852955611',
		['newvape/assets/new/settingdots.png'] = 'rbxassetid://130896840048276',
		['newvape/assets/new/settings.png'] = 'rbxassetid://73820177347303',
		['newvape/assets/new/settingsmini.png'] = 'rbxassetid://115732118290997',
		['newvape/assets/new/targetinfo.png'] = 'rbxassetid://121604266095276',
		['newvape/assets/new/textgui.png'] = 'rbxassetid://99438663817412',
		['newvape/assets/new/theme.png'] = 'rbxassetid://111525258317113',
		['newvape/assets/new/utility.png'] = 'rbxassetid://108303206513893',
		['newvape/assets/new/vape.png'] = 'rbxassetid://92153855792786',
		['newvape/assets/new/vapelogo.png'] = 'rbxassetid://126205920310261',
		['newvape/assets/new/vapelogomini.png'] = 'rbxassetid://109041903452149',
		['newvape/assets/new/v4.png'] = 'rbxassetid://102549752760489',
		['newvape/assets/new/v4mini.png'] = 'rbxassetid://115213099001611',
		['newvape/assets/new/world.png'] = 'rbxassetid://118917453153459'
	}

	local function createDownloader(text)
		if vape.Loaded ~= true then
			local downloader = vape.Downloader
			if not downloader then
				downloader = Instance.new('TextLabel')
				downloader.BackgroundTransparency = 1
				downloader.FontFace = uipallet.Font
				downloader.Size = UDim2.new(1, 0, 0, 40)
				downloader.TextColor3 = Color3.new(1, 1, 1)
				downloader.TextSize = 20
				downloader.TextStrokeTransparency = 0
				downloader.Parent = vape.gui
				vape.Downloader = downloader
			end

			downloader.Text = 'Downloading '..text
		end
	end

	local function downloadFile(path, callback)
		if not isfile(path) then
			createDownloader(path)

			local success, data = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
			end)

			if not success or data == '404: Not Found' then
				error(data)
			end

			if path:find('.lua') then
				data = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..data
			end

			writefile(path, data)
		end

		return (callback or readfile)(path)
	end

	getvapeasset = not inputService.TouchEnabled and getcustomasset and function(path)
		return downloadFile(path, getcustomasset)
	end or function(path)
		return vapeAssets[path] or ''
	end
end

local tween = setmetatable({}, {
	__index = function()
		return {}
	end
})

do
	function tween:Tween(obj, info, goal, index)
		index = self[index or 'tweens']
		if index[obj] then
			index[obj]:Cancel()
			index[obj] = nil
		end

		if obj.Parent and (obj:IsA('UIStroke') or obj.Visible) then
			index[obj] = tweenService:Create(obj, info, goal)
			index[obj].Completed:Once(function()
				if index then
					index[obj] = nil
					index = nil
				end
			end)

			index[obj]:Play()
		else
			for prop, value in goal do
				obj[prop] = value
			end
		end
	end

	function tween:Cancel(obj, index)
		index = self[index or 'tweens']

		if index[obj] then
			index[obj]:Cancel()
			index[obj] = nil
		end
	end
end

uipallet = {
	Main = Color3.fromRGB(26, 25, 26),
	Text = Color3.fromRGB(200, 200, 200),
	Font = Font.fromEnum(Enum.Font.Arial),
	FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.SemiBold),
	Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
}

do
	local data = isfile('newvape/profiles/color.txt') and loadJson('newvape/profiles/color.txt')
	if data then
		uipallet.Main = data.Main and Color3.fromRGB(unpack(data.Main)) or uipallet.Main
		uipallet.Text = data.Text and Color3.fromRGB(unpack(data.Text)) or uipallet.Text
		uipallet.Font = data.Font and Font.new(
			data.Font:find('rbxasset') and data.Font
			or string.format('rbxasset://fonts/families/%s.json', data.Font)
		) or uipallet.Font
		uipallet.FontSemiBold = Font.new(uipallet.Font.Family, Enum.FontWeight.SemiBold)
	end

	fontsize.Font = uipallet.Font
end

vape.Libraries = {
	color = color,
	getfontbounds = getfontbounds,
	getvapeasset = getvapeasset,
	tween = tween,
	uipallet = uipallet,
}

local function addBlur(parent, notif, old)
	local blur
	if old then
		blur = Instance.new('ImageLabel')
		blur.Name = 'Blur'
		blur.Size = UDim2.new(1, 89, 1, 52)
		blur.Position = UDim2.fromOffset(-48, -31)
		blur.BackgroundTransparency = 1
		blur.Image = getvapeasset('newvape/assets/new/'..(notif and 'blurnoti' or 'blur')..'.png')
		blur.ScaleType = Enum.ScaleType.Slice
		blur.SliceCenter = Rect.new(52, 31, 261, 502)
		blur.Parent = parent
	else
		blur = Instance.new('UIShadow')
		blur.BlurRadius = UDim.new(0, 13)
		blur.Transparency = 0.25
		blur.Parent = parent
	end

	return blur
end

local function addCorner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 5)
	corner.Parent = parent

	return corner
end

local function addCloseButton(parent, mini, offset)
	local close = Instance.new('ImageButton')
	close.AutoButtonColor = false
	close.BackgroundColor3 = Color3.new(1, 1, 1)
	close.BackgroundTransparency = 1
	close.Image = getvapeasset('newvape/assets/new/'..(mini and 'closemini' or 'close')..'.png')
	close.ImageColor3 = color.Light(uipallet.Text, 0.2)
	close.ImageTransparency = 0.5
	close.Name = 'Close'
	close.Position = offset or (mini and UDim2.new(1, -28, 0, 11) or UDim2.new(1, -35, 0, 9))
	close.Size = mini and UDim2.fromOffset(20, 20) or UDim2.fromOffset(24, 24)
	close.Parent = parent
	addCorner(close, UDim.new(1, 0))

	close.MouseEnter:Connect(function()
		close.ImageTransparency = 0.3
		tween:Tween(close, uipallet.Tween, {
			BackgroundTransparency = 0.6
		})
	end)

	close.MouseLeave:Connect(function()
		close.ImageTransparency = 0.5
		tween:Tween(close, uipallet.Tween, {
			BackgroundTransparency = 1
		})
	end)

	return close
end

local function addDragHandler(gui, window)
	gui.InputBegan:Connect(function(input)
		if window and not window.Visible then return end

		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and (input.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			local dragPosition = Vector2.new(
				gui.AbsolutePosition.X - input.Position.X,
				gui.AbsolutePosition.Y - input.Position.Y + guiService:GetGuiInset().Y
			) / scale.Scale

			local releaseConnection
			local moveConnection = inputService.InputChanged:Connect(function(newInput)
				if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = newInput.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end

					gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			releaseConnection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					moveConnection:Disconnect()
					releaseConnection:Disconnect()
				end
			end)
		end
	end)
end

local function addMaid(obj)
	obj.Connections = {}

	function obj:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					callback:ClearAllChildren()
					callback:Destroy()
				end
			})
		elseif type(callback) == 'thread' then
			table.insert(self.Connections, {
				Disconnect = function()
					if coroutine.status(callback) ~= 'dead' then
						task.cancel(callback)
					end
				end
			})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {
				Disconnect = callback
			})
		else
			table.insert(self.Connections, callback)
		end
	end
end

local function addTooltip(gui, text, customText, visCheck)
	if not text then return end

	local function tooltipMoved(x, y)
		if visCheck and visCheck() then
			return
		end

		local isRight = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
		tooltip.Position = UDim2.fromOffset(
			(isRight and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale,
			((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale
		)

		tooltip.Visible = toolblur.Enabled
	end

	local function callback()
		local newText = customText()
		tooltip.Text = newText
		local tooltipSize = getfontbounds(tooltip.ContentText, tooltip.TextSize, uipallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10)
	end

	gui.MouseEnter:Connect(function(x, y)
		if visCheck and visCheck() then
			return
		end

		tooltip.Text = text
		local tooltipSize = getfontbounds(tooltip.ContentText, tooltip.TextSize, uipallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 10)
		tooltipMoved(x, y)

		if customText then
			vape.CurrentTooltip = callback
			callback()
		end
	end)
	gui.MouseMoved:Connect(tooltipMoved)
	gui.MouseLeave:Connect(function()
		if visCheck and visCheck() then
			return
		end

		tooltip.Visible = false
		vape.CurrentTooltip = nil
	end)
end

local function createSignal()
	local signal = {
		Connections = {}
	}

	function signal:Connect(callback)
		table.insert(self.Connections, callback)

		return {
			Disconnect = function()
				local index = table.find(signal.Connections, callback)
				if index then
					table.remove(signal.Connections, index)
				end
			end
		}
	end

	function signal:Fire(...)
		for _, callback in self.Connections do
			task.spawn(callback, ...)
		end
	end

	return signal
end

local function checkKeybinds(compare, target, key)
	if type(target) == 'table' then
		if table.find(target, key) then
			for _, key in target do
				if not table.find(compare, key) then
					return false
				end
			end

			return true
		end
	end

	return false
end

local function getTableSize(dict)
	local size = 0
	for _ in dict do
		size += 1
	end

	return size
end

local function loopClean(obj)
	for index, value in obj do
		if type(value) == 'table' then
			loopClean(value)
		end

		obj[index] = nil
	end
end

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end

	return table.concat(array)
end

local function removeTags(text)
	text = text:gsub('<br%s*/>', '\n')
	return text:gsub('<[^<>]->', '')
end

function vape:BlurCheck()
	if self.ThreadFix then
		setthreadidentity(8)
		runService:SetRobloxGuiFocused((clickgui.Visible or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and self.Blur.Enabled)
	end
end

function vape:CreateCategory(props)
	return components.Category(props)
end

function vape:CreateCategoryList(props)
	return components.CategoryList(props)
end

function vape:CreateNotification(title, text, duration, type)
	if not self.Notifications.Enabled then
		return
	end

	task.delay(0, function()
		if self.ThreadFix then
			setthreadidentity(8)
		end

		local index = #notifications:GetChildren() + 1
		local notification = Instance.new('ImageLabel')
		notification.BackgroundTransparency = 1
		notification.Position = UDim2.new(1, 0, 1, -(29 + (78 * index)))
		notification.Image = getvapeasset('newvape/assets/new/notification.png')
		notification.ScaleType = Enum.ScaleType.Slice
		notification.SliceCenter = Rect.new(7, 7, 9, 9)
		notification.ZIndex = 5
		notification.Parent = notifications
		addBlur(notification, true, true)
		local iconshadow = Instance.new('ImageLabel')
		iconshadow.BackgroundTransparency = 1
		iconshadow.Image = getvapeasset('newvape/assets/new/noti_'..(type or 'info')..'.png')
		iconshadow.ImageColor3 = Color3.new()
		iconshadow.ImageTransparency = 0.5
		iconshadow.Position = UDim2.fromOffset(-5, -8)
		iconshadow.Size = UDim2.fromOffset(60, 60)
		iconshadow.ZIndex = 5
		iconshadow.Parent = notification
		local icon = iconshadow:Clone()
		icon.ImageColor3 = Color3.new(1, 1, 1)
		icon.ImageTransparency = 0
		icon.Position = UDim2.fromOffset(-1, -1)
		icon.Parent = iconshadow
		local label = Instance.new('TextLabel')
		label.BackgroundTransparency = 1
		label.FontFace = uipallet.FontSemiBold
		label.Position = UDim2.fromOffset(46, 16)
		label.RichText = true
		label.Size = UDim2.new(1, -56, 0, 20)
		label.Text = "<stroke joins='round' thickness='0.3' transparency='0.5'>"..title..'</stroke>'
		label.TextColor3 = type == 'alert' and Color3.fromRGB(250, 50, 56) or Color3.new(1, 1, 1)
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextYAlignment = Enum.TextYAlignment.Top
		label.ZIndex = 5
		label.Parent = notification
		local textshadow = label:Clone()
		textshadow.FontFace = uipallet.Font
		textshadow.Position = UDim2.fromOffset(47, 44)
		textshadow.RichText = false
		textshadow.Text = removeTags(text)
		textshadow.TextColor3 = Color3.new()
		textshadow.TextTransparency = 0.5
		textshadow.Parent = notification
		notification.Size = UDim2.fromOffset(math.max(getfontbounds(textshadow.Text, 14, uipallet.Font).X + 80, 266), 75)
		local textlabel = textshadow:Clone()
		textlabel.Position = UDim2.fromOffset(-1, -1)
		textlabel.RichText = true
		textlabel.Text = text
		textlabel.TextColor3 = Color3.fromRGB(170, 170, 170)
		textlabel.TextTransparency = 0
		textlabel.Parent = textshadow
		local progress = Instance.new('Frame')
		progress.BackgroundColor3 =
			type == 'alert' and Color3.fromRGB(250, 50, 56)
			or type == 'warning' and Color3.fromRGB(236, 129, 44)
			or Color3.new(1, 1, 1)
		progress.BorderSizePixel = 0
		progress.Position = UDim2.new(0, 3, 1, -4)
		progress.Size = UDim2.new(1, -13, 0, 1)
		progress.ZIndex = 5
		progress.Parent = notification

		if tween.Tween then
			tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				AnchorPoint = Vector2.new(1, 0)
			}, 'tweenstwo')

			tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Size = UDim2.fromOffset(0, 1)
			})
		end

		task.delay(duration, function()
			if tween.Tween then
				tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					AnchorPoint = Vector2.new(0, 0)
				}, 'tweenstwo')
			end

			task.wait(0.2)
			notification:ClearAllChildren()
			notification:Destroy()
		end)
	end)
end

function vape:CreateOverlay(props)
	return components.Overlay(props)
end

function vape:Load(skipgui, profile)
	local guiData = {Categories = {}}
	local oldProfile = self.Profile
	local canSave = true
	local toggleCount = 0

	if isfile('newvape/profiles/'..game.GameId..'.gui.txt') then
		guiData = loadJson('newvape/profiles/'..game.GameId..'.gui.txt')
		if not guiData then
			guiData = {Categories = {}}
			self:CreateNotification('Vape', 'Failed to load GUI settings.', 10, 'alert')
			canSave = false
		end

		if guiData.v ~= 1 then
			guiData.Categories.Main = nil
		end

		self.Profile = profile or guiData.Profile or 'default'
		if self.ProfileLabel then
			self.ProfileLabel.Text = #self.Profile > 10 and self.Profile:sub(1, 10)..'...' or self.Profile
			self.ProfileLabel.Size = UDim2.fromOffset(getfontbounds(self.ProfileLabel.Text, self.ProfileLabel.TextSize, self.ProfileLabel.Font).X + 16, 24)
		end

		if not skipgui then
			for name, data in guiData.Categories do
				local category = self.Categories[name]
				if category then
					category:Load(data)
				end
			end
		end
	end

	if not self.Categories.Profiles:GetValue('default') then
		self.Categories.Profiles:ChangeValue('default', true)
	end

	if isfile('newvape/profiles/'..self.Profile..self.Place..'.txt') then
		local mainData = loadJson('newvape/profiles/'..self.Profile..self.Place..'.txt')
		if not mainData then
			mainData = {Categories = {}, Modules = {}, Legit = {}}
			self:CreateNotification('Vape', 'Failed to load '..self.Profile..' profile.', 10, 'alert')
			canSave = false
		end

		if mainData.v ~= 1 then
			for _, data in mainData.Modules do
				data.Bind = {Keys = data.Bind}
				data.Visible = true
			end
		end

		for name, data in mainData.Categories do
			local category = self.Categories[name]
			if category then
				category:Load(data)
			end
		end

		for name, data in mainData.Modules do
			local module = self.Modules[name]
			if module then
				module:Load(data)
				toggleCount += module.Enabled and 1 or 0
			end
		end

		for name, data in mainData.Legit do
			local module = self.Legit.Modules[name]
			if module then
				module:Load(data)
			end
		end

		self:UpdateTextGUI(true)
	else
		self:Save()
	end

	if self.Profile ~= oldProfile and skipgui then
		self:CreateNotification('Profile swap to <font color="#FFAA00">'..self.Profile..'</font>', toggleCount..' modules enabled', 3)
	end

	if self.Downloader then
		self.Downloader:Destroy()
		self.Downloader = nil
	end

	self.Loaded = canSave

	if inputService.TouchEnabled and not skipgui then
		local button = Instance.new('TextButton')
		button.BackgroundColor3 = Color3.new()
		button.BackgroundTransparency = 0.2
		button.Position = UDim2.new(1, -90, 0, 4)
		button.Size = UDim2.fromOffset(32, 32)
		button.Text = ''
		button.Parent = gui
		local image = Instance.new('ImageLabel')
		image.BackgroundTransparency = 1
		image.Image = getvapeasset('newvape/assets/new/vape.png')
		image.Position = UDim2.fromOffset(6, 6)
		image.Size = UDim2.fromOffset(20, 20)
		image.Parent = button
		addCorner(button, UDim.new(1, 0))

		button.MouseButton1Click:Connect(function()
			self.GUIBind.Triggered:Fire(true)
		end)
	end

	return toggleData
end

function vape:LoadOptions(obj, data)
	for name, componentData in data do
		local component = obj.Options[name]

		if component then
			component:Load(componentData)
		end
	end
end

function vape:LoadGUI()
	addMaid(vape)
	gui = Instance.new('ScreenGui')
	gui.Name = randomString()
	gui.DisplayOrder = 9999999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.IgnoreGuiInset = true
	
	if vape.ThreadFix then
		local holder = Instance.new('Folder')
		holder.Parent = cloneref(game:GetService('CoreGui'))
		gui.OnTopOfCoreBlur = true
		gui.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'))
		vape.holder = holder
	else
		gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
		gui.ResetOnSpawn = false
		vape.holder = gui
	end
	vape.gui = gui
	
	scaledgui = Instance.new('Frame')
	scaledgui.BackgroundTransparency = 1
	scaledgui.Name = 'ScaledGui'
	scaledgui.Size = UDim2.fromScale(1, 1)
	scaledgui.Parent = gui
	clickgui = Instance.new('Frame')
	clickgui.BackgroundTransparency = 1
	clickgui.Name = 'ClickGui'
	clickgui.Size = UDim2.fromScale(1, 1)
	clickgui.Visible = false
	clickgui.Parent = scaledgui
	local scarcitybanner = Instance.new('TextLabel')
	scarcitybanner.BackgroundTransparency = 1
	scarcitybanner.FontFace = uipallet.Font
	scarcitybanner.Position = UDim2.fromScale(0, 0.97)
	scarcitybanner.Size = UDim2.fromScale(1, 0.018)
	scarcitybanner.Text = 'All update logs and game support are found in the discord, click the discord icon to join.'
	scarcitybanner.TextColor3 = Color3.new(1, 1, 1)
	scarcitybanner.TextScaled = true
	scarcitybanner.TextStrokeTransparency = 0.5
	scarcitybanner.Parent = clickgui
	local modal = Instance.new('TextButton')
	modal.BackgroundTransparency = 1
	modal.Modal = true
	modal.Text = ''
	modal.Parent = clickgui
	local cursor = Instance.new('ImageLabel')
	cursor.BackgroundTransparency = 1
	cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
	cursor.Size = UDim2.fromOffset(64, 64)
	cursor.Visible = false
	cursor.Parent = gui
	notifications = Instance.new('Folder')
	notifications.Name = 'Notifications'
	notifications.Parent = scaledgui
	tooltip = Instance.new('TextLabel')
	tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
	tooltip.FontFace = uipallet.Font
	tooltip.Position = UDim2.fromScale(-1, -1)
	tooltip.RichText = true
	tooltip.Text = ''
	tooltip.TextColor3 = color.Dark(uipallet.Text, 0.16)
	tooltip.TextSize = 12
	tooltip.Visible = false
	tooltip.ZIndex = 5
	tooltip.Parent = scaledgui
	toolblur = addBlur(tooltip)
	addCorner(tooltip)
	scale = Instance.new('UIScale')
	scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
	scale.Parent = scaledgui
	scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
	components.GUI({})
	
	vape:CreateCategory({
		Name = 'Combat',
		Icon = getvapeasset('newvape/assets/new/combat.png'),
		Size = UDim2.fromOffset(13, 14)
	})
	vape:CreateCategory({
		Name = 'Blatant',
		Icon = getvapeasset('newvape/assets/new/blatant.png'),
		Size = UDim2.fromOffset(14, 14)
	})
	vape:CreateCategory({
		Name = 'Render',
		Icon = getvapeasset('newvape/assets/new/render.png'),
		Size = UDim2.fromOffset(15, 14)
	})
	vape:CreateCategory({
		Name = 'Utility',
		Icon = getvapeasset('newvape/assets/new/utility.png'),
		Size = UDim2.fromOffset(15, 14)
	})
	vape:CreateCategory({
		Name = 'World',
		Icon = getvapeasset('newvape/assets/new/world.png'),
		Size = UDim2.fromOffset(14, 14)
	})
	vape:CreateCategory({
		Name = 'Inventory',
		Icon = getvapeasset('newvape/assets/new/inventory.png'),
		Size = UDim2.fromOffset(15, 14)
	})
	vape.Categories.Main:CreateDivider({
		Text = 'misc'
	})
	
	--[[
		Friends
	]]
	do
		local friends
		local friendscolor = {
			Hue = 1,
			Sat = 1,
			Value = 1
		}
	
		friends = vape:CreateCategoryList({
			Name = 'Friends',
			Icon = getvapeasset('newvape/assets/new/friends.png'),
			Size = UDim2.fromOffset(17, 16),
			Placeholder = 'Roblox username',
			Color = Color3.fromRGB(5, 134, 105),
			Function = function()
				friends.Update:Fire()
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
			end
		})
		friends.Update = Instance.new('BindableEvent')
		friends.ColorUpdate = Instance.new('BindableEvent')
		friends:CreateToggle({
			Name = 'Recolor visuals',
			Darker = true,
			Default = true,
			Function = function()
				friends.Update:Fire()
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
			end
		})
		friendscolor = friends:CreateColorSlider({
			Name = 'Friends color',
			Darker = true,
			Function = function(hue, sat, val)
				for _, v in friends.Object.Children:GetChildren() do
					local dot = v:FindFirstChild('Dot')
					if dot and dot.BackgroundColor3 ~= color.Light(uipallet.Main, 0.37) then
						dot.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
						dot.Dot.BackgroundColor3 = dot.BackgroundColor3
					end
				end
	
				friends.ColorUpdate:Fire(hue, sat, val)
			end
		})
		friends:CreateToggle({
			Name = 'Use friends',
			Darker = true,
			Default = true,
			Function = function()
				friends.Update:Fire()
				friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
			end
		})
		vape:Clean(friends.Update)
		vape:Clean(friends.ColorUpdate)
	end
	
	--[[
		Profiles
	]]
	vape:CreateCategoryList({
		Name = 'Profiles',
		Icon = getvapeasset('newvape/assets/new/profiles.png'),
		Size = UDim2.fromOffset(17, 10),
		Position = UDim2.fromOffset(12, 16),
		Placeholder = 'Type name',
		Profiles = true
	})
	
	--[[
		Targets
	]]
	local targets
	targets = vape:CreateCategoryList({
		Name = 'Targets',
		Icon = getvapeasset('newvape/assets/new/friends.png'),
		Size = UDim2.fromOffset(17, 16),
		Placeholder = 'Roblox username',
		Function = function()
			targets.Update:Fire()
		end
	})
	targets.Update = Instance.new('BindableEvent')
	vape:Clean(targets.Update)
	
	components.LegitWindow()
	vape.SearchBar = components.SearchBar()
	vape.Categories.Main:CreateOverlayBar()
	
	--[[
		General Settings
	]]
	
	local general = vape.Categories.Main.Settings:CreateSettingsPane({Name = 'General'})
	local settingConnections = {}
	vape.MultiKeybind = general:CreateToggle({
		Name = 'Enable Multi-Keybinding',
		Tooltip = 'Allows multiple keys to be bound to a module (eg. G + H)'
	})
	general:CreateToggle({
		Name = 'Allow setting keybinds',
		Function = function(callback)
			if callback then
				for _, container in {vape.Modules, vape.Legit.Modules} do
					for _, module in container do
						for _, component in module.Options do
							if component.Type == 'Toggle' then
								local bind = components.Bind({
									Module = true
								}, nil, component)
								bind.Object.Position = UDim2.new(1, -40, 0, 5)
	
								table.insert(settingConnections, bind.Triggered:Connect(function(isDown)
									if bind.Hold then
										if component.Enabled ~= isDown then
											if vape.SettingToggleNotifications.Enabled then
												vape:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and "<font color='#00AA00'>ON</font>" or "<font color='#FF5A5A'>OFF</font>"), 1.5)
											end
	
											component:Toggle()
										end
									else
										if vape.SettingToggleNotifications.Enabled then
											vape:CreateNotification(module.Name, component.Name..' '..(not component.Enabled and "<font color='#00AA00'>ON</font>" or "<font color='#FF5A5A'>OFF</font>"), 1.5)
										end
	
										component:Toggle()
									end
								end))
	
								table.insert(settingConnections, component.Object.MouseEnter:Connect(function()
									bind:SetVisible(true)
								end))
	
								table.insert(settingConnections, component.Object.MouseLeave:Connect(function()
									bind:SetVisible(false)
								end))
							end
						end
					end
				end
			else
				for _, container in {vape.Modules, vape.Legit.Modules} do
					for _, module in container do
						for _, component in module.Options do
							if component.Bind then
								component.Bind:Destroy()
							end
						end
					end
				end
	
				for _, connection in settingConnections do
					connection:Disconnect()
				end
				table.clear(settingConnections)
			end
		end,
		Tooltip = 'Hover a toggle setting to bind it to a key'
	})
	
	general:CreateButton({
		Name = 'Reset current profile',
		Function = function()
		vape.Save = function() end
			if isfile('newvape/profiles/'..vape.Profile..vape.Place..'.txt') and delfile then
				delfile('newvape/profiles/'..vape.Profile..vape.Place..'.txt')
			end
	
			shared.vapereload = true
			if shared.VapeDeveloper then
				loadstring(readfile('newvape/loader.lua'), 'loader')()
			else
				loadstring(game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true))()
			end
		end,
		Tooltip = 'This will set your profile to the default settings of Vape'
	})
	
	general:CreateButton({
		Name = 'Self destruct',
		Function = function()
			vape:Uninject()
		end,
		Tooltip = 'Removes vape from the current game'
	})
	
	general:CreateButton({
		Name = 'Reinject',
		Function = function()
			shared.vapereload = true
			if shared.VapeDeveloper then
				loadstring(readfile('newvape/loader.lua'), 'loader')()
			else
				loadstring(game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true))()
			end
		end,
		Tooltip = 'Reloads vape for debugging purposes'
	})
	
	--[[
		Module Settings
	]]
	
	local modules = vape.Categories.Main.Settings:CreateSettingsPane({Name = 'Modules'})
	modules:CreateToggle({
		Name = 'Teams by server',
		Tooltip = 'Ignore players on your team designated by the server',
		Default = true,
		Function = function()
			if vape.Libraries.entity and vape.Libraries.entity.Running then
				vape.Libraries.entity.refresh()
			end
		end
	})
	
	modules:CreateToggle({
		Name = 'Use team color',
		Tooltip = 'Uses the TeamColor property on players for render modules',
		Default = true,
		Function = function()
			if vape.Libraries.entity and vape.Libraries.entity.Running then
				vape.Libraries.entity.refresh()
			end
		end
	})
	
	--[[
		GUI Settings
	]]
	
	local guipane = vape.Categories.Main.Settings:CreateSettingsPane({Name = 'GUI'})
	vape.Blur = guipane:CreateToggle({
		Name = 'Blur background',
		Function = function()
			vape:BlurCheck()
		end,
		Default = true,
		Tooltip = 'Blur the background of the GUI'
	})
	
	guipane:CreateToggle({
		Name = 'GUI bind indicator',
		Default = true,
		Tooltip = "Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'"
	})
	
	guipane:CreateToggle({
		Name = 'Show tooltips',
		Function = function(enabled)
			tooltip.Visible = false
			toolblur.Enabled = enabled
		end,
		Default = true,
		Tooltip = 'Toggles visibility of these'
	})
	
	guipane:CreateToggle({
		Name = 'Show legit mode',
		Function = function(enabled)
			clickgui.Search.Legit.Visible = enabled
			clickgui.Search.LegitDivider.Visible = enabled
			clickgui.Search.TextBox.Size = UDim2.new(1, enabled and -50 or -10, 0, 37)
			clickgui.Search.TextBox.Position = UDim2.fromOffset(enabled and 50 or 10, 0)
		end,
		Default = true,
		Tooltip = 'Shows the button to switch to the legit mod menu'
	})
	
	local ScaleSlider = {Object = {}, Value = 1}
	vape.Scale = guipane:CreateToggle({
		Name = 'Auto rescale',
		Default = true,
		Function = function(callback)
			ScaleSlider.Object.Visible = not callback
			if callback then
				--scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
			else
				scale.Scale = ScaleSlider.Value
			end
		end,
		Tooltip = 'Automatically rescales the gui using the screens resolution'
	})
	
	ScaleSlider = guipane:CreateSlider({
		Name = 'Scale',
		Min = 0.1,
		Max = 2,
		Decimal = 10,
		Function = function(val, final)
			if final and not vape.Scale.Enabled then
				scale.Scale = val
			end
		end,
		Default = 1,
		Darker = true,
		Visible = false
	})
	
	vape.RainbowSpeed = guipane:CreateSlider({
		Name = 'Rainbow speed',
		Min = 0.1,
		Max = 10,
		Decimal = 10,
		Default = 1,
		Tooltip = 'Adjusts the speed of rainbow values'
	})
	
	vape.RainbowUpdateSpeed = guipane:CreateSlider({
		Name = 'Rainbow update rate',
		Min = 1,
		Max = 144,
		Default = 60,
		Tooltip = 'Adjusts the update rate of rainbow values',
		Suffix = 'hz'
	})
	
	--[[guipane:CreateDropdown({
		Name = 'GUI Theme',
		List = inputService.TouchEnabled and {'new', 'old'} or {'new', 'old', 'rise'},
		Function = function(val, mouse)
			if mouse then
				writefile('newvape/profiles/gui.txt', val)
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true))()
				end
			end
		end,
		Tooltip = 'new - The newest vape theme to since v4.05\nold - The vape theme pre v4.05\nrise - Rise 6.0'
	})]]
	
	guipane:CreateDropdown({
		Name = 'Search bar style',
		List = {'Floating', 'None'},
		Default = 'Floating',
		Function = function(value)
			vape.SearchBar.Object.Visible = value == 'Floating'
		end,
		Tooltip = 'Switch between search bar styles'
	})
	
	vape.RainbowMode = guipane:CreateDropdown({
		Name = 'Rainbow Mode',
		List = {'Normal', 'Gradient', 'Retro'},
		Tooltip = 'Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color'
	})
	
	guipane:CreateButton({
		Name = 'Reset GUI positions',
		Function = function()
			for _, category in vape.Categories do
				category.Object.Position = UDim2.fromOffset(6, 42)
			end
		end,
		Tooltip = 'This will reset your GUI back to the default'
	})
	
	guipane:CreateButton({
		Name = 'Sort GUI',
		Function = function()
			local priority = {
				GUICategory = 1,
				CombatCategory = 2,
				BlatantCategory = 3,
				RenderCategory = 4,
				UtilityCategory = 5,
				WorldCategory = 6,
				InventoryCategory = 7,
				FriendsCategory = 8,
				ProfilesCategory = 9
			}
	
			local categories = {}
			for _, category in vape.Categories do
				if category.Type ~= 'Overlay' then
					table.insert(categories, category)
				end
			end
	
			table.sort(categories, function(a, b)
				return (priority[a.Object.Name] or 99) < (priority[b.Object.Name] or 99)
			end)
	
			local index = 0
			for _, category in categories do
				if category.Object.Visible then
					category.Object.Position = UDim2.fromOffset(6 + (index % 8 * 230), 60 + (index > 7 and 360 or 0))
					index += 1
				end
			end
		end,
		Tooltip = 'Sorts GUI by category order'
	})
	
	--[[
		Notification Settings
	]]
	
	local notifpane = vape.Categories.Main.Settings:CreateSettingsPane({Name = 'Notifications'})
	vape.Notifications = notifpane:CreateToggle({
		Name = 'Notifications',
		Function = function(enabled)
			if vape.ToggleNotifications.Object then
				vape.ToggleNotifications.Object.Visible = enabled
			end
	
			if vape.SettingToggleNotifications.Object then
				vape.SettingToggleNotifications.Object.Visible = enabled
			end
		end,
		Tooltip = 'Shows notifications',
		Default = true
	})
	
	vape.ToggleNotifications = notifpane:CreateToggle({
		Name = 'Toggle alert',
		Tooltip = 'Notifies you if a module is enabled/disabled.',
		Default = true,
		Darker = true
	})
	vape.SettingToggleNotifications = notifpane:CreateToggle({
		Name = 'Setting toggle alert',
		Tooltip = 'Notifies you when a bound setting is toggled.',
		Default = true,
		Darker = true
	})
	
	vape.GUIColor = vape.Categories.Main.Settings:CreateGUISlider({
		Name = 'GUI Theme',
		Function = function(h, s, v)
			vape:UpdateGUI()
		end
	})
	
	vape.GUIBind = vape.Categories.Main.Settings:CreateBind({
		Name = 'Rebind GUI',
		Default = {'RightShift'},
		NoRemove = true,
		Tooltip = 'Change the bind of the GUI'
	})
	
	run(function()
		local Sort
		local FontOption
		local ColorSlider
		local ColorMode
		local Scale
		local Shadow
		local Gradient
		local GradientV4
		local Animations
		local Watermark
		local Background
		local BackgroundTransparency
		local BackgroundTint
		local HideModules
		local HideModulesList
		local HideRender
		local CustomText
		local CustomTextBox
		local CustomTextFont
		local CustomTextColor
		local CustomTextColorSlider
		local Labels = {}
		local info = TweenInfo.new(0.3, Enum.EasingStyle.Exponential)
		
		local function findValidLabel(labels, index, dir)
			local label = labels[index + dir]
			if label then
				if label.Size ~= UDim2.fromOffset() then
					return label
				else
					return findValidLabel(labels, index + dir, dir)
				end
			end
		end
		
		TextGUI = vape:CreateOverlay({
			Name = 'Text GUI',
			Icon = getvapeasset('newvape/assets/new/textgui.png'),
			Size = UDim2.fromOffset(16, 12),
			Position = UDim2.fromOffset(12, 14),
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		Sort = TextGUI:CreateDropdown({
			Name = 'Sort',
			List = {'Alphabetical', 'Length'},
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		FontOption = TextGUI:CreateFont({
			Name = 'Font',
			Default = 'Arial',
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		ColorMode = TextGUI:CreateDropdown({
			Name = 'Color Mode',
			List = {'Match GUI color', 'Custom color'},
			Function = function(value)
				ColorSlider.Object.Visible = value == 'Custom color'
				vape:UpdateTextGUI()
			end
		})
		ColorSlider = TextGUI:CreateColorSlider({
			Name = 'Text GUI color',
			Function = function()
				vape:UpdateGUI()
			end,
			Darker = true,
			Visible = false
		})
		TextGUI:CreateSlider({
			Name = 'Scale',
			Min = 0,
			Max = 2,
			Decimal = 10,
			Default = 1,
			Function = function(val)
				Scale.Scale = val
				vape:UpdateTextGUI()
			end
		})
		Shadow = TextGUI:CreateToggle({
			Name = 'Shadow',
			Tooltip = 'Renders shadowed text.',
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		Gradient = TextGUI:CreateToggle({
			Name = 'Gradient',
			Tooltip = 'Renders a gradient',
			Function = function(callback)
				GradientV4.Object.Visible = callback
				vape:UpdateTextGUI()
			end
		})
		GradientV4 = TextGUI:CreateToggle({
			Name = 'V4 Gradient',
			Function = function()
				vape:UpdateTextGUI()
			end,
			Darker = true,
			Visible = false
		})
		Animations = TextGUI:CreateToggle({
			Name = 'Animations',
			Tooltip = 'Use animations on text gui',
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		Watermark = TextGUI:CreateToggle({
			Name = 'Watermark',
			Tooltip = 'Renders a vape watermark',
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		Background = TextGUI:CreateToggle({
			Name = 'Render background',
			Function = function(callback)
				BackgroundTransparency.Object.Visible = callback
				BackgroundTint.Object.Visible = callback
				vape:UpdateTextGUI()
			end
		})
		BackgroundTransparency = TextGUI:CreateSlider({
			Name = 'Transparency',
			Min = 0,
			Max = 1,
			Default = 0.5,
			Decimal = 10,
			Function = function()
				vape:UpdateTextGUI()
			end,
			Darker = true,
			Visible = false
		})
		BackgroundTint = TextGUI:CreateToggle({
			Name = 'Tint',
			Function = function()
				vape:UpdateTextGUI()
			end,
			Darker = true,
			Visible = false
		})
		HideModules = TextGUI:CreateToggle({
			Name = 'Hide modules',
			Tooltip = 'Allows you to blacklist certain modules from being shown.',
			Function = function(enabled)
				HideModulesList.Object.Visible = enabled
				vape:UpdateTextGUI()
			end
		})
		HideModulesList = TextGUI:CreateTextList({
			Name = 'Blacklist',
			Tooltip = 'Name of module to hide.',
			Color = Color3.fromRGB(250, 50, 56),
			Function = function()
				vape:UpdateTextGUI()
			end,
			Visible = false,
			Darker = true
		})
		HideRender = TextGUI:CreateToggle({
			Name = 'Hide render',
			Function = function()
				vape:UpdateTextGUI()
			end
		})
		CustomText = TextGUI:CreateToggle({
			Name = 'Add custom text',
			Function = function(enabled)
				CustomTextBox.Object.Visible = enabled
				CustomTextFont.Object.Visible = enabled
				CustomTextColor.Object.Visible = enabled
				CustomTextColorSlider.Object.Visible = CustomTextColor.Enabled and enabled
				vape:UpdateTextGUI()
			end
		})
		CustomTextBox = TextGUI:CreateTextBox({
			Name = 'Custom text',
			Function = function()
				vape:UpdateTextGUI()
			end,
			Darker = true,
			Visible = false
		})
		CustomTextFont = TextGUI:CreateFont({
			Name = 'Custom Font',
			Default = 'Arial',
			Function = function()
				vape:UpdateTextGUI()
			end,
			Darker = true,
			Visible = false
		})
		CustomTextColor = TextGUI:CreateToggle({
			Name = 'Set custom text color',
			Function = function(enabled)
				CustomTextColorSlider.Object.Visible = enabled
				vape:UpdateGUI()
			end,
			Darker = true,
			Visible = false
		})
		CustomTextColorSlider = TextGUI:CreateColorSlider({
			Name = 'Color of custom text',
			Function = function(afterload)
				vape:UpdateGUI()
			end,
			Darker = true,
			Visible = false
		})
		
		
		--[[
			Text GUI Objects
		]]
		
		Scale = Instance.new('UIScale')
		Scale.Parent = TextGUI.Children
		local Logo = Instance.new('ImageLabel')
		Logo.BackgroundColor3 = Color3.new()
		Logo.BackgroundTransparency = 1
		Logo.BorderSizePixel = 0
		Logo.Image = getvapeasset('newvape/assets/new/vapelogo.png')
		Logo.Name = 'Logo'
		Logo.Position = UDim2.new(1, -142, 0, 3)
		Logo.Size = UDim2.fromOffset(81, 24)
		Logo.Visible = false
		Logo.Parent = TextGUI.Children
		local LogoV4 = Instance.new('ImageLabel')
		LogoV4.BackgroundColor3 = Color3.new()
		LogoV4.BackgroundTransparency = 1
		LogoV4.BorderSizePixel = 0
		LogoV4.Image = getvapeasset('newvape/assets/new/v4.png')
		LogoV4.Name = 'Logo2'
		LogoV4.Position = UDim2.new(1, -1, 0, 0)
		LogoV4.Size = UDim2.fromOffset(35, 24)
		LogoV4.Parent = Logo
		local LogoShadow = Logo:Clone()
		LogoShadow.ImageColor3 = Color3.new()
		LogoShadow.ImageTransparency = 0.65
		LogoShadow.Position = UDim2.fromOffset(1, 1)
		LogoShadow.Visible = true
		LogoShadow.ZIndex = 0
		LogoShadow.Parent = Logo
		LogoShadow.Logo2.ImageColor3 = Color3.new()
		LogoShadow.Logo2.ImageTransparency = 0.65
		LogoShadow.Logo2.ZIndex = 0
		local LogoGradient = Instance.new('UIGradient')
		LogoGradient.Rotation = 90
		LogoGradient.Parent = Logo
		local LogoGradient2 = Instance.new('UIGradient')
		LogoGradient2.Rotation = 90
		LogoGradient2.Parent = LogoV4
		local LabelCustom = Instance.new('TextLabel')
		LabelCustom.BackgroundTransparency = 1
		LabelCustom.BorderSizePixel = 0
		LabelCustom.FontFace = CustomTextFont.Value
		LabelCustom.Position = UDim2.fromOffset(5, 2)
		LabelCustom.Text = ''
		LabelCustom.TextSize = 25
		LabelCustom.Visible = false
		LabelCustom.RichText = true
		local LabelCustomShadow = LabelCustom:Clone()
		LabelCustomShadow.TextColor3 = Color3.new()
		LabelCustomShadow.TextTransparency = 0.65
		LabelCustomShadow.Parent = TextGUI.Children
		LabelCustom.Parent = TextGUI.Children
		local LabelHolder = Instance.new('Frame')
		LabelHolder.Name = 'Holder'
		LabelHolder.Size = UDim2.fromScale(1, 1)
		LabelHolder.Position = UDim2.fromOffset(5, 37)
		LabelHolder.BackgroundTransparency = 1
		LabelHolder.Parent = TextGUI.Children
		local ListLayout = Instance.new('UIListLayout')
		ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ListLayout.Parent = LabelHolder
		
		LabelCustom:GetPropertyChangedSignal('Position'):Connect(function()
			LabelCustomShadow.Position = UDim2.new(
				LabelCustom.Position.X.Scale,
				LabelCustom.Position.X.Offset + 1,
				0,
				LabelCustom.Position.Y.Offset + 1
			)
		end)
		
		LabelCustom:GetPropertyChangedSignal('FontFace'):Connect(function()
			LabelCustomShadow.FontFace = LabelCustom.FontFace
		end)
		
		LabelCustom:GetPropertyChangedSignal('Text'):Connect(function()
			LabelCustomShadow.Text = LabelCustom.ContentText
		end)
		
		LabelCustom:GetPropertyChangedSignal('Size'):Connect(function()
			LabelCustomShadow.Size = LabelCustom.Size
		end)
		
		local oldRight = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
		vape:Clean(TextGUI.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			local isRight = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
			if oldRight ~= isRight then
				vape:UpdateTextGUI()
				oldRight = isRight
			end
		end))
		
		function vape:UpdateTextGUI(afterload)
			if not afterload and not vape.Loaded then return end
			if TextGUI.Button.Enabled then
				local isRight = TextGUI.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
		
				Logo.Visible = Watermark.Enabled
				Logo.Position = isRight and UDim2.new(1 / Scale.Scale, -113, 0, 6) or UDim2.fromOffset(0, 6)
				LogoShadow.Visible = Shadow.Enabled
				LabelCustom.Text = CustomTextBox.Value
				LabelCustom.FontFace = CustomTextFont.Value
				LabelCustom.Visible = LabelCustom.Text ~= '' and CustomText.Enabled
				LabelCustomShadow.Visible = LabelCustom.Visible and Shadow.Enabled
				ListLayout.HorizontalAlignment = isRight and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
				LabelHolder.Size = UDim2.fromScale(1 / Scale.Scale, 1)
				LabelHolder.Position = UDim2.fromOffset(isRight and 3 or 0, 11 + (Logo.Visible and Logo.Size.Y.Offset or 0) + (LabelCustom.Visible and 28 or 0) + (Background.Enabled and 3 or 0))
		
				if LabelCustom.Visible then
					local size = getfontbounds(LabelCustom.ContentText, LabelCustom.TextSize, LabelCustom.FontFace)
					LabelCustom.Size = UDim2.fromOffset(size.X, size.Y)
					LabelCustom.Position = UDim2.new(isRight and 1 / Scale.Scale or 0, isRight and -size.X or 0, 0, (Logo.Visible and 32 or 8))
				end
		
				local Previous = {}
				for _, label in Labels do
					if label.Enabled then
						table.insert(Previous, label.Object.Name)
					end
		
					label.Object:Destroy()
				end
				table.clear(Labels)
		
				for name, module in vape.Modules do
					if HideModules.Enabled and table.find(HideModulesList.ListEnabled, name) then
						continue
					end
		
					if HideRender.Enabled and module.Category == 'Render' then
						continue
					end
		
					if module.Enabled or table.find(Previous, name) then
						local bkg, colorline
						local holder = Instance.new('Frame')
						holder.BackgroundTransparency = 1
						holder.ClipsDescendants = true
						holder.Name = name
						holder.Size = UDim2.fromOffset()
						holder.Parent = LabelHolder
		
						if Background.Enabled then
							bkg = Instance.new('Frame')
							bkg.BackgroundColor3 = color.Dark(uipallet.Main, 0.15)
							bkg.BackgroundTransparency = BackgroundTransparency.Value
							bkg.BorderSizePixel = 0
							bkg.Size = UDim2.new(1, 0, 1, 0)
							bkg.Parent = holder
							local corner = Instance.new('UICorner')
							corner.Parent = bkg
							local line = Instance.new('Frame')
							line.BackgroundColor3 = Color3.new()
							line.BackgroundTransparency = 0.928 + (0.072 * math.clamp((BackgroundTransparency.Value - 0.5) / 0.5, 0, 1))
							line.BorderSizePixel = 0
							line.Position = UDim2.new(0, 0, 1, -1)
							line.Size = UDim2.new(1, 0, 0, 1)
							line.Parent = bkg
							local line2 = line:Clone()
							line2.Position = UDim2.new()
							line2.Name = 'Line'
							line2.Parent = bkg
							colorline = Instance.new('Frame')
							colorline.BorderSizePixel = 0
							colorline.Position = isRight and UDim2.new(1, -4, 0, 0) or UDim2.new()
							colorline.Size = UDim2.new(0, 4, 1, 0)
							colorline.Parent = bkg
							local colorcorner = Instance.new('UICorner')
							colorcorner.CornerRadius = UDim.new()
							colorcorner.Parent = colorline
						end
		
						local label = Instance.new('TextLabel')
						label.BackgroundTransparency = 1
						label.BorderSizePixel = 0
						label.FontFace = FontOption.Value
						label.Position = UDim2.fromOffset(isRight and 5 or 9, 2)
						label.Text = name..(module.ExtraText and " <font color='#A8A8A8'>"..module.ExtraText()..'</font>' or '')
						label.TextSize = 18
						label.RichText = true
		
						local size = getfontbounds(label.ContentText, label.TextSize, label.FontFace)
						label.Size = UDim2.fromOffset(size.X, size.Y)
		
						if Shadow.Enabled then
							local shadowlabel = label:Clone()
							shadowlabel.Position = UDim2.fromOffset(label.Position.X.Offset + 1, label.Position.Y.Offset + 1)
							shadowlabel.Text = label.ContentText
							shadowlabel.TextColor3 = Color3.new()
							shadowlabel.Parent = holder
						end
		
						label.Parent = holder
		
						local tweenSize = UDim2.fromOffset(size.X + 16, size.Y + 6)
						if Animations.Enabled then
							if not table.find(Previous, name) then
								tween:Tween(holder, info, {
									Size = tweenSize
								})
							else
								holder.Size = tweenSize
								if not module.Enabled then
									tween:Tween(holder, info, {
										Size = UDim2.fromOffset()
									})
								end
							end
						else
							holder.Size = module.Enabled and tweenSize or UDim2.fromOffset()
						end
		
						table.insert(Labels, {
							Background = bkg,
							Color = colorline,
							Enabled = module.Enabled,
							Object = holder,
							Text = label,
							Size = module.Enabled and tweenSize or UDim2.fromOffset()
						})
					end
				end
		
				if Sort.Value == 'Alphabetical' then
					table.sort(Labels, function(a, b)
						return a.Text.Text < b.Text.Text
					end)
				else
					table.sort(Labels, function(a, b)
						return a.Text.Size.X.Offset > b.Text.Size.X.Offset
					end)
				end
		
				for index, label in Labels do
					if label.Color then
						local topLabel = findValidLabel(Labels, index, -1)
						local bottomLabel = findValidLabel(Labels, index, 1)
						local top = (not topLabel or (topLabel.Size.X.Offset < label.Size.X.Offset)) and 4 or 0
						local bottom = (not bottomLabel or (bottomLabel.Size.X.Offset < label.Size.X.Offset)) and 4 or 0
		
						label.Color.Parent.Line.Visible = index ~= 1
						label.Color.UICorner.TopLeftRadius = isRight and UDim.new() or UDim.new(0, index == 1 and 4 or 0)
						label.Color.UICorner.TopRightRadius = isRight and UDim.new(0, index == 1 and 4 or 0) or UDim.new()
						label.Color.UICorner.BottomLeftRadius = isRight and UDim.new() or UDim.new(0, index == #Labels and 4 or 0)
						label.Color.UICorner.BottomRightRadius = isRight and UDim.new(0, index == #Labels and 4 or 0) or UDim.new()
		
						label.Background.UICorner.TopLeftRadius = UDim.new(0, top)
						label.Background.UICorner.TopRightRadius = UDim.new(0, top)
						label.Background.UICorner.BottomLeftRadius = UDim.new(0, bottom)
						label.Background.UICorner.BottomRightRadius = UDim.new(0, bottom)
					end
		
					label.Object.LayoutOrder = index
				end
			end
		
			self:UpdateGUI()
		end
		
		function TextGUI:UpdateColor(hue, sat, val, default)
			LogoGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
				ColorSequenceKeypoint.new(1, Gradient.Enabled and Color3.fromHSV(vape:Color((hue - 0.075) % 1)) or Color3.fromHSV(hue, sat, val))
			})
			LogoGradient2.Color = Gradient.Enabled and GradientV4.Enabled and LogoGradient.Color or ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
			})
			LabelCustom.TextColor3 = CustomTextColor.Enabled and Color3.fromHSV(CustomTextColorSlider.Hue, CustomTextColorSlider.Sat, CustomTextColorSlider.Value) or LogoGradient.Color.Keypoints[2].Value
		
			local isCustom = ColorMode.Value == 'Custom color' and Color3.fromHSV(ColorSlider.Hue, ColorSlider.Sat, ColorSlider.Value) or nil
			for index, label in Labels do
				label.Text.TextColor3 = isCustom or (vape.GUIColor.Rainbow and Color3.fromHSV(vape:Color((hue - ((Gradient.Enabled and index + 2 or index) * 0.025)) % 1)) or LogoGradient.Color.Keypoints[2].Value)
		
				if label.Color then
					label.Color.BackgroundColor3 = label.Text.TextColor3
				end
		
				if BackgroundTint.Enabled and label.Background then
					label.Background.BackgroundColor3 = color.Dark(label.Text.TextColor3, 0.75)
				end
			end
		end
	end)
	
	run(function()
		--[[
			Target Info
		]]
		
		local targetinfo = {
			Targets = {},
			Object = Holder,
			Health = 0,
			MaxHealth = 0
		}
		local TargetInfoOverlay
		local BackgroundTransparency = {
			Value = 0.5,
			Object = {Visible = {}}
		}
		local BorderColor
		local BKGColor
		local CustomColor
		local DisplayName
		
		TargetInfoOverlay = vape:CreateOverlay({
			Name = 'Target Info',
			Icon = getvapeasset('newvape/assets/new/targetinfo.png'),
			Size = UDim2.fromOffset(14, 14),
			Position = UDim2.fromOffset(12, 14),
			CategorySize = 240,
			Function = function(callback)
				if callback then
					TargetInfoOverlay:Clean(runService.RenderStepped:Connect(function()
						targetinfo:Update()
					end))
				end
			end
		})
		
		local Holder = Instance.new('Frame')
		Holder.Size = UDim2.fromOffset(240, 89)
		Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
		Holder.BackgroundTransparency = 0.5
		Holder.Parent = TargetInfoOverlay.Children
		local BlurHolder = addBlur(Holder, nil, true)
		BlurHolder.Visible = false
		addCorner(Holder)
		local Headshot = Instance.new('ImageLabel')
		Headshot.Size = UDim2.fromOffset(26, 27)
		Headshot.Position = UDim2.fromOffset(19, 17)
		Headshot.BackgroundColor3 = uipallet.Main
		Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420'
		Headshot.Parent = Holder
		addCorner(Headshot)
		local HurtFlash = Instance.new('Frame')
		HurtFlash.Size = UDim2.fromScale(1, 1)
		HurtFlash.BackgroundTransparency = 1
		HurtFlash.BackgroundColor3 = Color3.new(1, 0, 0)
		HurtFlash.Parent = Headshot
		addCorner(HurtFlash)
		local HeadshotBlur = addBlur(Headshot)
		HeadshotBlur.Enabled = false
		local Name = Instance.new('TextLabel')
		Name.Size = UDim2.fromOffset(145, 20)
		Name.Position = UDim2.fromOffset(54, 20)
		Name.BackgroundTransparency = 1
		Name.Text = 'Target name'
		Name.TextXAlignment = Enum.TextXAlignment.Left
		Name.TextYAlignment = Enum.TextYAlignment.Top
		Name.TextScaled = true
		Name.TextColor3 = color.Light(uipallet.Text, 0.4)
		Name.TextStrokeTransparency = 1
		Name.FontFace = uipallet.Font
		local NameShadow = Name:Clone()
		NameShadow.Position = UDim2.fromOffset(55, 21)
		NameShadow.TextColor3 = Color3.new()
		NameShadow.TextTransparency = 0.65
		NameShadow.Visible = false
		NameShadow.Parent = Holder
		for _, prop in {'Size', 'Text', 'FontFace'} do
			Name:GetPropertyChangedSignal(prop):Connect(function()
				NameShadow[prop] = Name[prop]
			end)
		end
		Name.Parent = Holder
		local HealthBKG = Instance.new('Frame')
		HealthBKG.Name = 'HealthBKG'
		HealthBKG.Size = UDim2.fromOffset(200, 9)
		HealthBKG.Position = UDim2.fromOffset(20, 56)
		HealthBKG.BackgroundColor3 = uipallet.Main
		HealthBKG.BorderSizePixel = 0
		HealthBKG.Parent = Holder
		addCorner(HealthBKG, UDim.new(1, 0))
		local Health = HealthBKG:Clone()
		Health.Size = UDim2.fromScale(0.8, 1)
		Health.Position = UDim2.new()
		Health.BackgroundColor3 = Color3.fromHSV(1 / 2.5, 0.89, 0.75)
		Health.Parent = HealthBKG
		Health:GetPropertyChangedSignal('Size'):Connect(function()
			Health.Visible = Health.Size.X.Scale > 0.01
		end)
		local Armor = Health:Clone()
		Armor.Size = UDim2.new()
		Armor.Position = UDim2.fromScale(1, 0)
		Armor.AnchorPoint = Vector2.new(1, 0)
		Armor.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
		Armor.Visible = false
		Armor.Parent = HealthBKG
		Armor:GetPropertyChangedSignal('Size'):Connect(function()
			Armor.Visible = Armor.Size.X.Scale > 0.01
		end)
		local HealthBlur = addBlur(HealthBKG)
		HealthBlur.Enabled = false
		local Stroke = Instance.new('UIStroke')
		Stroke.Enabled = false
		Stroke.Color = Color3.fromHSV(0.44, 1, 1)
		Stroke.Parent = Holder
		
		TargetInfoOverlay:CreateFont({
			Name = 'Font',
			Default = 'Arial',
			Function = function(val)
				Name.FontFace = val
			end
		})
		DisplayName = TargetInfoOverlay:CreateToggle({
			Name = 'Use Displayname',
			Default = true
		})
		TargetInfoOverlay:CreateToggle({
			Name = 'Render Background',
			Function = function(callback)
				Holder.BackgroundTransparency = callback and BackgroundTransparency.Value or 1
				NameShadow.Visible = not callback
				BlurHolder.Visible = callback
				HealthBlur.Enabled = not callback
				HeadshotBlur.Enabled = not callback
				BackgroundTransparency.Object.Visible = callback
			end,
			Default = true
		})
		BackgroundTransparency = TargetInfoOverlay:CreateSlider({
			Name = 'Transparency',
			Min = 0,
			Max = 1,
			Default = 0.5,
			Decimal = 10,
			Function = function(val)
				Holder.BackgroundTransparency = val
			end,
			Darker = true
		})
		CustomColor = TargetInfoOverlay:CreateToggle({
			Name = 'Custom Color',
			Function = function(callback)
				BKGColor.Object.Visible = callback
				if callback then
					Holder.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, BKGColor.Value)
					Headshot.BackgroundColor3 = Color3.fromHSV(BKGColor.Hue, BKGColor.Sat, math.max(BKGColor.Value - 0.1, 0.075))
					HealthBKG.BackgroundColor3 = Headshot.BackgroundColor3
				else
					Holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
					Headshot.BackgroundColor3 = uipallet.Main
					HealthBKG.BackgroundColor3 = uipallet.Main
				end
			end
		})
		BKGColor = TargetInfoOverlay:CreateColorSlider({
			Name = 'Color',
			Function = function(hue, sat, val)
				if CustomColor.Enabled then
					Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
					Headshot.BackgroundColor3 = Color3.fromHSV(hue, sat, math.max(val - 0.1, 0))
					HealthBKG.BackgroundColor3 = Headshot.BackgroundColor3
				end
			end,
			Darker = true,
			Visible = false
		})
		TargetInfoOverlay:CreateToggle({
			Name = 'Border',
			Function = function(callback)
				Stroke.Enabled = callback
				BorderColor.Object.Visible = callback
			end
		})
		BorderColor = TargetInfoOverlay:CreateColorSlider({
			Name = 'Border Color',
			Function = function(hue, sat, val, opacity)
				Stroke.Color = Color3.fromHSV(hue, sat, val)
				Stroke.Transparency = 1 - opacity
			end,
			Darker = true,
			Visible = false
		})
		
		function targetinfo:Update()
			local entitylib = vape.Libraries
			if not entitylib then return end
		
			local cloned = table.clone(self.Targets)
			for index, expire in cloned do
				if expire < tick() then
					self.Targets[index] = nil
				end
			end
			table.clear(cloned)
		
			local entity, highest = nil, tick()
			for index, level in self.Targets do
				if level > highest then
					entity = index
					highest = level
				end
			end
		
			Holder.Visible = entity ~= nil or clickgui.Visible
			if entity then
				Name.Text = entity.Player and (DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character and entity.Character.Name or Name.Text
				Headshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..(entity.Player and entity.Player.UserId or 1)..'&w=420&h=420'
		
				if not entity.Character then
					entity.Health = entity.Health or 0
					entity.MaxHealth = entity.MaxHealth or 100
				end
		
				if entity.Health ~= self.Health or entity.MaxHealth ~= self.MaxHealth then
					local percent = math.max(entity.Health / entity.MaxHealth, 0)
		
					tween:Tween(Health, TweenInfo.new(0.3), {
						Size = UDim2.fromScale(math.min(percent, 1), 1), BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
					})
		
					tween:Tween(Armor, TweenInfo.new(0.3), {
						Size = UDim2.fromScale(math.clamp(percent - 1, 0, 0.8), 1)
					})
		
					if self.Health > entity.Health and self.LastTarget == entity then
						tween:Cancel(HurtFlash)
						HurtFlash.BackgroundTransparency = 0.3
						tween:Tween(HurtFlash, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						})
					end
		
					self.Health = entity.Health
					self.MaxHealth = entity.MaxHealth
				end
		
				if not entity.Character then
					table.clear(entity)
				end
		
				self.LastTarget = entity
			end
		end
		
		vape.Libraries.targetinfo = targetinfo
	end)
	
	vape:Clean(task.spawn(function()
		local hue = 0
		repeat
			for _, component in vape.RainbowSliders do
				if component.Type == 'GUISlider' then
					component:SetValue(vape:Color(hue))
				else
					component:SetValue(hue)
				end
			end
	
			local delta = task.wait(1 / vape.RainbowUpdateSpeed.Value)
			hue = (hue + (delta * (0.2 * vape.RainbowSpeed.Value))) % 1
		until false
	end))
	
	local cursorConnection
	vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
		vape:UpdateGUI()
	
		if clickgui.Visible and inputService.MouseEnabled then
			if cursorConnection then
				cursorConnection:Disconnect()
			end
	
			cursorConnection = runService.RenderStepped:Connect(function()
				local isVisible = clickgui.Visible
				for _, window in vape.Windows do
					isVisible = isVisible or window.Visible
				end
	
				if not isVisible then
					cursor.Visible = false
					cursorConnection:Disconnect()
					cursorConnection = nil
					return
				end
	
				cursor.Visible = not inputService.MouseIconEnabled
				if cursor.Visible then
					local mouseLocation = inputService:GetMouseLocation()
					cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32)
				end
			end)
		end
	end))
	
	vape:Clean(function()
		if cursorConnection then
			cursorConnection:Disconnect()
		end
	end)
	
	vape:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
		if vape.Scale.Enabled then
			scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
		end
	end))
	
	vape:Clean(notifications.ChildRemoved:Connect(function()
		for index, notif in notifications:GetChildren() do
			if tween.Tween then
				tween:Tween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					Position = UDim2.new(1, 0, 1, -(29 + (78 * index)))
				})
			end
		end
	end))
	
	vape:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
		scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
	
		for _, obj in scaledgui:QueryDescendants('GuiObject >> [Visible = true]') do
			obj.Visible = false
			obj.Visible = true
		end
	end))
	
	vape:Clean(vape.GUIBind.Triggered:Connect(function()
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		for _, window in self.Windows do
			window.Visible = false
		end
	
		for _, module in self.Modules do
			if module.Bind.Mobile then
				module.Bind.Mobile.Visible = clickgui.Visible
			end
		end
	
		clickgui.Visible = not clickgui.Visible
		vape:BlurCheck()
	end))
	
	vape:Clean(inputService.InputBegan:Connect(function(input)
		if vape.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
			vape.CurrentTooltip()
		end
	
		if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
			table.insert(vape.HeldKeybinds, input.KeyCode.Name)
			if vape.Binding then return end
	
			for _, bind in vape.ActiveBinds do
				if checkKeybinds(vape.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
					bind.Triggered:Fire(true)
				end
			end
		end
	end))
	
	vape:Clean(inputService.InputEnded:Connect(function(input)
		if vape.CurrentTooltip and input.KeyCode == Enum.KeyCode.LeftShift then
			vape.CurrentTooltip()
		end
	
		if not inputService:GetFocusedTextBox() and input.KeyCode ~= Enum.KeyCode.Unknown then
			if vape.Binding then
				if not vape.MultiKeybind.Enabled then
					vape.HeldKeybinds = {input.KeyCode.Name}
				end
	
				vape.Binding:SetBind(vape.HeldKeybinds, true)
				vape.Binding = nil
			else
				for _, bind in vape.ActiveBinds do
					if bind.Hold and checkKeybinds(vape.HeldKeybinds, bind.Keys, input.KeyCode.Name) then
						bind.Triggered:Fire(false)
					end
				end
			end
		end
	
		local index = table.find(vape.HeldKeybinds, input.KeyCode.Name)
		if index then
			table.remove(vape.HeldKeybinds, index)
		end
	end))
end

function vape:Remove(obj)
	local container = (self.Modules[obj] and self.Modules or self.Legit.Modules[obj] and self.Legit.Modules or self.Categories)
	if container and container[obj] then
		local component = container[obj]
		local isModule = component.Type == 'Module'
		if self.ThreadFix then
			setthreadidentity(8)
		end

		if component.Destroy then
			component:Destroy()
		end

		for _, child in {'Object', 'Children', 'Toggle', 'Button'} do
			child = typeof(component[child]) == 'table' and component[child].Object or component[child]

			if typeof(child) == 'Instance' then
				child:Destroy()
				child:ClearAllChildren()
			end
		end

		loopClean(component)
		container[obj] = nil

		if isModule then
			self:SortCategories()
		end
	end
end

function vape:Save(newProfile)
	if not self.Loaded then
		return
	end

	local guiData = {
		Categories = {},
		Profile = newProfile or self.Profile,
		v = 1
	}

	local mainData = {
		Modules = {},
		Categories = {},
		Legit = {},
		v = 1
	}

	for name, category in self.Categories do
		category:Save((category.Type == 'Overlay' and mainData or guiData).Categories)
	end

	for _, module in self.Modules do
		module:Save(mainData.Modules)
	end

	for _, module in self.Legit.Modules do
		module:Save(mainData.Legit)
	end

	writefile('newvape/profiles/'..game.GameId..'.gui.txt', httpService:JSONEncode(guiData))
	writefile('newvape/profiles/'..self.Profile..self.Place..'.txt', httpService:JSONEncode(mainData))
end

function vape:SaveOptions(obj)
	local data = {}
	for _, component in obj.Options do
		if not component.Save then
			continue
		end

		component:Save(data)
	end

	return data
end

function vape:SortCategories()
	local sorting = {}
	for _, module in self.Modules do
		sorting[module.Category] = sorting[module.Category] or {}
		table.insert(sorting[module.Category], module.Name)
	end

	for _, sort in sorting do
		table.sort(sort)
		for index, name in sort do
			self.Modules[name].Index = index
			self.Modules[name].Object.LayoutOrder = index
			self.Modules[name].Children.LayoutOrder = index
		end
	end
end

function vape:Uninject()
	self:Save()
	self.Loaded = nil

	for _, module in self.Modules do
		if module.Enabled then
			module:Toggle()
		end
	end

	for _, module in self.Legit.Modules do
		if module.Enabled then
			module:Toggle()
		end
	end

	for _, category in self.Categories do
		if category.Type == 'Overlay' and category.Button.Enabled then
			category.Button:Toggle()
		end
	end

	for _, connection in self.Connections do
		pcall(function()
			connection:Disconnect()
		end)
	end

	if self.ThreadFix then
		setthreadidentity(8)
		clickgui.Visible = false
		self:BlurCheck()
	end

	gui:ClearAllChildren()
	gui:Destroy()
	table.clear(self.Connections)
	table.clear(self.Libraries)
	loopClean(self)

	shared.vape = nil
	shared.vapereload = nil
	shared.VapeIndependent = nil
end

local guiUpdate
function vape:UpdateGUI()
	if guiUpdate then
		return
	end

	guiUpdate = runService.RenderStepped:Once(function()
		if vape.Loaded ~= nil then
			vape:UpdateGUIQueue(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
		end

		guiUpdate = nil
	end)
end

function vape:UpdateGUIQueue(hue, sat, val)
	if TextGUI.Button.Enabled then
		TextGUI:UpdateColor(hue, sat, val, default)
	end

	if not clickgui.Visible and not vape.Legit.Window.Visible then return end
	local isRainbow = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro'

	for name, component in vape.Categories do
		component:Color(hue, sat, val, isRainbow)
	end

	for _, component in vape.Modules do
		component:Color(hue, sat, val, isRainbow)
	end

	for _, component in vape.Overlays.Options do
		if component.Color then
			component:Color(hue, sat, val, isRainbow)
		end
	end

	for _, pane in vape.Settings do
		for _, component in pane.Options do
			if component.Color then
				component:Color(hue, sat, val, isRainbow)
			end
		end
	end

	if vape.Legit.Window.Visible then
		for _, component in vape.Legit.Modules do
			component:Color(hue, sat, val, isRainbow)
		end
	end
end

components = {
	Bind = function(props, children, api)
		local component = {
			Hold = props.Hold or false,
			Keys = {},
			Triggered = createSignal(),
			Type = 'Bind'
		}
		
		local bind = Instance.new('TextButton')
		bind.AnchorPoint = Vector2.new(1, 0)
		bind.AutoButtonColor = false
		bind.BackgroundColor3 = Color3.new(1, 1, 1)
		bind.BackgroundTransparency = 0.92
		bind.BorderSizePixel = 0
		bind.Name = 'Bind'
		bind.Size = UDim2.fromOffset(20, 20)
		bind.Visible = false
		bind.Text = ''
		addCorner(bind, UDim.new(0, 4))
		addTooltip(bind, '', function()
			local holdText = 'Bind functionality = '..(component.Hold and 'Enable while held' or 'Toggle')
			if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				holdText = "<font color='#FF5A5A'>"..holdText.."</font>"
			end
		
			return 'Click to bind\nShift click to modify bind functionality\n'..holdText
		end)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/bind.png')
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		icon.Name = 'Icon'
		icon.Position = UDim2.new(0.5, -5, 0, 5)
		icon.Size = UDim2.fromOffset(10, 10)
		icon.Parent = bind
		local label = Instance.new('TextLabel')
		label.BackgroundTransparency = 1
		label.FontFace = uipallet.Font
		label.Position = UDim2.fromOffset(-1, 0)
		label.Size = UDim2.fromScale(1, 1)
		label.Text = ''
		label.TextColor3 = color.Dark(uipallet.Text, 0.43)
		label.TextSize = 12
		label.Visible = false
		label.Parent = bind
		local cover
		local coverlabel
		
		if props.Module then
			if props.Cover then
				cover = Instance.new('ImageLabel')
				cover.BackgroundTransparency = 1
				cover.Image = getvapeasset('newvape/assets/new/bindbkg.png')
				cover.Name = 'Cover'
				cover.ScaleType = Enum.ScaleType.Slice
				cover.SliceCenter = Rect.new(0, 0, 141, 40)
				cover.Size = UDim2.fromOffset(154, 40)
				cover.Visible = false
				cover.Parent = api.Object
				coverlabel = Instance.new('TextLabel')
				coverlabel.BackgroundTransparency = 1
				coverlabel.FontFace = uipallet.Font
				coverlabel.Name = 'Text'
				coverlabel.Size = UDim2.new(1, -10, 1, -3)
				coverlabel.Text = 'PRESS A KEY TO BIND'
				coverlabel.TextColor3 = uipallet.Text
				coverlabel.TextSize = 11
				coverlabel.Parent = cover
			end
		
			bind.Position = UDim2.new(1, -36, 0, 10)
			bind.Parent = api.Object
			component.Object = bind
		else
			local holder = Instance.new('TextButton')
			holder.AutoButtonColor = false
			holder.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
			holder.BorderSizePixel = 0
			holder.FontFace = uipallet.Font
			holder.Size = UDim2.new(1, 0, 0, 40)
			holder.Text = '          '..props.Name
			holder.TextColor3 = color.Dark(uipallet.Text, 0.16)
			holder.TextSize = 14
			holder.TextXAlignment = Enum.TextXAlignment.Left
			holder.Visible = props.Visible == nil or props.Visible
			holder.Parent = children
			addTooltip(holder, props.Tooltip)
			bind.Position = UDim2.new(1, -10, 0, 10)
			bind.Visible = true
			bind.Parent = holder
			component.Object = holder
		end
		
		function component:CreateMobileButton(position)
			self:DestroyMobileButton()
		
			local isHeld = false
			local button = Instance.new('TextButton')
			button.AnchorPoint = Vector2.new(0.5, 0.5)
			button.BackgroundColor3 = api.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
			button.BackgroundTransparency = 0.5
			button.Font = Enum.Font.Gotham
			button.Position = UDim2.fromOffset(position.X, position.Y)
			button.Size = UDim2.fromOffset(40, 40)
			button.Text = api.Name or 'Button'
			button.TextColor3 = Color3.new(1, 1, 1)
			button.TextScaled = true
			button.Parent = gui
			local constraint = Instance.new('UITextSizeConstraint')
			constraint.MaxTextSize = 16
			constraint.Parent = button
			addCorner(button, UDim.new(1, 0))
		
			button.MouseButton1Down:Connect(function()
				isHeld = true
		
				local holdtime, holdPos = os.clock(), inputService:GetMouseLocation()
				repeat
					isHeld = (inputService:GetMouseLocation() - holdPos).Magnitude < 6
		
					task.wait()
				until (os.clock() - holdtime) > 1 or not isHeld
		
				if isHeld then
					self:DestroyMobileButton()
				end
			end)
		
			button.MouseButton1Up:Connect(function()
				isHeld = false
			end)
		
			button.MouseButton1Click:Connect(function()
				self.Triggered:Fire(true)
				button.BackgroundColor3 = api.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
			end)
		
			self.Mobile = button
		end
		
		function component:Destroy()
			bind:Destroy()
			bind:ClearAllChildren()
		
			if self.Object then
				self.Object:Destroy()
				self.Object:ClearAllChildren()
			end
		
			if self.Mobile then
				self.Mobile:Destroy()
				self.Mobile = nil
			end
		
			local index = table.find(vape.ActiveBinds, self)
			if index then
				table.remove(vape.ActiveBinds, index)
			end
		end
		
		function component:DestroyMobileButton()
			if self.Mobile then
				self.Mobile:Destroy()
				self.Mobile = nil
			end
		end
		
		function component:Load(data)
			self.Hold = data.Hold
			self:SetBind(data.Keys)
		
			if data.Mobile then
				self:CreateMobileButton(Vector2.new(data.Mobile.X, data.Mobile.Y))
			end
		end
		
		function component:Save(data)
			data[props and props.Name or 'Bind'] = {
				Keys = self.Keys,
				Mobile = self.Mobile and {
					X = self.Mobile.Position.X.Offset,
					Y = self.Mobile.Position.Y.Offset
				},
				Hold = self.Hold
			}
		end
		
		function component:SetBind(keys, mouse)
			if props and props.NoRemove and #keys <= 0 then
				keys = props.Default
			end
		
			self.Binding = nil
			self.Keys = table.clone(keys)
		
			if mouse then
				icon.Image = getvapeasset('newvape/assets/new/edit.png')
		
				if cover then
					coverlabel.Text = #keys <= 0 and 'BIND REMOVED' or 'BOUND TO'
					cover.Size = UDim2.fromOffset(getfontbounds(coverlabel.Text, coverlabel.TextSize, coverlabel.FontFace).X + 20, 40)
		
					task.delay(1, function()
						cover.Visible = false
					end)
				end
			end
		
			if #keys <= 0 then
				label.Visible = false
				icon.Visible = true
				bind.Size = UDim2.fromOffset(20, 20)
		
				local index = table.find(vape.ActiveBinds, component)
				if index then
					table.remove(vape.ActiveBinds, index)
				end
			else
				bind.Visible = true
				label.Visible = true
				icon.Visible = false
				label.Text = table.concat(keys, ' + '):upper()
				bind.Size = UDim2.fromOffset(math.max(getfontbounds(label.Text, label.TextSize, label.FontFace).X + 10, 20), 20)
		
				if not table.find(vape.ActiveBinds, component) then
					table.insert(vape.ActiveBinds, component)
				end
			end
		end
		
		function component:SetColor(newColor)
			icon.ImageColor3 = newColor
			label.TextColor3 = newColor
		end
		
		function component:SetParent(parent)
			bind.Parent = parent
		
			if cover then
				cover.Parent = parent
			end
		end
		
		function component:SetVisible(visible)
			bind.Visible = #self.Keys > 0 or visible
		end
		
		bind.MouseEnter:Connect(function()
			label.Visible = false
			icon.Visible = not label.Visible
			icon.Image = getvapeasset(component.Binding and 'newvape/assets/new/close.png' or 'newvape/assets/new/edit.png')
		
			if not props.Cover or not api.Enabled then
				icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
			end
		end)
		
		bind.MouseLeave:Connect(function()
			label.Visible = #component.Keys > 0
			icon.Visible = not label.Visible
			icon.Image = getvapeasset(component.Binding and 'newvape/assets/new/close.png' or 'newvape/assets/new/bind.png')
		
			if not props.Cover or not api.Enabled then
				icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
			end
		end)
		
		bind.MouseButton1Click:Connect(function()
			if vape.Binding then
				if vape.Binding == component then
					component:SetBind({}, true)
					vape.Binding = nil
				end
		
				return
			end
		
			if props.Module and inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				component.Hold = not component.Hold
				if vape.CurrentTooltip then
					vape.CurrentTooltip()
				end
		
				return
			end
		
			if cover then
				coverlabel.Text = 'PRESS A KEY TO BIND'
				cover.Size = UDim2.fromOffset(getfontbounds(coverlabel.Text, coverlabel.TextSize, coverlabel.FontFace).X + 20, 40)
				cover.Visible = true
			end
		
			component.Binding = true
			icon.Image = getvapeasset('newvape/assets/new/close.png')
			vape.Binding = component
		end)
		
		if props.Module then
			api.Bind = component
		else
			if props.Default then
				component:SetBind(props.Default)
			end
		
			api.Options[props.Name] = component
		end
		
		return component
	end,
	Button = function(props, children, api)
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		button.BorderSizePixel = 0
		button.Size = UDim2.new(1, 0, 0, 31)
		button.Text = ''
		button.Parent = children
		addTooltip(button, props.Tooltip)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		holder.Position = UDim2.fromOffset(10, 2)
		holder.Size = UDim2.fromOffset(200, 27)
		holder.Parent = button
		addCorner(holder)
		local title = Instance.new('TextLabel')
		title.BackgroundColor3 = uipallet.Main
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(2, 2)
		title.Size = UDim2.new(1, -4, 1, -4)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 14
		title.Parent = holder
		addCorner(title, UDim.new(0, 4))
		props.Function = props.Function or function() end
		
		button.MouseEnter:Connect(function()
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
			})
		end)
		
		button.MouseLeave:Connect(function()
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			})
		end)
		
		button.MouseButton1Click:Connect(props.Function)
	end,
	Category = function(props, children, api)
		local component = {
			Expanded = false,
			Name = props.Name,
			Type = 'Category'
		}
		
		local window = Instance.new('TextButton')
		window.AutoButtonColor = false
		window.BackgroundColor3 = uipallet.Main
		window.Name = props.Name..'Category'
		window.Position = UDim2.fromOffset(236, 60)
		window.Size = UDim2.fromOffset(220, 41)
		window.Text = ''
		window.Visible = false
		window.Parent = clickgui
		addBlur(window)
		addCorner(window)
		addDragHandler(window)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = props.Icon
		icon.ImageColor3 = uipallet.Text
		icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 20 and 14 or 13))
		icon.Size = props.Size
		icon.Parent = window
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Size = UDim2.new(1, -(props.Size.X.Offset > 18 and 40 or 33), 0, 41)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = window
		local pencilbutton = Instance.new('TextButton')
		pencilbutton.BackgroundTransparency = 1
		pencilbutton.Position = UDim2.new(1, -49, 0, 0)
		pencilbutton.Size = UDim2.fromOffset(20, 40)
		pencilbutton.Text = ''
		pencilbutton.Visible = false
		pencilbutton.Parent = window
		addTooltip(pencilbutton, 'Edit hidden modules')
		local pencil = Instance.new('ImageLabel')
		pencil.BackgroundTransparency = 1
		pencil.Image = getvapeasset('newvape/assets/new/editlarge.png')
		pencil.ImageColor3 = Color3.fromRGB(140, 140, 140)
		pencil.Size = UDim2.fromOffset(12, 12)
		pencil.Position = UDim2.fromOffset(4, 14)
		pencil.Parent = pencilbutton
		local arrowbutton = Instance.new('TextButton')
		arrowbutton.BackgroundTransparency = 1
		arrowbutton.Position = UDim2.new(1, -29, 0, 0)
		arrowbutton.Size = UDim2.fromOffset(27, 40)
		arrowbutton.Text = ''
		arrowbutton.Parent = window
		local arrow = Instance.new('ImageLabel')
		arrow.BackgroundTransparency = 1
		arrow.Image = getvapeasset('newvape/assets/new/downexpand.png')
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		arrow.Size = UDim2.fromOffset(9, 4)
		arrow.Position = UDim2.fromOffset(9, 18)
		arrow.Rotation = 180
		arrow.Parent = arrowbutton
		local done = Instance.new('TextButton')
		done.BackgroundTransparency = 1
		done.FontFace = uipallet.Font
		done.Position = UDim2.new(1, -73, 0, 0)
		done.Size = UDim2.fromOffset(42, 40)
		done.Text = 'DONE'
		done.TextColor3 = Color3.fromRGB(140, 140, 140)
		done.TextSize = 12
		done.Visible = false
		done.Parent = window
		component.Done = done
		local children = Instance.new('ScrollingFrame')
		children.BackgroundTransparency = 1
		children.BorderSizePixel = 0
		children.CanvasSize = UDim2.new()
		children.Name = 'Children'
		children.Position = UDim2.fromOffset(0, 37)
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.Size = UDim2.new(1, 0, 1, -41)
		children.Visible = false
		children.Parent = window
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = Color3.new(1, 1, 1)
		divider.BackgroundTransparency = 0.928
		divider.BorderSizePixel = 0
		divider.Position = UDim2.fromOffset(0, 37)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Visible = false
		divider.Parent = window
		local stroke = Instance.new('UIStroke')
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(85, 85, 85)
		stroke.Transparency = 0.8
		stroke.Parent = window
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		
		function component:Color(hue, sat, val, isRainbow) end
		
		function component:Expand()
			self.Expanded = not self.Expanded
			children.Visible = self.Expanded
			arrow.Rotation = self.Expanded and 0 or 180
			window.Size = UDim2.fromOffset(220, self.Expanded and math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601) or 41)
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
		end
		
		function component:Load(data)
			if data.Enabled then
				self.Button:Toggle()
			end
		
			if data.Expanded then
				self:Expand()
			end
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Button.Enabled,
				Expanded = self.Expanded,
				Position = {
					X = window.Position.X.Offset,
					Y = window.Position.Y.Offset
				}
			}
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, children, component)
			end
		end
		
		arrowbutton.MouseButton1Click:Connect(function()
			component:Expand()
		end)
		
		arrowbutton.MouseButton2Click:Connect(function()
			component:Expand()
		end)
		
		arrowbutton.MouseEnter:Connect(function()
			arrow.ImageColor3 = Color3.fromRGB(220, 220, 220)
		end)
		
		arrowbutton.MouseLeave:Connect(function()
			arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		end)
		
		done.MouseButton1Click:Connect(function()
			vape.EditGUI = false
			pencilbutton.Visible = true
		
			for _, category in vape.Categories do
				if category.Type == 'Category' then
					category.Done.Visible = false
				end
			end
		
			for _, module in vape.Modules do
				module.Object.Visible = module.Visible
				module.Object.Text = string.rep(' ', 12)..module.Name
				module.Edit.Visible = false
			end
		end)
		
		done.MouseEnter:Connect(function()
			done.TextColor3 = Color3.fromRGB(220, 220, 220)
		end)
		
		done.MouseLeave:Connect(function()
			done.TextColor3 = Color3.fromRGB(140, 140, 140)
		end)
		
		pencilbutton.MouseButton1Click:Connect(function()
			vape.EditGUI = true
			pencilbutton.Visible = false
		
			for _, category in vape.Categories do
				if category.Type == 'Category' then
					category.Done.Visible = true
				end
			end
		
			for _, module in vape.Modules do
				module.Object.Visible = true
				module.Object.Text = string.rep(' ', 50)..module.Name
				module.Edit.Visible = true
			end
		end)
		
		pencilbutton.MouseButton2Click:Connect(function()
			component:Expand()
		end)
		
		pencilbutton.MouseEnter:Connect(function()
			pencil.ImageColor3 = Color3.fromRGB(220, 220, 220)
		end)
		
		pencilbutton.MouseLeave:Connect(function()
			pencil.ImageColor3 = Color3.fromRGB(140, 140, 140)
		end)
		
		window.MouseEnter:Connect(function()
			pencilbutton.Visible = not vape.EditGUI
		end)
		
		window.MouseLeave:Connect(function()
			pencilbutton.Visible = false
		end)
		
		window.InputBegan:Connect(function(input)
			if input.Position.Y < window.AbsolutePosition.Y + 41 and input.UserInputType == Enum.UserInputType.MouseButton2 then
				component:Expand()
			end
		end)
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
			if component.Expanded then
				window.Size = UDim2.fromOffset(220, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
			end
		end)
		
		component.Button = vape.Categories.Main:CreateGUIButton({
			Name = props.Name,
			Icon = props.Icon,
			Size = props.Size,
			Window = window
		})
		
		component.Object = window
		vape.Categories[props.Name] = component
		
		return component
	end,
	CategoryList = function(props, children, api)
		local component = {
			Expanded = false,
			List = {},
			ListEnabled = {},
			Objects = {},
			Options = {},
			Type = 'CategoryList'
		}
		props.Color = props.Color or Color3.fromRGB(5, 134, 105)
		
		local window = Instance.new('TextButton')
		window.AutoButtonColor = false
		window.BackgroundColor3 = uipallet.Main
		window.Name = props.Name..'CategoryList'
		window.Position = UDim2.fromOffset(240, 46)
		window.Size = UDim2.fromOffset(220, 45)
		window.Text = ''
		window.Visible = false
		window.Parent = clickgui
		addBlur(window)
		addCorner(window)
		addDragHandler(window)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = props.Icon
		icon.ImageColor3 = uipallet.Text
		icon.Name = 'Icon'
		icon.Size = props.Size
		icon.Position = props.Position or UDim2.fromOffset(12, (props.Size.X.Offset > 20 and 13 or 12))
		icon.Parent = window
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Name = 'Title'
		title.Size = UDim2.new(1, -(props.Size.X.Offset > 20 and 44 or 36), 0, 20)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 12)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = window
		local arrowbutton = Instance.new('TextButton')
		arrowbutton.BackgroundTransparency = 1
		arrowbutton.Name = 'Arrow'
		arrowbutton.Position = UDim2.new(1, -40, 0, 0)
		arrowbutton.Size = UDim2.fromOffset(40, 40)
		arrowbutton.Text = ''
		arrowbutton.Parent = window
		local arrow = Instance.new('ImageLabel')
		arrow.Name = 'Arrow'
		arrow.Size = UDim2.fromOffset(9, 4)
		arrow.Position = UDim2.fromOffset(15, 20)
		arrow.BackgroundTransparency = 1
		arrow.Image = getvapeasset('newvape/assets/new/downexpand.png')
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		arrow.Rotation = 180
		arrow.Parent = arrowbutton
		local children = Instance.new('ScrollingFrame')
		children.Name = 'Children'
		children.Size = UDim2.new(1, 0, 1, -45)
		children.Position = UDim2.fromOffset(0, 45)
		children.BackgroundTransparency = 1
		children.BorderSizePixel = 0
		children.Visible = false
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.CanvasSize = UDim2.new()
		children.Parent = window
		local childrentwo = Instance.new('Frame')
		childrentwo.BackgroundTransparency = 1
		childrentwo.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		childrentwo.Visible = false
		childrentwo.Parent = children
		local settings = Instance.new('ImageButton')
		settings.AutoButtonColor = false
		settings.BackgroundTransparency = 1
		settings.Image = getvapeasset('newvape/assets/new/settings.png')
		settings.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		settings.Name = 'Settings'
		settings.Position = UDim2.new(1, -56, 0, 15)
		settings.Size = UDim2.fromOffset(14, 14)
		settings.Parent = window
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = Color3.new(1, 1, 1)
		divider.BackgroundTransparency = 0.928
		divider.BorderSizePixel = 0
		divider.Name = 'Divider'
		divider.Position = UDim2.fromOffset(0, 41)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Visible = false
		divider.Parent = window
		local stroke = Instance.new('UIStroke')
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(85, 85, 85)
		stroke.Transparency = 0.8
		stroke.Parent = window
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.Padding = UDim.new(0, 4)
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		local windowlisttwo = Instance.new('UIListLayout')
		windowlisttwo.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlisttwo.SortOrder = Enum.SortOrder.LayoutOrder
		windowlisttwo.Parent = childrentwo
		local addbkg = Instance.new('Frame')
		addbkg.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		addbkg.Position = UDim2.fromOffset(10, 45)
		addbkg.Size = UDim2.fromOffset(200, 31)
		addbkg.Parent = children
		addCorner(addbkg)
		local addbox = addbkg:Clone()
		addbox.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		addbox.Position = UDim2.fromOffset(1, 1)
		addbox.Size = UDim2.new(1, -2, 1, -2)
		addbox.Parent = addbkg
		local addvalue = Instance.new('TextBox')
		addvalue.BackgroundTransparency = 1
		addvalue.ClearTextOnFocus = false
		addvalue.FontFace = uipallet.Font
		addvalue.PlaceholderText = props.Placeholder or 'Add entry...'
		addvalue.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8)
		addvalue.Position = UDim2.fromOffset(10, 0)
		addvalue.Size = UDim2.new(1, -35, 1, 0)
		addvalue.Text = ''
		addvalue.TextColor3 = Color3.new(1, 1, 1)
		addvalue.TextSize = 13
		addvalue.TextXAlignment = Enum.TextXAlignment.Left
		addvalue.Parent = addbkg
		local addbutton = Instance.new('ImageButton')
		addbutton.BackgroundTransparency = 1
		addbutton.Image = getvapeasset('newvape/assets/new/add.png')
		addbutton.ImageColor3 = props.Color
		addbutton.ImageTransparency = 0.3
		addbutton.Position = UDim2.new(1, -26, 0, 8)
		addbutton.Size = UDim2.fromOffset(16, 16)
		addbutton.Parent = addbkg
		local cursedpadding = Instance.new('Frame')
		cursedpadding.BackgroundTransparency = 1
		cursedpadding.Size = UDim2.fromOffset()
		cursedpadding.Parent = children
		props.Function = props.Function or function() end
		
		function component:CreateProfile(value, data)
			local profile = {
				Name = value
			}
		
			profile.Bind = components.Bind({
				Module = true,
				Cover = true
			}, nil, profile)
			profile.Bind.Object.Position = UDim2.new(1, -30, 0, 7)
			profile.Bind.Triggered:Connect(function(isPressed)
				if isPressed and vape.Profile ~= value then
					vape:Save(value)
					vape:Load(true)
					self:ChangeValue()
				end
			end)
		
			if data then
				profile.Bind:Load(data)
			end
		
			table.insert(self.List, profile)
		end
		
		function component:ChangeValue(value, skipGUI)
			if value then
				if props.Profiles then
					local index, profile = self:GetValue(value)
					if index then
						if value ~= 'default' then
							profile.Bind:Destroy()
							table.remove(self.List, index)
		
							if isfile('newvape/profiles/'..value..vape.Place..'.txt') and delfile then
								delfile('newvape/profiles/'..value..vape.Place..'.txt')
							end
						end
					else
						self:CreateProfile(value)
					end
				else
					local index = table.find(self.List, value)
					if index then
						table.remove(self.List, index)
		
						index = table.find(self.ListEnabled, value)
						if index then
							table.remove(self.ListEnabled, index)
						end
					else
						table.insert(self.List, value)
						table.insert(self.ListEnabled, value)
					end
				end
			end
		
			props.Function()
			for _, obj in self.Objects do
				obj:Destroy()
			end
			table.clear(self.Objects)
			self.Selected = nil
		
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			for _, name in self.List do
				if props.Profiles then
					local obj = Instance.new('TextButton')
					obj.Name = name.Name
					obj.Size = UDim2.fromOffset(200, 32)
					obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
					obj.AutoButtonColor = false
					obj.Text = ''
					obj.Parent = children
					addCorner(obj)
					local stroke = Instance.new('UIStroke')
					stroke.Color = color.Light(uipallet.Main, 0.1)
					stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					stroke.Enabled = false
					stroke.Parent = obj
					local label = Instance.new('TextLabel')
					label.Name = 'Title'
					label.Size = UDim2.new(1, -10, 1, 0)
					label.Position = UDim2.fromOffset(10, 0)
					label.BackgroundTransparency = 1
					label.Text = name.Name
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.TextColor3 = color.Dark(uipallet.Text, 0.4)
					label.TextSize = 15
					label.FontFace = uipallet.Font
					label.Parent = obj
					local dotsbutton = Instance.new('TextButton')
					dotsbutton.BackgroundTransparency = 1
					dotsbutton.Name = 'Dots'
					dotsbutton.Position = UDim2.new(1, -25, 0, 0)
					dotsbutton.Size = UDim2.fromOffset(25, 32)
					dotsbutton.Text = ''
					dotsbutton.Parent = obj
					local dots = Instance.new('ImageLabel')
					dots.BackgroundTransparency = 1
					dots.Image = getvapeasset('newvape/assets/new/settingdots.png')
					dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
					dots.Name = 'Dots'
					dots.Position = UDim2.fromOffset(11, 9)
					dots.Size = UDim2.fromOffset(3, 16)
					dots.Parent = dotsbutton
					name.Bind:SetParent(obj)
					name.Enabled = name.Name == vape.Profile
		
					dotsbutton.MouseButton1Click:Connect(function()
						if not name.Enabled then
							component:ChangeValue(name.Name)
						end
					end)
		
					dotsbutton.MouseEnter:Connect(function()
						if not name.Enabled then
							dots.ImageColor3 = uipallet.Text
						end
					end)
		
					dotsbutton.MouseLeave:Connect(function()
						if not name.Enabled then
							dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
						end
					end)
		
		
					obj.MouseButton1Click:Connect(function()
						vape:Save(name.Name)
						vape:Load(true)
						self:ChangeValue()
					end)
		
					obj.MouseEnter:Connect(function()
						name.Bind:SetVisible(true)
					end)
		
					obj.MouseLeave:Connect(function()
						name.Bind:SetVisible(false)
					end)
		
					if name.Enabled then
						self.Selected = obj
					else
						name.Bind:SetColor(color.Dark(uipallet.Text, 0.43))
					end
		
					table.insert(self.Objects, {
						Destroy = function()
							name.Bind:SetParent(nil)
							obj:Destroy()
						end
					})
				else
					local isEnabled = table.find(self.ListEnabled, name)
					local obj = Instance.new('TextButton')
					obj.Name = name
					obj.Size = UDim2.fromOffset(200, 31)
					obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
					obj.AutoButtonColor = false
					obj.Text = ''
					obj.Parent = children
					addCorner(obj)
					local bkg = Instance.new('Frame')
					bkg.BackgroundColor3 = uipallet.Main
					bkg.Position = UDim2.fromOffset(1, 1)
					bkg.Size = UDim2.new(1, -2, 1, -2)
					bkg.Visible = false
					bkg.Parent = obj
					addCorner(bkg)
					local dot = Instance.new('Frame')
					dot.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.37)
					dot.Position = UDim2.fromOffset(10, 12)
					dot.Size = UDim2.fromOffset(10, 11)
					dot.Parent = obj
					addCorner(dot, UDim.new(1, 0))
					local dotin = dot:Clone()
					dotin.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.02)
					dotin.Position = UDim2.fromOffset(1, 1)
					dotin.Size = UDim2.fromOffset(8, 9)
					dotin.Parent = dot
					local label = Instance.new('TextLabel')
					label.BackgroundTransparency = 1
					label.FontFace = uipallet.Font
					label.Position = UDim2.fromOffset(30, 0)
					label.Size = UDim2.new(1, -30, 1, 0)
					label.Text = name
					label.TextColor3 = color.Dark(uipallet.Text, 0.16)
					label.TextSize = 15
					label.TextXAlignment = Enum.TextXAlignment.Left
					label.Parent = obj
					local close = Instance.new('ImageButton')
					close.AutoButtonColor = false
					close.BackgroundColor3 = Color3.new(1, 1, 1)
					close.BackgroundTransparency = 1
					close.Image = getvapeasset('newvape/assets/new/closetiny.png')
					close.ImageColor3 = color.Light(uipallet.Text, 0.2)
					close.ImageTransparency = 0.5
					close.Position = UDim2.new(1, -27, 0, 8)
					close.Size = UDim2.fromOffset(18, 17)
					close.Parent = obj
					addCorner(close, UDim.new(1, 0))
		
					close.MouseEnter:Connect(function()
						close.ImageTransparency = 0.3
						tween:Tween(close, uipallet.Tween, {
							BackgroundTransparency = 0.6
						})
					end)
		
					close.MouseLeave:Connect(function()
						close.ImageTransparency = 0.5
						tween:Tween(close, uipallet.Tween, {
							BackgroundTransparency = 1
						})
					end)
		
					close.MouseButton1Click:Connect(function()
						component:ChangeValue(name)
					end)
		
					obj.MouseEnter:Connect(function()
						bkg.Visible = true
					end)
		
					obj.MouseLeave:Connect(function()
						bkg.Visible = false
					end)
		
					obj.MouseButton1Click:Connect(function()
						local index = table.find(self.ListEnabled, name)
						if index then
							table.remove(self.ListEnabled, index)
							dot.BackgroundColor3 = color.Light(uipallet.Main, 0.37)
							dotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
						else
							table.insert(self.ListEnabled, name)
							dot.BackgroundColor3 = props.Color
							dotin.BackgroundColor3 = props.Color
						end
		
						props.Function()
					end)
		
					table.insert(self.Objects, obj)
				end
			end
		
			if not skipGUI then
				vape:UpdateGUI()
			end
		end
		
		function component:Color(hue, sat, val, isRainbow)
			for _, component in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow)
				end
			end
		
			addbutton.ImageColor3 = isRainbow and Color3.fromHSV(vape:Color(hue % 1)) or Color3.fromHSV(hue, sat, val)
		
			if self.Selected then
				self.Selected.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color(hue % 1)) or Color3.fromHSV(hue, sat, val)
				self.Selected.Title.TextColor3 = vape.GUIColor.Rainbow and Color3.new(0.19, 0.19, 0.19) or vape:TextColor(hue, sat, val)
				self.Selected.Dots.Dots.ImageColor3 = self.Selected.Title.TextColor3
				self.Selected.Bind.Icon.ImageColor3 = self.Selected.Title.TextColor3
				self.Selected.Bind.TextLabel.TextColor3 = self.Selected.Title.TextColor3
			end
		end
		
		function component:Expand()
			self.Expanded = not self.Expanded
			children.Visible = self.Expanded
			arrow.Rotation = self.Expanded and 0 or 180
			window.Size = UDim2.fromOffset(220, self.Expanded and math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611) or 45)
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
		end
		
		function component:GetValue(name)
			for index, profile in self.List do
				if profile.Name == name then
					return index, profile
				end
			end
		end
		
		function component:Load(data)
			vape:LoadOptions(self, data.Options)
		
			if data.Enabled then
				self.Button:Toggle()
			end
		
			if data.Expanded then
				self:Expand()
			end
		
			if props.Profiles then
				for _, profile in data.List do
					self:CreateProfile(profile.Name, profile.Bind)
				end
		
				self:ChangeValue(nil, true)
			else
				if data.List and (#self.List > 0 or #data.List > 0) then
					self.List = data.List or {}
					self.ListEnabled = data.ListEnabled or {}
					self:ChangeValue(nil, true)
				end
			end
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Button.Enabled,
				Expanded = self.Expanded,
				List = self.List,
				ListEnabled = self.ListEnabled,
				Options = vape:SaveOptions(self),
				Position = {
					X = window.Position.X.Offset,
					Y = window.Position.Y.Offset
				}
			}
		
			if props.Profiles then
				local newList = {}
		
				for _, profile in self.List do
					local entry = {
						Name = profile.Name
					}
		
					profile.Bind:Save(entry)
					table.insert(newList, entry)
				end
		
				data[props.Name].List = newList
			end
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, childrentwo, component)
			end
		end
		
		addbutton.MouseEnter:Connect(function()
			addbutton.ImageTransparency = 0
		end)
		
		addbutton.MouseLeave:Connect(function()
			addbutton.ImageTransparency = 0.3
		end)
		
		addbutton.MouseButton1Click:Connect(function()
			if not table.find(component.List, addvalue.Text) then
				component:ChangeValue(addvalue.Text)
				addvalue.Text = ''
			end
		end)
		
		arrowbutton.MouseEnter:Connect(function()
			arrow.ImageColor3 = Color3.fromRGB(220, 220, 220)
		end)
		
		arrowbutton.MouseLeave:Connect(function()
			arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		end)
		
		arrowbutton.MouseButton1Click:Connect(function()
			component:Expand()
		end)
		
		arrowbutton.MouseButton2Click:Connect(function()
			component:Expand()
		end)
		
		addvalue.FocusLost:Connect(function(enter)
			if enter and not table.find(component.List, addvalue.Text) then
				component:ChangeValue(addvalue.Text)
				addvalue.Text = ''
			end
		end)
		
		addvalue.MouseEnter:Connect(function()
			tween:Tween(addbkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.14)
			})
		end)
		
		addvalue.MouseLeave:Connect(function()
			tween:Tween(addbkg, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			})
		end)
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
		end)
		
		settings.MouseEnter:Connect(function()
			settings.ImageColor3 = uipallet.Text
		end)
		
		settings.MouseLeave:Connect(function()
			settings.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		settings.MouseButton1Click:Connect(function()
			childrentwo.Visible = not childrentwo.Visible
		end)
		
		window.InputBegan:Connect(function(input)
			if input.Position.Y < window.AbsolutePosition.Y + 41 and input.UserInputType == Enum.UserInputType.MouseButton2 then
				component:Expand()
			end
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
			if component.Expanded then
				window.Size = UDim2.fromOffset(220, math.min(51 + windowlist.AbsoluteContentSize.Y / scale.Scale, 611))
			end
		end)
		
		windowlisttwo:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			childrentwo.Size = UDim2.fromOffset(220, windowlisttwo.AbsoluteContentSize.Y / scale.Scale)
		end)
		
		component.Button = vape.Categories.Main:CreateGUIButton({
			Name = props.Name,
			Icon = props.CategoryIcon,
			Size = props.CategorySize,
			Window = window
		})
		
		component.Object = window
		vape.Categories[props.Name] = component
		
		return component
	end,
	ColorSlider = function(props, children, api)
		local component = {
			Type = 'ColorSlider',
			Hue = props.DefaultHue or 0.44,
			Sat = props.DefaultSat or 1,
			Value = props.DefaultValue or 1,
			Opacity = props.DefaultOpacity or 1,
			Rainbow = false,
			Index = 0
		}
		
		local function createExtraSlider(name, gradientColor)
			local colorslidercustom = Instance.new('TextButton')
			colorslidercustom.AutoButtonColor = false
			colorslidercustom.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
			colorslidercustom.BorderSizePixel = 0
			colorslidercustom.Size = UDim2.new(1, 0, 0, 50)
			colorslidercustom.Text = ''
			colorslidercustom.Visible = false
			colorslidercustom.Parent = children
			local title = Instance.new('TextLabel')
			title.BackgroundTransparency = 1
			title.FontFace = uipallet.Font
			title.Position = UDim2.fromOffset(10, 2)
			title.Size = UDim2.fromOffset(60, 30)
			title.Text = name
			title.TextColor3 = color.Dark(uipallet.Text, 0.16)
			title.TextSize = 11
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = colorslidercustom
			local holder = Instance.new('Frame')
			holder.BackgroundColor3 = Color3.new(1, 1, 1)
			holder.BorderSizePixel = 0
			holder.Name = 'Holder'
			holder.Position = UDim2.fromOffset(10, 37)
			holder.Size = UDim2.new(1, -20, 0, 2)
			holder.Parent = colorslidercustom
			local uigradient = Instance.new('UIGradient')
			uigradient.Color = gradientColor
			uigradient.Parent = holder
			local fill = Instance.new('Frame')
			fill.BackgroundTransparency = 1
			fill.Name = 'Fill'
			fill.Size = UDim2.fromScale(math.clamp(name == 'Saturation' and component.Sat or name == 'Vibrance' and component.Value or component.Opacity, 0.04, 0.96), 1)
			fill.Parent = holder
			local knobholder = Instance.new('Frame')
			knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
			knobholder.BackgroundColor3 = colorslidercustom.BackgroundColor3
			knobholder.BorderSizePixel = 0
			knobholder.Position = UDim2.fromScale(1, 0.5)
			knobholder.Size = UDim2.fromOffset(24, 4)
			knobholder.Parent = fill
			local knob = Instance.new('Frame')
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.BackgroundColor3 = uipallet.Text
			knob.Position = UDim2.fromScale(0.5, 0.5)
			knob.Size = UDim2.fromOffset(14, 14)
			knob.Parent = knobholder
			addCorner(knob, UDim.new(1, 0))
		
			colorslidercustom.InputBegan:Connect(function(input)
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
					and (input.Position.Y - colorslidercustom.AbsolutePosition.Y) > (20 * scale.Scale)
				then
					local releaseConnection
					local moveConnection = inputService.InputChanged:Connect(function(newInput)
						if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
							local newValue = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
							component:SetValue(nil, name == 'Saturation' and newValue or nil, name == 'Vibrance' and newValue or nil, name == 'Opacity' and newValue or nil)
						end
					end)
		
					releaseConnection = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							moveConnection:Disconnect()
							releaseConnection:Disconnect()
						end
					end)
				end
			end)
		
			colorslidercustom.MouseEnter:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(16, 16)
				})
			end)
		
			colorslidercustom.MouseLeave:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(14, 14)
				})
			end)
		
			return colorslidercustom
		end
		
		local colorslider = Instance.new('TextButton')
		colorslider.AutoButtonColor = false
		colorslider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		colorslider.BorderSizePixel = 0
		colorslider.Size = UDim2.new(1, 0, 0, 50)
		colorslider.Text = ''
		colorslider.Visible = props.Visible == nil or props.Visible
		colorslider.Parent = children
		component.Object = colorslider
		addTooltip(colorslider, props.Tooltip)
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(10, 2)
		title.Size = UDim2.fromOffset(60, 30)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = colorslider
		local custombox = Instance.new('TextBox')
		custombox.BackgroundTransparency = 1
		custombox.FontFace = uipallet.Font
		custombox.Position = UDim2.new(1, -69, 0, 9)
		custombox.Size = UDim2.fromOffset(60, 15)
		custombox.Text = ''
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		custombox.TextSize = 11
		custombox.TextXAlignment = Enum.TextXAlignment.Right
		custombox.Visible = false
		custombox.Parent = colorslider
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = Color3.new(1, 1, 1)
		holder.BorderSizePixel = 0
		holder.Position = UDim2.fromOffset(10, 39)
		holder.Size = UDim2.new(1, -20, 0, 2)
		holder.Parent = colorslider
		local rainbowTable = {}
		for i = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
		end
		local uigradient = Instance.new('UIGradient')
		uigradient.Color = ColorSequence.new(rainbowTable)
		uigradient.Parent = holder
		local fill = Instance.new('Frame')
		fill.BackgroundTransparency = 1
		fill.Size = UDim2.fromScale(math.clamp(component.Hue, 0.04, 0.96), 1)
		fill.Parent = holder
		local knobholder = Instance.new('Frame')
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
		knobholder.BackgroundColor3 = colorslider.BackgroundColor3
		knobholder.BorderSizePixel = 0
		knobholder.Position = UDim2.fromScale(1, 0.5)
		knobholder.Size = UDim2.fromOffset(24, 4)
		knobholder.Parent = fill
		local knob = Instance.new('Frame')
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = uipallet.Text
		knob.Position = UDim2.fromScale(0.5, 0.5)
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Parent = knobholder
		addCorner(knob, UDim.new(1, 0))
		local preview = Instance.new('ImageButton')
		preview.BackgroundTransparency = 1
		preview.Image = getvapeasset('newvape/assets/new/colorpreview.png')
		preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
		preview.ImageTransparency = 1 - component.Opacity
		preview.Position = UDim2.new(1, -22, 0, 10)
		preview.Size = UDim2.fromOffset(12, 12)
		preview.Parent = colorslider
		local expand = Instance.new('TextButton')
		expand.BackgroundTransparency = 1
		expand.Position = UDim2.fromOffset(getfontbounds(title.Text, title.TextSize, title.FontFace).X + 11, 7)
		expand.Size = UDim2.fromOffset(17, 13)
		expand.Text = ''
		expand.Parent = colorslider
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/downexpandslider.png')
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		icon.Position = UDim2.fromOffset(4, 4)
		icon.Size = UDim2.fromOffset(10, 5)
		icon.Parent = expand
		local rainbow = Instance.new('TextButton')
		rainbow.BackgroundTransparency = 1
		rainbow.Position = UDim2.new(1, -42, 0, 10)
		rainbow.Size = UDim2.fromOffset(12, 12)
		rainbow.Text = ''
		rainbow.Parent = colorslider
		local ring1 = Instance.new('ImageLabel')
		ring1.BackgroundTransparency = 1
		ring1.Image = getvapeasset('newvape/assets/new/rainbow_1.png')
		ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
		ring1.Size = UDim2.fromOffset(12, 12)
		ring1.Parent = rainbow
		local ring2 = Instance.fromExisting(ring1)
		ring2.Image = getvapeasset('newvape/assets/new/rainbow_2.png')
		ring2.Parent = rainbow
		local ring3 = Instance.fromExisting(ring1)
		ring3.Image = getvapeasset('newvape/assets/new/rainbow_3.png')
		ring3.Parent = rainbow
		local ring4 = Instance.fromExisting(ring1)
		ring4.Image = getvapeasset('newvape/assets/new/rainbow_4.png')
		ring4.Parent = rainbow
		props.Function = props.Function or function() end
		
		local satSlider = createExtraSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, component.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, 1, component.Value))
		}))
		
		local vibSlider = createExtraSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, 1))
		}))
		
		local opSlider = createExtraSlider('Opacity', ColorSequence.new({
			ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, component.Value))
		}))
		
		function component:Load(data)
			if data.Rainbow ~= self.Rainbow then
				self:Toggle()
			end
		
			if self.Hue ~= data.Hue or self.Sat ~= data.Sat or self.Value ~= data.Value or self.Opacity ~= data.Opacity then
				self:SetValue(data.Hue, data.Sat, data.Value, data.Opacity)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Hue = self.Hue,
				Sat = self.Sat,
				Value = self.Value,
				Opacity = self.Opacity,
				Rainbow = self.Rainbow
			}
		end
		
		function component:SetValue(h, s, v, o)
			self.Hue = h or self.Hue
			self.Sat = s or self.Sat
			self.Value = v or self.Value
			self.Opacity = o or self.Opacity
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
			preview.ImageTransparency = 1 - self.Opacity
		
			satSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			})
		
			vibSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			})
		
			opSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color.Dark(uipallet.Main, 0.02)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, self.Value))
			})
		
			if self.Rainbow then
				fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
			else
				tween:Tween(fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
				})
			end
		
			if s then
				tween:Tween(satSlider.Holder.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
				})
			end
		
			if v then
				tween:Tween(vibSlider.Holder.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
				})
			end
		
			if o then
				tween:Tween(opSlider.Holder.Fill, uipallet.Tween, {
					Size = UDim2.fromScale(math.clamp(self.Opacity, 0.04, 0.96), 1)
				})
			end
		
			props.Function(self.Hue, self.Sat, self.Value, self.Opacity)
		end
		
		function component:Toggle()
			self.Rainbow = not self.Rainbow
		
			if self.Rainbow then
				table.insert(vape.RainbowSliders, self)
		
				ring1.ImageColor3 = Color3.fromRGB(5, 127, 100)
				task.delay(0.1, function()
					if not self.Rainbow then return end
					ring2.ImageColor3 = Color3.fromRGB(228, 125, 43)
					task.delay(0.1, function()
						if not self.Rainbow then return end
						ring3.ImageColor3 = Color3.fromRGB(225, 46, 52)
					end)
				end)
			else
				local index = table.find(vape.RainbowSliders, self)
				if index then
					table.remove(vape.RainbowSliders, index)
				end
		
				ring3.ImageColor3 = color.Light(uipallet.Main, 0.37)
				task.delay(0.1, function()
					if self.Rainbow then return end
					ring2.ImageColor3 = color.Light(uipallet.Main, 0.37)
					task.delay(0.1, function()
						if self.Rainbow then return end
						ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
					end)
				end)
			end
		end
		
		preview.MouseButton1Click:Connect(function()
			preview.Visible = false
			custombox.Visible = true
			custombox:CaptureFocus()
		
			local text = Color3.fromHSV(component.Hue, component.Sat, component.Value)
			custombox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255)
		end)
		
		local doubleClick = os.clock()
		colorslider.InputBegan:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - colorslider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local releaseConnection
				local moveConnection = inputService.InputChanged:Connect(function(newInput)
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						component:SetValue(math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1))
					end
				end)
		
				releaseConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect()
						releaseConnection:Disconnect()
					end
				end)
		
				if doubleClick > os.clock() then
					component:Toggle()
				else
					component:SetValue(math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1))
				end
		
				doubleClick = os.clock() + 0.3
			end
		end)
		
		colorslider.MouseEnter:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(16, 16)
			})
		end)
		
		colorslider.MouseLeave:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(14, 14)
			})
		end)
		
		colorslider:GetPropertyChangedSignal('Visible'):Connect(function()
			satSlider.Visible = icon.Rotation == 180 and colorslider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
		end)
		
		expand.MouseEnter:Connect(function()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
		end)
		
		expand.MouseLeave:Connect(function()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		end)
		
		expand.MouseButton1Click:Connect(function()
			satSlider.Visible = not satSlider.Visible
			vibSlider.Visible = satSlider.Visible
			opSlider.Visible = satSlider.Visible
			icon.Rotation = satSlider.Visible and 180 or 0
		end)
		
		rainbow.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		custombox.FocusLost:Connect(function(enter)
			preview.Visible = true
			custombox.Visible = false
		
			if enter then
				local success, parsed = pcall(function()
					local commas = custombox.Text:split(',')
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(valuebox.Text)
				end)
		
				if success then
					if component.Rainbow then
						component:Toggle()
					end
		
					component:SetValue(parsed:ToHSV())
				end
			end
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
	Divider = function(props, children, api)
		local divider = Instance.new('Frame')
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		divider.BorderSizePixel = 0
		divider.Parent = children
		
		if props and props.Text then
			local label = Instance.new('TextLabel')
			label.Size = UDim2.fromOffset(218, 27)
			label.BackgroundTransparency = 1
			label.Text = '          '..props.Text:upper()
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = color.Dark(uipallet.Text, 0.43)
			label.TextSize = 9
			label.FontFace = uipallet.Font
			label.Parent = children
			divider.BackgroundTransparency = 1
			--divider.Position = UDim2.fromOffset(0, 26)
			divider.Parent = label
		end
	end,
	Dropdown = function(props, children, api)
		local component = {
			Index = 0,
			Type = 'Dropdown',
			Value = props.List[1] or 'None'
		}
		
		local dropdown = Instance.new('TextButton')
		dropdown.AutoButtonColor = false
		dropdown.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		dropdown.BorderSizePixel = 0
		dropdown.Size = UDim2.new(1, 0, 0, 40)
		dropdown.Text = ''
		dropdown.Visible = props.Visible == nil or props.Visible
		dropdown.Parent = children
		component.Object = dropdown
		addTooltip(dropdown, props.Tooltip or props.Name)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		holder.Position = UDim2.fromOffset(10, 4)
		holder.Size = UDim2.new(1, -20, 1, -11)
		holder.Parent = dropdown
		addCorner(holder, UDim.new(0, 6))
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = uipallet.Main
		button.Position = UDim2.fromOffset(1, 1)
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Text = ''
		button.Parent = holder
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Size = UDim2.new(1, 0, 0, 29)
		title.Text = '         '..props.Name..' - '..component.Value
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 13
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = button
		addCorner(button, UDim.new(0, 6))
		local arrow = Instance.new('ImageLabel')
		arrow.BackgroundTransparency = 1
		arrow.Image = getvapeasset('newvape/assets/new/expandarrow.png')
		arrow.ImageColor3 = Color3.fromRGB(140, 140, 140)
		arrow.Position = UDim2.new(1, -17, 0, 11)
		arrow.Rotation = 90
		arrow.Size = UDim2.fromOffset(4, 8)
		arrow.Parent = button
		props.Function = props.Function or function() end
		local dropdownchildren
		
		function component:Change(list)
			props.List = list or {}
			if not table.find(props.List, self.Value) then
				self:SetValue(self.Value)
			end
		end
		
		function component:Load(data)
			if self.Value ~= data.Value then
				self:SetValue(data.Value)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Value = self.Value
			}
		end
		
		function component:SetValue(value, isClick)
			self.Value = table.find(props.List, value) and value or props.List[1] or 'None'
			title.Text = '         '..props.Name..' - '..self.Value
		
			if dropdownchildren then
				arrow.Rotation = 90
				dropdownchildren:Destroy()
				dropdownchildren = nil
				dropdown.Size = UDim2.new(1, 0, 0, 40)
			end
		
			props.Function(self.Value, isClick)
		end
		
		button.MouseButton1Click:Connect(function()
			if not dropdownchildren then
				arrow.Rotation = 270
				dropdown.Size = UDim2.new(1, 0, 0, 43 + (#props.List - 1) * 26)
				dropdownchildren = Instance.new('Frame')
				dropdownchildren.BackgroundTransparency = 1
				dropdownchildren.Position = UDim2.fromOffset(0, 27)
				dropdownchildren.Size = UDim2.new(1, 0, 0, (#props.List - 1) * 26)
				dropdownchildren.Parent = button
		
				local index = 0
				for _, v in props.List do
					if v == component.Value then continue end
					local entry = Instance.new('TextButton')
					entry.AutoButtonColor = false
					entry.BackgroundColor3 = uipallet.Main
					entry.BorderSizePixel = 0
					entry.FontFace = uipallet.Font
					entry.Position = UDim2.fromOffset(0, index * 26)
					entry.Size = UDim2.new(1, 0, 0, 26)
					entry.Text = '         '..v
					entry.TextColor3 = color.Dark(uipallet.Text, 0.16)
					entry.TextSize = 13
					entry.TextTruncate = Enum.TextTruncate.AtEnd
					entry.TextXAlignment = Enum.TextXAlignment.Left
					entry.Parent = dropdownchildren
		
					entry.MouseEnter:Connect(function()
						entry.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
						entry.TextColor3 = uipallet.Text
					end)
		
					entry.MouseLeave:Connect(function()
						entry.BackgroundColor3 = uipallet.Main
						entry.TextColor3 = color.Dark(uipallet.Text, 0.16)
					end)
		
					entry.MouseButton1Click:Connect(function()
						component:SetValue(v, true)
					end)
		
					index += 1
				end
			else
				component:SetValue(component.Value, true)
			end
		end)
		
		dropdown.MouseEnter:Connect(function()
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.0875)
			})
		end)
		
		dropdown.MouseLeave:Connect(function()
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.034)
			})
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
	Font = function(props, children, api)
		local fonts = {
			props.Default,
			'Custom'
		}
		
		for _, v in Enum.Font:GetEnumItems() do
			if not table.find(fonts, v.Name) then
				table.insert(fonts, v.Name)
			end
		end
		
		local component = {
			Value = Font.fromEnum(Enum.Font[fonts[1]])
		}
		local fontdropdown
		local fontbox
		props.Function = props.Function or function() end
		
		fontdropdown = components.Dropdown({
			Name = props.Name,
			List = fonts,
			Function = function(val)
				fontbox.Object.Visible = val == 'Custom' and fontdropdown.Object.Visible
				if val ~= 'Custom' then
					component.Value = Font.fromEnum(Enum.Font[val])
					props.Function(component.Value)
				else
					pcall(function()
						component.Value = Font.fromId(tonumber(fontbox.Value))
					end)
		
					props.Function(component.Value)
				end
			end,
			Darker = props.Darker,
			Visible = props.Visible
		}, children, api)
		component.Object = fontdropdown.Object
		
		fontbox = components.TextBox({
			Name = props.Name..' Asset',
			Placeholder = 'font (rbxasset)',
			Function = function()
				if fontdropdown.Value == 'Custom' then
					pcall(function()
						component.Value = Font.fromId(tonumber(fontbox.Value))
					end)
		
					props.Function(component.Value)
				end
			end,
			Visible = false,
			Darker = true
		}, children, api)
		
		fontdropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function()
			fontbox.Object.Visible = fontdropdown.Object.Visible and fontdropdown.Value == 'Custom'
		end)
		
		return component
	end,
	GUI = function(props, children, api)
		local component = {
			Buttons = {},
			Type = 'MainWindow'
		}
		
		local window = Instance.new('TextButton')
		window.AutoButtonColor = false
		window.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		window.Name = 'GUICategory'
		window.Position = UDim2.fromOffset(6, 60)
		window.Text = ''
		window.Parent = clickgui
		component.Object = window
		addBlur(window)
		addCorner(window)
		addDragHandler(window)
		local logo = Instance.new('ImageLabel')
		logo.BackgroundTransparency = 1
		logo.Image = getvapeasset('newvape/assets/new/vapelogomini.png')
		logo.ImageColor3 = select(3, uipallet.Main:ToHSV()) > 0.5 and uipallet.Text or Color3.new(1, 1, 1)
		logo.Name = 'VapeLogo'
		logo.Position = UDim2.fromOffset(12, 11)
		logo.Size = UDim2.fromOffset(55, 16)
		logo.Parent = window
		local v4logo = Instance.new('ImageLabel')
		v4logo.BackgroundTransparency = 1
		v4logo.Image = getvapeasset('newvape/assets/new/v4mini.png')
		v4logo.Name = 'V4Logo'
		v4logo.Position = UDim2.new(1, -1, 0, 0)
		v4logo.Size = UDim2.fromOffset(23, 16)
		v4logo.Parent = logo
		local children = Instance.new('Frame')
		children.BackgroundTransparency = 1
		children.Position = UDim2.fromOffset(0, 37)
		children.Size = UDim2.new(1, 0, 1, -33)
		children.Parent = window
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		local settingsbutton = Instance.new('TextButton')
		settingsbutton.BackgroundTransparency = 1
		settingsbutton.Position = UDim2.new(1, -40, 0, 0)
		settingsbutton.Size = UDim2.fromOffset(40, 40)
		settingsbutton.Text = ''
		settingsbutton.Parent = window
		addTooltip(settingsbutton, 'Open settings')
		local settingsicon = Instance.new('ImageLabel')
		settingsicon.BackgroundTransparency = 1
		settingsicon.Image = getvapeasset('newvape/assets/new/settings.png')
		settingsicon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		settingsicon.Position = UDim2.fromOffset(15, 12)
		settingsicon.Size = UDim2.fromOffset(14, 14)
		settingsicon.Parent = settingsbutton
		local discord = Instance.new('ImageButton')
		discord.BackgroundTransparency = 1
		discord.Image = getvapeasset('newvape/assets/new/discord.png')
		discord.Position = UDim2.new(1, -56, 0, 11)
		discord.Size = UDim2.fromOffset(16, 16)
		discord.Parent = window
		addTooltip(discord, 'Join discord')
		local stroke = Instance.new('UIStroke')
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(85, 85, 85)
		stroke.Transparency = 0.8
		stroke.Parent = window
		local settingspane = components.SettingsPane({
			Name = 'Settings',
			Main = true
		}, window, component)
		component.Settings = settingspane
		
		function component:Color(hue, sat, val, isRainbow)
			v4logo.ImageColor3 = Color3.fromHSV(hue, sat, val)
		
			for _, button in self.Buttons do
				if button.Enabled then
					button.Object.TextColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (button.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
		
					if button.Icon then
						button.Icon.ImageColor3 = button.Object.TextColor3
					end
				end
			end
		end
		
		function component:Load(data)
			for name, paneData in data.Settings do
				local pane = vape.Settings[name]
				if pane then
					pane:Load(paneData)
				end
			end
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y)
			end
		end
		
		function component:Save(data)
			data.Main = {
				Position = {
					X = window.Position.X.Offset,
					Y = window.Position.Y.Offset
				},
				Settings = {}
			}
		
			for name, pane in vape.Settings do
				pane:Save(data.Main.Settings)
			end
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, children, component)
			end
		end
		
		discord.MouseButton1Click:Connect(function()
			task.spawn(function()
				local body = httpService:JSONEncode({
					nonce = httpService:GenerateGUID(false),
					args = {
						invite = {code = 'VZEQJxMSnG'},
						code = 'VZEQJxMSnG'
					},
					cmd = 'INVITE_BROWSER'
				})
		
				for i = 1, 14 do
					task.spawn(function()
						pcall(function()
							request({
								Method = 'POST',
								Url = 'http://127.0.0.1:64'..(53 + i)..'/rpc?v=1',
								Headers = {
									['Content-Type'] = 'application/json',
									Origin = 'https://discord.com'
								},
								Body = body
							})
						end)
					end)
				end
			end)
		
			task.spawn(function()
				tooltip.Text = 'Copied!'
				setclipboard('https://discord.gg/VZEQJxMSnG')
			end)
		end)
		
		settingsbutton.MouseEnter:Connect(function()
			settingsicon.ImageColor3 = uipallet.Text
		end)
		
		settingsbutton.MouseLeave:Connect(function()
			settingsicon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		settingsbutton.MouseButton1Click:Connect(function()
			settingspane.Object.Visible = true
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			window.Size = UDim2.fromOffset(220, 42 + windowlist.AbsoluteContentSize.Y / scale.Scale)
			for _, button in component.Buttons do
				if button.Icon then
					button.Object.Text = string.rep(' ', 39 * scale.Scale)..button.Name
				end
			end
		end)
		
		vape.Categories.Main = component
		
		return component
	end,
	GUIButton = function(props, children, api)
		local component = {
			Enabled = false,
			Index = getTableSize(api.Buttons),
			Name = props.Name
		}
		
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = uipallet.Main
		button.BorderSizePixel = 0
		button.FontFace = uipallet.Font
		button.Name = props.Name
		button.Size = UDim2.fromOffset(220, 40)
		button.Text = (props.Icon and string.rep(' ', 39) or props.Window and string.rep(' ', 17) or string.rep(' ', 10))..props.Name
		button.TextColor3 = color.Dark(uipallet.Text, 0.16)
		button.TextSize = 14
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = children
		component.Object = button
		
		local icon
		if props.Icon then
			icon = Instance.new('ImageLabel')
			icon.BackgroundTransparency = 1
			icon.Image = props.Icon
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
			icon.Position = UDim2.fromOffset(16, 13)
			icon.Size = props.Size
			icon.Parent = button
			component.Icon = icon
		end
		
		if props.Name == 'Profiles' then
			local label = Instance.new('TextLabel')
			label.AnchorPoint = Vector2.new(1, 0)
			label.BackgroundColor3 = color.Light(uipallet.Main, 0.04)
			label.FontFace = uipallet.Font
			label.Position = UDim2.new(1, -36, 0, 8)
			label.Size = UDim2.fromOffset(53, 24)
			label.Text = 'default'
			label.TextColor3 = color.Dark(uipallet.Text, 0.29)
			label.TextSize = 12
			label.Parent = button
			addCorner(label)
			vape.ProfileLabel = label
		end
		
		local arrow = Instance.new('ImageLabel')
		arrow.BackgroundTransparency = 1
		arrow.Image = getvapeasset('newvape/assets/new/expandarrow.png')
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.37)
		arrow.Name = 'Arrow'
		arrow.Position = UDim2.new(1, -20, 0, 16)
		arrow.Size = UDim2.fromOffset(4, 8)
		arrow.Parent = button
		
		function component:Destroy()
			button:Destroy()
			button:ClearAllChildren()
		end
		
		function component:Toggle()
			if props.Window then
				self.Enabled = not self.Enabled
				tween:Tween(arrow, uipallet.Tween, {
					Position = UDim2.new(1, self.Enabled and -14 or -20, 0, 16)
				})
		
				button.TextColor3 = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or uipallet.Text
				if icon then
					icon.ImageColor3 = button.TextColor3
				end
		
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
				props.Window.Visible = self.Enabled
			else
				props.Function()
			end
		end
		
		button.MouseEnter:Connect(function()
			if not component.Enabled then
				button.TextColor3 = uipallet.Text
				if buttonicon then
					buttonicon.ImageColor3 = uipallet.Text
				end
		
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
		end)
		
		button.MouseLeave:Connect(function()
			if not component.Enabled then
				button.TextColor3 = color.Dark(uipallet.Text, 0.16)
				if buttonicon then
					buttonicon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
				end
		
				button.BackgroundColor3 = uipallet.Main
			end
		end)
		
		button.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		api.Buttons[props.Name] = component
		
		return component
	end,
	GUISlider = function(props, children, api)
		local component = {
			CustomColor = false,
			Hue = 0.46,
			Notch = 4,
			Rainbow = false,
			Sat = 0.96,
			Type = 'GUISlider',
			Value = 0.52
		}
		local colors = {
			Color3.fromRGB(250, 50, 56),
			Color3.fromRGB(242, 99, 33),
			Color3.fromRGB(252, 179, 22),
			Color3.fromRGB(5, 133, 104),
			Color3.fromRGB(47, 122, 229),
			Color3.fromRGB(126, 84, 217),
			Color3.fromRGB(232, 96, 152)
		}
		local colorPositions = {
			4,
			33,
			62,
			90,
			119,
			148,
			177
		}
		
		local function createSlider(name, gradientColor)
			local slider = Instance.new('TextButton')
			slider.Name = props.Name..'Slider'..name
			slider.Size = UDim2.fromOffset(220, 50)
			slider.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
			slider.BorderSizePixel = 0
			slider.AutoButtonColor = false
			slider.Visible = false
			slider.Text = ''
			slider.Parent = children
			local title = Instance.new('TextLabel')
			title.BackgroundTransparency = 1
			title.FontFace = uipallet.Font
			title.Position = UDim2.fromOffset(10, 2)
			title.Size = UDim2.fromOffset(60, 30)
			title.Text = name
			title.TextColor3 = color.Dark(uipallet.Text, 0.16)
			title.TextSize = 11
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.Parent = slider
			local holder = Instance.new('Frame')
			holder.BackgroundColor3 = Color3.new(1, 1, 1)
			holder.BorderSizePixel = 0
			holder.Name = 'Holder'
			holder.Position = UDim2.fromOffset(10, 37)
			holder.Size = UDim2.new(1, -20, 0, 2)
			holder.Parent = slider
			local uigradient = Instance.new('UIGradient')
			uigradient.Color = gradientColor
			uigradient.Parent = holder
			local fill = Instance.new('Frame')
			fill.BackgroundTransparency = 1
			fill.Name = 'Fill'
			fill.Size = UDim2.fromScale(math.clamp(1, 0.04, 0.96), 1)
			fill.Parent = holder
			local knobholder = Instance.new('Frame')
			knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
			knobholder.BackgroundColor3 = slider.BackgroundColor3
			knobholder.BorderSizePixel = 0
			knobholder.Position = UDim2.fromScale(1, 0.5)
			knobholder.Size = UDim2.fromOffset(24, 4)
			knobholder.Parent = fill
			local knob = Instance.new('Frame')
			knob.AnchorPoint = Vector2.new(0.5, 0.5)
			knob.BackgroundColor3 = uipallet.Text
			knob.Position = UDim2.fromScale(0.5, 0.5)
			knob.Size = UDim2.fromOffset(14, 14)
			knob.Parent = knobholder
			addCorner(knob, UDim.new(1, 0))
		
			if name == 'Custom color' then
				local reset = Instance.new('TextButton')
				reset.BackgroundTransparency = 1
				reset.FontFace = uipallet.Font
				reset.Position = UDim2.new(1, -52, 0, 5)
				reset.Size = UDim2.fromOffset(45, 20)
				reset.Text = 'RESET'
				reset.TextColor3 = color.Dark(uipallet.Text, 0.16)
				reset.TextSize = 11
				reset.Parent = slider
		
				reset.MouseButton1Click:Connect(function()
					component:SetValue(nil, nil, nil, 4)
				end)
			end
		
			slider.InputBegan:Connect(function(input)
				if
					(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
					and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
				then
					local releaseConnection
					local moveConnection = inputService.InputChanged:Connect(function(newInput)
						if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
							local value = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
							component:SetValue(
								name == 'Custom color' and value or nil,
								name == 'Saturation' and value or nil,
								name == 'Vibrance' and value or nil,
								name == 'Opacity' and value or nil
							)
						end
					end)
		
					releaseConnection = input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							moveConnection:Disconnect()
							releaseConnection:Disconnect()
						end
					end)
				end
			end)
		
			slider.MouseEnter:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(16, 16)
				})
			end)
		
			slider.MouseLeave:Connect(function()
				tween:Tween(knob, uipallet.Tween, {
					Size = UDim2.fromOffset(14, 14)
				})
			end)
		
			return slider
		end
		
		local slider = Instance.new('TextButton')
		slider.AutoButtonColor = false
		slider.BackgroundTransparency = 1
		slider.Name = props.Name..'Slider'
		slider.Size = UDim2.fromOffset(220, 50)
		slider.Text = ''
		slider.Parent = children
		component.Object = slider
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Name = 'Title'
		title.Position = UDim2.fromOffset(10, 2)
		title.Size = UDim2.fromOffset(60, 30)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = slider
		local holder = Instance.new('Frame')
		holder.BackgroundTransparency = 1
		holder.BorderSizePixel = 0
		holder.Name = 'Slider'
		holder.Position = UDim2.fromOffset(10, 37)
		holder.Size = UDim2.fromOffset(200, 2)
		holder.Parent = slider
		local colorXPos = 0
		for index, colorValue in colors do
			local colorframe = Instance.new('Frame')
			colorframe.BackgroundColor3 = colorValue
			colorframe.BorderSizePixel = 0
			colorframe.Position = UDim2.fromOffset(colorXPos, 0)
			colorframe.Size = UDim2.fromOffset(27 + (((index + 1) % 2) == 0 and 1 or 0), 2)
			colorframe.Parent = holder
			colorXPos += (colorframe.Size.X.Offset + 1)
		end
		local preview = Instance.new('ImageButton')
		preview.BackgroundTransparency = 1
		preview.Image = getvapeasset('newvape/assets/new/colorpreview.png')
		preview.ImageColor3 = Color3.fromHSV(component.Hue, component.Sat, component.Value)
		preview.Position = UDim2.new(1, -22, 0, 10)
		preview.Size = UDim2.fromOffset(12, 12)
		preview.Parent = slider
		local custombox = Instance.new('TextBox')
		custombox.BackgroundTransparency = 1
		custombox.FontFace = uipallet.Font
		custombox.Position = UDim2.new(1, -69, 0, 9)
		custombox.Size = UDim2.fromOffset(60, 15)
		custombox.Text = ''
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		custombox.TextSize = 11
		custombox.TextXAlignment = Enum.TextXAlignment.Right
		custombox.Visible = false
		custombox.Parent = slider
		local expand = Instance.new('TextButton')
		expand.BackgroundTransparency = 1
		expand.Position = UDim2.new(0, getfontbounds(title.Text, title.TextSize, title.Font).X + 11, 0, 7)
		expand.Size = UDim2.fromOffset(17, 13)
		expand.Text = ''
		expand.Parent = slider
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/downexpandslider.png')
		icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		icon.Position = UDim2.fromOffset(4, 4)
		icon.Size = UDim2.fromOffset(10, 5)
		icon.Parent = expand
		local rainbow = Instance.new('TextButton')
		rainbow.BackgroundTransparency = 1
		rainbow.Position = UDim2.new(1, -42, 0, 10)
		rainbow.Size = UDim2.fromOffset(12, 12)
		rainbow.Text = ''
		rainbow.Parent = slider
		local ring1 = Instance.new('ImageLabel')
		ring1.BackgroundTransparency = 1
		ring1.Image = getvapeasset('newvape/assets/new/rainbow_1.png')
		ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
		ring1.Size = UDim2.fromOffset(12, 12)
		ring1.Parent = rainbow
		local ring2 = Instance.fromExisting(ring1)
		ring2.Image = getvapeasset('newvape/assets/new/rainbow_2.png')
		ring2.Parent = rainbow
		local ring3 = Instance.fromExisting(ring1)
		ring3.Image = getvapeasset('newvape/assets/new/rainbow_3.png')
		ring3.Parent = rainbow
		local ring4 = Instance.fromExisting(ring1)
		ring4.Image = getvapeasset('newvape/assets/new/rainbow_4.png')
		ring4.Parent = rainbow
		local knob = Instance.new('ImageLabel')
		knob.BackgroundTransparency = 1
		knob.Image = getvapeasset('newvape/assets/new/theme.png')
		knob.ImageColor3 = colors[4]
		knob.Name = 'Knob'
		knob.Position = UDim2.fromOffset(colorPositions[4] - 3, -5)
		knob.Size = UDim2.fromOffset(26, 12)
		knob.Parent = holder
		props.Function = props.Function or function() end
		local rainbowTable = {}
		for i = 0, 1, 0.1 do
			table.insert(rainbowTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
		end
		
		local colorSlider = createSlider('Custom color', ColorSequence.new(rainbowTable))
		local satSlider = createSlider('Saturation', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, component.Value)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, 1, component.Value))
		}))
		
		local vibSlider = createSlider('Vibrance', ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(component.Hue, component.Sat, 1))
		}))
		
		local normalknob = getvapeasset('newvape/assets/new/theme.png')
		local rainbowknob = getvapeasset('newvape/assets/new/customtheme.png')
		local rainbowthread
		local currentNotch
		
		function component:Load(data)
			if data.Rainbow then
				self:Toggle()
			end
		
			if self.Rainbow or data.CustomColor then
				self:SetValue(data.Hue, data.Sat, data.Value)
			else
				self:SetValue(nil, nil, nil, data.Notch)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Hue = self.Hue,
				Sat = self.Sat,
				Value = self.Value,
				Notch = self.Notch,
				CustomColor = self.CustomColor,
				Rainbow = self.Rainbow
			}
		end
		
		function component:SetValue(h, s, v, n)
			if n then
				if self.Rainbow then
					self:Toggle()
				end
		
				self.CustomColor = false
				h, s, v = colors[n]:ToHSV()
			else
				self.CustomColor = true
			end
		
			self.Hue = h or self.Hue
			self.Sat = s or self.Sat
			self.Value = v or self.Value
			self.Notch = n
			preview.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
		
			satSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, self.Value)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, 1, self.Value))
			})
		
			vibSlider.Holder.UIGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 0, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(self.Hue, self.Sat, 1))
			})
		
			local newNotch = (self.Rainbow or self.CustomColor) and 4 or n or currentNotch
			if self.Rainbow or self.CustomColor then
				knob.Image = rainbowknob
				knob.ImageColor3 = Color3.new(1, 1, 1)
		
				if newNotch ~= currentNotch then
					tween:Tween(knob, uipallet.Tween, {
						Position = UDim2.fromOffset(colorPositions[4] - 3, -5)
					})
				end
			else
				knob.Image = normalknob
				knob.ImageColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value)
		
				if newNotch ~= currentNotch then
					tween:Tween(knob, uipallet.Tween, {
						Position = UDim2.fromOffset(colorPositions[n or 4] - 3, -5)
					})
				end
			end
		
			currentNotch = newNotch
			if self.Rainbow then
				if h then
					colorSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
				end
		
				if s then
					satSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
				end
		
				if v then
					vibSlider.Holder.Fill.Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
				end
			else
				if h then
					tween:Tween(colorSlider.Holder.Fill, uipallet.Tween, {
						Size = UDim2.fromScale(math.clamp(self.Hue, 0.04, 0.96), 1)
					})
				end
		
				if s then
					tween:Tween(satSlider.Holder.Fill, uipallet.Tween, {
						Size = UDim2.fromScale(math.clamp(self.Sat, 0.04, 0.96), 1)
					})
				end
		
				if v then
					tween:Tween(vibSlider.Holder.Fill, uipallet.Tween, {
						Size = UDim2.fromScale(math.clamp(self.Value, 0.04, 0.96), 1)
					})
				end
			end
		
			props.Function(self.Hue, self.Sat, self.Value)
		end
		
		function component:Toggle()
			self.Rainbow = not self.Rainbow
			if rainbowthread then
				task.cancel(rainbowthread)
			end
		
			if self.Rainbow then
				knob.Image = rainbowknob
				table.insert(vape.RainbowSliders, self)
		
				ring1.ImageColor3 = Color3.fromRGB(5, 127, 100)
				rainbowthread = task.delay(0.1, function()
					ring2.ImageColor3 = Color3.fromRGB(228, 125, 43)
					rainbowthread = task.delay(0.1, function()
						ring3.ImageColor3 = Color3.fromRGB(225, 46, 52)
						rainbowthread = nil
					end)
				end)
			else
				self:SetValue(nil, nil, nil, 4)
				knob.Image = normalknob
				local index = table.find(vape.RainbowSliders, self)
				if index then
					table.remove(vape.RainbowSliders, index)
				end
		
				ring3.ImageColor3 = color.Light(uipallet.Main, 0.37)
				rainbowthread = task.delay(0.1, function()
					ring2.ImageColor3 = color.Light(uipallet.Main, 0.37)
					rainbowthread = task.delay(0.1, function()
						ring1.ImageColor3 = color.Light(uipallet.Main, 0.37)
						rainbowthread = nil
					end)
				end)
			end
		end
		
		expand.MouseEnter:Connect(function()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.16)
		end)
		
		expand.MouseLeave:Connect(function()
			icon.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		end)
		
		expand.MouseButton1Click:Connect(function()
			colorSlider.Visible = not colorSlider.Visible
			satSlider.Visible = colorSlider.Visible
			vibSlider.Visible = satSlider.Visible
			icon.Rotation = satSlider.Visible and 180 or 0
		end)
		
		preview.MouseButton1Click:Connect(function()
			preview.Visible = false
			custombox.Visible = true
			custombox:CaptureFocus()
			local text = Color3.fromHSV(component.Hue, component.Sat, component.Value)
			custombox.Text = math.round(text.R * 255)..', '..math.round(text.G * 255)..', '..math.round(text.B * 255)
		end)
		
		slider.InputBegan:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local releaseConnection
				local moveConnection = inputService.InputChanged:Connect(function(newInput)
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						component:SetValue(nil, nil, nil, math.clamp(math.round((newInput.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7))
					end
				end)
		
				releaseConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect()
						releaseConnection:Disconnect()
					end
				end)
		
				component:SetValue(nil, nil, nil, math.clamp(math.round((input.Position.X - holder.AbsolutePosition.X) / scale.Scale / 27), 1, 7))
			end
		end)
		
		rainbow.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		custombox.FocusLost:Connect(function(enter)
			preview.Visible = true
			custombox.Visible = false
		
			if enter then
				local success, parsed = pcall(function()
					local commas = custombox.Text:split(',')
					return tonumber(commas[1]) and Color3.fromRGB(tonumber(commas[1]), tonumber(commas[2]), tonumber(commas[3])) or Color3.fromHex(custombox.Text)
				end)
		
				if success then
					if component.Rainbow then
						component:Toggle()
					end
		
					component:SetValue(parsed:ToHSV())
				end
			end
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
	ImageToggle = function(props, children, api)
		local component = {
			Enabled = false,
			Index = getTableSize(api.Options),
			Type = 'ImageToggle'
		}
		
		local isHover = false
		local toggle = Instance.new('TextButton')
		toggle.AutoButtonColor = false
		toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		toggle.BorderSizePixel = 0
		toggle.FontFace = uipallet.Font
		toggle.Size = UDim2.new(1, 0, 0, 40)
		toggle.Text = string.rep(' ', 33 * scale.Scale)..props.Name
		toggle.TextColor3 = color.Dark(uipallet.Text, 0.16)
		toggle.TextSize = 14
		toggle.TextXAlignment = Enum.TextXAlignment.Left
		toggle.Visible = props.Visible == nil or props.Visible
		toggle.Parent = children
		component.Object = toggle
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = props.Icon
		icon.ImageColor3 = uipallet.Text
		icon.Name = 'Icon'
		icon.Position = props.Position
		icon.Size = props.Size
		icon.Parent = toggle
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		holder.Name = 'Knob'
		holder.Position = UDim2.new(1, -30, 0, 14)
		holder.Size = UDim2.fromOffset(22, 12)
		holder.Parent = toggle
		addCorner(holder, UDim.new(1, 0))
		local knob = Instance.new('Frame')
		knob.BackgroundColor3 = uipallet.Main
		knob.Position = UDim2.fromOffset(2, 2)
		knob.Size = UDim2.fromOffset(8, 8)
		knob.Parent = holder
		addCorner(knob, UDim.new(1, 0))
		props.Function = props.Function or function() end
		
		function component:Color(hue, sat, val, isRainbow)
			if self.Enabled then
				tween:Cancel(holder)
				holder.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		end
		
		function component:Toggle()
			local isRainbow = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro'
			self.Enabled = not self.Enabled
		
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and (isRainbow and Color3.fromHSV(vape:Color((vape.GUIColor.Hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)) or (isHover and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
			})
		
			tween:Tween(knob, uipallet.Tween, {
				Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			})
		
			props.Function(self.Enabled)
		end
		
		scale:GetPropertyChangedSignal('Scale'):Connect(function()
			toggle.Text = string.rep(' ', 33 * scale.Scale)..props.Name
		end)
		
		toggle.MouseEnter:Connect(function()
			isHover = true
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.37)
				})
			end
		end)
		
		toggle.MouseLeave:Connect(function()
			isHover = false
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.14)
				})
			end
		end)
		
		toggle.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		if props.Default then
			component:Toggle()
		end
		
		api.Options[props.Name] = component
		
		return component
	end,
	LegitModule = function(props, children, api)
		vape:Remove(props.Name)
		local component = {
			Enabled = false,
			Legit = true,
			Name = props.Name,
			Options = {},
			Type = 'LegitModule'
		}
		
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		button.Name = props.Name
		button.Text = ''
		button.Parent = children
		component.Object = button
		addTooltip(button, props.Tooltip, nil, function()
			return vape.LegitVisible
		end)
		addCorner(button)
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(16, 81)
		title.Size = UDim2.new(1, -16, 0, 20)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.31)
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = button
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		holder.Position = UDim2.new(1, -57, 0, 15)
		holder.Size = UDim2.fromOffset(22, 12)
		holder.Parent = button
		addCorner(holder, UDim.new(1, 0))
		local knob = Instance.new('Frame')
		knob.BackgroundColor3 = uipallet.Main
		knob.Position = UDim2.fromOffset(2, 2)
		knob.Size = UDim2.fromOffset(8, 8)
		knob.Parent = holder
		addCorner(knob, UDim.new(1, 0))
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.BackgroundTransparency = 1
		dotsbutton.Name = 'Dots'
		dotsbutton.Position = UDim2.new(1, -27, 0, 9)
		dotsbutton.Size = UDim2.fromOffset(14, 24)
		dotsbutton.Text = ''
		dotsbutton.Parent = button
		local dots = Instance.new('ImageLabel')
		dots.BackgroundTransparency = 1
		dots.Image = getvapeasset('newvape/assets/new/overlaydots.png')
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		dots.Name = 'Dots'
		dots.Position = UDim2.fromOffset(6, 6)
		dots.Size = UDim2.fromOffset(2, 12)
		dots.Parent = dotsbutton
		local shadow = Instance.new('TextButton')
		shadow.Name = 'Shadow'
		shadow.Size = UDim2.new(1, 0, 1, -5)
		shadow.BackgroundColor3 = Color3.new()
		shadow.BackgroundTransparency = 1
		shadow.AutoButtonColor = false
		shadow.ClipsDescendants = true
		shadow.Visible = false
		shadow.Text = ''
		shadow.Parent = api.Window
		addCorner(shadow)
		local settingspane = Instance.new('TextButton')
		settingspane.Size = UDim2.new(0, 220, 1, 0)
		settingspane.Position = UDim2.fromScale(1, 0)
		settingspane.BackgroundColor3 = uipallet.Main
		settingspane.AutoButtonColor = false
		settingspane.Text = ''
		settingspane.Parent = shadow
		local settingstitle = Instance.new('TextLabel')
		settingstitle.Name = 'Title'
		settingstitle.Size = UDim2.new(1, -36, 0, 20)
		settingstitle.Position = UDim2.fromOffset(36, 12)
		settingstitle.BackgroundTransparency = 1
		settingstitle.Text = props.Name
		settingstitle.TextXAlignment = Enum.TextXAlignment.Left
		settingstitle.TextColor3 = color.Dark(uipallet.Text, 0.16)
		settingstitle.TextSize = 13
		settingstitle.FontFace = uipallet.Font
		settingstitle.Parent = settingspane
		local back = Instance.new('ImageButton')
		back.Name = 'Back'
		back.Size = UDim2.fromOffset(16, 16)
		back.Position = UDim2.fromOffset(11, 13)
		back.BackgroundTransparency = 1
		back.Image = getvapeasset('newvape/assets/new/back.png')
		back.ImageColor3 = color.Light(uipallet.Main, 0.37)
		back.Parent = settingspane
		addCorner(settingspane)
		local settingschildren = Instance.new('ScrollingFrame')
		settingschildren.BackgroundColor3 = uipallet.Main
		settingschildren.BorderSizePixel = 0
		settingschildren.CanvasSize = UDim2.new()
		settingschildren.Name = 'Children'
		settingschildren.Position = UDim2.fromOffset(0, 41)
		settingschildren.ScrollBarThickness = 2
		settingschildren.ScrollBarImageTransparency = 0.75
		settingschildren.Size = UDim2.new(1, 0, 1, -45)
		settingschildren.Parent = settingspane
		local windowlist = Instance.new('UIListLayout')
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.Parent = settingschildren
		if props.Size then
			local modulechildren = Instance.new('Frame')
			modulechildren.Size = props.Size
			modulechildren.BackgroundTransparency = 1
			modulechildren.Visible = false
			modulechildren.Parent = scaledgui
			addDragHandler(modulechildren, api.Window)
			local objectstroke = Instance.new('UIStroke')
			objectstroke.Color = Color3.fromRGB(5, 134, 105)
			objectstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			objectstroke.Thickness = 0
			objectstroke.Parent = modulechildren
			component.Children = modulechildren
		end
		props.Function = props.Function or function() end
		addMaid(component)
		
		function component:Color(hue, sat, val, isRainbow)
			if self.Enabled then
				tween:Cancel(holder)
				holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		
			for _, component in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow)
				end
			end
		end
		
		function component:Load(data)
			vape:LoadOptions(self, data.Options)
		
			if self.Enabled ~= data.Enabled then
				self:Toggle()
			end
		
			if data.Position and self.Children then
				self.Children.Position = UDim2.fromOffset(data.Position.X, data.Position.Y)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Enabled,
				Options = vape:SaveOptions(self),
				Position = self.Children and {
					X = self.Children.Position.X.Offset,
					Y = self.Children.Position.Y.Offset
				} or nil
			}
		end
		
		function component:Toggle()
			self.Enabled = not self.Enabled
			if self.Children then
				self.Children.Visible = self.Enabled
			end
		
			title.TextColor3 = self.Enabled and color.Light(uipallet.Text, 0.2) or color.Dark(uipallet.Text, 0.31)
			button.BackgroundColor3 = self.Enabled and color.Light(uipallet.Main, 0.05) or button.BackgroundColor3
		
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.14)
			})
		
			tween:Tween(knob, uipallet.Tween, {
				Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			})
		
			if not self.Enabled then
				for _, v in self.Connections do
					v:Disconnect()
				end
				table.clear(self.Connections)
			end
		
			task.spawn(props.Function, self.Enabled)
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, settingschildren, component)
			end
		end
		
		back.MouseEnter:Connect(function()
			back.ImageColor3 = uipallet.Text
		end)
		
		back.MouseLeave:Connect(function()
			back.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		back.MouseButton1Click:Connect(function()
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 1
			})
		
			tween:Tween(settingspane, uipallet.Tween, {
				Position = UDim2.fromScale(1, 0)
			})
		
			task.delay(0.2, function()
				shadow.Visible = false
			end)
		end)
		
		button.MouseEnter:Connect(function()
			if not component.Enabled then
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			end
		end)
		
		button.MouseLeave:Connect(function()
			if not component.Enabled then
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
		end)
		
		button.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		button.MouseButton2Click:Connect(function()
			shadow.Visible = true
		
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 0.5
			})
		
			tween:Tween(settingspane, uipallet.Tween, {
				Position = UDim2.new(1, -220, 0, 0)
			})
		end)
		
		dotsbutton.MouseButton1Click:Connect(function()
			shadow.Visible = true
		
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 0.5
			})
		
			tween:Tween(settingspane, uipallet.Tween, {
				Position = UDim2.new(1, -220, 0, 0)
			})
		end)
		
		dotsbutton.MouseEnter:Connect(function()
			dots.ImageColor3 = uipallet.Text
		end)
		
		dotsbutton.MouseLeave:Connect(function()
			dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		shadow.MouseButton1Click:Connect(function()
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 1
			})
		
			tween:Tween(settingspane, uipallet.Tween, {
				Position = UDim2.fromScale(1, 0)
			})
		
			task.delay(0.2, function()
				shadow.Visible = false
			end)
		end)
		
		shadow:GetPropertyChangedSignal('Visible'):Connect(function()
			tooltip.Visible = false
			vape.LegitVisible = shadow.Visible
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			settingschildren.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		end)
		
		api.Modules[props.Name] = component
		
		local sorting = {}
		for _, mod in api.Modules do
			table.insert(sorting, mod.Name)
		end
		table.sort(sorting)
		
		for index, name in sorting do
			api.Modules[name].Object.LayoutOrder = index
		end
		
		return component
	end,
	LegitWindow = function(props, children, api)
		local component = {
			Modules = {}
		}
		
		local window = Instance.new('Frame')
		window.BackgroundColor3 = uipallet.Main
		window.Position = UDim2.new(0.5, -350, 0.5, -190)
		window.Size = UDim2.fromOffset(700, 380)
		window.Name = 'LegitGUI'
		window.Visible = false
		window.Parent = scaledgui
		table.insert(vape.Windows, window)
		component.Window = window
		addBlur(window)
		addCorner(window)
		addDragHandler(window)
		local modal = Instance.new('TextButton')
		modal.BackgroundTransparency = 1
		modal.Modal = true
		modal.Text = ''
		modal.Parent = window
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/legit_mode_icon.png')
		icon.ImageColor3 = uipallet.Text
		icon.Position = UDim2.fromOffset(18, 11)
		icon.Size = UDim2.fromOffset(16, 16)
		icon.Parent = window
		local close = Instance.new('ImageButton')
		close.BackgroundTransparency = 1
		close.Image = getvapeasset('newvape/assets/new/min.png')
		close.ImageColor3 = color.Light(uipallet.Main, 0.24)
		close.Position = UDim2.new(1, -31, 0, 11)
		close.Size = UDim2.fromOffset(16, 16)
		close.Parent = window
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		holder.Position = UDim2.new(1, -253, 0, 42)
		holder.Size = UDim2.fromOffset(242, 29)
		holder.Parent = window
		addCorner(holder, UDim.new(0, 4))
		local stroke = Instance.new('UIStroke')
		stroke.Color = color.Light(uipallet.Main, 0.02)
		stroke.Parent = holder
		local searchicon = Instance.new('ImageLabel')
		searchicon.BackgroundTransparency = 1
		searchicon.Image = getvapeasset('newvape/assets/new/search.png')
		searchicon.ImageColor3 = color.Light(uipallet.Main, 0.42)
		searchicon.Position = UDim2.new(1, -25, 0, 9)
		searchicon.Size = UDim2.fromOffset(12, 12)
		searchicon.Parent = holder
		local box = Instance.new('TextBox')
		box.BackgroundTransparency = 1
		box.ClearTextOnFocus = false
		box.FontFace = uipallet.Font
		box.PlaceholderColor3 = color.Dark(uipallet.Text, 0.16)
		box.PlaceholderText = 'Search mods'
		box.Position = UDim2.fromOffset(8, 0)
		box.Size = UDim2.new(1, -8, 1, 0)
		box.Text = ''
		box.TextColor3 = color.Dark(uipallet.Text, 0.16)
		box.TextSize = 14
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Parent = holder
		local children = Instance.new('ScrollingFrame')
		children.BackgroundTransparency = 1
		children.BorderSizePixel = 0
		children.CanvasSize = UDim2.new()
		children.Position = UDim2.fromOffset(14, 76)
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.Size = UDim2.fromOffset(684, 301)
		children.Parent = window
		local windowlist = Instance.new('UIGridLayout')
		windowlist.CellSize = UDim2.fromOffset(163, 114)
		windowlist.CellPadding = UDim2.fromOffset(6, 6)
		windowlist.FillDirectionMaxCells = 4
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, children, component)
			end
		end
		
		function component:CreateModule(props)
			return components.LegitModule(props, children, component)
		end
		
		local function visibleCheck()
			for _, module in component.Modules do
				if module.Children then
					local visible = clickgui.Visible
					--[[for _, v2 in self.Windows do
						visible = visible or v2.Visible
					end]]
		
					module.Children.Visible = (not visible or window.Visible) and module.Enabled
				end
			end
		end
		
		box:GetPropertyChangedSignal('Text'):Connect(function()
			for name, module in component.Modules do
				module.Object.Visible = (box.Text == '' or name:lower():find(box.Text:lower())) and true or false
			end
		end)
		
		close.MouseButton1Click:Connect(function()
			window.Visible = false
			clickgui.Visible = true
		end)
		
		close.MouseEnter:Connect(function()
			close.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		close.MouseLeave:Connect(function()
			close.ImageColor3 = color.Light(uipallet.Main, 0.24)
		end)
		
		vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(visibleCheck))
		
		holder.MouseEnter:Connect(function()
			tween:Tween(stroke, uipallet.Tween, {
				Color = color.Light(uipallet.Main, 0.0875)
			})
		end)
		
		holder.MouseLeave:Connect(function()
			tween:Tween(stroke, uipallet.Tween, {
				Color = color.Light(uipallet.Main, 0.02)
			})
		end)
		
		window:GetPropertyChangedSignal('Visible'):Connect(function()
			vape:UpdateGUI()
			visibleCheck()
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		end)
		
		vape.Legit = component
		
		return component
	end,
	Module = function(props, children, api)
		vape:Remove(props.Name)
		local component = {
			Category = api.Name,
			Enabled = false,
			ExtraText = props.ExtraText,
			Index = getTableSize(vape.Modules),
			Name = props.Name,
			Options = {},
			Visible = true
		}
		
		local isHover = false
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = uipallet.Main
		button.BorderSizePixel = 0
		button.FontFace = uipallet.Font
		button.Name = props.Name
		button.Size = UDim2.fromOffset(220, 40)
		button.Text = string.rep(' ', 12)..props.Name
		button.TextColor3 = color.Dark(uipallet.Text, 0.16)
		button.TextSize = 14
		button.TextXAlignment = Enum.TextXAlignment.Left
		button.Parent = children
		component.Object = button
		addTooltip(button, props.Tooltip)
		local gradient = Instance.new('UIGradient')
		gradient.Enabled = false
		gradient.Rotation = 90
		gradient.Parent = button
		local modulechildren = Instance.new('Frame')
		modulechildren.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		modulechildren.BorderSizePixel = 0
		modulechildren.Name = props.Name..'Children'
		modulechildren.Size = UDim2.new(1, 0, 0, 0)
		modulechildren.Visible = false
		modulechildren.Parent = children
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = modulechildren
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.BackgroundTransparency = 1
		dotsbutton.Name = 'Dots'
		dotsbutton.Position = UDim2.new(1, -25, 0, 0)
		dotsbutton.Size = UDim2.fromOffset(25, 40)
		dotsbutton.Text = ''
		dotsbutton.Parent = button
		local dots = Instance.new('ImageLabel')
		dots.BackgroundTransparency = 1
		dots.Image = getvapeasset('newvape/assets/new/settingdots.png')
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		dots.Name = 'Dots'
		dots.Position = UDim2.fromOffset(4, 12)
		dots.Size = UDim2.fromOffset(3, 16)
		dots.Parent = dotsbutton
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = Color3.new(0.19, 0.19, 0.19)
		divider.BackgroundTransparency = 0.52
		divider.BorderSizePixel = 0
		divider.Name = 'Divider'
		divider.Position = UDim2.new(0, 0, 1, -1)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Visible = false
		divider.Parent = button
		local edit = Instance.new('TextButton')
		edit.AutoButtonColor = false
		edit.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		edit.BorderSizePixel = 0
		edit.Size = UDim2.fromOffset(40, 40)
		edit.Text = ''
		edit.Visible = false
		edit.Parent = button
		local editbox = Instance.new('Frame')
		editbox.BorderSizePixel = 0
		editbox.Position = UDim2.fromOffset(16, 16)
		editbox.Size = UDim2.fromOffset(8, 8)
		editbox.Parent = edit
		local editborder = Instance.new('UIStroke')
		editborder.BorderOffset = UDim.new(0, 1)
		editborder.LineJoinMode = Enum.LineJoinMode.Miter
		editborder.Parent = editbox
		props.Function = props.Function or function() end
		component.Edit = edit
		component.Children = modulechildren
		addMaid(component)
		
		function component:Color(hue, sat, val, isRainbow)
			if self.Enabled then
				button.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
				button.TextColor3 = vape.GUIColor.Rainbow and Color3.new(0.19, 0.19, 0.19) or vape:TextColor(hue, sat, val)
				button.UIGradient.Enabled = isRainbow and vape.RainbowMode.Value == 'Gradient'
		
				if button.UIGradient.Enabled then
					button.BackgroundColor3 = Color3.new(1, 1, 1)
					button.UIGradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(vape:Color((hue - (self.Index * 0.025)) % 1))),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(vape:Color((hue - ((self.Index + 1) * 0.025)) % 1)))
					})
				end
		
				self.Bind:SetColor(self.Object.TextColor3)
				dots.ImageColor3 = self.Object.TextColor3
			end
		
			if self.Visible then
				editbox.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.025)) % 1)) or Color3.fromHSV(hue, sat, val)
				editborder.Color = editbox.BackgroundColor3
			end
		
			for _, component in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow)
				end
			end
		end
		
		function component:Destroy()
			self.Bind:Destroy()
		
			for _, option in self.Options do
				if option.Type == 'Bind' then
					option:Destroy()
				end
			end
		end
		
		function component:Load(data)
			vape:LoadOptions(self, data.Options)
			self.Bind:Load(data.Bind)
		
			if self.Enabled ~= (data.Enabled and not self.Bind.Hold) then
				self:Toggle(true)
			end
		
			if self.Visible ~= data.Visible then
				self:SetVisible(data.Visible, true)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Enabled,
				Options = vape:SaveOptions(self),
				Visible = self.Visible
			}
		
			self.Bind:Save(data[props.Name])
		end
		
		function component:SetVisible(isVisible, isLoad)
			self.Visible = isVisible
			editbox.BackgroundTransparency = isVisible and 0 or 1
			editborder.Color = isVisible and editbox.BackgroundColor3 or color.Light(uipallet.Main, 0.37)
		
			if isLoad and not vape.EditGUI then
				button.Visible = isVisible
			end
		end
		
		function component:Toggle(multiple)
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			self.Enabled = not self.Enabled
			divider.Visible = self.Enabled
			gradient.Enabled = self.Enabled
			button.TextColor3 = (isHover or modulechildren.Visible) and uipallet.Text or color.Dark(uipallet.Text, 0.16)
			button.BackgroundColor3 = (isHover or modulechildren.Visible) and color.Light(uipallet.Main, 0.02) or uipallet.Main
			dots.ImageColor3 = self.Enabled and Color3.fromRGB(50, 50, 50) or color.Light(uipallet.Main, 0.37)
			component.Bind:SetColor(color.Dark(uipallet.Text, 0.43))
		
			if not self.Enabled then
				for _, v in self.Connections do
					v:Disconnect()
				end
				table.clear(self.Connections)
			end
		
			if multiple then
				if not vape.TextGUIThread then
					vape.TextGUIThread = task.defer(function()
						if vape.Loaded ~= nil then
							vape:UpdateTextGUI()
						end
		
						vape.TextGUIThread = nil
					end)
				end
			else
				vape:UpdateTextGUI()
			end
		
			task.spawn(props.Function, self.Enabled)
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, modulechildren, component)
			end
		end
		
		button.MouseEnter:Connect(function()
			isHover = true
			if not component.Enabled and not modulechildren.Visible then
				button.TextColor3 = uipallet.Text
				button.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			end
		
			component.Bind:SetVisible(isHover or modulechildren.Visible)
		end)
		
		button.MouseLeave:Connect(function()
			isHover = false
			if not component.Enabled and not modulechildren.Visible then
				button.TextColor3 = color.Dark(uipallet.Text, 0.16)
				button.BackgroundColor3 = uipallet.Main
			end
		
			component.Bind:SetVisible(isHover or modulechildren.Visible)
		end)
		
		button.MouseButton1Click:Connect(function()
			if vape.EditGUI then
				return
			end
		
			component:Toggle()
		end)
		
		button.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		
		dotsbutton.MouseButton1Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		
		dotsbutton.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
		end)
		
		dotsbutton.MouseEnter:Connect(function()
			if not component.Enabled then
				dots.ImageColor3 = uipallet.Text
			end
		end)
		
		dotsbutton.MouseLeave:Connect(function()
			if not component.Enabled then
				dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
			end
		end)
		
		edit.MouseButton1Click:Connect(function()
			component:SetVisible(not component.Visible)
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		end)
		
		local bind = component:CreateBind({
			Module = true,
			Cover = true
		})
		
		bind.Triggered:Connect(function(isDown)
			if bind.Hold then
				if component.Enabled ~= isDown then
					if vape.ToggleNotifications.Enabled then
						vape:CreateNotification(props.Name, (not component.Enabled and "<font color='#00AA00'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>"), 1.5)
					end
		
					component:Toggle(true)
				end
			else
				if vape.ToggleNotifications.Enabled then
					vape:CreateNotification(props.Name, (not component.Enabled and "<font color='#00AA00'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>"), 1.5)
				end
		
				component:Toggle(true)
			end
		end)
		
		if inputService.TouchEnabled then
			local isHeld = false
		
			button.MouseButton1Down:Connect(function()
				isHeld = true
				local holdtime, holdPos = os.clock(), inputService:GetMouseLocation()
				repeat
					isHeld = (inputService:GetMouseLocation() - holdPos).Magnitude < 3
					task.wait()
				until (os.clock() - holdtime) > 1 or not isHeld or not clickgui.Visible
		
				if isHeld and clickgui.Visible then
					if vape.ThreadFix then
						setthreadidentity(8)
					end
		
					clickgui.Visible = false
					tooltip.Visible = false
					vape:BlurCheck()
					for _, module in vape.Modules do
						if module.Bind.Mobile then
							module.Bind.Mobile.Visible = true
						end
					end
		
					local connection
					connection = inputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch then
							if vape.ThreadFix then
								setthreadidentity(8)
							end
		
							bind:CreateMobileButton(input.Position + Vector3.new(0, guiService:GetGuiInset().Y, 0))
							clickgui.Visible = true
							vape:BlurCheck()
		
							for _, module in vape.Modules do
								if module.Bind.Mobile then
									module.Bind.Mobile.Visible = false
								end
							end
		
							connection:Disconnect()
						end
					end)
				end
			end)
		
			button.MouseButton1Up:Connect(function()
				isHeld = false
			end)
		end
		
		vape.Modules[props.Name] = component
		vape:SortCategories()
		
		return component
	end,
	Overlay = function(props, children, api)
		local window
		local component
		component = {
			Button = vape.Overlays:CreateImageToggle({
				Name = props.Name,
				Function = function(callback)
					window.Visible = callback and (clickgui.Visible or component.Pinned)
		
					if not callback then
						for _, v in component.Connections do
							v:Disconnect()
						end
						table.clear(component.Connections)
					end
		
					if props.Function then
						task.spawn(props.Function, callback)
					end
				end,
				Icon = props.Icon,
				Size = props.Size,
				Position = props.Position
			}),
			Expanded = false,
			Pinned = false,
			Options = {},
			Type = 'Overlay'
		}
		
		window = Instance.new('TextButton')
		window.AutoButtonColor = false
		window.BackgroundColor3 = uipallet.Main
		window.Name = props.Name..'Overlay'
		window.Position = UDim2.fromOffset(240, 46)
		window.Size = UDim2.fromOffset(props.CategorySize or 220, 41)
		window.Text = ''
		window.Visible = false
		window.Parent = scaledgui
		component.Object = window
		local blur = addBlur(window)
		addCorner(window)
		addDragHandler(window)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = props.Icon
		icon.ImageColor3 = uipallet.Text
		icon.Position = UDim2.fromOffset(12, (icon.Size.X.Offset > 14 and 14 or 13))
		icon.Size = props.Size
		icon.Parent = window
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Size = UDim2.new(1, -32, 0, 41)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 0)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = window
		local pin = Instance.new('ImageButton')
		pin.Name = 'Pin'
		pin.Size = UDim2.fromOffset(14, 14)
		pin.Position = UDim2.new(1, -37, 0, 14)
		pin.BackgroundTransparency = 1
		pin.AutoButtonColor = false
		pin.Image = getvapeasset('newvape/assets/new/pin.png')
		pin.ImageColor3 = color.Dark(uipallet.Text, 0.43)
		pin.Parent = window
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.Name = 'Dots'
		dotsbutton.Size = UDim2.fromOffset(17, 40)
		dotsbutton.Position = UDim2.new(1, -17, 0, 0)
		dotsbutton.BackgroundTransparency = 1
		dotsbutton.Text = ''
		dotsbutton.Parent = window
		local dots = Instance.new('ImageLabel')
		dots.BackgroundTransparency = 1
		dots.Image = getvapeasset('newvape/assets/new/overlaydots.png')
		dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
		dots.Position = UDim2.fromOffset(5, 15)
		dots.Size = UDim2.fromOffset(2, 12)
		dots.Parent = dotsbutton
		local customchildren = Instance.new('Frame')
		customchildren.BackgroundTransparency = 1
		customchildren.Position = UDim2.fromScale(0, 1)
		customchildren.Size = UDim2.new(1, 0, 0, 200)
		customchildren.Parent = window
		local children = Instance.new('ScrollingFrame')
		children.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		children.BorderSizePixel = 0
		children.CanvasSize = UDim2.new()
		children.Position = UDim2.fromOffset(0, 37)
		children.Size = UDim2.new(1, 0, 1, -41)
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.Visible = false
		children.Parent = window
		local stroke = Instance.new('UIStroke')
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(85, 85, 85)
		stroke.Transparency = 0.8
		stroke.Parent = window
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		addMaid(component)
		
		function component:Color(hue, sat, val, isRainbow)
			for _, component in self.Options do
				if component.Color then
					component:Color(hue, sat, val, isRainbow)
				end
			end
		end
		
		function component:Expand(visCheck)
			if visCheck and not blur.Enabled then return end
		
			self.Expanded = not self.Expanded
			children.Visible = self.Expanded
			dots.ImageColor3 = self.Expanded and uipallet.Text or color.Light(uipallet.Main, 0.37)
		
			if self.Expanded then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
			else
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 41)
			end
		end
		
		function component:Load(data)
			vape:LoadOptions(self, data.Options)
		
			if self.Button.Enabled ~= data.Enabled then
				self.Button:Toggle()
			end
		
			if self.Pinned ~= data.Pinned then
				self:Pin()
				self:Update()
			end
		
			if data.Position then
				window.Position = UDim2.fromOffset(data.Position.X, data.Position.Y)
			end
		end
		
		function component:Pin()
			self.Pinned = not self.Pinned
			pin.ImageColor3 = self.Pinned and uipallet.Text or color.Dark(uipallet.Text, 0.43)
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Button.Enabled,
				Options = vape:SaveOptions(self),
				Pinned = self.Pinned,
				Position = {
					X = window.Position.X.Offset,
					Y = window.Position.Y.Offset
				}
			}
		end
		
		function component:Update()
			window.Visible = self.Button.Enabled and (clickgui.Visible or self.Pinned)
			if self.Expanded then
				self:Expand()
			end
		
			if clickgui.Visible then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 41)
				window.BackgroundTransparency = 0
				blur.Enabled = true
				stroke.Enabled = true
				icon.Visible = true
				title.Visible = true
				pin.Visible = true
				dotsbutton.Visible = true
			else
				window.Size = UDim2.fromOffset(window.Size.X.Offset, 0)
				window.BackgroundTransparency = 1
				blur.Enabled = false
				stroke.Enabled = false
				icon.Visible = false
				title.Visible = false
				pin.Visible = false
				dotsbutton.Visible = false
			end
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, children, component)
			end
		end
		
		vape:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
			component:Update()
		end))
		
		dotsbutton.MouseEnter:Connect(function()
			if not children.Visible then
				dots.ImageColor3 = uipallet.Text
			end
		end)
		
		dotsbutton.MouseLeave:Connect(function()
			if not children.Visible then
				dots.ImageColor3 = color.Light(uipallet.Main, 0.37)
			end
		end)
		
		dotsbutton.MouseButton1Click:Connect(function()
			component:Expand(true)
		end)
		
		dotsbutton.MouseButton2Click:Connect(function()
			component:Expand(true)
		end)
		
		pin.MouseButton1Click:Connect(function()
			component:Pin()
		end)
		
		window.MouseButton2Click:Connect(function()
			component:Expand(true)
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
			if component.Expanded then
				window.Size = UDim2.fromOffset(window.Size.X.Offset, math.min(41 + windowlist.AbsoluteContentSize.Y / scale.Scale, 601))
			end
		end)
		
		component.Children = customchildren
		vape.Categories[props.Name] = component
		
		return component
	end,
	OverlayBar = function(props, children, api)
		local component = {
			Options = {},
			Type = 'OverlayBar'
		}
		
		local bar = Instance.new('Frame')
		bar.Name = 'Overlays'
		bar.Size = UDim2.fromOffset(220, 36)
		bar.BackgroundColor3 = uipallet.Main
		bar.BorderSizePixel = 0
		bar.Parent = children
		components.Divider(nil, bar)
		local button = Instance.new('ImageButton')
		button.AutoButtonColor = false
		button.BackgroundTransparency = 1
		button.Image = getvapeasset('newvape/assets/new/overlays.png')
		button.ImageColor3 = color.Light(uipallet.Main, 0.37)
		button.Position = UDim2.new(1, -34, 0, 7)
		button.Size = UDim2.fromOffset(24, 24)
		button.Parent = bar
		addCorner(button, UDim.new(1, 0))
		addTooltip(button, 'Open overlays menu')
		local shadow = Instance.new('TextButton')
		shadow.AutoButtonColor = false
		shadow.BackgroundColor3 = Color3.new()
		shadow.BackgroundTransparency = 1
		shadow.ClipsDescendants = true
		shadow.Name = 'Shadow'
		shadow.Size = UDim2.new(1, 0, 1, -5)
		shadow.Text = ''
		shadow.Visible = false
		shadow.Parent = api.Object
		addCorner(shadow)
		local window = Instance.new('Frame')
		window.BackgroundColor3 = uipallet.Main
		window.Position = UDim2.fromScale(0, 1)
		window.Size = UDim2.fromOffset(220, 42)
		window.Parent = shadow
		addCorner(window)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/overlayslarge.png')
		icon.ImageColor3 = uipallet.Text
		icon.Position = UDim2.fromOffset(10, 13)
		icon.Size = UDim2.fromOffset(14, 12)
		icon.Parent = window
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(36, 0)
		title.Size = UDim2.new(1, -36, 0, 38)
		title.Text = 'Overlays'
		title.TextColor3 = uipallet.Text
		title.TextSize = 15
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = window
		local close = addCloseButton(window, false, UDim2.new(1, -35, 0, 7))
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		divider.BorderSizePixel = 0
		divider.Position = UDim2.fromOffset(0, 37)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Parent = window
		local childrentoggle = Instance.new('Frame')
		childrentoggle.BackgroundColor3 = uipallet.Main
		childrentoggle.BackgroundTransparency = 1
		childrentoggle.Position = UDim2.fromOffset(0, 38)
		childrentoggle.Parent = window
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = childrentoggle
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, childrentoggle, component)
			end
		end
		
		button.MouseEnter:Connect(function()
			button.ImageColor3 = uipallet.Text
			tween:Tween(button, uipallet.Tween, {
				BackgroundTransparency = 0.9
			})
		end)
		
		button.MouseLeave:Connect(function()
			button.ImageColor3 = color.Light(uipallet.Main, 0.37)
			tween:Tween(button, uipallet.Tween, {
				BackgroundTransparency = 1
			})
		end)
		
		button.MouseButton1Click:Connect(function()
			shadow.Visible = true
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 0.5
			})
		
			tween:Tween(window, uipallet.Tween, {
				Position = UDim2.new(0, 0, 1, -(window.Size.Y.Offset))
			})
		end)
		
		close.MouseButton1Click:Connect(function()
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 1
			})
		
			tween:Tween(window, uipallet.Tween, {
				Position = UDim2.fromScale(0, 1)
			})
		
			task.delay(0.2, function()
				shadow.Visible = false
			end)
		end)
		
		shadow.MouseButton1Click:Connect(function()
			tween:Tween(shadow, uipallet.Tween, {
				BackgroundTransparency = 1
			})
		
			tween:Tween(window, uipallet.Tween, {
				Position = UDim2.fromScale(0, 1)
			})
		
			task.delay(0.2, function()
				shadow.Visible = false
			end)
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			window.Size = UDim2.fromOffset(220, math.min(37 + windowlist.AbsoluteContentSize.Y / scale.Scale, 605))
			childrentoggle.Size = UDim2.fromOffset(220, window.Size.Y.Offset - 5)
		end)
		
		vape.Overlays = component
		
		return component
	end,
	SearchBar = function(props, children, api)
		local component = {
			Type = 'SearchBar'
		}
		
		local function listenProperty(src, dest, prop, obj)
			dest[prop] = src[prop]
			local connection = src:GetPropertyChangedSignal(prop):Connect(function()
				dest[prop] = src[prop]
			end)
		
			obj.Destroying:Once(function()
				connection:Disconnect()
			end)
		end
		
		local search = Instance.new('Frame')
		search.AnchorPoint = Vector2.new(0.5, 0)
		search.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		search.Name = 'Search'
		search.Position = UDim2.new(0.5, 0, 0, 13)
		search.Size = UDim2.fromOffset(220, 37)
		search.Parent = clickgui
		component.Object = search
		addBlur(search)
		addCorner(search)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/search.png')
		icon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		icon.Position = UDim2.new(1, -25, 0, 11)
		icon.Size = UDim2.fromOffset(14, 14)
		icon.Parent = search
		local legiticon = Instance.new('ImageButton')
		legiticon.BackgroundTransparency = 1
		legiticon.Image = getvapeasset('newvape/assets/new/legit_switch.png')
		legiticon.Name = 'Legit'
		legiticon.Position = UDim2.fromOffset(8, 11)
		legiticon.Size = UDim2.fromOffset(29, 16)
		legiticon.Parent = search
		listenProperty(vape.Categories.Main.Object.VapeLogo.V4Logo, legiticon, 'ImageColor3', legiticon)
		local legitdivider = Instance.new('Frame')
		legitdivider.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		legitdivider.BorderSizePixel = 0
		legitdivider.Name = 'LegitDivider'
		legitdivider.Position = UDim2.fromOffset(43, 13)
		legitdivider.Size = UDim2.fromOffset(2, 12)
		legitdivider.Parent = search
		local box = Instance.new('TextBox')
		box.BackgroundTransparency = 1
		box.ClearTextOnFocus = false
		box.FontFace = uipallet.Font
		box.PlaceholderText = ''
		box.Position = UDim2.fromOffset(50, 0)
		box.Size = UDim2.new(1, -50, 0, 37)
		box.Text = ''
		box.TextColor3 = uipallet.Text
		box.TextSize = 12
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Parent = search
		local children = Instance.new('ScrollingFrame')
		children.BackgroundTransparency = 1
		children.BorderSizePixel = 0
		children.CanvasSize = UDim2.new()
		children.Position = UDim2.fromOffset(0, 34)
		children.ScrollBarThickness = 2
		children.ScrollBarImageTransparency = 0.75
		children.Size = UDim2.new(1, 0, 1, -37)
		children.Parent = search
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = Color3.new(1, 1, 1)
		divider.BackgroundTransparency = 0.928
		divider.BorderSizePixel = 0
		divider.Position = UDim2.fromOffset(0, 33)
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Visible = false
		divider.Parent = search
		local stroke = Instance.new('UIStroke')
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(85, 85, 85)
		stroke.Transparency = 0.8
		stroke.Parent = search
		local windowlist = Instance.new('UIListLayout')
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.Parent = children
		
		box:GetPropertyChangedSignal('Text'):Connect(function()
			for _, obj in children:GetChildren() do
				if obj:IsA('TextButton') then
					obj:Destroy()
				end
			end
		
			if box.Text == '' then return end
		
			for name, module in vape.Modules do
				if name:lower():find(box.Text:lower()) then
					local button = module.Object:Clone()
					button.Bind:Destroy()
		
					button.MouseButton1Click:Connect(function()
						module:Toggle()
					end)
		
					button.MouseButton2Click:Connect(function()
						module.Object.Parent.Parent.Visible = true
						local frame = module.Object.Parent
						local highlight = Instance.new('Frame')
						highlight.Size = UDim2.fromScale(1, 1)
						highlight.BackgroundColor3 = Color3.new(1, 1, 1)
						highlight.BackgroundTransparency = 0.6
						highlight.BorderSizePixel = 0
						highlight.Parent = module.Object
		
						tween:Tween(highlight, TweenInfo.new(0.5), {
							BackgroundTransparency = 1
						})
						task.delay(0.5, highlight.Destroy, highlight)
						frame.CanvasPosition = Vector2.new(0, (module.Object.LayoutOrder * 40) - (math.min(frame.CanvasSize.Y.Offset, 600) / 2))
					end)
		
					for _, prop in {'Text', 'TextColor3', 'BackgroundColor3'} do
						listenProperty(module.Object, button, prop, button)
					end
		
					listenProperty(module.Object.UIGradient, button.UIGradient, 'Color', button)
					listenProperty(module.Object.UIGradient, button.UIGradient, 'Enabled', button)
					listenProperty(module.Object.Dots.Dots, button.Dots.Dots, 'ImageColor3', button)
		
					button.Parent = children
				end
			end
		end)
		
		children:GetPropertyChangedSignal('CanvasPosition'):Connect(function()
			divider.Visible = children.CanvasPosition.Y > 10 and children.Visible
		end)
		
		legiticon.MouseButton1Click:Connect(function()
			clickgui.Visible = false
			vape.Legit.Window.Visible = true
			vape.Legit.Window.Position = UDim2.new(0.5, -350, 0.5, -194)
		end)
		
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
			search.Size = UDim2.fromOffset(220, math.min(37 + windowlist.AbsoluteContentSize.Y / scale.Scale, 437))
		end)
		
		return component
	end,
	SettingsPane = function(props, children, api)
		local component = {
			Buttons = {},
			Options = {},
			Parent = api.Parent or children,
			Type = 'SettingsPane'
		}
		
		local pane = Instance.new('TextButton')
		pane.AutoButtonColor = false
		pane.BackgroundColor3 = props.Main and color.Dark(uipallet.Main, 0.02) or uipallet.Main
		pane.Size = UDim2.fromScale(1, 1)
		pane.Text = ''
		pane.Visible = false
		pane.Parent = component.Parent
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Name = 'Title'
		title.Size = UDim2.new(1, -36, 0, 20)
		title.Position = UDim2.fromOffset(math.abs(title.Size.X.Offset), 11)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = pane
		local close = addCloseButton(pane, true)
		local back = Instance.new('ImageButton')
		back.BackgroundTransparency = 1
		back.Image = getvapeasset('newvape/assets/new/backmini.png')
		back.ImageColor3 = color.Light(uipallet.Main, 0.37)
		back.Position = UDim2.fromOffset(12, 14)
		back.Size = UDim2.fromOffset(14, 14)
		back.Parent = pane
		addCorner(pane)
		local settingschildren = Instance.new('Frame')
		settingschildren.BackgroundColor3 = uipallet.Main
		settingschildren.BorderSizePixel = 0
		settingschildren.Name = 'Children'
		settingschildren.Position = UDim2.fromOffset(0, 41)
		settingschildren.Size = UDim2.new(1, 0, 1, -57)
		settingschildren.Parent = pane
		local divider = Instance.new('Frame')
		divider.BackgroundColor3 = Color3.new(1, 1, 1)
		divider.BackgroundTransparency = 0.928
		divider.BorderSizePixel = 0
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.Parent = settingschildren
		local listlayout = Instance.new('UIListLayout')
		listlayout.SortOrder = Enum.SortOrder.LayoutOrder
		listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		listlayout.Parent = settingschildren
		if props.Main then
			local versionlabel = Instance.new('TextLabel')
			versionlabel.BackgroundTransparency = 1
			versionlabel.FontFace = uipallet.Font
			versionlabel.Name = 'Version'
			versionlabel.Position = UDim2.new(0, 0, 1, -16)
			versionlabel.Size = UDim2.new(1, 0, 0, 16)
			versionlabel.Text = 'Vape '..vape.Version..' '..(
				isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt'):sub(1, 6) or ''
			)..' '
			versionlabel.TextColor3 = color.Dark(uipallet.Text, 0.43)
			versionlabel.TextSize = 10
			versionlabel.TextXAlignment = Enum.TextXAlignment.Right
			versionlabel.Parent = pane
		else
			api:CreateGUIButton({
				Name = props.Name,
				Function = function()
					pane.Visible = true
				end
			})
		end
		
		function component:Load(data)
			vape:LoadOptions(self, data)
		end
		
		function component:Save(data)
			data[props.Name] = vape:SaveOptions(self)
		end
		
		for index, comp in components do
			component['Create'..index] = function(_, props)
				return comp(props, settingschildren, component)
			end
		end
		
		back.MouseEnter:Connect(function()
			back.ImageColor3 = uipallet.Text
		end)
		
		back.MouseLeave:Connect(function()
			back.ImageColor3 = color.Light(uipallet.Main, 0.37)
		end)
		
		back.MouseButton1Click:Connect(function()
			pane.Visible = false
		end)
		
		close.MouseButton1Click:Connect(function()
			pane.Visible = false
		end)
		
		listlayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			pane.Size = UDim2.new(1, 0, 0, math.max(45 + listlayout.AbsoluteContentSize.Y, component.Parent.AbsoluteSize.Y) / scale.Scale)
		end)
		
		component.Object = pane
		vape.Settings[props.Name] = component
		
		return component
	end,
	Slider = function(props, children, api)
		local component = {
			Index = getTableSize(api.Options),
			Max = props.Max,
			Type = 'Slider',
			Value = props.Default or props.Min,
		}
		
		local slider = Instance.new('TextButton')
		slider.AutoButtonColor = false
		slider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		slider.BorderSizePixel = 0
		slider.Size = UDim2.new(1, 0, 0, 50)
		slider.Text = ''
		slider.Visible = props.Visible == nil or props.Visible
		slider.Parent = children
		component.Object = slider
		addTooltip(slider, props.Tooltip)
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(10, 2)
		title.Size = UDim2.fromOffset(60, 30)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = slider
		local valuelabel = Instance.new('TextButton')
		valuelabel.BackgroundTransparency = 1
		valuelabel.FontFace = uipallet.Font
		valuelabel.Position = UDim2.new(1, -69, 0, 9)
		valuelabel.Size = UDim2.fromOffset(60, 15)
		valuelabel.Text = component.Value..(props.Suffix and ' '..(type(props.Suffix) == 'function' and props.Suffix(component.Value) or props.Suffix) or '')
		valuelabel.TextColor3 = color.Dark(uipallet.Text, 0.16)
		valuelabel.TextSize = 11
		valuelabel.TextXAlignment = Enum.TextXAlignment.Right
		valuelabel.Parent = slider
		local custombox = Instance.new('TextBox')
		custombox.BackgroundTransparency = 1
		custombox.ClearTextOnFocus = false
		custombox.FontFace = uipallet.Font
		custombox.Position = valuelabel.Position
		custombox.Size = valuelabel.Size
		custombox.Text = component.Value
		custombox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		custombox.TextSize = 11
		custombox.TextXAlignment = Enum.TextXAlignment.Right
		custombox.Visible = false
		custombox.Parent = slider
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		holder.BorderSizePixel = 0
		holder.Position = UDim2.fromOffset(10, 37)
		holder.Size = UDim2.new(1, -20, 0, 2)
		holder.Parent = slider
		local fill = Instance.new('Frame')
		fill.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
		fill.BorderSizePixel = 0
		fill.Size = UDim2.fromScale(math.clamp((component.Value - props.Min) / props.Max, 0.04, 0.96), 1)
		fill.Parent = holder
		local knobholder = Instance.new('Frame')
		knobholder.AnchorPoint = Vector2.new(0.5, 0.5)
		knobholder.BackgroundColor3 = slider.BackgroundColor3
		knobholder.BorderSizePixel = 0
		knobholder.Position = UDim2.fromScale(1, 0.5)
		knobholder.Size = UDim2.fromOffset(24, 4)
		knobholder.Parent = fill
		local knob = Instance.new('Frame')
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
		knob.Position = UDim2.fromScale(0.5, 0.5)
		knob.Size = UDim2.fromOffset(14, 14)
		knob.Parent = knobholder
		addCorner(knob, UDim.new(1, 0))
		props.Function = props.Function or function() end
		props.Decimal = props.Decimal or 1
		
		function component:Color(hue, sat, val, isRainbow)
			fill.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			knob.BackgroundColor3 = fill.BackgroundColor3
		end
		
		function component:Load(data)
			local newValue = data.Value == data.Max and data.Max ~= self.Max and self.Max or data.Value
			if self.Value ~= newValue then
				self:SetValue(newValue, nil, true)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Value = self.Value,
				Max = self.Max
			}
		end
		
		function component:SetValue(value, position, wasReleased)
			if not math.isfinite(value) then
				return
			end
		
			tween:Tween(fill, uipallet.Tween, {
				Size = UDim2.fromScale(math.clamp(position or math.clamp(value / props.Max, 0, 1), 0.04, 0.96), 1)
			})
		
			if self.Value ~= value or wasReleased then
				self.Value = value
				valuelabel.Text = self.Value..(props.Suffix and ' '..(type(props.Suffix) == 'function' and props.Suffix(self.Value) or props.Suffix) or '')
				props.Function(value, wasReleased)
			end
		end
		
		slider.InputBegan:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - slider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local newPosition = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
				local lastPosition = newPosition
		
				local releaseConnection
				local moveConnection = inputService.InputChanged:Connect(function(newInput)
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPosition = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
						component:SetValue(math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition)
						lastPosition = newPosition
					end
				end)
		
				releaseConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect()
						releaseConnection:Disconnect()
						component:SetValue(component.Value, lastPosition, true)
					end
				end)
		
				component:SetValue(math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition)
			end
		end)
		
		slider.MouseEnter:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(16, 16)
			})
		end)
		
		slider.MouseLeave:Connect(function()
			tween:Tween(knob, uipallet.Tween, {
				Size = UDim2.fromOffset(14, 14)
			})
		end)
		
		valuelabel.MouseButton1Click:Connect(function()
			valuelabel.Visible = false
			custombox.Visible = true
			custombox.Text = component.Value
			custombox:CaptureFocus()
		end)
		
		custombox.FocusLost:Connect(function(enter)
			valuelabel.Visible = true
			custombox.Visible = false
		
			if enter and tonumber(custombox.Text) then
				component:SetValue(tonumber(custombox.Text), nil, true)
			end
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
	Targets = function(props, children, api)
		local component = {
			Index = getTableSize(api.Options),
			Type = 'Targets'
		}
		
		local targets = Instance.new('TextButton')
		targets.AutoButtonColor = false
		targets.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		targets.BorderSizePixel = 0
		targets.Size = UDim2.new(1, 0, 0, 50)
		targets.Text = ''
		targets.Visible = props.Visible == nil or props.Visible
		targets.Parent = children
		component.Object = targets
		addTooltip(targets, props.Tooltip)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		holder.Position = UDim2.fromOffset(10, 4)
		holder.Size = UDim2.new(1, -20, 1, -9)
		holder.Parent = targets
		addCorner(holder, UDim.new(0, 4))
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = uipallet.Main
		button.Position = UDim2.fromOffset(1, 1)
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Text = ''
		button.Parent = holder
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(5, 6)
		title.Size = UDim2.new(1, -5, 0, 15)
		title.Text = 'Target:'
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 15
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = button
		local items = Instance.new('TextLabel')
		items.BackgroundTransparency = 1
		items.FontFace = uipallet.Font
		items.Position = UDim2.fromOffset(5, 21)
		items.Size = UDim2.new(1, -5, 0, 15)
		items.Text = 'Ignore none'
		items.TextColor3 = color.Dark(uipallet.Text, 0.16)
		items.TextSize = 11
		items.TextTruncate = Enum.TextTruncate.AtEnd
		items.TextXAlignment = Enum.TextXAlignment.Left
		items.Parent = button
		addCorner(button, UDim.new(0, 4))
		local iconholder = Instance.new('Frame')
		iconholder.BackgroundTransparency = 1
		iconholder.Position = UDim2.fromOffset(52, 8)
		iconholder.Size = UDim2.fromOffset(65, 12)
		iconholder.Parent = button
		local layout = Instance.new('UIListLayout')
		layout.FillDirection = Enum.FillDirection.Horizontal
		layout.Padding = UDim.new(0, 6)
		layout.Parent = iconholder
		local targetswindow = Instance.new('TextButton')
		targetswindow.AutoButtonColor = false
		targetswindow.BackgroundColor3 = uipallet.Main
		targetswindow.BorderSizePixel = 0
		targetswindow.Position = UDim2.fromOffset(456, 139)
		targetswindow.Size = UDim2.fromOffset(220, 145)
		targetswindow.Text = ''
		targetswindow.Visible = false
		targetswindow.Parent = clickgui
		component.Window = targetswindow
		addBlur(targetswindow)
		addCorner(targetswindow)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/aim.png')
		icon.Position = UDim2.fromOffset(10, 15)
		icon.Size = UDim2.fromOffset(18, 12)
		icon.Parent = targetswindow
		local windowtitle = Instance.new('TextLabel')
		windowtitle.BackgroundTransparency = 1
		windowtitle.FontFace = uipallet.Font
		windowtitle.Size = UDim2.new(1, -36, 0, 20)
		windowtitle.Position = UDim2.fromOffset(math.abs(windowtitle.Size.X.Offset), 11)
		windowtitle.Text = 'Target settings'
		windowtitle.TextColor3 = uipallet.Text
		windowtitle.TextSize = 13
		windowtitle.TextXAlignment = Enum.TextXAlignment.Left
		windowtitle.Parent = targetswindow
		local close = addCloseButton(targetswindow)
		props.Function = props.Function or function() end
		
		function component:Color(hue, sat, val, isRainbow)
			if targetswindow.Visible then
				holder.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		
			if self.Players.Enabled then
				tween:Cancel(self.Players.Object.Frame)
				self.Players.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		
			if self.NPCs.Enabled then
				tween:Cancel(self.NPCs.Object.Frame)
				self.NPCs.Object.Frame.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		
			if self.Invisible.Enabled then
				tween:Cancel(self.Invisible.Object.Holder)
				self.Invisible.Object.Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		
			if self.Walls.Enabled then
				tween:Cancel(self.Walls.Object.Holder)
				self.Walls.Object.Holder.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
			end
		end
		
		function component:Load(data)
			if self.Players.Enabled ~= data.Players then
				self.Players:Toggle()
			end
		
			if self.NPCs.Enabled ~= data.NPCs then
				self.NPCs:Toggle()
			end
		
			if self.Invisible.Enabled ~= data.Invisible then
				self.Invisible:Toggle()
			end
		
			if self.Walls.Enabled ~= data.Walls then
				self.Walls:Toggle()
			end
		end
		
		function component:Save(data)
			data.Targets = {
				Players = self.Players.Enabled,
				NPCs = self.NPCs.Enabled,
				Invisible = self.Invisible.Enabled,
				Walls = self.Walls.Enabled
			}
		end
		
		function component:UpdateText()
			local newText = {}
		
			if self.Players.Enabled then
				table.insert(newText, 'Players')
			end
		
			if self.NPCs.Enabled then
				table.insert(newText, 'NPCs')
			end
		
			title.Text = 'Target: '..(#newText > 0 and table.concat(newText, ', ') or 'Nothing')
			title.TextColor3 = #newText > 0 and uipallet.Text or Color3.fromRGB(255, 90, 90)
		end
		
		component.Players = components.TargetsButton({
			Position = UDim2.fromOffset(11, 45),
			Icon = getvapeasset('newvape/assets/new/players.png'),
			IconSize = UDim2.fromOffset(16, 16),
			IconParent = iconholder,
			Targets = component,
			Tooltip = 'Target players',
			Function = props.Function
		}, targetswindow, iconholder)
		
		component.NPCs = components.TargetsButton({
			Position = UDim2.fromOffset(112, 45),
			Icon = getvapeasset('newvape/assets/new/npcs.png'),
			IconSize = UDim2.fromOffset(12, 16),
			IconParent = iconholder,
			Targets = component,
			Tooltip = 'Target NPCs',
			Function = props.Function
		}, targetswindow, iconholder)
		
		component.Invisible = components.Toggle({
			Name = 'Ignore invisible',
			Function = function()
				local newText = {}
		
				if component.Invisible.Enabled then
					table.insert(newText, 'invisible')
				end
		
				if component.Walls.Enabled then
					table.insert(newText, 'behind walls')
				end
		
				items.Text = 'Ignore '..(#newText > 0 and table.concat(newText, ', ') or 'none')
				props.Function()
			end
		}, targetswindow, {Options = {}})
		component.Invisible.Object.Position = UDim2.fromOffset(0, 81)
		
		component.Walls = components.Toggle({
			Name = 'Ignore behind walls',
			Function = function()
				local newText = {}
		
				if component.Invisible.Enabled then
					table.insert(newText, 'invisible')
				end
		
				if component.Walls.Enabled then
					table.insert(newText, 'behind walls')
				end
		
				items.Text = 'Ignore '..(#newText > 0 and table.concat(newText, ', ') or 'none')
				props.Function()
			end
		}, targetswindow, {Options = {}})
		component.Walls.Object.Position = UDim2.fromOffset(0, 111)
		
		if props.Players then
			component.Players:Toggle()
		end
		
		if props.NPCs then
			component.NPCs:Toggle()
		end
		
		if props.Invisible then
			component.Invisible:Toggle()
		end
		
		if props.Walls then
			component.Walls:Toggle()
		end
		
		close.MouseButton1Click:Connect(function()
			targetswindow.Visible = false
		end)
		
		button.MouseButton1Click:Connect(function()
			targetswindow.Visible = not targetswindow.Visible
			tween:Cancel(holder)
		
			holder.BackgroundColor3 = targetswindow.Visible and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.37)
		end)
		
		targets.MouseEnter:Connect(function()
			if not targetswindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.37)
				})
			end
		end)
		
		targets.MouseLeave:Connect(function()
			if not targetswindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.034)
				})
			end
		end)
		
		targets:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			local actualPosition = (targets.AbsolutePosition + Vector2.new(0, 60)) / scale.Scale
			targetswindow.Position = UDim2.fromOffset(actualPosition.X + 223, actualPosition.Y)
		end)
		
		api.Options.Targets = component
		
		return component
	end,
	TargetsButton = function(props, children, api)
		local component = {
			Enabled = false,
			Type = 'TargetsButton'
		}
		
		local targetsbutton = Instance.new('TextButton')
		targetsbutton.AutoButtonColor = false
		targetsbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		targetsbutton.Position = props.Position
		targetsbutton.Size = UDim2.fromOffset(98, 31)
		targetsbutton.Text = ''
		targetsbutton.Visible = props.Visible == nil or props.Visible
		targetsbutton.Parent = children
		component.Object = targetsbutton
		addCorner(targetsbutton)
		addTooltip(targetsbutton, props.Tooltip)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = uipallet.Main
		holder.Position = UDim2.fromOffset(1, 1)
		holder.Size = UDim2.new(1, -2, 1, -2)
		holder.Parent = targetsbutton
		addCorner(holder)
		local icon = Instance.new('ImageLabel')
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = props.Icon
		icon.ImageColor3 = color.Light(uipallet.Main, 0.37)
		icon.Position = UDim2.fromScale(0.5, 0.5)
		icon.Size = props.IconSize
		icon.Parent = holder
		props.Function = props.Function or function() end
		
		function component:Toggle()
			self.Enabled = not self.Enabled
		
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or uipallet.Main
			})
		
			tween:Tween(icon, uipallet.Tween, {
				ImageColor3 = self.Enabled and Color3.new(1, 1, 1) or color.Light(uipallet.Main, 0.37)
			})
		
			props.Targets:UpdateText()
			props.Function(self.Enabled)
		end
		
		targetsbutton.MouseEnter:Connect(function()
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value - 0.25)
				})
		
				tween:Tween(icon, uipallet.Tween, {
					ImageColor3 = Color3.new(1, 1, 1)
				})
			end
		end)
		
		targetsbutton.MouseLeave:Connect(function()
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = uipallet.Main
				})
		
				tween:Tween(icon, uipallet.Tween, {
					ImageColor3 = color.Light(uipallet.Main, 0.37)
				})
			end
		end)
		
		targetsbutton.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		return component
	end,
	TextBox = function(props, children, api)
		local component = {
			Index = 0,
			Type = 'TextBox',
			Value = props.Default or ''
		}
		
		local textbox = Instance.new('TextButton')
		textbox.AutoButtonColor = false
		textbox.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		textbox.BorderSizePixel = 0
		textbox.Size = UDim2.new(1, 0, 0, 58)
		textbox.Text = ''
		textbox.Visible = props.Visible == nil or props.Visible
		textbox.Parent = children
		component.Object = textbox
		addTooltip(textbox, props.Tooltip)
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(10, 3)
		title.Size = UDim2.new(1, -10, 0, 20)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 12
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = textbox
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		holder.Position = UDim2.fromOffset(10, 23)
		holder.Size = UDim2.new(1, -20, 0, 29)
		holder.Parent = textbox
		addCorner(holder, UDim.new(0, 4))
		local inputbox = Instance.new('TextBox')
		inputbox.BackgroundTransparency = 1
		inputbox.ClearTextOnFocus = false
		inputbox.FontFace = uipallet.Font
		inputbox.PlaceholderColor3 = color.Dark(uipallet.Text, 0.31)
		inputbox.PlaceholderText = props.Placeholder or 'Click to set'
		inputbox.Position = UDim2.fromOffset(8, 0)
		inputbox.Size = UDim2.new(1, -8, 1, 0)
		inputbox.Text = props.Default or ''
		inputbox.TextColor3 = color.Dark(uipallet.Text, 0.16)
		inputbox.TextSize = 12
		inputbox.TextXAlignment = Enum.TextXAlignment.Left
		inputbox.Parent = holder
		props.Function = props.Function or function() end
		
		function component:Load(data)
			if self.Value ~= data.Value then
				self:SetValue(data.Value)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Value = self.Value
			}
		end
		
		function component:SetValue(val, enter)
			self.Value = val
			inputbox.Text = val
			props.Function(enter)
		end
		
		textbox.MouseButton1Click:Connect(function()
			inputbox:CaptureFocus()
		end)
		
		inputbox.FocusLost:Connect(function(enter)
			component:SetValue(inputbox.Text, enter)
		end)
		
		inputbox:GetPropertyChangedSignal('Text'):Connect(function()
			component:SetValue(inputbox.Text)
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
	TextList = function(props, children, api)
		local component = {
			Index = getTableSize(api.Options),
			List = props.Default and table.clone(props.Default) or {},
			ListEnabled = props.Default and table.clone(props.Default) or {},
			Objects = {},
			Type = 'TextList',
			Window = {Visible = false}
		}
		
		props.Color = props.Color or Color3.fromRGB(5, 134, 105)
		local textlist = Instance.new('TextButton')
		textlist.AutoButtonColor = false
		textlist.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		textlist.BorderSizePixel = 0
		textlist.Size = UDim2.new(1, 0, 0, 50)
		textlist.Text = ''
		textlist.Visible = props.Visible == nil or props.Visible
		textlist.Parent = children
		component.Object = textlist
		addTooltip(textlist, props.Tooltip)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		holder.Position = UDim2.fromOffset(10, 4)
		holder.Size = UDim2.new(1, -20, 1, -9)
		holder.Parent = textlist
		addCorner(holder, UDim.new(0, 4))
		local button = Instance.new('TextButton')
		button.AutoButtonColor = false
		button.BackgroundColor3 = uipallet.Main
		button.Position = UDim2.fromOffset(1, 1)
		button.Size = UDim2.new(1, -2, 1, -2)
		button.Text = ''
		button.Parent = holder
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/allowediconmini.png')
		icon.Position = UDim2.fromOffset(10, 14)
		icon.Size = UDim2.fromOffset(14, 12)
		icon.Parent = button
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(35, 6)
		title.Size = UDim2.new(1, -35, 0, 15)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 15
		title.TextTruncate = Enum.TextTruncate.AtEnd
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = button
		local amount = Instance.fromExisting(title)
		amount.Position = UDim2.fromOffset(0, 6)
		amount.Size = UDim2.new(1, -13, 0, 15)
		amount.Text = '0'
		amount.TextXAlignment = Enum.TextXAlignment.Right
		amount.Parent = button
		local items = Instance.fromExisting(title)
		items.Position = UDim2.fromOffset(35, 21)
		items.Text = 'None'
		items.TextColor3 = color.Dark(uipallet.Text, 0.43)
		items.TextSize = 11
		items.Parent = button
		addCorner(button, UDim.new(0, 4))
		local textlistwindow = Instance.new('TextButton')
		textlistwindow.AutoButtonColor = false
		textlistwindow.BackgroundColor3 = uipallet.Main
		textlistwindow.BorderSizePixel = 0
		textlistwindow.Position = UDim2.fromOffset(456, 227)
		textlistwindow.Size = UDim2.fromOffset(220, 85)
		textlistwindow.Text = ''
		textlistwindow.Visible = false
		textlistwindow.Parent = api.Legit and vape.Legit.Window or clickgui
		component.Window = textlistwindow
		addBlur(textlistwindow)
		addCorner(textlistwindow)
		local icon = Instance.new('ImageLabel')
		icon.BackgroundTransparency = 1
		icon.Image = getvapeasset('newvape/assets/new/allowedicon.png')
		icon.Position = UDim2.fromOffset(10, 13)
		icon.Size = UDim2.fromOffset(19, 16)
		icon.Parent = textlistwindow
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(36, 11)
		title.Size = UDim2.new(1, -36, 0, 20)
		title.Text = props.Name
		title.TextColor3 = uipallet.Text
		title.TextSize = 13
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = textlistwindow
		local close = addCloseButton(textlistwindow)
		local boxholder = Instance.new('Frame')
		boxholder.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		boxholder.Position = UDim2.fromOffset(10, 45)
		boxholder.Size = UDim2.fromOffset(200, 31)
		boxholder.Parent = textlistwindow
		addCorner(boxholder)
		local boxinner = Instance.new('Frame')
		boxinner.BackgroundColor3 = color.Dark(uipallet.Main, 0.02)
		boxinner.Position = UDim2.fromOffset(1, 1)
		boxinner.Size = UDim2.new(1, -2, 1, -2)
		boxinner.Parent = boxholder
		addCorner(boxinner)
		local textbox = Instance.new('TextBox')
		textbox.BackgroundTransparency = 1
		textbox.ClearTextOnFocus = false
		textbox.FontFace = uipallet.Font
		textbox.PlaceholderText = props.Placeholder or 'Add entry...'
		textbox.PlaceholderColor3 = Color3.new(0.8, 0.8, 0.8)
		textbox.Position = UDim2.fromOffset(10, 0)
		textbox.Size = UDim2.new(1, -35, 1, 0)
		textbox.Text = ''
		textbox.TextColor3 = Color3.new(1, 1, 1)
		textbox.TextSize = 13
		textbox.TextXAlignment = Enum.TextXAlignment.Left
		textbox.Parent = boxholder
		local add = Instance.new('ImageButton')
		add.BackgroundTransparency = 1
		add.Image = getvapeasset('newvape/assets/new/add.png')
		add.ImageColor3 = props.Color
		add.ImageTransparency = 0.3
		add.Position = UDim2.new(1, -26, 0, 8)
		add.Size = UDim2.fromOffset(16, 16)
		add.Parent = boxholder
		props.Function = props.Function or function() end
		
		function component:Color(hue, sat, val, isRainbow)
			if textlistwindow.Visible then
				holder.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		end
		
		function component:ChangeValue(value)
			if value then
				local index = table.find(self.List, value)
				if index then
					table.remove(self.List, index)
		
					index = table.find(self.ListEnabled, value)
					if index then
						table.remove(self.ListEnabled, index)
					end
				else
					table.insert(self.List, value)
					table.insert(self.ListEnabled, value)
				end
			end
		
			props.Function(self.List)
			for _, v in self.Objects do
				v:Destroy()
			end
			table.clear(self.Objects)
			textlistwindow.Size = UDim2.fromOffset(220, 85 + (#self.List * 35))
			amount.Text = #self.List
			items.Text = #self.ListEnabled > 0 and table.concat(self.ListEnabled, ', ') or 'None'
		
			for index, value in self.List do
				local isEnabled = table.find(self.ListEnabled, value)
				local obj = Instance.new('TextButton')
				obj.AutoButtonColor = false
				obj.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
				obj.Position = UDim2.fromOffset(10, 47 + (index * 35))
				obj.Size = UDim2.fromOffset(200, 31)
				obj.Text = ''
				obj.Parent = textlistwindow
				addCorner(obj)
				local bkg = Instance.new('Frame')
				bkg.BackgroundColor3 = uipallet.Main
				bkg.Position = UDim2.fromOffset(1, 1)
				bkg.Size = UDim2.new(1, -2, 1, -2)
				bkg.Visible = false
				bkg.Parent = obj
				addCorner(bkg)
				local dot = Instance.new('Frame')
				dot.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.37)
				dot.Position = UDim2.fromOffset(10, 12)
				dot.Size = UDim2.fromOffset(10, 11)
				dot.Parent = obj
				addCorner(dot, UDim.new(1, 0))
				local dotin = dot:Clone()
				dotin.BackgroundColor3 = isEnabled and props.Color or color.Light(uipallet.Main, 0.02)
				dotin.Position = UDim2.fromOffset(1, 1)
				dotin.Size = UDim2.fromOffset(8, 9)
				dotin.Parent = dot
				local label = Instance.new('TextLabel')
				label.BackgroundTransparency = 1
				label.FontFace = uipallet.Font
				label.Position = UDim2.fromOffset(30, 0)
				label.Size = UDim2.new(1, -30, 1, 0)
				label.Text = value
				label.TextColor3 = color.Dark(uipallet.Text, 0.16)
				label.TextSize = 15
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = obj
				local close = Instance.new('ImageButton')
				close.AutoButtonColor = false
				close.BackgroundColor3 = Color3.new(1, 1, 1)
				close.BackgroundTransparency = 1
				close.Image = getvapeasset('newvape/assets/new/closetiny.png')
				close.ImageColor3 = color.Light(uipallet.Text, 0.2)
				close.ImageTransparency = 0.5
				close.Position = UDim2.new(1, -27, 0, 8)
				close.Size = UDim2.fromOffset(18, 17)
				close.Parent = obj
				addCorner(close, UDim.new(1, 0))
		
				close.MouseEnter:Connect(function()
					close.ImageTransparency = 0.3
					tween:Tween(close, uipallet.Tween, {
						BackgroundTransparency = 0.6
					})
				end)
		
				close.MouseLeave:Connect(function()
					close.ImageTransparency = 0.5
					tween:Tween(close, uipallet.Tween, {
						BackgroundTransparency = 1
					})
				end)
		
				close.MouseButton1Click:Connect(function()
					self:ChangeValue(value)
				end)
		
				obj.MouseEnter:Connect(function()
					bkg.Visible = true
				end)
		
				obj.MouseLeave:Connect(function()
					bkg.Visible = false
				end)
		
				obj.MouseButton1Click:Connect(function()
					local index = table.find(self.ListEnabled, value)
					if index then
						table.remove(self.ListEnabled, index)
						dot.BackgroundColor3 = color.Light(uipallet.Main, 0.37)
						dotin.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
					else
						table.insert(self.ListEnabled, value)
						dot.BackgroundColor3 = props.Color
						dotin.BackgroundColor3 = props.Color
					end
		
					items.Text = #self.ListEnabled > 0 and table.concat(self.ListEnabled, ', ') or 'None'
					props.Function(self.List)
				end)
		
				table.insert(self.Objects, obj)
			end
		end
		
		function component:Load(data)
			self.List = data.List or {}
			self.ListEnabled = data.ListEnabled or {}
			self:ChangeValue()
		end
		
		function component:Save(data)
			data[props.Name] = {
				List = self.List,
				ListEnabled = self.ListEnabled
			}
		end
		
		add.MouseEnter:Connect(function()
			add.ImageTransparency = 0
		end)
		
		add.MouseLeave:Connect(function()
			add.ImageTransparency = 0.3
		end)
		
		add.MouseButton1Click:Connect(function()
			local newText = props.TextFunction and props.TextFunction(textbox.Text) or textbox.Text
			if not table.find(component.List, newText) then
				component:ChangeValue(newText)
				textbox.Text = ''
			end
		end)
		
		textbox.FocusLost:Connect(function(enter)
			local newText = props.TextFunction and props.TextFunction(textbox.Text) or textbox.Text
			if enter and not table.find(component.List, newText) then
				component:ChangeValue(newText)
				textbox.Text = ''
			end
		end)
		
		textbox.MouseEnter:Connect(function()
			tween:Tween(boxholder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.14)
			})
		end)
		
		textbox.MouseLeave:Connect(function()
			tween:Tween(boxholder, uipallet.Tween, {
				BackgroundColor3 = color.Light(uipallet.Main, 0.02)
			})
		end)
		
		close.MouseButton1Click:Connect(function()
			textlistwindow.Visible = false
		end)
		
		button.MouseButton1Click:Connect(function()
			textlistwindow.Visible = not textlistwindow.Visible
		
			tween:Cancel(holder)
			holder.BackgroundColor3 = textlistwindow.Visible and Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value) or color.Light(uipallet.Main, 0.37)
		end)
		
		textlist.MouseEnter:Connect(function()
			if not textlistwindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.37)
				})
			end
		end)
		
		textlist.MouseLeave:Connect(function()
			if not textlistwindow.Visible then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.034)
				})
			end
		end)
		
		textlist:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		
			local actualPosition = (textlist.AbsolutePosition - (api.Legit and vape.Legit.Window.AbsolutePosition or -guiService:GetGuiInset())) / scale.Scale
			textlistwindow.Position = UDim2.fromOffset(actualPosition.X + 223, actualPosition.Y)
		end)
		
		if props.Default then
			component:ChangeValue()
		end
		
		api.Options[props.Name] = component
		
		return component
	end,
	Toggle = function(props, children, api)
		local component = {
			Enabled = false,
			Index = getTableSize(api.Options),
			Name = props.Name,
			Type = 'Toggle'
		}
		
		local isHover = false
		local toggle = Instance.new('TextButton')
		toggle.AutoButtonColor = false
		toggle.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		toggle.BorderSizePixel = 0
		toggle.FontFace = uipallet.Font
		toggle.Size = UDim2.new(1, 0, 0, 30)
		toggle.Text = '          '..props.Name
		toggle.TextColor3 = color.Dark(uipallet.Text, 0.16)
		toggle.TextSize = 14
		toggle.TextXAlignment = Enum.TextXAlignment.Left
		toggle.Visible = props.Visible == nil or props.Visible
		toggle.Parent = children
		component.Object = toggle
		addTooltip(toggle, props.Tooltip)
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.14)
		holder.Name = 'Holder'
		holder.Position = UDim2.new(1, -30, 0, 9)
		holder.Size = UDim2.fromOffset(22, 12)
		holder.Parent = toggle
		addCorner(holder, UDim.new(1, 0))
		local knob = Instance.new('Frame')
		knob.BackgroundColor3 = uipallet.Main
		knob.Position = UDim2.fromOffset(2, 2)
		knob.Size = UDim2.fromOffset(8, 8)
		knob.Parent = holder
		addCorner(knob, UDim.new(1, 0))
		props.Function = props.Function or function() end
		
		function component:Color(hue, sat, val, isRainbow)
			if self.Enabled then
				tween:Cancel(holder)
				holder.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			end
		end
		
		function component:Load(data)
			if self.Enabled ~= data.Enabled then
				self:Toggle()
			end
		
			if self.Bind and data.Bind then
				self.Bind:Load(data.Bind)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				Enabled = self.Enabled
			}
		
			if self.Bind then
				self.Bind:Save(data[props.Name])
			end
		end
		
		function component:Toggle()
			local isRainbow = vape.GUIColor.Rainbow and vape.RainbowMode.Value ~= 'Retro'
			self.Enabled = not self.Enabled
		
			tween:Tween(holder, uipallet.Tween, {
				BackgroundColor3 = self.Enabled and (isRainbow and Color3.fromHSV(vape:Color((vape.GUIColor.Hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)) or (isHover and color.Light(uipallet.Main, 0.37) or color.Light(uipallet.Main, 0.14))
			})
		
			tween:Tween(knob, uipallet.Tween, {
				Position = UDim2.fromOffset(self.Enabled and 12 or 2, 2)
			})
		
			props.Function(self.Enabled)
		end
		
		toggle.MouseEnter:Connect(function()
			isHover = true
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.37)
				})
			end
		end)
		
		toggle.MouseLeave:Connect(function()
			isHover = false
		
			if not component.Enabled then
				tween:Tween(holder, uipallet.Tween, {
					BackgroundColor3 = color.Light(uipallet.Main, 0.14)
				})
			end
		end)
		
		toggle.MouseButton1Click:Connect(function()
			component:Toggle()
		end)
		
		if props.Default then
			component:Toggle()
		end
		
		api.Options[props.Name] = component
		
		return component
	end,
	TwoSlider = function(props, children, api)
		local component = {
			Index = getTableSize(api.Options),
			Max = props.Max,
			Type = 'TwoSlider',
			ValueMin = props.DefaultMin or props.Min,
			ValueMax = props.DefaultMax or 10
		}
		
		local twoslider = Instance.new('TextButton')
		twoslider.AutoButtonColor = false
		twoslider.BackgroundColor3 = color.Dark(children.BackgroundColor3, props.Darker and 0.02 or 0)
		twoslider.BorderSizePixel = 0
		twoslider.Size = UDim2.new(1, 0, 0, 50)
		twoslider.Text = ''
		twoslider.Visible = props.Visible == nil or props.Visible
		twoslider.Parent = children
		component.Object = twoslider
		addTooltip(twoslider, props.Tooltip)
		local title = Instance.new('TextLabel')
		title.BackgroundTransparency = 1
		title.FontFace = uipallet.Font
		title.Position = UDim2.fromOffset(10, 2)
		title.Size = UDim2.fromOffset(60, 30)
		title.Text = props.Name
		title.TextColor3 = color.Dark(uipallet.Text, 0.16)
		title.TextSize = 11
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Parent = twoslider
		local maxvalue = Instance.new('TextButton')
		maxvalue.BackgroundTransparency = 1
		maxvalue.FontFace = uipallet.Font
		maxvalue.Position = UDim2.new(1, -69, 0, 9)
		maxvalue.Size = UDim2.fromOffset(60, 15)
		maxvalue.Text = component.ValueMax
		maxvalue.TextColor3 = color.Dark(uipallet.Text, 0.16)
		maxvalue.TextSize = 11
		maxvalue.TextXAlignment = Enum.TextXAlignment.Right
		maxvalue.Parent = twoslider
		local minvalue = maxvalue:Clone()
		minvalue.Position = UDim2.new(1, -125, 0, 9)
		minvalue.Text = component.ValueMin
		minvalue.Parent = twoslider
		local custommax = Instance.new('TextBox')
		custommax.BackgroundTransparency = 1
		custommax.ClearTextOnFocus = false
		custommax.FontFace = uipallet.Font
		custommax.Position = maxvalue.Position
		custommax.Size = UDim2.fromOffset(60, 15)
		custommax.Text = component.ValueMax
		custommax.TextColor3 = color.Dark(uipallet.Text, 0.16)
		custommax.TextSize = 11
		custommax.TextXAlignment = Enum.TextXAlignment.Right
		custommax.Visible = false
		custommax.Parent = twoslider
		local custommin = custommax:Clone()
		custommin.Position = minvalue.Position
		custommin.Parent = twoslider
		local holder = Instance.new('Frame')
		holder.BackgroundColor3 = color.Light(uipallet.Main, 0.034)
		holder.BorderSizePixel = 0
		holder.Position = UDim2.fromOffset(10, 37)
		holder.Size = UDim2.new(1, -20, 0, 2)
		holder.Parent = twoslider
		local fill = Instance.new('Frame')
		fill.BackgroundColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
		fill.BorderSizePixel = 0
		fill.Position = UDim2.fromScale(math.clamp(component.ValueMin / props.Max, 0.04, 0.96), 0)
		fill.Size = UDim2.fromScale(math.clamp(math.clamp(component.ValueMax / props.Max, 0, 1), 0.04, 0.96) - fill.Position.X.Scale, 1)
		fill.Parent = holder
		local knob = Instance.new('Frame')
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = twoslider.BackgroundColor3
		knob.BorderSizePixel = 0
		knob.Position = UDim2.fromScale(0, 0.5)
		knob.Size = UDim2.fromOffset(16, 4)
		knob.Parent = fill
		local knobknob = Instance.new('ImageLabel')
		knobknob.AnchorPoint = Vector2.new(0.5, 0.5)
		knobknob.BackgroundTransparency = 1
		knobknob.Image = getvapeasset('newvape/assets/new/range.png')
		knobknob.ImageColor3 = Color3.fromHSV(vape.GUIColor.Hue, vape.GUIColor.Sat, vape.GUIColor.Value)
		knobknob.Position = UDim2.fromScale(0.5, 0.5)
		knobknob.Size = UDim2.fromOffset(9, 16)
		knobknob.Parent = knob
		local knobmax = knob:Clone()
		knobmax.Position = UDim2.fromScale(1, 0.5)
		knobmax.Parent = fill
		local knobmaxknob = knobmax.ImageLabel
		knobmaxknob.Rotation = 180
		local arrow = Instance.new('ImageLabel')
		arrow.BackgroundTransparency = 1
		arrow.Image = getvapeasset('newvape/assets/new/rangeindicator.png')
		arrow.ImageColor3 = color.Light(uipallet.Main, 0.14)
		arrow.Position = UDim2.new(1, -56, 0, 10)
		arrow.Size = UDim2.fromOffset(12, 6)
		arrow.Parent = twoslider
		props.Function = props.Function or function() end
		props.Decimal = props.Decimal or 1
		local random = Random.new()
		
		function component:Color(hue, sat, val, isRainbow)
			fill.BackgroundColor3 = isRainbow and Color3.fromHSV(vape:Color((hue - (self.Index * 0.075)) % 1)) or Color3.fromHSV(hue, sat, val)
			knobknob.ImageColor3 = fill.BackgroundColor3
			knobmaxknob.ImageColor3 = fill.BackgroundColor3
		end
		
		function component:GetRandomValue()
			return random:NextNumber(component.ValueMin, component.ValueMax)
		end
		
		function component:Load(data)
			if self.ValueMin ~= data.ValueMin then
				self:SetValue(false, data.ValueMin)
			end
		
			if self.ValueMax ~= data.ValueMax then
				self:SetValue(true, data.ValueMax)
			end
		end
		
		function component:Save(data)
			data[props.Name] = {
				ValueMin = self.ValueMin,
				ValueMax = self.ValueMax
			}
		end
		
		function component:SetValue(isMax, value)
			if not math.isfinite(value) then
				return
			end
		
			self[isMax and 'ValueMax' or 'ValueMin'] = value
			maxvalue.Text = self.ValueMax
			minvalue.Text = self.ValueMin
		
			local size = math.clamp(math.clamp(self.ValueMin / props.Max, 0, 1), 0.04, 0.96)
			tween:Tween(fill, TweenInfo.new(0.1), {
				Position = UDim2.fromScale(size, 0),
				Size = UDim2.fromScale(math.clamp(math.clamp(self.ValueMax / props.Max, 0.04, 0.96) - size, 0, 1), 1)
			})
		end
		
		knob.MouseEnter:Connect(function()
			tween:Tween(knobknob, uipallet.Tween, {
				Size = UDim2.fromOffset(11, 18)
			})
		end)
		
		knob.MouseLeave:Connect(function()
			tween:Tween(knobknob, uipallet.Tween, {
				Size = UDim2.fromOffset(9, 16)
			})
		end)
		
		knobmax.MouseEnter:Connect(function()
			tween:Tween(knobmaxknob, uipallet.Tween, {
				Size = UDim2.fromOffset(11, 18)
			})
		end)
		
		knobmax.MouseLeave:Connect(function()
			tween:Tween(knobmaxknob, uipallet.Tween, {
				Size = UDim2.fromOffset(9, 16)
			})
		end)
		
		twoslider.InputBegan:Connect(function(input)
			if
				(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
				and (input.Position.Y - twoslider.AbsolutePosition.Y) > (20 * scale.Scale)
			then
				local maxCheck = (input.Position.X - knobmax.AbsolutePosition.X) > -10
				local newPosition = math.clamp((input.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
		
				local releaseConnection
				local moveConnection = inputService.InputChanged:Connect(function(newInput)
					if newInput.UserInputType == (input.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
						local newPosition = math.clamp((newInput.Position.X - holder.AbsolutePosition.X) / holder.AbsoluteSize.X, 0, 1)
						component:SetValue(maxCheck, math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition)
					end
				end)
		
				releaseConnection = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						moveConnection:Disconnect()
						releaseConnection:Disconnect()
					end
				end)
		
				component:SetValue(maxCheck, math.floor((props.Min + (props.Max - props.Min) * newPosition) * props.Decimal) / props.Decimal, newPosition)
			end
		end)
		
		maxvalue.MouseButton1Click:Connect(function()
			maxvalue.Visible = false
			custommax.Visible = true
			custommax.Text = component.ValueMax
			custommax:CaptureFocus()
		end)
		
		minvalue.MouseButton1Click:Connect(function()
			minvalue.Visible = false
			custommin.Visible = true
			custommin.Text = component.ValueMin
			custommin:CaptureFocus()
		end)
		
		custommax.FocusLost:Connect(function(enter)
			maxvalue.Visible = true
			custommax.Visible = false
		
			if enter and tonumber(custommax.Text) then
				component:SetValue(true, tonumber(custommax.Text))
			end
		end)
		
		custommin.FocusLost:Connect(function(enter)
			minvalue.Visible = true
			custommin.Visible = false
		
			if enter and tonumber(custommin.Text) then
				component:SetValue(false, tonumber(custommin.Text))
			end
		end)
		
		api.Options[props.Name] = component
		
		return component
	end,
}

vape.Components = setmetatable(components, {
	__newindex = function(_, index, callback)
		for _, module in vape.Modules do
			rawset(module, 'Create'..index, function(_, props)
				return callback(props, module.Children, module)
			end)
		end

		if vape.Legit then
			for _, module in vape.Legit.Modules do
				rawset(module, 'Create'..index, function(_, props)
					return callback(props, module.Children, module)
				end)
			end
		end

		rawset(components, index, callback)
	end
})

vape:LoadGUI()

return vape