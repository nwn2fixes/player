// nx_s2_shapers_alembic
/*
    The Shapers Alembic Spell Script

    Copyright (c) 2007 Obsidian Entertainment Inc.
*/
// ChazM OEI 3/14/07
// ChazM 7/3/07 - Changed Essence grade relation from 10 to 8; added some constants.
// ChazM 7/25/07 - Essence Groups more strictly defined to include element type as 
//					part of tag (prevents special essences from being improperly affected)

const int SPELL_SHAPERS_ALEMBIC         = 1097; 
const int SPELL_SHAPERS_ALEMBIC_DIVIDE  = 1098; 
const int SPELL_SHAPERS_ALEMBIC_COMBINE = 1099; 
const int SPELL_SHAPERS_ALEMBIC_CONVERT = 1100; 

const int ESSENCE_GROUP_INVALID			= 0;
// essence tag/resref parts
const int ESSENCE_GROUP1      			= 1;
const int ESSENCE_GROUP1_MAX_GRADE		= 4;
const int ESSENCE_GROUP1_GRADE_RELATION	= 2;
const string ESSENCE_GROUP1_PREFIX      = "cft_ess_";
const string ESSENCE_TYPE1_FIRE 		= "cft_ess_fire";
const string ESSENCE_TYPE1_WATER     	= "cft_ess_water";
const string ESSENCE_TYPE1_AIR 			= "cft_ess_air";
const string ESSENCE_TYPE1_EARTH 		= "cft_ess_earth";
const string ESSENCE_TYPE1_POWER		= "cft_ess_power";

const int ESSENCE_GROUP2      			= 2;
const int ESSENCE_GROUP2_MAX_GRADE		= 3;
const int ESSENCE_GROUP2_GRADE_RELATION	= 8;
const string ESSENCE_GROUP2_PREFIX      = "nx1_cft_ess_";
const string ESSENCE_TYPE2_FIRE 		= "nx1_cft_ess_fire0";
const string ESSENCE_TYPE2_WATER     	= "nx1_cft_ess_water0";
const string ESSENCE_TYPE2_AIR 			= "nx1_cft_ess_air0";
const string ESSENCE_TYPE2_EARTH 		= "nx1_cft_ess_earth0";
const string ESSENCE_TYPE2_POWER		= "nx1_cft_ess_power0";
const string ESSENCE_TYPE2_SPIRIT		= "nx1_cft_ess_spirit0";

const string ELEMENT_AIR                = "air";
const string ELEMENT_EARTH              = "earth";
const string ELEMENT_FIRE               = "fire";
const string ELEMENT_WATER              = "water";
const string ELEMENT_POWER              = "power";
const string ELEMENT_SPIRIT             = "spirit";

// errors
const int ERROR_ITEM_NOT_ESS                    = 186022; //"Target not an essence."
const int ERROR_ESS_CANT_DIVIDE                 = 186023; //"This essence can't be further divided."
const int ERROR_ESS_CANT_COMBINE                = 186024; //"This essence can't be further combined."
const int ERROR_ESS_INSUFFICIENT_TO_COMBINE     = 186025; //"Insufficient essences to combine."
const int ERROR_ESS_CANT_CONVERT_SPIRIT         = 186026; //"Can't convert spirit essences."
const int ERROR_ESS_CANT_CONVERT_LOW_GRADE      = 186027; //"Essence grade to low to convert."
const int ERROR_ESS_INSUFFICIENT_TO_CONVERT     = 186028; //"Insufficient essences to convert."

#include "x2_inc_spellhook"
#include "ginc_crafting"


int IsPrefixMatch(string sString, string sPrefix)
{
	int bRet = FALSE;
	if (FindSubString(sString, sPrefix) == 0)
		bRet = TRUE;
	return (bRet);
}

string GetEssenceResRef(int nGroup, string sElement, int nGrade)
{
    string sGroup;
    
    if (nGroup == ESSENCE_GROUP1)
    {
        sGroup = ESSENCE_GROUP1_PREFIX;
    }
    else if (nGroup == ESSENCE_GROUP2)
    {
        sGroup = ESSENCE_GROUP2_PREFIX;
        sElement = sElement + "0";
    }
    
    string sRet = sGroup + sElement + IntToString (nGrade);
    return (sRet);
}

// Essence Group 1 is the OC essences
int GetIsEssenceGroup1(object oTarget)
{
    //if (GetSubString(sTag,0, 8) == ESSENCE_GROUP1_PREFIX)
	//	return (TRUE);
	
	string sTag = GetTag(oTarget);
	
	if (IsPrefixMatch(sTag, ESSENCE_TYPE1_FIRE) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE1_WATER) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE1_AIR) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE1_EARTH) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE1_POWER) )
       	return (TRUE);

    return FALSE;        
}

// Essence Group 2 is the NX1 essence additions
int GetIsEssenceGroup2(object oTarget)
{
    //if (GetSubString(GetTag(oTarget),0, 12) == ESSENCE_GROUP2_PREFIX)
	//	return (TRUE);
	
	string sTag = GetTag(oTarget);
	
	if (IsPrefixMatch(sTag, ESSENCE_TYPE2_FIRE) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE2_WATER) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE2_AIR) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE2_EARTH) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE2_POWER) ||
		IsPrefixMatch(sTag, ESSENCE_TYPE2_SPIRIT))
       	return (TRUE);

    return FALSE;        
       
}


