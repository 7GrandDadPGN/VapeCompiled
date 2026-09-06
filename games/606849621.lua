local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert') end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function() return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/VapeCompiled/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true) end)
		if not suc or res == '404: Not Found' then error(res) end
		if path:find('.lua') then res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res end
		writefile(path, res)
	end
	return (func or readfile)(path)
end
local run = function(func)
	func()
end
local cloneref = cloneref or function(obj)
	return obj
end
local vapeEvents = setmetatable({}, {
	__index = function(self, index)
		self[index] = Instance.new('BindableEvent')
		return self[index]
	end
})

local playersService = cloneref(game:GetService('Players'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local runService = cloneref(game:GetService('RunService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local tweenService = cloneref(game:GetService('TweenService'))
local collectionService = cloneref(game:GetService('CollectionService'))
local contextService = cloneref(game:GetService('ContextActionService'))
local httpService = cloneref(game:GetService('HttpService'))
local teams = cloneref(game:GetService('Teams'))

local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer

local vape = shared.vape
local entitylib = vape.Libraries.entity
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local vm = loadstring(downloadFile('newvape/libraries/vm.lua'), 'vm')()

local jb = {}
local Spring = {}
local InfNitro = {Enabled = false}
local LazerGodmode = {Enabled = false}
local InvTracker = {Inventories = {}, Connections = {}}
local oldBulletUpdate
local aimTimer, shootTimer, aimVec = os.clock(), os.clock()

local function getTableSize(dict)
	local size = 0
	for _ in dict do
		size += 1
	end

	return size
end

local function getVehicle(entity)
	if entity.Player then
		for _, car in collectionService:GetTagged('Vehicle') do
			for _, seat in car:GetChildren() do
				if (seat.Name == 'Seat' or seat.Name == 'Passenger') then
					seat = seat:FindFirstChild('PlayerName')
					if seat and seat.Value == entity.Player.Name then
						return car
					end
				end
			end
		end
	end
end

local function isFriend(plr, recolor)
	if vape.Categories.Friends.Options['Use friends'].Enabled then
		local friend = table.find(vape.Categories.Friends.ListEnabled, plr.Name) and true
		if recolor then
			friend = friend and vape.Categories.Friends.Options['Recolor visuals'].Enabled
		end
		return friend
	end

	return nil
end

local function isIllegal(entity, teamCheck)
	if entity.Character:GetAttribute('HasHandcuffs') then
		return false
	end

	if entity.Player and entity.Player.Team == teams.Prisoner then
		for tool in InvTracker.Inventories[entity.Player] do
			if tool ~= 'MansionInvite' and tool ~= 'Donut' then
				return true
			end
		end

		return entity.InVehicle
	end

	return not teamCheck
end

local function isTarget(plr)
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true
end

local function notif(...)
	return vape:CreateNotification(...)
end

local frictionTable, oldfrict = {}, {}
local function updateVelocity()
	if getTableSize(frictionTable) > 0 then
		if entitylib.isAlive then
			for _, part in entitylib.character.Character:GetChildren() do
				if part:IsA('BasePart') and part.Name ~= 'HumanoidRootPart' and not oldfrict[part] then
					oldfrict[part] = part.CustomPhysicalProperties or 'none'
					part.CustomPhysicalProperties = PhysicalProperties.new(0.0001, 0.2, 0.5, 1, 1)
				end
			end
		end
	else
		for part, data in oldfrict do
			part.CustomPhysicalProperties = data ~= 'none' and data or nil
		end

		table.clear(oldfrict)
	end
end

local OriginScanner = {Cache = {}}
run(function()
	local rayParams = RaycastParams.new()
	local overlapParams = OverlapParams.new()
	rayParams.RespectCanCollide = true
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.RespectCanCollide = true
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	OriginScanner.Ray = rayParams

	local positions = {
		Vector3.new(0, 1, 0),
		Vector3.new(1, 0, 0),
		Vector3.new(0.7, -0.5, -0.5),
		Vector3.new(-0.1, -0.8, -0.8),
		Vector3.new(-0.8, -0.5, -0.5),
		Vector3.new(-1, 0, 0),
		Vector3.new(-0.8, 0.4, 0.4),
		Vector3.new(0, 0.7, 0.7),
		Vector3.new(0.7, 0.5, 0.5),
		Vector3.new(1, 0, 0),
		Vector3.new(0.7, 0, -0.8),
		Vector3.new(-0.1, 0, -1),
		Vector3.new(-0.8, 0, -0.8),
		Vector3.new(-1, 0, 0),
		Vector3.new(-0.8, 0, 0.7),
		Vector3.new(0, 0, 1),
		Vector3.new(0.7, 0, 0.7),
		Vector3.new(1, 0, 0),
		Vector3.new(0.7, 0.4, -0.5),
		Vector3.new(-0.1, 0.7, -0.8),
		Vector3.new(-0.8, 0.4, -0.5),
		Vector3.new(-1, -0.1, 0),
		Vector3.new(-0.8, -0.5, 0.4),
		Vector3.new(0, -0.8, 0.7),
		Vector3.new(0.7, -0.6, 0.5),
		Vector3.new(0, -1, 0)
	}

	local function checkPoint(pos, params)
		for _, part in workspace:GetPartBoundsInRadius(pos, 0, params) do
			if part.CanCollide and (part:GetClosestPointOnSurface(pos) - pos).Magnitude <= 0.0001 then
				return false
			end
		end

		return true
	end

	function OriginScanner:Scan(origin, target, extra, part)
		if self.Cache[part] then
			return table.unpack(self.Cache[part])
		end

		if extra and (origin - extra).Magnitude < 14 then
			self.Cache[part] = {extra}
			return extra
		end

		local scanPositions = {}
		local diff = CFrame.lookAt(origin * Vector3.new(1, 0, 1), target * Vector3.new(1, 0, 1)).LookVector
		for _, offset in positions do
			if (offset * Vector3.new(1, 0, 1)):Dot(diff) > -0.5 then
				local pos = origin + offset * 14

				if checkPoint(pos, overlapParams) then
					table.insert(scanPositions, pos)
				end
			end
		end

		for _, pos in scanPositions do
			local ray = workspace:Raycast(target, (pos - target), rayParams)

			if not ray then
				self.Cache[part] = {pos}
				return pos
			end
		end
	end

	function OriginScanner:UpdateIgnore(data)
		local ignore = {lplr.Character, workspace.Items, unpack(data)}
		for _, entity in entitylib.List do
			table.insert(ignore, entity.Character)
		end

		rayParams.FilterDescendantsInstances = ignore
		overlapParams.FilterDescendantsInstances = ignore
	end
end)

run(function()
	function InvTracker:AddInventory(inventory)
		local plr = inventory.Parent
		if plr and plr:IsA('Player') then
			self.Inventories[plr] = {}
			self.Connections[inventory] = {
				inventory.ChildAdded:Connect(function(tool)
					self.Inventories[plr][tool.Name] = tool

					if plr == lplr then
						vapeEvents.ItemAdded:Fire(tool)
					else
						local entity = entitylib.getEntity(plr)
						if entity then
							entitylib.Events.EntityUpdated:Fire(entity)
						end
					end
				end),
				inventory.ChildRemoved:Connect(function(tool)
					self.Inventories[plr][tool.Name] = nil

					if plr ~= lplr then
						local entity = entitylib.getEntity(plr)
						if entity then
							entitylib.Events.EntityUpdated:Fire(entity)
						end
					end
				end),
				inventory.Destroying:Once(function()
					for _, connection in self.Connections[inventory] do
						connection:Disconnect()
					end

					table.clear(self.Connections[inventory])
					table.clear(self.Inventories[plr])
					self.Inventories[plr] = nil
				end)
			}

			for _, tool in inventory:GetChildren() do
				self.Inventories[plr][tool.Name] = tool
			end
		end
	end

	for _, inventory in collectionService:GetTagged('Inventory') do
		InvTracker:AddInventory(inventory)
	end

	vape:Clean(collectionService:GetInstanceAddedSignal('Inventory'):Connect(function(inventory)
		InvTracker:AddInventory(inventory)
	end))

	vape:Clean(function()
		for _, connections in InvTracker.Connections do
			for _, connection in connections do
				connection:Disconnect()
			end
		end

		table.clear(InvTracker.Connections)
		table.clear(InvTracker.Inventories)
	end)
end)

local BountyTracker = {Data = {}, List = {}}
run(function()
	function BountyTracker:UpdateData(data, update)
		table.clear(self.Data)
		table.clear(self.List)

		for _, entry in data do
			self.Data[entry.Name] = entry.Bounty
			table.insert(self.List, {entry.Name, entry.Bounty})
		end

		table.sort(self.List, function(a, b)
			return a[2] > b[2]
		end)

		if update then
			for _, entity in entitylib.List do
				entitylib.Events.EntityUpdated:Fire(entity)
			end
		end
	end

	BountyTracker:UpdateData(httpService:JSONDecode(replicatedStorage.BountyData.Value))
	vape:Clean(replicatedStorage.BountyData:GetPropertyChangedSignal('Value'):Connect(function()
		BountyTracker:UpdateData(httpService:JSONDecode(replicatedStorage.BountyData.Value), true)
	end))
end)

run(function()
	local function getMousePosition()
		if inputService.TouchEnabled then
			return gameCamera.ViewportSize / 2
		end

		return inputService:GetMouseLocation()
	end

	entitylib.getUpdateConnections = function(entity)
		local hum = entity.Humanoid
		entity.InVehicle = not entity.Character:GetAttribute('HasHandcuffs') and (entity.Character:GetAttribute('InVehicle') or entity.InVehicle)
		entity.Illegal = isIllegal(entity, true)

		return {
			hum:GetPropertyChangedSignal('Health'),
			hum:GetPropertyChangedSignal('MaxHealth'),
			entity.Character:GetAttributeChangedSignal('InVehicle'),
			entity.Character:GetAttributeChangedSignal('HasHandcuffs'),
			{
				Connect = function()
					entity.Friend = entity.Player and isFriend(entity.Player) or nil
					entity.Target = entity.Player and isTarget(entity.Player) or nil
					return {Disconnect = function() end}
				end
			}
		}
	end

	entitylib.targetCheck = function(entity)
		if entity.TeamCheck then return entity:TeamCheck() end
		if entity.NPC then return true end
		if isFriend(entity.Player) then return false end
		if not select(2, whitelist:get(entity.Player)) then return false end

		if lplr.Team == teams.Police then
			return entity.Player.Team ~= teams.Police
		else
			return entity.Player.Team == teams.Police
		end

		return true
	end

	entitylib.EntityMouse = function(entitysettings)
		if entitylib.isAlive then
			local mouseLocation, sortingTable = entitysettings.MouseOrigin or getMousePosition(), {}
			local localPosition = entitysettings.Origin or entitylib.character.HumanoidRootPart.Position
			for _, entity in entitylib.List do
				if not entitysettings.Players and entity.Player then continue end
				if not entitysettings.NPCs and entity.NPC then continue end
				if not entity.Targetable then continue end
				local position, vis = gameCamera.WorldToViewportPoint(gameCamera, entity[entitysettings.Part].Position)
				if not vis then continue end
				local mag = (mouseLocation - Vector2.new(position.x, position.y)).Magnitude
				if mag > entitysettings.Range then continue end
				if entitylib.isVulnerable(entity, entitysettings.AttackCheck) then
					if entitysettings.RangePosition then
						local pmag = (entity[entitysettings.Part].Position - localPosition).Magnitude
						if pmag > entitysettings.RangePosition then continue end
					end

					table.insert(sortingTable, {
						Entity = entity,
						Magnitude = entity.Target and -1 or mag
					})
				end
			end

			table.sort(sortingTable, entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end)

			for _, v in sortingTable do
				if entitysettings.Wallcheck then
					if entitylib.Wallcheck(entitysettings.Origin, v.Entity[entitysettings.Part].Position, entitysettings.Wallbang, v.Entity[entitysettings.Part]) then continue end
				end
				table.clear(entitysettings)
				table.clear(sortingTable)
				return v.Entity
			end
			table.clear(sortingTable)
		end
		table.clear(entitysettings)
	end

	entitylib.EntityPosition = function(entitysettings)
		if entitylib.isAlive then
			local localPosition, sortingTable = entitysettings.Origin or entitylib.character.HumanoidRootPart.Position, {}
			for _, entity in entitylib.List do
				if not entitysettings.Players and entity.Player then continue end
				if not entitysettings.NPCs and entity.NPC then continue end
				if not entity.Targetable then continue end
				local mag = (entity[entitysettings.Part].Position - localPosition).Magnitude
				if mag > entitysettings.Range then continue end
				if entitylib.isVulnerable(entity, entitysettings.AttackCheck) then
					table.insert(sortingTable, {
						Entity = entity,
						Magnitude = entity.Target and -1 or mag
					})
				end
			end

			table.sort(sortingTable, entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end)

			for _, v in sortingTable do
				if entitysettings.Wallcheck then
					if entitylib.Wallcheck(localPosition, v.Entity[entitysettings.Part].Position, entitysettings.Wallbang, v.Entity[entitysettings.Part]) then continue end
				end
				table.clear(entitysettings)
				table.clear(sortingTable)
				return v.Entity
			end
			table.clear(sortingTable)
		end
		table.clear(entitysettings)
	end

	entitylib.AllPosition = function(entitysettings)
		local returned = {}
		if entitylib.isAlive then
			local localPosition, sortingTable = entitysettings.Origin or entitylib.character.HumanoidRootPart.Position, {}
			for _, entity in entitylib.List do
				if not entitysettings.Players and entity.Player then continue end
				if not entitysettings.NPCs and entity.NPC then continue end
				if not entity.Targetable then continue end
				local mag = (entity[entitysettings.Part].Position - localPosition).Magnitude
				if mag > entitysettings.Range then continue end
				if entitylib.isVulnerable(entity, entitysettings.AttackCheck) then
					table.insert(sortingTable, {
						Entity = entity,
						Magnitude = entity.Target and -1 or mag
					})
				end
			end

			table.sort(sortingTable, entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end)

			for _, v in sortingTable do
				if entitysettings.Wallcheck then
					if entitylib.Wallcheck(localPosition, v.Entity[entitysettings.Part].Position, entitysettings.Wallbang, v.Entity[entitysettings.Part]) then continue end
				end
				table.insert(returned, v.Entity)
				if #returned >= (entitysettings.Limit or math.huge) then break end
			end
			table.clear(sortingTable)
		end
		table.clear(entitysettings)
		return returned
	end

	entitylib.Wallcheck = function(origin, position, checkpos, part)
		local ray = workspace.Raycast(workspace, position, (origin - position), OriginScanner.Ray)
		if ray then
			return not checkpos or not OriginScanner:Scan(checkpos, position, ray.Position + ray.Normal * 0.01, part)
		end

		return false
	end
end)
entitylib.start()

run(function()
	local function dumpRemotes(scripts, renamed)
		local returned = {}

		for _, scr in scripts do
			local deserializedcode = vm.luau_deserialize(getscriptbytecode(scr))

			for _, proto in deserializedcode.protoList do
				local stack, top, code = {}, -1, proto.code
				for i, inst in code do
					if inst.opcode == 4 then -- LOADN
						stack[inst.A] = inst.D
					elseif inst.opcode == 5 then -- LOADK
						stack[inst.A] = inst.K
					elseif inst.opcode == 6 then -- MOVE
						stack[inst.A] = stack[inst.B]
					elseif inst.opcode == 12 then -- GETIMPORT
						local count, import = inst.KC, getrenv()[inst.K0]

						if count == 1 then
							stack[inst.A] = import
						elseif count == 2 then
							stack[inst.A] = import[inst.K1]
						elseif count == 3 then
							stack[inst.A] = import[inst.K1][inst.K2]
						end
					elseif inst.opcode == 20 then -- NAMECALL
						local A, B, kv = inst.A, inst.B, inst.K
						stack[A + 1] = stack[B]

						local callInst = code[i + 2]
						local callA, callB, callC = callInst.A, callInst.B, callInst.C
						local params = if callB == 0 then top - callA else callB - 1
						if kv == 'sub' or kv == 'reverse' then
							local arg1, arg2, arg3 = table.unpack(stack, callA + 1, callA + params)
							if kv == 'reverse' and not arg1 then arg1 = 'a' end

							local ret_list = table.pack(string[kv](arg1, arg2, arg3))
							local ret_num = ret_list.n - 1
							if callC == 0 then
								top = callA + ret_num - 1
							else
								ret_num = callC - 1
							end

							table.move(ret_list, 1, ret_num, callA, stack)
						elseif kv == 'FireServer' then
							local name, val = proto.debugname == '(??)' and scr.Name or proto.debugname, stack[callA + 2]
							if name == val then table.insert(returned, val) continue end
							if returned[name] then
								for i = 1, 10 do
									if not returned[name..i] then name ..= i break end
								end
							end

							returned[name] = val
						end
					elseif inst.opcode == 49 then -- CONCAT
						local s = ""
						for i = inst.B, inst.C do
							if type(stack[i]) ~= 'string' then continue end
							s ..= stack[i]
						end
						stack[inst.A] = s
					end
				end
			end
		end

		for i, v in table.clone(returned) do
			if renamed[i] then
				returned[i] = nil
				returned[renamed[i]] = v
			end
		end

		return returned
	end

	local function getAwardEvent()
		for _, callback in debug.getupvalue(jb.TeamChooseController.Init, 2) do
			if type(callback) == 'function' then
				for _, const in debug.getconstants(callback) do
					if tostring(const):find('PlusCash') then
						return callback
					end
				end
			end
		end
	end

	local function toMoney(num)
		local one, two, three = string.match(tostring(num), '^([^%d]*%d)(%d*)(.-)$')
		return one .. (two:reverse():gsub('(%d%d%d)', '%1,'):reverse() .. three)..'$'
	end

	jb = {
		AlexChassis = require(replicatedStorage.Module.AlexChassis),
		Audio = require(replicatedStorage.Std.Audio),
		BulletEmitter = require(replicatedStorage.Game.ItemSystem.BulletEmitter),
		CircleAction = require(replicatedStorage.Module.UI).CircleAction,
		FallingController = require(replicatedStorage.Game.Falling),
		GunController = require(replicatedStorage.Game.Item.Gun),
		GunUtils = require(replicatedStorage.Game.GunShop.GunUtils),
		InventoryItemBinder = require(replicatedStorage.Inventory.InventoryItemBinder),
		InventoryItemSystem = require(replicatedStorage.Inventory.InventoryItemSystem),
		ItemSystemController = require(replicatedStorage.Game.ItemSystem.ItemSystem),
		LightningUtils = require(replicatedStorage.Game.LightningUtils),
		PlayerUtils = require(replicatedStorage.Game.PlayerUtils),
		TeamChooseController = require(replicatedStorage.TeamSelect.TeamChooseUI),
		VehicleController = require(replicatedStorage.Vehicle.VehicleUtils),
		VehicleSystem = require(replicatedStorage.Game.VehicleSystem)
	}

	if not jb.VehicleController.toggleLocalLocked or not jb.VehicleController.NitroShopVisible then
		repeat
			task.wait()
		until (jb.VehicleController.toggleLocalLocked and jb.VehicleController.NitroShopVisible) or vape.Loaded == nil

		if vape.Loaded == nil then
			return
		end
	end

	local remotetable = debug.getupvalue(jb.VehicleController.toggleLocalLocked, 2)
	local fireserver, hook = remotetable.FireServer

	remotes = dumpRemotes({
		replicatedStorage.Game.TrainSystem.LocomotiveFront,
		replicatedStorage.Game.ItemSystem.ItemSystem,
		replicatedStorage.Game.CashBuyUI,
		replicatedStorage.Game.GunShop.GunShopUI,
		replicatedStorage.Game.Item.Taser,
		replicatedStorage.Game.Item.Donut,
		replicatedStorage.Game.Item.Gun,
		replicatedStorage.Game.Falling,
		lplr.PlayerScripts.LocalScript
	}, {
		Action3 = 'Pickup',
		AttemptArrest = 'Arrest',
		attemptPunch = 'Punch',
		AttemptPickPocket = 'Pickpocket',
		AttemptVehicleEject = 'Eject',
		AttemptVehicleEnter = 'GetIn',
		BroadcastInputBegan = 'InputBegan',
		BroadcastInputEnded = 'InputEnded',
		CalculateDelta = 'UseNitro',
		Draw = 'TaseReplicate',
		Gun = 'PopTires',
		GunShopUI = 'UnequipItem',
		GunShopUI1 = 'EquipItem',
		LocalScript2 = 'LookAngle',
		LocalScript = 'SelfDamage',
		onPressed = 'FlipVehicle',
		OnJump = 'GetOut',
		OnJump1 = 'GetOut',
		UpdateMousePosition = 'AimPosition'
	})

	local function FireServerHook(...)
		local self, id = ...
		local remote
		for name, key in remotes do
			if key == id then
				remote = name
			end
		end

		if InfNitro.Enabled and remote == 'UseNitro' then return end
		if LazerGodmode.Enabled and remote == 'SelfDamage' then return end
		if remote ~= 'LookAngle' and remote ~= 'AimPosition' and shared.VapeDeveloper then
			local called = getfenv(3)
			called = called and called.script
			if called and (not remote) then
				print(id, 'called with', called:GetFullName())
			end

			print(id, remote or id, ...)
		end

		return hook(...)
	end

	hook = hookfunction(fireserver, function(...)
		return FireServerHook(...)
	end)

	function jb:FireServer(id, ...)
		if not remotes[id] then
			notif('Vape', 'Failed to find remote ('..id..')', 10, 'alert')
			return
		end

		return hook(remotetable, remotes[id], ...)
	end

	local arrests = sessioninfo:AddItem('Arrested')
	local moneymade = sessioninfo:AddItem('Money Made', 0, toMoney, true)
	local bounty = sessioninfo:AddItem('Bounty List', '', function()
		local text = ''

		for _, data in BountyTracker.List do
			text = text..'\n'..data[1]..': '..toMoney(tostring(data[2]))
		end

		return text
	end, false)

	local awardCallback = getAwardEvent()
	if awardCallback then
		local hook
		hook = hookfunction(awardCallback, function(amount, text, ...)
			moneymade:Increment(amount)
			if text == 'Arrest' then
				arrests:Increment()
			end

			return hook(amount, text, ...)
		end)

		vape:Clean(function()
			restorefunction(awardCallback)
		end)
	end

	for _, connection in getconnections(runService.Heartbeat) do
		if connection.Function and islclosure(connection.Function) and #debug.getupvalues(connection.Function) > 5 then
			local upval = debug.getupvalue(connection.Function, 6)
			if type(upval) == 'function' and debug.info(upval, 'n') == 'WalkSpeedFun' then
				jb.WalkSpeedFun = upval
				break
			end
		end
	end

	table.insert(whitelist.tagcallback, function(plr, plrtag, rich)
		if plr then
			local entity = entitylib.getEntity(plr)
			if entity then
				if plr.Team == teams.Prisoner and entity.Illegal then
					table.insert(plrtag, {text = rich and '💢' or 'Hostile'})
				end

				if BountyTracker.Data[plr.Name] then
					table.insert(plrtag, {
						text = toMoney(tostring(BountyTracker.Data[plr.Name])),
						color = Color3.fromHSV(0.4, 0.89, 0.75)
					})
				end
			end
		end
	end)

	vape:Clean(runService.RenderStepped:Connect(function()
		table.clear(OriginScanner.Cache)
	end))

	vape:Clean(entitylib.Events.EntityUpdated:Connect(function(entity)
		local isInVehicle = entity.Character:GetAttribute('InVehicle')
		if entity.VehicleState ~= isInVehicle and not isInVehicle then
			entity.VehicleTimer = os.clock() + 0.3
		end

		entity.VehicleState = isInVehicle
		entity.InVehicle = not entity.Character:GetAttribute('HasHandcuffs') and (isInVehicle or entity.InVehicle)
		entity.Illegal = isIllegal(entity, true)

		if entity.Player and entity.Player.Team == teams.Prisoner then
			entity.Pickpocket = nil
		end
	end))

	vape:Clean(entitylib.Events.LocalAdded:Connect(updateVelocity))

	vape:Clean(function()
		table.clear(remotes)
		table.clear(jb)
		restorefunction(fireserver)
	end)
end)

run(function()
	-- https://github.com/J1ck/roblox-spring/blob/main/src/roblox-spring.luau
	Spring.__index = Spring

	function Spring.new(Properties)
		local TypeRefined = Properties or {}

		local self = setmetatable({
			Target = Vector3.new(),
			Position = Vector3.new(),
			Velocity = Vector3.new(),

			Mass = TypeRefined.Mass or 5,
			Force = TypeRefined.Force or 50,
			Damping	= TypeRefined.Damping or 4,
			Speed = TypeRefined.Speed or 4,
		}, Spring)

		return self
	end

	function Spring:Update(DeltaTime)
		local IterationsThisFrame = DeltaTime / ((1 / 60) / 8)
		local ScaledDeltaTime = DeltaTime * self.Speed / IterationsThisFrame

		for i = 1, math.round(IterationsThisFrame) do
			local IterationForce = self.Target - self.Position
			local Acceleration = (IterationForce * self.Force) / self.Mass

			Acceleration -= self.Velocity * self.Damping

			self.Velocity += Acceleration * ScaledDeltaTime
			self.Position += self.Velocity * ScaledDeltaTime
		end

		return self.Position
	end
end)

for _, v in {'Reach', 'TriggerBot', 'Disabler', 'AntiFall', 'HitBoxes', 'Killaura', 'MurderMystery'} do
	vape:Remove(v)
end

run(function()
	local SilentAim
	local Target
	local Mode
	local Range
	local HitChance
	local HeadshotChance
	local Wallbang
	local CircleColor
	local CircleTransparency
	local CircleFilled
	local CircleObject
	local rand = Random.new()
	local old
	local ProjectileRaycast = RaycastParams.new()
	ProjectileRaycast.RespectCanCollide = true
	
	local function getMousePosition()
		if inputService.TouchEnabled then
			return gameCamera.ViewportSize / 2
		end
	
		return inputService:GetMouseLocation()
	end
	
	local function getTarget(origin, limit, attackcheck)
		if rand.NextNumber(rand, 0, 100) > HitChance.Value then
			return
		end
	
		local targetPart = (rand.NextNumber(rand, 0, 100) < HeadshotChance.Value) and 'Head' or 'RootPart'
		local entity = entitylib['Entity'..Mode.Value]({
			Range = Mode.Value == 'Position' and math.min(Range.Value, limit) or Range.Value,
			RangePosition = limit,
			Wallcheck = Target.Walls.Enabled and true or nil,
			Wallbang = Wallbang.Enabled and entitylib.character.RootPart.Position or nil,
			Part = targetPart,
			Origin = origin.Position,
			Players = Target.Players.Enabled,
			NPCs = Target.NPCs.Enabled
		})
	
		if entity then
			targetinfo.Targets[entity] = tick() + 1
		end
	
		return entity, entity and entity[targetPart], origin
	end
	
	local function Hook(...)
		local item = ...
	
		if item.Local then
			OriginScanner:UpdateIgnore(item.BulletEmitter.IgnoreList)
			shootTimer = os.clock() + 0.1
			local entity, targetPart, origin = getTarget(item.Tip.CFrame, (item.Config.BulletSpeed or 1000) * item.BulletEmitter.LifeSpan)
	
			if entity then
				local oldTip
				if Wallbang.Enabled then
					local ray = workspace:Raycast(targetPart.Position, (origin.Position - targetPart.Position), OriginScanner.Ray)
	
					if ray then
						local neworigin, hitbox = OriginScanner:Scan(entitylib.character.RootPart.Position, targetPart.Position, ray.Position + ray.Normal * 0.01, targetPart)
	
						if neworigin then
							oldTip = item.Tip.CFrame
							origin = CFrame.lookAt(neworigin, targetPart.Position)
							item.Tip.CFrame = origin
						end
					end
				end
	
				ProjectileRaycast.FilterDescendantsInstances = {gameCamera, entity.Character, workspace.Vehicles}
				ProjectileRaycast.CollisionGroup = entity.RootPart.CollisionGroup
	
				local trajectory = oldBulletUpdate and targetPart.Position or prediction.SolveTrajectory(origin.Position, item.Config.BulletSpeed or 1000, math.abs(item.BulletEmitter.GravityVector.Y), targetPart.Position, entity.RootPart.AssemblyLinearVelocity, workspace.Gravity, entity.HipHeight, nil, ProjectileRaycast)
				if trajectory then
					targetinfo.Targets[entity] = tick() + 1
					item.TipDirection = CFrame.lookAt(origin.Position, trajectory).LookVector
					aimTimer = os.clock() + 0.3
					aimVec = targetPart.Position
				end
	
				if oldTip then
					local call = table.pack(old(...))
					item.Tip.CFrame = oldTip
					return unpack(call, 1, call.n)
				end
			end
		end
	
		return old(...)
	end
	
	SilentAim = vape.Categories.Combat:CreateModule({
		Name = 'SilentAim',
		Function = function(callback)
			if CircleObject then
				CircleObject.Visible = callback and Mode.Value == 'Mouse'
			end
	
			if Wallbang.Enabled then
				debug.setconstant(jb.GunController.ShootCheckConditions, 1, callback and '_Tip' or 'Tip')
			end
	
			if callback then
				old = hookfunction(jb.GunController.ShootOther, function(...)
					return Hook(...)
				end)
	
				repeat
					if CircleObject then
						CircleObject.Position = getMousePosition()
					end
	
					task.wait()
				until not SilentAim.Enabled
			else
				if old then
					restorefunction(jb.GunController.ShootOther)
					old = nil
				end
			end
		end,
		Tooltip = 'Silently adjusts your aim towards the enemy'
	})
	Target = SilentAim:CreateTargets({
		Players = true
	})
	Mode = SilentAim:CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Position'},
		Function = function(val)
			if CircleObject then
				CircleObject.Visible = SilentAim.Enabled and val == 'Mouse'
			end
		end,
		Tooltip = 'Mouse - Checks for entities near the mouses position\nPosition - Checks for entities near the local character'
	})
	Range = SilentAim:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 1000,
		Default = 150,
		Function = function(val)
			if CircleObject then
				CircleObject.Radius = val
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	HitChance = SilentAim:CreateSlider({
		Name = 'Hit Chance',
		Min = 0,
		Max = 100,
		Default = 85,
		Suffix = '%'
	})
	HeadshotChance = SilentAim:CreateSlider({
		Name = 'Headshot Chance',
		Min = 0,
		Max = 100,
		Default = 65,
		Suffix = '%'
	})
	Wallbang = SilentAim:CreateToggle({
		Name = 'Wallbang',
		Function = function(callback)
			if SilentAim.Enabled then
				debug.setconstant(jb.GunController.ShootCheckConditions, 1, callback and '_Tip' or 'Tip')
			end
		end,
		Tooltip = 'Allow you to shoot people through walls when specific conditions are met.\n(If the entity has a valid hitbox position exposed or if the shoot position can be moved past walls (eg hugging walls))'
	})
	SilentAim:CreateToggle({
		Name = 'Range Circle',
		Function = function(callback)
			if callback then
				CircleObject = Drawing.new('Circle')
				CircleObject.Filled = CircleFilled.Enabled
				CircleObject.Color = Color3.fromHSV(CircleColor.Hue, CircleColor.Sat, CircleColor.Value)
				CircleObject.Position = vape.gui.AbsoluteSize / 2
				CircleObject.Radius = Range.Value
				CircleObject.NumSides = 100
				CircleObject.Transparency = 1 - CircleTransparency.Value
				CircleObject.Visible = SilentAim.Enabled and Mode.Value == 'Mouse'
			else
				pcall(function()
					CircleObject.Visible = false
					CircleObject:Remove()
				end)
			end
			CircleColor.Object.Visible = callback
			CircleTransparency.Object.Visible = callback
			CircleFilled.Object.Visible = callback
		end
	})
	CircleColor = SilentAim:CreateColorSlider({
		Name = 'Circle Color',
		Function = function(hue, sat, val)
			if CircleObject then
				CircleObject.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Darker = true,
		Visible = false
	})
	CircleTransparency = SilentAim:CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 1,
		Decimal = 10,
		Default = 0.5,
		Function = function(val)
			if CircleObject then
				CircleObject.Transparency = 1 - val
			end
		end,
		Darker = true,
		Visible = false
	})
	CircleFilled = SilentAim:CreateToggle({
		Name = 'Circle Filled',
		Function = function(callback)
			if CircleObject then
				CircleObject.Filled = callback
			end
		end,
		Darker = true,
		Visible = false
	})
end)

