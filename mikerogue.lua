local Mike_Rogue_Interacting = false

function Mike_Rogue_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_Rogue_Interacting = true
    end
    if arg == "Ammo needs to be in the paper doll ammo slot before it can be fired." then
        SendChatMessage("NO AMMO LEFT", "RAID", nil, nil)
    end
end

function Mike_Rogue_Main()
    if Mike_Rogue_Talent == nil then
        Mike_Rogue_Talent = Mike_GetTalentIndex()
    end
    Mike_Rogue_Common_Function()
    if Mike_Rogue_Talent == "Beast Mastery" then
        Mike_Rogue_BeastMastery()
    elseif Mike_Rogue_Talent == "Marksmanship" then
        Mike_Rogue_Marksmanship()
    elseif Mike_Rogue_Talent == "Survival" then
        Mike_Rogue_Survival()
    end
end

function Mike_Rogue_BeastMastery()
    -- Not implemented
end

function Mike_Rogue_Marksmanship()
    -- Not implemented
end

function Mike_Rogue_Survival()
    -- Not implemented
end

function Mike_Rogue_Buff()
    -- Not implemented
end

function Mike_Rogue_Critical_Health()
    if Mike_Percentage_health("player") <= 0.8 and Mike_Check_spell_ready("Barkskin") then
    end
end

function Mike_Rogue_Common_Function()
    -- Not implemented
end