// 'gui_rest'
/*
	Do rest or wait action based on what is selected in the Rest GUI.
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
// kevL's 2020.03.07 - refactor this mess so I can read it.
// kevL's 2020.03.08 - refactor harder
//                   - pass AmbushType from PartyForceRest() to PartyRest()
//                   - pass AmbushType from PartyRest() to PlayerRest()
//                   - delete redundant reset of "se_has_used_devour_ability" from PartyForceRest()
//                     and add relevant check for no Ambush in PartyRest()
//                   - define PC as OwnedCharacter of OBJECT_SELF
//                   - send messages to the controlled character(s)
//                   - do not prevent rest if a nearby hostile is scripthidden


/*******************************************************************************
 * INCLUDES
 */

#include "ginc_restsys"
#include "ginc_time"
#include "kinc_spirit_eater"	// for global version (in /Data)
//#include "ginc_overland"		// for    SoZ version (in /Campaign_X2)
//#include "ginc_overland_ai"	// for    SoZ version (in /Campaign_X2)


/*******************************************************************************
 * CONSTANTS
 */

const int STR_REF_MONSTER_INTERRUPT      = 207061; // "A nearby enemy has interrupted your rest."
const int STR_REF_MEMBER_IN_CONVERSATION = 208545; // "You cannot rest while a party member is in conversation."
const int STR_REF_HOURS_PASSED           = 186225; // " hours have passed."
const int STR_REF_1_HOUR_PASSED          = 186226; // "1 hour has passed."

const float RS_TIME_CHANGE_DELAY = 1.0f; // amount of time to wait until doing the time set
const float RS_AFTER_TIME_CHANGE = 5.0f; // a value somewhat greater than TIME_CHANGE_DELAY

const int RS_STANDARD_REST_HOURS = 8;    // hours in a standard rest
const float RS_REST_BAR_SECONDS  = 5.0f; // seconds the engine makes the restbar last

const string VAR_N2_RESTSYS_IN_PROGRESS = "N2_RESTSYS_IN_PROGRESS";

const float FADE_SPEED_INSTANT = 0.0f;

const float DIST_ABORT_HOSTILE     = 43.0f;
const float DIST_ABORT_HOSTILE_SOZ =  5.0f;


/*******************************************************************************
 * FUNCTION DEFINITIONS
 */

/**
 * Helper functions
 */

//
void RestKillBleedingOut(object oPc)
{
	effect eDeath = EffectDeath(FALSE, FALSE, TRUE, TRUE);

	object oParty = GetFirstFactionMember(oPc, FALSE);
	while (GetIsObjectValid(oParty))
	{
		effect eEffect = GetFirstEffect(oParty);
		while (GetIsEffectValid(eEffect))
		{
			if (GetEffectType(eEffect) == EFFECT_TYPE_HITPOINT_CHANGE_WHEN_DYING
				&& GetEffectInteger(eEffect, 0) == 0) // JWR-OEI - make sure they haven't been stabilized.
			{
				ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oParty);

				break; // kL_add: It only needs to die once.
			}
			eEffect = GetNextEffect(oPc);
		}
		oParty = GetNextFactionMember(oPc, FALSE);
	}
}

/* SoZ funct. is same as MotB 'kinc_spirit_eater' funct.
int GetIsFactionMemberInConversation(object oMemberOfFaction, int bPCOnly = TRUE)
{
	object oPartyMember = GetFirstFactionMember(oMemberOfFaction, bPCOnly);
	while (GetIsObjectValid(oPartyMember))
	{
		if (IsInConversation(oPartyMember))
			return TRUE;

		oPartyMember = GetNextFactionMember(oMemberOfFaction, bPCOnly);
	}
	return FALSE;
} */


/**
 * Player RestSystem functions
 */

