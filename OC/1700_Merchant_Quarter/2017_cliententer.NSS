// '2017_cliententer'
/*
	OnClientEnter script for area: {1017}axle.
*/
// Created by: Brian Fox
// Created on: 9/24/05
// kevL 2023 aug 12 - destealth Moire [travus fix]
// travus 1/15/26 - Destroy rogue candle flame placed effects and added new ones.

#include "20_inc"

string VAR_CANDLEFIXDONE = "CandleFix";

//
int GetIsReadyForEdmundIntro(object oPc)
{
	if (!GetGlobalInt("gbWatch"))
	{
		int iQuestState = GetJournalQuestEntry("20_squiring", oPc);
		return iQuestState == 12 || iQuestState == 21;
	}
	return FALSE;
}


//
void main()
{
	object oLeader = GetFactionLeader(GetFirstEnteringPC());
	if (FiredFromPartyTransition())
	{
		if (GetIsReadyForEdmundIntro(oLeader))
		{
			ShowSponsor(oLeader); // Edmund cutscene (first entry into this area when gbWatch==FALSE)
		}
		else
			HideSponsor(oLeader); // just populate Axle as normal
	}

	object oMoire = GetNearestObjectByTag("10_moire", oLeader); // travus fix - destealth Moire ->
	SetActionMode(oMoire, ACTION_MODE_STEALTH, FALSE);

// travus start - fix candle flame positions ///////////////////////////////////
// kL - refactored a bit
	object oArea = OBJECT_SELF;
	if (!GetLocalInt(oArea, VAR_CANDLEFIXDONE))
	{
		SetLocalInt(oArea, VAR_CANDLEFIXDONE, TRUE);

		vector p;
		object o = GetFirstObjectInArea();
		while (GetIsObjectValid(o))
		{
			if (GetObjectType(o) == OBJECT_TYPE_PLACED_EFFECT)
			{
				// don't destroy other placed effects
				// candle flames to be destroyed are position less than x=6.0 and y=15.0
				p = GetPosition(o);
				if (p.x < 6.f && p.y < 15.f)
					DestroyObject(o);
			}
			o = GetNextObjectInArea();
		}

		effect e = EffectNWN2SpecialEffectFile("fx_candle");

		p = Vector(4.80209, 14.32725, 3.2025);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(5.324763, 14.08747, 3.157998);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(5.477927, 13.5085, 3.083998);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(5.12642, 13.04561, 3.206999);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(4.53125, 13.02709, 3.098999);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(4.148097, 13.47349, 3.173999);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
		p = Vector(4.285214, 14.07942, 3.123498);
		ApplyEffectAtLocation(DURATION_TYPE_PERMANENT, e, Location(oArea, p, 0.f));
	}
// travus end //////////////////////////////////////////////////////////////////
}
