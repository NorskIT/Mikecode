
local Mike_intCounter = 1
local Mike_buffCounter = 1

local Mike_isFightingBoss = false

local Mike_mage_jump = false


function Mike_Mage_Main()
    single_target_mage_arcane() 
end

function Combat_hp_mp_check()
    if UnitAffectingCombat("player") then
        if Mike_Percentage_mana("player") < 0.20 then
            if Mike_Check_spell_ready("Evocation") then
                Stop_Follow()
                CastSpellByName("Evocation")
                Mike_Print("Casting: Evocation")
            else
                Mana_pot()
            end
        end
        if Mike_Percentage_health("player") < 0.20 then
            if Mike_Check_spell_ready("Ice Block") then
                CastSpellByName("Ice Block")
                Mike_Print("Casting: Ice Block")
            else
                Heal_pot()
            end
        end
    end
end


-- ARCANE DPS
function single_target_mage_arcane()
    local spell = UnitChannelInfo("player")
    -- The Nexus last boss. Jumps if Crystallize has been removed.
    hasCrystallize = Mike_CountDebuff("Crystallize")
    if hasCrystallize <= 1 then
        Mike_mage_jump = true
    elseif Mike_mage_jump and hasCrystallize == 0 then
        JumpOrAscendStart()
        Mike_mage_jump = false
    end
    if spell == nil then
        Combat_hp_mp_check()
        for i, v in ipairs(Mike_party) do 
            Remove_curse(v)
        end
        if UnitExists("target") then
            if UnitClassification("target") == "elite" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss" then
                Mike_isFightingBoss = true;
            else
                Mike_isFightingBoss = false;
            end
            if Mike_Interrupt_target() then
                return
            end
            if IsMounted() then
                Dismount()
            end
            if Mike_isFightingBoss then
                CastSpellByName("Berserking")
                CastSpellByName("Presence of Mind")
                CastSpellByName("Icy Veins")
                Mike_Print("Casting: Boost spells")
            end
            if (UnitAura("player", "Missile Barrage") and Mike_CountAura("Arcane Blast") > 2) or Mike_CountAura("Arcane Blast") == 4 then
            --if UnitAura("player", "Missile Barrage") then
                Stop_Follow()
                CastSpellByName("Arcane Missiles")
                Mike_Print("Casting: Arcane Missiles")
            elseif IsSpellInRange("Arcane Blast", "target") then
                CastSpellByName("Arcane Blast");
                SpellTargetUnit("target");
                Mike_Print("Casting: Arcane Blast")
            end
        end
    end
end

-- FROST DPS
function single_target_mage_frost()
    local spell = UnitChannelInfo("player")
    if spell == nil then
        if Mike_Check_spell_ready("Ice Barrier") and not UnitAura("player", "Ice Barrier") then
            CastSpellByName("Ice Barrier")
        end
        Combat_hp_mp_check()
        for i, v in ipairs(Mike_party) do 
            Remove_curse(v)
        end
        if UnitExists("target") then
            if IsMounted() then
                Dismount()
            end
            if Mike_Check_spell_ready("Summon Water Elemental") then
                CastSpellByName("Summon Water Elemental")
            end
            Mike_Interrupt_target()
            if UnitExists("pet") then
                CastSpellByName("Waterbolt")
                SpellTargetUnit("target");
            end
            if Mike_Check_spell_ready("Deep Freeze") then
                CastSpellByName("Deep Freeze");
                SpellTargetUnit("target");
            end
            CastSpellByName("Frostbolt");
            SpellTargetUnit("target");
        end
    end
end

function Mage_aoe()
    Combat_hp_mp_check()
    local spell = UnitChannelInfo("player")
    if spell == nil then
        if IsMounted() then
            Dismount()
        end
        if Mike_Check_spell_ready("Arcane Explosion") then
            CastSpellByName("Arcane Explosion");
            Mike_Print("Casting: Arcane Explosion")
        end
    end
end

function Mage_buff()
    name = UnitName("player")
    if not UnitAura("player", "Molten Armor") then
        CastSpellByName("Molten Armor");
        SpellTargetUnit("player");
        Mike_Print("Casting: Molten Armor")
    end
    if Mike_partyMages[Mike_buffCounter] == name then
        for i, v in ipairs(Mike_party) do 
            if not UnitAura(v, "Arcane Brilliance") then
                if Mike_Check_spell_ready("Arcane Brilliance") then
                    ClearTarget();
                    ClearCursor();
                    CastSpellByName("Arcane Brilliance");
                end
            end
        end
    end  
    Mike_buffCounter = Mike_buffCounter + 1
    if Mike_buffCounter > 7 then
        Mike_buffCounter = 1
    end
end