Mike_party = {"player", "raid1", "raid2", "raid3", "raid4", "raid5", "raid6", "raid7", "raid8", "raid9"}
Mike_partyReverse = {"raid9", "raid8", "raid7", "raid6", "raid5", "raid4", "raid3", "raid2", "raid1", "player"}
Mike_partyName = {"Mikewarrior", "Mikemagen", "Mikemagto", "Mikemagtre", "Mikemagfire", "Mikemagfem", "Mikemagseks", "Mikemagsyv", "Mikepriest", "Mikeshamheal"}
Mike_partyMages = {"Mikemagen", "Mikemagto", "Mikemagtre", "Mikemagfire", "Mikemagfem", "Mikemagseks", "Mikemagsyv"}
Mike_partyInterruptors = {"Mikemagen", "Mikemagto", "Mikemagtre", "Mikemagfire", "Mikemagfem", "Mikemagseks", "Mikemagsyv", "Mikeshamheal", "Mikewarrior"}
Mike_health_flask = {"Runic Healing Potion", "Super Healing Potion"}
Mike_mana_flask = {"Runic Mana Potion", "Super Mana Potion"}

-- MAIN CHARACTER
Mike_Name_Main = "Mikepalen"

Mike_Priest_Interact = false

Mike_intCounter = 1

Mike_Role = nil -- tank / caster / melee
Mike_Caster_Interact = false -- Is a caster walking towards an enemy

local class = UnitClass("player")
if class == "Warrior" or class == "Paladin" then
    Mike_Role = "melee"
elseif class == "Mage" or class == "Shaman" then
    Mike_Role = "caster"
end

-- Change this to `true` if you want to output everything that is happening on all the toons. Gets printed in eachs toon chat window.
local Mike_Debug = true

local MAGNUSBOX = CreateFrame("Button","MAGNUSBOX",UIParent)

MAGNUSBOX:RegisterEvent("UI_ERROR_MESSAGE");
local Mike_outOfRange = false
local Mike_isMoving = false
function MAGNUSBOX:OnEvent()
    if (event == "UI_ERROR_MESSAGE" and arg1 ~= "Spell is not ready yet.") then
        if UnitName("player") == "Mikepriest" then
            Mike_Priest_Interact = true
        end
        if UnitName("player") == "Mikeshamheal" then
            Mike_Shaman_Interact = true
        end
        if (arg1 =="Target needs to be in front of you.") and UnitName("player") ~= "Mikepriest" then
            InteractUnit("target")
        elseif (arg1 == "Out of range.") and UnitName("player") ~= "Mikepriest"  then
            InteractUnit("target")
        elseif arg1 == "You are too far away!" and UnitName("player") ~= "Mikepriest"  then
            Mike_Paladin_OnUpdate("You are too far away!")
            InteractUnit("target")
        elseif IsSpellInRange("Arcane Blast", "target") and arg1 == "Can't do that while moving" then
            print("Stopped moving: " .. arg1)
            MoveForwardStart()
            MoveForwardStop()
        end
        return
    end
end
MAGNUSBOX:SetScript("OnEvent", MAGNUSBOX.OnEvent)

function Mike_Follow(spec)
    if UnitName("player") == Mike_Name_Main then return end
    if IsCurrentAction(24) then
        UseAction(24)
    end
    if spec == "Healer" then
        if UnitIsDeadOrGhost("Mikemagen") ~= nil then
            Mike_Follow_Closest()
        else
            FollowUnit("Mikemagen")
        end
        return
    else
        if UnitIsDeadOrGhost(Mike_Name_Main) ~= nil then
            Mike_Follow_Closest()
        else
            FollowUnit(Mike_Name_Main)
        end
        return
    end
end


function Mike_Assist()
    if UnitName("player") == Mike_Name_Main then return end
    AssistUnit(Mike_Name_Main)
    Mike_InteractUnit("target")
    if Mike_Role == "caster" then
        Mike_Caster_Interact = true
    end
end

function Mike_InteractUnit(target)
    SetCVar("autoInteract", 1)
    InteractUnit(target)
    SetCVar("autoInteract", 0)
end

function Mike_Setup()
    Mike_Interact_Counter = 0
    Mike_Create_Macros()
end