run(function()
	local Sprint
	
	Sprint = vape.Categories.Combat:CreateModule({
		Name = 'Sprint',
		Function = function(callback)
			if callback then
				repeat
					debug.setupvalue(jb.WalkSpeedFun, 9, true)
					task.wait(0.05)
				until not Sprint.Enabled
			end
		end,
		Tooltip = 'Sets your sprinting to true.'
	})
end)

run(function()
	local AutoArrest
	local Range
	local AutoEquip
	local cooldown = 0
	
	local function equipTool(tool)
		local obj = jb.InventoryItemBinder:Get(tool)
		if obj then
			obj:AttemptSelect()
		end
	end
	
	AutoArrest = vape.Categories.Blatant:CreateModule({
		Name = 'AutoArrest',
		Function = function(callback)
			if callback then
				repeat
					local cuffs = InvTracker.Inventories[lplr].Handcuffs
	
					if entitylib.isAlive and lplr.Team == teams.Police and cuffs then
						local serverPos = entitylib.character.Humanoid:FindFirstChild('HumanoidUnloadServerPosition')
						local target
	
						local entities = entitylib.AllPosition({
							Players = true,
							Part = 'RootPart',
							Range = Range.Value,
							Origin = serverPos and serverPos.Value or nil
						})
	
						for _, entity in entities do
							if entity.Player and isIllegal(entity) then
								if not entity.Character:GetAttribute('InVehicle') and not entity.Character:GetAttribute('HasHandcuffs') and not target and cooldown < os.clock() then
									target = entity.Player.Name
								end
							end
						end
	
						if target then
							local lastEquipped = jb.ItemSystemController:GetLocalEquipped()
							if AutoEquip.Enabled and not (lastEquipped and lastEquipped.__ClassName == 'Handcuffs') then
								equipTool(cuffs)
							end
	
							local equipped = jb.ItemSystemController:GetLocalEquipped()
							if equipped and equipped.__ClassName == 'Handcuffs' then
								if target then
									jb:FireServer('Arrest', target)
									cooldown = os.clock() + 0.5
								end
							end
	
							if AutoEquip.Enabled and lastEquipped ~= equipped then
								equipTool(lastEquipped and lastEquipped.inventoryItemValue or cuffs)
							end
						end
					end
	
					task.wait(0.016)
				until not AutoArrest.Enabled
			end
		end,
		Tooltip = 'Automatically uses handcuffs on nearby entities'
	})
	Range = AutoArrest:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 16,
		Default = 16,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AutoEquip = AutoArrest:CreateToggle({
		Name = 'AutoEquip',
		Tooltip = 'Automatically equip the handcuffs for performing actions (RISKY)'
	})
end)

