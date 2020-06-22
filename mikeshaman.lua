function Shaman_startup_heal()
    if not UnitAura("player", "Mana Spring") then
        CastSpellByName("Call of the Elements")
    end
    local hasEnchantWeapon = GetWeaponEnchantInfo("player")
    if hasEnchantWeapon == nil then
        CastSpellByName("Earthliving Weapon")
    end
    if not UnitAura("player", "Water Shield") and Mike_Percentage_health("player") == 1 then
        CastSpellByName("Water Shield")
    end
end

function Shaman_heal()
    Mike_Interrupt_target()
    local spellChannel = UnitChannelInfo("player")
    local spellCast = UnitCastingInfo("unit")
    if not spellChannel == nil and not spellCast == nil then return end
    if Detoxin() then return end
    if IsSpellInRange("Earth Shock","target") == 1 and Mike_Shaman_Interact and not spellChannel == nil and not spellCast == nil then
        Mike_Shaman_Interact = false
        if IsCurrentAction(24) then
            UseAction(24)
        end
        Stop_Follow()
        print("Stopped following")
    end
    if UnitAffectingCombat("player") or UnitAffectingCombat("Mikewarrior") then
        Shaman_startup_heal()
        if Mike_Percentage_mana("player") < 0.3 then
            if Mike_Check_spell_ready("Mana Tide Totem") then
                CastSpellByName("Mana Tide Totem")
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
                CastSpellByName("Nature's Swiftness")
                return
            end
            if Mike_Check_spell_ready("Tidal Force")then
                CastSpellByName("Tidal Force")
                return
            end
        end
        if howManyHurt >= 4 then
            CastSpellByName("Chain Heal")
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
            CastSpellByName("Riptide")
            SpellTargetUnit(unit)
            return
        elseif Mike_Percentage_health(unit) <= 0.7 and Mike_Check_spell_ready("Lesser Healing Wave") then
            print("Casting: Lesser Healing Wave. Target: "..UnitName(unit))
            CastSpellByName("Lesser Healing Wave")
            SpellTargetUnit(unit)
            return
        elseif Mike_Percentage_health(unit) <= 0.4 and Mike_Check_spell_ready("Healing Wave") then
            print("Casting: Healing Wave. Target: "..UnitName(unit))
            CastSpellByName("Healing Wave")
            SpellTargetUnit(unit)
            return
        end
    end
    _,englishClass,_ = UnitClass(unit);
    if englishClass == "WARRIOR" and Mike_Check_spell_ready("Earth Shield") then
        if not UnitAura(unit,"Earth Shield") then
            CastSpellByName("Earth Shield");
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
                CastSpellByName("Ancestral Spirit")
                SpellTargetUnit(v)
                return
            end
        end
        for i, v in ipairs(Mike_party) do
            _,englishClass,_ = UnitClass(v);
            if UnitIsDead(v) then
                CastSpellByName("Ancestral Spirit")
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
                        CastSpellByName("Cure Toxins");
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


