
local Mike_buffCounter = 1
local Mike_isFightingBoss = false
local Mike_Mage_Talent = nil
local Mike_Mage_Interacting = false
local Mike_Mage_Interact_Bug_Fix_Counter = 0
local Mike_Mage_Party = {}

function Mike_Mage_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_Mage_Interacting = true
    end
end


function Mike_Mage_Main()
    Mike_Role = "caster"
    Mike_Mage_Common_Function()
    if Mike_Mage_Interacting then return end
    if Mike_Mage_Talent == nil then
        Mike_Mage_Talent = Mike_GetTalentIndex()
    end
    if Mike_Mage_Talent == "Frost" then
        Mike_Mage_Frost()
    elseif Mike_Mage_Talent == "Arcane" then
        Mike_Mage_Arcane()
    elseif Mike_Mage_Talent == "Fire" then
        Mike_Mage_Fire()
    end
end

function Mike_Mage_Critical_Health()
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

function Mike_Mage_Common_Function()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if IsSpellInRange("Arcane Blast","target") == 1 and Mike_Mage_Interacting then
        print("x")
        Mike_Mage_Interacting = false
        StopAttack()
        Stop_Follow()
        print("Stopped following")
    end
    Mike_Mage_Critical_Health()
end

-- ARCANE DPS
function Mike_Mage_Arcane()
    if not Mike_Is_Busy() then
        for i=1, Mike_Get_Group_Size() do
            Remove_curse(Mike_Get_Group_Prefix()..i)
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
function Mike_Mage_Frost()
    local spell = UnitChannelInfo("player")
    if spell == nil then
        if Mike_Check_spell_ready("Ice Barrier") and not UnitAura("player", "Ice Barrier") then
            CastSpellByName("Ice Barrier")
        end
        for i=1, Mike_Get_Group_Size() do
            Remove_curse(Mike_Get_Group_Prefix()..i)
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

function Mike_Mage_Aoe()
    Mike_Mage_Common_Function()
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

function Mike_Mage_Buff()
    if table.getn(Mike_Mage_Party) == 0 then
        for x=1, Mike_Get_Group_Size() do
            class = UnitClass(Mike_Get_Group_Prefix()..x)
            if class == "Mage" then
                Mike_Mage_Party[#Mike_Mage_Party+1] = UnitName(Mike_Get_Group_Prefix()..x)
            end
        end
        Mike_Mage_Party = Mike_Sort_Table(Mike_Mage_Party)
    end
    name = UnitName("player")
    if not UnitAura("player", "Molten Armor") then
        CastSpellByName("Molten Armor");
        SpellTargetUnit("player");
        Mike_Print("Casting: Molten Armor")
    end
    if Mike_Mage_Party[Mike_buffCounter] == name then
        for i=1, Mike_Get_Group_Size() do
            if not UnitAura(Mike_Get_Group_Prefix()..i, "Arcane Brilliance") then
                if Mike_Check_spell_ready("Arcane Brilliance") then
                    ClearTarget();
                    ClearCursor();
                    CastSpellByName("Arcane Brilliance");
                end
            end
        end
    end  
    Mike_buffCounter = Mike_buffCounter + 1
    if Mike_buffCounter > table.getn(Mike_Mage_Party) then
        Mike_buffCounter = 1
    end
end