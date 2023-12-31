-- tyzone
-- Used by Hit and CustomPhysicsReplicator


local ParabolaModule = {}

local function CubeRoot(x) -- Get the cube root while preserving the negative or positive operand
	local Multiplier = x > 0 and 1 or -1
	return Multiplier * (x * Multiplier)^(1/3)
end

local function CubicRoots(A, B, C, D) -- Parameters are coefficients of a cubic polynomial ax^3 + bx^2 + cx + d = 0
	-- Use the cubic formula here to solve for x (in our case, t) - https://math.vanderbilt.edu/schectex/courses/cubic/cubic.gif
	local O = -B/(3*A)
	local P = (3*A*C - B^2) / (3*A^2)
	local Q = (2*B^3 - 9*A*B*C + 27*A*A*D) / (27*A^3)
	
	local Delta = -4*P^3 - 27*Q^2
	
	local z0, z1, z2
	if Delta < 0 then
		local k0, k1, k2
		k0 = -Q/2
		k1 = (Q^2)/4
		k2 = (P^3)/27
		
		
		--k1 + k2 is always positive here
		local sqrtsum = math.sqrt(k1 + k2)
		
		z0 = CubeRoot(k0 + sqrtsum) + CubeRoot(k0 - sqrtsum)
		--local z0 = (math.abs(k0) + math.sqrt(k1 + k2))^0.3333 + (math.abs(k0) - math.sqrt(k1 + k2))^0.3333
		--if k0 < 0 then z0 = -z0 end
	else
		local M = 2*math.sqrt(-P/3)
		local Phi = math.acos(3*Q/(M*P))
		z0 = M*math.cos(Phi/3)
		z1 = M*math.cos((Phi + 2*math.pi)/3)
		z2 = M*math.cos((Phi + 4*math.pi)/3)
	end
	return z0 + O, z1 and z1 + O, z2 and z2 + O
	-- z1 and z2 only exist if Delta is 0 or greater, so we do 'z1 and z1 + O' to return nil before trying to add nil and a number
end

local h = 1/240

local function ClosestTime(p0, v0, a, p1)
	local dp = p0 - p1
	
	local vOff = v0 + .5 * h * a
	
	a *= 0.5
	
	--We only use those for verification right now
	local QA, QB, QC, QD, QE
	QA = a.Y^2 --yes
	QB = 2*a.Y*vOff.Y --yes
	QC = vOff:Dot(vOff) + 2*a.Y*dp.Y
	QD = 2*vOff:Dot(dp)
	QE = dp:Dot(dp)
	
	local A,B,C,D
	A = 4*QA
	B = 3*QB
	C = 2*QC
	D = QD
	
	local function quartic(t)
		return QA*t^4 + QB*t^3 + QC*t^2 + QD*t + QE
	end
	
	local roots = {CubicRoots(A,B,C,D)}
	table.sort(roots, 
		function(t1, t2)
			return quartic(t1) < quartic(t2)
		end
	)
	return roots[1]
end

local function getOffset(a, t)
	
	return .5 * h * a * t
end

function ParabolaModule:ClosestVector(...)
	local t = ClosestTime(...)
	local p0, v0, a = ...
	
	return 
		p0 + (v0 * t) + (0.5 * a * t^2) + getOffset(a,t), -- Position at time t
		v0 + (a * t), -- Velocity at time t
		t -- Time t (probably will not be used)
end

function ParabolaModule:Eval(...)
	local p0, v0, a, t0, t1 = ...
	local dt = t1-t0
	return 
		p0 + (v0 * dt) + (0.5 * a * dt^2) + getOffset(a,dt), -- Position at time t
		v0 + (a * dt)
end

function ParabolaModule:Check(...)
	local ClosestPosition = self:ClosestVector(...)
	local _, _, _, p1, AllowedFallout = ...
	local Dist = (ClosestPosition - p1).Magnitude
	local safe = Dist <= AllowedFallout
	if not safe then
		--print(Dist,(Dist <= AllowedFallout and "<" or ">"),tostring(AllowedFallout))
		--print(ClosestPosition)
		--print(p1)
	end
	return safe
