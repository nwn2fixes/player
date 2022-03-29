//::///////////////////////////////////////////////////////////////////////////
//::
//::	3052a_cut_scar.nss
//::
//::	This file contains the cutscene actions for conversation 3052_cut_scar.
//::
//::///////////////////////////////////////////////////////////////////////////
//::
//::	Created by: Brian Fox & Constant Gaw
//::	Created on: 11/9/05
//::
//::///////////////////////////////////////////////////////////////////////////
#include "30_constants"
//#include "30_true_name_inc"
#include "ginc_companions"
#include "ginc_group"
#include "ginc_object"
#include "x0_i0_partywide"
#include "ginc_cutscene"
//::///////////////////////////////////////////////////////////////////////////

const string RR_SILVER_SWORD = "silver_sword";
const string TAG_SILVER_SWORD = "silver_sword";

const string REAVER_PARTY_NAME = "Reaver2Party";
const string REAVER_MINIONS = "Reaver2Minions";

//::///////////////////////////////////////////////////////////////////////////
void UnequipPC();
void DestroyDanan();
void SetWeaponsVisible();
void SetWeaponsInvisible();
void MoveCameraTracker3();
void HideCameraTracker1();
void HideCameraTracker2();
void HideCameraTracker3();
void HideCameraTracker4();
void HideCameraTracker5();
void ZhjaeveMovesToScar();
void PCMovesToScar();
void ZhjaeveSits();
void PCSits();
void SpawnSwordFragments();
void PCGlowsSoftly();
void PCGlowsBrightly();
void ShardsGlowSoftly();
void ShardsGlowBrightly();
void MoveCameraTracker5();
void DestroyShardPlaceable();
void PlayReforgingEffect();
void MoveCameraTracker2();
void FadeToWhite();
void CreateAndEquipSilverSwordOnPC();
void PCRaiseSilverSword();
void ZhjaeveStandsUp();
void MoveCameraTracker1();
void RevealReaver();
void ReaverEntersScene();
void MoveCameraTracker4();
void RevealShadows1();
void RevealShadows2();
void FlamesErupt();
void TurnReaverPartyHostile();
void DestroySilverShards();
void UseTrueName( string sTag );
void DestroyCameraMen();

//::///////////////////////////////////////////////////////////////////////////

void main( int nChoice )
{
	object oRegulator = GetTarget("3052_ip_controller");
	object oZhjaeve;

	switch( nChoice )
	{
		case 1:
			ActionPauseCutscene(1000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(1.0f));
			break;
			
		case 2:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			break;	
			
		case 3:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
			break;					
						
		case 4:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));		
			DestroyDanan();
			break;
			
		case 5:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));		
			MoveCameraTracker3();
			break;			
						
		case 6:
			//SetWeaponsVisible();
			UnequipPC();
			break;
			
		case 7:
			//SetWeaponsInvisible();
			break;
			
		case 8:
			HideCameraTracker3();
			break;
			
		case 10:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));
			ZhjaeveMovesToScar();
			break;
			
		case 12:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));
