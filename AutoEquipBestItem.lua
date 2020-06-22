local slots = {"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist", "Waist", "Legs", "Feet", "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "MainHand", "SecondaryHand"}


function Equip()
    -- for each equip slot
    for i, slotName in ipairs(slots) do
        local slotID = GetInventorySlotInfo(slotName.."Slot")
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink ~= nil then
            local itemName,_,_,itemLevel,itemMinLevel,_,itemSubType,_,itemEquipLoc = GetItemInfo(itemLink)
            -- for each bag
            for bagID=0,11 do
                -- for each slot in current bag
                for v=0,GetContainerNumSlots(bagID) do
                    local bagItemLink = GetContainerItemLink(bagID, v)
                    if bagItemLink ~= nil then
                        local bagItemName,_,_,bagItemLevel,bagItemMinLevel,_,bagItemSubType,_,bagItemEquipLoc = GetItemInfo(bagItemLink)
                        bagItemGS = GearScore_GetItemScore_Mike(bagItemLink)
                        itemGS = GearScore_GetItemScore_Mike(itemLink)
                        -- check if item in bag is better than equipped item
                        if bagItemEquipLoc == itemEquipLoc and bagItemSubType == itemSubType and bagItemGS > itemGS and UnitLevel("player") >= bagItemMinLevel and IsEquippableItem(bagItemName) then
                            -- if better, change item
                            EquipItemByName(bagItemName)
                            EquipPendingItem(0);
                        end
                    end
                end
            end
        end
    end
end



-- Gearscore code. Author: Gearscore creators?
function GearScore_GetItemScore_Mike(ItemLink)
	local QualityScale = 1; local PVPScale = 1; local PVPScore = 0; local GearScore = 0
	if not ( ItemLink ) then return 0, 0; end
	local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink); local Table = {}; local Scale = 1.8618
 	if ( ItemRarity == 5 ) then QualityScale = 1.3; ItemRarity = 4;
	elseif ( ItemRarity == 1 ) then QualityScale = 0.005;  ItemRarity = 2
	elseif ( ItemRarity == 0 ) then QualityScale = 0.005;  ItemRarity = 2 end
    if ( ItemRarity == 7 ) then ItemRarity = 3; ItemLevel = 187.05; end
    local TokenLink, TokenNumber = GearScore_GetItemCode_Mike(ItemLink)
	if ( GS_Tokens[TokenNumber] ) then return GS_Tokens[TokenNumber].ItemScore, GS_Tokens[TokenNumber].ItemLevel, GS_Tokens[TokenNumber].ItemSlot; end
    if ( GS_ItemTypes[ItemEquipLoc] ) then
        if ( ItemLevel > 120 ) then Table = GS_Formula["A"]; else Table = GS_Formula["B"]; end
		if ( ItemRarity >= 2 ) and ( ItemRarity <= 4 )then
            local Red, Green, Blue = GearScore_GetQuality_Mike((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 12.25 )
            GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * GS_ItemTypes[ItemEquipLoc].SlotMOD * Scale * QualityScale)
			if ( ItemLevel == 187.05 ) then ItemLevel = 0; end
			if ( GearScore < 0 ) then GearScore = 0;   Red, Green, Blue = GearScore_GetQuality_Mike(1); end
			GearScoreTooltip:SetOwner(GS_Frame1, "ANCHOR_Right")
			if ( PVPScale == 0.75 ) then PVPScore = 1; GearScore = GearScore * 1; 
			else PVPScore = GearScore * 0; end
			GearScore = floor(GearScore)
			PVPScore = floor(PVPScore)
			return GearScore, ItemLevel, GS_ItemTypes[ItemEquipLoc].ItemSlot, Red, Green, Blue, PVPScore, ItemEquipLoc;
		end
  	end
	return -1, ItemLevel, 50, 1, 1, 1, PVPScore, ItemEquipLoc
end

function GearScore_GetItemCode_Mike(ItemLink)
	if not ( ItemLink ) then return nil; end
	local found, _, ItemString = string.find(ItemLink, "^|c%x+|H(.+)|h%[.*%]"); local Table = {}
	for v in string.gmatch(ItemString, "[^:]+") do tinsert(Table, v); end
	return Table[2]..":"..Table[3], Table[2]
end

function GearScore_GetQuality_Mike(ItemScore)
	--if not ItemScore then return; end
	--ItemScore = ItemScore / 2;
	local Red = 0.1; local Blue = 0.1; local Green = 0.1; local GS_QualityDescription = "Legendary"
   	if not ( ItemScore ) then return 0, 0, 0, "Trash"; end
   	if ( ItemScore > 5999 ) then ItemScore = 5999; end
	for i = 0,6 do
		if ( ItemScore > i * 1000 ) and ( ItemScore <= ( ( i + 1 ) * 1000 ) ) then
		    local Red = GS_Quality[( i + 1 ) * 1000].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Red["B"])*GS_Quality[( i + 1 ) * 1000].Red["C"])*GS_Quality[( i + 1 ) * 1000].Red["D"])
            local Blue = GS_Quality[( i + 1 ) * 1000].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Green["B"])*GS_Quality[( i + 1 ) * 1000].Green["C"])*GS_Quality[( i + 1 ) * 1000].Green["D"])
            local Green = GS_Quality[( i + 1 ) * 1000].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Blue["B"])*GS_Quality[( i + 1 ) * 1000].Blue["C"])*GS_Quality[( i + 1 ) * 1000].Blue["D"])
			return Red, Green, Blue, GS_Quality[( i + 1 ) * 1000].Description
		end
	end
return 0.1, 0.1, 0.1
end