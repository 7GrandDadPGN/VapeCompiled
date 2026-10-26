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
local inputService = cloneref(game:GetService('UserInputService'))
local replicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local collectionService = cloneref(game:GetService('CollectionService'))
local textChatService = cloneref(game:GetService('TextChatService'))
local runService = cloneref(game:GetService('RunService'))
local guiService = cloneref(game:GetService('GuiService'))
local coreGui = cloneref(game:GetService('CoreGui'))
local contextActionService = cloneref(game:GetService('ContextActionService'))
local vim = cloneref(Instance.new('VirtualInputManager'))

local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vape = shared.vape
local entitylib = vape.Libraries.entity
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo
local getfontbounds = vape.Libraries.getfontbounds

local tribes = {}
local HitboxHook = {Hooks = {}}
local VelocityTracker = {Entries = setmetatable({}, {__mode = 'k'})}
local isMatch = false
local realInput

local function dumpInput()
	if not realInput then
		local connection
		connection = inputService.InputEnded:Connect(function(input)
			if input.KeyCode == Enum.KeyCode.Return then
				realInput = input
				connection:Disconnect()
			end
		end)

		vim:SendKeyEvent(true, Enum.KeyCode.Return, false, nil)
		vim:SendKeyEvent(false, Enum.KeyCode.Return, false, nil)
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

local function isTarget(plr)
	return table.find(vape.Categories.Targets.ListEnabled, plr.Name) and true
end

local function notif(...)
	return vape:CreateNotification(...)
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return (str:gsub('<[^<>]->', ''))
end

run(function()
	entitylib.targetCheck = function(entity)
		if entity.NPC then return lplr:GetAttribute('Team') ~= entity.Character:GetAttribute('Team') end
		if isFriend(entity.Player) then return false end
		if not select(2, whitelist:get(entity.Player)) then return false end
		return lplr:GetAttribute('Team') ~= entity.Character:GetAttribute('Team')
	end

	entitylib.addPlayer = function(plr)

	end

	local oldstart = entitylib.start
	local function customEntity(entity)
		local plr = playersService:GetPlayerFromCharacter(entity)

		entity:GetAttributeChangedSignal('Team'):Connect(function()
			if plr ~= lplr and vape.Loaded ~= nil then
				entitylib.refreshEntity(entity, plr)
			end
		end)

		entitylib.addEntity(entity, plr)
	end

	entitylib.start = function()
		oldstart()
		if entitylib.Running then
			for _, entity in collectionService:GetTagged('Combatant') do
				customEntity(entity)
			end

			table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('Combatant'):Connect(customEntity))
			table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('Combatant'):Connect(function(entity)
				entitylib.removeEntity(entity)
			end))
		end
	end
end)
entitylib.start()

run(function()
	tribes = {
		Camera = require(replicatedStorage.Shared.Camera),
		Combat = require(replicatedStorage.Shared.Combat),
		CombatController = require(lplr.PlayerScripts.Combat.Controller),
		Economy = require(lplr.PlayerScripts.UI.Economy),
		Melee = require(lplr.PlayerScripts.Combat.Handlers.Melee),
		Weapons = require(replicatedStorage.Shared.Weapons),
		Util = require(lplr.PlayerScripts.Combat.Util),
		UIState = require(lplr.PlayerScripts.UI.State),
		WeaponIcon = debug.getupvalue(require(lplr.PlayerScripts.UI.WeaponIcon).Init, 5),
		WeaponRedraw = debug.getupvalue(debug.getupvalue(debug.getupvalue(require(lplr.PlayerScripts.UI.WeaponIcon).Init, 5), 3), 8)
	}

	tribes.State = debug.getupvalue(tribes.CombatController.State, 2)
	tribes.Handlers = debug.getupvalue(debug.getupvalue(tribes.CombatController.Equip, 11), 10)
	tribes.SetSpeed = debug.getupvalue(debug.getupvalue(tribes.CombatController.Equip, 11), 15)

	local kills = sessioninfo:AddItem('Kills')
	local deaths = sessioninfo:AddItem('Deaths')
	local games = sessioninfo:AddItem('Games')
	local wins = sessioninfo:AddItem('Wins')
	local winstreaks = sessioninfo:AddItem('Winstreaks', '', function()
		local streaks = {}

		for _, plr in playersService:GetPlayers() do
			if plr ~= lplr and (plr:GetAttribute('Streak') or 0) > 0 then
				table.insert(streaks, plr.Name..': '..plr:GetAttribute('Streak'))
			end
		end

		if #streaks > 0 then
			table.sort(streaks, function(a, b)
				return (tonumber(a:split(': ')[2]) or 0) > (tonumber(b:split(': ')[2]) or 0)
			end)

			return '\n'..table.concat(streaks, '\n')
		end

		return 'None'
	end, false)
	isMatch = not workspace:FindFirstChild('Lobby')

	if isMatch then
		task.delay(1, function()
			games:Increment()
		end)
	end

	vape:Clean(replicatedStorage.Remotes.HitConfirm.OnClientEvent:Connect(function(data)
		if data and data.killed and isMatch then
			kills:Increment()
		end
	end))

	vape:Clean(replicatedStorage.Remotes.MatchEvent.OnClientEvent:Connect(function(event, data)
		if isMatch then
			if event == 'MatchEnd' then
				local didWin = data and data.winnerTeam == lplr:GetAttribute('Team')
				if didWin then
					wins:Increment()
				end

				vapeEvents.MatchEnded:Fire(didWin)
			elseif event == 'Elimination' and data and data.victimId == 'p'..lplr.UserId then
				deaths:Increment()
			end
		end
	end))

	vape:Clean(task.spawn(function()
		repeat
			for _, entity in entitylib.List do
				if not VelocityTracker.Entries[entity.RootPart] then
					VelocityTracker.Entries[entity.RootPart] = {}
				end

				local entry = VelocityTracker.Entries[entity.RootPart]
				repeat
					local _, obj = next(entry)
					if obj and (os.clock() - obj[2]) > 0.5 then
						table.remove(entry, 1)
					else
						break
					end
				until false

				table.insert(entry, {entity.RootPart.AssemblyLinearVelocity, os.clock()})
			end

			task.wait()
		until false
	end))
end)

run(function()
	local oldhitbox

	local function Hook(...)
		local args = table.pack(...)
		for _, v in HitboxHook.Hooks do
			if v[2](args) then return end
		end

		return oldhitbox(unpack(args, 1, args.n))
	end

	function HitboxHook:Add(key, val, priority)
		table.insert(self.Hooks, {key, val, priority or 0})
		table.sort(self.Hooks, function(a, b)
			return a[3] < b[3]
		end)

		if not oldhitbox then
			oldhitbox = hookfunction(tribes.Melee.Detect, function(...)
				return Hook(...)
			end)
		end
	end

	function HitboxHook:Remove(key)
		for i, v in self.Hooks do
			if v[1] == key then
				table.remove(self.Hooks, i)
				break
			end
		end

		if oldhitbox and not next(self.Hooks) then
			if restorefunction then
				restorefunction(tribes.Melee.Detect)
			else
				hookfunction(tribes.Melee.Detect, oldhitbox)
			end

			oldhitbox = nil
		end
	end

	function VelocityTracker:Get(root, diff)
		local entry = self.Entries[root]

		if entry and diff then
			local final, count = Vector3.zero, 0
			local ctime = os.clock()

			for _, velo in entry do
				if (ctime - velo[2]) <= diff then
					final += velo[1]
					count += 1
				end
			end

			if count > 0 then
				final /= count
				return Vector3.new(final.X, root.AssemblyLinearVelocity.Y, final.Z)
			end
		end

		return root.AssemblyLinearVelocity
	end
end)