int GetEssenceGroup(object oEssence)
{
    int nRet = ESSENCE_GROUP_INVALID;
    if (GetIsEssenceGroup1(oEssence))
        nRet = ESSENCE_GROUP1;
    else if (GetIsEssenceGroup2(oEssence))
        nRet = ESSENCE_GROUP2;

    return (nRet);        
}        

// assumes oEssence is an essence
int GetEssenceGrade(object oEssence)
{
    string sTag = GetTag(oEssence);
    string sGrade = GetStringRight(sTag, 1);
    int iGrade = StringToInt(sGrade);
    return (iGrade);
}

string GetEssenceType(object oEssence)
{
    string sTag = GetTag(oEssence);
    int iLength = GetStringLength(sTag);
    string sType = GetStringLeft(sTag, iLength-1);
  
    return (sType);
}

void SetItemStackSizeOrDestroy(object oItem, int iRemainder)
{
    if (iRemainder == 0)
	    DestroyObject(oItem);
    else
        SetItemStackSize(oItem, iRemainder);                
}


// skill check for distillation    
int DoDistillationSkillCheck(int iSkillReq, object oPC=OBJECT_SELF)
{
	int iPCSkill = GetSkillRank(SKILL_CRAFT_ALCHEMY, oPC);		
	if (iPCSkill < iSkillReq)
	{	// has insufficient skill
   		ErrorNotify(oPC, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		return FALSE;
	}

    //ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_SELF), oPC);	
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_SELF), GetLocation(oPC));
	SuccessNotify(oPC);
    return TRUE;
}	

    
void CreateListOfItemsMultipleTimes(int iNumTimes, string sItemTemplateList, object oTarget, int bIdentify=TRUE)
{
	int i;
    for (i=1; i<= iNumTimes; i++)
	{
		CreateListOfItemsInInventory(sItemTemplateList, oTarget);
	}
}

int GetMaxGrade(int iGroup)
{
    int iMaxGrade=0;
    switch (iGroup) 
    {
        case 1: iMaxGrade = ESSENCE_GROUP1_MAX_GRADE;
                break;
                
        case 2: iMaxGrade = ESSENCE_GROUP2_MAX_GRADE;
                break;
    }
    return (iMaxGrade);
}

int GetGradeRelationship(int iGroup)
{
    int iGradeRelationship = 0;
    switch (iGroup) 
    {
        case 1: iGradeRelationship = ESSENCE_GROUP1_GRADE_RELATION;
                break;
                
        case 2: iGradeRelationship = ESSENCE_GROUP2_GRADE_RELATION;
                break;
    }
    return (iGradeRelationship);
}

// Divide the essences into lower value
int DivideEssences(object oEssence, object oCaster)
{
    int nGrade      = GetEssenceGrade(oEssence);
    string sType    = GetEssenceType(oEssence);
	int nStackSize  = GetItemStackSize(oEssence); // we can distill multiple objects at once.
    
    int nNewGrade   = nGrade -1;
    
    int nGroup = GetEssenceGroup(oEssence);
    int nGradeRelationship = GetGradeRelationship(nGroup);
    
    if (nGrade <= 1)
    {
        PrettyDebug("This Essence can't be further divided");
        ErrorNotify(oCaster, ERROR_ESS_CANT_DIVIDE);
        return FALSE;
    }
    
    int nNewStackSize = nStackSize * nGradeRelationship;
    string sItemTemplateList = sType + IntToString(nNewGrade);
    
    // skill required = twice the  grade of the essence
    if (!DoDistillationSkillCheck(nGrade*2, oCaster))
        return FALSE;
        
   	DestroyObject(oEssence);
    CreateListOfItemsMultipleTimes(nNewStackSize, sItemTemplateList, oCaster);

    return TRUE;
}

// Combine the essences to higher value
int CombineEssences(object oEssence, object oCaster)
{
    int nGrade = GetEssenceGrade(oEssence);
    string sType = GetEssenceType(oEssence);
	int nStackSize = GetItemStackSize(oEssence); // we can distill multiple objects at once.
    
    int nNewGrade = nGrade +1;
    
    int nGroup = GetEssenceGroup(oEssence);
    int nGradeRelationship = GetGradeRelationship(nGroup);
    int nMaxGrade = GetMaxGrade(nGroup);
    
    if (nGrade == nMaxGrade)
    {
        PrettyDebug("This essence can't be further combined");
        ErrorNotify(oCaster, ERROR_ESS_CANT_COMBINE);
        return FALSE;
    }
    if (nStackSize < nGradeRelationship)
    {
        PrettyDebug("Insufficient essences to combine");
        ErrorNotify(oCaster, ERROR_ESS_INSUFFICIENT_TO_COMBINE);
        return FALSE;
    }
    
    int nNewStackSize = nStackSize/nGradeRelationship;
    int nRemainder = nStackSize % nGradeRelationship;
    string sItemTemplateList = sType + IntToString(nNewGrade);
    
    // skill required = twice the new grade of the essence
    if (!DoDistillationSkillCheck(nNewGrade*2, oCaster))
        return FALSE;
    
    // all requirements passed                
    SetItemStackSizeOrDestroy(oEssence, nRemainder);
    CreateListOfItemsMultipleTimes(nNewStackSize, sItemTemplateList, oCaster);
    return TRUE;
}