run(function()
	local AutoEject
	local Range
	local Hand
	local cooldown = 0
	
	AutoEject = vape.Categories.Blatant:CreateModule({
		Name = 'AutoEject',
		Function = function(callback)
			if callback then
				repeat
					local cuffs = InvTracker.Inventories[lplr].Handcuffs
	
					if entitylib.isAlive and lplr.Team == teams.Police and cuffs then
						local equipped = jb.ItemSystemController:GetLocalEquipped()
	
						if not Hand.Enabled or equipped and equipped.__ClassName == 'Handcuffs' then
							local serverPos = entitylib.character.Humanoid:FindFirstChild('HumanoidUnloadServerPosition')
							local vehicle
	
							local entities = entitylib.AllPosition({
								Players = true,
								Part = 'RootPart',
								Range = Range.Value,
								Origin = serverPos and serverPos.Value or nil
							})
	
							for _, entity in entities do
								if entity.Player and isIllegal(entity) then
									if entity.Character:GetAttribute('InVehicle') then
										if not vehicle and cooldown < os.clock() then
											vehicle = getVehicle(entity)
										end
									end
								end
							end
	
							if vehicle then
								jb:FireServer('Eject', vehicle)
								cooldown = os.clock() + 0.5
							end
						end
					end
	
					task.wait(0.016)
				until not AutoEject.Enabled
			end
		end,
		Tooltip = 'Automatically ejects on nearby vehicles'
	})
	Range = AutoEject:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 40,
		Default = 40,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	Hand = AutoEject:CreateToggle({
		Name = 'Hand Check',
		Tooltip = 'Only eject while holding handcuffs'
	})
end)

