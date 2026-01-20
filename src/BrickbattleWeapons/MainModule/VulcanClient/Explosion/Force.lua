--!nonstrict
local Force = {}
local Collections = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local function getExplosionImpulseValues(ExplosionPosition, Part, BlastRadius, Pressure, Mass)
	--This technically encompasses limbs and accessories...
	--...But isn't there a cleaner way?
	local IsInCharacter = (
		(Part.Parent:FindFirstChildWhichIsA("Humanoid")
		) or
			(Part.Parent.Parent:FindFirstChildWhichIsA("Humanoid")
			)
	)

	local delta = Part.Position - ExplosionPosition
	local normal = (delta == Vector3.new(0,0,0))
		and Vector3.new(0,1,0)
		or  delta.unit

	local r = delta.magnitude
	local radius = Part.Size.magnitude / 2
	local surfaceArea = radius * radius
	local impulse = normal * Pressure * surfaceArea * (1.0 / 4560.0)

	local frac, mass
	if IsInCharacter then
		frac = 2-- - math.max(0, math.min(1, (r-2)/BlastRadius))
		mass = 0
		local parts = Part:GetConnectedParts(true)
		for _,p in pairs(parts) do
			mass += p.Mass
		end
	else
		frac = 1
		mass = Part.Mass
	end

	local currentVelocity = Part.Velocity
	local deltaVelocity = impulse / mass
	local accelNeeded = workspace.Gravity

	local rotImpulse = impulse * 0.5 * radius
	local currentRotVelocity = Part.RotVelocity
	local momentOfInertia = (2 * Part:GetMass() * radius * radius / 5) -- moment of inertia = 2/5*m*r^2 (assuming roughly spherical)
	local deltaRotVelocity = rotImpulse / momentOfInertia
	local torqueNeeded = 20 * momentOfInertia
	
	accelNeeded = accelNeeded * 10 * frac
	torqueNeeded = torqueNeeded * 10 * frac

	return deltaVelocity, accelNeeded, deltaRotVelocity, torqueNeeded
end

--https://devforum.roblox.com/t/explosion-visible-true-false/6170/31
function Force:Exert(ExplosionPosition, Part, BlastRadius, Pressure, Mass)
	
	if Part and workspace:IsAncestorOf(Part) and (Part:CanSetNetworkOwnership() and Part:GetNetworkOwner() == nil) then

		local dV, accel, dRV, torque = getExplosionImpulseValues(
			ExplosionPosition, Part, BlastRadius, Pressure, Mass
		)
		
		local dt = 0.1
		
		local force = accel * Part.Mass
		local bodyV = Instance.new('BodyVelocity')
		bodyV.velocity = Part.Velocity + dV
		bodyV.maxForce = Vector3.new(force, force, force)
		Collections:AddTag(bodyV,"BodyMoverServer")
		bodyV.Parent = Part
		Debris:AddItem(bodyV, dt)

		local rot = Instance.new('BodyAngularVelocity')
		rot.Name = "BodyAngularVelocityServer"
		rot.angularvelocity = Part.RotVelocity + dRV
		rot.maxTorque = Vector3.new(torque, torque, torque)
		Collections:AddTag(rot,"BodyMoverServer")
		rot.Parent = Part
		Debris:AddItem(rot, dt)
	end
end

-- No rotational force
function Force:ExertDirectionally(ExplosionPosition, Part, BlastRadius, Pressure, Mass)
	if Part then
		local dV, accel, dRV, torque = getExplosionImpulseValues(
			ExplosionPosition, Part, BlastRadius, Pressure, Mass
		)
		local dt = 0.1
		
		--Boost for player and bomb
		dV *= 1.5
		
		local IsInCharacter = (
			(Part.Parent:FindFirstChildWhichIsA("Humanoid")
			) or
				(Part.Parent.Parent:FindFirstChildWhichIsA("Humanoid")
				)
		)
		
		if IsInCharacter then
			local mul = 1.5
			dV = Vector3.new(dV.X * mul, dV.Y, dV.Z * mul)
		end
		
		
		--[[
		local maxSpeed = math.sqrt(3*accel^2) * dt
		print(dV.Magnitude, maxSpeed)
		if dV.Magnitude > maxSpeed then
			dV = dV.Unit * maxSpeed
		end
		]]
		
		local dx, dy, dz = dV.X, dV.Y, dV.Z
		
		--[[
		local maxSpeed = accel * dt
		
		if dx > maxSpeed then dx = maxSpeed end
		if dx < -maxSpeed then dx = -maxSpeed end
		if dy > maxSpeed then dy = maxSpeed end
		if dy < -maxSpeed then dy = -maxSpeed end
		if dz > maxSpeed then dz = maxSpeed end
		if dz < -maxSpeed then dz = -maxSpeed end
		]]


		local maxSpeed = accel * dt
		local maxSpeedXZ = maxSpeed * 1.5

		if dx > maxSpeedXZ then dx = maxSpeedXZ end
		if dx < -maxSpeedXZ then dx = -maxSpeedXZ end
		if dy > maxSpeed then dy = maxSpeed end
		if dy < -maxSpeed then dy = -maxSpeed end
		if dz > maxSpeedXZ then dz = maxSpeedXZ end
		if dz < -maxSpeedXZ then dz = -maxSpeedXZ end
		
		dV = Vector3.new(dx, dy, dz)
		
		Part.Velocity = Part.Velocity + dV

	end
end

function Force:ExertLocally(ExplosionPosition,Part, BlastRadius, Pressure,Mass)
	if Part then
		local dV, accel, dRV, torque = getExplosionImpulseValues(
			ExplosionPosition, Part, BlastRadius, Pressure, Mass
		)
		
		local force = accel * Part.Mass
		--Get rid of bodymover later
		local bodyV = Instance.new('BodyVelocity', Part)
		bodyV.velocity = Part.Velocity + dV
		bodyV.maxForce = Vector3.new(force, force, force)
		game.Debris:AddItem(bodyV, 0.1)
		
		--Get rid of bodymover later
		local rot = Instance.new('BodyAngularVelocity', Part)
		rot.angularvelocity = Part.RotVelocity + dRV
		rot.maxTorque = Vector3.new(torque, torque, torque)
		game.Debris:AddItem(rot, 0.1)
	end
end


return Force
