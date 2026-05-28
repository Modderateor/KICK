-- ============================================================
-- SLIME RNG - ENHANCED EDITION (Exclusive)
-- Built on VaenHub base + major enhancements
-- ============================================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name             = "Slime RNG | Enhanced",
    LoadingTitle     = "Slime RNG Enhanced",
    LoadingSubtitle  = "Exclusive Edition",
    Theme            = "Default",
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "SlimeRNG_Enhanced",
        FileName   = "Config",
    },
    KeySystem = false,
})

-- ============================================================
-- SERVICES
-- ============================================================
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local LP            = Players.LocalPlayer

-- ============================================================
-- REMOTE HELPER
-- ============================================================
local function GetRemote(name)
    return game:GetService("ReplicatedStorage")
        :WaitForChild("Packages")
        :WaitForChild("_Index")
        :WaitForChild("leifstout_networker@0.3.1")
        :WaitForChild("networker")
        :WaitForChild("_remotes")
        :WaitForChild(name)
        :WaitForChild("RemoteFunction")
end

local Remotes = {}
local function R(name)
    if not Remotes[name] then
        pcall(function() Remotes[name] = GetRemote(name) end)
    end
    return Remotes[name]
end

-- ============================================================
-- DELAYS (all tunable)
-- ============================================================
local DELAY = {
    ROLL        = 0.1,
    EQUIP       = 1,
    UPGRADE     = 0.1,
    REBIRTH     = 1,
    LOOT        = 0.5,
    ZONE_BUY    = 1,
    ZONE_TP     = 1,
    INDEX       = 1,
    BOOST       = 0.1,
    DICE        = 1,
    CODE        = 0.5,
    CRAFT       = 0.1,
    FEED        = 0.1,
    ANTI_AFK    = 60,
    WALK_SPEED  = 16,
}

-- ============================================================
-- UPGRADE LIST (all known upgrades)
-- ============================================================
local ALL_UPGRADES = {
    "voidRolls","enemySpawnSpeed3","luck2","bigEnemies","diamondRolls4","rollSpeed6",
    "friendLuck4","diamondRolls2","friendLuckBoost2","rollSpeed4","voidRolls4",
    "slimeTargetRange3","voidRolls2","rollSpeed2","invertedEnemyChance1","shinySlimes",
    "friendLuck1","playerTree","voidRolls3","enemyCount5","hugeEnemyChance1","luck1",
    "hugeSlimes","rollSpeed3","friendLuck3","slots2","goopDropRate4","enemyCount4",
    "slots4","cloverRolls3","cloverRolls2","goopDropRate3","rollSpeed1","shinyEnemyChance1",
    "diamondRolls3","lootTree","slimeTargetRange1","luck9","shinyEnemies","extraRollChance2",
    "bonusRolls2","friendLuckBoost3","luck15","luck14","luck13","backpack","luck12","luck11",
    "friendLuckBoost1","cloverRolls4","luck8","autoRoll","luck7","luck6","slots5",
    "goldenRolls4","luck5","friendLuckBoost4","goop","bonusRolls3","extraRollChance3",
    "extraRollChance1","luck10","luck3","cloverRolls1","goldenRolls3","enemyCount6",
    "friendLuck5","friendLuck2","goldenRolls","bigEnemyChance1","friendLuck6","diamondRolls",
    "slots3","enemySpawnSpeed1","goldenRolls2","rollSpeed5","enemyCount2","bonusRolls1",
    "enemyCount7","slots6","enemySpawnSpeed2","invertedEnemies","hugeEnemies","luck4",
    "goopDropRate6","goopDropRate5","goopDropRate2","enemyCount3","goopDropRate1",
    "invertedSlimes","bigSlimes","slimeTargetRange2","cloverRolls5","offlineLootAmount2",
    "coinIncome8","lootLuck","coinIncome12","overkill5","lootCurrency","offlineLootAmount1",
    "overkill1","coinIncome7","coinIncome5","lootWatermelon","lootDrumstick","coinIncome10",
    "overkill6","lootChicken","lootPizza","overkill2","lootApple","coinIncome2",
    "offlineLootAmount3","coinIncome4","coinIncome3","offlineLootAmount5","coinIncome13",
    "coinIncome1","lootUltraLuck","coinIncome9","lootBanana","lootGrapes","overkill3",
    "lootCarrot","overkill4","offlineLootAmount4","lootCherries","coinIncome11",
    "lootRollSpeed","coinIncome6","walkSpeed1","magnet1","walkSpeed2","magnet3",
    "walkSpeed3","teleporter","magnet2",
}

