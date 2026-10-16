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

local gameCamera = workspace.CurrentCamera
local lplr = playersService.LocalPlayer
local vape = shared.vape
local entitylib = vape.Libraries.entity
local whitelist = vape.Libraries.whitelist
local prediction = vape.Libraries.prediction
local targetinfo = vape.Libraries.targetinfo
local sessioninfo = vape.Libraries.sessioninfo

local tribes = {}

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

run(function()
	entitylib.targetCheck = function(entity)
		if entity.TeamCheck then
			return entity:TeamCheck()
		end
		if entity.NPC then return true end
		if isFriend(entity.Player) then return false end
		if not select(2, whitelist:get(entity.Player)) then return false end
		return lplr:GetAttribute('Team') ~= entity.Player:GetAttribute('Team')
	end

	entitylib.addPlayer = function(plr)

	end

	local oldstart = entitylib.start
	local function customEntity(entity)
		local plr = playersService:GetPlayerFromCharacter(entity)
		entitylib.addEntity(entity, plr, not plr and function(self)
			return lplr:GetAttribute('Team') ~= self.Character:GetAttribute('Team')
		end or nil)
	end

	entitylib.start = function()
		oldstart()
		if entitylib.Running then
			for _, ent in collectionService:GetTagged('Combatant') do
				customEntity(ent)
			end

			table.insert(entitylib.Connections, collectionService:GetInstanceAddedSignal('Combatant'):Connect(customEntity))
			table.insert(entitylib.Connections, collectionService:GetInstanceRemovedSignal('Combatant'):Connect(function(ent)
				entitylib.removeEntity(ent)
			end))
		end
	end
end)
entitylib.start()

run(function()
	tribes = {
		Combat = require(replicatedStorage.Shared.Combat),
		CombatController = require(lplr.PlayerScripts.Combat.Controller),
		Economy = require(lplr.PlayerScripts.UI.Economy),
		Weapons = require(replicatedStorage.Shared.Weapons),
		Util = require(lplr.PlayerScripts.Combat.Util)
	}

	tribes.State = debug.getupvalue(tribes.CombatController.State, 2)
	tribes.SetSpeed = debug.getupvalue(debug.getupvalue(tribes.CombatController.Equip, 11), 15)

	local kills = sessioninfo:AddItem('Kills')
	local deaths = sessioninfo:AddItem('Deaths')
	local games = sessioninfo:AddItem('Games')
	local wins = sessioninfo:AddItem('Wins')

	if not workspace:FindFirstChild('Lobby') then
		task.delay(1, function()
			games:Increment()
		end)
	end

	vape:Clean(replicatedStorage.Remotes.HitConfirm.OnClientEvent:Connect(function(data)
		if data and data.killed then
			kills:Increment()
		end
	end))

	vape:Clean(replicatedStorage.Remotes.MatchEvent.OnClientEvent:Connect(function(event, data)
		if event == 'MatchEnd' then
			local didWin = data and data.winnerTeam == lplr:GetAttribute('Team')
			if didWin then
				wins:Increment()
			end

			vapeEvents.MatchEnded:Fire(didWin)
		elseif event == 'Elimination' and data and data.victimId == 'p'..lplr.UserId then
			deaths:Increment()
		end
	end))
end)

for _, v in {'Reach', 'TriggerBot', 'Jesus', 'AutoRejoin', 'Disabler', 'MurderMystery', 'Parkour', 'Wallhop'} do
	vape:Remove(v)
end

