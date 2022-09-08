local mod = RegisterMod("Defibrillator Trinket", 1)
local sndManager = SFXManager()
local TRINKET_DEFRIBRILLATOR = Isaac.GetTrinketIdByName("Defibrillator")
local defibrillatorDesc = "Instead of losing HP upon taking damage, lose active item charges#If the held active has 6 or more charges, 3 are lost when hit#If it has 12 charges, 4 are lost#If it has less than 6, 2 are lost#If it has less than 2 charges, damage will not be prevented"

if EID then
    EID:addTrinket(TRINKET_DEFRIBRILLATOR, defibrillatorDesc)
end

if Encyclopedia then
    Encyclopedia.AddTrinket({
      ID = TRINKET_DEFRIBRILLATOR,
      WikiDesc = Encyclopedia.EIDtoWiki(defibrillatorDesc),
    })
end

local chargeValues = {
    sixCharge = 3,
    twelveCharge = 4,
    minCharge = 2
}

function mod:onHit(entity, amount, flags, source, countdown)
    if not entity then return end
        local player = entity:ToPlayer()
    if not player then return end
    if player:HasTrinket(TRINKET_DEFRIBRILLATOR) then
        if player:GetActiveCharge() > 1 and flags ~= DamageFlag.DAMAGE_FAKE then
            local charge = player:GetActiveCharge()

            if player:GetBatteryCharge() > 0 then -- Accounts for 2nd charge bar granted by The Battery, etc
                charge = charge + player:GetBatteryCharge()
            end

            if charge >= 6 and charge < 12 then
                player:SetActiveCharge(charge - chargeValues.sixCharge)
            elseif charge >= 12 then 
                player:SetActiveCharge(charge - chargeValues.twelveCharge)
            else
                player:SetActiveCharge(charge - chargeValues.minCharge)
            end

            sndManager:Play(SoundEffect.SOUND_BATTERYDISCHARGE)
            player:TakeDamage(amount, DamageFlag.DAMAGE_FAKE, source, countdown)
            return false
        end
    end
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.onHit, EntityType.ENTITY_PLAYER)