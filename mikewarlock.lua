
Mike_Warlock_Party = {}

local Mike_Warlock_Talent = nil
local Mike_Warlock_Interacting = false
local Mike_Warlock_Total_Warlocks_On_Team = nil

function Mike_Warlock_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_Warlock_Interacting = true
    end
end

function Mike_Warlock_Main()
    Mike_Role = "caster"
    if Mike_Warlock_Talent == nil then
        Mike_Warlock_Talent = Mike_GetTalentIndex()
    end
    Mike_Warlock_Common_Function()
    if Mike_Warlock_Talent == "Affliction" then
        Mike_Warlock_Affliction()
    elseif Mike_Warlock_Talent == "Demonology" then
        Mike_Warlock_Demonology()
    elseif Mike_Warlock_Talent == "Destruction" then
        Mike_Warlock_Destruction()
    end
end

function Mike_Warlock_Common_Function()
    Mike_Warlock_Critical_Health()
    if Mike_Warlock_Total_Warlocks_On_Team == nil then
        Mike_Warlock_Total_Warlocks_On_Team = Mike_Count_Class_On_Team("Warlock")
    end
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if IsSpellInRange("Shadow Bolt","target") == 1 and Mike_Warlock_Interacting and spellChannel == nil and spellCast == nil then
        Mike_Warlock_Interacting = false
        StopAttack()
        Stop_Follow()
        print("Stopped following")
    end
    if Mike_Percentage_health("player") >= 0.6 and Mike_Percentage_mana("player") <= 0.4 then
        Mike_CastSpellByName("Life Tap")
        return
    end
end

function Mike_Warlock_Critical_Health()
    if UnitAffectingCombat("player") then
        if Mike_Percentage_health("player") <= 0.2 then
            -- Cast some awesome spells to prevent immenet death
        Heal_pot()
        end
    end
end

function Mike_Warlock_Summon()
    if Mike_Warlock_Party[1] == UnitName("player") then
        if not HasPetUI() then 
            Mike_CastSpellByName("Summon Imp")
            return
        end
    elseif Mike_Warlock_Party[2] == UnitName("player") then
        if not HasPetUI() then 
            Mike_CastSpellByName("Summon Felhunter")
            return
        end
    else
        if not HasPetUI() then 
            Mike_CastSpellByName("Summon Succubus")
            return
        end
    end
end

function Mike_Warlock_Summon_Attack()
    if Mike_Check_spell_ready("Shadow Bite") then
        Mike_CastSpellByName("Shadow Bite")
        SpellTargetUnit("target")
    end
    if Mike_Check_spell_ready("Firebolt") then
        Mike_CastSpellByName("Firebolt")
        SpellTargetUnit("target")
    end
    if Mike_Check_spell_ready("Lash of Pain") then
        Mike_CastSpellByName("Lash of Pain")
        SpellTargetUnit("target")
    end   
end

