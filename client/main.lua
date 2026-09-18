--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LASSO — Client: the game's rope on players, and what the tied can be
     ═══════════════════════════════════════════════════════════════════════════
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local LXRCore = exports['lxr-core']:GetCoreObject()
local R = LXRLasso
local wasTied = false

local function me() return LXRCore.PlayerData or {} end
local function sid(e) return GetPlayerServerId(NetworkGetPlayerIndexFromPed(e)) end
local function toast(key, kind, vars) LXRCore.Notify(Lang:t(key, vars), kind or 'info') end

-- let the game rope and hogtie this ped
local function flags()
    local ped = PlayerPedId()
    SetPedLassoHogtieFlag(ped, 1, Config.Rope.allowLasso)
    SetPedLassoHogtieFlag(ped, 6, Config.Rope.allowLasso)
 end

-- the tied state, seen from the tied
CreateThread(function()
    while true do
        Wait(1000)
        if LocalPlayer.state.isLoggedIn then
            flags()
            local ped = PlayerPedId()
            local now = IsPedHogtied(ped)
            if now and not wasTied then
                wasTied = true
                TriggerServerEvent('lxr-lasso:server:hogtied')
                SetHogtieEscapeTimer(ped, (Config.Rope.escapeSeconds or 0) * 1000)
            elseif not now and wasTied then
                wasTied = false
                if LocalPlayer.state.tied then TriggerServerEvent('lxr-lasso:server:free', nil, 'loose') end
            end
        end
    end
end)

RegisterNetEvent('lxr-lasso:client:hogtie', function(targetId)
    local idx = GetPlayerFromServerId(targetId)
    local target = idx ~= -1 and GetPlayerPed(idx) or 0
    if target == 0 then return end
    TaskHogtieTargetPed(PlayerPedId(), target)
end)

RegisterNetEvent('lxr-lasso:client:free', function(byId, how)
    local ped = PlayerPedId()
    if IsPedHogtied(ped) then
        if byId then
            local idx = GetPlayerFromServerId(byId)
            local cutter = idx ~= -1 and GetPlayerPed(idx) or 0
            if cutter ~= 0 then TaskCutFreeHogtiedTargetPed(cutter, ped) return end
        end
        ClearPedTasksImmediately(ped, false, false)
    end
end)

RegisterCommand('lasso_wriggle', function() if LocalPlayer.state.tied then TriggerServerEvent('lxr-lasso:server:free', nil, 'loose') end end, false)
RegisterKeyMapping('lasso_wriggle', 'Wriggle loose', 'keyboard', 'X')

CreateThread(function()
    while GetResourceState('lxr-interact') ~= 'started' do Wait(1000) end
    local I = exports['lxr-interact']
    local isTied = function(e) return e and Player(sid(e)).state.tied == true end
    I:AddGlobal('lxr-lasso:player', 'player', { label = Lang:t('ui.person'), distance = Config.Rope.distance, options = {
        { label = Lang:t('ui.tie'), key = 'G', canInteract = function(e) return e and not isTied(e) and R.IsLaw(me().job) and R.HasRope(me().items) ~= nil end, onSelect = function(d) TriggerServerEvent('lxr-lasso:server:tie', sid(d.entity)) end },
        { label = Lang:t('ui.cut'), key = 'G', canInteract = function(e) return isTied(e) and R.HasKnife(me().items) end, onSelect = function(d) TriggerServerEvent('lxr-lasso:server:free', sid(d.entity), 'cut') end },
        { label = Lang:t('ui.untie'), key = 'H', canInteract = function(e) return isTied(e) and not Config.Rope.knifeToCut end, onSelect = function(d) TriggerServerEvent('lxr-lasso:server:free', sid(d.entity), 'untie') end },
        { label = Lang:t('ui.carry'), key = 'E', canInteract = function(e) return Config.Rope.carry and isTied(e) and GetCarrierAsPed(e) == 0 end, onSelect = function(d) TaskPickupCarriableEntity(PlayerPedId(), d.entity) end },
        { label = Lang:t('ui.put_down'), key = 'E', canInteract = function(e) return Config.Rope.carry and isTied(e) and GetCarrierAsPed(e) == PlayerPedId() end, onSelect = function(d)
            local pos = GetEntityCoords(PlayerPedId()) + GetEntityForwardVector(PlayerPedId()) * 1.2
            TaskPlaceCarriedEntityAtCoord(PlayerPedId(), d.entity, pos.x, pos.y, pos.z, 0.0, 0)
        end },
        { label = Lang:t('ui.on_horse'), key = 'R', canInteract = function(e) return Config.Rope.carry and isTied(e) and GetCarrierAsPed(e) == PlayerPedId() and GetMountOwnedByPlayer(PlayerId()) ~= 0 end, onSelect = function(d)
            TaskPlaceCarriedEntityOnMount(PlayerPedId(), d.entity, GetMountOwnedByPlayer(PlayerId()), 0)
        end },
    }})
end)

RegisterNetEvent('lxr:client:loaded', function() Wait(1500) TriggerServerEvent('lxr-lasso:server:ready') end)
exports('IsTied', function() return LocalPlayer.state.tied == true end)