// This will flip the var on for doing a rest, do a rest, and then flip it back off.
// - OBJECT_SELF is a player-controlled-character
void Rest()
{
	object oPcc = OBJECT_SELF;

	RestSendMessage(oPcc, STR_REF_REST_STARTED);

	SetLocalInt(oPcc, VAR_REST_NOW,           TRUE); // OnPlayerRest event will allow rest and then reset back to FALSE
	SetLocalInt(oPcc, VAR_REST_REPORT_CANCEL, TRUE); // OnPlayerRest event will report a cancel if this is true

	// This will actually cause resting since the global is cleared for the moment.
	// - delayed for a split second to prevent the event from firing while paused
	DelayCommand(0.1f, ActionRest()); // <-- HERE IT IS

	// Setting this back immediately doesn't give the rest enough time to occur so delay it.
	// - this needs to finish before doing the time set so it needs to be < TIME_CHANGE_DELAY
	DelayCommand(0.5f, SetLocalInt(oPcc, VAR_REST_NOW, FALSE)); // reset Flag for next time player hits the rest-button

	// allow reporting of cancel for duration of rest
	DelayCommand(5.5f, SetLocalInt(oPcc, VAR_REST_REPORT_CANCEL, FALSE));
}

// This function is set to run when the time change occurs - thus these delays
// are all relative to the new time.
// - OBJECT_SELF is a player-controlled-character
void PlayerRestFinish(int iHours, int bWaitOnly, int iAmbushType)
{
	object oPcc = OBJECT_SELF;

	FadeToBlack(oPcc, FADE_SPEED_INSTANT); // try to go to black immediately

	if (!bWaitOnly)
	{
		ClearAllActions();
		Rest();

		switch (iAmbushType)
		{
			case WM_CHECK_NO_AMBUSH:
				// Players might start moving their characters before they finish
				// resting. Since there was no ambush ensure they get a full rest.
				ActionDoCommand(ForceRest(oPcc)); // <-- HERE IT IS
				break;

			case WM_CHECK_AMBUSH: // wake early
			{
				float fDelay = IntToFloat(iHours) / IntToFloat(RS_STANDARD_REST_HOURS) * RS_REST_BAR_SECONDS;
				DelayCommand(fDelay, ClearAllActions());
				break;
			}
		}
	}

	DelayCommand(1.0f, FadeFromBlack(oPcc, FADE_SPEED_SLOWEST)); // 3 sec fade-in

	string sText;
	if (iHours == 1)
		sText = GetStringByStrRef(STR_REF_1_HOUR_PASSED);
	else
		sText = IntToString(iHours) + GetStringByStrRef(STR_REF_HOURS_PASSED);

	DelayCommand(4.0f, FloatingTextStringOnCreature(sText, oPcc, FALSE));
}

// - OBJECT_SELF is a player-controlled-character
void PlayerRest(int iHours, int bWaitOnly, int iAmbushType)
{
	if (!bWaitOnly)
	{
		// kneel before we fade out so it looks like a rest.
		// (trying to do a second rest causes problems, so can't have rest bar up while starting out rest).
		ActionPlayAnimation(ANIMATION_LOOPING_KNEELIDLE, 1.0f, RS_TIME_CHANGE_DELAY);
	}

	// delay by a tiny amount so that if paused when the rest-button is pressed
	// it waits until unpaused before the fade-out
	DelayCommand(0.01f, FadeToBlack(OBJECT_SELF, RS_TIME_CHANGE_DELAY));

	// this will fire just as soon after the time change (currently in 1 second).
	DelayCommand(RS_AFTER_TIME_CHANGE, PlayerRestFinish(iHours, bWaitOnly, iAmbushType));
}


/**
 * Party RestSystem functions
 */

//
void SetGlobalIntVoid(string sVar, int iVal)
{
	SetGlobalInt(sVar, iVal);
}

// This will cause the whole party to rest using ActionRest(). Standard resting
// encompasses several engine effects including resting over time, the countdown
// timer, the kneel animation, and it also fires off the module rest event for
// the player on start and on end.
// Params:
//  oTruePc     - players whose party is to rest
//  iHours      - used only for reporting to player
//  bWaitOnly   - FALSE = rest, TRUE = wait
//  iAmbushType - a partial resting benefit is gained even if there's an ambush
void PartyRest(object oTruePc, int iHours, int bWaitOnly, int iAmbushType)
{
	// kL_note: should be && GetIsMotB() but for some some reason they
	// wanted to reset "se_has_used_devour_ability" in the OC (etc) too.
	if (!bWaitOnly && iAmbushType == WM_CHECK_NO_AMBUSH && !GetIsSoZ())
	{
		DelayCommand(RS_AFTER_TIME_CHANGE, SetGlobalIntVoid("se_has_used_devour_ability", FALSE));
	}

	// only need to tell the TruePcs to rest - other party will follow suit
	// NOTE: GetFirstFactionMember() gets the Owned PC - need to make the controlled characters rest.
	// kL_note: Those are contradictory.
	object oPcc;
	object oPc = GetFirstFactionMember(oTruePc);
	while (GetIsObjectValid(oPc))
	{
		oPcc = GetControlledCharacter(oPc);
		AssignCommand(oPcc, PlayerRest(iHours, bWaitOnly, iAmbushType)); // iHours passed for reporting only

		oPc = GetNextFactionMember(oTruePc);
	}
}

