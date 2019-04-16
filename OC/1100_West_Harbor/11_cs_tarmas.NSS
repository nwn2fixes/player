// '11_cs_tarmas'
/*
	Tarmas and the Githyanki royal rumble.
*/
// EPF 9/20/05
// DBR 2/15/06 - set speaker tag
// kevL 2019 apr 15 - tidy
// kevL 2019 apr 15 - move Tarmas to a gather-point instead of directly to the wheatfield

#include "ginc_group"
#include "11_inc_constants"
#include "nw_i0_spells"
//#include "x2_inc_switches"
//#include "ginc_misc"
//#include "ginc_debug"


// wrapper so we can stick this in an action queue
void ActionCreate(string sCreature, location lLoc)
{
	object oSpider = CreateObject(OBJECT_TYPE_CREATURE, sCreature, lLoc);
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile("sp_summon_creature_1"), lLoc, 6.f);
}

//
void CreateTempEffect(string sEffect, location lLoc)
{
	object oFX = CreateObject(OBJECT_TYPE_PLACED_EFFECT, sEffect, lLoc);
	AssignCommand(GetModule(), DelayCommand(6.f, DestroyObject(oFX)));
}

//
void TarmasDamageReactionWrapper(object oTarget)
{
	PlayCustomAnimation(oTarget, "*dodge01", FALSE);
}

//
void GithDamageReactionWrapper(object oTarget)
{
	PlayCustomAnimation(oTarget, "*dodge01", FALSE);
}


