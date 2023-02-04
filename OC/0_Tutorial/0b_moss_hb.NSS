//::///////////////////////////////////////////////////////////////////////////
//::
//::	0b_moss_round
//::
//::	Check for player, amie, and bevil's knockout from Brawl
//::
//::///////////////////////////////////////////////////////////////////////////
// DBR 1/4/6
// kevL 2023 feb 4 - add a fallthrough to FindNewTarget() jic

#include "0inc_brawl"

void MossLeaveCharAlone(object oChar)
{
	object oMoss=GetObjectByTag("0_wyl");
	if (oChar==GetAttackTarget(oMoss))
		AssignCommand(oMoss,FindNewTarget());
	oMoss=GetObjectByTag("0_webb");
	if (oChar==GetAttackTarget(oMoss))
		AssignCommand(oMoss,FindNewTarget());
	oMoss=GetObjectByTag("0_ward");
	if (oChar==GetAttackTarget(oMoss))
		AssignCommand(oMoss,FindNewTarget());
}


void main()
{
	if (GetBrawlState()==FALSE)
		return;

	if (GetLocalInt(OBJECT_SELF, "attack") == 1)
	{
		object oPC = GetBrawlPC();
		if (!GetIsObjectValid(oPC))
			oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR,TRUE);
		object oAmie=GetObjectByTag("0_amie"), oBevil=GetObjectByTag("npc_bevil");
		//object oKipp=GetObjectByTag("0_kipp");
		int nWin;
		//if (GetFactionEqual(oKipp,oBevil))
		//	nWin=3;
		//else
			nWin=2;

		int bBypassFindTarget = FALSE; // kL

		object oAttackee=GetAttackTarget();

		if (GetIsObjectValid(oAmie))
			if (GetLocalInt(oAmie,"brawl_knockout")!=1)
			{
				if (GetCurrentHitPoints(oAmie)<=1)
				{
					SetLocalInt(oAmie,"brawl_knockout",1);
					AssignCommand(oAmie, PCLeaveFight());
					MossLeaveCharAlone(oAmie);
					if (GetLocalInt(oBevil,"brawl_knockout")+GetLocalInt(oPC,"brawl_knockout")==nWin)
					{
						AssignCommand(GetModule(),TransportOutOfMossFight(oPC));					//RoundOver, Moss wins
						return;
					}
				}
			}
			else if (oAttackee==oAmie)
			{
				FindNewTarget();
				bBypassFindTarget = TRUE; // kL
			}

		if (GetIsObjectValid(oBevil))
			if (GetLocalInt(oBevil,"brawl_knockout")!=1)
			{
				if (GetCurrentHitPoints(oBevil)<=1)
				{
					SetLocalInt(oBevil,"brawl_knockout",1);
					AssignCommand(oBevil, PCLeaveFight());
					MossLeaveCharAlone(oBevil);
					if (GetLocalInt(oAmie,"brawl_knockout")+GetLocalInt(oPC,"brawl_knockout")==nWin)
					{
						AssignCommand(GetModule(),TransportOutOfMossFight(oPC));					//RoundOver, Moss wins
						return;
					}
				}
			}
			else if (oAttackee==oBevil)
			{
				FindNewTarget();
				bBypassFindTarget = TRUE; // kL
			}

		if (GetIsObjectValid(oPC))
			if (GetLocalInt(oPC,"brawl_knockout")!=1)
			{
				if (GetCurrentHitPoints(oPC)<=1)
				{
					SetLocalInt(oPC,"brawl_knockout",1);
					AssignCommand(oPC, PCLeaveFight());
					MossLeaveCharAlone(oPC);
					if (GetLocalInt(oBevil,"brawl_knockout")+GetLocalInt(oAmie,"brawl_knockout")==nWin)
					{
						AssignCommand(GetModule(),TransportOutOfMossFight(oPC));//RoundOver, Moss wins
						return;
					}
				}
			}
			else if (oAttackee==oPC)
			{
				FindNewTarget();
				bBypassFindTarget = TRUE; // kL
			}

		/*if (GetLocalInt(oKipp,"brawl_knockout")!=1)
		{
			if (GetCurrentHitPoints(oKipp)<=1)
			{
				SetLocalInt(oKipp,"brawl_knockout",1);
				AssignCommand(oKipp, PCLeaveFight());
				MossLeaveCharAlone(oKipp);
				if (GetLocalInt(oPC,"brawl_knockout")+GetLocalInt(oBevil,"brawl_knockout")+GetLocalInt(oAmie,"brawl_knockout")==nWin)
				{
					AssignCommand(GetModule(),TransportOutOfMossFight(oPC));//RoundOver, Moss wins
					return;
				}
			}
		}
		else if (oAttackee==oKipp) FindNewTarget();*/


		// kL_start ->
		if (!bBypassFindTarget)
		{
			oAttackee = GetAttackTarget(); // reget
			if (!GetIsObjectValid(oAttackee)
				|| GetLocalInt(oAttackee, "brawl_knockout") == 1
				|| GetCurrentHitPoints(oAttackee) <= 1)
			{
				FindNewTarget();
			}
		}
		// kL_end.
	}


	ExecuteScript("nw_c2_default1",OBJECT_SELF);
}
