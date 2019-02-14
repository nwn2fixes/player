// gui_rest
/*
	Do rest or wait action based on what is selected in the Rest GUI
	This script is only called if they hit ok.
	
*/
// ChazM 4/10/07
// ChazM 4/11/07 - modified to support party rest
// ChazM 4/12/07 - fix for time change interrupting sleep.  Added SinglePartyWMRestEncounterCheck()
// ChazM 4/13/07 - major changes
// ChazM 6/19/07 - Modified PlayerRest() - tiny pause before fade.
// ChazM 6/19/07 - Fix for resting while controlling a companion.
// MDiekmann 6/21/07 - Modifications made so that before actual rest occurs a hostile check is done. This prevents time advancing without actually resting.
// MDiekmann 6/22/07 - Should a nearby hostile interrupt rest, we force rest to make sure spells and health are regained.
// ChazM 6/29/07 - updated and moved SinglePartyWMRestEncounterCheck() to ginc_restsys
// MDiekmann 7/5/07 - modified interrupted rest check to make sure object is alive.
// MDiekmann 7/10/07 - Changes made to unpause spirit bar when entering rest state.
// ChazM 7/24/07 - Altered FadeToBlack to no longer use w/o failsafe
// ChazM 8/3/07 - Added Rest Sys lock to prevent simultaneous multiple resting
// ChazM 8/13/07 - Added supoort for CAMPAIGN_SWITCH_REST_SYS_USE_FORCE_REST
// NLC 10/10/08 - Modified for NX2.
// kevL's 2019.02.14 - merge this with the SoZ Campaign 'gui_rest' so it's suitable for /Override.

#include "ginc_restsys"
#include "ginc_time"
#include "kinc_spirit_eater"	// OC
//#include "ginc_overland"		// SoZ
//#include "ginc_overland_ai"	// SoZ

const int STR_REF_MONSTER_INTERRUPT			= 207061; // "A nearby enemy has interrupted your rest."
const int STR_REF_MEMBER_IN_CONVERSATION	= 208545; // "You cannot rest while a party member is in conversation."
const int STR_REF_HOURS_PASSED 				= 186225;  // " hours have passed."
const int STR_REF_1_HOUR_PASSED 			= 186226;  // "1 hour has passed."

const float RS_TIME_CHANGE_DELAY 		= 1.0f; // amount of time to wait until doing the time set.
const float RS_AFTER_TIME_CHANGE		= 5.0f; // a value somewhat greater than TIME_CHANGE_DELAY.

const int RS_STANDARD_REST_HOURS		= 8;	// number of hours in a standard rest.
const float RS_REST_BAR_SECONDS			= 5.0f;	// Number of seconds the engine makes the rest bar last.

const string VAR_N2_RESTSYS_IN_PROGRESS = "N2_RESTSYS_IN_PROGRESS";


void RestKillBleedingOut(object oPC);
// -------------------------------
// Helper functions
// -------------------------------
void VoidSetGlobalInt(string sName, int nValue)
{
	SetGlobalInt(sName, nValue);
}
/* int GetIsFactionMemberInConversation(object oMemberOfFaction, int bPCOnly=TRUE) // SoZ funct. is same as MotB 'kinc_spirit_eater' funct.
{
	object oPartyMember = GetFirstFactionMember(oMemberOfFaction, bPCOnly);
    while(GetIsObjectValid(oPartyMember) == TRUE)
    {
		if (IsInConversation(oPartyMember))
			return(TRUE);
        oPartyMember = GetNextFactionMember(oMemberOfFaction, bPCOnly);
    }
	return (FALSE);
} */
// -------------------------------
// NX1 campaign specific funtions
// (references to these can be removed for other campaigns)
// -------------------------------
void NX1OnRestOrPartialRest()
{
	// if resting, then reset this var.
	DelayCommand(RS_AFTER_TIME_CHANGE, VoidSetGlobalInt("se_has_used_devour_ability", FALSE));
}

