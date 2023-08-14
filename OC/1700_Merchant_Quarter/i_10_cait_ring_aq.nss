// 'i_10_cait_ring_aq'
/*
	In the Tomb of the Betrayers area ({1019}tombs)(1700_Merchant_Quarter.mod)
	there is a chest in the NW chamber which contains the unique Ring of
	Caitlyn. This ring has two properties:

		AC Bonus +2 (deflection)
		Armor Bonus vs undead +1 (deflection)

	Deflection bonuses do not stack, so this ring will only ever provide a +2
	bonus no matter if fighting undead or not as the best deflection bonus will
	be used. I'm assuming the intent was to stack the bonuses for a total +3 AC
	bonus when fighting undead.

	The easiest way to fix this is to run an ItemAcquired script that changes
	the Armor Bonus vs undead to +3.

	On a side note, the only blueprint for this item (10caitring) is located in
	the 1000_Neverwinter_A1 mod.
*/
// travus 2023 aug 9
// kevL 2023 aug 13 - refactor and move MarkItemAsDone() out of the loop

#include "ginc_item_script"

//
void main()
{
	if (IsItemAcquiredByPartyMember())
	{
		object oItem = GetModuleItemAcquired();
		if (!IsItemMarkedAsDone(oItem, SCRIPT_MODULE_ON_ACQUIRE_ITEM))
		{
			MarkItemAsDone(oItem, SCRIPT_MODULE_ON_ACQUIRE_ITEM);

			itemproperty ip = GetFirstItemProperty(oItem);
			while (GetIsItemPropertyValid(ip))
			{
				if (GetItemPropertyType(ip) == ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP)
				{
					RemoveItemProperty(oItem, ip);
					AddItemProperty(DURATION_TYPE_PERMANENT, ItemPropertyACBonusVsRace(IP_CONST_RACIALTYPE_UNDEAD, 3), oItem);

					break;
				}
				ip = GetNextItemProperty(oItem);
			}
		}
	}
}
