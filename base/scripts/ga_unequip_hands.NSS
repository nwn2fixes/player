// ga_unequip_hands
/*
	unequip hands, and mark items so they can be restored
*/
// ChazM 6/27/06
// EPF 8/29/06 - uneqip offhand before main hand, else the offhand weapon is switched to the main
// hand by the engine.

#include "ginc_param_const"
#include "ginc_item"

void main(string sOwner)
{
	object oOwner =  GetTarget(sOwner);
	
	RememberEquippedItem(oOwner, INVENTORY_SLOT_LEFTHAND);
	UnequipSlot(oOwner, INVENTORY_SLOT_LEFTHAND);
	
	RememberEquippedItem(oOwner, INVENTORY_SLOT_RIGHTHAND);
	UnequipSlot(oOwner, INVENTORY_SLOT_RIGHTHAND);
}	