//			PCMovesToScar();
			ZhjaeveSits();			
			break;	
			
		case 15:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ZhjaeveSits();	
			break;		
			
		case 17:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			PCSits();
			break;	
			
		case 19:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));		
			DelayCommand(0.5f, SpawnSwordFragments());
			break;							
			
		case 20:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));
			ShardsGlowSoftly();
			MoveCameraTracker5();
			break;			

		case 25:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));		
			PCGlowsSoftly();
			HideCameraTracker5();
			break;							
			
		case 30:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));		
			ShardsGlowBrightly();
			PCGlowsBrightly();
			break;	
			
		case 31:
			DestroyShardPlaceable();
			break;
			
		case 32:
			ActionPauseCutscene(5000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(5.0f));		
			PlayReforgingEffect();
			break;	
			
		case 33:
			MoveCameraTracker2();
			break;
			
		case 34:			
			DelayCommand(4.5f, AssignCommand(oRegulator, FadeToWhite()));
			DelayCommand(5.0f, PCRaiseSilverSword());
			break;

		case 35:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));		
			DelayCommand(2.0f, CreateAndEquipSilverSwordOnPC());
			HideCameraTracker2();			
			break;			

		case 40:
			ActionPauseCutscene(3000, FALSE);		
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));	
//			PCRaiseSilverSword();			
			break;
			
		case 45:
			ActionPauseCutscene(2000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(2.0f));	
			ZhjaeveStandsUp();
			break;
			
		case 48:
			ActionPauseCutscene(4000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(4.0f));			
			MoveCameraTracker1();
			break;
			
		case 50:
			ActionPauseCutscene(3000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(3.0f));	
			HideCameraTracker1();					
			RevealReaver();
			break;			
	
		case 60:
			ActionPauseCutscene( PAUSE_TIME, FALSE );
			AssignCutsceneActionToObject( oRegulator, ReaverEntersScene() );
			break;

		case 70:
			ActionPauseCutscene(6000, FALSE);
			AssignCutsceneActionToObject(oRegulator, ActionWait(6.0f));	
			MoveCameraTracker4();					
			DelayCommand(1.0f, RevealShadows1());
			DelayCommand(4.0f, RevealShadows2());			
			break;	
			
		case 72:
			HideCameraTracker4();
			break;	
						
		case 75:
			FlamesErupt();
			break;	
	
		case 80:
			TurnReaverPartyHostile();
			break;	
			
		case 85:
			DestroyCameraMen();
			break;		

		case 90:
			//PrepReciterForTrueName( TAG_AMMON );
			break;			

		case 95:
			ActionPauseCutscene( PAUSE_TIME, FALSE );
			//AssignCutsceneActionToObject( oPC, KickstartReciterCastsTrueName(TAG_AMMON, TAG_REAVER_3052) );
			break;

		case 100:
			//PrepReciterForTrueName( TAG_ZHJAEVE );
			break;			
		
		case 105:
			ActionPauseCutscene( PAUSE_TIME, FALSE );
			//AssignCutsceneActionToObject( oPC, KickstartReciterCastsTrueName(TAG_ZHJAEVE, TAG_REAVER_3052) );
			break;
	
		case 110:
			DestroySilverShards();
			break;
		
		default:
			PrettyError( "Unhandled case (" + IntToString(nChoice) + ") in 3052a_cut_scar." );
			break;
	}
}

//::///////////////////////////////////////////////////////////////////////////

void PlayCustomAnimationWrapper(object oObject, string sAnimationName, int nLooping, float fSpeed)
{
	PlayCustomAnimation(oObject, sAnimationName, nLooping, fSpeed);
}

void SetWeaponsVisible()
{
	object oPC = GetFactionLeader(GetFirstPC());
	
	SetWeaponVisibility(oPC, 1, 0);
}

void SetWeaponsInvisible()
{
	object oPC = GetFactionLeader(GetFirstPC());
	
	SetWeaponVisibility(oPC, 0, 0);
}

void UnequipPC()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oWeaponItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);	
	object oWeaponItem2 = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);	

	AssignCommand(oPC, ClearAllActions());
	AssignCommand(oPC, ActionUnequipItem(oWeaponItem));
	AssignCommand(oPC, ActionUnequipItem(oWeaponItem2));
	
	int i = 0;
	object oItem = GetFirstItemInInventory(oPC);
	object oDropItem1;
	
	while (GetIsObjectValid(oItem) == TRUE)
	{
		i = i + 1;
		
		oItem = GetNextItemInInventory(oPC);
	}
	
	if (i >= 127)
	{
		oDropItem1 = GetFirstItemInInventory(oPC);		
		AssignCommand(oPC, ActionPutDownItem(oDropItem1));	
	}
}

void DestroyDanan()
{
	object oDanan = GetNearestObjectByTag("3052_starling");
	object oRetta = GetNearestObjectByTag("3052_retta");
	object oShadowDanan = GetNearestObjectByTag("3052_shadow_danan");
	object oShadowRetta = GetNearestObjectByTag("3052_greater_shadow_retta");	
	
	DestroyObject(oDanan);	
	DestroyObject(oRetta);
	DestroyObject(oShadowDanan);
	DestroyObject(oShadowRetta);
}

