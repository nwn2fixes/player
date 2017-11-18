//::///////////////////////////////////////////////////////////////////////////
//::
//::	gai_preference_dcr
//::
//::	Determine Combat Round for the Class Priority AI.
//::
//::        Spell Queue AI's will cast spells form an ordered list attached to them.
//::		To Attach a list, use the function ******, the conversation script ******,
//::		or manually using these variables (must be done pre-spawn) *******.
//::
//::///////////////////////////////////////////////////////////////////////////
// DBR 1/31/06
// DBR 2/28/06 - added support for mixing in the AI type preference (the type that prefers other AI types) 
// BMA 4/05/06 - bCheat || GetHasSpell() for SpellQueueResolve() 
// DBR 9/19/06 - swapped out distance checks for perception checks

#include "nw_i0_generic"
#include "x2_inc_switches"
#include "ginc_param_const"
#include "ginc_ai"
#include "nw_i0_plot"

//#include "ginc_debug"

#include "ginc_ai"
#include "ginc_group"


int TankProtect(int nClassType);
object CPGetSuitableEnemy(int nClassType);
int SpellQueueResolve();
object SQGetSuitablePC();
object SQGetSuitableEnemy();
object SQGetSuitableFriend();
object AIPGetSuitableEnemy(int nAIType);


