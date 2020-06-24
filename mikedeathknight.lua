local Mike_dk_Interacting = false

function Mike_dk_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_dk_Interacting = true
    end
    if arg == "Ammo needs to be in the paper doll ammo slot before it can be fired." then
        SendChatMessage("NO AMMO LEFT", "RAID", nil, nil)
    end
end

function Mike_dk_Main()
    if Mike_dk_Talent == nil then
        Mike_dk_Talent = Mike_GetTalentIndex()
    end
    Mike_dk_Common_Function()
    if Mike_dk_Talent == "Beast Mastery" then
        Mike_dk_BeastMastery()
    elseif Mike_dk_Talent == "Marksmanship" then
        Mike_dk_Marksmanship()
    elseif Mike_dk_Talent == "Survival" then
        Mike_dk_Survival()
    end
end

function Mike_dk_BeastMastery()
    -- Not implemented
end

function Mike_dk_Marksmanship()
    -- Not implemented
end

function Mike_dk_Survival()
    -- Not implemented
end

function Mike_dk_Buff()
    -- Not implemented
end

function Mike_dk_Critical_Health()
    if Mike_Percentage_health("player") <= 0.8 and Mike_Check_spell_ready("Barkskin") then
    end
end

function Mike_dk_Common_Function()
    -- Not implemented
end