void MoveCameraTracker3()
{
	object oTracker = GetTarget("3052_camera_tracker3");
	object oWP = GetTarget("3052_wp_tracker3");
	
	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void HideCameraTracker1()
{
	object oTracker = GetTarget("3052_camera_tracker1");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker2()
{
	object oTracker = GetTarget("3052_camera_tracker2");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker3()
{
	object oTracker = GetTarget("3052_camera_tracker3");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker4()
{
	object oTracker = GetTarget("3052_camera_tracker4");
	SetScriptHidden(oTracker, TRUE);
}

void HideCameraTracker5()
{
	object oTracker = GetTarget("3052_camera_tracker5");
	SetScriptHidden(oTracker, TRUE);
}

void ZhjaeveMovesToScar()
{
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	object oWP = GetTarget("3052_wp_zhjaeve_sit");

	AssignCommand(oZhjaeve, ActionForceMoveToObject(oWP, FALSE));	
}

void PCMovesToScar()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oWP = GetTarget("3052_wp_pc_sit");

	AssignCommand(oPC, ClearAllActions(TRUE));
	AssignCommand(oPC, ActionForceMoveToObject(oWP, FALSE));	
}

void ZhjaeveSits()
{
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	object oPC = GetFactionLeader(GetFirstPC());
	object oWP = GetTarget("3052_wp_pc_sit");	

	DelayCommand(1.0f, AssignCommand(oZhjaeve, PlayCustomAnimationWrapper(oZhjaeve, "sitgroundidle", 1, 1.0f)));
	AssignCommand(oPC, ActionForceMoveToObject(oWP, FALSE, 0.0f));		
}

void PCSits()
{
	object oPC = GetFactionLeader(GetFirstPC());
	
	DelayCommand(1.0f, AssignCommand(oPC, PlayCustomAnimationWrapper(oPC, "sitgroundidle", 1, 1.0f)));		
}	

void SpawnSwordFragments()
{
	string sSwordRR = "3052_plc_brokenswd";
	string sNewTag = "3052_ss_fragments";
	object oWP = GetTarget("3052_wp_ssplaceable");
	location lLocation = GetLocation(oWP);
	
	CreateObject(OBJECT_TYPE_PLACEABLE, sSwordRR, lLocation, FALSE, sNewTag);
}

void PCGlowsSoftly()
{
	object oPC = GetFactionLeader(GetFirstPC());
	effect eGlow = EffectNWN2SpecialEffectFile("fx_shard_rip.sef");
	
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oPC, 15.0f);
}

void PCGlowsBrightly()
{
	object oPC = GetFactionLeader(GetFirstPC());
	location lPC = GetLocation(oPC);
	effect eGlow = EffectNWN2SpecialEffectFile("fx_glowstone_blue_p.sef");
	
//	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oPC, 5.0f);
	ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eGlow, lPC, 5.0f);	
}

void ShardsGlowSoftly()
{
	object oShards = GetTarget("3052_ss_fragments");
	effect eGlow = EffectNWN2SpecialEffectFile("fx_shard_rip.sef");
	
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oShards, 5.0f);
}

void ShardsGlowBrightly()
{
	object oShards = GetTarget("3052_ss_fragments");
	effect eGlow = EffectNWN2SpecialEffectFile("3052_fx_shard_glow.sef");
	
	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eGlow, oShards, 10.0f);
}

void MoveCameraTracker5()
{
	object oTracker = GetTarget("3052_camera_tracker5");
	object oWP = GetTarget("3052_wp_tracker5");
	
	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void DestroyShardPlaceable()
{
	object oShards = GetTarget("3052_ss_fragments");
	
	DestroyObject(oShards);
}

void PlayReforgingEffect()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oWP = GetTarget("3052_wp_scar");
	object oSword;
	object oSound = GetTarget("3052_snd_sword_forge");
	location lLocation = GetLocation(oWP);

	effect eShards = EffectNWN2SpecialEffectFile("3052_fx_silversword_reform.sef");
	effect ePC = EffectNWN2SpecialEffectFile("fx_silversword_fx.sef");

	oSword = CreateObject(OBJECT_TYPE_PLACED_EFFECT, "fx_silversword_reform", lLocation);
	DelayCommand(0.5f, SoundObjectPlay(oSound));
//	ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePC, oPC, 6.0f);
//	ApplyEffectToObject(DURATION_TYPE_INSTANT, eShards, oPC);
	DelayCommand(6.0f, DestroyObject(oSword));
}

