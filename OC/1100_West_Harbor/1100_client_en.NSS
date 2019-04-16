// '1100_client_en'
/*
	OnClientEnter script for West Harbor.
*/
// kevL 2019 apr 14 - destroy pre-placed Tarmas and spawn Tarmas w/ spells
// kevL 2019 apr 15 - tidy + refactor a bit

#include "ginc_cutscene"
#include "ginc_param_const"
#include "11_inc_constants"
//#include "11_inc_effects"
//#include "ginc_cutscene"
//#include "ginc_group"
//#include "ginc_misc"
//#include "nw_i0_generic"
//#include "x0_i0_petrify"

void DouseFires();
void VillageCleanup();

//
int StartingConditional()
{
	// kL_begin: spawn a version of Tarmas that has spells from a resref
	if (!GetLocalInt(OBJECT_SELF, "kL_bTarmasDone"))
	{
		SetLocalInt(OBJECT_SELF, "kL_bTarmasDone", TRUE);

		object oTarmas = GetObjectByTag("npc_tarmas");
		if (GetIsObjectValid(oTarmas)) // safety.
		{
			location lTarmas = GetLocation(oTarmas);
			DestroyObject(oTarmas);
			CreateObject(OBJECT_TYPE_CREATURE, "tarmasbattle", lTarmas);
		}
	}
	// kL_end


//	object oMerring = GetObjectByTag("npc_merring");

	// TDE 11/08/06 - Make sure Orlen is gone if the player has recruited him
	if (GetGlobalInt("01_Join_Orlen") > 0)
	{
		object oOrlen = GetObjectByTag("npc_orlen");
		if (GetIsObjectValid(oOrlen))
			DestroyObject(oOrlen);
	}

	// TDE 11/08/06 - Make sure Bevil is gone if the player has recruited him
	object oBevil = GetObjectByTag("npc_bevil");
	if (GetIsObjectValid(oBevil) && GetGlobalInt("01_Join_Bevil") > 0)
	{
		DestroyObject(oBevil);
	}

	// DBR 11/08/06 - If You have Crossroad keep, make sure Bevil is there.
	if (!GetIsObjectValid(oBevil)
		&& GetGlobalInt("b2000HasKeep") == 1
		&& GetGlobalInt("01_Join_Bevil") == 0)
	{
		CreateObject(OBJECT_TYPE_CREATURE, "npc_bevil", GetLocation(GetObjectByTag("sp_in_bevil")));
	}

	// JYL 09/15/06 Clean up West Harbor after PC reaches Highcliff
	if (GetGlobalInt("12_entered_highcliff") == 1)
	{
		VillageCleanup();
	}

	// JYL 07/20/06 Moved this code up so the script don't return out until
	// the XP check is completed.
	int d; // bring all PCs up to 3000 xp if lower

	object oPC = GetFirstEnteringPC();
	object oPlayerPC = GetFirstFactionMember(oPC);
	while (GetIsObjectValid(oPlayerPC))
	{
		if ((d = 3000 - GetXP(oPlayerPC)) > 0)
			GiveXPToCreature(oPlayerPC, d);

		oPlayerPC = GetNextFactionMember(oPC);
	}


	SetPlotFlag(oPC, FALSE);
	SetImmortal(oPC, FALSE);

	if (GetIsObjectValid(oBevil))
	{
		SetPlotFlag(oBevil, FALSE);
		SetImmortal(oBevil, FALSE);
	}

	object oAmie = GetObjectByTag("0_amie");
	if (GetIsObjectValid(oAmie))
	{
		SetPlotFlag(oAmie, FALSE);

		if (!GetIsDead(oAmie))
			SetImmortal(oAmie, TRUE);
	}


	object oWard = GetObjectByTag("11_wounded2");
	if (GetLocalInt(oWard, "Wounded") == 1)
	{
		PlayCustomAnimation(oWard, "idleinj", TRUE);
	}

	object oWyl = GetObjectByTag("11_wounded1");
	if (GetLocalInt(oWyl, "Wounded") == 1)
	{
		PlayCustomAnimation(oWyl, "idleinj", TRUE);
	}

	object oPit = GetObjectByTag("11_wounded3");
	if (GetLocalInt(oPit, "Wounded") == 1)
	{
		PlayCustomAnimation(oPit, "idleinj", TRUE);
	}

	object oDDwarf = GetObjectByTag("11_die_dwarf");
	if (GetLocalInt(GetModule(), "11_play_ddwarf") < 1)
	{
		PlayCustomAnimation(oDDwarf, "idleinj", TRUE);
	}

	int i = 0;
	object oHurtGuy = GetObjectByTag("11dying", i);
	while (GetIsObjectValid(oHurtGuy))
	{
		switch (i)
		{
			case 0:
				PlayCustomAnimation(oHurtGuy, "wounded", TRUE, 0.75f);
				break;

			case 1:
				PlayCustomAnimation(oHurtGuy, "wounded", TRUE);
				break;

			case 2:
				PlayCustomAnimation(oHurtGuy, "wounded", TRUE, 1.3f);
				break;
		}
		oHurtGuy = GetObjectByTag("11dying", ++i);
	}

	// We no longer need this as Ben's cutscene struct automatically
	// handles fading in from black.
/*	int bBlack = GetLocalInt(OBJECT_SELF, "bBlack");
	int bDone  = GetLocalInt(OBJECT_SELF, "bDone");

	if (GetGlobalInt("11_west_harbor_plot") == 20)
	{
		if (bBlack < 1)
		{
			SetLocalInt(OBJECT_SELF, "bBlack", 1);
			return TRUE;
		}
	} */


	// Do not execute if OnClientEnter was not fired from a group area transition
	if (FiredFromPartyTransition() == FALSE)
		return FALSE;

	// Get party leader, force control of owned PC
	object oLeader = GetFactionLeader(oPC);
	oPC = SetOwnersControlledCompanion(oLeader);

	// Initialize temp CutsceneInfo
	struct CutsceneInfo stCI;
	stCI = ResetCutsceneInfo(stCI);
	int bCutsceneCondition;
	string sSpeakerTag;
	string sDialogName;

	// *** START CLIENT ENTER CUTSCENES ***

	// Cutscene: 1. Merring tells of Georg
	if (GetIsCutscenePending(stCI) == FALSE)
	{
		bCutsceneCondition = (GetLocalInt(OBJECT_SELF, "bDone") == FALSE);	// 2. Replace (FALSE) with condition to play
		sSpeakerTag = "npc_merring";										// 3. Specify Speaker and Dialog
		sDialogName = "1100_cs_enter";

		stCI = SetupCutsceneInfo(stCI, sSpeakerTag, oPC, sDialogName, bCutsceneCondition);

		if (GetIsCutscenePending(stCI) == TRUE)
		{
			SetLocalInt(OBJECT_SELF, "bDone",TRUE);

			// 4. Additional cutscene setup
			// Set the Bridge Duergar to always miss.
			// Set Militiamen to always miss.
//			SetPlotFlag(GetObjectByTag("npc_georg_red"), FALSE);
			SetPlotFlag(GetObjectByTag("11_georg_guard1"), FALSE);
			SetPlotFlag(GetObjectByTag("11_georg_guard2"), FALSE);

			SetCombatOverrides(GetObjectByTag("npc_georg_red"),   OBJECT_INVALID, -1, -1, OVERRIDE_ATTACK_RESULT_DEFAULT, 0, 0, TRUE, TRUE, FALSE, TRUE);
			SetCombatOverrides(GetObjectByTag("11_georg_guard1"), OBJECT_INVALID, -1, -1, OVERRIDE_ATTACK_RESULT_DEFAULT, 0, 0, TRUE, TRUE, FALSE, TRUE);
			SetCombatOverrides(GetObjectByTag("11_georg_guard2"), OBJECT_INVALID, -1, -1, OVERRIDE_ATTACK_RESULT_DEFAULT, 0, 0, TRUE, TRUE, FALSE, TRUE);

			object oTarmas = GetObjectByTag("npc_tarmas");
			effect eShield = EffectVisualEffect(VFX_DUR_SPELL_SHIELD);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, eShield, oTarmas);
			ApplyEffectToObject(DURATION_TYPE_PERMANENT, eShield, GetObjectByTag("11_tarmas_gith"));


			int i;
			for (i = 1; i <= 7; i++)
			{
				SetPlotFlag(GetObjectByTag("11_bridge_dwarf" + IntToString(i)), FALSE);
				SetCombatOverrides(GetObjectByTag("11_bridge_dwarf" + IntToString(i)),
								   OBJECT_INVALID,
								   -1, -1,
								   OVERRIDE_ATTACK_RESULT_MISS,
								   -1, -1,
								   TRUE, TRUE, FALSE, TRUE);
			}
		}
	}

	// Cutscene: 1. Daeghun welcomes PC back
	if (GetIsCutscenePending(stCI) == FALSE)
	{
		bCutsceneCondition = (GetLocalInt(GetModule(), "Second_Enter") == FALSE	// 2. Replace (FALSE) with condition to play
						  && GetGlobalInt("11_west_harbor_plot") == 20);
		sSpeakerTag = "npc_daeghun";											// 3. Specify Speaker and Dialog
		sDialogName = "11_daeghun";

		stCI = SetupCutsceneInfo(stCI, sSpeakerTag, oPC, sDialogName, bCutsceneCondition);

		if (GetIsCutscenePending(stCI) == TRUE)
		{
			// Second Enter is for when the PC comes back from the Ruins
//			if (GetLocalInt(GetModule(), "Second_Enter") == FALSE && GetGlobalInt("11_west_harbor_plot") == 20)
//			{
				// clean up fires
				DouseFires();

				// spawn in our wandering villagers
				location lWP = GetLocation(GetWaypointByTag("wp_ambient_spawn"));

				int nRand;
				int i;
				for (i = 1; i <= NUM_AMBIENT_VILLAGERS; i++)
				{
//					nRand = 4;			// kL_note: clever (not)
					nRand = Random(5);	// kL_fix
					if (nRand == 0)
						CreateObject(OBJECT_TYPE_CREATURE, "g_vill_wander", lWP);
					else
						CreateObject(OBJECT_TYPE_CREATURE, "g_vill_wander" + IntToString(nRand), lWP);
				}

				// Spawn in new peeps (like Retta)
//				lWP = GetLocation(GetWaypointByTag("second_retta"));
//				CreateObject(OBJECT_TYPE_CREATURE, "npc_retta", lWP);

				// Destroy Militiamen from wheatfield
				object oMilitia;
				for (i = 1; i <= 6; i++)
				{
					oMilitia = GetObjectByTag("11_militia" + IntToString(i));
					SetPlotFlag(oMilitia, FALSE);
					DestroyObject(oMilitia, 0.1f);
				}

				// Spawn in or teleport Bevil for talking
				object oTarg = GetObjectByTag("npc_bevil");
				object oWP   = GetObjectByTag("second_bev");
				if (!GetIsObjectValid(oTarg))
				{
					PrintString("Bevil not found");
					lWP = GetLocation(oWP);
					oTarg = CreateObject(OBJECT_TYPE_CREATURE, "npc_bevil", lWP);
				}
				else
				{
					AssignCommand(oTarg, ClearAllActions());
					AssignCommand(oTarg, ActionJumpToObject(oWP));
				}

				// Spawn in or teleport Daeghun for talking
				oTarg = GetObjectByTag("npc_daeghun");
				oWP   = GetObjectByTag("second_daeghun");
				if (!GetIsObjectValid(oTarg))
				{
					PrintString("Daeghun not found");
					lWP = GetLocation(oWP);
					oTarg = CreateObject(OBJECT_TYPE_CREATURE, "npc_daeghun", lWP);
				}
				else
				{
					AssignCommand(oTarg, ClearAllActions());
					AssignCommand(oTarg, ActionJumpToObject(oWP));
				}

//				object oWP2 = GetObjectByTag("second_daeghun2");
//				AssignCommand(oTarg, ActionMoveToObject(oWP2));

				SetLocalInt(GetTarget("npc_bevil"), "bWarpEnabled", FALSE); // conditionals for his dialogue.

				RemoveEffectOfType(oPC, EFFECT_TYPE_AC_INCREASE);
				RemoveEffectOfType(oPC, EFFECT_TYPE_ATTACK_INCREASE);
				RemoveEffectOfType(oPC, EFFECT_TYPE_ABILITY_INCREASE);
//			}
			SetLocalInt(GetModule(), "Second_Enter", TRUE);
		}
	}
	// *** END CLIENT ENTER CUTSCENES ***

	// Cue cutscene or revert control to original character
	if (GetIsCutscenePending(stCI) == TRUE)
	{
		FireAndForgetConversation(stCI.oSpeaker, oPC, stCI.sDialog);
	}
	else
	{
		SetOwnersControlledCompanion(oPC, oLeader);
	}

	// If cutscene is pending, fade to black
	return GetIsCutscenePending(stCI);
}


