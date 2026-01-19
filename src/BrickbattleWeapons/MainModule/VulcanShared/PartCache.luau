local ObjectCache = {}
ObjectCache.__index = ObjectCache

function ObjectCache.new(template: BasePart, prewarmAmount: number?, container: Instance?)
    local self = setmetatable({}, ObjectCache)

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

function ObjectCache:_prepare(item: BasePart)
    item.Parent = self._container
end

function ObjectCache:_flush()
    for _, item in ipairs(self._reusePool) do
        table.insert(self._cache, item)
    end
    table.clear(self._reusePool)
end

function ObjectCache:get(): BasePart
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

    return item :: BasePart
end

function ObjectCache:reuse(item: BasePart)
    table.insert(self._reusePool, item)
end

return ObjectCache