-- ============================================================
-- CODES
-- ============================================================
local CODES = {
    "gullible","test","GOFAST","SUPERL00T","SUNOB","RAWRRRR","THATSHUGE",
    "moonSlimeNoWay2","spin2win","Release","stonks","Semils","mutationPLS",
    "craftAway","time2Grind","giveMeLuckNOW","2muchluck",
}

-- ============================================================
-- BOOSTS
-- ============================================================
local BOOSTS = {
    {display="🍀 Luck",       name="luck"},
    {display="✨ Ultra Luck", name="ultraLuck"},
    {display="⚡ Roll Speed", name="rollSpeed"},
    {display="💰 Currency",   name="currency"},
}

-- ============================================================
-- DICE ITEMS
-- ============================================================
local DICE = {
    {display="🎲 Big Dice",      name="bigDice"},
    {display="🎰 Huge Dice",     name="hugeDice"},
    {display="✨ Shiny Dice",    name="shinyDice"},
    {display="🔮 Inverted Dice", name="invertedDice"},
    {display="🎯 Jackpot Spin",  name="jackpotSpin"},
}

-- ============================================================
-- FOOD ITEMS
-- ============================================================
local FOOD = {"apple","carrot","cherries","grapes","banana","watermelon","pizza","chicken","drumstick"}

-- ============================================================
-- INDEX TYPES
-- ============================================================
local INDEX_TYPES = {"basic","big","huge","shiny","inverted"}

-- ============================================================
-- TASK MANAGER (clean start/stop)
-- ============================================================
local Tasks = {}
local function StopTask(key)
    if Tasks[key] then
        pcall(task.cancel, Tasks[key])
        Tasks[key] = nil
    end
end
local function StartTask(key, fn)
    StopTask(key)
    Tasks[key] = task.spawn(fn)
end

-- ============================================================
-- UTILITY
-- ============================================================
local function SafeWait(t, checkFn)
    local elapsed = 0
    while elapsed < t do
        local step = math.min(0.1, t - elapsed)
        task.wait(step)
        elapsed = elapsed + step
        if checkFn and not checkFn() then return false end
    end
    return true
end

local function GetChar()
    return LP.Character
end

local function GetHRP()
    local char = GetChar()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetChar()
    return char and char:FindFirstChild("Humanoid")
end

local function TeleportTo(pos, offsetY)
    local hrp = GetHRP()
    if hrp and pos then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, offsetY or 5, 0))
    end
end

-- Find biggest part in a model (zone floor detection)
local function GetMainPart(model)
    local biggest, biggestVol = nil, 0
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") and not part.Name:match("Gate") then
            local vol = part.Size.X * part.Size.Y * part.Size.Z
            if vol > biggestVol then biggestVol = vol; biggest = part end
        end
    end
    return biggest
end

local function GetModelPos(model)
    local part = GetMainPart(model)
    if part then return part.Position end
    if model:IsA("Model") then
        local ok, pos = pcall(function() return model:GetPivot().Position end)
        if ok then return pos end
    end
    return nil
end

-- Find the next locked zone
local function GetNextLockedZone()
    local zones = workspace:FindFirstChild("Zones")
    if not zones then return nil end
    local best, bestNum = nil, math.huge
    for _, zone in ipairs(zones:GetChildren()) do
        local num = tonumber(zone.Name)
        if num then
            local gate = zone:FindFirstChild("Gate")
            if gate then
                for _, part in ipairs(gate:GetChildren()) do
                    if part.Name:match("^ClientGateBlocker_") and part:IsA("BasePart") then
                        if part.CanCollide and num < bestNum then
                            bestNum = num; best = zone
                        end
                        break
                    end
                end
            end
        end
    end
    return best, bestNum
