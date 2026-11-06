-- Client-only adaptation of the supplied GMA. This does not register a SWEP.
-- The server continues to use Garry's Mod's stock physgun and gravity gun.

sound.Add({
    name = "CustomPhysgunReplacement.Idle",
    channel = CHAN_WEAPON,
    volume = 0.58,
    level = 72,
    pitch = 100,
    sound = "44k/nostradamus/jakub_baku/physgun_loop2.wav"
})

sound.Add({
    name = "CustomPhysgunReplacement.Hold",
    channel = CHAN_WEAPON,
    volume = 0.78,
    level = 76,
    pitch = 100,
    sound = "44k/nostradamus/jakub_baku/physgun_loop1.wav"
})

local beamMaterial = Material("sprites/physgun_beam_baku")
local glowMaterial = Material("sprites/physgun_glow_baku")
local glowMaterial2 = Material("sprites/physgun_glow2_baku")
local orange = Color(255, 112, 12, 255)
local loopSound
local loopMode
local lastWeapon

local function stopLoop()
    if loopSound then
        loopSound:Stop()
        loopSound = nil
    end
    loopMode = nil
end

local function setLoop(weapon, mode)
    if loopMode == mode and loopSound then return end
    stopLoop()
    if not IsValid(weapon) then return end
    loopMode = mode
    loopSound = CreateSound(weapon, mode == "hold" and
        "CustomPhysgunReplacement.Hold" or "CustomPhysgunReplacement.Idle")
    if loopSound then loopSound:PlayEx(mode == "hold" and 0.78 or 0.58, 100) end
end

hook.Add("Think", "CustomPhysgunReplacement.Sounds", function()
    local player = LocalPlayer()
    if not IsValid(player) then return end
    local weapon = player:GetActiveWeapon()
    local class = IsValid(weapon) and weapon:GetClass() or ""

    if weapon ~= lastWeapon then
        stopLoop()
        if class == "weapon_physgun" or class == "weapon_physcannon" then
            surface.PlaySound("44k/nostradamus/jakub_baku/physgun_on.wav")
        end
        lastWeapon = weapon
    end

    if class ~= "weapon_physgun" then
        stopLoop()
        return
    end

    setLoop(weapon, player:KeyDown(IN_ATTACK) and "hold" or "idle")
end)

hook.Add("ShutDown", "CustomPhysgunReplacement.StopSounds", stopLoop)

hook.Add("DrawPhysgunBeam", "CustomPhysgunReplacement.Beam", function(player, weapon, enabled, target, bone, hitPos)
    if not enabled or not IsValid(player) or not IsValid(weapon) then return false end

    local sourceEntity = weapon
    if player == LocalPlayer() and not player:ShouldDrawLocalPlayer() then
        local viewModel = player:GetViewModel()
        if IsValid(viewModel) then sourceEntity = viewModel end
    end

    local attachment = sourceEntity:GetAttachment(1)
    if not attachment then return end
    local startPos = attachment.Pos

    render.SetMaterial(beamMaterial)
    render.DrawBeam(startPos, hitPos, 5, 0, 1, orange)
    render.SetMaterial(glowMaterial)
    render.DrawSprite(startPos, 22, 22, orange)
    render.SetMaterial(glowMaterial2)
    render.DrawSprite(hitPos, 18, 18, orange)
    return false
end)
