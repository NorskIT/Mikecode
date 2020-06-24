local Mike_Hunter_Interacting = false
local Mike_Hunter_Turn_Left_Counter = 0

function Mike_Hunter_OnUpdate(arg)
    if arg ~= nil then
        print(Mike_Hunter_Turn_Left_Counter.. " " .. arg)
    end
    if arg == "Target needs to be in front of you." and Mike_Hunter_Turn_Left_Counter < 2 then
        print("TURN LEFT START")
        TurnLeftStart()
        Mike_Hunter_Turn_Left_Counter = Mike_Hunter_Turn_Left_Counter+1
        return
    end
    if Mike_Hunter_Turn_Left_Counter == 2 then
        print("TURN LEFT STOP")
        TurnLeftStop()
        Mike_Hunter_Turn_Left_Counter = 0
    end
    if arg == "You are too far away!" or arg == "Out of range." then
        TurnLeftStop()
        Mike_InteractUnit("target")
    end
    if arg == "Ammo needs to be in the paper doll ammo slot before it can be fired." then
        SendChatMessage("NO AMMO LEFT", "RAID", nil, nil)
    end
    TurnLeftStop()
end

function Mike_Hunter_Main()
    Mike_Role = "caster"
    if Mike_Hunter_Talent == nil then
        Mike_Hunter_Talent = Mike_GetTalentIndex()
    end
    Mike_Hunter_Common_Function()
    if Mike_Hunter_Talent == "Beast Mastery" then
        Mike_Hunter_BeastMastery()
    elseif Mike_Hunter_Talent == "Marksmanship" then
        Mike_Hunter_Marksmanship()
    elseif Mike_Hunter_Talent == "Survival" then
        Mike_Role = "melee"
        Mike_Hunter_Survival()
    end
end

function Mike_Hunter_Aoe()

end

function Mike_Hunter_BeastMastery()
    -- Not implemented
end

function Mike_Hunter_Marksmanship()
    Mike_Hunter_Pet()
    if not Mike_hasDebuff_Target("Hunter's Mark") then
        Mike_CastSpellByName("Hunter's Mark")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Serpent Sting") and not Mike_hasDebuff_Target("Serpent Sting") then
        Mike_CastSpellByName("Serpent Sting")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Chimera Shot") and Mike_hasDebuff_Target("Serpent Sting") then
        Mike_CastSpellByName("Chimera Shot")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Arcane Shot") then
        Mike_CastSpellByName("Arcane Shot")
        SpellTargetUnit("target")
        return
    end
    if Mike_Check_spell_ready("Steady Shot") then
        Mike_CastSpellByName("Steady Shot")
        SpellTargetUnit("target")
        return
    end
end

function Mike_Hunter_Survival()
    -- Not implemented
end

function Mike_Hunter_Pet()
    if not UnitAffectingCombat("player") then
        if UnitIsDead("pet") ~= nil then
            Mike_CastSpellByName("Revive Pet")
            return
        elseif not HasPetUI() then 
            Mike_CastSpellByName("Call Pet")
            return
        end
        if Mike_Percentage_health("pet") <= 1 then
            Mike_CastSpellByName("Mend Pet")
            return
        end
    else
        if Mike_Check_spell_ready("Demoralizing Screech") and not Mike_hasDebuff_Target("Demoralizing Screech") then
            Mike_CastSpellByName("Demoralizing Screech")
            SpellTargetUnit("target")
            return
        end
        if Mike_Check_spell_ready("Bite") then
            Mike_CastSpellByName("Bite")
            SpellTargetUnit("target")
            return
        end
    end
end

function Mike_Hunter_Buff()
    if not UnitAura("player","Trueshot Aura") and Mike_Check_spell_ready("Trueshot Aura") then
        Mike_CastSpellByName("Trueshot Aura")
        return
    end
    if not UnitAura("player","Aspect of the Monkey") and Mike_Check_spell_ready("Aspect of the Monkey") then
        Mike_CastSpellByName("Aspect of the Monkey")
        return
    end
end

function Mike_Hunter_Critical_Health()
    if Mike_Percentage_health("player") <= 0.8 and Mike_Check_spell_ready("Barkskin") then
    end
end

function Mike_Hunter_Common_Function()
end