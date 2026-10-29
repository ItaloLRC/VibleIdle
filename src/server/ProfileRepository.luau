--!nonstrict
-- Dependency injected so locking and data validation can be tested without Roblox.
local Repository = {}
Repository.__index = Repository

function Repository.new(store, stateModule, balance, clock, leaseSeconds)
    return setmetatable({ store = store, stateModule = stateModule, balance = balance,
        clock = clock, leaseSeconds = leaseSeconds }, Repository)
end

function Repository:acquire(key, owner)
    local denied
    local ok, result = pcall(function()
        return self.store:UpdateAsync(key, function(old)
            local now=self.clock()
            denied = nil
            if old ~= nil and type(old) ~= "table" then denied = "invalid_record"; return nil end
            if old and old.schemaVersion ~= self.balance.SCHEMA_VERSION
                and old.schemaVersion ~= 1 and old.schemaVersion ~= 2 and old.schemaVersion ~= 3
                and old.schemaVersion ~= 4 and old.schemaVersion ~= 5 and old.schemaVersion ~= 6 and old.schemaVersion ~= 7 and old.schemaVersion ~= 8 and old.schemaVersion ~= 9 and old.schemaVersion ~= 10 and old.schemaVersion ~= 11 and old.schemaVersion ~= 12 and old.schemaVersion ~= 13 and old.schemaVersion ~= 14 and old.schemaVersion ~= 15 and old.schemaVersion ~= 16 and old.schemaVersion ~= 17 then
                denied = "unsupported_schema"; return nil
            end
            if old and (type(old.data) ~= "table" or old.data.schemaVersion ~= old.schemaVersion) then
                denied = "invalid_record"; return nil
            end
            if old and old.lock then
                if type(old.lock) ~= "table" or type(old.lock.owner) ~= "string"
                    or not self.stateModule.isFinite(old.lock.expiresAt) then
                    denied = "invalid_lock"; return nil
                end
                if old.lock.owner ~= owner and old.lock.expiresAt > now then denied = "profile_busy"; return nil end
            end
            local data = self.stateModule.new(self.balance)
            if old then
                local parsed, reason = self.stateModule.fromStored(old.data, self.balance)
                if not parsed then denied = reason; return nil end
                data = parsed
            end
            return { schemaVersion = self.balance.SCHEMA_VERSION, data = data,
                lock = { owner = owner, expiresAt = now + self.leaseSeconds } }
        end)
    end)
    if not ok then return nil, "storage_error" end
    if denied then return nil, denied end
    if type(result) ~= "table" or not result.lock or result.lock.owner ~= owner then return nil, "acquire_failed" end
    local data, reason = self.stateModule.fromStored(result.data, self.balance)
    if not data then return nil, reason end
    return { key = key, owner = owner, expiresAt = result.lock.expiresAt, state = data }
end

function Repository:save(handle, release)
    local denied
    local snapshot, reason = self.stateModule.fromStored(handle.state, self.balance)
    if not snapshot then return false, reason end
    local ok, result = pcall(function()
        return self.store:UpdateAsync(handle.key, function(old)
            local now=self.clock()
            denied = nil
            if type(old) ~= "table" or type(old.lock) ~= "table"
                or old.lock.owner ~= handle.owner or not self.stateModule.isFinite(old.lock.expiresAt)
                or old.lock.expiresAt <= now then denied = "lease_lost"; return nil end
            if old.schemaVersion ~= self.balance.SCHEMA_VERSION then denied = "unsupported_schema"; return nil end
            local lease = nil
            if not release then lease = { owner = handle.owner, expiresAt = now + self.leaseSeconds } end
            return { schemaVersion = self.balance.SCHEMA_VERSION, data = snapshot, lock = lease }
        end)
    end)
    if not ok then return false, "storage_error" end
    if denied then return false, denied end
    if type(result) ~= "table" then return false, "save_failed" end
    if not release then handle.expiresAt = result.lock.expiresAt end
    return true
end

return Repository