// This will cause the whole party to rest using ForceRest(). It is otherwise
// similar to PartyRest().
// Params:
//  oTruePc     - players whose party is to rest
//  iHours      - used only for reporting to player
//  bWaitOnly   - FALSE = rest, TRUE = wait
//  iAmbushType - there's no resting benefit if there's an ambush
void PartyForceRest(object oTruePc, int iHours, int bWaitOnly, int iAmbushType)
{
	// get all the player clients to do the fade, message report, etc.
	PartyRest(oTruePc, iHours, TRUE, iAmbushType); // pass in bWaitOnly flag - the actual rest is handled below

	// Need to tell all party members to ForceRest - ForceResting a PC doesn't affect his followers.
	// - only do this if resting and not getting ambushed (no partial rests if ambushed)
	if (!bWaitOnly && iAmbushType == WM_CHECK_NO_AMBUSH)
	{
		object oParty = GetFirstFactionMember(oTruePc, FALSE);
		while (GetIsObjectValid(oParty))
		{
			DelayCommand(RS_AFTER_TIME_CHANGE, ForceRest(oParty)); // <-- HERE IT IS
			oParty = GetNextFactionMember(oTruePc, FALSE);
		}
	}
}

// Checks for an encounter and does a PartyRest.
//   oTruePc - player whose party is to rest
void StartPartyRest(object oTruePc)
{
	// if true the party will not use the regular rest-action and instead uses
	// ForceRest (this prevents the rest bar from appearing)
	int bForceRest = GetGlobalInt(CAMPAIGN_SWITCH_REST_SYS_USE_FORCE_REST);

	location lTruePc = GetLocation(oTruePc);

	if (!GetIsSoZ())
	{
		object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, DIST_ABORT_HOSTILE, lTruePc); // default is Creature
		while (GetIsObjectValid(oCreature))
		{
			if (!GetIsDead(oCreature)
				&& !GetScriptHidden(oCreature)
				&& GetIsReactionTypeHostile(oCreature)) // kL_note: Perhaps that's not the best function to use here.
			{
				SendMessageToPCByStrRef(GetControlledCharacter(oTruePc), STR_REF_MONSTER_INTERRUPT);
				return;
			}
			oCreature = GetNextObjectInShape(SHAPE_SPHERE, DIST_ABORT_HOSTILE, lTruePc);
		}

		// do Wandering Monster check
		int iAmbushType = SinglePartyWMRestEncounterCheck(oTruePc);

		int iHours;
		switch (iAmbushType)
		{
			case WM_CHECK_NO_AMBUSH:
				iHours = RS_STANDARD_REST_HOURS; // 8 hours pass
				break;

			case WM_CHECK_AMBUSH:
				iHours = d4(); // less than 8 hours pass
				break;
		}

		// Move time forward!
		// NOTE: When time changes it affects many things:
		// * sleep will have ended so it will essentially be interrupted
		// * delayed commands set to occur prior to the time change will all go off
		DelayCommand(RS_TIME_CHANGE_DELAY, SetCTimeDate(GetCurrentCTimeDate(0, 0, 0, iHours))); // Rest needs to occur after this


		if (bForceRest)
			PartyForceRest(oTruePc, iHours, FALSE, iAmbushType);
		else
			PartyRest(oTruePc, iHours, FALSE, iAmbushType);
	}
	else // is SoZ ->
	{
		object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, DIST_ABORT_HOSTILE_SOZ, lTruePc); // default is Creature
		while (GetIsObjectValid(oCreature))
		{
			if (GetLocalInt(oCreature, "bHostile"))
			{
				SendMessageToPCByStrRef(GetControlledCharacter(oTruePc), STR_REF_MONSTER_INTERRUPT);
				return;
			}
			oCreature = GetNextObjectInShape(SHAPE_SPHERE, DIST_ABORT_HOSTILE_SOZ, lTruePc);
		}


		oTruePc = GetFactionLeader(GetFirstPC());

		// do Wandering Monster check
		int iAmbushType = SinglePartyWMRestEncounterCheck(oTruePc);

		int iHours;
		switch (iAmbushType)
		{
			case WM_CHECK_NO_AMBUSH:
				iHours = RS_STANDARD_REST_HOURS; // 8 hours pass
				break;

			case WM_CHECK_AMBUSH:
				iHours = d4(); // less than 8 hours pass
				break;
		}

		if (GetHasFeat(FEAT_TW_GROUP_TRANCE, oTruePc, TRUE)) // Group Trance halves the amount of time required for the party to rest.
			iHours /= 2;

		// Move time forward!
		// NOTE: When time changes it affects many things:
		// * sleep will have ended so it will essentially be interrupted
		// * delayed commands set to occur prior to the time change will all go off
		DelayCommand(RS_TIME_CHANGE_DELAY, RestKillBleedingOut(oTruePc));
		DelayCommand(RS_TIME_CHANGE_DELAY, SetCTimeDate(GetCurrentCTimeDate(0, 0, 0, iHours))); // Rest needs to occur after this


		if (bForceRest)
			PartyForceRest(oTruePc, iHours, FALSE, iAmbushType);
		else
			PartyRest(oTruePc, iHours, FALSE, iAmbushType);
	}
}