// Combine the essences to higher value
int ConvertEssences(object oEssence, object oCaster)
{
    int nGrade      = GetEssenceGrade(oEssence);
    string sType    = GetEssenceType(oEssence);
 	int nStackSize  = GetItemStackSize(oEssence); // we can distill multiple objects at once.
 
    string sItemTemplateList;
    int nNewStackSize;
    int nRemainder;
    
    int nGroup = GetEssenceGroup(oEssence);
    int nGradeRelationship = GetGradeRelationship(nGroup);
    
    if (sType == ESSENCE_TYPE2_SPIRIT)
    {
        PrettyDebug("Can't convert spirit essences");
        ErrorNotify(oCaster, ERROR_ESS_CANT_CONVERT_SPIRIT);
        return FALSE;            
    }
       
    if ((sType == ESSENCE_TYPE1_POWER)
        || (sType == ESSENCE_TYPE2_POWER))
    {
        // convert 1 power essence into x/3 of each elemental essence 1 grade lower.
        // where x = Conversion Rate rounded down.
        if (nGrade == 1 )
        {
            PrettyDebug("essence grade to low for conversion");
            ErrorNotify(oCaster, ERROR_ESS_CANT_CONVERT_LOW_GRADE);
            return FALSE;
        }
        nNewStackSize = nGradeRelationship/3;
        if (nNewStackSize <1)
            nNewStackSize = 1;
        nRemainder =  nStackSize - 1;
        int nNewGrade = nGrade-1;
        sItemTemplateList = MakeList(GetEssenceResRef(nGroup, ELEMENT_AIR, nNewGrade),
                                    GetEssenceResRef(nGroup, ELEMENT_EARTH, nNewGrade),
                                    GetEssenceResRef(nGroup, ELEMENT_FIRE, nNewGrade),
                                    GetEssenceResRef(nGroup, ELEMENT_WATER, nNewGrade));
    }
    else // fire, earth, air or water essence of both groups
    {   // convert 2 elemental essences into 1 power essence of same grade.
        if (nStackSize<2)
        {
            PrettyDebug("Two elemental essences required for conversion");
            ErrorNotify(oCaster, ERROR_ESS_INSUFFICIENT_TO_CONVERT);
            return FALSE;
        }
        nNewStackSize = 1;
        nRemainder = nStackSize-2;
        sItemTemplateList = GetEssenceResRef(nGroup, ELEMENT_POWER, nGrade);
    }
    
    // skill required = twice the new grade of the essence
    if (!DoDistillationSkillCheck(nGrade*2, oCaster))
        return FALSE;
    
    // all requirements passed                
    SetItemStackSizeOrDestroy(oEssence, nRemainder);
    CreateListOfItemsMultipleTimes(nNewStackSize, sItemTemplateList, oCaster);
   
    return TRUE;
}

void main()
{
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run
    // this spell.
    if (!X2PreSpellCastCode())
    {
        return;
    }

    object oCaster = OBJECT_SELF;
    object oTarget = GetSpellTargetObject();
    int nSpell = GetSpellId();
    PrettyDebug("Shapers Alembic script called with spell ID " + IntToString(nSpell));
    
    int iType = GetObjectType(oTarget);
    if (iType != OBJECT_TYPE_ITEM)
    {
        PrettyDebug("Target not an item type");
        ErrorNotify(oCaster, ERROR_ITEM_NOT_ESS);
        return;            
    }            
    if (GetEssenceGroup(oTarget) == ESSENCE_GROUP_INVALID)
    {
        PrettyDebug("Target not an essence");
        ErrorNotify(oCaster, ERROR_ITEM_NOT_ESS);
        return;            
    }
    
    // ============================================================
    if (nSpell == SPELL_SHAPERS_ALEMBIC_DIVIDE)
    {
        PrettyDebug("Divide essence");
        DivideEssences(oTarget, oCaster);
    }
    else if (nSpell == SPELL_SHAPERS_ALEMBIC_COMBINE)
    {
        PrettyDebug("Combine essence");
        CombineEssences(oTarget, oCaster);
    }
    else if (nSpell == SPELL_SHAPERS_ALEMBIC_CONVERT)
    {
        PrettyDebug("Convert essence");
        // Convert normal essences to Power, and Power to normal.
        // Spirit Essences aren't convertible.
        ConvertEssences(oTarget, oCaster);
    }
    else
    {
        PrettyDebug("Unrecognized spell id");
    }
    // ============================================================
    
    // This "spell" only affects specific types of items
    
    //Fire cast spell at event for the specified target
    //SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_SHAPERS_ALEMBIC, FALSE));
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpell, FALSE));
    
}