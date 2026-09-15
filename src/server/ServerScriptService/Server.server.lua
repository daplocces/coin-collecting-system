const Players = game:GetService("Players")

const CoinService = require("./CoinService")
task.spawn(CoinService.init)

const numericValues = {
	Coins = 0 :: number
}

Players.PlayerAdded:Connect(function(playerAdded: Player)
	const leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = playerAdded
	
	for nN, nV in numericValues do
		local newVal = Instance.new("NumberValue")
		newVal.Name = nN
		newVal.Value = nV
		newVal.Parent = leaderstats
	end
end)