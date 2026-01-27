local PartCache = {}
PartCache.__index = PartCache

function PartCache.new(template: Part, prewarmAmount: number?, container: Instance?)
    local self = setmetatable({}, PartCache)

    self._template = template
    self._container = container or workspace
    self._reusePool = {}
    self._cache = {}

    if prewarmAmount and prewarmAmount > 0 then
        for i = 1, prewarmAmount do
            local item = self._template:Clone()
            self:_prepare(item)
            table.insert(self._cache, item)
        end
    end

    return self
end

function PartCache:_prepare(item: Part)
    item.Parent = self._container
end

function PartCache:_flush()
    for _, item in ipairs(self._reusePool) do
        table.insert(self._cache, item)
    end
    table.clear(self._reusePool)
end

function PartCache:get(): Part
    if #self._cache == 0 then
        self:_flush()
    end

    local item
    if #self._cache == 0 then
        item = self._template:Clone()
        self:_prepare(item)
    else
        item = table.remove(self._cache)
    end

    return item :: Part
end

function PartCache:reuse(item: Part)
    table.insert(self._reusePool, item)
end

return PartCache