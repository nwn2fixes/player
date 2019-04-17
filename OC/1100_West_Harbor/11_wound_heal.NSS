// '11_wound_heal'
/*
	Spawn a heal effect and bring the wounded guy to full health.
*/
// JYL 03/04/06
// kevL 2019 apr 13 - do not re-assign an identical series of actions to NPCs
//                  - switch Wyl's one-liner dialog w/ Pitney's
// kevL 2019 apr 15 - tidy + refactor (don't AssignCommand to OBJECT_SELF, etc)
//                  - check the entire PC party for moss, not just the true PCs (etc)
//                  - don't make recruits wait so long before moving to destination

#include "ginc_effect"

const string sWP_FIELD_PRE = "11_wp_whrecruit";


// kL. The dialogs check if the PC has received Moss from Brother Merring (via a
// global_int "11_bHealMoss") before showing the node. So don't recheck that
// here; just decrement the stack. Note that the Moss can be but doesn't have to
// be in party inventory. Eg, Amie could have died with it so it's lying on the
// ground under her corpse. Also note that decrementing the Moss - or even
// giving it a stacksize to begin with - is utterly pointless since it's not a
// usable item ... but that was their decision. As is using a global_int instead
// of checking party inventory for the item itself.
void UseMoss()
{
	object oMoss = GetObjectByTag("11_swamp_moss");
	int iSize = GetItemStackSize(oMoss) - 1;
	if (iSize != 0)
		SetItemStackSize(oMoss, iSize);
	else
		DestroyObject(oMoss);
}


//
void main(int iDialogNode)
{
	object oSelf = OBJECT_SELF;

	switch (iDialogNode)
	{
		case 10: // We're nice people and heal the guy
		{
			UseMoss();
			ApplySEFToLocation("sp_cure_light", GetLocation(oSelf));

			effect eHeal = EffectHeal(GetMaxHitPoints(oSelf) - GetCurrentHitPoints(oSelf));
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, oSelf);

			ClearAllActions(TRUE);
			ActionWait(1.5f);


			object oNote;

			object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,
											oSelf, 1,
											CREATURE_TYPE_IS_ALIVE, CREATURE_ALIVE_TRUE);

			if (GetTag(oSelf) == "11_wounded1") // Wyl Mossfeld
			{
				oNote = GetObjectByTag("10_militia7");
				SetMapPinEnabled(oNote, FALSE);

				PlayCustomAnimation(oSelf, "%", FALSE);
				SpeakOneLinerConversation("11_wound_bark_wyl", oPC); // kL_fix (was "11_wound_bark")

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}
			else if (GetTag(oSelf) == "11_wounded2") // Ward Mossfeld
			{
				oNote = GetObjectByTag("10_militia1");
				SetMapPinEnabled(oNote, FALSE);

				PlayCustomAnimation(oSelf, "%", FALSE);
				SpeakOneLinerConversation("11_wound_bark_ward", oPC);

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}
			else if (GetTag(oSelf) == "11_wounded3") // Pitney Lannon
			{
				oNote = GetObjectByTag("10_militia5");
				SetMapPinEnabled(oNote, FALSE);

				PlayCustomAnimation(oSelf, "%", FALSE);
				SpeakOneLinerConversation("11_wound_bark", oPC); // kL_fix (was "11_wound_bark_wyl")

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}

			location lDest = GetLocation(GetWaypointByTag(sWP_FIELD_PRE + IntToString(GetGlobalInt("11_bMilitiamenNumber"))));
			ActionForceMoveToLocation(lDest, TRUE);
			ActionDoCommand(DestroyObject(oSelf));
			SetCommandable(FALSE);
			break;
		}

		case 20: // Player is evil McEvil
			SetPlotFlag(oSelf, FALSE);
			SetImmortal(oSelf, FALSE);
			PlayCustomAnimation(oSelf, "%", FALSE);
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oSelf);
			break;
	}
}