void main()
{
	/////This allows this custom DCR to re-call DetermineCombatRound() but with a new target (short circuiting the current)
	if (GetLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK"))//via a loophole, this function can be called recursively.
	{
		DeleteLocalInt(OBJECT_SELF,"X2_SPECIAL_COMBAT_AI_SCRIPT_OK");
		return;														//this makes sure redundant code is not run.
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////////////


	////////////////////////////Handling Determine Combat round red tape
    object oIntruder = GetCreatureOverrideAIScriptTarget();
    ClearCreatureOverrideAIScriptTarget(); 
	
	
	//////this section ensures that AI's will fight even if they can't get to their preffered targets/////////////
	int nBlockCount=GetLocalInt(OBJECT_SELF,VAR_AP_BLOCKCOUNT);
	if (nBlockCount<0) //set creature to act normally
	{
		nBlockCount+=1;
		SetLocalInt(OBJECT_SELF,VAR_AP_BLOCKCOUNT,nBlockCount);
		return;
	}
	if (nBlockCount>10)//the AI has put the creature between a rock and a hard place. Act normally until this is all sorted out
	{
		//PrettyMessage("Overridding AI - " +GetTag(OBJECT_SELF) + " is stuck");
		nBlockCount=-2;
		SetLocalInt(OBJECT_SELF,VAR_AP_BLOCKCOUNT,nBlockCount);
		return;
	}
	SetLocalInt(OBJECT_SELF,VAR_AP_BLOCKCOUNT,0);	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////

//	PrettyMessage("Entering DCR");


    if (__InCombatRound())	//if I'm already doing stuff, don't overload me here.
        return;
	


	//Spell Queues occur before anything else
	if (SpellQueueResolve())
		return;






	int nTotalPrefs=GetLocalInt(OBJECT_SELF,VAR_AP_NUM_PREF);

	int nChance=Random(100)+1;
	int i = 1;
	int nRange = GetLocalInt(OBJECT_SELF,VAR_AP_CHANCE_PREFIX+IntToString(i));
	while ((nRange<nChance)&&(i<=nTotalPrefs))
	{
		nChance-=nRange;
		i+=1;
		nRange = GetLocalInt(OBJECT_SELF,VAR_AP_CHANCE_PREFIX+IntToString(i));
	}
	if (i>nTotalPrefs)
		return;				//Random chance determined that standard DCR should handle this round
	//otherwise, we have our preferance
	int nPref = GetLocalInt(OBJECT_SELF,VAR_AP_PREF_PREFIX+IntToString(i));
	
	if (nPref==ATTACK_PREFERENCE_STRONGEST)
	{
//		PrettyMessage("Which is Attack Strongest");
		object oTemp,oHigh=OBJECT_INVALID;//find the strongest enemy near me
		int nHighest=0;
		int i=0, nTemp;
		//float fDist=0.0f;
		//while ((fDist<13.0f) && (GetIsObjectValid(oTemp=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE))))
		while (GetIsObjectValid(oTemp=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN)))
		{
			//fDist=GetDistanceBetween(OBJECT_SELF,oTemp);
			nTemp=GetAbilityScore(oTemp,ABILITY_STRENGTH);
			if (nTemp>nHighest)
			{
				nHighest=nTemp;
				oHigh=oTemp;
			}
		}
		if (GetIsObjectValid(oHigh))
		{
		    SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oHigh);			//and Call myself again with the new target.
			
			ActionDoCommand(SetCreatureOverrideAIScriptFinished());// these two lines are appended to DCR()'s added actions.. 
			ActionDoCommand(DetermineCombatRound());// that way if the actions cannot be completed, the creature does something 
			
			SetCreatureOverrideAIScriptFinished();	//we handled things
			return;
		}
//		PrettyMessage("NO TARGET!!!");
		return;
	}

	if (nPref==ATTACK_PREFERENCE_WEAKEST)
	{
//		PrettyMessage("Which is Attack Weakest");
		object oTemp,oLow=OBJECT_INVALID;//find the weakest enemy near me
		int nLowest=1000;
		int i=0, nTemp;
		//float fDist=0.0f;
		//while ((fDist<13.0f) && (GetIsObjectValid(oTemp=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE))))
		while (GetIsObjectValid(oTemp=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN)))
		{
			//fDist=GetDistanceBetween(OBJECT_SELF,oTemp);
			nTemp=GetAbilityScore(oTemp,ABILITY_STRENGTH);
			if (nTemp<nLowest)
			{
				nLowest=nTemp;
				oLow=oTemp;
			}
		}
		if (GetIsObjectValid(oLow))
		{			
		    SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oLow);			//and Call myself again with the new target.

			ActionDoCommand(SetCreatureOverrideAIScriptFinished());// these two lines are appended to DCR()'s added actions.. 
			ActionDoCommand(DetermineCombatRound());// that way if the actions cannot be completed, the creature does something 
			
			SetCreatureOverrideAIScriptFinished();	//we handled things
			return;
		}
		//PrettyMessage("NO TARGET!!!");
		return;
	}

	if (nPref==ATTACK_PREFERENCE_GROUPATTACK)
	{
	//	PrettyMessage("Which is GroupAttack");
		string sGroup=GetGroupName(OBJECT_SELF);
		if (sGroup=="")		//if I'm not in a group, just go with standard DCR. It'll be like the group of one is all attacking something
			return;	
		object oTarget=GetGroupObject(sGroup,VAR_AP_GROUP_TARGET);
		if (GetIsObjectValid(oTarget)) //if my group has a target, smack 'em.
		{
		    SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oTarget);			//and Call myself again with the new target.
			SetCreatureOverrideAIScriptFinished();	//
			return;
		}
		//if my group doesn't have a target... make one.. then smack 'em.
		oTarget=GetNearestEnemy();
		SetGroupObject(sGroup,VAR_AP_GROUP_TARGET,oTarget);
	    SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
		DetermineCombatRound(oTarget);			//and Call myself again with the new target.
		SetCreatureOverrideAIScriptFinished();	//
		return;
	}	
	
	if (nPref==ATTACK_PREFERENCE_MOSTDAMAGEDBY)
	{
//		PrettyMessage("Which is Most Damaged By");
		int nNumThreats=GetLocalInt(OBJECT_SELF,VAR_AP_NUM_DAMAGERS);
		if (nNumThreats<=0) //no one has hurt me yet, I've killed everyone who has hurt me, etc.
		{
//			PrettyMessage("No Targs");
			return; //so just do a standard DCR
		}
		object oTarget;
		int i=0;
		while ((GetCurrentHitPoints(oTarget=GetLocalObject(OBJECT_SELF,VAR_AP_DAMAGER+"1"))<=0)||(GetArea(oTarget)!=GetArea(OBJECT_SELF)))//this guy has died. Bump up the list
		{
			//PrettyMessage("A person has died");
			if (oTarget==OBJECT_INVALID)	//we have hit the end of our list. Everyone who has killed us is dead.
				return;		//so do a standard DCR
			//The first target in our list has died or otherwise become invalid. dec list count.
			SetLocalInt(OBJECT_SELF,VAR_AP_NUM_DAMAGERS,--nNumThreats);
			i=1;
			//  Bump everyone up the list (2 becomes 1, 3 becomes 2)
			while ((oTarget=GetLocalObject(OBJECT_SELF,VAR_AP_DAMAGER+IntToString(++i)))!=OBJECT_INVALID)
			{
			//	PrettyMessage("Bumping up...");
				SetLocalObject(OBJECT_SELF,VAR_AP_DAMAGER+IntToString(i-1), oTarget);
				SetLocalInt(OBJECT_SELF,VAR_AP_DAMAGER_PTS+IntToString(i-1),GetLocalInt(OBJECT_SELF,VAR_AP_DAMAGER_PTS+IntToString(i)));
			}
			SetLocalObject(OBJECT_SELF,VAR_AP_DAMAGER+IntToString(i-1),OBJECT_INVALID);//erase last entry
		}
//		PrettyMessage("attacking : "+GetTag(oTarget) + " Because he has hit me for: " +IntToString(GetLocalInt(OBJECT_SELF,VAR_AP_DAMAGER_PTS+"1")));		
		//now, oTarget is a valid object from the top of the list (done most damage). So smack 'em.
	    SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
		DetermineCombatRound(oTarget);			//and Call myself again with the new target.
		SetCreatureOverrideAIScriptFinished();	//
		return;
	}
	
	if (nPref==ATTACK_PREFERENCE_PROTECTOR)
	{
//		PrettyMessage("Which is Protector");
		object oGuardee=GetLocalObject(OBJECT_SELF,VAR_P_GUARDTHIS);
		object oTarget=OBJECT_INVALID;
		int i=0;
		while ((oTarget=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,oGuardee,++i,CREATURE_TYPE_IS_ALIVE,TRUE,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN))!=OBJECT_INVALID)
			if (GetAttackTarget(oTarget)==oGuardee)
			{
    			SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
				DetermineCombatRound(oTarget);			//and Call myself again with the new target.
				SetCreatureOverrideAIScriptFinished();	//
				return;
			}
		//no one's attacking my defend target. So attack the guy closest to it.
		oTarget=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,oGuardee,1,CREATURE_TYPE_IS_ALIVE,TRUE,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN);
   		SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
		DetermineCombatRound(oTarget);			//and Call myself again with the new target.
		SetCreatureOverrideAIScriptFinished();	//
		return;
	}	

	if (nPref==ATTACK_PREFERENCE_TANK)
	{
//		PrettyMessage("Which is Tank");
		//if low on health, potions, spells 
		if (GetCurrentHitPoints(OBJECT_SELF) * 1.0f < GetMaxHitPoints(OBJECT_SELF) * 0.5f)
			if (TalentHealingSelf()==TRUE) // kL_fix, was "99"
			{
				SetCreatureOverrideAIScriptFinished();	
				return;
			}	
		if (TankProtect(CLASS_TYPE_WIZARD))
			return;
		if (TankProtect(CLASS_TYPE_SORCERER))
			return;
		if (TankProtect(CLASS_TYPE_CLERIC))
			return;
		if (TankProtect(CLASS_TYPE_RANGER))
			return;
		if (TankProtect(-1)) //Any class
			return;	
		//I am a good tank. My friends are ok. So Parry/expertise
		if (GetHasFeat(FEAT_IMPROVED_COMBAT_EXPERTISE))
		{
			if (!GetActionMode(OBJECT_SELF,ACTION_MODE_IMPROVED_COMBAT_EXPERTISE))
				SetActionMode(OBJECT_SELF,ACTION_MODE_IMPROVED_COMBAT_EXPERTISE,TRUE);
		}
		else if (GetHasFeat(FEAT_COMBAT_EXPERTISE))
		{
			if (!GetActionMode(OBJECT_SELF,ACTION_MODE_COMBAT_EXPERTISE))
				SetActionMode(OBJECT_SELF,ACTION_MODE_COMBAT_EXPERTISE,TRUE);
		}
		else
		{
			if (!GetActionMode(OBJECT_SELF,ACTION_MODE_PARRY))
				SetActionMode(OBJECT_SELF,ACTION_MODE_PARRY,TRUE);
		}
		SetCreatureOverrideAIScriptFinished();	//
		return;
	}	

	if (nPref==ATTACK_PREFERENCE_CLASS_PRIORITY)
	{
//		PrettyMessage("WHich is Class Priority");
		int nNumEntries = GetLocalInt(OBJECT_SELF,VAR_CP_NUM_ENTRIES);		//find out what we're looking for
		int nClassType,i=1;
		object oTarget=OBJECT_INVALID;
		while ((i<=nNumEntries)&&(!GetIsObjectValid(oTarget)))
		{
			nClassType=GetLocalInt(OBJECT_SELF,VAR_CP_ENTRY_PREFIX+IntToString(i));
			oTarget=CPGetSuitableEnemy(nClassType);		
			i+=1;
		}
	
		if (GetIsObjectValid(oTarget))
		{
	    	SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oTarget);			//and Call myself again with the new target.
			SetCreatureOverrideAIScriptFinished();	//
			return;
		}
	}

	if (nPref==ATTACK_PREFERENCE_AI_TYPE)
	{
//		PrettyMessage("WHich is AI Priority");
		int nNumEntries = GetLocalInt(OBJECT_SELF,VAR_AIP_NUM_ENTRIES);		//find out what we're looking for
		int nAIType,i=1;
		object oTarget=OBJECT_INVALID;
		while ((i<=nNumEntries)&&(!GetIsObjectValid(oTarget)))
		{
			nAIType=GetLocalInt(OBJECT_SELF,VAR_AIP_ENTRY_PREFIX+IntToString(i));
			oTarget=AIPGetSuitableEnemy(nAIType);		
			i+=1;
		}
	
		if (GetIsObjectValid(oTarget))
		{
	    	SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oTarget);			//and Call myself again with the new target.
			SetCreatureOverrideAIScriptFinished();	//
			return;
		}
	}

