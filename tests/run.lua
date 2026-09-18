--[[ ═══════════════════════════════════════════════════════════════════════════
     LXR-LASSO — Offline tests: rope and knives from the catalog, locale parity
     Usage (from the lxr-lasso folder):  lua tests/run.lua
     © 2026 iBoss21 / LXRCore — All Rights Reserved
     ═══════════════════════════════════════════════════════════════════════════ ]]

local CORE = os.getenv('LXR_CORE_PATH') or '../lxr-core'
package.path = CORE .. '/?.lua;' .. package.path
local ok = pcall(function() require('tests.lib.fxshim') end)
if not ok then print('lxr-core shim not found at ' .. CORE) os.exit(2) end
local Shim = require('tests.lib.fxshim')
for _, f in ipairs({ 'shared/main.lua', 'shared/locale.lua', 'locales/en.lua', 'config.lua', 'shared/catalog.lua', 'shared/items.lua', 'shared/prices.lua', 'shared/weapons.lua', 'shared/jobs.lua' }) do Shim.load(CORE .. '/' .. f) end
Config = nil Locale = nil
Shim.load('shared/locale.lua') Shim.load('locales/en.lua') Shim.load('locales/ka.lua') Shim.load('config.lua') Shim.load('shared/rules.lua')
local R = LXRLasso

local passed, failed = 0, 0
local function test(name, fn) local okT, err = xpcall(fn, debug.traceback) if okT then passed = passed + 1 print('  ^ ok   ' .. name) else failed = failed + 1 print('  x FAIL ' .. name .. '\n' .. err) end end
local function eq(a, b, msg) if a ~= b then error((msg or 'eq') .. ': expected ' .. tostring(b) .. ' got ' .. tostring(a), 2) end end

print('lxr-lasso offline tests')
test('rope items exist; knives are melee weapons', function()
    for _, n in ipairs(Config.Rope.hogtieItems) do assert(LXRShared.Items[n], n) end
    assert(R.HasRope({ { name = 'rope', amount = 1 } }))
    assert(not R.HasRope({ { name = 'bread', amount = 1 } }))
    assert(R.HasKnife({ { name = 'weapon_melee_knife', amount = 1 } }))
    assert(not R.HasKnife({ { name = 'weapon_revolver_cattleman', amount = 1 } }))
    Config.Rope.knifeToCut = false assert(R.HasKnife({})) Config.Rope.knifeToCut = true
end)
test('law gate', function()
    assert(R.IsLaw({ name = 'unemployed' }), 'anyone when lawOnly is off')
    Config.Rope.lawOnly = true
    assert(R.IsLaw({ name = 'vallaw', onduty = true }))
    assert(not R.IsLaw({ name = 'vallaw', onduty = false }))
    assert(not R.IsLaw({ name = 'valdoc', onduty = true }))
    Config.Rope.lawOnly = false
end)
test('locale parity', function()
    local en, ka = Locale.Bundles.en, Locale.Bundles.ka
    local missing = {}
    for k in pairs(en) do if ka[k] == nil then missing[#missing + 1] = k end end
    eq(#missing, 0, 'ka missing: ' .. table.concat(missing, ', '))
end)
print(('%d passed, %d failed'):format(passed, failed))
os.exit(failed == 0 and 0 or 1)
