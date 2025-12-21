local PlayerGetter = {}
PlayerGetter.__index = PlayerGetter
PlayerGetter.DisplayNameCache = {}

function PlayerGetter.Init(PlayerManager: Players)
	local self = setmetatable({}, PlayerGetter)
	self.PlayerManager = PlayerManager

	for _, Player in PlayerManager:GetPlayers() do
		self.DisplayNameCache[Player.DisplayName] = Player.DisplayName
	end

	PlayerManager.PlayerAdded:Connect(function(NewPlayer: Player)
		self.DisplayNameCache[NewPlayer.DisplayName] = NewPlayer.Name
	end)

	PlayerManager.PlayerRemoving:Connect(function(Player: Player)
		self.DisplayNameCache[Player.DisplayName] = nil
	end)

	return self :: any
end

function PlayerGetter:GetPlayerFromDisplayName(DisplayName: string): Player
	return self.PlayerManager:FindFirstChild(self.DisplayNameCache[DisplayName])
end

return PlayerGetter