//	PrettyMessage("Which is Default DCR");    
}


object AIPGetSuitableEnemy(int nAIType)
{
	int i=0;
	object oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN);
	if (!GetIsObjectValid(oTarget))
		return OBJECT_INVALID;
	while (!GetIsAIType(oTarget,nAIType))
	{
		oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,OBJECT_SELF,++i,CREATURE_TYPE_PERCEPTION,PERCEPTION_SEEN);
		if (!GetIsObjectValid(oTarget))
			return OBJECT_INVALID;
	}
	return oTarget;
}



int TankProtect(int nClassType)
{
		object oFriend=OBJECT_INVALID,oThreat;
		int i;
		//Attack those who are attacking faction nClassType's
		i=0;
		while (!GetIsObjectValid(oFriend))
		{
			if (nClassType>=0)
				oFriend=GetNearestCreature(CREATURE_TYPE_CLASS,nClassType,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_FRIEND);
			else
				oFriend=GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_FRIEND,OBJECT_SELF,++i,CREATURE_TYPE_IS_ALIVE,TRUE);
			if (oFriend==OBJECT_INVALID) //no more candidates
				break; 
			oThreat=GetLastAttacker(oFriend);
			if (!GetFactionEqual(OBJECT_SELF,oFriend))	//must be in my faction..
				oFriend=OBJECT_INVALID;
			else if (!GetIsObjectValid(oThreat))		//attacker data must not be out of date
				oFriend=OBJECT_INVALID;
			else if (GetArea(oThreat)!=GetArea(OBJECT_SELF)) //must still be in the same area
				oFriend=OBJECT_INVALID;
			else if (GetAttackTarget(oThreat)!=oFriend)		//must still be attacking my friend
				oFriend=OBJECT_INVALID;
		}
		if (GetIsObjectValid(oFriend))
		{
   			SetCreatureOverrideAIScriptFinished();//Short circuit the Determine Combat round I'm already in,
			DetermineCombatRound(oThreat);			//and Call myself again with the new target.
			SetCreatureOverrideAIScriptFinished();	//
			return 1;
		}
		return 0;
}



