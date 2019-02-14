// ginc_effect
/*
	Effects related constants and functions

	Note that many of these effects are temporary.  I would not count on the SP_ effects
	and TESTSEF effects in particular to persist until ship time, so keep that in mind. -EPF

*/
// ChazM 10/03/05	
// EPF 10/3/05
// ChazM 10/03/05 added CreateBeam(), VoidCreateBeam(), changed include file
// ChazM 10/04/05 added Note on SEF's and the nBodyPart param
// BMA-OEI 7/04/06 -- Added GetHasEffectType(), RemoveEffectByType()
// ChazM 6/22/07 -- Added Subtype supprot to GetHasEffectType(), RemoveEffectByType()
// Aqvilinus 2019.feb.14 - CreateBeam() pass 'bMissEffect' into EffectBeam()

#include "ginc_param_const"

//void main (){}
	
//For reference, here are the prototypes for the related functions in nwscript.nss:
/*
//RWT-OEI 05/31/05
//This function creates a Special Effects File effect that can
//then be applied to an object or a location
//For effects that just need a single location (or source object),
//such as particle emitters, the source loc or object comes from
//using AttachEffectToObject and AttachEffectToLocation
//For Point-to-Point effects, like beams and lightning, oTarget
//is the target object for the other end of the effect. If oTarget
//is OBJECT_INVALID, then the position located in vTargetPosition
//is used instead. 
effect EffectNWN2SpecialEffectFile( string sFileName, object oTarget=OBJECT_INVALID, vector vTargetPosition=[0.0,0.0,0.0]  );

	
//RWT-OEI 06/07/05
//This function removes 1 instance of a SEF from an object. Since
//an object can only have 1 instance of a specific SEF running on it
//at once, this should effectively remove 'all' instances of the
//specified SEF from the object
void RemoveSEFFromObject( object oObject, string sSEFName );
*/

/*
Note on SEF's and the nBodyPart param:
The nBodyPart piece has been moved to the .SEF file.  
The SEF file can be used to specify which attachment points the beam should
connect to on both the source and the target. 
*/	
	
//Durations below this number specified in the effect applying functions will be treated as 0,
//which we take to mean you want to apply an effect permanently
const float MY_EPSILON = 0.001;

const string BLOODSPURT		= "bloodspurt.sef";
const string FX_ALTARGEN 	= "fx_altargen.sef";
const string FX_BLACK_COULD	= "fx_black_cloud.sef";
const string FX_CANDLE		= "fx_candle.sef";
const string FX_DUST 		= "fx_dust.sef";
const string FX_FIREFLIES	= "fx_fireflies.sef";
const string FX_FIREPLACE	= "fx_fireplace.sef";
const string FX_FIRE_LG		= "fx_fire_lg.sef";
const string FX_FIRE_LG_BLUR	= "fx_fire_lg_blur.sef";
const string FX_FIRE_SMOKE	= "fx_fire_smoke.sef";
const string FX_FOG_LG		= "fx_fog_lg.sef";
const string FX_LAMPGLOW	= "fx_lampglow.sef";
const string FX_LOOTBAG		= "fx_lootbag.sef";
const string FX_SPLASH		= "fx_splash.sef";
const string FX_SPLASH2		= "fx_splash2.sef";
const string FX_TORCH_BLUE	= "fx_torch_blue.sef";
const string FX_TORCHGLOW	= "fx_torchglow.sef";
const string FX_VOID		= "fx_void.sef";
const string SP_ATK_MISSILE	= "sp_atk_missile.sef";
const string SP_BLESS		= "sp_bless.sef";
const string SP_CURE_CRITICAL	= "sp_cure_critical.sef";
const string SP_CURE_LIGHT	= "sp_cure_light.sef";
const string SP_FIREBALL	= "sp_fireball.sef";
const string SP_MAGICMISSILE = "sp_magicmissile.sef";
const string SP_RAYFROST	= "sp_rayfrost.sef";



//** FUNCTION DECLARATIONS ** 

// SEF effect functions
//** For all below functions, Duration of 0 means effect is permanent. **
void ApplySEFToLocation(string sEffectFile, location lLoc, float fDuration = 0.f);
void ApplySEFToObject(string sEffectFile, object oTarget, float fDuration = 0.f);
void ApplySEFToObjectByTag(string sEffectFile, string sTag, float fDuration = 0.f);
void ApplySEFToWP(string sEffectFile, string sWPTag, float fDuration = 0.f);

//SEF goes to all WPs of tag sWPTag
void ApplySEFToWPs(string sEffectFile, string sWPTag, float fDuration = 0.f);
void RemoveSEFFromWP(string sEffectFile, string sWPTag );

//SEF removed from all WPs of tag sWPTag
void RemoveSEFFromWPs(string sEffectFile, string sWPTag );

// Other effect functions
effect CreateBeam(int iBeamVisualEffect, object oSource, object oTarget, int nDurationType=DURATION_TYPE_PERMANENT, 
		float fDuration = 0.0f, int nBodyPart = BODY_NODE_CHEST, int bMissEffect = FALSE);
void VoidCreateBeam(int iBeamVisualEffect, object oSource, object oTarget, int nDurationType=DURATION_TYPE_PERMANENT,
        float fDuration = 0.0f, int nBodyPart = BODY_NODE_CHEST, int bMissEffect = FALSE);
		