run(function()
	local AutoPickpocket
	local Range
	local cooldown = 0
	
	local function equipTool(tool)
		local obj = jb.InventoryItemBinder:Get(tool)
		if obj then
			obj:AttemptSelect()
		end
	end
	
	AutoPickpocket = vape.Categories.Blatant:CreateModule({
		Name = 'AutoPickpocket',
		Function = function(callback)
			if callback then
				repeat
					if entitylib.isAlive then
						local serverPos = entitylib.character.Humanoid:FindFirstChild('HumanoidUnloadServerPosition')
						local target
	
						local entities = entitylib.AllPosition({
							Players = true,
							Part = 'RootPart',
							Range = Range.Value,
							Origin = serverPos and serverPos.Value or nil
						})
	
						for _, entity in entities do
							if entity.Player and entity.Player.Team ~= teams.Prisoner then
								if not (target or entity.Pickpocket) and cooldown < os.clock() then
									if entity.Player.Team == teams.Criminal and not entity.Character:GetAttribute('HasHandcuffs') then
										continue
									end
	
									target = entity
									break
								end
							end
						end
	
						if target then
							target.Pickpocket = target.Player.Team == teams.Criminal
							jb:FireServer('Pickpocket', target.Player.Name)
							cooldown = os.clock() + 0.2
						end
					end
	
					task.wait(0.016)
				until not AutoPickpocket.Enabled
			end
		end,
		Tooltip = 'Automatically steals from nearby entities'
	})
	Range = AutoPickpocket:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 16,
		Default = 16,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
end)

