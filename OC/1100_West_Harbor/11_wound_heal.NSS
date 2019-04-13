// 11_wound_heal
/*
	Spawn a heal effect and bring the wounded guy to full health.
*/
// JYL 03/04/06
// kevL 2019 apr 13 - do not re-assign an identical series of actions to NPCs
//                  - switch Wyl's one-liner dialog w/ Pitney's

#include "ginc_effect"

int JohnsCheckPartyForItem(object oMember, string sItem) // nw_i0_tool hates me, so I'm just going to steal the function I need.
{
    object oPartyMember = GetFirstFactionMember(oMember, TRUE);
    while (GetIsObjectValid(oPartyMember) == TRUE)
    {
        if(HasItem(oPartyMember, sItem))
            return TRUE;
        oPartyMember = GetNextFactionMember(oMember, TRUE);
    }

    return FALSE;
}

void main(int nDialogNode)
{
	object oGuy = OBJECT_SELF;
	object oNote;

	location lSpellEffect = GetLocation(OBJECT_SELF);
	location lJump;

	string sJump = "11_wp_whrecruit";

	int nWPNum = GetGlobalInt("11_bMilitiamenNumber");
	int nMaxHealth = GetMaxHitPoints(OBJECT_SELF);
	int nCurrentHealth = GetCurrentHitPoints(OBJECT_SELF);
	int nHealAmount = nMaxHealth - nCurrentHealth;

	effect eHeal = EffectHeal(nHealAmount);

	switch (nDialogNode)
	{
		case 10: // We're nice people and heal the guy
		{
			lJump = GetLocation(GetWaypointByTag(sJump + IntToString(nWPNum)));

			if (JohnsCheckPartyForItem(GetFirstPC(), "11_swamp_moss"))
			{
				object oMoss = GetObjectByTag("11_swamp_moss");
				int nOriginal = GetItemStackSize(oMoss);
				int nNew = nOriginal - 1;

				SetItemStackSize(oMoss, nNew);

				if (nNew < 1)
				{
					DestroyObject(oMoss, 0.1);
				}
			}

			PlaySound("sim_heal02");
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, OBJECT_SELF);
			ApplySEFToLocation("sp_cure_light.sef", lSpellEffect);

			AssignCommand(oGuy, ClearAllActions(TRUE));
			AssignCommand(oGuy, ActionWait(2.0));

			if (GetTag(oGuy) == "11_wounded1") // Wyl Mossfeld
			{
				oNote = GetObjectByTag("10_militia7");
				PlayCustomAnimation(oGuy, "%", FALSE);
				SetMapPinEnabled(oNote, 0);
				AssignCommand(oGuy, SpeakOneLinerConversation("11_wound_bark_wyl", GetNearestPC())); // kL_fix (was "11_wound_bark")

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}
			else if (GetTag(oGuy) == "11_wounded2") // Ward Mossfeld
			{
				oNote = GetObjectByTag("10_militia1");
				PlayCustomAnimation(oGuy, "%", FALSE);
				SetMapPinEnabled(oNote, 0);
				AssignCommand(oGuy, SpeakOneLinerConversation("11_wound_bark_ward", GetNearestPC()));

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}
			else if (GetTag(oGuy) == "11_wounded3") // Pitney Lannon
			{
				oNote = GetObjectByTag("10_militia5");
				PlayCustomAnimation(oGuy, "%", FALSE);
				SetMapPinEnabled(oNote, 0);
				AssignCommand(oGuy, SpeakOneLinerConversation("11_wound_bark", GetNearestPC())); // kL_fix (was "11_wound_bark_wyl")

				// kL_fix
				// The actions are redundant. They will be assigned in '11_a_meet'
				// by the one-liner dialog. Redundancy can/does cause stupidity.
				return;
				// kL_fix_end
			}

			AssignCommand(oGuy, ActionForceMoveToLocation(lJump, TRUE));
			AssignCommand(oGuy, ActionDoCommand(SetCommandable(TRUE)) );
			AssignCommand(oGuy, ActionDoCommand(DestroyObject(oGuy)));
			AssignCommand(oGuy, SetCommandable(FALSE) );
		}
		break;

		case 20: // Player is evil McEvil
		{
			effect eDeath = EffectDeath();

			SetPlotFlag(oGuy, FALSE);
			SetImmortal(oGuy, FALSE);
			PlayCustomAnimation(oGuy, "%", FALSE);
			ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oGuy);
			//AssignCommand(oGuy, ClearAllActions(TRUE));
			//AssignCommand(oGuy, ActionPlayAnimation(ANIMATION_LOOPING_DEAD_BACK, 1.0, 9999.0));
		}
		break;
	}
}