//
void DouseFires()
{
	int i = 0;
	object oFX = GetObjectByTag("11_fire", i);
	while (GetIsObjectValid(oFX))
	{
		DestroyObject(oFX, 0.1f);
		oFX = GetObjectByTag("11_fire", ++i);
	}

	// kL_note: Why is 'i' not reset for this ->
	oFX = GetObjectByTag("11_smoke", i);
	while (GetIsObjectValid(oFX))
	{
		DestroyObject(oFX, 0.1f);
		oFX = GetObjectByTag("11_smoke", ++i);
	}
}

//
void VillageCleanup()
{
	if (GetGlobalInt("11_return_cleanup_done") != 1)
	{
		SetGlobalInt("11_return_cleanup_done", 1);


		object oDwarf = GetObjectByTag("11_die_dwarf");
		AssignCommand(oDwarf, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oDwarf, FALSE);
		DestroyObject(oDwarf, 0.1f);

		object oBladeling = GetObjectByTag("m_bladeling_dead");
		AssignCommand(oBladeling, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oBladeling, FALSE);
		DestroyObject(oBladeling, 0.1f);

		object oLewy = GetObjectByTag("11_lewy");
		AssignCommand(oLewy, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oLewy, FALSE);
		DestroyObject(oLewy, 0.1f);

		object oLewyPig = GetObjectByTag("11_lewy_pig");
		AssignCommand(oLewyPig, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oLewyPig, FALSE);
		DestroyObject(oLewyPig, 0.1f);

		object oWard = GetObjectByTag("11_wounded2");
		AssignCommand(oWard, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oWard, FALSE);
		DestroyObject(oWard, 0.1f);

		object oWyl = GetObjectByTag("11_wounded1");
		AssignCommand(oWyl, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oWyl, FALSE);
		DestroyObject(oWyl, 0.1f);

		object oPitney = GetObjectByTag("11_wounded3");
		AssignCommand(oPitney, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oPitney, FALSE);
		DestroyObject(oPitney, 0.1f);


		int i = 0;
		object oDwarfCorpse = GetObjectByTag("m_dgnome_dead", i);
		while (GetIsObjectValid(oDwarfCorpse))
		{
			AssignCommand(oDwarfCorpse, SetIsDestroyable(TRUE, FALSE, FALSE));
			SetPlotFlag(oDwarfCorpse, FALSE);

			DestroyObject(oDwarfCorpse, 0.1f);

			oDwarfCorpse = GetObjectByTag("m_dgnome_dead", ++i);
		}

		i = 0;
		object oWounded = GetObjectByTag("11dying", i);
		while (GetIsObjectValid(oWounded))
		{
			AssignCommand(oWounded, SetIsDestroyable(TRUE, FALSE, FALSE));
			SetPlotFlag(oWounded, FALSE);

			DestroyObject(oWounded, 0.1f);

			oWounded = GetObjectByTag("11dying", ++i);
		}

		i = 0;
		object oCasualty = GetObjectByTag("11_casualty_male", i);
		while (GetIsObjectValid(oCasualty))
		{
			AssignCommand(oCasualty, SetIsDestroyable(TRUE, FALSE, FALSE));
			SetPlotFlag(oCasualty, FALSE);

			DestroyObject(oCasualty, 0.1f);

			oCasualty = GetObjectByTag("11_casualty_male", ++i);
		}

		oCasualty = GetObjectByTag("11_casualty_female");
		AssignCommand(oCasualty, SetIsDestroyable(TRUE, FALSE, FALSE));
		SetPlotFlag(oCasualty, FALSE);
		DestroyObject(oCasualty, 0.1f);
	}
}