function Mike_Create_Macros()
    local race = UnitRace("player")
    if race == "Orc" then
        Mike_Mount_Sequence = "/run CastSpellByName(\"Tawny Wind Rider\"); CastSpellByName(\"Swift Timber Wolf\")"
    elseif race == "Troll" then
        Mike_Mount_Sequence = "/run CastSpellByName(\"Tawny Wind Rider\"); CastSpellByName(\"Swift Orange Raptor\")"
    elseif race == "Blood Elf" then
        Mike_Mount_Sequence = "/run CastSpellByName(\"Tawny Wind Rider\"); CastSpellByName(\"Swift Red Hawkstrider\")"
    end
    Mike_DeleteMacro("Mount")
    index=CreateMacro("Mount",0,Mike_Mount_Sequence,nil)
	PickupMacro(index)
	PlaceAction(56)
    ClearCursor()
    Mike_DeleteMacro("Mike_Buff")
    index=CreateMacro("Mike_Buff",1,"/run Mike_"..class.."_Buff()",nil)
	PickupMacro(index)
	PlaceAction(55)
    ClearCursor()


    if class ~= "Mage" then
        PickupSpell("Auto Attack")
        PlaceAction(24)
        ClearCursor()
    end
end

function Mike_Follow_Closest()
    local Mike_Group_Total = 0
    local Mike_Group_Prefix = nil
    if UnitInRaid("player") ~= nil then
        Mike_Group_Total = GetNumRaidMembers()
        Mike_Group_Prefix = "raid"
    else
        Mike_Group_Total = GetNumPartyMembers()
        Mike_Group_Prefix = "party"
    end
    for x=1, Mike_Group_Total do
        if UnitIsDeadOrGhost(Mike_Group_Prefix..x) == nil and CheckInteractDistance(Mike_Group_Prefix..x, 4) then
            FollowUnit(Mike_Group_Prefix..x)
        end
    end    
end

function Mike_Sort_Table(arr)
    table.sort(arr, function(a, b) return a > b end)
    return arr
end

function Mike_Set_Main()
    Mike_Name_Main = UnitName("player")
end

function Mike_GetTalentIndex()
    local Mike_pointChecker = 0
    local Mike_Talent_tName = nil
    for x=1,3 do
        local tName, _, pointsSpent, _, _ = GetTalentTabInfo(x)
        if Mike_pointChecker < pointsSpent then
            Mike_Talent_tName = tName
        end
    end
    return Mike_Talent_tName
end

function Mike_None_In_Combat()
    for i, v in ipairs(Mike_party) do
        if UnitAffectingCombat(v) then
            return false
        end
    end
    return true
end

function Mike_Is_Anyone_Dead()
    for i, v in ipairs(Mike_party) do
        if Mike_Percentage_health(v) == 0 then
            return true
        end
    end
    return false
end

-- Return which memeber is most low, his health and how many are hurt
function Mike_Member_most_hurt()
    local unitHealth = 1
    local unit = nil
    local howManyMinorHurt = 0      -- How many with less than 90% hp left
    local howManyHurt = 0           -- How many with less than 70% hp left.
    local howManyCriticalHurt = 0   -- How many with less than 50% hp left.
    for i, v in ipairs(Mike_party) do
        if Mike_Percentage_health(v) ~= 0 then
            if unit == nil then
                unit = v
            end
            if Mike_Percentage_health(v) < 0.9 and Mike_Percentage_health(v) >= 0.7 then
                --print("Minor")
                howManyMinorHurt = howManyMinorHurt + 1
            end
            if Mike_Percentage_health(v) < 0.7 and Mike_Percentage_health(v) >= 0.5 then
                --print("Medium")
                howManyHurt = howManyHurt + 1
            end
            if Mike_Percentage_health(v) < 0.5 then
                --print("Critical")
                howManyHurt = howManyHurt + 1
            end
            if Mike_Percentage_health(v) < unitHealth then
                unitHealth = Mike_Percentage_health(v)
                unit = v
            end
        end
    end
    return unit, unitHealth, howManyMinorHurt, howManyHurt, howManyCriticalHurt
end

function Stop_Follow()
    MoveForwardStart(0)
    MoveForwardStop(0)
end

function Mike_Target_is_close(unit)
    Mike_Unitname = UnitName(unit)
    return CheckInteractDistance(unit, 3) == 1 and Mike_Percentage_health(unit) ~= 0 and (UnitIsEnemy("player",unit) or Mike_Unitname == "Raid-debuffed Training Dummy")
end


function Heal_pot()
    for i, item in ipairs(Mike_health_flask) do
        UseItemByName(item)
    end
end

