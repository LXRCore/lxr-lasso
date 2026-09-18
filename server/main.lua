--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LASSO — Server: who is tied, who may tie, who may cut
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local R = LXRLasso
local RES = GetCurrentResourceName()
local tied = {}    -- src → { by, at }
local buckets = {}

local function limited(src)
    local b = buckets[src]
    local now = GetGameTimer()
    if not b or now - b.at > Config.Security.rateLimit.windowMs then b = { at = now, n = 0 } buckets[src] = b end
    b.n = b.n + 1
    return b.n > Config.Security.rateLimit.burst
end
local function player(src) return LXRCore.Functions.GetPlayer(src) end
local function notify(src, key, kind, vars) LXRCore.Notify(src, Lang:t(key, vars), kind or 'info') end
local function near(a, b)
    local pa, pb = GetPlayerPed(a), GetPlayerPed(b)
    return pa ~= 0 and pb ~= 0 and #(GetEntityCoords(pa) - GetEntityCoords(pb)) <= Config.Security.maxDistance
end

local function set(t, on, by)
    if on then tied[t] = { by = by, at = GetGameTimer() } else tied[t] = nil end
    Player(t).state:set('tied', on == true, true)
    LXRCore.Emit('lxr:lasso:tied', nil, t, on == true, by)
end

-- the game did the hogtie (lasso or hand); the tied player's client reports it
RegisterNetEvent('lxr-lasso:server:hogtied', function(byId)
    local src = source
    if limited(src) then return end
    if not player(src) then return end
    set(src, true, tonumber(byId))
end)

RegisterNetEvent('lxr-lasso:server:tie', function(targetId)
    local src = source
    if limited(src) then return end
    local P, T = player(src), player(tonumber(targetId) or -1)
    if not P or not T or T.PlayerData.source == src then return end
    local t = T.PlayerData.source
    if not near(src, t) then return notify(src, 'error.too_far', 'error') end
    if tied[t] then return notify(src, 'error.already', 'error') end
    if not R.IsLaw(P.PlayerData.job) then return notify(src, 'error.not_law', 'error') end
    if not R.HasRope(P.PlayerData.items) then return notify(src, 'error.no_rope', 'error') end
    TriggerClientEvent('lxr-lasso:client:hogtie', src, t)
end)

RegisterNetEvent('lxr-lasso:server:free', function(targetId, how)
    local src = source
    if limited(src) then return end
    local P = player(src)
    local t = tonumber(targetId) or src
    if not P or not tied[t] then return end
    if t == src then
        local after = (Config.Rope.escapeSeconds or 0) * 1000
        if after <= 0 or GetGameTimer() - tied[t].at < after then return notify(src, 'error.too_soon', 'error') end
    else
        if not near(src, t) then return notify(src, 'error.too_far', 'error') end
        if how == 'cut' and not R.HasKnife(P.PlayerData.items) then return notify(src, 'error.no_knife', 'error') end
    end
    set(t, false, src)
    TriggerClientEvent('lxr-lasso:client:free', t, src ~= t and src or nil, how)
    notify(t, 'info.you_free', 'inform')
    if t ~= src then notify(src, 'info.freed', 'success') end
end)

RegisterNetEvent('lxr-lasso:server:ready', function() local src = source Player(src).state:set('tied', tied[src] ~= nil, true) end)
AddEventHandler('playerDropped', function() tied[source] = nil buckets[source] = nil end)
CreateThread(function() if Config.Debug.printBanner then print(('^1[lxr-lasso]^7 v%s'):format(GetResourceMetadata(RES, 'version', 0))) end end)

exports('IsTied', function(src) return tied[src] ~= nil end)
exports('Free', function(src) if tied[src] then set(src, false, nil) TriggerClientEvent('lxr-lasso:client:free', src, nil, 'export') return true end return false end)
