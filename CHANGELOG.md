# Changelog

## 3.0.0 — 2026-09-19
* Fix: `LXRCore.PlayerData` stays current — the core object comes back as a copy, so cash, job and metadata never changed after login in this resource. It now listens to `lxr:client:data` / `lxr:client:unloaded` and refreshes its copy.
* LXRCore v3 release line: every resource ships as 3.0.0 from here (the entries below are the road to it).

## 3.0.0 — 2026-09-18

First build, on the LXRCore v3 native API.

* The game rope on players; hogtie by hand with a lasso or rope; carry, saddle, put down, cut, wriggle loose
* State bag `tied`, event `lxr:lasso:tied`; locales EN / KA; offline tests