void NX1TimePassPrep(object oPC)
{
	// in NX1, need to make sure we leave spirit-bar-paused mode before we move time forward.
	// Without this, time passed shortly after a conversation would have no effect on Spirit Energy.
	SpiritEaterConversationPauseCheck(oPC);
}


// -------------------------------
// NX1 Party Rest System functions
// -------------------------------

// This will flip the var on for doing a rest, do a rest, and then flip it back off.
void ActionRealRest(int bReportStart, int bReportCancel)
{
	SetLocalInt(OBJECT_SELF, VAR_REST_NOW, TRUE); // OnPlayerRest event will allow rest and then reset back to FALSE
	if (bReportStart == TRUE)
		RestSendMessage(OBJECT_SELF, STR_REF_REST_STARTED);
	if (bReportCancel == TRUE)
		SetLocalInt(OBJECT_SELF, VAR_REST_REPORT_CANCEL, TRUE); // OnPlayerRest event will report a cancel if this is true
		
	// this will actually cause resting since the global is cleared for the moment.
	// Delayed for a split second to prevent the event from firing when doing it while paused.		
	DelayCommand(0.1f, ActionRest()); 
	
	// setting this back immediately doesn't give the rest enough time to occur, so we delay it.
	// this needs to finish before we do the time set, so needs to be < TIME_CHANGE_DELAY
	//SetLocalInt(OBJECT_SELF, VAR_REST_NOW, FALSE); // OnPlayerRest event will allow rest and then reset back to FALSE
	DelayCommand(0.5f, SetLocalInt(OBJECT_SELF, VAR_REST_NOW, FALSE));	// Reset Flag for next time player hits rest button.
	
	// allow reporting of cancel for duration of rest.	
	if (bReportCancel == TRUE)
		DelayCommand(5.5f, SetLocalInt(OBJECT_SELF, VAR_REST_REPORT_CANCEL, FALSE));
	
}


// this function set to run when the time change occurs
// thus these delays are all relative to the new time.
void PlayerRestFinish(int nNumHours, int bJustWait=FALSE, int nAmbushResult=WM_CHECK_NO_AMBUSH)
{
	FadeToBlack(OBJECT_SELF, 0.0); // try to go to black immediately
	if (bJustWait == FALSE)
	{
		//SetGlobalInt("se_has_used_devour_ability", FALSE);
		ClearAllActions();
		ActionRealRest(TRUE, TRUE); // this will actually cause resting
		
		// if not a full 8 hours then force waking early
		if (nAmbushResult == WM_CHECK_AMBUSH)
		{
			float fSleepDuration = (IntToFloat(nNumHours)/IntToFloat(RS_STANDARD_REST_HOURS)) * RS_REST_BAR_SECONDS;
			PrettyDebug("Ambushed! Partial rest for " + FloatToString(fSleepDuration) + " seconds.");
			DelayCommand(fSleepDuration, ClearAllActions());
		}
		else
		{
			PrettyDebug("No ambush");
			// Players might start moving before they finish resting.  Since there was no ambush,
			// we ensure that they get a full rest.  
			ActionDoCommand(ForceRest(OBJECT_SELF));
		}
	}	
	
	// fade back in slowly...
	DelayCommand(1.0f, FadeFromBlack(OBJECT_SELF, 3.0f));
	string sOut = "";
	if (nNumHours == 1)
		sOut = GetStringByStrRef(STR_REF_1_HOUR_PASSED);
	else
		sOut = IntToString(nNumHours) + GetStringByStrRef(STR_REF_HOURS_PASSED);
	DelayCommand(4.0f, FloatingTextStringOnCreature(sOut, OBJECT_SELF, FALSE));
}

