--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LASSO — Shared rules
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

LXRLasso = LXRLasso or {}
local R = LXRLasso

function R.HasRope(items)
    for _, it in pairs(items or {}) do
        if it then for _, n in ipairs(Config.Rope.hogtieItems) do if it.name == n and (it.amount or 0) > 0 then return it end end end
    end
    return nil
end

function R.HasKnife(items)
    if not Config.Rope.knifeToCut then return true end
    for _, it in pairs(items or {}) do
        local rec = it and LXRShared.WeaponsByName and LXRShared.WeaponsByName[it.name]
        if rec and rec.category == 'melee' then return true end
    end
    return false
end

function R.IsLaw(job)
    if not Config.Rope.lawOnly then return true end
    local def = job and LXRShared.Jobs and LXRShared.Jobs[job.name]
    local t = def and def.type
    return (t == 'leo' or t == 'federal') and job.onduty == true
end
