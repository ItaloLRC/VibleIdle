--!nonstrict
local RateLimiter = {}

function RateLimiter.new(rate, capacity, now)
    return { rate = rate, capacity = capacity, tokens = capacity, last = now }
end

function RateLimiter.allow(bucket, now)
    if type(now) ~= "number" or now ~= now or now == math.huge or now < bucket.last then return false end
    bucket.tokens = math.min(bucket.capacity, bucket.tokens + (now - bucket.last) * bucket.rate)
    bucket.last = now
    if bucket.tokens < 1 then return false end
    bucket.tokens = bucket.tokens - 1
    return true
end

return RateLimiter