object SQGetSuitablePC()
{
	return GetNearestPC();
}

object SQGetSuitableEnemy()
{
	return GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY);
}

object SQGetSuitableFriend()
{
	return GetNearestCreature(CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_FRIEND);
}

int SpellQueueResolve()
{
	int nWhichEntry=GetLocalInt(OBJECT_SELF,sSPELL_QUEUE_NUM_CAST)+1;//Which spell am I on?
	string sTarget = GetLocalString(OBJECT_SELF,sSPELL_QUEUE_TARGET_ENTRY+IntToString(nWhichEntry));
	if (sTarget=="") //see if we are out of spells queued up
	{
		//SetCreatureOverrideAIScript(OBJECT_SELF,""); //turn off this special AI
		DeleteLocalInt(OBJECT_SELF,sSPELL_QUEUE_NUM_CAST);
		return 0;
	}
	SetLocalInt(OBJECT_SELF,sSPELL_QUEUE_NUM_CAST,nWhichEntry);

	int nSpell = GetLocalInt(OBJECT_SELF,sSPELL_QUEUE_ENTRY+IntToString(nWhichEntry));
	int bCheat = GetLocalInt(OBJECT_SELF,sSPELL_QUEUE_ENTRY_CHEAT+IntToString(nWhichEntry));
	int bInstant = GetLocalInt(OBJECT_SELF, sSPELL_QUEUE_ENTRY_INSTANTCAST+IntToString(nWhichEntry));
	DeleteLocalInt(OBJECT_SELF,sSPELL_QUEUE_ENTRY+IntToString(nWhichEntry));
	DeleteLocalString(OBJECT_SELF,sSPELL_QUEUE_TARGET_ENTRY+IntToString(nWhichEntry));
	DeleteLocalInt(OBJECT_SELF,sSPELL_QUEUE_ENTRY_CHEAT+IntToString(nWhichEntry));
	DeleteLocalInt(OBJECT_SELF,sSPELL_QUEUE_ENTRY_INSTANTCAST+IntToString(nWhichEntry));
	
	object oTarget;

	if (GetStringLeft(sTarget,1)=="$")
	{
		if (sTarget=="$SELF")
			oTarget=OBJECT_SELF;
		else if (sTarget=="$PC")
			oTarget=SQGetSuitablePC();
		else if (sTarget=="$ENEMY")
			oTarget=SQGetSuitableEnemy();
		else if (sTarget=="$FRIEND")
			oTarget=SQGetSuitableFriend();	
	}
	else
		oTarget = GetTarget(sTarget);
	if (!GetIsObjectValid(oTarget))
		return 0;

	// True if this is the last spell on the queue
	int bLastSpell = (GetLocalString(OBJECT_SELF,sSPELL_QUEUE_TARGET_ENTRY+IntToString(nWhichEntry+1)) == "");
		
	if (bCheat || GetHasSpell(nSpell))
	{
		//if an instant spell is last on the queue, we make it do the combat round override so that DCR doesn't clear the action queue.
		if(bInstant && !bLastSpell)
		{
			ActionCastSpellAtObject(nSpell,oTarget,METAMAGIC_ANY,bCheat, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
			
			//instant spells do not require a combat round, so we'll try to resolve the next spell in the queue, too, and we'll
			//do this until we either find a spell that isn't instant or we run out of spells, in which case we go to normal combat.
			SpellQueueResolve();
			return 1;
			
		}
	    __TurnCombatRoundOn(TRUE);	//set me up not to be interrupted by other Determine Combat Rounds
		ActionCastSpellAtObject(nSpell,oTarget,METAMAGIC_ANY,bCheat, PROJECTILE_PATH_TYPE_DEFAULT, bInstant);
		__TurnCombatRoundOn(FALSE);
	    SetCreatureOverrideAIScriptFinished();//Tell Determine Combat Round That I handled things.
		return 1;
	}
	return 0;
}

object CPGetSuitableEnemy(int nClassType)
{
	float fDist, fDistmin;
	if (nClassType==AI_CLASS_TYPE_MELEE) //currently encompasses Barbarians, Clerics, Fighters, Monks and Paladins
	{
		object oChoice=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_BARBARIAN,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		fDistmin=GetDistanceBetween(OBJECT_SELF,oChoice);
		if (fDistmin==0.0f)
			fDistmin=1000.0f;
		object oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_CLERIC,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_FIGHTER,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_MONK,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_PALADIN,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		if (GetObjectSeen(oChoice))//suitable attack range
			return oChoice;
		else
			return OBJECT_INVALID;
	}
	else
	if (nClassType==AI_CLASS_TYPE_RANGED)//currently encompasses Druids, Rangers, Sorcerers and Wizards.
	{
		object oChoice=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_DRUID,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		fDistmin=GetDistanceBetween(OBJECT_SELF,oChoice);
		if (fDistmin==0.0f)
			fDistmin=1000.0f;
		object oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_RANGER,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_SORCERER,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_WIZARD,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		if (GetObjectSeen(oChoice))//suitable attack range
			return oChoice;
		else
			return OBJECT_INVALID;
	}
	else
	if (nClassType==AI_CLASS_TYPE_SPELLCASTERS)//currently encompasses Wizards and Sorcerers.
	{
		object oChoice=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_WIZARD,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		fDistmin=GetDistanceBetween(OBJECT_SELF,oChoice);
		if (fDistmin==0.0f)
			fDistmin=1000.0f;
		object oNext=GetNearestCreature(CREATURE_TYPE_CLASS,CLASS_TYPE_SORCERER,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if ((fDist = GetDistanceBetween(OBJECT_SELF,oNext))!=0.0f) //if valid
			if (fDist<fDistmin)
			{
				oChoice=oNext;
				fDistmin=fDist;
			}
		if (GetObjectSeen(oChoice))//suitable attack range
			return oChoice;
		else
			return OBJECT_INVALID;
	}
	else
	{
		object oChoice=GetNearestCreature(CREATURE_TYPE_CLASS,nClassType,OBJECT_SELF,1,CREATURE_TYPE_REPUTATION,REPUTATION_TYPE_ENEMY,CREATURE_TYPE_IS_ALIVE,TRUE);
		if (GetObjectSeen(oChoice))//suitable attack range
			return oChoice;
		else
			return OBJECT_INVALID;
	}
}