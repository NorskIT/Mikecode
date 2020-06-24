local Mike_Druid_Talent
local Mike_Druid

local Mike_Druid_Interacting = false

function Mike_Druid_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_Warlock_Interacting = true
    end
end

function Mike_Druid_Main()
    if Mike_Druid_Talent == nil then
        Mike_Druid_Talent = Mike_GetTalentIndex()
    end
    Mike_Druid_Common_Function()
    if Mike_Druid_Talent == "Balance" then
        Mike_Druid_Balance()
    elseif Mike_Druid_Talent == "Feral Combat" then
        Mike_Druid_Feral()
    elseif Mike_Druid_Talent == "Restoration" then
        Mike_Druid_Restoration()
    end
end

function Mike_Warlock_Critical_Health()
    if UnitAffectingCombat("player") then
        if Mike_Percentage_health("player") <= 0.2 then
            -- Cast some awesome spells to prevent immenet death
            Heal_pot()
        end
        if Mike_Percentage_health("player") <= 0.6 and UnitAura("player","Predator's Swiftness") then
            Mike_CastSpellByName("Healing Touch")
            SpellTargetUnit("player")
            return
        end

    end
end

function Mike_Druid_Aoe()

end

function Mike_Druid_Common_Function()
    Mike_Druid_Critical_Health()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if IsSpellInRange("Moonfire","target") == 1 and Mike_Warlock_Interacting and spellChannel == nil and spellCast == nil then
        Mike_Warlock_Interacting = false
        if IsCurrentAction(24) then
            UseAction(24)
        end
        Stop_Follow()
        print("Stopped following")
    end
    if Mike_Check_spell_ready("Nature's Grasp") then
        Mike_CastSpellByName("Nature's Grasp")
        return
    end
end

function Mike_Druid_Critical_Health()
    if Mike_Percentage_health("player") <= 0.8 and Mike_Check_spell_ready("Barkskin") then
        Mike_CastSpellByName("Barkskin")
        return
    end
end

function Mike_Druid_Buff()
    if not UnitAura("player","Gift of the Wild") and Mike_Check_spell_ready("Gift of the Wild") then
        Mike_CastSpellByName("Gift of the Wild")
        return
    end
    if not UnitAura(Mike_Name_Main_Tank,"Thorns") and IsSpellInRange("Thorns",Mike_Name_Main_Tank) then
        Mike_CastSpellByName("Thorns")
        SpellTargetUnit(Mike_Name_Main_Tank)
        return
    end
    if not Mike_Is_In_Group() then return end
    for i=1, Mike_Get_Group_Size() do
        if not UnitAura(Mike_Get_Group_Prefix()..i,"Gift of the Wild") then
            Mike_CastSpellByName("Gift of the Wild")
            return
        end
    end
end

function Mike_Druid_Balance()
    if not UnitAura("player","Moonkin Form") and Mike_Check_spell_ready("Moonkin Form") then
        Mike_CastSpellByName("Moonkin Form")
        return
    end
    -- How to auto place area-spells?
    --if Mike_Check_spell_ready("Force of Nature") then
    --    Mike_CastSpellByName("Force of Nature")
    --    SpellTargetUnit("player")
    --    return
    --end

    if UnitAura("player","Eclipse (Lunar)") and Mike_Check_spell_ready("Starfire") then
        Mike_CastSpellByName("Starfire")
        SpellTargetUnit("target")
        return
    end
    if UnitAura("player","Eclipse (Solar)") and Mike_Check_spell_ready("Wrath") then
        Mike_CastSpellByName("Wrath")
        SpellTargetUnit("target")
        return
    end
    if not Mike_hasDebuff_Target("Moonfire") and Mike_Check_spell_ready("Moonfire") then
        Mike_CastSpellByName("Moonfire")
        SpellTargetUnit("target")
        return
    end
    if not Mike_hasDebuff_Target("Insect Swarm") and Mike_Check_spell_ready("Insect Swarm") then
        Mike_CastSpellByName("Insect Swarm")
        SpellTargetUnit("target")
        return
    end
    if not Mike_hasDebuff_Target("Faerie Fire") and Mike_Check_spell_ready("Faerie Fire") then
        Mike_CastSpellByName("Faerie Fire")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Starfall") then
        Mike_CastSpellByName("Starfall")
        SpellTargetUnit("target")
        return
    end
    if UnitAura("player","Nature's Grace") and Mike_Check_spell_ready("Starfire") then
        Mike_CastSpellByName("Starfire")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Wrath") then
        Mike_CastSpellByName("Wrath")
        SpellTargetUnit("target")
        return
    end
end

function Mike_Druid_Feral()
    if not UnitAura("player","Cat Form") then
        Mike_CastSpellByName("Cat Form")
        return
    end
    if UnitMana("player") <= 30 and Mike_Check_spell_ready("Tiger's Fury") then
        Mike_CastSpellByName("Tiger's Fury")
        return
    end
    if not Mike_hasDebuff_Target("Mangle (Cat)") and Mike_Check_spell_ready("Mangle (Cat)") then
        Mike_CastSpellByName("Mangle (Cat)")
        SpellTargetUnit("target")
        return
    end
    if not Mike_hasDebuff_Target("Rake") and Mike_Check_spell_ready("Rake") then
        Mike_CastSpellByName("Rake")
        SpellTargetUnit("target")
        return
    end
    if not Mike_hasDebuff_Target("Faerie Fire (Feral)") and Mike_Check_spell_ready("Faerie Fire (Feral)") then
        Mike_CastSpellByName("Faerie Fire (Feral)")
        SpellTargetUnit("target")
        return
    end
    if GetComboPoints("player", "target") == 5 and Mike_Check_spell_ready("Rip") then
        Mike_CastSpellByName("Rip")
        SpellTargetUnit("target")
        return
    end
    if GetComboPoints("player", "target") == 5 and Mike_Check_spell_ready("Ferocious Bite") then
        Mike_CastSpellByName("Ferocious Bite")
        SpellTargetUnit("target")
        return
    end 
end

function Mike_Druid_Restoration()
    Mike_Print("Not implementet Restoration")
end