end

--[[ Tyzone
Uses "average" of two parabolas to find the true touch position of the projectile.
Why not just use Projectile.Position at the moment of touch? Physics is computed at
4x the speed of touch events firing. Means that the position could be up to 4 frames off,
which is intolerable for our security system.
]]
function ParabolaModule:FindTouchPoint(a,   p0, v0, t0,   p1, v1, t1)
	--[[
	The coefficients get too large if we use arbitrary values for time.
	This can cause floating point errors.
	We're only interested in time differences, so we set t0=0 for this calculation.
	We revert this change at the very end of the function.
	]]
	
	--local ERROR_CONSTANT = 0.0020387359836901
	
	--TODO: the "a" in the function params only accounts for the bodyforce.
	--The "a" in our formula should account for gravity + bodyforce.

	local dt = t1 - t0
	local off = getOffset(a, dt)
	
	
	local ka = 0.5 * a
	local kb = v0
	local kc = p0
	
	local kd = ka
	local ke = v1 - a * dt
	local kf = p1 - v1 * dt + 0.5 * a * dt^2
	kf = kf - off
	
	--[[
	local ka = 0.5 * a
	local kb = v0
	local kc = p0

	local kd = ka
	local ke = v1 - a * dt
	local kf = p1 - v1 * dt + 0.5*a*dt^2 - off*dt
	]]

	local L = ke - kb
	local M = kf - kc

	local SameParabola = (L.Magnitude < 10e-1 and M.Magnitude < 0.1)
	--print("SameParabola =",SameParabola,"(",L.Magnitude,",",M.Magnitude,",",v0.Magnitude,")")

	local tTouch = (M:Dot(L)) / (L:Dot(L))

	if (L*tTouch + M).Magnitude > (-L*tTouch + M).Magnitude then
		tTouch = -tTouch
	end

	local idt0 = tTouch
	local pTouch0 = p0 + (v0 * idt0) + (ka * idt0^2) + getOffset(a, idt0)
	--[[
	local idt1Candidates = {
		tTouch - dt,
		(tTouch - dt) * 3/4,
		(tTouch - dt) * 2/4,
		(tTouch - dt) * 1/4,
	}
	local bestPTouch = nil
	local bestDistance = math.huge
	for _,w in pairs(idt1Candidates) do
		local pCandidate = p1 + (v1 * w) + (kd * w^2) + getOffset(a, w)
		local ClosestPosition = self:ClosestVector(p0, v0, a, pCandidate)
		local Dist = (ClosestPosition - p).Magnitude
		
	end]]
	local idt1 = tTouch - dt
	local pTouch1 = p1 + (v1 * idt1) + (kd * idt1^2) + getOffset(a, idt1)
	local vTouch = v1 + a * idt1
	
	--print(off * idt1)

	--[[
	print("COEFFICIENTS")
	print(ka.magnitude, kb.magnitude, kc.magnitude)
	print(kd.magnitude, ke.magnitude, kf.magnitude)
	
	print("Position:",CFrameIWant.Position)
	print("Position 2:",p3)

	local s0 = game.ReplicatedStorage.SBVis:Clone()
	s0.Parent = game.Workspace
	s0.CFrame = CFrame.new(pTouch0)
	s0.BrickColor = BrickColor.new("Bright red")

	local s1 = game.ReplicatedStorage.SBVis:Clone()
	s1.Parent = game.Workspace
	s1.CFrame = CFrame.new(pTouch1)
	s1.BrickColor = BrickColor.new("Bright blue")
	]]
	
	if ((p0-p1).magnitude < 10e-3) and ((v0-v1).magnitude < 10e-3) then
		pTouch1 = p1
		vTouch = v1
		tTouch = (t0 + t1) / 2
		SameParabola = true
	end

	return pTouch1, vTouch, tTouch + t0, SameParabola, ka, kb, kc, kd, ke, kf, L.Magnitude, M.Magnitude
	-- everything past the fourth arg is for debugging purposes only
end

return ParabolaModule