// UnEquip Script for Staff of Balpheron "n2_wmgst001"
// Removes Casting Abilities
// CGaw OEI 7/13/06

#include "ginc_misc"

void main()
{
    // * This code runs when the item is unequipped
    object oItem = GetPCItemLastUnequipped();
	DeleteLocalInt(oItem, "EQUIPPED");
	IPRemoveMatchingItemProperties(oItem, ITEM_PROPERTY_CAST_SPELL, DURATION_TYPE_PERMANENT, -1);
}