//
void main(int nScene)
{
	object oGith   = GetTarget("11_tarmas_gith");

	object oTarmas = GetTarget("npc_tarmas");
	object oBevil  = GetTarget("npc_bevil");
	object oAmie   = GetTarget("0_amie");

	object oSpider1, oSpider2, oSpider3, oWP, oTarg;

	object oPig = GetObjectByTag("11_faction_pig");

	string sName;
	int i;

	location lSummon1 = GetLocation(GetTarget("11_wp_summon1"));
	location lSummon2 = GetLocation(GetTarget("11_wp_summon2"));
	location lSummon3 = GetLocation(GetTarget("11_wp_summon3"));

	vector vGith   = GetPosition(oGith);
	vector vTarmas = GetPosition(oTarmas);
	vector vAmie   = GetPosition(oAmie);
	vector vPC     = GetPosition(GetPCSpeaker());

	switch (nScene)
	{
		case 1: // Tarmas casts spell
			ActionPauseCutscene(5000);
			AssignCommand(oGith, ClearAllActions(TRUE));
			IgnoreTargetRulesEnqueueTarget(oGith, oTarmas);
			AssignCutsceneActionToObject(oGith, ActionCastSpellAtObject(SPELL_MAGIC_MISSILE, oTarmas, METAMAGIC_ANY, TRUE));
			AssignCutsceneActionToObject(oGith, ActionDoCommand(AssignCommand(oTarmas, TarmasDamageReactionWrapper(oTarmas))));
			AssignCutsceneActionToObject(oGith, ActionWait(1.f));

			SetCreatureOverrideAIScript(oGith,   "");
			SetCreatureOverrideAIScript(oTarmas, "");
			SetLocalInt(oGith,   "bInCutscene", 1);
			SetLocalInt(oTarmas, "bInCutscene", 1);

			// the lizard shaman is an npc who's guaranteed to be alive and neutral at this stage of the game
			//AssignCutsceneActionToObject(oTarmas, ActionDoCommand(ChangeFaction(oGith, GetObjectByTag("m_lizard_shaman"))));
			//AssignCutsceneActionToObject(oTarmas, ActionDoCommand(AssignCommand(oGith, SurrenderToEnemies())));
			//AssignCutsceneActionToObject(oTarmas, ActionDoCommand(AssignCommand(oGith, ClearAllActions(TRUE))));
			//AssignCommand(oTarmas, PlayAnimation(ANIMATION_LOOPING_INJURED, 1.f, 8.f));
			//AssignCutsceneActionToObject(oTarmas, ActionDoCommand(SetIsTemporaryNeutral(oTarmas, oGith)));
			//AssignCutsceneActionToObject(oTarmas, ActionDoCommand(SetIsTemporaryNeutral(oGith, oTarmas)));
			//AssignCutsceneActionToObject(oTarmas, ActionWait(0.5f));
			break;

		case 2: // Githyanki summons spiders
			ActionPauseCutscene(6000);
			ChangeFaction(oGith, oPig);
			AssignCommand(oGith, SetFacingPoint(vTarmas, FALSE));
			AssignCommand(oTarmas, SetFacingPoint(vGith, TRUE));
			AssignCutsceneActionToObject(oGith, ActionCastFakeSpellAtLocation(SPELL_SUMMON_CREATURE_I, lSummon1));
			//AssignCutsceneActionToObject(oGith, ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2), lSummon2)));
			//AssignCutsceneActionToObject(oGith, ActionDoCommand(ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_MONSTER_2), lSummon3)));
			AssignCutsceneActionToObject(oGith, ActionDoCommand(ActionCreate("11_tarm_spid", lSummon1)));
			AssignCutsceneActionToObject(oGith, ActionDoCommand(ActionCreate("11_tarm_spid", lSummon2)));
			AssignCutsceneActionToObject(oGith, ActionDoCommand(ActionCreate("11_tarm_spid", lSummon3)));
			break;

		case 3: // spiders move forward, Githyanki runs off. Also, re-hostilize previously neutralized bladelings
			PrettyMessage("We should be paused for about 4 seconds here.");

			ActionPauseCutscene(4000);
			oSpider1 = GetObjectByTag("11_tarm_spid", 0);
			oSpider2 = GetObjectByTag("11_tarm_spid", 1);
			oSpider3 = GetObjectByTag("11_tarm_spid", 2);

			GroupAddMember(GITH_SPIDERS, oSpider1);
			GroupAddMember(GITH_SPIDERS, oSpider2);
			GroupAddMember(GITH_SPIDERS, oSpider3);

			GroupOnDeathBeginConversation(GITH_SPIDERS, "npc_tarmas", "11_tarmas");

			//AssignCommand(oSpider1, ActionMoveToObject(oTarmas,TRUE));
			//AssignCommand(oSpider2, ActionMoveToObject(GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oSpider2), TRUE));
			//AssignCommand(oSpider3, ActionMoveToObject(GetTarget("npc_bevil"), TRUE));
			AssignCutsceneActionToObject(oTarmas, ActionWait(4.f));
			SetLocalInt(oTarmas, "bInCutscene", 0);
			oWP = GetTarget("11_wp_gith_exit");
			AssignCommand(oGith, ClearAllActions(TRUE));
			AssignCutsceneActionToObject(oGith, ActionForceMoveToObject(oWP, TRUE, 4.f));
			AssignCutsceneActionToObject(oGith, ActionDoCommand(DestroyObject(oGith)));

			// re-hostilize
/*			i = 0; // The Merring cutscene duegar
			oTarg = GetObjectByTag("11_dgnome1", i);
			while (GetIsObjectValid(oTarg))
			{
				AssignCommand(oTarg, ClearAllActions(TRUE));
				ChangeToStandardFaction(oTarg, STANDARD_FACTION_HOSTILE);
				i++;
				oTarg = GetObjectByTag("11_dgnome1", i);
			}
			i = 0; // The spawned duegar
			oTarg = GetObjectByTag("11_dgnome", i);
			while (GetIsObjectValid(oTarg))
			{
				AssignCommand(oTarg, ClearAllActions(TRUE));
				ChangeToStandardFaction(oTarg, STANDARD_FACTION_HOSTILE);
				i++;
				oTarg = GetObjectByTag("11_dgnome", i);
			}
			i = 0; // The fight1 guys
			oTarg = GetObjectByTag("fight1", i);
			while (GetIsObjectValid(oTarg))
			{
				sName = GetStringLeft(GetName(oTarg), 4);
				if (sName == "Gray" || sName == "Blad")
				{
					AssignCommand(oTarg, ClearAllActions(TRUE));
					ChangeToStandardFaction(oTarg, STANDARD_FACTION_HOSTILE);
				}
				i++;
				oTarg = GetObjectByTag("fight1", i);
			}
			i = 0; // The fight2 guys
			oTarg = GetObjectByTag("fight1", i);
			while (GetIsObjectValid(oTarg))
			{
				sName = GetStringLeft(GetName(oTarg), 4);
				if (sName == "Gray" || sName=="Blad")
				{
					AssignCommand(oTarg, ClearAllActions(TRUE));
					ChangeToStandardFaction(oTarg, STANDARD_FACTION_HOSTILE);
				}
				i++;
				oTarg=GetObjectByTag("fight2", i);
			} */
			break;

		case 4: // spiders attack
			//ChangeToStandardFaction(oTarmas, STANDARD_FACTION_DEFENDER);
			//ActionPauseCutscene(4000);
			//AssignCutsceneActionToObject(oTarmas, ActionWait(4.f));
			SetLocalInt(oTarmas, "bInCutscene", 0);
			break;

		case 5: // tarmas goes to the farm // kL_change: to the gather-point
		{
			// he goes neutral so as not to get distracted
			SetLocalInt(oTarmas, "bInCutscene", FALSE);
			SetLocalInt(oTarmas, "bSpidersDead", TRUE);

//			SetEventHandler(oTarmas, CREATURE_SCRIPT_ON_HEARTBEAT, "11_b_tarmas_hb"); // kL_changed: no.

			ForceRest(oTarmas); // give him his spells back

			//AssignCommand(oTarmas, SurrenderToEnemies()); // in case he's battling anyone unexpected.
			//ChangeFaction(oTarmas, GetTarget("m_lizard_shaman"));

			ChangeToStandardFaction(oTarmas, STANDARD_FACTION_DEFENDER);

			SetCreatureOverrideAIScript(oTarmas, "");

			AssignCommand(oTarmas, ClearAllActions(TRUE));
			AssignCommand(oTarmas, ActionForceMoveToObject(GetObjectByTag("11_wp_gith_exit"), TRUE));	// kL_change: move Tarmas to a gather-point instead of directly to the
																										// wheatfield; he will move to the wheatfield when the rest of the militia
																										// moves there in '11_a_georg_lv'.
//			AssignCommand(oTarmas, ActionForceMoveToObject(GetTarget("11_wp_tarmas_farm"), TRUE));		// kL_change: timeout was 15.f but he didn't quite make it.
//			AssignCommand(oTarmas, ActionJumpToObject(GetTarget("11_wp_tarmas_farm")));					// kL_change: that's pointless when using ForceMove
			AssignCommand(oTarmas, ActionDoCommand(SetCommandable(TRUE)));
			AssignCommand(oTarmas, SetCommandable(FALSE));
			break;
		}

		case 6: // Amie sees master in trouble
			break;

		case 7: // Tarmas doesn't want them to interfere
			//RemoveRosterMember("0_amie");
			//PrettyDebug("oAMie = " + GetTag(oAmie));
			//SetLocalInt(oAmie,"Focused",TRUE);
			SetImmortal(oAmie, FALSE);
			AssignCommand(oAmie, ClearAllActions(TRUE));
			AssignCommand(oAmie, ActionJumpToObject(GetObjectByTag("11_wp_amie_warp_atk")));
			AssignCommand(oTarmas, ClearAllActions(TRUE));
			AssignCommand(oTarmas, SetFacingPoint(vPC));
			SetCreatureOverrideAIScript(oGith,   "");
			SetCreatureOverrideAIScript(oTarmas, "");
			SetLocalInt(oGith,   "bInCutscene", 1);
			SetLocalInt(oTarmas, "bInCutscene", 1);
			break;

		case 8: // Amie casts a spell at Mr.Githy
			ChangeFaction(oAmie, oTarmas);
			ActionPauseCutscene(10000);
			AssignCommand(oGith, ClearAllActions(TRUE));
			AssignCommand(oGith, SetFacingPoint(vAmie, TRUE));
			AssignCommand(oAmie, ClearAllActions(TRUE));
			IgnoreTargetRulesEnqueueTarget(oAmie, oGith);
			AssignCutsceneActionToObject(oAmie, ActionForceMoveToObject(GetObjectByTag("11_wp_amie_atk"), TRUE, 0.2f, 6.f));
			//AssignCommand(oTarmas, SetFacingPoint(GetPosition(oAmie, TRUE)); // done in COnvo now
			AssignCutsceneActionToObject(oAmie, ActionCastSpellAtObject(SPELL_MAGIC_MISSILE, oGith, METAMAGIC_NONE, TRUE));
			AssignCutsceneActionToObject(oAmie, ActionDoCommand(AssignCommand(oGith, GithDamageReactionWrapper(oGith))));
			break;

		case 9: // Mr.Githy retaliates. Or squishes a bug.
			SetImmortal(oAmie, FALSE);
			SetPlotFlag(oAmie, FALSE);
			ActionPauseCutscene(7000);
			AssignCommand(oAmie, ClearAllActions(TRUE));
			IgnoreTargetRulesEnqueueTarget(oGith, oAmie);
			AssignCutsceneActionToObject(oGith, ClearAllActions(TRUE));
			AssignCutsceneActionToObject(oGith, ActionCastSpellAtObject(SPELL_FLAME_ARROW, oAmie, METAMAGIC_NONE, TRUE));
			//AssignCutsceneActionToObject(oGith, ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(TRUE, TRUE), oAmie)));
			AssignCutsceneActionToObject(oGith, ActionWait(0.2f));
			break;

		case 10: // Amie perishes
			//AssignCommand(oAmie,PlayAnimation(ANIMATION_LOOPING_SPASM,1.0,3.0f));
			if (GetCurrentHitPoints(oAmie) > 0)
				AssignCommand(oAmie, ActionDoCommand(ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(TRUE, TRUE), oAmie)));
			break;

		case 11: // Spiders attack
			oSpider1 = GetObjectByTag("11_tarm_spid", 0);
			oSpider2 = GetObjectByTag("11_tarm_spid", 1);
			oSpider3 = GetObjectByTag("11_tarm_spid", 2);

			AssignCommand(oSpider1, ActionMoveToObject(oTarmas, TRUE));
			AssignCommand(oSpider2, ActionMoveToObject(oTarmas, TRUE));
			AssignCommand(oSpider3, ActionMoveToObject(GetTarget("npc_bevil"), TRUE));
			SetIsRosterMemberCampaignNPC("npc_amie", TRUE);
			AssignCommand(oSpider1, ActionAttack(oTarmas));
			AssignCommand(oSpider2, ActionAttack(oTarmas));

			if (GetDistanceBetween(oSpider3, oBevil) < 25.f)
			{
				AssignCommand(oSpider3, ActionAttack(oBevil));
			}
			else
			{
				AssignCommand(oSpider3, ActionAttack(oTarmas));
			}

			AssignCommand(oTarmas, ClearAllActions(TRUE));
			//AssignCutsceneActionToObject(oTarmas, ActionWait(4.f));
			AssignCommand(oTarmas, DetermineCombatRound());
			break;

		// since re-order, new nodes:
		case 20: // Remove effect from Tarmas
			//effect eShield = EffectVisualEffect(VFX_DUR_SPELL_MAGE_ARMOR);
			//RemoveEffect(oTarmas, eShield);
			ForceRest(oTarmas);
			break;

		case 100: // Stop your ambient fight and start our scripted stuff
			SetCreatureOverrideAIScript(oGith,   "");
			SetCreatureOverrideAIScript(oTarmas, "");
			SetEventHandler(oGith,   CREATURE_SCRIPT_ON_HEARTBEAT, "");
			SetEventHandler(oTarmas, CREATURE_SCRIPT_ON_HEARTBEAT, "");
			SetLocalInt(oGith,   "bInCutscene", 1);
			SetLocalInt(oTarmas, "bInCutscene", 1);
			AssignCommand(oGith,   ClearAllActions(TRUE));
			AssignCommand(oTarmas, ClearAllActions(TRUE));
			ChangeFaction(oGith, oTarmas);
			AssignCommand(oAmie, SetAssociateState(NW_ASC_MODE_DEFEND_MASTER, FALSE));
			AssignCommand(oAmie, SetAssociateState(NW_ASC_MODE_STAND_GROUND, TRUE));
			AssignCommand(oAmie, ActionDoCommand(SetIsDestroyable(FALSE, FALSE, FALSE)));
			SetLocalString(oAmie, "DeathScript", "fakescript");
			RemoveRosterMemberFromParty("0_amie", GetPCSpeaker(), FALSE);
			RemoveRosterMember("0_amie");

			oAmie = GetTarget("0_amie");
			for (i = 0; i <= 12; i++)
				SetEventHandler(oAmie, i, "");

			AssignCommand(oAmie, ClearAllActions(TRUE));
			ForceRest(oAmie);   // Added by JYL 03/09/06
			//ForceRest(oGith); // Added by JYL 03/09/06
			//ActionPauseCutscene(10000);
			//AssignCommand(oTarmas, ClearAllActions(TRUE));
			//AssignCommand(oTarmas, PlayAnimation(ANIMATION_LOOPING_PAUSE_TIRED, 1.f, 5.f));

			// this variable will disable their cast at scripts.
			SetImmortal(oAmie, TRUE);
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(GetCurrentHitPoints(oAmie) - 1), oAmie);
			break;
	}
}