function Mana_pot()
    for i, item in ipairs(Mike_mana_flask) do
        UseItemByName(item)
    end
end

function Mike_Percentage_health(unitIdToCheckHealth)
    return math.floor((UnitHealth(unitIdToCheckHealth)/UnitHealthMax(unitIdToCheckHealth)) * 10) / 10
end

function Mike_Percentage_mana(unitIdToCheckMana)
    return  math.floor((UnitMana(unitIdToCheckMana)/UnitManaMax(unitIdToCheckMana)) * 10) / 10
end

function Remove_curse(unit)
    for i=1,40 do 
        local _,_,_,_,type = UnitDebuff(unit,i,1) 
        if type == "Curse" then
            CastSpellByName("Remove Curse");
            SpellTargetUnit(unit);
            SendChatMessage("Cast Remove Curse on "..unit, "RAID", nil, nil)
        end 
    end
end

function Mike_CountAura(aura)
    local Mike_aura_sum = 0
    for i=1,40 do
        local name,_,_,count = UnitDebuff("player",i)
        if name == aura then
            Mike_aura_sum = count
        end
    end
    return Mike_aura_sum
end

function Mike_CountBuff(aura)
    local Mike_buff_sum = 0
    for i=1,40 do
        local name,_,_,count = UnitBuff("player",i)
        if name == aura then
            Mike_buff_sum = count
        end
    end
    return Mike_buff_sum
end

function Mike_CountDebuff(aura)
    local Mike_debuff_sum = 0
    for i=1,40 do
        local name,_,_,count = UnitDebuff("player",i)
        if name == aura then
            Mike_debuff_sum = count
        end
    end
    return Mike_debuff_sum
end

function Mike_hasDebuff_Target(debuffName)
    local Mike_debuff_sum = 0
    for i=1,40 do
        local name,_,_,count = UnitDebuff("target",i)
        if name == debuffName then
            return true
        end
    end
    return false
end

function Mike_Check_spell_ready(spell)
    x = IsUsableSpell(spell)
    _,durgcd = GetSpellCooldown(61304)
    _,dur = GetSpellCooldown(spell)
    return x and durgcd == 0 and dur == 0
end

function Mike_CastSpellByName(spell)
    if Mike_Debug then
        print("Casting: "..spell)
    end
    CastSpellByName(spell)
end

function Mike_Print(x)
    if Mike_Debug then
        print(x)
    end
end

function Mike_DeleteMacro(indexorname)
    name,_,body,_ = GetMacroInfo(indexorname)
    if body then
        DeleteMacro(name)
    end
end

function Mike_Interrupt_target()
    spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("target")
    name = UnitName("player")
    if spell == nil then 
        return 
    end
    if not interrupt then
        print("Spell is interruptable")
        print("List name: " .. Mike_partyInterruptors[Mike_intCounter])
        Mike_intCounter = Mike_intCounter + 1
        if Mike_intCounter > 9 then
            Mike_intCounter = 1
        end
        if  Mike_partyInterruptors[Mike_intCounter] == name then
            print("Enemy is casting:" .. spell)
            _,englishClass,_ = UnitClass("player");
            if englishClass == "WARRIOR" then
                if Mike_Check_spell_ready("Shield Bash") then
                    CastSpellByName("Shield Bash")
                    SpellTargetUnit("target")
                    SendChatMessage("Casting: Shield Bash on target: "..UnitName("target"), "RAID", nil, nil)
                    return true
                elseif Mike_Check_spell_ready("Pummel") then
                    CastSpellByName("Berserker Stance")
                    CastSpellByName("Pummel")
                    SpellTargetUnit("target")
                    SendChatMessage("Casting: Pummel on target: "..UnitName("target"), "RAID", nil, nil)
                    return true
                end
            elseif englishClass == "MAGE" then
                if Mike_Check_spell_ready("Counterspell") then
                    Stop_Follow()
                    CastSpellByName("Counterspell")
                    SpellTargetUnit("target")
                    SendChatMessage("Casting: Counterspell on target: "..UnitName("target"), "RAID", nil, nil)
                    return true
                    
                end
            elseif englishClass == "SHAMAN" then
                if Mike_Check_spell_ready("Wind Shear") then
                    Stop_Follow()
                    CastSpellByName("Wind Shear")
                    SpellTargetUnit("target")
                    SendChatMessage("Casting: Wind Shear on target: "..UnitName("target"), "RAID", nil, nil)
                    return true
                end
            end
        end
    end
    return false
end

-- END