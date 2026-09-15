const CoinService = {}
CoinService.__index = CoinService

const Players = game:GetService("Players")
const RunService = game:GetService("RunService")

const COIN_AMOUNT = 10 :: number
const GAP_IN_BETWEEN = 2 :: number
const PLAY_SOUND = false :: boolean
const LOAD_COINS_ON_START = true :: boolean -- Equivalent to COIN_AMOUNT
const COIN_PROPERTIES = {
	CanCollide = false,
	Anchored = true
}

const function GetRandomPosition() : Vector3
	const spawnArea = script:GetAttribute("SpawnArea"):Get() :: Object
	if spawnArea then
		local x : number
		local z : number
		
		repeat task.wait()
			x = math.random(spawnArea.Position.X - spawnArea.Size.X / 2, spawnArea.Position.X + spawnArea.Size.X/2)
			z = math.random(spawnArea.Position.Z - spawnArea.Size.Z / 2, spawnArea.Position.Z + spawnArea.Size.Z/2)
		until math.abs(x - z) > GAP_IN_BETWEEN
		
		return Vector3.new(x, spawnArea.Position.Y + spawnArea.Size.Y / 2, z) :: Vector3
	end
	
	return Vector3.zero
end

function CoinService:collect()
	if PLAY_SOUND then
		const collectSound: Sound = self.coin:FindFirstChild("Collecting", true)
		if collectSound then
			collectSound:Play()
		end
	end
	
	self.coin:Destroy()
	
	for _, v in self.connections do
		v:Disconnect()
		v = nil
	end
end

function CoinService:create()
	self.coin = script.CoinModel:Clone() :: Model
	self.coin.Parent = script:GetAttribute("SpawnArea"):Get() or workspace
	self.pos = GetRandomPosition()
	self.coin:PivotTo(CFrame.new(self.pos))
	
	if type(COIN_PROPERTIES) == "table" then
		for pN, pV in COIN_PROPERTIES do
			self.coin.PrimaryPart[pN] = pV
		end
	end
	
	self.connections = {}
	
	self.connections.touchConn = self.coin.PrimaryPart.Touched:Connect(function(otherPart : BasePart)
		const player: Player = Players:GetPlayerFromCharacter(otherPart.Parent)
		if player then
			self:collect()
			player.leaderstats.Coins.Value += 1
		end
	end)
	
	self.connections.rfConn = RunService.Heartbeat:Connect(function(_)
		self.coin:PivotTo(self.coin:GetPivot() * CFrame.Angles(0, math.rad(1), 0))
	end)
end

function CoinService.new() : Coin & CoinService
	return setmetatable({}, CoinService) :: Coin & CoinService
end

function CoinService.init()
	if LOAD_COINS_ON_START then
		for _ = 1, COIN_AMOUNT do
			CoinService.new():create()
		end
	end
	
	script:GetAttribute("SpawnArea"):Get().ChildRemoved:Connect(function(child: Instance)
		task.delay(math.random(1, 5), function()
			CoinService.new():create() 
		end)
	end)
end

type Coin = {
	pos: Vector3
}

type CoinService = typeof(CoinService)

return CoinService