// Party waits until iToHour.
void StartPartyWait(object oTruePc, int iToHour)
{
	int iHours = iToHour - GetTimeHour();
	if (iHours < 0)
		iHours += 24;

	if (GetIsSoZ())
		AssignCommand(oTruePc, ClearAllActions());

	DelayCommand(RS_TIME_CHANGE_DELAY, SetTime(iToHour, 0, 0, 0));
	PartyRest(oTruePc, iHours, TRUE, WM_CHECK_NO_AMBUSH); // just wait. you'll see ...
}


// Clears the rest-system-in-progress flag.
void ResetRestsys()
{
	SetGlobalInt(VAR_N2_RESTSYS_IN_PROGRESS, FALSE);
}


// *****************************************************************************
// MAIN (finally)
// *
void main()
{
	//SendMessageToPC(GetFirstPC(FALSE), "do GUI_REST ( " + GetName(OBJECT_SELF) + " )");

	if (!GetGlobalInt(VAR_N2_RESTSYS_IN_PROGRESS)) // disallow rest while resting
	{
		SetGlobalInt(VAR_N2_RESTSYS_IN_PROGRESS, TRUE);
		DelayCommand(RS_TIME_CHANGE_DELAY, ResetRestsys());


		object oTruePc = GetOwnedCharacter(GetPCSpeaker());
		if (!GetIsObjectValid(oTruePc))
			oTruePc = OBJECT_SELF;

		if (GetIsFactionMemberInConversation(oTruePc))
		{
			SendMessageToPCByStrRef(GetControlledCharacter(oTruePc), STR_REF_MEMBER_IN_CONVERSATION);
			return;
		}

		if (!GetIsSoZ())
		{
			// in MotB exit spiritbar-paused mode before moving time forward
			// - without doing this time passed shortly after a conversation
			//   would have no effect on Spirit Energy
			SpiritEaterConversationPauseCheck(oTruePc);
		}


		switch (GetLocalInt(oTruePc, VAR_REST_CHOICE))
		{
			case 0: // Rest
			{
				StartPartyRest(oTruePc);
				break;
			}

			case 1: // Wait
			{
				int iToHour;
				if (GetIsNight() || GetIsDusk())
				{
					iToHour = GetDawnHour();
				}
				else
					iToHour = GetDuskHour();

				StartPartyWait(oTruePc, iToHour);
				break;
			}
		}
	}
}
