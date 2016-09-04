// 13_inc_npc
//
// Functions to deal with basic npc operations
//
// EPF 4/29/05

#include "nw_i0_generic"
#include "ginc_misc"

// SurrenderToTalk()
// 
// oSurrenderer surrenders to enemies and becomes neutral.
// bImmortal specifies a value for the oSurrenderer's Immortal flag --
// often the NPC is set to immortal so he can surrender rather than die, but
// the PC will have the option to kill him after the surrender.
// oSurrenderer speaks sSurrenderLine, or not at all if it's an empty string.
void SurrenderToTalk(object oSurrenderer, int bImmortal = FALSE, string sSurrenderLine = "");


// GoHostileAndAttack()
// 
// oAttacker is switched to the Hostile faction, is set to regard oTarget
// as a personal enemy as well (undoing temporary friend/neutral status),
// and then attacks oTarget.
void GoHostileAndAttack(object oAttacker, object oTarget);


// GoHostileAndAttackAnything()
// 
// oAttacker is switched to the Hostile faction, and goes straight to determinecombatround.
void GoHostileAndAttackAnything(object oAttacker);

void SurrenderToTalk(object oSurrenderer, int bImmortal, string sSurrenderLine)
{
	AssignCommand(oSurrenderer, SurrenderToEnemies());
	
	if(sSurrenderLine != "")
	{
		ActionSpeakString(sSurrenderLine, TALKVOLUME_TALK);
	}
	
	if(GetImmortal(oSurrenderer))
	{
		SetImmortal(oSurrenderer,bImmortal);
	}
	ChangeFaction(oSurrenderer, GetTarget("npc_neutral"));
	object oNeutral = GetTarget("npc_neutral");
	PrintString(GetName(oNeutral));
}

void GoHostileAndAttack(object oAttacker, object oTarget)
{
	ChangeToStandardFaction(oAttacker, STANDARD_FACTION_HOSTILE);
	AssignCommand(oAttacker, ClearAllActions(TRUE));
	DelayCommand(0.2, AssignCommand(oAttacker, DetermineCombatRound(oTarget)));
}

void GoHostileAndAttackAnything(object oAttacker)
{
	ChangeToStandardFaction(oAttacker, STANDARD_FACTION_HOSTILE);
	AssignCommand(oAttacker, ClearAllActions(TRUE));
	DelayCommand(0.2, AssignCommand(oAttacker, DetermineCombatRound()));
}

void GoHostileAndAttackNearest(object oAttacker)
{
	ChangeToStandardFaction(oAttacker, STANDARD_FACTION_HOSTILE);
	AssignCommand(oAttacker, ClearAllActions(TRUE));
	DelayCommand(0.2, AssignCommand(oAttacker, DetermineCombatRound(GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY, oAttacker))));
}

// MoveCreatureToRandomLocation()
//
// Move oCreature to a random location within the bounds dictated by the 4 x and y params.
void MoveCreatureToRandomLocation(object oCreature, int nMinX, int nMaxX, int nMinY, int nMaxY)
{
	float x,y,z;
		
	
	//determine whether we want to use the bounds for the lower or upper city
	x = IntToFloat(Random(nMaxX - nMinX) + nMinX);
	y = IntToFloat(Random(nMaxY - nMinY) + nMinY);
	z = 0.f;

	vector vPos = Vector(x,y,z);
	location lRand = Location(GetArea(oCreature),vPos, 0.f);
	AssignCommand(oCreature, ActionMoveToLocation(lRand));	
}