function Disenchant_auto()
    local spell = UnitChannelInfo("player")
        for bagID=0,11 do
            for v=0,GetContainerNumSlots(bagID) do
                local bagItemLink = GetContainerItemLink(bagID, v)
                if bagItemLink ~= nil then
                    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(bagItemLink)
                    if itemRarity >= 2 and (itemType == "Armor" or itemType == "Weapon") then
                        CastSpellByName("Disenchant")
                        UseContainerItem(bagID, v);
                        ClearCursor()
                        return
                    end
                end
            end
        end
end