void MoveCameraTracker2()
{
	object oTracker = GetTarget("3052_camera_tracker2");
	object oWP = GetTarget("3052_wp_tracker2");
	
	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void FadeToWhite()
{
	object oPC = GetFirstPC();
	object oPCFacMem = GetFirstFactionMember(oPC);	
	float fFadeSpeed = 1.0f;
	float fSafeDelay = 10.0f;
	int nColor = 16777215;
	
	while(GetIsObjectValid(oPCFacMem))
    {
		FadeToBlack(oPCFacMem, fFadeSpeed, fSafeDelay, nColor);
		
        oPCFacMem = GetNextFactionMember(oPC);
    } 
}
	
void CreateAndEquipSilverSwordOnPC()
{
	object oPC = GetFactionLeader(GetFirstPC());
	object oSilverSword = CreateItemOnObject( RR_SILVER_SWORD, oPC );
	
	AssignCommand( oPC, ActionEquipItem(oSilverSword, INVENTORY_SLOT_RIGHTHAND) );		
}

void PCRaiseSilverSword()
{
	object oPC = GetFactionLeader( GetFirstPC() );

	PlayCustomAnimationWrapper(oPC, "%", 1, 1.0f);
	PlayCustomAnimationWrapper(oPC, "liftswordloop", 1, 0.5f);	
//	AssignCutsceneActionToObject( oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY1) );	
	// TODO: replace animation constant with final animation when available
}

void ZhjaeveStandsUp()
{
	object oPC = GetFactionLeader( GetFirstPC() );
	object oZhjaeve = GetTarget(TAG_ZHJAEVE);
	
	AssignCommand(oZhjaeve, ClearAllActions(TRUE));
//	AssignCommand(oZhjaeve, ActionPlayAnimation(ANIMATION_FIREFORGET_SALUTE));	
	AssignCommand(oZhjaeve, PlayCustomAnimationWrapper(oZhjaeve, "%", 1, 1.0f));
	PlayCustomAnimationWrapper(oPC, "%", 1, 1.0f);
}

void MoveCameraTracker1()
{
	object oTracker = GetTarget("3052_camera_tracker1");
	object oWP = GetTarget("3052_wp_tracker1");
	
	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}

void RevealReaver()
{
	effect eFlash = EffectNWN2SpecialEffectFile("fx_garius_ritual.sef");
	int i;		
	object oBGolem;
	object oFElemen;	

	object oReaver = GetTarget( TAG_REAVER_3052 );
	SetScriptHidden( oReaver, FALSE );
	ApplyEffectToObject(DURATION_TYPE_INSTANT, eFlash, oReaver);
	
	ResetGroup( REAVER_PARTY_NAME );
	
	GroupAddMember( REAVER_PARTY_NAME, oReaver );	
		
	for (i = 1; i <=3; i++)
	{

		oFElemen = GetTarget("3052_felemen" + IntToString(i));
		SetScriptHidden(oFElemen, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, oFElemen, FALSE);

	}

	i = 1;
	
	for (i = 1; i <=2; i++)
	{
		oBGolem = GetTarget("3052_bgolem" + IntToString(i));
		SetScriptHidden(oBGolem, FALSE);
		GroupAddMember(REAVER_PARTY_NAME, oBGolem, FALSE);
	}	
}

void ReaverEntersScene()
{
	object oReaver = GetTarget( TAG_REAVER_3052 );

	AssignCutsceneActionToObject( oReaver, ActionForceMoveToObject(GetPCSpeaker()) );	
}

void MoveCameraTracker4()
{
	object oTracker = GetTarget("3052_camera_tracker4");
	object oWP = GetTarget("3052_wp_tracker4");
	
	AssignCommand(oTracker, ClearAllActions(TRUE));
	AssignCommand(oTracker, ActionForceMoveToObject(oWP, FALSE));
}
	
void RevealShadows1()
{
	object oPC = GetFactionLeader( GetFirstPC() );
	int i;
//	object oShadow = GetNearestObjectByTag( TAG_SHADOW_3052, oPC, i );
	object oShadow = GetNearestObjectByTag( "3052_reaver_shadow", oPC, i );
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless.sef");
	
	for (i = 1; i <= 2; i++)
	{
		oShadow = GetTarget("3052_reaver_shadow" + IntToString(i));	
		SetScriptHidden( oShadow, FALSE );
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.0f);
		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void RevealShadows2()
{
	object oPC = GetFactionLeader( GetFirstPC() );
	int i;
//	object oShadow = GetNearestObjectByTag( TAG_SHADOW_3052, oPC, i );
	object oShadow = GetNearestObjectByTag( "3052_reaver_shadow", oPC, i );
	effect ePoof = EffectNWN2SpecialEffectFile("sp_bless.sef");
	
	for (i = 3; i <= 4; i++)
	{
		oShadow = GetTarget("3052_reaver_shadow" + IntToString(i));	
		SetScriptHidden( oShadow, FALSE );
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ePoof, oShadow, 1.0f);
		GroupAddMember(REAVER_MINIONS, oShadow);
	}
}

void FlamesErupt()
{
	object o3052 = GetObjectByTag("3052_wharbor");
	object oWP;
	object oEntranceSound = GetTarget("3052_snd_reaver_entrance");
	object oFire1 = GetTarget("3052_snd_fire_smolder_scar");
	object oFire2 = GetTarget("3052_snd_fire_large_scar");
	int i;
	location lLoc;
	string sNewTag;
	string sTemplate;
	
	for (i = 1; i <= 13; i++)
	{
		oWP = GetNearestObjectByTag("3052_wp_reaverfire" + IntToString(i));
		lLoc = GetLocation(oWP);
		sNewTag = "3052_reaverfire" + IntToString(i);
		sTemplate = "n2_fx_fire_lg";
		CreateObject(OBJECT_TYPE_PLACED_EFFECT, sTemplate, lLoc, FALSE, sNewTag);
	}
	
	SetLocalInt(o3052, "ReaverFlamesOn", 1);
	
	SoundObjectPlay(oEntranceSound);
	SoundObjectPlay(oFire1);
	SoundObjectPlay(oFire2);
	MusicBackgroundStop(o3052);
}

void TurnReaverPartyHostile()
{
	GroupChangeToStandardFaction( REAVER_PARTY_NAME, STANDARD_FACTION_HOSTILE );
	GroupChangeToStandardFaction( REAVER_MINIONS, STANDARD_FACTION_HOSTILE );	
	GroupDetermineCombatRound(REAVER_PARTY_NAME);
	GroupDetermineCombatRound(REAVER_MINIONS);	
}
	
void DestroySilverShards()
{
	object oPC = GetFirstPC();
	object oCompanion;
	string sShardTagPrefix = "nwn2_it_shard";
	int nCounter = 0;
	object oShard;
	string sRosterName;
	string sShardTag;
	int bShardFound;

	while (nCounter < 9 )
	{
		bShardFound = FALSE;
	
		sShardTag = sShardTagPrefix + IntToString( nCounter );
		oShard = GetTarget( sShardTag );	// check the module first
	
		if ( GetIsObjectValid(oShard) )		// we found it in the module (outside of inventory)
		{
			bShardFound = TRUE;
			DelayCommand( 0.1f, DestroyObject(oShard) );
		}
		else
		{
			// let's iterate through the roster members and check their inventory
			sRosterName = GetFirstRosterMember();
			while ( sRosterName != "" )
			{
				oCompanion = GetTarget( sRosterName );
				oShard = GetItemPossessedBy( oCompanion, sShardTag );
				
				if ( GetIsObjectValid(oShard) )	// we found it in the roster member's inventory
				{
					bShardFound = TRUE;
					DelayCommand( 0.1f, DestroyObject(oShard) );
				}
	
				sRosterName = GetNextRosterMember();
			}
		}
		
		if ( bShardFound = FALSE )	// if we STILL haven't found it, just remove it from the party PCs
		{
			RemoveItemFromParty( oPC, sShardTag );	// this will cover the PCs in the party; last resort but most likely outcome
		}

		nCounter++;
	}	
}
	
// Helper function for UseTrueName
void CastTrueName( object oTarget )
{
	ClearAllActions( TRUE );
	ActionCastSpellAtObject(SPELL_TRUE_NAME, oTarget, METAMAGIC_NONE, TRUE);
}

void UseTrueName( string sTag )
{
	object oReciter = GetTarget( sTag );
	object oReaver = GetTarget( TAG_REAVER_3050 );
	/*
	location lReaver = GetLocation( oReaver );
	object oTrueNameScroll = GetItemPossessedBy( oReciter, TAG_TRUE_NAME_SCROLL );
	event eActivateTrueNameScroll = EventActivateItem( oTrueNameScroll, lReaver, oReaver );
	*/
	
	//SignalEvent( oReciter, eActivateTrueNameScroll );
	
	AssignCommand( oReciter, CastTrueName(oReaver) );
}	

void DestroyCameraMen()
{
	object oCameraMan;
	int i;
	
	for (i = 1; i <= 5; i++)
	{
		oCameraMan = GetTarget("3052_camera_tracker" + IntToString(i));
		DestroyObject(oCameraMan);
	}
}
	
	