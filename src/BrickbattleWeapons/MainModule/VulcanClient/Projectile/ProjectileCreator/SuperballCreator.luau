--!strict
local VulcanClient = script.Parent.Parent.Parent

local PartCache = require(VulcanClient.Common.PartCache)

local Config = require(VulcanClient.Management.ClientConfig)

local config = Config.get()

local SuperballCreator = {}

local part = Instance.new("Part")
part.Anchored = true
local partCache = PartCache.new(part, 200, workspace.Projectiles.Buffers)

function SuperballCreator.create(player: Player): Part
	local part: Part = partCache:get()
	part.Name = player.Name.."'s Superball"

	part.Size = config.Superball.PartConfig.Size
	part.Shape = config.Superball.PartConfig.Shape
	part.CustomPhysicalProperties = config.Superball.PartConfig.PhysicalProperties

	part.CastShadow = false
	part.Massless = false
	part.Anchored = false
	part.CanCollide = true
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.TopSurface = Enum.SurfaceType.Smooth

	return part
end

return SuperballCreator
