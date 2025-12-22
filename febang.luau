local MGUI = --[[ require("./mgui") or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/mgui.luau"))()
local AnimationController = --[[ require("./animutilv2.luau") -- or ]] loadstring(game:HttpGet("https://raw.githubusercontent.com/AltIsBacc/RobloxScripts/master/animutilv2.luau"))()
local Players = game:GetService("Players")

type DisplayNameMapping = { [string]: string }

local DisplayNameMap: DisplayNameMapping = {}

local function initDisplayNameMap()
	for _, Player in Players:GetPlayers() do
		DisplayNameMap[Player.DisplayName] = Player.Name
	end

	Players.PlayerAdded:Connect(function(NewPlayer: Player)
		DisplayNameMap[NewPlayer.DisplayName] = NewPlayer.Name
	end)

	Players.PlayerRemoving:Connect(function(Player: Player)
		DisplayNameMap[Player.DisplayName] = nil
	end)
end

local function Main()
	initDisplayNameMap()

	local WinOpt = MGUI.DefaultWindowOptions
	WinOpt.WindowTitle = "Simple Sex GUI"
	WinOpt.WindowSize = { X = 317, Y = 280 }
	WinOpt.ResetOnSpawn = false

	local MainWin = MGUI.CreateWindow(WinOpt)

	local MainSec = MainWin:CreateSection("Sex")
	local Status = MainSec:CreateLabel("you freaky 😈❓️")
	local TargetPlayer = MainSec:CreateInputField("Target Player", Players.LocalPlayer:GetFullName().split(".")[2], nil)
	local BangSpeed = MainSec:CreateInputField("Bang Speed", 10, 10)

	local function redir(a: string) Status:UpdateLabel(a) end

	local WeStoppingNow = false
	
	local FollowTask: thread? = nil
	local Anim = AnimationController.new {
		owner = Players.LocalPlayer,
		speed = BangSpeed:GetText(),
		r6AnimId = "rbxassetid://148840371",
		r15AnimId = "rbxassetid://5918726674",

		onError = redir,
		onStatusChange = redir,
	}

	
	MainSec:CreateButton("Commence 😈", function()
		if WeStoppingNow then
			Anim:Stop()
			if FollowTask then task.cancel(FollowTask) end

			Status:UpdateLabel("stopped banging 😈")
			workspace.FallenPartsDestroyHeight = -500
		else
			Anim._config.speed = tonumber(BangSpeed:GetText()) or 1
			Anim:Start()

			local Target = Players:FindFirstChild(TargetPlayer:GetText())
			if not Target then
				Target = Players:FindFirstChild(DisplayNameMap[TargetPlayer:GetText()])
			end

			FollowTask = Anim:FollowTarget(Target, CFrame.new(0, 0, 1.1))
			Status:UpdateLabel("we fucking now 😈😈😈")
			
			workspace.FallenPartsDestroyHeight = -1000
		end
		WeStoppingNow = not WeStoppingNow
	end)
end

Main()