run(function()
	local SilentAim
	local Target
	local Range
	local HitChance
	local CircleColor
	local CircleTransparency
	local CircleFilled
	local CircleObject
	local old
	
	local function Hook(...)
		local tuning
	
		for _, obj in debug.getstack(3) do
			if type(obj) == 'table' and rawget(obj, 'tuning') then
				tuning = obj
				break
			end
		end
	
		if tuning then
			local entity = entitylib.EntityMouse({
				Range = Range.Value,
				Part = 'RootPart',
				Players = Target.Players.Enabled,
				NPCs = Target.NPCs.Enabled
			})
	
			if entity then
				local targetPart = entity.RootPart
				local origin = ... or gameCamera.CFrame.Position
				local projSpeed = tuning.tuning.speed or (tuning.tuning.speedMax or 200)
	
				if tuning.drawSound then
					projSpeed = select(2, tribes.Combat.DrawnShot(tuning.tuning, debug.getstack(3, 4)))
				end
	
				local calc = prediction.SolveTrajectory(origin, projSpeed, math.abs(tuning.tuning.gravity or 60), targetPart.Position, entity.RootPart.AssemblyLinearVelocity)
				if calc then
					targetinfo.Targets[entity] = os.clock() + 1
					return CFrame.lookAt(origin, calc).LookVector
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
						CircleObject.Position = inputService:GetMouseLocation()
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
	local Killaura
	local Targets
	local CPS
	local SwingRange
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
	local Particles, Boxes, AttackDelay, AnimDelay, BlockDelay = {}, {}, os.clock(), os.clock(), os.clock()
	
	local function block(didAttack, tool)
		if not didAttack and BlockDelay > os.clock() then
			return
		end
	
		BlockDelay = os.clock() + 0.05
		local handler = tribes.State.handler
		if handler.tuning.block then
			if handler.blocking then
				handler.ctx.send('Block', {tool = tool, on = true})
			else
				handler:SetBlock(true)
			end
	
			if vape.ThreadFix then
				setthreadidentity(8)
			end
		end
	end
	
	local function getAttackData()
		if Mouse.Enabled then
			if not inputService:IsMouseButtonPressed(0) then return false end
		end
	
		if tribes.State.handler and tribes.State.handler.lastSwing then
			return tribes.State.tool
		end
	end
	
	Killaura = vape.Categories.Blatant:CreateModule({
		Name = 'Killaura',
		Function = function(callback)
			if callback then
				repeat
					local tool = getAttackData()
					local attacked = {}
	
					if tool then
						local didAttack = false
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
								table.insert(attacked, {
									Entity = entity,
									Check = BoxAttackColor
								})
							end
	
							if #attacked > 0 then
								local cmpPos = attacked[1].Entity.RootPart.Position
								local delta = (cmpPos - localPos)
								local angle = math.abs(localFacing:Angle(delta * Vector3.new(1, 0, 1)))
								if angle > math.rad(100) / 2 then
									entitylib.character.RootPart.CFrame = CFrame.lookAlong(localPos, delta * Vector3.new(1, 0, 1))
								end
	
								if AttackDelay < os.clock() and (AutoBlock.Enabled or not tribes.State.handler.blocking) then
									AttackDelay = os.clock() + 0.05
	
									local targets = {}
									local handler = tribes.State.handler
									handler.lastSwing = os.clock()
									for _, data in attacked do
										table.insert(targets, data.Entity.Character)
									end
	
									if AnimDelay < os.clock() then
										AnimDelay = os.clock() + (handler.tuning.cooldown or 0.5)
										local comboTable = handler.tuning.combo or {1}
										local animTable = handler.preset.swings or {}
	
										handler.combo = (handler.combo % #comboTable) + 1
										tribes.Util.PlayAnim(handler.ctx.animator, animTable[((handler.combo - 1) % math.max(1, #animTable)) + 1], (handler.preset.swingSpeed or 1), 0.05)
										handler.ctx.emit('Swing', {
											step = handler.combo,
											finisher = (#comboTable > 2) and (handler.tuning.combo == #comboTable),
											hitDelay = handler.preset.hitDelay or 0.1
										})
									end
	
									didAttack = true
									handler.ctx.send('Swing', {
										dir = CFrame.lookAt(localPos, attacked[1].Entity.RootPart.Position).LookVector,
										tool = tool,
										hits = targets
									})
	
									if vape.ThreadFix then
										setthreadidentity(8)
									end
								end
							end
						end
	
						if AutoBlock.Enabled then
							block(didAttack, tool)
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
	local AutoQueue
	
	AutoQueue = vape.Categories.Utility:CreateModule({
		Name = 'AutoQueue',
		Function = function(callback)
			if callback then
				AutoQueue:Clean(vapeEvents.MatchEnded.Event:Connect(function()
					task.spawn(function()
						replicatedStorage.Remotes.QueueAction:InvokeServer('PlayAgain')
					end)
				end))
			end
		end,
		Tooltip = 'Automatically requeue after the match ends.'
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
	local AutoUpgrade
	
	AutoUpgrade = vape.Categories.Inventory:CreateModule({
		Name = 'AutoUpgrade',
		Function = function(callback)
			if callback then
				repeat
					if lplr.Character and (not lplr.Character:GetAttribute('MatchId') or lplr.Character:GetAttribute('MatchId') == '') then
						local item = tribes.Economy.ReadyList()[1]
						if item then
							tribes.Economy.Upgrade(item)
						end
					end
	
					task.wait(0.05)
				until not AutoUpgrade.Enabled
			end
		end,
		Tooltip = 'Automatically upgrade all collectable gear.'
	})
end)