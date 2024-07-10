local redis = require "resty.redis"
local cjson = require "cjson.safe"

-- Connect to Redis
local function connect_redis()
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec

    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect to Redis: ", err)
        return nil
    end
    return red
end

local function check_blacklist(red, ip)
    local res, err = red:get("blacklist:" .. ip)
    if res == "1" then
        return true
    end
    return false
end

local function add_to_blacklist(red, ip)
    local res, err = red:setex("blacklist:" .. ip, 86400, "1") -- 24 hours
    if not res then
        ngx.log(ngx.ERR, "failed to add to blacklist: ", err)
    end
end

local function increment_failures(red, ip)
    local res, err = red:incr("failures:" .. ip)
    if not res then
        ngx.log(ngx.ERR, "failed to increment failures: ", err)
        return 0
    end
    red:expire("failures:" .. ip, 86400) -- 24 hours
    return res
end

local function get_user_id(red, token)
    local user_id, err = red:get(token)
    if not user_id or user_id == ngx.null then
        return nil
    end
    return user_id
end

-- Main logic
local red = connect_redis()
if not red then
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    return
end

local ip = ngx.var.remote_addr
if check_blacklist(red, ip) then
    ngx.exit(ngx.HTTP_FORBIDDEN)
    return
end

local token = ngx.var.arg_token
if not token then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end

local user_id = get_user_id(red, token)
if not user_id then
    local failures = increment_failures(red, ip)
    if failures >= 3 then
        add_to_blacklist(red, ip)
    end
    ngx.exit(ngx.HTTP_FORBIDDEN)
    return
end

ngx.var.user_id = user_id
