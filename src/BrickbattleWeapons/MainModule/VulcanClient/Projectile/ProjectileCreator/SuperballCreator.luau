--!strict
local VulcanClient = script.Parent.Parent.Parent

local DependencyUtils = require(VulcanClient.Management.DependencyUtils)
local PartCache = DependencyUtils.getPartCache()

local Config = require(VulcanClient.Management.ClientConfig)

local config = Config.get()

local SuperballCreator = {}

function SuperballCreator.create(player: Player): Part
	local part: Part = PartCache:GetPart()
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