// Return TRUE, if oObject is affected by effect type nEffectType
//int GetHasEffectType( object oObject, int nEffectType );
int GetHasEffectType( object oObject, int nEffectType, int nEffectSubType=0 );

// Removes all effects from oObject matching effect type nEffectType
// Returns number of matching effects removed
//int RemoveEffectsByType( object oObject, int nEffectType );
int RemoveEffectsByType( object oObject, int nEffectType, int nEffectSubType=0 );



void ApplySEFToLocation(string sEffectFile, location lLoc, float fDuration = 0.f)
{
	if(fDuration < MY_EPSILON)
	{
		ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile(sEffectFile), lLoc);
	}
	else
	{
		ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile(sEffectFile), lLoc, fDuration);
	}
}

void ApplySEFToObject(string sEffectFile, object oTarget, float fDuration = 0.f)
{
	if(fDuration < MY_EPSILON)
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile(sEffectFile), oTarget);
	}
	else
	{
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile(sEffectFile), oTarget, fDuration);
	}
}
	
void ApplySEFToObjectByTag(string sEffectFile, string sTag, float fDuration = 0.f)
{
	if(fDuration < MY_EPSILON)
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sTag));
	}
	else
	{
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sTag), fDuration);
	}
}

void ApplySEFToWP(string sEffectFile, string sWPTag, float fDuration = 0.f)
{
	if(fDuration < MY_EPSILON)
	{
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sWPTag));
	}
	else
	{
		ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sWPTag), fDuration);
	}
}

void ApplySEFToWPs(string sEffectFile, string sWPTag, float fDuration = 0.f)
{
	object oWP = GetObjectByTag(sWPTag);
	int i = 1;

	while(GetIsObjectValid(oWP))
	{
		if(fDuration < MY_EPSILON)
		{
			ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sWPTag));
		}
		else
		{
			ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectNWN2SpecialEffectFile(sEffectFile), GetTarget(sWPTag), fDuration);
		}
		oWP = GetObjectByTag(sWPTag,i);
		i++;
	}
}



void RemoveSEFFromWP(string sEffectFile, string sWPTag )
{
	RemoveSEFFromObject( GetTarget(sWPTag), sEffectFile );
}


void RemoveSEFFromWPs(string sEffectFile, string sWPTag )
{
	object oWP = GetObjectByTag(sWPTag);
	int i = 1;

	while(GetIsObjectValid(oWP))
	{
		RemoveSEFFromObject(oWP, sEffectFile);
		oWP = GetObjectByTag(sWPTag,i);
		i++;
	}
}


// create a beam between two objects
effect CreateBeam(int iBeamVisualEffect, object oSource, object oTarget, int nDurationType=DURATION_TYPE_PERMANENT, 
		float fDuration = 0.0f, int nBodyPart = BODY_NODE_CHEST, int bMissEffect = FALSE)
{
    effect eBeam = EffectBeam(iBeamVisualEffect, oSource, nBodyPart, bMissEffect); // fix_Aqvilinus
    ApplyEffectToObject(nDurationType, eBeam, oTarget, fDuration);
	return (eBeam);
}

void VoidCreateBeam(int iBeamVisualEffect, object oSource, object oTarget, int nDurationType=DURATION_TYPE_PERMANENT,
        float fDuration = 0.0f, int nBodyPart = BODY_NODE_CHEST, int bMissEffect = FALSE)
{
    CreateBeam(iBeamVisualEffect, oSource, oTarget, nDurationType,
         fDuration, nBodyPart, bMissEffect);
}

// Return TRUE, if oObject is affected by effect type nEffectType
// Effects of a specific subtype can be specified, or 0 to ignore subtype
int GetHasEffectType( object oObject, int nEffectType, int nEffectSubType=0 )
{
	effect eEffect = GetFirstEffect( oObject );
	while ( GetIsEffectValid(eEffect) == TRUE )
	{
		if ( GetEffectType(eEffect) == nEffectType )
		{
			if ((nEffectSubType == 0)  || (GetEffectSubType(eEffect) == nEffectSubType))
				return ( TRUE );
		}
		eEffect = GetNextEffect( oObject );
	} 
	
	return ( FALSE );
}

// Removes all effects from oObject matching effect type nEffectType
// Returns number of matching effects removed
// Effects of a specific subtype can be specified, or 0 to ignore subtype
int RemoveEffectsByType( object oObject, int nEffectType, int nEffectSubType=0 )
{
	int nCount = 0;
	effect eEffect = GetFirstEffect( oObject );
	while ( GetIsEffectValid(eEffect) == TRUE )
	{
		if ( GetEffectType(eEffect) == nEffectType )
		{
			if ((nEffectSubType == 0)  || (GetEffectSubType(eEffect) == nEffectSubType))
			{
				nCount = nCount + 1;
				RemoveEffect( oObject, eEffect );
			}				
			// eEffect = GetFirstEffect( oObject );
		}
		else
		{
			// eEffect = GetNextEffect( oObject );
		}
		eEffect = GetNextEffect( oObject );
	}
	
	return ( nCount );
}

