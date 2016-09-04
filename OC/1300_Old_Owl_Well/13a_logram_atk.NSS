//13a_logram_atk
/*
    Logram and men go hostile.
*/
// JYL 2/11/05
// JYL 09/13/05 Changed to a switch statement as Logram's scene got more complex.
// ChazM 6/26/06 - Fixed some Yaisog Tag problems.
// kevL 160904 - let Logram and Yaisog equip their armor and weapons.

#include "13_inc_npc"
#include "ginc_item" // kL

void main(int nDialogNode)
{
	object oOrc1 = GetObjectByTag("13_logramarcher1");
	object oOrc2 = GetObjectByTag("13_logramarcher2");
	object oOrc3 = GetObjectByTag("13_logramarcher3");
	object oOrc4 = GetObjectByTag("13_logramarcher4");

	object oLogram = GetObjectByTag("13_logram");
	object oCas = GetObjectByTag("casavir");
	location lCas = GetLocation(GetWaypointByTag("13_cas_log_jump"));
	object oYaisog;
	string sYaisogTag = "13_yaisog"; // this is what is referenced in the conversation (13_logram)

	switch (nDialogNode)
	{
		case 10: // Spawn Yaisog if we need him
		{
			// Feat fixes begin - Logram
			FeatAdd(oLogram, FEAT_WEAPON_PROFICIENCY_MARTIAL, FALSE);
			FeatAdd(oLogram, FEAT_ARMOR_PROFICIENCY_MEDIUM, FALSE);
			IdentifyInventory(oLogram);
			IdentifyEquippedItems(oLogram);
			object oWarHammer = GetItemPossessedBy(oLogram, "NW_WDBMMA004");
			object oChainmail = GetItemPossessedBy(oLogram, "NW_MAARCL066");
			object oHelm = GetItemPossessedBy(oLogram, "NW_ARMHE006");
			AssignCommand(oLogram, ActionEquipItem(oWarHammer, INVENTORY_SLOT_RIGHTHAND));
			AssignCommand(oLogram, ActionEquipItem(oChainmail, INVENTORY_SLOT_CHEST));
			AssignCommand(oLogram, ActionEquipItem(oHelm, INVENTORY_SLOT_HEAD));
			// Feat fixes end.

			if (GetGlobalInt("13_UrgatEnd") == 1)
			{
				location lYaisog = GetLocation(GetWaypointByTag("13_wp_yaisog_sp"));
				oYaisog = CreateObject(OBJECT_TYPE_CREATURE, "yaisog", lYaisog, FALSE, sYaisogTag);

				// Feat fixes begin - Yaisog
				IdentifyInventory(oYaisog);
				IdentifyEquippedItems(oYaisog);
				object oGreatAxe = GetItemPossessedBy(oYaisog, "NW_WAXMGR008");
				object oChainmail2 = GetItemPossessedBy(oYaisog, "NW_MAARCL035");
				object oBelt = GetItemPossessedBy(oYaisog, "nw_it_mbelt009");
				AssignCommand(oYaisog, ActionEquipItem(oGreatAxe, INVENTORY_SLOT_RIGHTHAND));
				AssignCommand(oYaisog, ActionEquipItem(oChainmail2, INVENTORY_SLOT_CHEST));
				AssignCommand(oYaisog, ActionEquipItem(oBelt, INVENTORY_SLOT_BELT));
				// Feat fixes end.
			}

			// Also jump Casavir into position.
			AssignCommand(oCas, ClearAllActions(TRUE));
			AssignCommand(oCas, ActionJumpToLocation(lCas));
		}
		break;
		case 20: // Yaisog moves in
		{
			oYaisog = GetObjectByTag(sYaisogTag);
			object oDoor = GetObjectByTag("13_logram_door");
			location lYaisog = GetLocation(GetWaypointByTag("13_wp_yaisog_return"));
			
			AssignCommand(oDoor, ActionOpenDoor(oDoor));
			AssignCommand(oYaisog, ClearAllActions(TRUE));
			AssignCommand(oYaisog, ActionMoveToLocation(lYaisog));
		}
		break;
		case 50: // Attack!
		{
			oYaisog = GetObjectByTag(sYaisogTag);
			GoHostileAndAttackAnything(oOrc1);
			GoHostileAndAttackAnything(oOrc2);
			GoHostileAndAttackAnything(oOrc3);
			GoHostileAndAttackAnything(oOrc4);
			GoHostileAndAttackAnything(oYaisog);
			
			GoHostileAndAttackAnything(oLogram);
		}
		break;
	}
}