--!strict
-- Thegameboy

local WeldTracker = {}
WeldTracker.__index = WeldTracker

function WeldTracker.new(root)
	return setmetatable({
		root = root;
		didStart = false;
		activeWelds = {};
		weldsByPart = {};
	}, WeldTracker)
end

function WeldTracker:Start()
	if self.didStart then return end
	self.didStart = true
	
	local activeWelds = self.activeWelds
	local weldsByPart = self.weldsByPart
	local weldToCons = {}
	
	local function onDescendantAdded(i)
		local class = i.ClassName
		if class ~= "WeldConstraint" and class ~= "Weld" and class ~= "Snap" then return end
		activeWelds[i] = true
		
		local part0 = i.Part0
		local function onPart0Changed()
			if weldsByPart[part0] then
				weldsByPart[part0][i] = nil
			end
			
			local newPart = i.Part0
			if newPart then
				weldsByPart[newPart] = weldsByPart[newPart] or {}
				weldsByPart[newPart][i] = true
			end
			part0 = newPart
		end
		
		local part1 = i.Part1
		local function onPart1Changed()
			if weldsByPart[part1] then
				weldsByPart[part1][i] = nil
			end
			
			local newPart = i.Part1
			if newPart then
				weldsByPart[newPart] = weldsByPart[newPart] or {}
				weldsByPart[newPart][i] = true
			end
			part1 = newPart
		end
		
		local cons = {}
		weldToCons[i] = cons
		
		table.insert(cons, i:GetPropertyChangedSignal("Part0"):Connect(onPart0Changed))
		table.insert(cons, i:GetPropertyChangedSignal("Part1"):Connect(onPart1Changed))
		onPart0Changed()
		onPart1Changed()
	end
	
	self.root.DescendantAdded:Connect(onDescendantAdded)
	for _, i in pairs(self.root:GetDescendants()) do
		onDescendantAdded(i)
	end
	
	self.root.DescendantRemoving:Connect(function(i)
		local class = i.ClassName
		if class ~= "WeldConstraint" and class ~= "Weld" and class ~= "Snap" then return end
		activeWelds[i] = nil
		
		local part0 = i.Part0
		if part0 then
			local welds = weldsByPart[part0]
			welds[i] = nil
		end
		
		local part1 = i.Part1
		if part1 then
			local welds = weldsByPart[part1]
			welds[i] = nil
		end
		
		for _, con in pairs(weldToCons[i]) do
			con:Disconnect()
		end
		weldToCons[i] = nil
	end)
end

function WeldTracker:GetWelds()
	return self.activeWelds
end

function WeldTracker:GetWeldsByPart(part)
	local entry = self.weldsByPart[part]
	if entry == nil then
		return {}
	end
	
	local array = {}
	for weld in pairs(entry) do
		table.insert(array, weld)
	end
	
	return array
end

local singleton = WeldTracker.new(workspace)
singleton:Start()
return singleton