Mike_Paladin_Party = {}
Mike_Paladin_Aura = {"Devotion Aura","Retribution Aura","Concentration Aura","Frost Resistance Aura","Shadow Resistance Aura","Fire Resistance Aura"}
Mike_Paladin_Raid_Blessings = {"Greater Blessing of Kings","Greater Blessing of Might","Greater Blessing of Wisdom"}
Mike_Paladin_Seals = {"Seal of Command", "Seal of Justice", "Seal of Wisdom", "Seal of Righteousness"}
Mike_Paladin_Talent = nil

local Mike_Paladin_Buff_Counter = 1
local Mike_Paladin_Active_Buff = nil
local Mike_Paladin_Active_Judgement = nil

function Mike_Paladin_OnUpdate(arg)
    if arg == "You are too far away!" then
        Mike_InteractUnit("target")
    end
end

function Mike_Paladin_Buff()
    local class = nil
    if table.getn(Mike_Paladin_Party) == 0 then
        if UnitInRaid("player") ~= nil then
            for x=1, GetNumRaidMembers() do
                class = UnitClass("raid"..x)
                if class == "Paladin" then
                    Mike_Paladin_Party[#Mike_Paladin_Party+1] = UnitName("raid"..x)
                end
            end
        else
            for x=1, GetNumPartyMembers() do
                class = UnitClass("party"..x)
                if class == "Paladin" then
                    Mike_Paladin_Party[#Mike_Paladin_Party+1] = UnitName("party"..x)
                end
            end
        end 
        Mike_Paladin_Party = Mike_Sort_Table(Mike_Paladin_Party)
    end
    -- Iterate total amount of auras (6)
    for i=1,6 do
        if UnitName("player") == Mike_Paladin_Party[i] and not UnitAura("player",Mike_Paladin_Aura[i]) then
           Mike_CastSpellByName(Mike_Paladin_Aura[i])
        end
    end
    -- Blessings:
    for blessIndex=1, table.getn(Mike_Paladin_Raid_Blessings) do
        local blessing = Mike_Paladin_Raid_Blessings[blessIndex]
        if Mike_Paladin_Party[blessIndex] == UnitName("player") then
            for v=1, Mike_Get_Group_Size() do
                local playerUnitId = Mike_Get_Group_Prefix()..v
                if not UnitAura(playerUnitId,blessing) and IsSpellInRange(blessing, playerUnitId) then
                    Mike_CastSpellByName(blessing)
                    SpellTargetUnit(playerUnitId)
                    return
                end
            end
        end
    end
end

function Mike_Paladin_Aoe()
    if Mike_Check_spell_ready("Consecration") then
        Mike_CastSpellByName("Consecration")
        return
    end
end

function Mike_Paladin_Main()
    Mike_Paladin_Common_Function()
    if Mike_Paladin_Talent == nil then
        Mike_Paladin_Talent = Mike_GetTalentIndex()
        if Mike_Paladin_Talent == "Holy" then
            Mike_Role = "caster"
        end
    end
    if Mike_Paladin_Talent == "Holy" then
        Mike_Paladin_Holy()
    elseif Mike_Paladin_Talent == "Protection" then
        Mike_Paladin_Protection()
    elseif Mike_Paladin_Talent == "Retribution" then
        Mike_Paladin_Retribution()
    end
end

function Mike_Paladin_Common_Function()
    Mike_Paladin_Critical_Health()
end

function Mike_Paladin_Critical_Health()
    if UnitAffectingCombat("player") then
        if Mike_Percentage_health("player") <= 0.2 then
            if Mike_Check_spell_ready("Divine Shield") then
                Mike_CastSpellByName("Divine Shield")
            elseif Mike_Check_spell_ready("Divine Protection") then
                Mike_CastSpellByName("Divine Protection")
            elseif Mike_Check_spell_ready("Lay on Hands") then
                Mike_CastSpellByName("Lay on Hands")
                SpellTargetUnit("player")
            end
            Heal_pot()
        end
    end
    
end
function Mike_Paladin_Holy()
    -- Not implemented
end

function Mike_Paladin_Protection()
    -- Not implemented
end

function Mike_Paladin_Retribution()
    if UnitAura("player","The Art of War") and Mike_Percentage_health("player") <= 0.9 then
        Mike_CastSpellByName("Flash of Light")
        SpellTargetUnit("player")
        return
    end
    if UnitAura("player","The Art of War") and Mike_Check_spell_ready("Exorcism") then
        Mike_CastSpellByName("Exorcism")
        SpellTargetUnit("target")
        return
    end
    if Mike_Paladin_Cast_Judgement() then return end
    if Mike_Check_spell_ready("Hammer of Wrath") then
        Mike_CastSpellByName("Hammer of Wrath")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Crusader Strike") then
        Mike_CastSpellByName("Crusader Strike")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Consecration") then
        Mike_CastSpellByName("Consecration")
        return
    end
    if Mike_Check_spell_ready("Divine Storm") then
        Mike_CastSpellByName("Divine Storm")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Holy Wrath") then
        Mike_CastSpellByName("Holy Wrath")
        SpellTargetUnit("target")
        return
    end

end

function Mike_Paladin_Cast_Judgement()
    if Mike_Paladin_Active_Judgement ~= nil then
        if not Mike_hasDebuff_Target(Mike_Paladin_Active_Judgement) then
            Mike_Paladin_Active_Judgement = nil
        end
    end
    if Mike_Paladin_Active_Judgement == nil then
        local Mike_Paladin_SealToUse = ""
        --Mike_Paladin_SealToUse = "Seal of Command" -- DPS
        Mike_Paladin_SealToUse = "Seal of Wisdom" -- Mana
        if not UnitAura("player",Mike_Paladin_SealToUse)  then
            Mike_CastSpellByName(Mike_Paladin_SealToUse)
            return true
        end
        if not Mike_hasDebuff_Target("Judgement of Justice") and Mike_Check_spell_ready("Judgement of Justice") then
            Mike_CastSpellByName("Judgement of Justice")
            SpellTargetUnit("target")
            if Mike_Paladin_Active_Judgement == nil then
                Mike_Paladin_Active_Judgement = "Judgement of Justice"
            end
            return true
        elseif not Mike_hasDebuff_Target("Judgement of Light") and Mike_Check_spell_ready("Judgement of Light") then
            Mike_CastSpellByName("Judgement of Light")
            SpellTargetUnit("target")
            if Mike_Paladin_Active_Judgement == nil then
                Mike_Paladin_Active_Judgement = "Judgement of Light"
            end
            return true
        elseif not Mike_hasDebuff_Target("Judgement of Wisdom") and Mike_Check_spell_ready("Judgement of Wisdom") then
            Mike_CastSpellByName("Judgement of Wisdom")
            SpellTargetUnit("target")
            if Mike_Paladin_Active_Judgement == nil then
                Mike_Paladin_Active_Judgement = "Judgement of Wisdom"
            end
            return true
        end
    end
    return false
end