for _, v in {'AutoClicker', 'TriggerBot', 'HitBoxes', 'Jesus', 'AutoRejoin', 'Disabler', 'MurderMystery', 'Parkour', 'Wallhop'} do
	vape:Remove(v)
end

run(function()
	local AimAssist
	local Targets
	local Sort
	local AimSpeed
	local Distance
	local AngleSlider
	local StrafeIncrease
	local Vertical
	local ClickAim
	
	AimAssist = vape.Categories.Combat:CreateModule({
		Name = 'AimAssist',
		Function = function(callback)
			if callback then
				AimAssist:Clean(runService.Heartbeat:Connect(function(dt)
					if entitylib.isAlive and tribes.State.handler and tribes.State.handler.lastSwing and ((not ClickAim.Enabled) or (os.clock() - (tribes.State.handler.lastSwing or 0)) < 0.5) then
						local entity = entitylib.EntityPosition({
							Range = Distance.Value,
							Part = 'RootPart',
							Wallcheck = Targets.Walls.Enabled,
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled
						})
	
						if entity then
							local delta = (entity.RootPart.Position - entitylib.character.RootPart.Position)
							local localfacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
							local angle = math.acos(localfacing:Dot((delta * Vector3.new(1, 0, 1)).Unit))
							if angle >= (math.rad(AngleSlider.Value) / 2) then return end
							targetinfo.Targets[entity] = os.clock() + 1
							local lerped = gameCamera.CFrame:Lerp(CFrame.lookAt(gameCamera.CFrame.Position, entity.RootPart.Position), (AimSpeed.Value + (StrafeIncrease.Enabled and (inputService:IsKeyDown(Enum.KeyCode.A) or inputService:IsKeyDown(Enum.KeyCode.D)) and 10 or 0)) * dt).LookVector
							tribes.Camera.SetLook(math.atan2(-lerped.X, -lerped.Z), Vertical.Enabled and math.asin(lerped.Y) or nil)
						end
					end
				end))
			end
		end,
		Tooltip = 'Smoothly aims to closest valid target with sword'
	})
	Targets = AimAssist:CreateTargets({
		Players = true,
		NPCs = true,
		Walls = true
	})
	AimSpeed = AimAssist:CreateSlider({
		Name = 'Aim Speed',
		Min = 1,
		Max = 20,
		Default = 6
	})
	Distance = AimAssist:CreateSlider({
		Name = 'Distance',
		Min = 1,
		Max = 30,
		Default = 30,
		Suffx = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AngleSlider = AimAssist:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 70
	})
	ClickAim = AimAssist:CreateToggle({
		Name = 'Click Aim',
		Default = true
	})
	Vertical = AimAssist:CreateToggle({
		Name = 'Vertical Aim'
	})
	StrafeIncrease = AimAssist:CreateToggle({
		Name = 'Strafe increase'
	})
end)