run(function()
	local AutoPop
	local Range
	local TeamCheck
	local hitDelays = {}
	
	local function getEntitiesInVehicle(car)
		local entities = {}
	
		for _, seat in car:GetChildren() do
			if (seat.Name == 'Seat' or seat.Name == 'Passenger') then
				seat = seat:FindFirstChild('PlayerName')
				if seat then
					for _, entity in entitylib.List do
						if entity.Player and entity.Player.Name == seat.Value then
							table.insert(entities, entity)
						end
					end
				end
			end
		end
	
		return entities
	end
	
	local function getVehiclesNear()
		local vehicles = {}
	
		if entitylib.isAlive then
			local localPosition = entitylib.character.HumanoidRootPart.Position
	
			for _, vehicle in collectionService:GetTagged('Vehicle') do
				if vehicle.PrimaryPart and (vehicle.PrimaryPart.Position - localPosition).Magnitude <= Range.Value and vehicle:GetAttribute('VehicleHasDriver') then
					local entities = getEntitiesInVehicle(vehicle)
					local canAttack = #entities > 0
	
					if TeamCheck.Enabled then
						for _, entity in entities do
							if not entity.Targetable then
								canAttack = false
								break
							end
						end
					end
	
					if canAttack then
						table.insert(vehicles, vehicle)
					end
				end
			end
		end
	
		return vehicles
	end
	
	AutoPop = vape.Categories.Blatant:CreateModule({
		Name = 'AutoPop',
		Function = function(callback)
			if callback then
				task.spawn(function()
					repeat
						local item = jb.ItemSystemController:GetLocalEquipped()
						if item and item.BulletEmitter then
							for _, car in getVehiclesNear() do
								if (hitDelays[car] or 0) > os.clock() then
									continue
								end
	
								hitDelays[car] = os.clock() + 0.1
								jb:FireServer('PopTires', car, item.__ClassName)
							end
						end
	
						task.wait(0.016)
					until not AutoPop.Enabled
				end)
			else
				table.clear(hitDelays)
			end
		end,
		Tooltip = 'Automatically pops vehicles tires around you'
	})
	Range = AutoPop:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 640,
		Default = 640,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	TeamCheck = AutoPop:CreateToggle({
		Name = 'Priority Only'
	})
end)

run(function()
	local AutoPunch
	
	AutoPunch = vape.Categories.Blatant:CreateModule({
		Name = 'AutoPunch',
		Function = function(callback)
			if callback then
				repeat
					if entitylib.isAlive then
						jb:FireServer('Punch')
					end
	
					task.wait(0.3)
				until not AutoPunch.Enabled
			end
		end,
		Tooltip = 'Always punches objects and entities infront of you'
	})
end)

run(function()
	local AutoTaze
	local Range
	local HandCheck
	local VehicleCheck
	local CooldownBar
	local cdholder, cdframe, cdlabel
	
	local function drawTaser(origin, target)
		local tracer = jb.LightningUtils.strikePosition({
			Transparency = 0,
			PartWidth = 0.1,
			NumSegments = 10,
			OffsetRadius = 2,
			Origin = origin.Position,
			Target = target,
			Color = Color3.fromRGB(175, 130, 90)
		})
	
		jb.Audio.ObjectLocal(origin, 754972373)
	
		task.delay(0.1, tracer.Destroy, tracer)
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	end
	
	AutoTaze = vape.Categories.Blatant:CreateModule({
		Name = 'AutoTaze',
		Function = function(callback)
			if callback then
				repeat
					local taser = InvTracker.Inventories[lplr].Taser
	
					if entitylib.isAlive and taser then
						local equipped = jb.ItemSystemController:GetLocalEquipped()
						local isTaser = equipped and equipped.__ClassName == 'Taser'
	
						if (not HandCheck.Enabled or isTaser) then
							local entities = entitylib.AllPosition({
								Players = true,
								Part = 'RootPart',
								Range = Range.Value
							})
	
							if (taser:GetAttribute('NextUse') or 0) < os.clock() then
								for _, entity in entities do
									if isIllegal(entity) and (entity.VehicleTimer or 0) < os.clock() and not (entity.Character:GetAttribute('HasHandcuffs') or (VehicleCheck.Enabled and entity.Character:GetAttribute('InVehicle')) or entity.Head.CanCollide) then
										drawTaser(equipped and equipped.Tip or entitylib.character.RootPart, entity.RootPart.Position)
										taser:SetAttribute('LastUsedAt', os.clock())
										taser:SetAttribute('NextUse', os.clock() + 10)
	
										if isTaser then
											jb:FireServer('TaseReplicate', entity.RootPart.Position)
										end
	
										jb:FireServer('Tase', entity.Humanoid, entity.RootPart, entity.RootPart.Position)
	
										if isTaser then
											equipped:BroadcastInputBegan({UserInputType = Enum.UserInputType.MouseButton1, KeyCode = Enum.KeyCode.None})
										end
	
										break
									end
								end
							end
						end
					end
	
					if cdholder then
						if vape.ThreadFix then
							setthreadidentity(8)
						end
	
						cdholder.Visible = taser and (taser:GetAttribute('NextUse') or 0) > os.clock() or false
	
						if cdholder.Visible then
							local diff = (taser:GetAttribute('NextUse') or 0) - os.clock()
							cdframe.Size = UDim2.new(math.clamp(diff / 10, 0, 1), -2, 1, -2)
							cdlabel.Text = (math.round(diff * 10) / 10)..'s'
						end
					end
	
					task.wait(0.016)
				until not AutoTaze.Enabled
			else
				if cdholder then
					cdholder.Visible = false
				end
			end
		end,
		Tooltip = 'Immobilizes entities around you'
	})
	Range = AutoTaze:CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 75,
		Default = 75,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	HandCheck = AutoTaze:CreateToggle({
		Name = 'Hand Check'
	})
	VehicleCheck = AutoTaze:CreateToggle({
		Name = 'Vehicle Check',
		Tooltip = 'Avoid tazing players in vehicles (RECOMMENDED)',
		Default = true
	})
	CooldownBar = AutoTaze:CreateToggle({
		Name = 'Cooldown Bar',
		Function = function(callback)
			if callback then
				cdholder = Instance.new('Frame')
				cdholder.Visible = false
				cdholder.BorderSizePixel = 0
				cdholder.BackgroundTransparency = 0.7
				cdholder.AnchorPoint = Vector2.new(0.5, 0)
				cdholder.BackgroundColor3 = Color3.new(1, 1, 1)
				cdholder.Size = UDim2.new(0.1, 0, 0, 5)
				cdholder.Position = UDim2.fromScale(0.5, 0.55)
				cdholder.Parent = vape.gui
				cdframe = Instance.new('Frame')
				cdframe.BorderSizePixel = 0
				cdframe.BackgroundTransparency = 0.3
				cdframe.BackgroundColor3 = Color3.new(1, 1, 1)
				cdframe.Size = UDim2.new(1, -2, 1, -2)
				cdframe.Position = UDim2.fromOffset(1, 1)
				cdframe.Parent = cdholder
				cdlabel = Instance.new('TextLabel')
				cdlabel.Size = UDim2.new(1, 0, 0, 14)
				cdlabel.Position = UDim2.fromOffset(0, 10)
				cdlabel.BackgroundTransparency = 1
				cdlabel.TextColor3 = Color3.new(1, 1, 1)
				cdlabel.TextScaled = true
				cdlabel.TextStrokeTransparency = 0
				cdlabel.Font = Enum.Font.Arial
				cdlabel.Parent = cdholder
			else
				if cdholder then
					cdholder:Destroy()
					cdholder = nil
				end
			end
		end,
		Tooltip = 'Show the cooldown for arresting'
	})
end)

