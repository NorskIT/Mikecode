--Priest variables
local Mike_Priest_lowHpHeal = false

local Mike_Priest_Heal_All = true
local Mike_Priest_Interacting = false

function Mike_Priest_OnUpdate(arg)
    if arg == "You are too far away!" or arg == "Target needs to be in front of you." then
        Mike_InteractUnit("target")
        Mike_Mage_Interacting = true
    end
end

function Mike_Priest_Main()
    Mike_Role = "caster"
    if Mike_Priest_Talent == nil then
        Mike_Priest_Talent = Mike_GetTalentIndex()
    end
    Mike_Priest_Common_Function()

    if Mike_Priest_Talent == "Holy" then
        Mike_Priest_Holy()
    elseif Mike_Priest_Talent == "Shadow" then
        --Mike_Priest_Shadow()
    elseif Mike_Priest_Talent == "Discipline" then
        --Mike_Priest_Discipline()
    end
end

function Mike_Priest_Common_Function()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if IsSpellInRange("Smite","target") == 1 and Mike_Mage_Interacting and spellChannel == nil and spellCast == nil then
        Mike_Mage_Interacting = false
        StopAttack()
        Stop_Follow()
        print("Stopped following")
    end
end

function Mike_Priest_Holy()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("unit")
    if UnitExists("target") then
        if IsMounted() then
            Dismount()
        end
    end
    if Mike_Is_Anyone_Dead() and Mike_None_In_Combat() then
        Priest_res()
        return
    end
    if UnitAffectingCombat("player") then
        if Mike_Percentage_mana("player") < 0.30 then
            if Mike_Check_spell_ready("Shadowfiend") then
                Mike_Print("Casting: Shadowfiend")
                CastSpellByName("Shadowfiend");
                SpellTargetUnit("target");
            else
                Mike_Print("Casting: tries to use mana pot")
                
                if Mike_Percentage_mana("player") <= 0.10 then
                    Mana_pot()
                end
            end
        end
    end
    
    if Mike_Check_spell_ready("Power Word: Shield") and not UnitAura("Mikewarrior","Power Word: Shield") then
        TargetUnit("Mikewarrior")
        if IsUsableSpell("Power Word: Shield") then
            CastSpellByName("Power Word: Shield")
            SpellTargetUnit("Mikewarrior")
        end
    end
    
    if Mike_Percentage_mana("player") <= 0.3 then
        Mike_Print("Casting: Guardian Spirit on "..UnitName("Mikewarrior"))
        CastSpellByName("Guardian Spirit");
        SpellTargetUnit("Mikewarrior");
    end
    if not UnitAura("Mikewarrior", "Fear Ward") and Mike_Check_spell_ready("Fear Ward") then
        ClearCursor()
        CastSpellByName("Fear Ward");
        SpellTargetUnit("Mikewarrior");
    end
    if Mike_Percentage_health("Mikewarrior") <= 0.4 then
        Mike_Holy_Heal("Mikewarrior")
        return
    end

    if not Mike_Priest_Heal_All then return end

    -- then heal team
    local unitToHeal, unitHealth, howManyMinorHurt, howManyHurt, howManyCriticalHurt = Mike_Member_most_hurt()
    if howManyMinorHurt ~= 0 or howManyHurt ~= 0 or howManyCriticalHurt ~= 0 then
        print("Minor: " .. howManyMinorHurt .. ". Middel: " .. howManyHurt .. ". Critical: " .. howManyCriticalHurt)
    end
    if howManyCriticalHurt >= 3 then
        if unitHealth < 0.3 then
            Mike_Print(UnitName(unitToHeal).." has less than 30% HP. Skipping aoe heal")
            Mike_Holy_Heal(unitToHeal)
            return
        end
        print("Party heal on: "..unitToHeal)
        if Mike_Check_spell_ready("Circle of Healing") then
            CastSpellByName("Circle of Healing on "..UnitName(unitToHeal))
            SpellTargetUnit(unitToHeal)
            return
        end
        Mike_Print("Casting: Prayer of Healing on "..UnitName(unitToHeal))
        CastSpellByName("Prayer of Healing")
        SpellTargetUnit(unitToHeal)
        return
    end

    -- Check if we need normal (less than 70% hp) mass healing
    if howManyHurt >= 3 then
        Mike_Print("Casting: Prayer of Healing on "..UnitName(unitToHeal))
        CastSpellByName("Prayer of Healing")
        SpellTargetUnit(unitToHeal)
        return
    end

    -- Check if we need minor (less than 90% hp) mass healing
    if howManyMinorHurt >= 3 then
        if Mike_Check_spell_ready("Circle of Healing") then
            Mike_Print("Casting: Circle of Healing on "..UnitName(unitToHeal))
            CastSpellByName("Circle of Healing")
            SpellTargetUnit(unitToHeal)
            return
        end
    end
    Mike_Holy_Heal(unitToHeal)
    
end