end

-- Check if player is inside a zone
local function IsInZone(zone)
    local hrp = GetHRP()
    if not hrp then return false end
    local part = GetMainPart(zone)
    if not part then return false end
    local local_pos = part.CFrame:PointToObjectSpace(hrp.Position)
    return math.abs(local_pos.X) <= part.Size.X/2
        and math.abs(local_pos.Z) <= part.Size.Z/2
        and math.abs(local_pos.Y) <= part.Size.Y/2 + 10
end

-- ============================================================
-- TABS
-- ============================================================
local TabMain    = Window:CreateTab("🏠 Main",     nil)
local TabFarm    = Window:CreateTab("⚡ Farm",     nil)
local TabItems   = Window:CreateTab("🧪 Items",    nil)
local TabCraft   = Window:CreateTab("⚒️ Crafting", nil)
local TabMisc    = Window:CreateTab("🛠️ Misc",     nil)
local TabStats   = Window:CreateTab("📊 Stats",    nil)

-- ============================================================
-- MAIN TAB — Master toggles
-- ============================================================
TabMain:CreateSection("⚡ Master Control")

TabMain:CreateToggle({
    Name         = "🌟 AUTO FARM EVERYTHING",
    CurrentValue = false,
    Flag         = "MasterFarm",
    Callback     = function(val)
        -- Triggers all farm toggles at once
        local flags = {
            "AutoRoll","AutoEquip","AutoUpgrade","AutoRebirth",
            "AutoLoot","AutoBuyZone","AutoZoneTP","AutoIndex",
            "AutoBoost","AutoCode","AutoAntiAFK","AutoWalkSpeed",
        }
        for _, flag in ipairs(flags) do
            local el = Rayfield:GetFlag(flag)
            if el then el:Set(val) end
        end
        Rayfield:Notify({
            Title   = val and "🌟 ALL FARMS ON" or "🛑 ALL FARMS OFF",
            Content = val and "Every feature is now active!" or "All features stopped.",
            Duration = 3,
        })
    end,
})

TabMain:CreateSection("📊 Live Stats")

local StatsLabel = TabMain:CreateParagraph({
    Title   = "Player Stats",
    Content = "Loading...",
})