// This is run on the PC
void PlayerRest(int nNumHours, int bJustWait=FALSE, int nAmbushResult=WM_CHECK_NO_AMBUSH)
{
	if (bJustWait == FALSE)
	{
		// kneel before we fade out so it looks like a rest.
		// (trying to do a second rest causes problems, so can't have rest bar up while starting out rest).
		ActionPlayAnimation(ANIMATION_LOOPING_KNEELIDLE, 1.0, RS_TIME_CHANGE_DELAY);
	}	
		
	// delay by a tiny amount so that if paused when rest button hit we wait till unpause for fade.
	DelayCommand(0.01f, FadeToBlack(OBJECT_SELF, RS_TIME_CHANGE_DELAY));
	
	// this will fire just as soon as we do the time change (currently in 1 second).
	DelayCommand(RS_AFTER_TIME_CHANGE, PlayerRestFinish(nNumHours, bJustWait, nAmbushResult));
}

// This will cause the whole party to rest using ActionRest().
// Standard resting encompasses several engine effects including resting over time, the countdown timer,
// the kneel animation, and it also fires off the module rest event for the player on start and on end.
// Params:
// 	oPC 		- players whose party is to rest
// 	iNumHours 	- used only for reporting to player
// 	bJustWait 	- FALSE = rest, TRUE = wait.
// 	nAmbushResult - if there's an ambush, a partial resting benefiet is gained.
void WholePartyRest(object oPC, int nNumHours, int bJustWait=FALSE, int nAmbushResult=WM_CHECK_NO_AMBUSH)
{
	if (bJustWait == FALSE && !GetIsSoZ())
	{
		NX1OnRestOrPartialRest();
	}
	
	// only need to tell the PC's to rest.  Other party members will follow suit.
	// Note that GetFirstFactionMember() gets the Owned PC, we need to make the controlled characters rest.
    object oPartyMember = GetFirstFactionMember(oPC, TRUE);
	object oRestingPC;
    while(GetIsObjectValid(oPartyMember) == TRUE)
    {
		oRestingPC = GetControlledCharacter(oPartyMember);
		AssignCommand(oRestingPC, PlayerRest(nNumHours, bJustWait));	// iNumHours passed for reporting only
        oPartyMember = GetNextFactionMember(oPC, TRUE);
    }
}


// This will cause the whole party to rest using ForceRest().  
// It is otherwise similar to WholePartyRest()
// Params:
// 	oPC 		- players whose party is to rest
// 	iNumHours 	- used only for reporting to player
// 	bJustWait 	- FALSE = rest, TRUE = wait.
// 	nAmbushResult - if there's an ambush then no resting benefiet.
void WholePartyForceRest(object oPC, int nNumHours, int bJustWait=FALSE, int nAmbushResult=WM_CHECK_NO_AMBUSH)
{
	// get all the player clients to do the fade, message report, etc.
	WholePartyRest(oPC, nNumHours, TRUE); // turn on bJustWait flag - actual rest handled below.

	// Need to tell all party members to ForceRest - ForceResting a PC doesn't affect his followers.
	// only do this if we are resting and not getting ambushed. (no partial rests if ambushed)
	if ((bJustWait == FALSE) && (nAmbushResult == WM_CHECK_NO_AMBUSH))
	{
		if (!GetIsSoZ())
			NX1OnRestOrPartialRest();

	    object oPartyMember = GetFirstFactionMember(oPC, FALSE);
	    while(GetIsObjectValid(oPartyMember) == TRUE)
	    {
			DelayCommand(RS_AFTER_TIME_CHANGE, ForceRest(oPartyMember));
	        oPartyMember = GetNextFactionMember(oPC, FALSE);
	    }
	}		
}



// Have party wait until nWaitTillHour.
void DoWholePartyWait(object oPC, int nWaitTillHour)
{
	// unlike resting, waiting takes the players to the top of the hour.	
	int nNumHours = nWaitTillHour - GetTimeHour();
	if (nNumHours <0)
		nNumHours += 24;	

	if (GetIsSoZ())
		AssignCommand(oPC, ClearAllActions());

	DelayCommand(RS_TIME_CHANGE_DELAY, SetTime(nWaitTillHour,0,0,0));
	WholePartyRest(oPC, nNumHours, TRUE); // just wait.
}