function Mike_Holy_Heal(unitHeal)
    local _,englishClass,_ = UnitClass(unitHeal);
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("unit")
    if not spellChannel == nil and not spellCast == nil then return end
    if UnitAura("player","Spirit of Redemption") then
        CastSpellByName("Prayer of Healing")
        SpellTargetUnit(unitToHeal)
    end
    --ClearTarget()
    if Mike_Percentage_health(unitHeal) ~= 0 or not Mike_Percentage_health(unitHeal) == 1 then
        if Cleans(unitHeal) then
            return
        end
        if UnitAura("player","Surge of Light") and Mike_Percentage_health(unitHeal) <= 0.6 and not Mike_Percentage_health(unitHeal) == 1 then
            CastSpellByName("Flash Heal");
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Flash Heal. Prox: Surge of Light")
            return
        end
        if Mike_CountBuff("Serendipity") == 3 and Mike_Percentage_health(unitHeal) <= 0.6 then
            CastSpellByName("Greater Heal");
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Greater Heal")
            return
        elseif Mike_Priest_lowHpHeal and Mike_CountBuff("Serendipity") >= 2 then
            CastSpellByName("Greater Heal");
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Greater Heal")
            Mike_Priest_lowHpHeal = false;  
            return
        elseif Mike_Percentage_health(unitHeal) <= 0.20 then
            if Mike_Check_spell_ready("Inner Focus") then
                CastSpellByName("Inner Focus");
            end
            if Mike_CountBuff("Serendipity") >= 2 then
                CastSpellByName("Greater Heal");
                SpellTargetUnit(unitHeal);
                Mike_Print("Casting: Greater Heal")
                return
            else
                if UnitName("player") == UnitName(unitHeal) then
                    CastSpellByName("Flash Heal");
                    SpellTargetUnit(unitHeal);
                    Mike_Print("Casting: Flash Heal")
                    return
                end
                CastSpellByName("Binding Heal");
                SpellTargetUnit(unitHeal);
                Mike_Print("Casting: Binding Heal")
                Mike_Priest_lowHpHeal = true;  
                return
            end
        elseif Mike_Percentage_health(unitHeal) <= 0.5 then
            if UnitName("player") == UnitName(unitHeal) then
                CastSpellByName("Flash Heal");
                SpellTargetUnit(unitHeal);
                Mike_Print("Casting: Flash Heal")
                return
            end
            CastSpellByName("Binding Heal")
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Binding Heal")
            return
        elseif Mike_Percentage_health(unitHeal) > 0.5 and Mike_Percentage_health(unitHeal) <= 0.7 then
            CastSpellByName("Flash Heal")
            SpellTargetUnit(unitHeal)
            Mike_Print("Casting: Flash Heal")
            return
        end
        if not UnitAura(unitHeal, "Renew") and Mike_Percentage_health(unitHeal) <= 0.9 then
            CastSpellByName("Renew");
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Renew")
            return
        end
        if not UnitAura(unitHeal, "Prayer of Mending") and Mike_Check_spell_ready("Prayer of Mending") and Mike_Percentage_health(unitHeal) <= 0.9 and englishClass == "WARRIOR" then
            CastSpellByName("Prayer of Mending");
            SpellTargetUnit(unitHeal);
            Mike_Print("Casting: Prayer of Mending")
            return
        end
    end
    if Mike_Check_spell_ready("Fade") and Mike_Percentage_mana("player") >= 0.5 then
        CastSpellByName("Fade");
        return
    end
    if not IsCurrentAction(24) then -- 24 is last spot on second row
        --UseAction(24)
    end
end

function Cleans(unit)
    for i=1,40 do 
        local _,_,_,_,type = UnitDebuff(unit,i,1) 
        if type == "Disease" and Mike_Check_spell_ready("Cure Disease") then
            ClearTarget()
            CastSpellByName("Cure Disease");
            Mike_Print("Casting: Binding Heal")
            SendChatMessage("Cast Cure Disease on "..unit, "RAID", nil, nil)
            SpellTargetUnit(unit);
            return true
        end
        if type == "Magic" and Mike_Check_spell_ready("Dispel Magic") then
            ClearTarget()
            SendChatMessage("Cast Dispel Magic on "..UnitName(unit), "RAID", nil, nil)
            CastSpellByName("Dispel Magic");
            SpellTargetUnit(unit);
            return true
        end 
    end
    return false
end

function Mike_Priest_Aoe()

end

function Priest_res()
    local spell = UnitChannelInfo("player")
    if spell == nil then
        for i=1, Mike_Get_Group_Size() do
            _,englishClass,_ = UnitClass(Mike_Get_Group_Prefix()..i);
            if (englishClass == "SHAMAN" or englishClass == "PRIEST") and UnitIsDeadOrGhost(Mike_Get_Group_Prefix()..i) == 1 then
                Mike_CastSpellByName("Resurrection")
                SpellTargetUnit(Mike_Get_Group_Prefix()..i)
                Mike_Print("Casting: Ressurection on "..UnitName(Mike_Get_Group_Prefix()..i))
            end
        end
        for i=1, Mike_Get_Group_Size() do
            if UnitIsDeadOrGhost(Mike_Get_Group_Prefix()..i) == 1 then
                Mike_CastSpellByName("Resurrection")
                SpellTargetUnit(Mike_Get_Group_Prefix()..i)
                Mike_Print("Casting: Ressurection on "..UnitName(Mike_Get_Group_Prefix()..i))
            end
        end
    end
end

function Mike_Priest_Buff()
    if not UnitAura("player", "Inner Fire") then
        CastSpellByName("Inner Fire");
        SpellTargetUnit("player");
    end
    for i=1, Mike_Get_Group_Size() do
        local v = Mike_Get_Group_Prefix()..i
        if not UnitAura(v, "Prayer of Fortitude") then
            if Mike_Check_spell_ready("Prayer of Fortitude") then
                ClearTarget();
                ClearCursor();
                CastSpellByName("Prayer of Fortitude");
            end
        end
        powerType, powerTypeString = UnitPowerType(v);
        if powerTypeString == "MANA" then
            if not UnitAura(v, "Prayer of Spirit") then
                if Mike_Check_spell_ready("Prayer of Spirit") then
                    ClearTarget();
                    ClearCursor();
                    CastSpellByName("Prayer of Spirit");
                end
            end
        end
        if not UnitAura(v, "Prayer of Shadow Protection") then
            if Mike_Check_spell_ready("Prayer of Shadow Protection") then
                ClearTarget();
                ClearCursor();
                CastSpellByName("Prayer of Shadow Protection");
            end
        end
    end
end