-- Update stats every 2 seconds
task.spawn(function()
    while task.wait(2) do
        pcall(function()
            local char = GetChar()
            local hum  = GetHumanoid()
            local hrp  = GetHRP()
            local pos  = hrp and string.format("%.0f, %.0f, %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) or "N/A"
            local hp   = hum and string.format("%.0f / %.0f", hum.Health, hum.MaxHealth) or "N/A"
            local zone, zoneNum = GetNextLockedZone()
            local zoneStr = zone and ("Next locked: Zone " .. tostring(zoneNum)) or "All zones unlocked!"
            StatsLabel:Set({
                Title   = "📊 Live Stats",
                Content = string.format(
                    "❤️ HP: %s\n📍 Position: %s\n🏞️ %s",
                    hp, pos, zoneStr
                ),
            })
        end)
    end
end)

-- ============================================================
-- FARM TAB
-- ============================================================
TabFarm:CreateSection("🎲 Rolling")

TabFarm:CreateToggle({
    Name         = "🎲 Auto Roll",
    CurrentValue = false,
    Flag         = "AutoRoll",
    Callback     = function(val)
        if val then
            StartTask("roll", function()
                local remote = R("RollService")
                while Tasks["roll"] do
                    pcall(function() remote:InvokeServer("requestRoll") end)
                    task.wait(DELAY.ROLL)
                end
            end)
        else StopTask("roll") end
    end,
})

TabFarm:CreateSlider({
    Name         = "Roll Delay (seconds)",
    Range        = {0.05, 2},
    Increment    = 0.05,
    Suffix       = "s",
    CurrentValue = DELAY.ROLL,
    Flag         = "RollDelay",
    Callback     = function(val) DELAY.ROLL = val end,
})

TabFarm:CreateSection("⚔️ Equipment")

TabFarm:CreateToggle({
    Name         = "⚔️ Auto Equip Best Slime",
    CurrentValue = false,
    Flag         = "AutoEquip",
    Callback     = function(val)
        if val then
            StartTask("equip", function()
                local remote = R("InventoryService")
                while Tasks["equip"] do
                    pcall(function() remote:InvokeServer("requestEquipBest") end)
                    task.wait(DELAY.EQUIP)
                end
            end)
        else StopTask("equip") end
    end,
})

TabFarm:CreateSection("⬆️ Upgrades")

TabFarm:CreateToggle({
    Name         = "⬆️ Auto Buy ALL Upgrades",
    CurrentValue = false,
    Flag         = "AutoUpgrade",
    Callback     = function(val)
        if val then
            StartTask("upgrade", function()
                local remote = R("UpgradeService")
                while Tasks["upgrade"] do
                    for _, upgName in ipairs(ALL_UPGRADES) do
                        if not Tasks["upgrade"] then break end
                        pcall(function() remote:InvokeServer("requestUnlock", upgName) end)
                        task.wait(DELAY.UPGRADE)
                    end
                    task.wait(0.5)
                end
            end)
        else StopTask("upgrade") end
    end,
})

TabFarm:CreateSection("🌟 Rebirth")

TabFarm:CreateToggle({
    Name         = "🌟 Auto Rebirth",
    CurrentValue = false,
    Flag         = "AutoRebirth",
    Callback     = function(val)
        if val then
            StartTask("rebirth", function()
                local remote = R("RebirthService")
                while Tasks["rebirth"] do
                    pcall(function() remote:InvokeServer("requestRebirth") end)
                    task.wait(DELAY.REBIRTH)
                end
            end)
        else StopTask("rebirth") end
    end,
})

TabFarm:CreateSection("🎁 Loot")

TabFarm:CreateToggle({
    Name         = "🎁 Auto Collect Loot",
    CurrentValue = false,
    Flag         = "AutoLoot",
    Callback     = function(val)
        if val then
            StartTask("loot", function()
                while Tasks["loot"] do
                    local hrp = GetHRP()
                    local lootFolder = workspace:FindFirstChild("Loot")
                    if hrp and lootFolder then
                        for _, container in ipairs(lootFolder:GetChildren()) do
                            if not Tasks["loot"] then break end
                            for _, desc in ipairs(container:GetDescendants()) do
                                if desc:IsA("TouchTransmitter") then
                                    local part = desc.Parent
                                    if part and part:IsA("BasePart") then
                                        pcall(function()
                                            firetouchinterest(hrp, part, 0)
                                            firetouchinterest(hrp, part, 1)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                    task.wait(DELAY.LOOT)
                end
            end)
        else StopTask("loot") end
    end,
})

TabFarm:CreateSection("🏞️ Zones")

TabFarm:CreateToggle({
    Name         = "🏞️ Auto Buy Next Zone",
    CurrentValue = false,
    Flag         = "AutoBuyZone",
    Callback     = function(val)
        if val then
            StartTask("buyzone", function()
                local remote = R("ZonesService")
                while Tasks["buyzone"] do
                    pcall(function() remote:InvokeServer("requestPurchaseZone") end)
                    task.wait(DELAY.ZONE_BUY)
                end
            end)
        else StopTask("buyzone") end
    end,
})

TabFarm:CreateToggle({
    Name         = "🚀 Auto TP to Best Zone",
    CurrentValue = false,
    Flag         = "AutoZoneTP",
    Callback     = function(val)
        if val then
            StartTask("zonetp", function()
                while Tasks["zonetp"] do
                    local zone = GetNextLockedZone()
                    if zone and not IsInZone(zone) then
                        local pos = GetModelPos(zone)
                        if pos then TeleportTo(pos, 5) end
                    end
                    task.wait(DELAY.ZONE_TP)
                end
            end)
        else StopTask("zonetp") end
    end,
})

TabFarm:CreateSection("📚 Index")

TabFarm:CreateToggle({
    Name         = "📚 Auto Claim Index Rewards",
    CurrentValue = false,
    Flag         = "AutoIndex",
    Callback     = function(val)
        if val then
            StartTask("index", function()
                local remote = R("IndexService")
                while Tasks["index"] do
                    for _, indexType in ipairs(INDEX_TYPES) do
                        if not Tasks["index"] then break end
                        pcall(function() remote:InvokeServer("requestClaimReward", indexType) end)
                        task.wait(DELAY.INDEX)
                    end
                    task.wait(2)
                end
            end)
        else StopTask("index") end
    end,
})

-- ============================================================
-- ITEMS TAB — Boosts, Dice, Food
-- ============================================================
TabItems:CreateSection("🍀 Auto Use Boosts")

local boostDisplayNames = {}
for _, b in ipairs(BOOSTS) do table.insert(boostDisplayNames, b.display) end

local selectedBoosts = {}
TabItems:CreateDropdown({
    Name            = "Select Boosts to Use",
    Options         = boostDisplayNames,
    CurrentOption   = boostDisplayNames,
    MultipleOptions = true,
    Flag            = "SelectedBoosts",
    Callback        = function(val) selectedBoosts = val end,
})

TabItems:CreateToggle({
    Name         = "🍀 Auto Use Selected Boosts",
    CurrentValue = false,
    Flag         = "AutoBoost",
    Callback     = function(val)
        if val then
            StartTask("boost", function()
                local remote = R("BoostService")
                while Tasks["boost"] do
                    for _, b in ipairs(BOOSTS) do
                        if not Tasks["boost"] then break end
                        if #selectedBoosts == 0 or table.find(selectedBoosts, b.display) then
                            pcall(function() remote:InvokeServer("requestUseBoost", b.name) end)
                            task.wait(DELAY.BOOST)
                        end
                    end
                    task.wait(1)
                end
            end)
        else StopTask("boost") end
    end,
})

TabItems:CreateSection("🎲 Auto Use Dice")

local diceDisplayNames = {}
for _, d in ipairs(DICE) do table.insert(diceDisplayNames, d.display) end

local selectedDice = {diceDisplayNames[1]}
TabItems:CreateDropdown({
    Name            = "Select Dice to Use",
    Options         = diceDisplayNames,
    CurrentOption   = selectedDice,
    MultipleOptions = false,
    Flag            = "SelectedDice",
    Callback        = function(val)
        selectedDice = type(val) == "table" and val or {val}
    end,
})

TabItems:CreateToggle({
    Name         = "🎲 Auto Use Selected Dice",
    CurrentValue = false,
    Flag         = "AutoDice",
    Callback     = function(val)
        if val then
            StartTask("dice", function()
                local remote = R("InventoryService")
                while Tasks["dice"] do
                    for _, d in ipairs(DICE) do
                        if not Tasks["dice"] then break end
                        local chosen = selectedDice[1] or diceDisplayNames[1]
                        if d.display == chosen then
                            pcall(function() remote:InvokeServer("requestUseItem", d.name) end)
                        end
                    end
                    task.wait(DELAY.DICE)
                end
            end)
        else StopTask("dice") end
    end,
})

TabItems:CreateSection("🍎 Auto Feed Slimes")

local selectedFood = {FOOD[1]}
TabItems:CreateDropdown({
    Name            = "Select Food",
    Options         = FOOD,
    CurrentOption   = selectedFood,
    MultipleOptions = false,
    Flag            = "SelectedFood",
    Callback        = function(val)
        selectedFood = type(val) == "table" and val or {val}
    end,
})

TabItems:CreateToggle({
    Name         = "🍎 Auto Feed Slimes",
    CurrentValue = false,
    Flag         = "AutoFeed",
    Callback     = function(val)
        if val then
            StartTask("feed", function()
                local remote = R("InventoryService")
                while Tasks["feed"] do
                    local food = selectedFood[1] or FOOD[1]
                    pcall(function() remote:InvokeServer("requestFeedSlime", food) end)
                    task.wait(DELAY.FEED)
                end
            end)
        else StopTask("feed") end
    end,
})

-- ============================================================
-- CRAFTING TAB
-- ============================================================
TabCraft:CreateSection("⚒️ Auto Craft")

local CRAFT_RECIPES = {
    "crafty", "thorn", "geode", "slimeSlimeSlime",
    "puffy", "astro", "sunny", "melly",
}

local selectedRecipe = {CRAFT_RECIPES[1]}
TabCraft:CreateDropdown({
    Name            = "Select Recipe",
    Options         = CRAFT_RECIPES,
    CurrentOption   = selectedRecipe,
    MultipleOptions = false,
    Flag            = "SelectedRecipe",
    Callback        = function(val)
        selectedRecipe = type(val) == "table" and val or {val}
    end,
})

TabCraft:CreateToggle({
    Name         = "⚒️ Auto Craft Selected Recipe",
    CurrentValue = false,
    Flag         = "AutoCraft",
    Callback     = function(val)
        if val then
            StartTask("craft", function()
                local remote = R("CraftingService")
                while Tasks["craft"] do
                    local recipe = selectedRecipe[1] or CRAFT_RECIPES[1]
                    pcall(function() remote:InvokeServer("requestCraft", recipe) end)
                    task.wait(DELAY.CRAFT)
                end
            end)
        else StopTask("craft") end
    end,
})

TabCraft:CreateSection("🔑 Redeem Codes")

TabCraft:CreateButton({
    Name     = "🔑 Redeem ALL Codes",
    Callback = function()
        task.spawn(function()
            local remote = R("CodeService")
            local redeemed, failed = 0, 0
            for _, code in ipairs(CODES) do
                local ok, result = pcall(function()
                    return remote:InvokeServer("requestRedeemCode", code)
                end)
                if ok and result then redeemed = redeemed + 1
                else failed = failed + 1 end
                task.wait(DELAY.CODE)
            end
            Rayfield:Notify({
                Title   = "🔑 Codes Done",
                Content = string.format("✅ %d redeemed | ❌ %d failed/already used", redeemed, failed),
                Duration = 5,
            })
        end)
    end,
})

-- ============================================================
-- MISC TAB — Speed, Anti-AFK, Teleport, Extras
-- ============================================================
TabMisc:CreateSection("🏃 Walk Speed")

TabMisc:CreateToggle({
    Name         = "🏃 Custom Walk Speed",
    CurrentValue = false,
    Flag         = "AutoWalkSpeed",
    Callback     = function(val)
        if val then
            StartTask("walkspeed", function()
                while Tasks["walkspeed"] do
                    local hum = GetHumanoid()
                    if hum then hum.WalkSpeed = DELAY.WALK_SPEED end
                    task.wait(0.5)
                end
                -- Restore on stop
                local hum = GetHumanoid()
                if hum then hum.WalkSpeed = 16 end
            end)
        else
            StopTask("walkspeed")
            local hum = GetHumanoid()
            if hum then hum.WalkSpeed = 16 end
        end
    end,
})

TabMisc:CreateSlider({
    Name         = "Walk Speed Value",
    Range        = {16, 250},
    Increment    = 1,
    CurrentValue = 16,
    Flag         = "WalkSpeedValue",
    Callback     = function(val) DELAY.WALK_SPEED = val end,
})

TabMisc:CreateSection("🛡️ Anti-AFK")

TabMisc:CreateToggle({
    Name         = "🛡️ Anti-AFK",
    CurrentValue = false,
    Flag         = "AutoAntiAFK",
    Callback     = function(val)
        if val then
            StartTask("antiafk", function()
                local VirtualUser = game:GetService("VirtualUser")
                while Tasks["antiafk"] do
                    pcall(function()
                        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end)
                    task.wait(DELAY.ANTI_AFK)
                end
            end)
        else StopTask("antiafk") end
    end,
})

TabMisc:CreateSection("🔭 Camera")

TabMisc:CreateSlider({
    Name         = "Max Zoom Distance",
    Range        = {10, 1000},
    Increment    = 10,
    CurrentValue = 400,
    Flag         = "MaxZoom",
    Callback     = function(val)
        pcall(function()
            LP.CameraMaxZoomDistance = val
        end)
    end,
})

TabMisc:CreateSection("🌀 Teleport Tools")

TabMisc:CreateButton({
    Name     = "🌀 TP to Zone 1",
    Callback = function()
        local zones = workspace:FindFirstChild("Zones")
        if zones then
            local z1 = zones:FindFirstChild("1")
            if z1 then
                local pos = GetModelPos(z1)
                if pos then TeleportTo(pos, 5) end
            end
        end
    end,
})

TabMisc:CreateButton({
    Name     = "🌀 TP to Spawn",
    Callback = function()
        local spawn = workspace:FindFirstChild("SpawnLocation")
            or workspace:FindFirstChildWhichIsA("SpawnLocation")
        if spawn then
            TeleportTo(spawn.Position, 5)
        else
            Rayfield:Notify({Title="TP", Content="Spawn not found!", Duration=3})
        end
    end,
})

TabMisc:CreateSection("⚙️ Delays (Advanced)")

TabMisc:CreateSlider({
    Name         = "Loot Collect Delay",
    Range        = {0.1, 3},
    Increment    = 0.1,
    Suffix       = "s",
    CurrentValue = DELAY.LOOT,
    Flag         = "LootDelay",
    Callback     = function(val) DELAY.LOOT = val end,
})

TabMisc:CreateSlider({
    Name         = "Zone Buy Delay",
    Range        = {0.5, 5},
    Increment    = 0.5,
    Suffix       = "s",
    CurrentValue = DELAY.ZONE_BUY,
    Flag         = "ZoneBuyDelay",
    Callback     = function(val) DELAY.ZONE_BUY = val end,
})

TabMisc:CreateSlider({
    Name         = "Rebirth Delay",
    Range        = {0.5, 10},
    Increment    = 0.5,
    Suffix       = "s",
    CurrentValue = DELAY.REBIRTH,
    Flag         = "RebirthDelay",
    Callback     = function(val) DELAY.REBIRTH = val end,
})

-- ============================================================
-- STATS TAB — Live counters
-- ============================================================
TabStats:CreateSection("📊 Session Stats")

local sessionStats = {
    rolls    = 0,
    rebirths = 0,
    loot     = 0,
    zones    = 0,
    uptime   = tick(),
}

local SessionLabel = TabStats:CreateParagraph({
    Title   = "Session Stats",
    Content = "Starting...",
})

-- Track rolls
local origRollTask = Tasks["roll"]
RunService.Heartbeat:Connect(function()
    -- Count active tasks
    local active = 0
    for _, v in pairs(Tasks) do if v then active = active + 1 end end

    local uptime = math.floor(tick() - sessionStats.uptime)
    local mins   = math.floor(uptime / 60)
    local secs   = uptime % 60

    pcall(function()
        SessionLabel:Set({
            Title   = "📊 Session Stats",
            Content = string.format(
                "⏱️ Uptime: %dm %ds\n⚡ Active Tasks: %d\n🎲 Auto Roll: %s\n⬆️ Auto Upgrade: %s\n🌟 Auto Rebirth: %s\n🎁 Auto Loot: %s\n🏞️ Auto Zone: %s",
                mins, secs,
                active,
                Tasks["roll"]    and "✅ ON" or "❌ OFF",
                Tasks["upgrade"] and "✅ ON" or "❌ OFF",
                Tasks["rebirth"] and "✅ ON" or "❌ OFF",
                Tasks["loot"]    and "✅ ON" or "❌ OFF",
                Tasks["buyzone"] and "✅ ON" or "❌ OFF"
            ),
        })
    end)
end)

TabStats:CreateSection("🔧 Controls")

TabStats:CreateButton({
    Name     = "🛑 Stop ALL Tasks",
    Callback = function()
        for key in pairs(Tasks) do StopTask(key) end
        Rayfield:Notify({
            Title   = "🛑 Stopped",
            Content = "All automation tasks stopped.",
            Duration = 3,
        })
    end,
})

TabStats:CreateButton({
    Name     = "🔄 Rejoin Server",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
    end,
})

-- ============================================================
-- STARTUP NOTIFICATION
-- ============================================================
task.wait(1)
Rayfield:Notify({
    Title    = "✅ Slime RNG Enhanced",
    Content  = "Exclusive edition loaded! All features ready.",
    Duration = 5,
    Image    = "rbxassetid://10723407389",
})
