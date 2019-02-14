// i_smithhammer_ac
/*
	when the smith hammer is used on the workbench, an item may be created!
*/
// ChazM 1/31/06
// ChazM 3/28/06 Crafting call interface change
// ChazM 4/7/06 fix - assigned DoMundaneCrafting() to workbench
// ChazM 8/8/06 added ERROR_UNRECOGNIZED_HAMMER_USAGE,  added additional tags and local var setting for identifying blacksmith bench.
// ChazM 8/16/06 moved stuff to ginc_crafting
// ChazM 6/11/07 If campaign switch enabled, smith hammer can be used to rename any item.

#include "ginc_crafting"
#include "x2_inc_switches"

void main()
{
	PrettyDebug("i_smithhammer_ac : started");
    // * This code runs when the Unique Power property of the item is used
    object oPC      = GetItemActivator();
    object oItem    = GetItemActivated();
    object oTarget  = GetItemActivatedTarget();
    location lTarget = GetItemActivatedTargetLocation();
    string sTargetTag  = GetTag(oItem);
	int bSmithHammerRenameItem = GetGlobalInt(CAMPAIGN_SWITCH_SMITH_HAMMER_RENAME_ITEM);
	
	PrettyDebug("oPC = " + GetName(oPC));
	PrettyDebug("oItem = " + GetName(oItem));
	PrettyDebug("oTarget = " + GetName(oTarget));
	
	if (IsSmithWorkbench(oTarget))
	{
    	AssignCommand(oTarget, DoMundaneCrafting(oPC));
	}
	else if (bSmithHammerRenameItem && (GetObjectType(oTarget) == OBJECT_TYPE_ITEM))
	{
		SetEnchantedItemName(oPC, oTarget);
	}
	else
	{
		ErrorNotify(oPC, ERROR_UNRECOGNIZED_HAMMER_USAGE);
	}		
	PrettyDebug("i_smithhammer_ac : completed");
}		