function Mike_Warlock_Buff()
    Mike_Print("Warlock Buff")
    local class
    if table.getn(Mike_Warlock_Party) == 0 then
        class = UnitClass("player")
        if class == "Warlock" then
            Mike_Warlock_Party[#Mike_Warlock_Party+1] = UnitName("player")
        end
        if UnitInRaid("player") ~= nil then
            for x=1, GetNumRaidMembers() do
                class = UnitClass("raid"..x)
                if class == "Warlock" then
                    Mike_Warlock_Party[#Mike_Warlock_Party+1] = UnitName("raid"..x)
                end
            end
        else
            for x=1, GetNumPartyMembers() do
                class = UnitClass("party"..x)
                if class == "Warlock" then
                    Mike_Warlock_Party[#Mike_Warlock_Party+1] = UnitName("party"..x)
                end
            end
        end 
    end
    Mike_Warlock_Party = Mike_Sort_Table(Mike_Warlock_Party)
    if not HasPetUI() then 
        Mike_Warlock_Summon()
        return
    elseif Mike_Warlock_Party[1] == UnitName("player") then
        if not UnitAura("player","Blood Pact") then
            Mike_CastSpellByName("Blood Pact")
            return
        end
    elseif Mike_Warlock_Party[2] == UnitName("player") then
        if not UnitAura("player","Fel Intelligence") then
            Mike_CastSpellByName("Fel Intelligence")
            return
        end
    end
    if not UnitAura("player","Demon Armor") and Mike_Check_spell_ready("Demon Armor") then
        Mike_CastSpellByName("Demon Armor")
        return
    end
end

function Mike_Warlock_Aoe()

end

function Mike_Warlock_Affliction()
    Mike_Warlock_Summon_Attack()
    if Mike_Is_Busy() then return end
    Warlock_Cast_Dots()
    if Mike_Check_spell_ready("Haunt") and not Mike_Debuff_Check_If_Im_Owner("Haunt") then
        Mike_CastSpellByName("Haunt")
        SpellTargetUnit("target")
        return
    end
    Mike_Warlock_Cast_Curse()
    if Mike_Check_spell_ready("Shadow Bolt") then
        Mike_CastSpellByName("Shadow Bolt")
        SpellTargetUnit("target")
        return
    end
end

function Mike_Warlock_Cast_Curse()
    if Mike_Warlock_Party[1] == UnitName("player") then
        if not Mike_hasDebuff_Target("Curse of the Elements") then
            Mike_CastSpellByName("Curse of the Elements")
            SpellTargetUnit("target")
            return
        end
    elseif Mike_Warlock_Party[2] == UnitName("player") then
        if not Mike_hasDebuff_Target("Curse of Weakness") then
            Mike_CastSpellByName("Curse of Weakness")
            SpellTargetUnit("target")
            return
        end
    end
end

function Warlock_Cast_Dots()
    if not Mike_Debuff_Check_If_Im_Owner("Corruption") then
        Mike_CastSpellByName("Corruption")
        SpellTargetUnit("target")
        return
    end
    if not Mike_Debuff_Check_If_Im_Owner("Curse of Agony") then
        Mike_CastSpellByName("Curse of Agony")
        SpellTargetUnit("target")
        return
    end
    if IsSpellKnown(30108) then
        if not Mike_Debuff_Check_If_Im_Owner("Unstable Affliction") then
            Mike_CastSpellByName("Unstable Affliction")
            SpellTargetUnit("target")
            return
        end
    end
    if not Mike_Debuff_Check_If_Im_Owner("Immolate") then
        Mike_CastSpellByName("Immolate")
        SpellTargetUnit("target")
        return
    end
end

function Mike_Warlock_Demonology()
    Mike_Warlock_Summon_Attack()
    Mike_Print("Demonology not implemented")
    Warlock_Cast_Dots()
    
end

function Mike_Warlock_Destruction()
    Mike_Warlock_Summon_Attack()
    if Mike_Is_Busy() then return end
    Warlock_Cast_Dots()
    Mike_Warlock_Cast_Curse()
    if Mike_Check_spell_ready("Chaos Bolt") then
        Mike_CastSpellByName("Chaos Bolt")
        SpellTargetUnit("target")
        return
    end
    if Mike_Percentage_health("target") <= 0.1 then
        Mike_CastSpellByName("Drain Soul")
        SpellTargetUnit("target")
        return
    end
    if IsSpellKnown(29722) then
        if Mike_Debuff_Check_If_Im_Owner("Immolate") and Mike_Check_spell_ready("Incinerate") then
            Mike_CastSpellByName("Incinerate")
            SpellTargetUnit("target")
            return
        end
    end
    if Mike_Debuff_Check_If_Im_Owner("Immolate") and Mike_Check_spell_ready("Conflagrate") then
        Mike_CastSpellByName("Conflagrate")
        SpellTargetUnit("target")
        return
    end
end