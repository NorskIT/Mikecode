
local chargeCounter = 0

function Mike_Warrior_Main()
    single_target_warr_prot()
end

function single_target_warr_prot()
    if GetShapeshiftForm() ~= 2 then
        CastSpellByName("Defensive Stance")
        Mike_Print("Casting: Defensive Stance")
    end
    -- Prevents Intercept to be casted directly after Charge has been casted.
    if chargeCounter > 0 then
        chargeCounter = chargeCounter-1
    end
    if UnitExists("target") then
        -- Dismount if mounted.
        if IsMounted() then
            Dismount()
        end
        -- Check if player is about to die.
        
        if Mike_Percentage_health("player") <= 0.3 and UnitAffectingCombat("player") then
            if UnitAura("player", "Enrage") then
                CastSpellByName("Enraged Regeneration");
            end
            CastSpellByName("Last Stand");
            CastSpellByName("Shield Wall");
            CastSpellByName("Shield Block");
            Heal_pot()
            Mike_Print("Casting: Critical spells. Low health")
        end
        -- Try to interrupt spell
        Mike_Interrupt_target()
        -- Check for procs
        if Mike_Check_spell_ready("Revenge") then
            CastSpellByName("Revenge");
            SpellTargetUnit("target");
            Mike_Print("Casting: Revenge")
            return
        end
        if UnitAura("player","Sword and Board") then
            CastSpellByName("Shield Slam");
            SpellTargetUnit("target");
            Mike_Print("Casting proc: Shield Slam")
            return
        end
        if Mike_Percentage_health("player") > 0.80 and UnitMana("player") == 0 then
            CastSpellByName("Bloodrage");
            Mike_Print("Casting: Bloodrage")
            return
        end
        if IsSpellInRange("Devastate","target") == 0 then
            -- If target is far away Charge and Intercept
            if Mike_Check_spell_ready("Heroic Throw") then
                CastSpellByName("Heroic Throw");
                SpellTargetUnit("target");
                Mike_Print("Casting: Heroic Throw")
                return
            elseif Mike_Check_spell_ready("Charge") then
                chargeCounter = 5
                CastSpellByName("Charge");
                SpellTargetUnit("target");
                Mike_Print("Casting: Charge")
                return
            elseif Mike_Check_spell_ready("Intercept") and chargeCounter == 0 and UnitMana("player") > 7 then
                CastSpellByName("Berserker Stance");
                CastSpellByName("Intercept");
                SpellTargetUnit("target");
                Mike_Print("Casting: Intercept")
                return
            elseif Mike_Check_spell_ready("Taunt") then
                    CastSpellByName("Taunt");
                    SpellTargetUnit("target");
                    Mike_Print("Casting: Taunt")
                    return
            end
        else
            -- If target is close
            -- If target is not focusing player, then try to taunt it in different ways.
            if not UnitIsUnit("targettarget", "player") then
                if Mike_Check_spell_ready("Taunt") then
                    CastSpellByName("Taunt");
                    SpellTargetUnit("target");
                    Mike_Print("Casting: Taunt")
                    return
                end
                if Mike_Check_spell_ready("Thunder Clap") then
                    CastSpellByName("Thunder Clap");
                    SpellTargetUnit("target");
                    Mike_Print("Casting: Thunder Clap")
                    return
                end
                if Mike_Check_spell_ready("Mocking Blow") then
                    CastSpellByName("Mocking Blow");
                    SpellTargetUnit("target");
                    Mike_Print("Casting: Mocking Blow")
                    return
                end
            end
            -- Check if target had debuff
            if not UnitDebuff("target","Demoralizing Shout") then
                CastSpellByName("Demoralizing Shout")
                Mike_Print("Casting: Demoralizing Shout")
                return
            end
            if Mike_Check_spell_ready("Shockwave") then
                CastSpellByName("Shockwave")
                SpellTargetUnit("target");
                Mike_Print("Casting: Shockwave")
                return
            end
            if Mike_Check_spell_ready("Shield Slam") then
                CastSpellByName("Shield Slam")
                SpellTargetUnit("target");
                Mike_Print("Casting: Shield Slam")
                return
            end
            sunderCount = 0
            for i=1,40 do
                local name,_,_,count = UnitDebuff("target",i)
                if name == "Sunder Armor" then
                    sunderCount = count
                end
            end
            if sunderCount < 3 then
                CastSpellByName("Devastate")
                SpellTargetUnit("target");
                Mike_Print("Casting: Devastate")
                return
            end
            if Mike_Check_spell_ready("Thunder Clap") then
                CastSpellByName("Thunder Clap");
                SpellTargetUnit("target");
                Mike_Print("Casting: Thunder Clap")
                return
            end
        end
        if not UnitAura("player", "Battle Shout") then
            CastSpellByName("Battle Shout")
            Mike_Print("Casting: Battle Shout")
            return
        end
        if UnitMana("player") > 80 then
            CastSpellByName("Heroic Strike")
            Mike_Print("Casting: Heroic Strike")
        end
        Mike_Print("Casting: Devastate")
        CastSpellByName("Devastate")
        SpellTargetUnit("target");
    end
end


-- HELPFULL FUNTIONS. Not related to class.


-- END