run(function()
	local Value
	local Arc
	local old
	
	Reach = vape.Categories.Combat:CreateModule({
		Name = 'Reach',
		Function = function(callback)
			if callback then
				HitboxHook:Add('Reach', function(args)
					args[2] += Value.Value
					args[3] = math.min(args[3] + Arc.Value, 90)
				end)
			else
				HitboxHook:Remove('Reach')
			end
		end,
		Tooltip = 'Extends attack reach'
	})
	Value = Reach:CreateSlider({
		Name = 'Range',
		Min = 0,
		Max = 4,
		Default = 4,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	Arc = Reach:CreateSlider({
		Name = 'Arc',
		Min = 0,
		Max = 60,
		Default = 60,
		Suffix = function(val)
			return val == 1 and 'degree' or 'degrees'
		end
	})
end)

run(function()
	local SilentAim
	local Target
	local Part
	local Range
	local HitChance
	local Prediction
	local PredictionTime
	local CircleColor
	local CircleTransparency
	local CircleFilled
	local CircleObject
	local ProjectileRaycast = RaycastParams.new()
	ProjectileRaycast.RespectCanCollide = true
	local Toggles = {}
	local old
	
	local function getMousePosition()
		if inputService.TouchEnabled then
			return gameCamera.ViewportSize / 2
		end
	
		return inputService:GetMouseLocation()
	end
	
	local function Hook(...)
		local handler
	
		for _, obj in debug.getstack(3) do
			if type(obj) == 'table' and rawget(obj, 'tuning') then
				handler = obj
				break
			end
		end
	
		if handler then
			if type(tribes.Handlers) == 'table' then
				for index, obj in next, tribes.Handlers do
					if getmetatable(handler) == obj and not Toggles[index].Enabled then
						return old(...)
					end
				end
			end
	
			local entity = entitylib.EntityMouse({
				Range = Range.Value,
				Part = Part.Value,
				Players = Target.Players.Enabled,
				NPCs = Target.NPCs.Enabled,
				Wallcheck = Target.Walls.Enabled and true or nil
			})
	
			if entity then
				local targetPart = entity[Part.Value]
				local origin = ... or gameCamera.CFrame.Position
				local projSpeed = handler.tuning.speed or (handler.tuning.speedMax or 200)
				local gravity = handler.tuning.gravity or (handler.spreadNow and 0 or 60)
				ProjectileRaycast.FilterDescendantsInstances = {gameCamera, entity.Character}
				ProjectileRaycast.CollisionGroup = targetPart.CollisionGroup
	
				if handler.drawStart then
					projSpeed = select(2, tribes.Combat.DrawnShot(handler.tuning, debug.getstack(3, 4)))
				end
	
				if handler.tuning.throw then
					projSpeed = handler.tuning.throw.speed or 120
					gravity = handler.tuning.throw.gravity or 0
				end
	
				local calc = prediction.SolveTrajectory(origin, projSpeed, math.abs(gravity), targetPart.Position + (Part.Value == 'Head' and Vector3.new(0, 0.3, 0) or Vector3.zero), Prediction.Enabled and VelocityTracker:Get(entity.RootPart, PredictionTime.Value) or targetPart.AssemblyLinearVelocity, workspace.Gravity, entity.HipHeight, nil, ProjectileRaycast)
				if calc then
					local lookDir = CFrame.lookAt(origin, calc).LookVector
					targetinfo.Targets[entity] = os.clock() + 1
	
					if handler.maxCharges then
						return (lookDir - Vector3.new(0, ((handler.kind == 'Bomb') and 0.16) or (((handler.kind == 'Sling') and 0.05) or (((handler.kind ~= 'Javelin') and 0.01) or 0.04)), 0)).Unit
					end
	
					if handler.tuning.throw then
						local aimPoint = debug.getstack(3, 5)
						local someMag = (aimPoint - origin).Magnitude
	
						if gravity > 0 and someMag > 1 then
							return (lookDir * someMag - Vector3.new(0, 0.5 * gravity * (someMag / projSpeed) * (someMag / projSpeed), 0)).Unit
						end
					end
	
					if handler.spreadNow and handler.kind ~= 'Blunderbuss' then
						local spread
						if handler.kind == 'Crossbow' then
							spread = 0
						elseif handler:Aimed() then
							spread = handler.tuning.spreadAim or 0
						else
							spread = handler.tuning.spreadHip or 0
						end
	
						local spreadDir = tribes.Combat.SpreadDir(lookDir, spread, handler:Seed(tribes.State.shotId + 1), 0)
						return (CFrame.lookAt(Vector3.zero, lookDir) * CFrame.lookAt(Vector3.zero, lookDir):ToObjectSpace(CFrame.lookAt(Vector3.zero, spreadDir)):Inverse()).LookVector
					end
	
					return lookDir
				end
			end
		end
	
		return old(...)
	end
	
	SilentAim = vape.Categories.Combat:CreateModule({
		Name = 'SilentAim',
		Function = function(callback)
			if CircleObject then
				CircleObject.Visible = callback
			end
	
			if callback then
				old = hookfunction(tribes.Util.AimDirection, function(...)
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
					if restorefunction then
						restorefunction(tribes.Util.AimDirection)
					else
						hookfunction(tribes.Util.AimDirection, old)
					end
					old = nil
				end
			end
		end,
		ExtraText = function()
			return 'Tribes'
		end,
		Tooltip = 'Silently adjusts your aim towards the enemy'
	})
	Target = SilentAim:CreateTargets({
		Players = true,
		NPCs = true
	})
	Part = SilentAim:CreateDropdown({
		Name = 'Part',
		List = {'RootPart', 'Head'},
		Tooltip = 'RootPart - Default\nHead - More damage, but harder to hit.'
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
	Prediction = SilentAim:CreateToggle({
		Name = 'Velocity prediction',
		Function = function(callback)
			PredictionTime.Object.Visible = callback
		end
	})
	PredictionTime = SilentAim:CreateSlider({
		Name = 'Prediction time',
		Min = 0,
		Max = 0.5,
		Default = 0.15,
		Decimal = 100,
		Visible = false,
		Darker = true
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
				CircleObject.Visible = SilentAim.Enabled
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
	
	if type(tribes.Handlers) == 'table' then
		for index in next, tribes.Handlers do
			if type(index) == 'string' then
				Toggles[index] = SilentAim:CreateToggle({
					Name = index,
					Default = true,
					Darker = true
				})
			end
		end
	end
end)

run(function()
	local SilentAura
	local Targets
	local AttackRange
	local AngleSlider
	local AutoSwing
	local AutoBlock
	
	SilentAura = vape.Categories.Combat:CreateModule({
		Name = 'SilentAura',
		Function = function(callback)
			if callback then
				local old, didSwing
	
				SilentAura:Clean(runService.PostSimulation:Connect(function()
					if entitylib.isAlive and tribes.State.handler and tribes.State.handler.lastSwing then
						local localPos = entitylib.character.RootPart.Position
						local localFacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
						local entities = entitylib.AllPosition({
							Range = AttackRange.Value,
							Wallcheck = Targets.Walls.Enabled or nil,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = 10
						})
	
						if #entities > 0 then
							for _, entity in entities do
								local cmpPos = entity.RootPart.Position
								local delta = (cmpPos - localPos)
								local yaw = select(2, gameCamera.CFrame:ToEulerAnglesYXZ())
								local angle = math.abs(CFrame.fromEulerAnglesYXZ(0, yaw, 0).LookVector:Angle(delta * Vector3.new(1, 0, 1)))
	
								if angle > (math.rad(AngleSlider.Value) / 2) or delta.Y >= 8 then
									continue
								end
	
								if AutoSwing.Enabled and not tribes.State.handler.holding then
									vim:SendMouseButtonEvent(gameCamera.ViewportSize.X / 2, gameCamera.ViewportSize.Y / 2, 0, true, nil, 0)
									didSwing = true
								end
	
								targetinfo.Targets[entity] = os.clock() + 1
								old = gameCamera.CFrame
								gameCamera.CFrame = CFrame.lookAlong(old.Position, CFrame.lookAt(localPos, cmpPos).LookVector)
								if angle > math.rad(100) then
									entitylib.character.RootPart.CFrame = CFrame.lookAlong(localPos, delta * Vector3.new(1, 0, 1))
								end
	
								break
							end
						else
							if AutoSwing.Enabled and tribes.State.handler.holding and didSwing then
								vim:SendMouseButtonEvent(gameCamera.ViewportSize.X / 2, gameCamera.ViewportSize.Y / 2, 0, false, nil, 0)
								didSwing = false
							end
						end
	
						--[[if AutoBlock.Enabled and tribes.State.handler.tuning.block then
							if tribes.State.handler:Ready() and #entities > 0 then
								tribes.State.handler:SetBlock(false)
								tribes.State.handler:Swing()
							end
	
							tribes.State.handler:SetBlock(true)
							if vape.ThreadFix then
								setthreadidentity(8)
							end
						end]]
					end
				end))
	
				SilentAura:Clean(runService.Heartbeat:Connect(function()
					if old then
						gameCamera.CFrame = old
						old = nil
					end
				end))
			end
		end,
		Tooltip = 'Silently adjust your camera towards nearby targets.'
	})
	Targets = SilentAura:CreateTargets({
		Players = true,
		NPCs = true
	})
	AttackRange = SilentAura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 14,
		Default = 14,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AngleSlider = SilentAura:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 90
	})
	AutoSwing = SilentAura:CreateToggle({
		Name = 'Auto swing'
	})
	--[[AutoBlock = SilentAura:CreateToggle({
		Name = 'AutoBlock'
	})]]
end)

run(function()
	local Velocity
	
	local function LocalAdded(char)
		Velocity:Clean(char.RootPart.AttributeChanged:Connect(function(key)
			if key:find('Kb') and char.RootPart:GetAttribute(key) then
				char.RootPart:SetAttribute(key, nil)
			end
		end))
	end
	
	Velocity = vape.Categories.Combat:CreateModule({
		Name = 'Velocity',
		Function = function(callback)
			if callback then
				Velocity:Clean(entitylib.Events.LocalAdded:Connect(LocalAdded))
				if entitylib.isAlive then
					LocalAdded(entitylib.character)
				end
			end
		end,
		Tooltip = 'Prevent the player from taking knockback'
	})
end)

run(function()
	local AntiFall
	
	AntiFall = vape.Categories.Blatant:CreateModule({
		Name = 'AntiFall',
		Function = function(callback)
			if callback then
				AntiFall:Clean(runService.Heartbeat:Connect(function()
					if entitylib.isAlive then
						local root = entitylib.character.RootPart
						local diff = math.max(root.Position.Y, -29.9) - root.Position.Y
	
						if math.abs(diff) > 0 then
							root.CFrame += Vector3.new(0, diff, 0)
							root.AssemblyLinearVelocity *= Vector3.new(1, 0, 1)
						end
					end
				end))
			end
		end,
		Tooltip = 'Prevents you from dying to the void'
	})
end)

run(function()
	local Killaura
	local Targets
	local AttackRange
	local AngleSlider
	local Max
	local Mouse
	local AutoBlock
	local BoxSwingColor
	local BoxAttackColor
	local ParticleTexture
	local ParticleColor1
	local ParticleColor2
	local ParticleSize
	local Particles, Boxes, AttackDelay = {}, {}, os.clock()
	local rand = Random.new()
	
	local function getAttackData()
		if Mouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
	
		if tribes.State.handler and tribes.State.handler.lastSwing then
			return tribes.State.handler.ctx.tool
		end
	end
	
	local function sanitizeAngle(cf)
		local y, x, z = cf:ToEulerAnglesYXZ()
		return CFrame.Angles(math.clamp(y, -1.3962634015954636, 1.361356816555577), x, z).LookVector
	end
	
	Killaura = vape.Categories.Blatant:CreateModule({
		Name = 'Killaura',
		Function = function(callback)
			if callback then
				repeat
					local tool = getAttackData()
					local attacked = {}
	
					if tool then
						local handler = tribes.State.handler
						local entities = entitylib.AllPosition({
							Range = AttackRange.Value,
							Wallcheck = Targets.Walls.Enabled or nil,
							Part = 'RootPart',
							Players = Targets.Players.Enabled,
							NPCs = Targets.NPCs.Enabled,
							Limit = Max.Value
						})
	
						if #entities > 0 then
							local localPos = entitylib.character.RootPart.Position
							local localFacing = entitylib.character.RootPart.CFrame.LookVector * Vector3.new(1, 0, 1)
	
							for _, entity in entities do
								local delta = (entity.RootPart.Position - localPos)
								local angle = math.abs(localFacing:Angle(delta * Vector3.new(1, 0, 1)))
								if angle > (math.rad(AngleSlider.Value) / 2) then
									continue
								end
	
								targetinfo.Targets[entity] = os.clock() + 1
								if #attacked < (handler.tuning.maxTargets or 1) then
									table.insert(attacked, {
										Entity = entity,
										Check = BoxAttackColor
									})
								end
							end
	
							if #attacked > 0 then
								local cmpPos = attacked[1].Entity.RootPart.Position
								local delta = (cmpPos - localPos)
								local angle = math.abs(localFacing:Angle(delta * Vector3.new(1, 0, 1)))
								if angle > math.rad(100) / 2 then
									entitylib.character.RootPart.CFrame = CFrame.lookAlong(localPos, delta * Vector3.new(1, 0, 1))
								end
	
								handler.lastSwing = os.clock()
								if AttackDelay < os.clock() and (AutoBlock.Enabled or not tribes.State.handler.blocking) then
									local targets = {}
									local cooldown = handler:Cooldown()
									local hitDelay = handler.preset.hitDelay or 0.1
	
									AttackDelay = os.clock() + cooldown
									for _, data in attacked do
										table.insert(targets, data.Entity.Character)
									end
	
									if AutoBlock.Enabled and handler.tuning.block then
										tribes.State.handler:SetBlock(false)
									end
	
									local oneHanded = handler:OneHanded()
									local comboTable = oneHanded and (handler.tuning.oneHanded.combo or {1}) or (handler.tuning.combo or {1})
									local animTable = oneHanded and handler.preset.oneSwings or handler.preset.swings or {}
									handler.combo = (handler.combo % #comboTable) + 1
									local finisher = (#comboTable > 2) and (handler.combo == #comboTable)
									local fakeTime = os.clock() - (hitDelay + (rand:NextNumber() * 0.02) - 0.01)
									tribes.Util.PlayAnim(handler.ctx.animator, animTable[((handler.combo - 1) % math.max(1, #animTable)) + 1], (handler.preset.swingSpeed or 1) * (finisher and 0.95 or 1), 0.05)
	
									handler.ctx.emit('Swing', {
										step = handler.combo,
										finisher = finisher,
										hitDelay = hitDelay,
										oneHanded = oneHanded
									})
	
									handler.ctx.send('Swing', {
										dir = sanitizeAngle(CFrame.lookAt(localPos + Vector3.new(0, 1.5, 0), attacked[1].Entity.RootPart.Position)),
										tool = tool,
										hits = targets,
										k = math.floor((os.clock() - fakeTime) * 1000),
										w = math.floor(fakeTime * 1000) % 9973
									})
	
									if AutoBlock.Enabled and handler.tuning.block then
										handler:SetBlock(true)
									end
	
									if vape.ThreadFix then
										setthreadidentity(8)
									end
								end
							end
						elseif AutoBlock.Enabled and handler.tuning.block then
							if tribes.Util.CanAct() then
								handler:SetBlock(true)
							end
	
							if vape.ThreadFix then
								setthreadidentity(8)
							end
						end
					end
	
					for index, box in Boxes do
						box.Adornee = attacked[index] and attacked[index].Entity.RootPart or nil
						if box.Adornee then
							box.Color3 = Color3.fromHSV(attacked[index].Check.Hue, attacked[index].Check.Sat, attacked[index].Check.Value)
							box.Transparency = 1 - attacked[index].Check.Opacity
						end
					end
	
					for index, particle in Particles do
						particle.Position = attacked[index] and attacked[index].Entity.RootPart.Position or Vector3.new(math.huge, math.huge, math.huge)
						particle.Parent = attacked[index] and gameCamera or nil
					end
	
					task.wait()
				until not Killaura.Enabled
			else
				for _, box in Boxes do
					box.Adornee = nil
				end
	
				for _, particle in Particles do
					particle.Parent = nil
				end
			end
		end,
		Tooltip = 'Attack players around you\nwithout aiming at them.'
	})
	Targets = Killaura:CreateTargets({
		Players = true,
		NPCs = true
	})
	AttackRange = Killaura:CreateSlider({
		Name = 'Attack range',
		Min = 1,
		Max = 14,
		Default = 14,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})
	AngleSlider = Killaura:CreateSlider({
		Name = 'Max angle',
		Min = 1,
		Max = 360,
		Default = 90
	})
	Max = Killaura:CreateSlider({
		Name = 'Max targets',
		Min = 1,
		Max = 10,
		Default = 10
	})
	Mouse = Killaura:CreateToggle({
		Name = 'Require mouse down'
	})
	AutoBlock = Killaura:CreateToggle({
		Name = 'AutoBlock'
	})
	Killaura:CreateToggle({
		Name = 'Show target',
		Function = function(callback)
			BoxSwingColor.Object.Visible = callback
			BoxAttackColor.Object.Visible = callback
	
			if callback then
				for i = 1, 10 do
					local box = Instance.new('BoxHandleAdornment')
					box.Adornee = nil
					box.AlwaysOnTop = true
					box.CFrame = CFrame.new(0, -0.5, 0)
					box.Size = Vector3.new(3, 5, 3)
					box.ZIndex = 0
					box.Parent = vape.holder
					Boxes[i] = box
				end
			else
				for _, box in Boxes do
					box:Destroy()
				end
				table.clear(Boxes)
			end
		end
	})
	BoxSwingColor = Killaura:CreateColorSlider({
		Name = 'Target Color',
		Darker = true,
		DefaultHue = 0.6,
		DefaultOpacity = 0.5,
		Visible = false
	})
	BoxAttackColor = Killaura:CreateColorSlider({
		Name = 'Attack Color',
		Darker = true,
		DefaultOpacity = 0.5,
		Visible = false
	})
	Killaura:CreateToggle({
		Name = 'Target particles',
		Function = function(callback)
			ParticleTexture.Object.Visible = callback
			ParticleColor1.Object.Visible = callback
			ParticleColor2.Object.Visible = callback
			ParticleSize.Object.Visible = callback
	
			if callback then
				for i = 1, 10 do
					local part = Instance.new('Part')
					part.Size = Vector3.new(2, 4, 2)
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1
					part.CanQuery = false
					part.Parent = Killaura.Enabled and gameCamera or nil
					local particles = Instance.new('ParticleEmitter')
					particles.Brightness = 1.5
					particles.Size = NumberSequence.new(ParticleSize.Value)
					particles.Shape = Enum.ParticleEmitterShape.Sphere
					particles.Texture = ParticleTexture.Value
					particles.Transparency = NumberSequence.new(0)
					particles.Lifetime = NumberRange.new(0.4)
					particles.Speed = NumberRange.new(16)
					particles.Rate = 128
					particles.Drag = 16
					particles.ShapePartial = 1
					particles.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
					})
					particles.Parent = part
					Particles[i] = part
				end
			else
				for _, particle in Particles do
					particle:Destroy()
				end
				table.clear(Particles)
			end
		end
	})
	ParticleTexture = Killaura:CreateTextBox({
		Name = 'Texture',
		Default = 'rbxassetid://14736249347',
		Function = function()
			for _, particle in Particles do
				particle.ParticleEmitter.Texture = ParticleTexture.Value
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor1 = Killaura:CreateColorSlider({
		Name = 'Color Begin',
		Function = function(hue, sat, val)
			for _, particle in Particles do
				particle.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(ParticleColor2.Hue, ParticleColor2.Sat, ParticleColor2.Value))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleColor2 = Killaura:CreateColorSlider({
		Name = 'Color End',
		Function = function(hue, sat, val)
			for _, particle in Particles do
				particle.ParticleEmitter.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(ParticleColor1.Hue, ParticleColor1.Sat, ParticleColor1.Value)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(hue, sat, val))
				})
			end
		end,
		Darker = true,
		Visible = false
	})
	ParticleSize = Killaura:CreateSlider({
		Name = 'Size',
		Min = 0,
		Max = 1,
		Default = 0.2,
		Decimal = 100,
		Function = function(val)
			for _, particle in Particles do
				particle.ParticleEmitter.Size = NumberSequence.new(val)
			end
		end,
		Darker = true,
		Visible = false
	})
end)

run(function()
	local old, oldshake, oldslow
	
	vape.Categories.Blatant:CreateModule({
		Name = 'NoRecoil',
		Function = function(callback)
			if callback then
				old = hookfunction(tribes.Util.Recoil, function() end)
				oldshake = hookfunction(tribes.Util.Shake, function() end)
				oldslow = hookfunction(tribes.Util.RecoilSlow, function() end)
			else
				if old then
					restorefunction(tribes.Util.Recoil)
					old = nil
				end
	
				if oldshake then
					restorefunction(tribes.Util.Shake)
					oldshake = nil
				end
	
				if oldslow then
					restorefunction(tribes.Util.RecoilSlow)
					oldslow = nil
				end
			end
		end,
		Tooltip = 'Remove camera shake & recoil from many aspects of the game.'
	})
end)

run(function()
	vape.Categories.Blatant:CreateModule({
		Name = 'NoSlowdown',
		Function = function(callback)
			if callback then
				old = hookfunction(tribes.SetSpeed, function() end)
				table.clear(tribes.State.speed)
			else
				if old then
					restorefunction(tribes.SetSpeed)
				end
			end
		end,
		Tooltip = 'Prevents slowing down when using items.'
	})
end)

run(function()
	local SpinBot
	local Mode
	local XToggle
	local YToggle
	local ZToggle
	local Value
	
	SpinBot = vape.Categories.Blatant:CreateModule({
		Name = 'SpinBot',
		Function = function(callback)
			if callback then
				SpinBot:Clean(runService.PreSimulation:Connect(function()
					if entitylib.isAlive then
						if Mode.Value == 'RotVelocity' then
							if entitylib.character.Humanoid.Sit then
								return
							end
	
							local original = entitylib.character.RootPart.AssemblyAngularVelocity
							entitylib.character.Humanoid.AutoRotate = false
							entitylib.character.RootPart.AssemblyAngularVelocity = Vector3.new(XToggle.Enabled and Value.Value or original.X, YToggle.Enabled and Value.Value or original.Y, ZToggle.Enabled and Value.Value or original.Z)
						elseif Mode.Value == 'CFrame' then
							if entitylib.character.Humanoid.Sit then
								return
							end
	
							local val = math.rad((os.clock() * (20 * Value.Value)) % 360)
							local x, y, z = entitylib.character.RootPart.CFrame:ToOrientation()
							entitylib.character.RootPart.CFrame = CFrame.new(entitylib.character.RootPart.Position) * CFrame.Angles(XToggle.Enabled and val or x, YToggle.Enabled and val or y, ZToggle.Enabled and val or z)
						end
					end
				end))
			else
				if entitylib.isAlive and Mode.Value == 'RotVelocity' then
					entitylib.character.Humanoid.AutoRotate = true
				end
			end
		end,
		Tooltip = 'Makes your character spin around in circles (does not work in first person)'
	})
	Mode = SpinBot:CreateDropdown({
		Name = 'Mode',
		List = {'CFrame', 'RotVelocity'},
		Tooltip = 'CFrame - Directly adjusts your characters angle\nRotVelocity - Sets the rotation velocity so that you spin'
	})
	Value = SpinBot:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 100,
		Default = 40
	})
	XToggle = SpinBot:CreateToggle({
		Name = 'Spin X'
	})
	YToggle = SpinBot:CreateToggle({
		Name = 'Spin Y',
		Default = true
	})
	ZToggle = SpinBot:CreateToggle({
		Name = 'Spin Z'
	})
end)

run(function()
	local NameTags
	local Targets
	local Color
	local Background
	local Stroke
	local DisplayName
	local Health
	local Distance
	local Equipment
	local DrawingToggle
	local Scale
	local FontOption
	local Teammates
	local DistanceCheck
	local DistanceLimit
	local Strings, Sizes, Reference = {}, {}, {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.gui
	local methodused
	
	local function getInventory(entity, state)
		local cmpId = type(entity) == 'string' and entity or entity.Character:GetAttribute('CombatantId')
		if state or tribes.UIState.Match then
			for _, team in (state or tribes.UIState.Match).teams do
				for _, member in team.members do
					if member.id == cmpId then
						local items = table.clone(member.loadout.items)
						if member.loadout.armor then
							table.insert(items, 1, member.loadout.armor)
						end
	
						return items
					end
				end
			end
		end
	end
	
	local function deepEq(tab, tab2)
		if type(tab) ~= 'table' or type(tab2) ~= 'table' then
			return tab == tab2
		end
	
		if #tab ~= #tab2 then
			return false
		end
	
		for i = 1, #tab do
			if tab[i] ~= tab2[i] then
				return false
			end
		end
	
		return true
	end
	
	local Added = {
		Normal = function(entity)
			if not Targets.Players.Enabled and entity.Player then return end
			if not Targets.NPCs.Enabled and entity.NPC then return end
			if Teammates.Enabled and (not entity.Targetable) and (not entity.Friend) then return end
			if vape.ThreadFix then
				setthreadidentity(8)
			end
	
			Strings[entity] = entity.Player and whitelist:tag(entity.Player, true, true)..(DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name
	
			if Health.Enabled then
				local healthColor = Color3.fromHSV(math.clamp(entity.Health / entity.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
				Strings[entity] = Strings[entity]..' <font color="#'..healthColor:ToHex()..'">'..math.round(entity.Health)..'</font>'
			end
	
			if Distance.Enabled then
				Strings[entity] = '<font color="#55ff55">[</font><font color="#ffffff">%s</font><font color="#55ff55">]</font> '..Strings[entity]
			end
	
			local nametag = Instance.new('TextLabel')
			nametag.TextSize = 14 * Scale.Value
			nametag.FontFace = FontOption.Value
			local size = getfontbounds(removeTags(Strings[entity]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
			nametag.Name = entity.Player and entity.Player.Name or entity.Character.Name
			nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7)
			nametag.AnchorPoint = Vector2.new(0.5, 1)
			nametag.BackgroundColor3 = Color3.new()
			nametag.BackgroundTransparency = Background.Value
			nametag.TextStrokeTransparency = Stroke.Value
			nametag.BorderSizePixel = 0
			nametag.Visible = false
			nametag.Text = Strings[entity]
			nametag.TextColor3 = entitylib.getEntityColor(entity) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.RichText = true
			nametag.Parent = Folder
	
			if Equipment.Enabled then
				local inv = getInventory(entity)
				if inv then
					local old = debug.getupvalue(tribes.WeaponRedraw, 1)
					debug.setupvalue(tribes.WeaponRedraw, 1, {})
	
					local holder = Instance.new('Frame')
					holder.AnchorPoint = Vector2.new(0.5, 0)
					holder.BackgroundTransparency = 1
					holder.Position = UDim2.fromScale(0.5, 0)
					holder.Size = UDim2.fromOffset(#inv * 30, 0)
					holder.Parent = nametag
	
					for i, item in inv do
						local Icon = Instance.new('Frame')
						Icon.BackgroundTransparency = 1
						Icon.Position = UDim2.fromOffset(-30 + (i * 30), -30)
						Icon.Size = UDim2.fromOffset(30, 30)
						Icon.Parent = workspace
	
						tribes.WeaponIcon(Icon, {id = item, opts = {glow = false, outline = false}})
						task.defer(function()
							Icon.Parent = holder
						end)
					end
	
					debug.setupvalue(tribes.WeaponRedraw, 1, old)
					if vape.ThreadFix then
						setthreadidentity(8)
					end
				end
			end
	
			Reference[entity] = nametag
		end,
		Drawing = function(entity)
			if not Targets.Players.Enabled and entity.Player then return end
			if not Targets.NPCs.Enabled and entity.NPC then return end
			if Teammates.Enabled and (not entity.Targetable) and (not entity.Friend) then return end
	
			local nametag = {}
			nametag.BG = Drawing.new('Square')
			nametag.BG.Filled = true
			nametag.BG.Transparency = 1 - Background.Value
			nametag.BG.Color = Color3.new()
			nametag.BG.ZIndex = 1
			nametag.Text = Drawing.new('Text')
			nametag.Text.Size = 15 * Scale.Value
			nametag.Text.Font = 0
			nametag.Text.ZIndex = 2
			Strings[entity] = entity.Player and whitelist:tag(entity.Player, true)..(DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name
	
			if Health.Enabled then
				Strings[entity] = Strings[entity]..' '..math.round(entity.Health)
			end
	
			if Distance.Enabled then
				Strings[entity] = '[%s] '..Strings[entity]
			end
	
			nametag.Text.Text = Strings[entity]
			nametag.Text.Color = entitylib.getEntityColor(entity) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
			Reference[entity] = nametag
		end
	}
	
	local Removed = {
		Normal = function(entity)
			local v = Reference[entity]
			if v then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Reference[entity] = nil
				Strings[entity] = nil
				Sizes[entity] = nil
				v:Destroy()
				v:ClearAllChildren()
			end
		end,
		Drawing = function(entity)
			local v = Reference[entity]
			if v then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Reference[entity] = nil
				Strings[entity] = nil
				Sizes[entity] = nil
				for _, obj in v do
					pcall(function()
						obj.Visible = false
						obj:Remove()
					end)
				end
			end
		end
	}
	
	local Updated = {
		Normal = function(entity)
			local nametag = Reference[entity]
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Sizes[entity] = nil
				Strings[entity] = entity.Player and whitelist:tag(entity.Player, true, true)..(DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name
	
				if Health.Enabled then
					local color = Color3.fromHSV(math.clamp(entity.Health / entity.MaxHealth, 0, 1) / 2.5, 0.89, 0.75)
					Strings[entity] = Strings[entity]..' <font color="#'..color:ToHex()..'">'..math.round(entity.Health)..'</font>'
				end
	
				if Distance.Enabled then
					Strings[entity] = '<font color="#55ff55">[</font><font color="#ffffff">%s</font><font color="#55ff55">]</font> '..Strings[entity]
				end
	
				local size = getfontbounds(removeTags(Strings[entity]), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
				nametag.Size = UDim2.fromOffset(size.X + 8, size.Y + 7)
				nametag.Text = Strings[entity]
			end
		end,
		Drawing = function(entity)
			local nametag = Reference[entity]
			if nametag then
				if vape.ThreadFix then
					setthreadidentity(8)
				end
				Sizes[entity] = nil
				Strings[entity] = entity.Player and whitelist:tag(entity.Player, true)..(DisplayName.Enabled and entity.Player.DisplayName or entity.Player.Name) or entity.Character.Name
	
				if Health.Enabled then
					Strings[entity] = Strings[entity]..' '..math.round(entity.Health)
				end
	
				if Distance.Enabled then
					Strings[entity] = '[%s] '..Strings[entity]
					nametag.Text.Text = entitylib.isAlive and string.format(Strings[entity], math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude)) or Strings[entity]
				else
					nametag.Text.Text = Strings[entity]
				end
	
				nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
				nametag.Text.Color = entitylib.getEntityColor(entity) or Color3.fromHSV(Color.Hue, Color.Sat, Color.Value)
			end
		end
	}
	
	local ColorFunc = {
		Normal = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for entity, v in Reference do
				v.TextColor3 = entitylib.getEntityColor(entity) or color
			end
		end,
		Drawing = function(hue, sat, val)
			local color = Color3.fromHSV(hue, sat, val)
			for entity, v in Reference do
				v.Text.Color = entitylib.getEntityColor(entity) or color
			end
		end
	}
	
	local Loop = {
		Normal = function()
			for entity, nametag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToViewportPoint(entity.RootPart.Position + Vector3.new(0, entity.HipHeight + 1, 0))
				nametag.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance.Enabled then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude) or 0
					if Sizes[entity] ~= mag then
						nametag.Text = string.format(Strings[entity], mag)
						local ize = getfontbounds(removeTags(nametag.Text), nametag.TextSize, nametag.FontFace, Vector2.new(100000, 100000))
						nametag.Size = UDim2.fromOffset(ize.X + 8, ize.Y + 7)
						Sizes[entity] = mag
					end
				end
	
				nametag.Position = UDim2.fromOffset(headPos.X, headPos.Y)
			end
		end,
		Drawing = function()
			for entity, nametag in Reference do
				if DistanceCheck.Enabled then
					local distance = entitylib.isAlive and (entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude or math.huge
					if distance < DistanceLimit.ValueMin or distance > DistanceLimit.ValueMax then
						nametag.Text.Visible = false
						nametag.BG.Visible = false
						continue
					end
				end
	
				local headPos, headVis = gameCamera:WorldToViewportPoint(entity.RootPart.Position + Vector3.new(0, entity.HipHeight + 1, 0))
				nametag.Text.Visible = headVis
				nametag.BG.Visible = headVis
				if not headVis then
					continue
				end
	
				if Distance.Enabled then
					local mag = entitylib.isAlive and math.floor((entitylib.character.RootPart.Position - entity.RootPart.Position).Magnitude) or 0
					if Sizes[entity] ~= mag then
						nametag.Text.Text = string.format(Strings[entity], mag)
						nametag.BG.Size = Vector2.new(nametag.Text.TextBounds.X + 8, nametag.Text.TextBounds.Y + 7)
						Sizes[entity] = mag
					end
				end
	
				nametag.BG.Position = Vector2.new(headPos.X - (nametag.BG.Size.X / 2), headPos.Y - nametag.BG.Size.Y)
				nametag.Text.Position = nametag.BG.Position + Vector2.new(4, 3)
			end
		end
	}
	
	NameTags = vape.Categories.Render:CreateModule({
		Name = 'NameTags',
		Function = function(callback)
			if callback then
				methodused = DrawingToggle.Enabled and 'Drawing' or 'Normal'
				if Removed[methodused] then
					NameTags:Clean(entitylib.Events.EntityRemoved:Connect(Removed[methodused]))
				end
				if Added[methodused] then
					for _, entity in entitylib.List do
						if Reference[entity] then
							Removed[methodused](entity)
						end
						Added[methodused](entity)
					end
					NameTags:Clean(entitylib.Events.EntityAdded:Connect(function(entity)
						if Reference[entity] then
							Removed[methodused](entity)
						end
						Added[methodused](entity)
					end))
	
					if Equipment.Enabled then
						local state = tribes.UIState.Match
						NameTags:Clean(replicatedStorage.Remotes.MatchState.OnClientEvent:Connect(function(newState, ...)
							task.defer(function()
								if state then
									for _, team in state.teams do
										for _, member in team.members do
											if not deepEq(getInventory(member.id, state), getInventory(member.id, newState)) then
												for _, entity in entitylib.List do
													if entity.Character:GetAttribute('CombatantId') == member.id then
														if Reference[entity] then
															Removed[methodused](entity)
														end
	
														Added[methodused](entity)
														break
													end
												end
											end
										end
									end
								end
	
								state = newState
							end)
						end))
					end
				end
				if Updated[methodused] then
					NameTags:Clean(entitylib.Events.EntityUpdated:Connect(Updated[methodused]))
					for _, entity in entitylib.List do
						Updated[methodused](entity)
					end
				end
				if ColorFunc[methodused] then
					NameTags:Clean(vape.Categories.Friends.ColorUpdate.Event:Connect(function()
						ColorFunc[methodused](Color.Hue, Color.Sat, Color.Value)
					end))
				end
				if Loop[methodused] then
					NameTags:Clean(runService.RenderStepped:Connect(Loop[methodused]))
				end
			else
				if Removed[methodused] then
					for entity in Reference do
						Removed[methodused](entity)
					end
				end
			end
		end,
		Tooltip = 'Renders nametags on entities through walls.'
	})
	Targets = NameTags:CreateTargets({
		Players = true,
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	FontOption = NameTags:CreateFont({
		Name = 'Font',
		Blacklist = 'Arial',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Color = NameTags:CreateColorSlider({
		Name = 'Player Color',
		Function = function(hue, sat, val)
			if NameTags.Enabled and ColorFunc[methodused] then
				ColorFunc[methodused](hue, sat, val)
			end
		end
	})
	Scale = NameTags:CreateSlider({
		Name = 'Scale',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = 1,
		Min = 0.1,
		Max = 1.5,
		Decimal = 10
	})
	Background = NameTags:CreateSlider({
		Name = 'Transparency',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = 0.5,
		Min = 0,
		Max = 1,
		Decimal = 10
	})
	Stroke = NameTags:CreateSlider({
		Name = 'Stroke Transparency',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = 1,
		Min = 0,
		Max = 1,
		Decimal = 10
	})
	Health = NameTags:CreateToggle({
		Name = 'Health',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Distance = NameTags:CreateToggle({
		Name = 'Distance',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	Equipment = NameTags:CreateToggle({
		Name = 'Equipment',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	DisplayName = NameTags:CreateToggle({
		Name = 'Use Displayname',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = true
	})
	Teammates = NameTags:CreateToggle({
		Name = 'Priority Only',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end,
		Default = true,
		Tooltip = 'Hides teammates & non targetable entities'
	})
	DrawingToggle = NameTags:CreateToggle({
		Name = 'Drawing',
		Function = function()
			if NameTags.Enabled then
				NameTags:Toggle()
				NameTags:Toggle()
			end
		end
	})
	DistanceCheck = NameTags:CreateToggle({
		Name = 'Distance Check',
		Function = function(callback)
			DistanceLimit.Object.Visible = callback
		end
	})
	DistanceLimit = NameTags:CreateTwoSlider({
		Name = 'Player Distance',
		Min = 0,
		Max = 256,
		DefaultMin = 0,
		DefaultMax = 64,
		Darker = true,
		Visible = false
	})
end)

run(function()
	local TrapESP
	local FillColor
	local OutlineColor
	local FillTransparency
	local OutlineTransparency
	local Walls
	local Reference = {}
	local Folder = Instance.new('Folder')
	Folder.Parent = vape.holder
	local Frame
	
	local function Added(obj)
		if vape.ThreadFix then
			setthreadidentity(8)
		end
	
		if obj:GetAttribute('Team') == lplr:GetAttribute('Team') then
			return
		end
	
		local box = Instance.new('BoxHandleAdornment')
		box.AlwaysOnTop = Walls.Enabled
		box.Adornee = obj
		box.Size = Vector3.new(3, 1, 3)
		box.ZIndex = 0
		box.Transparency = FillTransparency.Value
		box.Color3 = Color3.fromHSV(FillColor.Hue, FillColor.Sat, FillColor.Value)
		box.Parent = Folder
		Reference[obj] = box
	end
	
	local function Removed(obj)
		if Reference[obj] then
			if vape.ThreadFix then
				setthreadidentity(8)
			end
	
			Reference[obj]:Destroy()
			Reference[obj] = nil
		end
	end
	
	TrapESP = vape.Categories.Render:CreateModule({
		Name = 'TrapESP',
		Function = function(callback)
			if callback then
				TrapESP:Clean(collectionService:GetInstanceAddedSignal('BearTrap'):Connect(Added))
				TrapESP:Clean(collectionService:GetInstanceRemovedSignal('BearTrap'):Connect(Removed))
	
				for _, obj in collectionService:GetTagged('BearTrap') do
					task.spawn(Added, obj)
				end
			else
				Folder:ClearAllChildren()
				table.clear(Reference)
			end
		end,
		Tooltip = 'Render traps through walls'
	})
	FillColor = TrapESP:CreateColorSlider({
		Name = 'Color',
		Function = function(hue, sat, val)
			for _, entry in Reference do
				local color = Color3.fromHSV(hue, sat, val)
				entry.Color3 = color
			end
		end
	})
	FillTransparency = TrapESP:CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 1,
		Default = 0.5,
		Function = function(val)
			for _, entry in Reference do
				entry.Transparency = val
			end
		end,
		Decimal = 10
	})
	Walls = TrapESP:CreateToggle({
		Name = 'Render Walls',
		Function = function(callback)
			for _, entry in Reference do
				entry.AlwaysOnTop = callback
			end
		end,
		Default = true
	})
end)

run(function()
	local AutoQueue
	local Delay
	local Notification
	
	AutoQueue = vape.Categories.Utility:CreateModule({
		Name = 'AutoQueue',
		Function = function(callback)
			if callback then
				dumpInput()
	
				AutoQueue:Clean(vapeEvents.MatchEnded.Event:Connect(function()
					if Notification.Enabled and Delay.Value > 0 then
						notif('AutoQueue', 'Playing again in '..string.format('%.1f', Delay.Value)..' seconds!', Delay.Value)
					end
	
					task.delay(Delay.Value, function()
						local button = lplr.PlayerGui:FindFirstChild('TR_Menus')
						button = button and button:FindFirstChild('MatchEnd', true) or nil
						button = button and button:FindFirstChild('PlayAgain', true) or nil
	
						if button and button:IsA('TextButton') and realInput then
							firesignal(button.Activated, realInput, 0)
						end
					end)
				end))
			end
		end,
		Tooltip = 'Automatically requeue after the match ends.'
	})
	Delay = AutoQueue:CreateSlider({
		Name = 'Delay',
		Min = 0,
		Max = 2,
		Default = 1,
		Decimal = 10,
		Suffix = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})
	Notification = AutoQueue:CreateToggle({
		Name = 'Notification',
		Default = true
	})
end)

run(function()
	local AutoToxic
	local GG
	local Toggles, Lists, Cloned, Presets = {}, {}, {}, {}
	
	local function sendMessage(name, obj, default)
		local message = default
		if #Lists[name].ListEnabled > 0 then
			if #Cloned[name] <= 0 then
				Cloned[name] = table.clone(Lists[name].ListEnabled)
			end
	
			local entry = Random.new():NextInteger(1, #Cloned[name])
			message = Cloned[name][entry]
			table.remove(Cloned[name], entry)
		end
	
		if not message then return end
	
		message = message and message:gsub('<obj>', obj or '') or ''
		if textChatService:CanUserChatAsync(lplr.UserId) then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
		else
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendPresetAsync(Presets[message] or Presets['So close'])
		end
	end
	
	AutoToxic = vape.Categories.Utility:CreateModule({
		Name = 'AutoToxic',
		Function = function(callback)
			if callback then
				AutoToxic:Clean(vapeEvents.MatchEnded.Event:Connect(function(won)
					if GG.Enabled then
						if textChatService:CanUserChatAsync(lplr.UserId) then
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync('gg')
						else
							textChatService.ChatInputBarConfiguration.TargetTextChannel:SendPresetAsync(Presets['Good game'])
						end
					end
	
					if won then
						if Toggles.Win.Enabled then
							sendMessage('Win', nil, 'yall garbage')
						end
					end
				end))
			end
		end,
		Tooltip = 'Says a message after a certain action'
	})
	GG = AutoToxic:CreateToggle({
		Name = 'AutoGG',
		Default = true
	})
	for _, v in {'Win'} do
		Cloned[v] = {}
		Toggles[v] = AutoToxic:CreateToggle({
			Name = v..' ',
			Function = function(callback)
				if Lists[v] then
					Lists[v].Object.Visible = callback
				end
			end
		})
		Lists[v] = AutoToxic:CreateTextList({
			Name = v,
			Darker = true,
			Visible = false,
			Function = function()
				table.clear(Cloned[v])
			end
		})
	end
	
	pcall(function()
		for _, group in textChatService:GetPresetsAsync().categoryGroups do
			for _, category in group.categories do
				for _, message in category.messages do
					Presets[message.value] = message.presetId
				end
			end
		end
	end)
end)

run(function()
	local AutoSkip
	
	AutoSkip = vape.Categories.Inventory:CreateModule({
		Name = 'AutoSkip',
		Function = function(callback)
			if callback then
				dumpInput()
				repeat
					local bind = contextActionService:GetBoundActionInfo('TR_RevealKeys')
					if bind.priorityLevel == 3050 then
						local reveal = lplr.PlayerGui:FindFirstChild('TR_Reveal')
						local button1 = reveal and reveal:FindFirstChild('Skip', true) or nil
						local button2 = reveal and reveal:FindFirstChild('Continue', true) or nil
	
						if button1 and button1:IsA('TextButton') and button2 and button2:IsA('TextButton') and realInput then
							firesignal(button1.Activated, realInput, 0)
							firesignal(button2.Activated, realInput, 0)
						end
					end
	
					task.wait(0.05)
				until not AutoSkip.Enabled
			end
		end,
		Tooltip = 'Automatically skip through all crate popups'
	})
end)

run(function()
	local AutoUpgrade
	
	AutoUpgrade = vape.Categories.Inventory:CreateModule({
		Name = 'AutoUpgrade',
		Function = function(callback)
			if callback then
				dumpInput()
	
				repeat
					local gui = lplr.PlayerGui:FindFirstChild('TR_Menus')
					gui = gui and gui:FindFirstChild('Collection', true) or nil
	
					if gui and gui:IsA('Frame') then
						local holder = gui:FindFirstChild('Grid', true)
	
						if holder and holder:IsA('ScrollingFrame') then
							for _, button in holder:GetChildren() do
								if button:IsA('TextButton') then
									local upgrade = button:FindFirstChild('Upgrade', true)
	
									if upgrade and upgrade:IsA('TextButton') and upgrade.Visible and realInput then
										firesignal(upgrade.Activated, realInput, 0)
										break
									end
								end
							end
						end
					end
	
					task.wait(0.05)
				until not AutoUpgrade.Enabled
			end
		end,
		Tooltip = 'Automatically upgrade all collectable gear.'
	})
end)