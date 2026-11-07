# Roblox Gameplay Ability Script

Skybound Loot Traps is a server-authoritative Roblox gameplay script system featuring impact traps, timed supply shipments, toggle flight, and instant nearby looting. It is designed for a Roblox experience you own and includes server validation for trap placement, flight state, loot distance, cooldowns, and reward collection.

## Install

1. Open your Roblox experience in Roblox Studio.
2. In `ServerScriptService`, create a Script named `GameAbilities`.
3. Copy the contents of `ServerScriptService/GameAbilities.server.lua` into the new Script.
4. In `StarterPlayer > StarterPlayerScripts`, create a LocalScript named `AbilityControls`.
5. Copy the contents of `StarterPlayer/StarterPlayerScripts/AbilityControls.client.lua` into the new LocalScript.
6. Press Play in Studio.
7. Confirm that each player receives a `leaderstats` folder with a `Coins` value.

The server script creates the `ReplicatedStorage.GameAbilities` RemoteEvent automatically. No manual RemoteEvent setup is required.

## Use

- Press `F` to toggle flight.
- Use `W`, `A`, `S`, and `D` to steer while flying.
- Press `Space` to rise while flying.
- Press `LeftControl` to descend while flying.
- Press `T` to place an impact trap eight studs in front of your character.
- Traps have an eight-second cooldown and are removed after up to 90 seconds.
- When another player triggers a trap, nearby players can receive damage within the configured blast radius.
- Press `E` to loot every tagged loot object within 12 studs.
- Each successfully collected loot object grants 25 Coins and is destroyed.
- A supply crate spawns every three minutes near the first `SpawnLocation` in the workspace. If no spawn exists, it appears at `(0, 18, 0)`.
- Supply crates are automatically tagged `Lootable` and expire after five minutes.
- Other server-created models or parts can be made lootable by adding the `Lootable` tag through `CollectionService`.
- Adjust the constants at the top of `GameAbilities.server.lua` to change trap damage, cooldowns, ranges, flight speed, shipment timing, and coin rewards.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/d643c7c1-9909-421c-9689-7654f118c0f1?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=d643c7c1-9909-421c-9689-7654f118c0f1
