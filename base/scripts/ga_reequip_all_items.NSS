// ga_reequip_all_items
/*
	re-equips all "remembered" items.
*/
// ChazM 6/27/06
#include "ginc_param_const"
#include "ginc_item"

void main(string sTarget)
{
	object oOwner = GetTarget(sTarget);
	RestoreEquippedItems(oOwner, TRUE);
}