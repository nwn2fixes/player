// ga_bb_transform_specitem
// by Brendan Bellina
// July, 2008

// This script transforms the special items:
//  the Dagger of Chaos on the Activator,
//  and the Rod of Lordly Might on the Activator.

// These transformations are triggered by conversations with the special item.

#include "ginc_misc"
//#include "ginc_debug"

void DestroyItem(string sItem, object oTarget, float fDelay=0.0f, int nDisplayFeedback=TRUE, int nInventoryOnly=FALSE);
void PrepItemForDestruction (object oTarget);

void PrepItemForDestruction(object oTarget)
{
	SetPlotFlag(oTarget,FALSE);
    SetImmortal(oTarget,FALSE);
    AssignCommand(oTarget,SetIsDestroyable(TRUE,FALSE,FALSE));
}

void DestroyItem(string sItem, object oTarget, float fDelay=0.0f, int nDisplayFeedback=TRUE, int nInventoryOnly=FALSE)
{
	if (GetIsObjectValid(oTarget))
	{
		if (GetIsObjectValid(GetItemPossessedBy(oTarget,sItem)))
		{
			// Find any instances of the item and destroy them
			
			// Destroy any in inventory
			object oItem = GetFirstItemInInventory(oTarget);
			while (GetIsObjectValid(oItem))
			{
				if (sItem == GetTag(oItem))
				{
					PrepItemForDestruction(oItem);
					DestroyObject(oItem, fDelay, nDisplayFeedback);
				}
				oItem = GetNextItemInInventory(oTarget);
			}

			if (!nInventoryOnly)
			{
				// Destroy any in equip slots
				if (GetIsObjectValid(GetItemPossessedBy(oTarget,sItem)))
				{
					int nSlot = 0;
					while ( GetIsObjectValid(GetItemPossessedBy(oTarget,sItem))
						&& nSlot <= NUM_INVENTORY_SLOTS)
					{
						object oItem = GetItemInSlot(nSlot,oTarget);
						if (GetIsObjectValid(oItem) && sItem == GetTag(oItem))
						{
							PrepItemForDestruction(oItem);
							DestroyObject(oItem, fDelay, nDisplayFeedback);
						}
						nSlot++;	
					}
				}
			}
		}
	}
}

void main( string sNewRes, string sGlobalVarName, string sGlobalVarItemTag )
{
	string sActor = GetGlobalString(sGlobalVarName);
	object oPC = GetTarget(sActor);
	if (oPC == OBJECT_INVALID)
		oPC =(GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());
	string sTarget = GetLocalString(oPC, sGlobalVarItemTag);
	DestroyItem(sTarget, oPC);
	CreateItemOnObject(sNewRes, oPC);
}