local Fly
local LongJump
run(function()
	local Value
	local UpKey
	local DownKey
	local VerticalValue
	local CustomProperties
	local PlatformStanding
	local Platform, YLevel, OldYLevel
	local up, down = 0, 0

	Fly = vape.Categories.Blatant:CreateModule({
		Name = 'Fly',
		Function = function(callback)
			frictionTable.Fly = callback and CustomProperties.Enabled or nil
			updateVelocity()
			if callback then
				Platform = Instance.new('Part')
				Platform.CanQuery = false
				Platform.Anchored = true
				Platform.Size = Vector3.new(100, 1, 100)
				Platform.Transparency = 1

				Fly:Clean(Platform)
				Fly:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						if PlatformStanding.Enabled then
							entitylib.character.Humanoid.PlatformStand = true
							entitylib.character.RootPart.AssemblyAngularVelocity = Vector3.zero
							entitylib.character.RootPart.CFrame = CFrame.lookAlong(entitylib.character.RootPart.CFrame.Position, gameCamera.CFrame.LookVector)
						end

						local hum = entitylib.character.Humanoid
						local root = entitylib.character.RootPart
						if hum.Sit then
							local packet = jb.VehicleController.GetLocalVehiclePacket()
							local wheel = packet and packet.EngineThrusters[1]

							if wheel then
								local suspension = (packet.Model:GetAttribute('GarageSuspensionHeight') or 0) + packet.Height
								lplr.Character:SetAttribute('DoNotAllowVehicleExit', table.find(UpKey.Keys, 'Space') and true or false)
								packet.Seat.CFrame += Vector3.new(0, (up + down) * VerticalValue.Value * dt, 0)
								Platform.Position = wheel.Engine.Position + Vector3.new(0, -suspension, 0)
								Platform.Parent = gameCamera
							end

							return
						else
							Platform.Parent = nil
						end

						root.AssemblyLinearVelocity = (hum.MoveDirection * Value.Value) + Vector3.new(0, 2.25 + ((up + down) * VerticalValue.Value), 0)
					else
						YLevel = nil
						OldYLevel = nil
					end
				end))

				up, down = 0, 0

				Fly:Clean(UpKey.Triggered:Connect(function(isDown)
					up = isDown and 1 or 0
				end))

				Fly:Clean(DownKey.Triggered:Connect(function(isDown)
					down = isDown and -1 or 0
				end))

				if inputService.TouchEnabled then
					pcall(function()
						local jumpButton = lplr.PlayerGui.TouchGui.TouchControlFrame.JumpButton
						Fly:Clean(jumpButton:GetPropertyChangedSignal('ImageRectOffset'):Connect(function()
							up = jumpButton.ImageRectOffset.X == 146 and 1 or 0
						end))
					end)
				end
			else
				YLevel, OldYLevel = nil, nil
				if entitylib.isAlive then
					if PlatformStanding.Enabled then
						entitylib.character.Humanoid.PlatformStand = false
					end

					lplr.Character:SetAttribute('DoNotAllowVehicleExit', nil)
				end
			end
		end,
		Tooltip = 'Makes you go zoom.'
	})
	UpKey = Fly:CreateBind({
		Name = 'Up Key',
		Default = {'Space'},
		Hold = true,
		Tooltip = 'Keybind to fly upwards'
	})
	DownKey = Fly:CreateBind({
		Name = 'Down Key',
		Default = {'LeftControl'},
		Hold = true,
		Tooltip = 'Keybind to fly downwards'
	})
	Value = Fly:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 150,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	VerticalValue = Fly:CreateSlider({
		Name = 'Vertical Speed',
		Min = 1,
		Max = 150,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	PlatformStanding = Fly:CreateToggle({
		Name = 'PlatformStand',
		Function = function(callback)
			if Fly.Enabled then
				entitylib.character.Humanoid.PlatformStand = callback
			end
		end,
		Tooltip = 'Forces the character to look infront of the camera'
	})
	CustomProperties = Fly:CreateToggle({
		Name = 'Custom Properties',
		Function = function()
			if Fly.Enabled then
				Fly:Toggle()
				Fly:Toggle()
			end
		end,
		Default = true
	})
end)

run(function()
	local ForceEquip
	local old
	
	ForceEquip = vape.Categories.Blatant:CreateModule({
		Name = 'ForceEquip',
		Function = function(callback)
			if callback then
				for _, condition in jb.InventoryItemSystem._equipConditions do
					if debug.getconstants(condition)[1] == 'IsCrawling' then
						debug.setconstant(condition, 1, '_IsCrawling')
						old = condition
						break
					end
				end
			else
				if old then
					debug.setconstant(old, 1, 'IsCrawling')
					old = nil
				end
			end
		end,
		Tooltip = 'Allow you to equip while crouching'
	})
end)

run(function()
	local GunModifications
	local Recoil
	local Spread
	local Automatic
	local EquipTime
	local VehicleWallbang
	local Headshot
	local Hitscan
	local oldhit
	local oldequip
	local olddata = {}
	
	local function ModifyGun(gun)
		if gun and gun.LastReplicateMousePosition then
			if not olddata[gun.Config] then
				olddata[gun.Config] = table.clone(gun.Config)
			end
	
			gun.Config.CamShakeMagnitude = Recoil.Enabled and 0 or olddata[gun.Config].CamShakeMagnitude
			gun.Config.FireAuto = Automatic.Enabled or olddata[gun.Config].FireAuto
	
			if gun.Config.BulletSpread then
				gun.Config.BulletSpread = Spread.Enabled and 0 or olddata[gun.Config].BulletSpread
			end
	
			local vehicleIndex = table.find(gun.BulletEmitter.IgnoreList, workspace.Vehicles)
			if vehicleIndex then
				if not VehicleWallbang.Enabled then
					table.remove(gun.BulletEmitter.IgnoreList, vehicleIndex)
				end
			else
				if VehicleWallbang.Enabled then
					table.insert(gun.BulletEmitter.IgnoreList, workspace.Vehicles)
				end
			end
		end
	end
	
	local function ApplyMods()
		if GunModifications.Enabled then
			local equipped = jb.ItemSystemController:GetLocalEquipped()
			if equipped then
				task.spawn(ModifyGun, equipped)
			end
		end
	end
	
	GunModifications = vape.Categories.Blatant:CreateModule({
		Name = 'GunModifications',
		Function = function(callback)
			if callback then
				if Hitscan.Enabled then
					oldBulletUpdate = hookfunction(jb.BulletEmitter.Update, function(...)
						local self = ...
						if self.Local then
							self.LastUpdate = tick() - self.LifeSpan
						end
	
						return oldBulletUpdate(...)
					end)
				end
	
				--[[if Headshot.Enabled then
					oldhit = hookfunction(jb.GunController.BulletEmitterOnLocalHitPlayer, function(...)
						local shotData = select(15, ...)
						shotData.isHeadshot = true
						return oldhit(...)
					end)
				end]]
	
				if EquipTime.Enabled then
					oldequip = hookfunction(jb.GunUtils.getShouldAddEquipTime, function()
						return false
					end)
				end
	
				GunModifications:Clean(jb.ItemSystemController.OnLocalItemEquipped:Connect(function(item)
					task.spawn(ModifyGun, item)
				end))
	
				local equipped = jb.ItemSystemController:GetLocalEquipped()
				if equipped then
					task.spawn(ModifyGun, equipped)
				end
			else
				if oldBulletUpdate then
					restorefunction(jb.BulletEmitter.Update)
					oldBulletUpdate = nil
				end
	
				if oldhit then
					restorefunction(jb.GunController.BulletEmitterOnLocalHitPlayer)
					oldhit = nil
				end
	
				if oldequip then
					restorefunction(jb.GunUtils.getShouldAddEquipTime)
					oldequip = nil
				end
	
				for config, data in olddata do
					for i, v in data do
						config[i] = v
					end
				end
	
				table.clear(olddata)
			end
		end,
		Tooltip = 'Apply various modifications to enhance any firearm'
	})
	Recoil = GunModifications:CreateToggle({
		Name = 'No Recoil',
		Function = ApplyMods
	})
	Spread = GunModifications:CreateToggle({
		Name = 'No Spread',
		Function = ApplyMods
	})
	EquipTime = GunModifications:CreateToggle({
		Name = 'No Equip Time',
		Function = function()
			if GunModifications.Enabled then
				GunModifications:Toggle()
				GunModifications:Toggle()
			end
		end
	})
	Automatic = GunModifications:CreateToggle({
		Name = 'Full Automatic',
		Function = ApplyMods
	})
	VehicleWallbang = GunModifications:CreateToggle({
		Name = 'Vehicle Wallbang',
		Function = ApplyMods,
		Tooltip = 'Allow you to shoot through vehicles.'
	})
	--[[Headshot = GunModifications:CreateToggle({
		Name = 'Always Headshot',
		Function = function()
			if GunModifications.Enabled then
				GunModifications:Toggle()
				GunModifications:Toggle()
			end
		end,
		Tooltip = 'Force headshot damage when hitting any body part'
	})]]
	Hitscan = GunModifications:CreateToggle({
		Name = 'Hitscan Bullets',
		Function = function()
			if GunModifications.Enabled then
				GunModifications:Toggle()
				GunModifications:Toggle()
			end
		end,
		Tooltip = 'Instantly teleport bullets along the destination trajectory'
	})
end)

run(function()
	local modified = {}
	local overlapCheck = OverlapParams.new()
	
	LazerGodmode = vape.Categories.Blatant:CreateModule({
		Name = 'LazerGodmode',
		Function = function(callback)
			if callback then
				LazerGodmode:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive then
						overlapCheck.FilterDescendantsInstances = {gameCamera, lplr.Character}
	
						local parts = workspace:GetPartBoundsInRadius(entitylib.character.RootPart.Position, 10, overlapCheck)
						for _, part in parts do
							modified[part] = true
							part.CanTouch = false
						end
	
						for part in modified do
							if not table.find(parts, part) then
								modified[part] = nil
								part.CanTouch = true
							end
						end
					end
				end))
			else
				for inst in modified do
					inst.CanTouch = true
				end
	
				table.clear(modified)
			end
		end,
		Tooltip = 'Allow you to ignore specific damage sources'
	})
