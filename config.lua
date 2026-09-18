--[[
    ██╗     ██╗  ██╗██████╗       ██╗      █████╗ ███████╗███████╗ ██████╗
    ██║     ╚██╗██╔╝██╔══██╗      ██║     ██╔══██╗██╔════╝██╔════╝██╔═══██╗
    ██║      ╚███╔╝ ██████╔╝█████╗██║     ███████║███████╗███████╗██║   ██║
    ██║      ██╔██╗ ██╔══██╗╚════╝██║     ██╔══██║╚════██║╚════██║██║   ██║
    ███████╗██╔╝ ██╗██║  ██║      ███████╗██║  ██║███████║███████║╚██████╔╝
    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝      ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝

    LXR Core - Lasso

    Rope on people. Players can be lassoed and hogtied the way the game
    does it with animals — the flag that allows it is set by this resource,
    the server keeps who is tied, and the tied can be carried on a shoulder,
    laid across a saddle, cut free with a knife, or wriggle loose after a
    while. Hogtying needs a lasso or a rope in the satchel.

    Brand:       LXRCore — Lux Empire eXperience RedM Core
    Product:     wolves.land / The Land of Wolves
    Developer:   iBoss21 / LXRCore
    Website:     https://www.lxrcore.com
    Discord:     https://discord.gg/ZHMKVYyhBa (development)
    GitHub:      https://github.com/LXRCore

    Version: 3.0.0
    Performance Target: 0.00 ms idle (one 1 s watch for the tied state)

    © 2026 iBoss21 / LXRCore | lxrcore.com | All Rights Reserved
]]

Config = Config or {}

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ LANGUAGE ██████████████████████████████████████████████
-- ████████████████████████████████████████████████████████████████████████████████
Config.Lang = 'en'

-- ████████████████████████████████████████████████████████████████████████████████
-- ████████████████████████ THE ROPE ══════════════════════════════════════════════
-- ████████████████████████████████████████████████████████████████████████████████
Config.Rope = {
    allowLasso = true,           -- players may be lassoed by other players (the game's own rope)
    hogtieItems = { 'lasso', 'rope' },   -- one of these in the satchel to hogtie by hand
    lawOnly = false,             -- only the law (job type leo / federal) may hogtie
    escapeSeconds = 90,          -- the tied may wriggle loose after this (0 = never)
    knifeToCut = true,           -- cutting free needs a knife-class weapon in the satchel
    carry = true,                -- the tied can be carried and put on a mount
    distance = 2.5,
}

Config.Security = { rateLimit = { windowMs = 2000, burst = 6 }, maxDistance = 3.5 }
Config.Debug = { printBanner = true }
