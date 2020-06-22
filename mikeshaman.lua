-- (1): Elemental (2): Enchancement (3): Restoration
local Mike_Shaman_talent = nil

function Mike_Shaman_Main()
    Mike_Shaman_Common_Function()
    if Mike_Shaman_talent == nil then
        Mike_Shaman_talent = Mike_GetTalentIndex()
    end
    if Mike_Shaman_talent == 1 then
        if UnitName("player") ~= Mike_Name_Main then
            AssistUnit(Mike_Name_Main)
        end
        Mike_Role = "caster"
        Mike_Shaman_Elemental()
    elseif Mike_Shaman_talent == 2 then
        if UnitName("player") ~= Mike_Name_Main then
            AssistUnit(Mike_Name_Main)
        end
        Mike_Role = "melee"
        Mike_Shaman_Enchancement()
    elseif Mike_Shaman_talent == 3 then
        Mike_Role = "caster"
        Mike_Shaman_Restoration()
    end
        
end

function Mike_Shaman_Enchancement()
    -- Not implemented
end

function Mike_Shaman_Aoe()

end

function Mike_Shaman_PowerUp()

end

function Mike_Shaman_Common_Function()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if IsSpellInRange("Earth Shock","target") == 1 and Mike_Caster_Interact and spellChannel == nil and spellCast == nil then
        Mike_Caster_Interact = false
        if IsCurrentAction(24) then
            UseAction(24)
        end
        Stop_Follow()
        print("Stopped following")
    end
end

function Mike_Shaman_Elemental()
    Mike_Call_Of_the_Elements()
    if Mike_Check_spell_ready("Flame Shock") and not UnitAura("target","Flame Shock") then
        Mike_CastSpellByName("Flame Shock")
        SpellTargetUnit("target")
        return
    elseif Mike_Check_spell_ready("Lava Burst") and UnitAura("target","Flame Shock") and IsSpellKnown(51505) == true then
        Mike_CastSpellByName("Lava Burst")
        SpellTargetUnit("target")
        return
    elseif Mike_Check_spell_ready("Elemental Mastery") then
        Mike_CastSpellByName("Elemental Mastery")
        return
    elseif Mike_Check_spell_ready("Chain Lightning") then
        Mike_CastSpellByName("Chain Lightning")
        SpellTargetUnit("target")
        return
    else
        Mike_CastSpellByName("Lightning Bolt")
        SpellTargetUnit("target")
        return
    end
end

function Mike_Call_Of_the_Elements()
    local totalTotemsUp = 0
    for x=1,4 do
        haveTotem, totemName, startTime, duration = GetTotemInfo(x)
        if totemName ~= "" then
            totalTotemsUp = totalTotemsUp + 1
        end
    end
    if totalTotemsUp <= 2 then
        Mike_CastSpellByName("Call of the Elements")
    end 
end

function Shaman_startup_heal()
    if not UnitAura("player", "Mana Spring") then
       Mike_CastSpellByName("Call of the Elements")
    end
    local hasEnchantWeapon = GetWeaponEnchantInfo("player")
    if hasEnchantWeapon == nil then
       Mike_CastSpellByName("Earthliving Weapon")
    end
    if not UnitAura("player", "Water Shield") and Mike_Percentage_health("player") == 1 then
       Mike_CastSpellByName("Water Shield")
    end
end

function Mike_Shaman_Restoration()
    Mike_Interrupt_target()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("player")
    if not spellChannel == nil and not spellCast == nil then return end
    if Detoxin() then return end
    if UnitAffectingCombat("player") or UnitAffectingCombat("Mikewarrior") then
        Shaman_startup_heal()
        if Mike_Percentage_mana("player") < 0.3 then
            if Mike_Check_spell_ready("Mana Tide Totem") then
               Mike_CastSpellByName("Mana Tide Totem")
                return
            end
        end
    elseif Mike_Is_Anyone_Dead() and Mike_None_In_Combat() then
        Shaman_res()
        return
    end
    local playerToHeal, unitHealth, howManyMinorHurt, howManyHurt, howManyCriticalHurt = Mike_Member_most_hurt()
    if playerToHeal ~= nil then
        if (howManyHurt + howManyCriticalHurt) > 4 then
            if Mike_Check_spell_ready("Nature's Swiftness") then
               Mike_CastSpellByName("Nature's Swiftness")
                return
            end
            if Mike_Check_spell_ready("Tidal Force")then
               Mike_CastSpellByName("Tidal Force")
                return
            end
        end
        if howManyHurt >= 4 then
           Mike_CastSpellByName("Chain Heal")
            SpellTargetUnit(playerToHeal)
            return
        else
            Heal(playerToHeal)
        end
    end
end

function Heal(unit)
    if Mike_Percentage_health(unit) ~= 1 then
        ClearTarget()
        if Mike_Percentage_health(unit) <= 0.9 and not UnitAura(unit, "Riptide") and Mike_Check_spell_ready("Riptide") then
            print("Casting Riptide")
           Mike_CastSpellByName("Riptide")
            SpellTargetUnit(unit)
            return
        elseif Mike_Percentage_health(unit) <= 0.7 and Mike_Check_spell_ready("Lesser Healing Wave") then
            print("Casting: Lesser Healing Wave. Target: "..UnitName(unit))
           Mike_CastSpellByName("Lesser Healing Wave")
            SpellTargetUnit(unit)
            return
        elseif Mike_Percentage_health(unit) <= 0.4 and Mike_Check_spell_ready("Healing Wave") then
            print("Casting: Healing Wave. Target: "..UnitName(unit))
           Mike_CastSpellByName("Healing Wave")
            SpellTargetUnit(unit)
            return
        end
    end
    _,englishClass,_ = UnitClass(unit);
    if englishClass == "WARRIOR" and Mike_Check_spell_ready("Earth Shield") then
        if not UnitAura(unit,"Earth Shield") then
           Mike_CastSpellByName("Earth Shield");
            SpellTargetUnit(unit);
            return
        end
    end
end



function Shaman_res()
    local spell = UnitChannelInfo("player")
    if spell == nil then
        for i, v in ipairs(Mike_party) do
            _,englishClass,_ = UnitClass(v);
            if englishClass == "PRIEST" and UnitIsDead(v) then
               Mike_CastSpellByName("Ancestral Spirit")
                SpellTargetUnit(v)
                return
            end
        end
        for i, v in ipairs(Mike_party) do
            _,englishClass,_ = UnitClass(v);
            if UnitIsDead(v) then
               Mike_CastSpellByName("Ancestral Spirit")
                SpellTargetUnit(v)
                return
            end
        end
    end
end


function Detoxin()
    for i, v in ipairs(Mike_party) do
        for o=1,40 do 
            local name,_,_,_,type = UnitDebuff(v,i,1) 
            if type == "Poison" then
                if Mike_Check_spell_ready("Cure Toxins") then
                        SendChatMessage("Remove poison on "..UnitName(v), "RAID", nil, nil)
                       Mike_CastSpellByName("Cure Toxins");
                        SpellTargetUnit(v);
                    return true
                end
            end
        end
    end
    return false
end



-- Return which memeber is most how, his health and how many are hurt





-- HELPFULL FUNTIONS. Not related to class.

-- END