// Check for an encounter and do a WholePartyRest
// Params:
// 	oPC 		- players whose party is to rest
//  bUseForceRest - if true, the party will not use the regular action rest and instead uses ForceRest.
//					This prevents the rest bar from appearing.
void DoWholePartyRest(object oPC, int bUseForceRest)
{
	if (GetIsSoZ())
	{
		oPC = GetFactionLeader(GetFirstPC());
		// Is there a monster that has gotten close?
		object oMonster = GetFirstObjectInShape(SHAPE_SPHERE, 5.0f, GetLocation(OBJECT_SELF));
		while(GetIsObjectValid(oMonster))
		{ 
			if( GetLocalInt(oMonster, "bHostile") )
			{
				//SendMessageToPCByStrRef(OBJECT_SELF, STR_REF_MONSTER_INTERRUPT);
				SendMessageToPCByStrRef(GetControlledCharacter(OBJECT_SELF), STR_REF_MONSTER_INTERRUPT);
				return;
			}
			oMonster = GetNextObjectInShape(SHAPE_SPHERE, 8.0f, GetLocation(OBJECT_SELF));
		}
		
		// Wandering Monster Check
		int nResult = SinglePartyWMRestEncounterCheck(oPC);
		int nNumHours;
		if (nResult == WM_CHECK_NO_AMBUSH)
		{	// 8 hours pass
			nNumHours = RS_STANDARD_REST_HOURS;
	
			if(GetHasFeat(FEAT_TW_GROUP_TRANCE, oPC, TRUE))		//Group Trance halves the amount of time required for the party to rest.  
				nNumHours /= 2;
		}
	
		if (nResult == WM_CHECK_AMBUSH)
		{ 	// less than 8 hours pass
			nNumHours = d4();
			
			if(GetHasFeat(FEAT_TW_GROUP_TRANCE, oPC, TRUE))		//Group Trance also halves the amount of time that passes when the party gets a random encounter.
				nNumHours /= 2;		
		}
		// Move time forward!
		// Note: When time changes, it affects many things:
		// 	* sleep will have ended, so it will essentially be interruped.
		// 	* delay commands set to occur prior to the time change will all go off
	
		DelayCommand(RS_TIME_CHANGE_DELAY, RestKillBleedingOut(oPC));
		DelayCommand(RS_TIME_CHANGE_DELAY, SetCTimeDate(GetCurrentCTimeDate(0, 0, 0, nNumHours))); //Rest needs to occur after this
		
		// Use appropriate type of Resting on Party.
		if (bUseForceRest == TRUE)
			WholePartyForceRest(oPC, nNumHours, FALSE, nResult);
		else
			WholePartyRest(oPC, nNumHours, FALSE, nResult);
	}
	else
	{
		// Is there a monster that has gotten close?
		object oMonster = GetFirstObjectInShape(SHAPE_SPHERE, 43.0f, GetLocation(OBJECT_SELF));
		while(GetIsObjectValid(oMonster))
		{
			if(GetIsReactionTypeHostile(oMonster) && !GetIsDead(oMonster))
			{
				SendMessageToPCByStrRef(OBJECT_SELF, STR_REF_MONSTER_INTERRUPT);
				return;
			}
			oMonster = GetNextObjectInShape(SHAPE_SPHERE, 43.0f, GetLocation(OBJECT_SELF));
		}
	
		// Wandering Monster Check
		int nResult = SinglePartyWMRestEncounterCheck(oPC);
		int nNumHours;
		if (nResult == WM_CHECK_NO_AMBUSH)
		{	// 8 hours pass
			nNumHours = RS_STANDARD_REST_HOURS;
		}
		if (nResult == WM_CHECK_AMBUSH)
		{ 	// less than 8 hours pass
			nNumHours = d4();
		}
	
		// Move time forward!
		// Note: When time changes, it affects many things:
		// 	* sleep will have ended, so it will essentially be interruped.
		// 	* delay commands set to occur prior to the time change will all go off
		DelayCommand(RS_TIME_CHANGE_DELAY, SetCTimeDate(GetCurrentCTimeDate(0, 0, 0, nNumHours))); //Rest needs to occur after this
	
		// Use appropriate type of Resting on Party.
		if (bUseForceRest == TRUE)
			WholePartyForceRest(oPC, nNumHours, FALSE, nResult);
		else
			WholePartyRest(oPC, nNumHours, FALSE, nResult);
	}
}

