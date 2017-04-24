observer = {}

function observer.create()
    local self = {}
    setmetatable(self, {__index = observer})

    self.listeners = {}

    return self
end

function observer:add_listener(event, callback)
    -- If there's no listener table for the event create it.
    if not self.listeners[event] then
        self.listeners[event] = {}
    end

    table.insert(self.listeners[event], callback)
end

function observer:notify(event)
    for k, callback in pairs(self.listeners[event]) do
        callback()
    end
end