end)

run(function()
	local Mode
	local Value
	local AutoDisable
	
	LongJump = vape.Categories.Blatant:CreateModule({
		Name = 'LongJump',
		Function = function(callback)
			if callback then
				local exempt = tick() + 0.1
				LongJump:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive then
						local hum = entitylib.character.Humanoid
						local root = entitylib.character.RootPart
						if hum.FloorMaterial ~= Enum.Material.Air then
							if exempt < tick() and AutoDisable.Enabled then
								if LongJump.Enabled then
									LongJump:Toggle()
								end
							else
								entitylib.character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							end
						end
	
						if hum.Sit then return end
	
						local dir = hum.MoveDirection * Value.Value
						if Mode.Value == 'Velocity' then
							root.AssemblyLinearVelocity = dir + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
						elseif Mode.Value == 'Impulse' then
							local diff = (dir - root.AssemblyLinearVelocity) * Vector3.new(1, 0, 1)
							if diff.Magnitude > (dir == Vector3.zero and 10 or 2) then
								root:ApplyImpulse(diff * root.AssemblyMass)
							end
						else
							root.CFrame += dir * dt
						end
					end
				end))
			end
		end,
		ExtraText = function()
			return Mode.Value
		end,
		Tooltip = 'Lets you jump farther'
	})
	Mode = LongJump:CreateDropdown({
		Name = 'Mode',
		List = {'Velocity', 'Impulse', 'CFrame'},
		Tooltip = 'Velocity - Uses smooth physics based movement\nImpulse - Same as velocity while using forces instead\nCFrame - Directly adjusts the position of the root'
	})
	Value = LongJump:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 150,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AutoDisable = LongJump:CreateToggle({
		Name = 'Auto Disable',
		Default = true
	})
end)

run(function()
	vape.Categories.Blatant:CreateModule({
		Name = 'NoFall',
		Function = function(callback)
			debug.setconstant(debug.getupvalue(jb.FallingController.Init, 20), 9, callback and 'Archivable' or 'Sit')
		end,
		Tooltip = 'Disables ragdoll handling and fall damage'
	})
end)

run(function()
	local NoSlowdown
	local Toggles = {}
	
	NoSlowdown = vape.Categories.Blatant:CreateModule({
		Name = 'NoSlowdown',
		Function = function(callback)
			debug.setconstant(jb.WalkSpeedFun, 5, callback and Toggles.Damage.Enabled and 'MaxHealth' or 'Health')
			debug.setconstant(jb.WalkSpeedFun, 13, callback and Toggles.SWAT.Enabled and '_ShieldSWAT' or 'ShieldSWAT')
			debug.setconstant(jb.WalkSpeedFun, 16, callback and Toggles.Crawling.Enabled and 1 or 0.4)
			debug.setconstant(jb.WalkSpeedFun, 33, callback and Toggles.Spotlight.Enabled and '_IsInTrackingSpotlight' or 'IsInTrackingSpotlight')
		end,
		Tooltip = 'Prevents slowing down from various sources.'
	})
	
	for _, toggle in {'Damage', 'Crawling', 'SWAT', 'Spotlight'} do
		Toggles[toggle] = NoSlowdown:CreateToggle({
			Name = toggle,
			Function = function(callback)
				if NoSlowdown.Enabled then
					NoSlowdown:Toggle()
					NoSlowdown:Toggle()
				end
			end
		})
	end
end)

run(function()
	local Speed
	local Value
	local CustomProperties
	
	Speed = vape.Categories.Blatant:CreateModule({
		Name = 'Speed',
		Function = function(callback)
			frictionTable.Speed = callback and CustomProperties.Enabled or nil
			updateVelocity()
			if callback then
				Speed:Clean(runService.PreSimulation:Connect(function(dt)
					if entitylib.isAlive and not Fly.Enabled and not LongJump.Enabled then
						local hum = entitylib.character.Humanoid
						local state = entitylib.character.Humanoid:GetState()
						if state == Enum.HumanoidStateType.Climbing then return end
						if hum.Sit then return end
	
						local root = entitylib.character.RootPart
						root.AssemblyLinearVelocity = (hum.MoveDirection * Value.Value) + Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
					end
				end))
			end
		end,
		Tooltip = 'Increases your movement with various methods.'
	})
	Value = Speed:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 150,
		Default = 50,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	CustomProperties = Speed:CreateToggle({
		Name = 'Custom Properties',
		Function = function()
			if Speed.Enabled then
				Speed:Toggle()
				Speed:Toggle()
			end
		end,
		Default = true
	})
end)

run(function()
	local VehicleSpeed
	local Value
	local old
	
	VehicleSpeed = vape.Categories.Blatant:CreateModule({
		Name = 'VehicleSpeed',
		Function = function(callback)
			if callback then
				old = hookfunction(jb.AlexChassis.Update, function(...)
					local self = ...
					self.GarageEngineSpeed = Value.Value
					return old(...)
				end)
			else
				if old then
					restorefunction(jb.AlexChassis.Update)
					old = nil
				end
			end
		end,
		Tooltip = 'Automatically adjust the engine level of the vehicle.'
	})
	Value = VehicleSpeed:CreateSlider({
		Name = 'Speed',
		Min = 0,
		Max = 30,
		Default = 30
	})
	
end)

run(function()
	local oldnitro
	
	InfNitro = vape.Categories.Utility:CreateModule({
		Name = 'InfiniteNitro',
		Function = function(callback)
			if callback then
				oldnitro = jb.VehicleController.nitroState.Nitro
				jb.VehicleController.updateSpdBarRatio(1)
	
				repeat
					jb.VehicleController.nitroState.Nitro = 250
					task.wait(0.1)
				until not InfNitro.Enabled
			else
				jb.VehicleController.nitroState.Nitro = oldnitro
				jb.VehicleController.updateSpdBarRatio(oldnitro / 250)
			end
		end,
		Tooltip = 'Infinite boost for the local car'
	})
end)

run(function()
	local old
	local await
	
	vape.Categories.Utility:CreateModule({
		Name = 'InstantAction',
		Function = function(callback)
			if callback then
				old = hookfunction(jb.CircleAction.Press, function(...)
					local action = jb.CircleAction.Spec
					if action and action.Timed and not (action.ReleaseCallback or action.ShouldHotwire or await) then
						local old = action.Timed
	
						action.Timed = false
						await = task.defer(function()
							action.Timed = old
							await = nil
						end)
					end
	
					return old(...)
				end)
			else
				if old then
					restorefunction(jb.CircleAction.Press)
					old = nil
				end
			end
		end,
		Tooltip = 'Allows you to instantly complete ProximityPrompt actions'
	})
end)

run(function()
	local AutoHeal
	
	AutoHeal = vape.Categories.Inventory:CreateModule({
		Name = 'AutoHeal',
		Function = function(callback)
			if callback then
				repeat
					local entity = entitylib.isAlive and entitylib.character
					local donut = InvTracker.Inventories[lplr].Donut
	
					if donut and entity and entity.Humanoid.Health <= 70 then
						jb:FireServer('Donut')
					end
	
					task.wait(0.05)
				until not AutoHeal.Enabled
			end
		end,
		Tooltip = 'Automatically heal damage with consumables.'
	})
end)

run(function()
	local AutoHotbar
	local SortList = {Police = {}, Prisoner = {}}
	
	local function DoSorting()
		local collected = {}
		for _, item in InvTracker.Inventories[lplr] do
			table.insert(collected, {
				Tool = item,
				Slot = item:GetAttribute('DisplayOrder') or 0
			})
		end
	
		local list = SortList[lplr.Team == teams.Police and 'Police' or 'Prisoner']
		table.sort(collected, function(a, b)
			return (list[a.Tool.name] or 15 + a.Slot) < (list[b.Tool.name] or 15 + b.Slot)
		end)
	
		for index, item in collected do
			item.Tool:SetAttribute('DisplayOrder', index)
			table.clear(item)
		end
	
		table.clear(collected)
	end
	
	AutoHotbar = vape.Categories.Inventory:CreateModule({
		Name = 'AutoHotbar',
		Function = function(callback)
			if callback then
				AutoHotbar:Clean(vapeEvents.ItemAdded.Event:Connect(DoSorting))
				task.spawn(DoSorting)
			end
		end,
		Tooltip = 'Automatically sort hotbar entries'
	})
	
	for _, team in {'Prisoner', 'Police'} do
		AutoHotbar:CreateTextList({
			Name = team..' Pickups',
			Default = team == 'Prisoner' and {'1/AK47', '2/Shotgun', '3/Pistol'} or {'1/AK47', '2/Shotgun', '3/Pistol', '4/Taser', '5/RoadSpike'},
			Placeholder = 'priority/item',
			Function = function(list)
				table.clear(SortList[team])
	
				for _, entry in list do
					local data = entry:split('/')
					local priority = tonumber(data[1]) or 999
					SortList[team][data[2] or ''] = priority
				end
			end
		})
	end
end)