void RestKillBleedingOut(object oPC)
{
	object oFM = GetFirstFactionMember(oPC, FALSE);
	while(GetIsObjectValid(oFM))
	{
		effect eEffect = GetFirstEffect(oFM);
		while(GetIsEffectValid(eEffect))
		{
			if(GetEffectType(eEffect) == EFFECT_TYPE_HITPOINT_CHANGE_WHEN_DYING)
			{
				// JWR-OEI - make sure they haven't been stabilized.
				if ( GetEffectInteger(eEffect, 0) == 0 )
				{
					effect eDeath = EffectDeath(FALSE, FALSE, TRUE, TRUE);
					ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oFM);
				}
			}
			eEffect = GetNextEffect(oPC);
		}
		
		oFM = GetNextFactionMember(oPC, FALSE);
	}
}
// set the rest-system-in-progress flag.
void RestSysSet(int nVal)
{
	SetGlobalInt(VAR_N2_RESTSYS_IN_PROGRESS, nVal);
}

void main()
{

	// Prevent resting again before time change has even changed.		
	if (GetGlobalInt(VAR_N2_RESTSYS_IN_PROGRESS) == 1)
	{
		PrettyDebug("Can't rest again, system currently in progress.");
		return;
	}		
	RestSysSet(1);
	DelayCommand(RS_TIME_CHANGE_DELAY, RestSysSet(0));
	
	
	object oPC = (GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());
	int nState = GetLocalInt(oPC, VAR_REST_CHOICE);
	PrettyDebug ("The Rest State is: " + IntToString(nState));

	// is a party member in conversation at the moment?
	if(GetIsFactionMemberInConversation(oPC))
	{
		SendMessageToPCByStrRef(OBJECT_SELF, STR_REF_MEMBER_IN_CONVERSATION);
		return;
	}

	if (GetIsSoZ())
	{
		if(nState == 0) // rest
		{
				int bUseForceRest = GetGlobalInt(CAMPAIGN_SWITCH_REST_SYS_USE_FORCE_REST);
				DoWholePartyRest(oPC, bUseForceRest);
		}	
			
		else if (nState == 1)	//Wait
		{
			int nSetHour;
			if (GetIsNight() || GetIsDusk())
			{	// wait until dawn
				nSetHour = GetDawnHour();
			}
			else
			{ 	// wait until dusk
				nSetHour = GetDuskHour();
			}
				
			DoWholePartyWait(oPC, nSetHour);
	
		}					
	}
	else
	{
		NX1TimePassPrep(oPC);
	
		switch (nState)
		{
			case 0: // rest
			{
				int bUseForceRest = GetGlobalInt(CAMPAIGN_SWITCH_REST_SYS_USE_FORCE_REST);
				DoWholePartyRest(oPC, bUseForceRest);
				break;
			}
	
			case 1:	// Wait
			{
				int nSetHour;
				if (GetIsNight() || GetIsDusk())
				{	// wait until dawn
					nSetHour = GetDawnHour();
				}
				else
				{ 	// wait until dusk
					nSetHour = GetDuskHour();
				}
	
				DoWholePartyWait(oPC, nSetHour);
				break;
			}
	
			default: // unknown
				PrettyDebug ("no known way this could happen.");
				break;
		}
	}
}