run(function()
	local AutoPickup
	local Lists = {}
	local Regions = {}
	local pickupList = {Police = {}, Prisoner = {}}
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.MaxParts = 1
	
	local function doesPlayerOwn(item)
		local items = lplr:FindFirstChild('Items')
		return items and items:FindFirstChild(item) or false
	end
	
	AutoPickup = vape.Categories.Inventory:CreateModule({
		Name = 'AutoPickup',
		Function = function(callback)
			if callback then
				Regions = collectionService:GetTagged('GunShopRegion')
				overlapParams.FilterDescendantsInstances = Regions
	
				AutoPickup:Clean(collectionService:GetInstanceAddedSignal('GunShopRegion'):Connect(function(obj)
					table.insert(Regions, obj)
					overlapParams.FilterDescendantsInstances = Regions
				end))
	
				AutoPickup:Clean(collectionService:GetInstanceRemovedSignal('GunShopRegion'):Connect(function(obj)
					local index = table.find(Regions, obj)
					if index then
						table.remove(Regions, index)
					end
				end))
	
				repeat
					if entitylib.isAlive then
						local parts = workspace:GetPartsInPart(entitylib.character.RootPart, overlapParams)
						if #parts > 0 then
							for _, entry in pickupList[lplr.Team == teams.Police and 'Police' or 'Prisoner'] do
								if not InvTracker.Inventories[lplr][entry] and doesPlayerOwn(entry) then
									jb:FireServer('EquipItem', entry, nil)
								end
							end
	
							task.wait(0.2)
						end
					end
	
					task.wait(0.05)
				until not AutoPickup.Enabled
			else
				table.clear(Regions)
			end
		end,
		Tooltip = 'Automatically grab item pickups'
	})
	
	for _, team in {'Prisoner', 'Police'} do
		AutoPickup:CreateTextList({
			Name = team..' Pickups',
			Default = team == 'Prisoner' and {'AK47', 'Shotgun', 'Pistol'} or {'AK47', 'Shotgun'},
			Placeholder = 'item',
			Function = function(list)
				table.clear(pickupList[team])
	
				for _, entry in list do
					table.insert(pickupList[team], entry)
				end
			end
		})
	end
end)

run(function()
	local FPSBooster
	local destructibles = {}
	local old
	
	local function addInstance(obj)
		local found = obj:FindFirstChild('DestructibleInstance')
		if found and found.Value then
			destructibles[obj] = found.Value
		end
	end
	
	FPSBooster = vape.Legit:CreateModule({
		Name = 'FPSBooster',
		Function = function(callback)
			if callback then
				old = debug.getupvalue(jb.GunController.Setup, 2)
				debug.setupvalue(jb.GunController.Setup, 2, {
					GetTagged = function()
						local self = debug.getstack(2, 1)
						if type(self) == 'table' and self.IgnoreList then
							for _, obj in destructibles do
								table.insert(self.IgnoreList, obj)
							end
						end
	
						return {}
					end
				})
	
				for _, obj in collectionService:GetTagged('DestructibleSpawn') do
					addInstance(obj)
				end
	
				FPSBooster:Clean(collectionService:GetInstanceAddedSignal('DestructibleSpawn'):Connect(addInstance))
				FPSBooster:Clean(collectionService:GetInstanceRemovedSignal('DestructibleSpawn'):Connect(function(obj)
					destructibles[obj] = nil
				end))
			else
				if old then
					debug.setupvalue(jb.GunController.Setup, 2, old)
					old = nil
				end
	
				table.clear(destructibles)
			end
		end,
		Tooltip = 'Optimize certain parts of the game to gain more FPS'
	})
end)

run(function()
	local Viewmodel
	local Depth
	local Horizontal
	local Vertical
	local Sway
	local ForceField
	local ColorSl
	local handle
	local old
	local moveSpring = Spring.new()
	local aimSpring = Spring.new({Speed = 15})
	
	local function ToolAdded(tool)
		if tool then
			if vtool then
				vtool:Destroy()
			end
	
			old = tool
			vtool = tool:Clone()
			handle = vtool:FindFirstChild('BoundingBox', true) or vtool:FindFirstChild('Center', true)
			vtool.Parent = gameCamera
	
			local motor = vtool:FindFirstChild('Motor6D', true) or vtool:FindFirstChild('Motor', true)
			if motor then
				motor:Destroy()
			end
	
			for _, part in vtool:QueryDescendants('BasePart') do
				part.Material = ForceField.Enabled and Enum.Material.ForceField or part.Material
				part.Color = ForceField.Enabled and Color3.fromHSV(ColorSl.Hue, ColorSl.Sat, ColorSl.Value) or part.Color
			end
	
			for _, inst in old:QueryDescendants('BasePart, Texture, Decal') do
				inst.LocalTransparencyModifier = 1
			end
		end
	end
	
	Viewmodel = vape.Legit:CreateModule({
		Name = 'Viewmodel',
		Function = function(callback)
			if callback then
				Viewmodel:Clean(jb.ItemSystemController.OnLocalItemEquipped:Connect(function(item)
					task.spawn(ToolAdded, item.Model)
				end))
	
				Viewmodel:Clean(jb.ItemSystemController.OnLocalItemUnequipped:Connect(function()
					task.spawn(function()
						if vtool then
							vtool:Destroy()
							vtool = nil
						end
	
						old = nil
					end)
				end))
	
				local equipped = jb.ItemSystemController:GetLocalEquipped()
				if equipped then
					task.spawn(ToolAdded, equipped.Model)
				end
	
				Viewmodel:Clean(runService.RenderStepped:Connect(function(dt)
					if handle then
						moveSpring.Target = entitylib.isAlive and entitylib.character.RootPart.AssemblyLinearVelocity * 0.005 or Vector3.zero
	
						if Sway.Enabled then
							if moveSpring.Target.Magnitude > 0.1 then
								moveSpring.Target += (gameCamera.CFrame * CFrame.new(math.sin(tick() * 10) * 0.06, 0, 0)).Position - gameCamera.CFrame.Position
							else
								moveSpring.Target += (gameCamera.CFrame * CFrame.new(0, math.sin(tick()) * 0.04, 0)).Position - gameCamera.CFrame.Position
							end
						end
	
						local cf = (gameCamera.CFrame * CFrame.new(Horizontal.Value, Vertical.Value, -Depth.Value)) + moveSpring:Update(dt)
						aimSpring.Target = aimTimer > os.clock() and CFrame.lookAt(cf.Position, aimVec).LookVector or gameCamera.CFrame.LookVector
						handle.CFrame = CFrame.lookAlong(cf.Position, aimSpring:Update(dt)) * (CFrame.Angles(math.rad(math.max(shootTimer - os.clock(), 0) * 10), 0, 0) * CFrame.new(0, 0, math.max(shootTimer - os.clock(), 0)))
						handle.AssemblyLinearVelocity = Vector3.zero
					end
				end))
			else
				if old then
					for _, inst in old:QueryDescendants('BasePart, Texture, Decal') do
						inst.LocalTransparencyModifier = 0
					end
	
					old = nil
				end
	
				if vtool then
					vtool:Destroy()
					vtool = nil
					handle = nil
				end
			end
		end,
		Tooltip = 'Custom viewmodel for guns'
	})
	Depth = Viewmodel:CreateSlider({
		Name = 'Depth',
		Min = 0,
		Max = 4,
		Default = 4,
		Decimal = 10
	})
	Horizontal = Viewmodel:CreateSlider({
		Name = 'Horizontal',
		Min = 0,
		Max = 2.5,
		Default = 2.5,
		Decimal = 10
	})
	Vertical = Viewmodel:CreateSlider({
		Name = 'Vertical',
		Min = -1.5,
		Max = 2,
		Default = -1.5,
		Decimal = 10
	})
	Sway = Viewmodel:CreateToggle({
		Name = 'Sway Effect',
		Default = true
	})
	ForceField = Viewmodel:CreateToggle({
		Name = 'ForceField Effect',
		Function = function(callback)
			ColorSl.Object.Visible = callback
			if callback and Viewmodel.Enabled then
				Viewmodel:Toggle()
				Viewmodel:Toggle()
			end
		end
	})
	ColorSl = Viewmodel:CreateColorSlider({
		Name = 'Color',
		Function = function(hue, sat, val)
			if vtool then
				for _, v in vtool:QueryDescendants('BasePart') do
					v.Color = Color3.fromHSV(hue, sat, val)
				end
			end
		end,
		Visible = false
	})
end)