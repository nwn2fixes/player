// ginc_crafting
/*
	Crafting related functions
*/
// ChazM 12/15/05
// ChazM 1/31/06 Moved lots of functions out to their appropriate include files.
// ChazM 1/31/06 Updated/fixed prototypes
// ChazM 2/1/06 Added Alchemy and Distillation.  Renamed and reorganized numerous functions.
// ChazM 2/1/06 Added Wondrous Items
// ChazM 2/2/06 Added various 2DA support
// ChazM 2/2/06 Added ability to use either 2DA or variables depending on if VAR_REC_SET is set.  Reorganized functions.
// ChazM 3/23/06 Added ExecuteDistillation()
// ChazM 3/23/06 Changed Mold suffix to be a mold prefix to match the current data set
// ChazM 3/28/06 Updated crafting to require various feats and skills
// ChazM 3/29/06 Added CasterLevel to Magical/Wondrous Crafting, addded additional error codes 
// ChazM 3/30/06 Added SuccessNotify(), updated Error codes - string refs with real values
// ChazM 4/8/06 Added bIdentify param to CreateListOfItemsInInventory()
// ChazM 4/11/06 Added MakeRepeatedItemList()
// ChazM 4/18/06 Modified CreateMagicalRecipe(), GetTargetItem(), and DoMagicCrafting() to support using item category (instead of tag suffix list)
// ChazM 5/5/06 Changed GetRecipeElement() to GetRecipeIntElement() and GetRecipeStringElement()
// ChazM 5/30/06 Added SetEnchantedItemName() - used in DoMagicCrafting()
// ChazM 5/31/06 Modified SetEnchantedItemName()
// ChazM 5/31/06 added strrefs to SetEnchantedItemName()
// ChazM 7/14/06 Modified DoMagicCrafting() -  Renaming Item only applies to Magic weapons and armor
// ChazM 7/29/06 Fix error in DoMundaneCrafting()
// ChazM 8/1/06 Max item properties set to 3. Masterwork weapons can be renamed on each enchanting, everything else only on the first enchanting
// ChazM 8/11/06 Updated str refs in SetEnchantedItemName()
// ChazM 8/11/06 updated CreateDistillationRecipe() - correction
// ChazM 8/14/06 added GetExpandedTags(), updated GetSortedItemList() - fix for stacks of items
// ChazM 8/16/06 added various workbench identification functions
// ChazM 8/27/06 added temp crafting VFX
// PKM 08.28.06 put in final VFX
// ChazM 9/10/06 Modified ExecuteDistillation() - stacks can now be distilled, added fix for playing special effect
// ChazM 9/29/06 DoMagicCrafting() - everything can be renamed upon enchanting, unless it has a special var; refixed SetEnchantedItemName()
// ChazM 3/14/07 GetRowIndexes handles Warlock "Imbue Item" special case.
// ChazM 3/16/07 Wondrous Item recipes now support enchantment or creation.
// ChazM 3/22/07 Enchant/Construct recipes can now use either feat.  Enchanting recipes now match to the allowed Affected items.
// ChazM 3/23/07 additional fixes & clean-ip, multiple effect support
// ChazM 4/4/07 multiple effect fix
// ChazM 5/1/07 added ginc_2da include, removed index search cap
// MDiekmann 5/2/07 made adjustments to DoMagicCrafting()
// ChazM 5/2/07 Added GetPropSlotsUsed() from TCC by Dash; added support for auto policy handling for adding Item Props - many functions added.
// MDiekmann 6/15/07 modified GetCrafting2DARecipeMatch so that iRow is not incremented from -1 to 0 causing a big long loop.
// ChazM 6/27/07 update for ERROR_TARGET_HAS_MAX_ENCHANTMENTS_NON_EPIC
// ChazM 6/28/07 update for ERROR_TARGET_NOT_LEGAL_FOR_EFFECT
// MDiekamnn 7/17/07 - modified DoMundaneCrafting to recognize failure for craft trap.
// ChazM 7/24/07 - Modified IsWorkbench scripts to better id workbenches (mostly to keep spells targeting workbenches from firing)
// ChazM 8/9/07 - Magical crafting observes flag CAMPAIGN_SWITCH_CRAFTING_USE_TOTAL_LEVEL
// MDiekmann 8/15/07 - Included x2_inc_switches so access so that this can access that new variable
// Lord Grave 160907 - fix mismatched prototype/definition of GetIsItemPropertyAnUpgrade() (impl/ by kevL).
// Lord Grave 160907 - fix for ImbueItem, bypass checking Crafting_Index.2da row #40 so the loop doesn't exit prematurely (impl/ by kevL).

//void main(){}

#include "x0_i0_stringlib"
#include "ginc_vars"
#include "ginc_item"
#include "ginc_debug"	
#include "ginc_param_const"
#include "ginc_2da"
#include "x2_inc_switches"

// ************************
// *** Constants
// ************************
const string ENCODED_EFFECT_LIST_DELIMITER	= ";";

const string VAR_REC_SET = "RecipiesSet"; // Global Var

const string MAGICAL_RECIPE_PREFIX 		= "MAG";
const string MUNDANE_RECIPE_PREFIX		= "MUN";
const string ALCHEMY_RECIPE_PREFIX		= "ALC";
const string ALCHEMY_RECIPE_SUFFIX		= "ALC"; 
const string DISTILLATION_RECIPE_PREFIX	= "DIS";
const string DISTILLATION_RECIPE_SUFFIX = "DIS";

														// Used by:
const string VAR_RECIPE_COUNT   		= "_COUNT_";	// magical/wondrous, mundane, alchemy, distillation, 

// apparently this has changed to a suffix.
//const string MOLD_SUFFIX				= "_mld";		// tag of weapon/armor molds must always have this suffix.
const string MOLD_PREFIX				= "n2_crft_mold";		// tag of weapon/armor molds must always have this suffix.

const string VAR_RECIPE_SPELLID_LIST	= "RECIPE_SPELLID_LIST";	// list of SpellID indexes
const string VAR_RECIPE_RESREF_LIST		= "RECIPE_RESREF_LIST";		// list of mold resref inexes

const string VAR_ROW_NUMBER 			= "ROW_NUMBER";				// 2DA Row Number
const string VAR_RECIPE_2DA_INDEXES		= "RECIPE_2DA_INDEXES";		// List of info for index 2DA

const string CRAFTING_2DA 				= "crafting";
const string COL_CRAFTING_CATEGORY 		= "CATEGORY";	// magical/wondrous, mundane, alchemy, distillation, 
const string COL_CRAFTING_REAGENTS 		= "REAGENTS";	// magical/wondrous, mundane, alchemy, distillation, 
const string COL_CRAFTING_TAGS     		= "TAGS";		// magical/wondrous (Items Affected)
const string COL_CRAFTING_EFFECTS  		= "EFFECTS";	// magical/wondrous (Encoded Effect)
const string COL_CRAFTING_OUTPUT		= "OUTPUT";		// magical/wondrous, mundane, alchemy, distillation
const string COL_CRAFTING_CRAFT_SKILL	= "SKILL";		// magical/wondrous (Feat), mundane(skill)
const string COL_CRAFTING_SKILL_LEVEL	= "LEVEL";		// magical/wondrous (caster level), mundane (skill level), alchemy (alchemy level), distillation (alchemy level)

	
const string CRAFTING_INDEX_2DA 		= "crafting_index";
//const string COL_CRAFTING_CATEGORY 	= "CATEGORY";	// this col in both 2DA's
const string COL_CRAFTING_START_ROW		= "START_ROW";

const string ITEM_PROP_DEF_2DA 			= "itempropdef";
const string COL_ITEM_PROP_DEF_SLOTS 	= "Slots";		// New col (idea by Dash)
const string COL_ITEM_PROP_DEF_SUB_TYPE_RESREF = "SubTypeResRef";



// Error codes - string refs
const int ERROR_ITEM_NOT_DISTILLABLE                = 174285; //"No match found for this item"        
const int ERROR_MISSING_REQUIRED_MOLD               = 174286; //"No mold found"    
const int ERROR_RECIPE_NOT_FOUND                    = 174287; //"No match found for this spell/reagent combo" 
const int ERROR_TARGET_NOT_FOUND_FOR_RECIPE         = 174288; //"couldn't find object for effect to be put on."
const int ERROR_INSUFFICIENT_CASTER_LEVEL           = 174289; //"Not high enough level of spell caster to use this magical recipe"
const int ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL	= 174290;
const int ERROR_INSUFFICIENT_CRAFT_ARMOR_SKILL      = 174291;
const int ERROR_INSUFFICIENT_CRAFT_WEAPON_SKILL     = 174293;
const int ERROR_INSUFFICIENT_CRAFT_TRAP_SKILL		= 208635;
const int ERROR_NO_CRAFT_WONDROUS_FEAT              = 174294;
const int ERROR_NO_CRAFT_MAGICAL_FEAT               = 174295;
const int OK_CRAFTING_SUCCESS                 		= 174296;
const int ERROR_TARGET_HAS_MAX_ENCHANTMENTS			= 182996; // "Item can not be further enchanted."
const int ERROR_TARGET_HAS_MAX_ENCHANTMENTS_NON_EPIC = 207914; // "Item cannot be further enchanted. (Only an epic character can further enchant this item)"
const int ERROR_TARGET_NOT_LEGAL_FOR_EFFECT			= 207917; // Not a valid enchantment for that particular type of item.

const int ERROR_UNRECOGNIZED_MORTAR_USAGE 			= 183206 ; // The mortar & pestle must be used on an alchemist's workbench or on an item.
const int ERROR_UNRECOGNIZED_HAMMER_USAGE 			= 183205 ; // "The smith hammer must be used on a blacksmith's workbench."		

// this variable is stored on the owned character so that script "gui_name_enchanted_item" can retrieve a reference to the item.
const string VAR_ENCHANTED_ITEM_OBJECT 	= "EnchantedItemObject";

// Standard Workbench Tag Prefixes
const string TAG_WORKBENCH_PREFIX1 	= "PLC_MC_WBENCH";
const string TAG_WORKBENCH_PREFIX2 	= "PLC_MC_CBENCH";

// Alchemy Workbench tags
const string TAG_ALCHEMY_BENCH1 	= "alchemy_bench";
const string TAG_ALCHEMY_BENCH2 	= "PLC_MC_CBENCH01";
const string TAG_ALCHEMY_BENCH3 	= "alchemy";
const string TAG_ALCHEMY_BENCH4 	= "PLC_MR_AWBench";

// Blacksmith Workbench tags
const string TAG_WORKBENCH1 		= "workbench";
const string TAG_WORKBENCH2 		= "PLC_MC_CBENCH02";
const string TAG_WORKBENCH3 		= "blacksmith";
const string TAG_WORKBENCH4 		= "PLC_MR_WWBench";

// Magical Workbench tags
const string TAG_MAGICAL_BENCH1 	= "magical_bench";
const string TAG_MAGICAL_BENCH2 	= "PLC_MC_CBENCH03";
const string TAG_MAGICAL_BENCH3 	= "magical";
const string TAG_MAGICAL_BENCH4 	= "PLC_MR_MWBench";


// workbench vars - set to 1 to indicate workbench
const string VAR_ALCHEMY			= "WB_alchemy";	
const string VAR_BLACKSMITH 		= "WB_blacksmith";
const string VAR_MAGICAL 			= "WB_magical";

						
// just like vector, but with ints
struct IntVector
{
    int x;
 	int y;
	int z;
};

// ************************
// *** Prototypes
// ************************

// ------------------------
// data functions	
string GetMagicalRecipeVar(string sRecipeVar, int iSpellID);
string GetMundaneRecipeVar(string sRecipeVar, string sMoldResRef);
string GetAlchemyRecipeVar(string sRecipeVar);
string GetDistillationRecipeVar(string sRecipeVar);
string GetRecipeVar(string sRecipeType, string sRecipeVar, string sCategory);
string GetCraftingStringData(string sRecipeType, string sCategory, string sColumn, int iCount);
int GetCraftingIntData(string sRecipeType, string sCategory, string sColumn, int iCount);

// ------------------------
// useful functions (may be moved elsewhere)
string MakeNonNegIntList(int nVal1, int nVal2 = -10000, int nVal3 = -10000, int nVal4 = -10000, int nVal5 = -10000);
string MakeBaseItemList(int nVal1, int nVal2 = -10000, int nVal3 = -10000, int nVal4 = -10000, int nVal5 = -10000);
string MakeList(string sReagent1, string sReagent2="", string sReagent3="", string sReagent4="", string sReagent5="",
            	string sReagent6="", string sReagent7="", string sReagent8="", string sReagent9="", string sReagent10="");
string MakeRepeatedItemList(string sListElement, int iCount);	
string MakeEncodedEffect(int nPropID, int nParam1 = 0, int nParam2 = 0, int nParam3 = 0, int nParam4 = 0);
itemproperty GetEncodedEffectItemProperty(string sEncodedEffect);

int GetIsAlwaysKeptItemProperty(itemproperty ip);
int GetIsIgnoreSubtypeItemProperty(itemproperty ip);
int GetIsItemPropertyAnUpgrade(object oItem, itemproperty ip, int nDurationType = DURATION_TYPE_PERMANENT);
int GetIsEncodedEffectAnUpgrade(object oItem, string sEncodedEffect);
int GetAreAllEncodedEffectsAnUpgrade(object oItem, string sEncodedEffects);
void AddItemPropertyAutoPolicy(object oItem, itemproperty ip, float fDuration =0.0f);
void ApplyEncodedEffectToItem(object oItem, string sEncodedEffect, float fDuration = 0.0f);
void ApplyEncodedEffectsToItem(object oItem, string sEncodedEffects, float fDuration =0.0f);
void CreateListOfItemsInInventory(string sItemTemplateList, object oTarget, int bIdentify=TRUE);
void DestroyItemsInInventory(int bIsEnchanting = FALSE, object oTarget=OBJECT_SELF);
//int Search2DA(string s2DA, string sColumn, string sMatchElement, int iStartRow, int iEndRow);
string PadString(int iMinSize, string sValue);

// ------------------------
// functions for creating recipes
void CreateEnchantRecipe(int iFeat, int iSpellId, string sEffect, string sItemsAffected, string sReagentList, int iCasterLevel=1);
void CreateConstructItemRecipe(int iFeat, int iSpellId, string sReagentList, string sOutputResRef, int iCasterLevel=1);

void CreateMagicalRecipe(int iSpellId, string sEffect, int iItemCategory, string sReagentList, int iCasterLevel=1);
void CreateWondrousRecipe(int iSpellId, string sReagentList, string sOutputResRef, int iCasterLevel=1);
void CreateMundaneRecipe(string sMoldTag, int iCraftSkill, int iSkillLevel, string sReagentList, string sOutputResRef);
void CreateAlchemyRecipe(int iSkillLevel, string sReagentList, string sOutputResRef);
void CreateDistillationRecipe(int iSkillLevel, string sReagent, string sOutputResRefList);

// ------------------------
// **** 2da output related functions
//struct IntVector GetRowIndexes(string sCategory);
string GetRecipeStringElement(string sRecipeType, string sRecipeVar, string sCategory, int iCount);
int GetRecipeIntElement(string sRecipeType, string sRecipeVar, string sCategory, int iCount);
string FormatHeaderRow();
string FormatRecipeRow(string sRecipePrefix, string sCategory, int iCount);
int OutputRecipeSet(string sRecipePrefix, string sIndex);
int OutputRecipeType(string sRecipePrefix, string sIndexList);
int OutputRecipes();
string FormatIndexHeaderRow();
string FormatIndexRecipeRow(int iRow, string sCategory, string sRowIndex);
int OutputRecipeIndex();

// ------------------------
// private (helper) functions for using recipes
string GetSortedItemList(int bIsEnchanting = FALSE, object oTarget=OBJECT_SELF);
int GetInventoryRecipeMatch(string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID);
int GetRecipeMatch(string sSortedItemList, string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID);
struct IntVector GetRowIndexes(string sCategory);
int GetCrafting2DARecipeMatch(string sSortedItemList, string sRecipePrefix, string sCategory, object oItem = OBJECT_INVALID);
int GetGlobalVarRecipeMatch(string sSortedItemList, string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID);

int GetIsItemOfBaseTypes(object oItem, string sListOfBaseTypes);
int GetMatchesAffectedItems(object oItem, string sItemsAffected);
string FindMundaneIndexTag(string sTagSuffix, object oObject=OBJECT_SELF);

// ------------------------
// functions for using recipes
void DoMagicCrafting(int iSpellID, object oPC);
void DoMundaneCrafting(object oPC);
void DoAlchemyCrafting(object oPC);
void DoDistillation(object oItem, object oPC);
void ExecuteDistillation(int iSkillReq, object oItem, object oPC, string sItemTemplateList);
void SuccessNotify(object oPC, int iStrRef=OK_CRAFTING_SUCCESS);
void ErrorNotify(object oPC, int iErrorStrRef);
void SetEnchantedItemName(object oPC, object oItem);

// ------------------------
// is workbench functions
int IsWorkbench(object oTarget);
int IsSmithWorkbench(object oTarget);
int IsAlchemyWorkbench(object oTarget);


// ************************
// *** Functions
// ************************


int IsMagicalWorkbench(object oTarget)
{
	int iObjType = GetObjectType(oTarget);
	if (iObjType != OBJECT_TYPE_PLACEABLE) // alchemy workbench must be a placeable
		return FALSE;

	// magical workbench can be identified by it's tag or by a local variable		
	string sTargetTag = GetTag(oTarget);
	if ((sTargetTag == TAG_MAGICAL_BENCH1) || (sTargetTag == TAG_MAGICAL_BENCH2) || 
		(sTargetTag == TAG_MAGICAL_BENCH3) || (sTargetTag == TAG_MAGICAL_BENCH4) )
		return TRUE;
		
	if (GetLocalInt(oTarget, VAR_MAGICAL) == TRUE)
		return TRUE;
		
	return FALSE;	
}

// Needed by Smith Hammer which works on Smith Workbench
int IsSmithWorkbench(object oTarget)
{
	int iObjType = GetObjectType(oTarget);
	if (iObjType != OBJECT_TYPE_PLACEABLE) // smith workbench must be a placeable
		return FALSE;

	// smith workbench can be identified by it's tag or by a local variable		
	string sTargetTag = GetTag(oTarget);
	if ((sTargetTag == TAG_WORKBENCH1) || (sTargetTag == TAG_WORKBENCH2) ||
		(sTargetTag == TAG_WORKBENCH3) || (sTargetTag == TAG_WORKBENCH4) )
		return TRUE;
		
	if (GetLocalInt(oTarget, VAR_BLACKSMITH) == TRUE)
		return TRUE;
		
	return FALSE;		
}


// Needed by Mortar & Pestle which only works on Alchemy Workbench
int IsAlchemyWorkbench(object oTarget)
{
	int iObjType = GetObjectType(oTarget);
	if (iObjType != OBJECT_TYPE_PLACEABLE) // alchemy workbench must be a placeable
		return FALSE;

	// alchemy workbench can be identified by it's tag or by a local variable		
	string sTargetTag = GetTag(oTarget);
	if ((sTargetTag == TAG_ALCHEMY_BENCH1) || (sTargetTag == TAG_ALCHEMY_BENCH2) ||
		(sTargetTag == TAG_ALCHEMY_BENCH3) || (sTargetTag == TAG_ALCHEMY_BENCH4) )
		return TRUE;
		
	if (GetLocalInt(oTarget, VAR_ALCHEMY) == TRUE)
		return TRUE;
		
	return FALSE;		
}

// workbenches should all have 1 of 2 standard prefixes
int IsWorkbench(object oTarget)
{
	//int iObjType = GetObjectType(oTarget);
	//if (iObjType != OBJECT_TYPE_PLACEABLE) // smith workbench must be a placeable
	//	return FALSE;

	string sTargetTag = GetTag(oTarget);
	string sTargetTagPrefix = GetStringLeft(sTargetTag, GetStringLength(TAG_WORKBENCH_PREFIX1));
	if ((sTargetTagPrefix == TAG_WORKBENCH_PREFIX1) || (sTargetTagPrefix == TAG_WORKBENCH_PREFIX2))
		return TRUE;
		
	if (IsSmithWorkbench(oTarget) || IsAlchemyWorkbench(oTarget) || IsMagicalWorkbench(oTarget))
		return TRUE;
		
	return FALSE;		
}


void output(string sText, object oTarget = OBJECT_SELF)
{
	PrettyMessage(sText);
    //PrintString(sText);
    //AssignCommand(oTarget, SpeakString(sText));
}

	

// ===========================================
// Data Functions
// ===========================================

// Recipe info is stored in globals with the following format:
// MAG_[LIST/TAGS/EFFECT]_<SpellID>_X - where X is the index
string GetMagicalRecipeVar(string sRecipeVar, int iSpellID)
{
	string sVarName = GetRecipeVar(MAGICAL_RECIPE_PREFIX, sRecipeVar, IntToString(iSpellID));
    return (sVarName);
}

// Recipe info is stored in globals with the following format:
// MUN_[LIST/...]_<MoldResRef>_X
string GetMundaneRecipeVar(string sRecipeVar, string sMoldResRef)
{
	string sVarName = GetRecipeVar(MUNDANE_RECIPE_PREFIX, sRecipeVar, sMoldResRef);
    return (sVarName);
}

// Recipe info is stored in globals with the following format:
// ALC_[LIST/...]_ALC_X
string GetAlchemyRecipeVar(string sRecipeVar)
{
	string sVarName = GetRecipeVar(ALCHEMY_RECIPE_PREFIX, sRecipeVar, ALCHEMY_RECIPE_SUFFIX);
    return (sVarName);
}

string GetDistillationRecipeVar(string sRecipeVar)
{
	string sVarName = GetRecipeVar(DISTILLATION_RECIPE_PREFIX, sRecipeVar, DISTILLATION_RECIPE_SUFFIX);
    return (sVarName);
}

	
// Get Recipe Variable Name (used w/ SetGlobalArray*())
string GetRecipeVar(string sRecipeType, string sRecipeVar, string sCategory)
{
    string sVarName = sRecipeType + sRecipeVar + sCategory + "_";
	// tbd: should probably do a check to ensure string length not to long.
    return (sVarName);
}

// Get Specific RecipeElement from global var
string GetRecipeStringElement(string sRecipeType, string sRecipeVar, string sCategory, int iCount)
{
    string sVarRecipeList = GetRecipeVar(sRecipeType, sRecipeVar, sCategory);
    return (GetGlobalArrayString(sVarRecipeList, iCount));
}

// Get Specific RecipeElement from global var
int GetRecipeIntElement(string sRecipeType, string sRecipeVar, string sCategory, int iCount)
{
    string sVarRecipeList = GetRecipeVar(sRecipeType, sRecipeVar, sCategory);
    return (GetGlobalArrayInt(sVarRecipeList, iCount));
}

int UsingVariables()
{	
	return (GetGlobalInt(VAR_REC_SET));
}

// unified crafting data retrieval from global variables or 2da files.
// If globals variables are set then we use global vars.
// sRecipeType 	- var	- magical, mundane, etc - used as prefix of var name
// sCategory	- var	- spell id or other info used to determine var name 
// sColumn		- var/2da 	- the column of data we want (reagents, effects, etc.)
// iCount		- var/2da	- the count for var name -or- the index into the crafting.2da
string GetCraftingStringData(string sRecipeType, string sCategory, string sColumn, int iCount)
{
	string sStringData;
	if (UsingVariables())
	{
    	//string sGlobalArrayVar = GetRecipeVar(sRecipeType, sColumn, sCategory);
    	//sStringData = GetGlobalArrayString(sGlobalArrayVar, iCount);
		sStringData = GetRecipeStringElement(sRecipeType, sColumn, sCategory, iCount);
		
	}
	else // 2da version:
		sStringData = Get2DAString(CRAFTING_2DA, sColumn, iCount);

	return(sStringData);
}

int GetCraftingIntData(string sRecipeType, string sCategory, string sColumn, int iCount)
{
	int iIntData;		
	if (UsingVariables())
		iIntData = GetRecipeIntElement(sRecipeType, sColumn, sCategory, iCount);
	else // 2da version:
		iIntData = StringToInt(Get2DAString(CRAFTING_2DA, sColumn, iCount));

	return(iIntData);
	
	// return (StringToInt(GetCraftingStringData(sRecipeType, sCategory, sColumn, iCount)));
}

// ===========================================
// Useful funcs
// ===========================================

string MakeNonNegIntList(int nVal1, int nVal2 = -10000, int nVal3 = -10000, int nVal4 = -10000, int nVal5 = -10000)
{
    string sRet;

    sRet = IntToString(nVal1);
	if (nVal2 != -10000)
    	sRet += FormListElement(IntToString(nVal2));
	if (nVal3 != -10000)
	    sRet += FormListElement(IntToString(nVal3));
	if (nVal4 != -10000)
	    sRet += FormListElement(IntToString(nVal4));
	if (nVal5 != -10000)
	    sRet += FormListElement(IntToString(nVal5));

    return (sRet);
}


string MakeBaseItemList(int nVal1, int nVal2 = -10000, int nVal3 = -10000, int nVal4 = -10000, int nVal5 = -10000)
{
    string sRet = "B" + MakeNonNegIntList(nVal1, nVal2, nVal3, nVal4, nVal5);
    return (sRet);
}


// Set up a list with up to 10 elements
// this list is simply a comma delimited string
// First element is required.
string MakeList(string sReagent1, string sReagent2="", string sReagent3="", string sReagent4="", string sReagent5="",
             	string sReagent6="", string sReagent7="", string sReagent8="", string sReagent9="", string sReagent10="")
{
    string sReagentList;

    sReagentList = sReagent1;
    sReagentList += FormListElement(sReagent2);
    sReagentList += FormListElement(sReagent3);
    sReagentList += FormListElement(sReagent4);
    sReagentList += FormListElement(sReagent5);
    sReagentList += FormListElement(sReagent6);
    sReagentList += FormListElement(sReagent7);
    sReagentList += FormListElement(sReagent8);
    sReagentList += FormListElement(sReagent9);
    sReagentList += FormListElement(sReagent10);

    return (sReagentList);
}

// will create a repeated list of items.
string MakeRepeatedItemList(string sListElement, int iCount)	
{
    string sList;
	int i;
	
	if (iCount >= 1)		
		sList = sListElement;

	for (i=2; i<=iCount; i++)		
    	sList += FormListElement(sListElement);
	

   	return (sList);
}


	
// Property ID required.  See function IPSafeAddItemProperty() in x2_inc_itemprop for supported props and params
// Creates a list containing the property and params for the effect to apply.
string MakeEncodedEffect(int nPropID, int nParam1 = 0, int nParam2 = 0, int nParam3 = 0, int nParam4 = 0)
{
    string sRecipeEffect;

    sRecipeEffect = IntToString(nPropID);
    sRecipeEffect += FormListElement(IntToString(nParam1));
    sRecipeEffect += FormListElement(IntToString(nParam2));
    sRecipeEffect += FormListElement(IntToString(nParam3));
    sRecipeEffect += FormListElement(IntToString(nParam4));

    return (sRecipeEffect);
}

// 
itemproperty GetEncodedEffectItemProperty(string sEncodedEffect)
{
	int nPropID = GetIntParam(sEncodedEffect, 0);
	int nParam1 = GetIntParam(sEncodedEffect, 1);
	int nParam2 = GetIntParam(sEncodedEffect, 2);
	int nParam3 = GetIntParam(sEncodedEffect, 3);
	int nParam4 = GetIntParam(sEncodedEffect, 4);
	
    itemproperty ip = IPGetItemPropertyByID(nPropID, nParam1, nParam2, nParam3, nParam4);
	return (ip);
}



// IP's that never get replaced		
int GetIsAlwaysKeptItemProperty(itemproperty ip)
{
	int nIPType = GetItemPropertyType(ip);
	
	// allow for multiple bonus spell slot IP's
	if (nIPType == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
		return TRUE;
		
	return FALSE;		
}

// IP's that ignore subtype
int GetIsIgnoreSubtypeItemProperty(itemproperty ip)
{
	int nIPType = GetItemPropertyType(ip);
	
	// visual effects have subtypes, but only 1 should be applied, so ignore subtype
	if (nIPType == ITEM_PROPERTY_VISUALEFFECT)
		return TRUE;

	return FALSE;		
}

// returns whether this IP will be treated as an upgrade when we go to add it.
// Note: IP's don't have DurationTypes until they are applied
int GetIsItemPropertyAnUpgrade(object oItem, itemproperty ip, int nDurationType = DURATION_TYPE_PERMANENT) // Lord Grave fix (kevL)
{
	int bIgnoreSubType = FALSE;

	// IP's that never get replaced
	if (GetIsAlwaysKeptItemProperty(ip))
		return FALSE;
		
	// IP's that ignore subtype
	if (GetIsIgnoreSubtypeItemProperty(ip))
		bIgnoreSubType = TRUE;

	int bRet = IPGetItemHasProperty(oItem, ip, nDurationType, bIgnoreSubType);
	
	return bRet;
}


int GetIsEncodedEffectAnUpgrade(object oItem, string sEncodedEffect)
{
	itemproperty ip = GetEncodedEffectItemProperty(sEncodedEffect);
	int bRet = FALSE;
	if (GetIsItemPropertyValid(ip))		
	{
		bRet = GetIsItemPropertyAnUpgrade(oItem, ip);
	}		
	else
		PrettyError("Invalid ItemProperty: " + sEncodedEffect);	
		
	return (bRet);
}

// Apply the encoded effect to an item (created w/ MakeEncodedEffect())
// effects are delimited with the semicolon ";"
int GetAreAllEncodedEffectsAnUpgrade(object oItem, string sEncodedEffects)
{
	int bRet = TRUE;
	string sEncodedEffect;
		
    struct sStringTokenizer stEncodedEffects = GetStringTokenizer(sEncodedEffects, ENCODED_EFFECT_LIST_DELIMITER);
    while (HasMoreTokens(stEncodedEffects)) 
	{
        stEncodedEffects = AdvanceToNextToken(stEncodedEffects);
        sEncodedEffect = GetNextToken(stEncodedEffects);
		if(!GetIsEncodedEffectAnUpgrade(oItem, sEncodedEffect))
			return FALSE; // if 1 is not an upgrade then all are not an upgrade
    }
	return TRUE;
}


// Determine policies to use before sending off to IPSafeAddItemProperty()
void AddItemPropertyAutoPolicy(object oItem, itemproperty ip, float fDuration =0.0f)
{
	int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;
	int bIgnoreDurationType = FALSE;
	int bIgnoreSubType = FALSE;
	
	// IP's that never get replaced		
	if (GetIsAlwaysKeptItemProperty(ip))
		nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_KEEP_EXISTING;
		
	// IP's that ignore subtype
	if (GetIsIgnoreSubtypeItemProperty(ip))
		bIgnoreSubType = TRUE;
		
   	IPSafeAddItemProperty(oItem, ip, fDuration, nAddItemPropertyPolicy, bIgnoreDurationType, bIgnoreSubType);
}

//
void ApplyEncodedEffectToItem(object oItem, string sEncodedEffect, float fDuration = 0.0f)
{
 	int bIgnoreDurationType = FALSE;
	int bIgnoreSubType 		= FALSE; // subtypes will presumably be the same for properties that don't have subtypes, so no reason to ignore (except for special cases).

	int nAddItemPropertyPolicy = X2_IP_ADDPROP_POLICY_REPLACE_EXISTING;
	itemproperty ip = GetEncodedEffectItemProperty(sEncodedEffect);
	
	if (GetIsItemPropertyValid(ip))		
	{
		AddItemPropertyAutoPolicy(oItem, ip);
	}		
	else
		PrettyError("Invalid ItemProperty: " + sEncodedEffect);	
		
}


// Apply the encoded effect to an item (created w/ MakeEncodedEffect())
// effects are delimited with the semicolon ";"
void ApplyEncodedEffectsToItem(object oItem, string sEncodedEffects, float fDuration =0.0f)
{
    //output ("applying sEncodedEffect " + sEncodedEffect);
	string sEncodedEffect;
		
    struct sStringTokenizer stEncodedEffects = GetStringTokenizer(sEncodedEffects, ENCODED_EFFECT_LIST_DELIMITER);
    while (HasMoreTokens(stEncodedEffects)) 
	{
        stEncodedEffects = AdvanceToNextToken(stEncodedEffects);
        sEncodedEffect = GetNextToken(stEncodedEffects);
		ApplyEncodedEffectToItem(oItem, sEncodedEffect, fDuration);
    }
}

// create a comma delimited list of items in the inventory of oTarget
// bIdentify: -1 leave as default, FALSE (0) - set as not identified, TRUE (1) - set as identified.
void CreateListOfItemsInInventory(string sItemTemplateList, object oTarget, int bIdentify=TRUE)
{
	int nPos = 0;
	string sItemTemplate = GetStringParam(sItemTemplateList, nPos);
	object oCreatedObject;
	while (sItemTemplate != "")
	{
		output ("creating :" + sItemTemplate);
		oCreatedObject = CreateItemOnObject(sItemTemplate, oTarget);
		// 
		if (bIdentify != -1)
			SetIdentified(oCreatedObject, bIdentify);
		nPos++;
 		sItemTemplate = GetStringParam(sItemTemplateList, nPos);
	}
}


// Destroy all items that are not base type armor or weapon
//void DestroyItemsInInventory(int iIncludeCategories = ITEM_CATEGORY_ALL, object oTarget=OBJECT_SELF)
void DestroyItemsInInventory(int bIsEnchanting = FALSE, object oTarget=OBJECT_SELF)
{
    object oItem =  GetFirstItemInInventory(oTarget);

    while (GetIsObjectValid(oItem))
    {
        //if (GetIsItemCategory(oItem, iIncludeCategories))
		if (!bIsEnchanting
			|| !GetIsEquippable(oItem))
        {
            DestroyObject(oItem, 0.2f);
        }
        oItem = GetNextItemInInventory(oTarget);
    }
}


//                                          1         2         3         4         5         6         7         8         9         0   
//            				       1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
const string BLANK_SPACE_100 	= "                                                                                                    ";

// pad string w/ space to MinSize
string PadString(int iMinSize, string sValue)
{
	if (sValue == "" )
		sValue = "****";

	sValue += " ";
	int iLength = GetStringLength(sValue);
	int iNumSpaces = iMinSize - iLength;
	sValue += GetStringLeft(BLANK_SPACE_100, iNumSpaces);
	return (sValue);
}


// ===========================================
// functions for creating recipes
// ===========================================

// An enchant Magical Arms & Armor recipe used strictly w/ item categories (armor or weapons)
void CreateMagicalRecipe(int iSpellId, string sEffect, int iItemCategory, string sReagentList, int iCasterLevel=1)
{
    string sItemsAffected = IntToString(iItemCategory);
    CreateEnchantRecipe(FEAT_CRAFT_MAGIC_ARMS_AND_ARMOR, iSpellId, sEffect, sItemsAffected, sReagentList, iCasterLevel);
}

// Magical recipes always require a spellID which is used as an index to improve search speed
// MAG_COUNT_<SPELL>_ = array count
// MAG_LIST_<SPELL>_X = recipe reagents
// MAG_TAGS_<SPELL>_X = recipe Items Affected (item category or list of base types).  
// MAG_EFFECT_<SPELL>_X = recipe Effect
// MAG_SKILL_<SPELL>_X = feat required
// MAG_LEVEL_<SPELL>_X = caster level required
//
// Parameters:
// int iSpellId         - the required spell 
// string sEffect       - the enchantment to apply. Use MakeEncodedEffect() to create this string
// string sItemsAffected- the type of items that can be affected - either a number representing a category or 
//                          a list of Base item types created using MakeBaseItemList()
// string sReagentList  - the list of reagents neede for the recipe. Cannot be equippable items.  Create this using MakeList()
// int iCasterLevel     - the minimum caster level needed to be able to use this recipe.
void CreateEnchantRecipe(int iFeat, int iSpellId, string sEffect, string sItemsAffected, string sReagentList, int iCasterLevel=1)
{
	string sNewList = AppendGlobalList(VAR_RECIPE_SPELLID_LIST, IntToString(iSpellId), TRUE);
	//output("new spellid list:" + sNewList);
    string sVarRecipeCount = GetMagicalRecipeVar(VAR_RECIPE_COUNT, iSpellId);
	int iCount = ModifyGlobalInt(sVarRecipeCount, 1);

    string sVarRecipeReagents   = GetMagicalRecipeVar(COL_CRAFTING_REAGENTS, iSpellId);
    string sVarRecipeTags       = GetMagicalRecipeVar(COL_CRAFTING_TAGS, iSpellId);
    string sVarRecipeEffect     = GetMagicalRecipeVar(COL_CRAFTING_EFFECTS, iSpellId);
    string sVarRecipeCraftFeat 	= GetMagicalRecipeVar(COL_CRAFTING_CRAFT_SKILL, iSpellId);
   	string sVarRecipeCasterLevel= GetMagicalRecipeVar(COL_CRAFTING_SKILL_LEVEL, iSpellId);

    sReagentList = Sort(sReagentList);
	//output("CreateMagicalRecipe: Add " + sReagentList);

    SetGlobalArrayString(sVarRecipeReagents, iCount, sReagentList);
    //SetGlobalArrayInt(sVarRecipeTags, iCount, iItemCategory);
    SetGlobalArrayString(sVarRecipeTags, iCount, sItemsAffected);
    SetGlobalArrayString(sVarRecipeEffect, iCount, sEffect);
    SetGlobalArrayInt(sVarRecipeCraftFeat, iCount, iFeat);
    SetGlobalArrayInt(sVarRecipeCasterLevel, iCount, iCasterLevel);
	
//    output ("sVarRecipeEffect = " + sVarRecipeEffect);
//    output ("sEffect = " + sEffect);
}

// A Construct Item - Wondrous Item recipe
void CreateWondrousRecipe(int iSpellId, string sReagentList, string sOutputResRef, int iCasterLevel=1)
{
	CreateConstructItemRecipe(FEAT_CRAFT_WONDROUS_ITEMS, iSpellId, sReagentList, sOutputResRef, iCasterLevel);
}

// Wonderous recipes always require a spellID which is used as an index to improve search speed
// These recipes are stored together with magical weapon/armor recipes.
// MAG_COUNT_<SPELL>_ = array count
// MAG_LIST_<SPELL>_X = recipe reagents
// MAG_OUT_<SPELL>_X = output
// MAG_SKILL_<SPELL>_X = feat required
// MAG_LEVEL_<SPELL>_X = caster level required

// A Construct Item recipe
void CreateConstructItemRecipe(int iFeat, int iSpellId, string sReagentList, string sOutputResRef, int iCasterLevel=1)
{
	string sNewList = AppendGlobalList(VAR_RECIPE_SPELLID_LIST, IntToString(iSpellId), TRUE);
	//output("new spellid list:" + sNewList);
    string sVarRecipeCount = GetMagicalRecipeVar(VAR_RECIPE_COUNT, iSpellId);
	int iCount = ModifyGlobalInt(sVarRecipeCount, 1);

    string sVarRecipeReagents   = GetMagicalRecipeVar(COL_CRAFTING_REAGENTS, iSpellId);
    string sVarRecipeOutput   	= GetMagicalRecipeVar(COL_CRAFTING_OUTPUT, iSpellId);
    string sVarRecipeCraftFeat 	= GetMagicalRecipeVar(COL_CRAFTING_CRAFT_SKILL, iSpellId);
   	string sVarRecipeCasterLevel= GetMagicalRecipeVar(COL_CRAFTING_SKILL_LEVEL, iSpellId);

    sReagentList = Sort(sReagentList);
	//output("CreateWondrousRecipe: Add " + sReagentList);

    SetGlobalArrayString(sVarRecipeReagents, iCount, sReagentList);
    SetGlobalArrayString(sVarRecipeOutput, iCount, sOutputResRef);
    SetGlobalArrayInt(sVarRecipeCraftFeat, iCount, iFeat);
    SetGlobalArrayInt(sVarRecipeCasterLevel, iCount, iCasterLevel);
}


// Mundane recipes always require a mold which is used as an index to improve search speed
// MUN_COUNT_<MOLD>_ = array count
// MUN_LIST_<MOLD>_X = recipe reagents
// MUN_OUT_<MOLD>_X = output
// MUN_SKILL_<MOLD>_X = skill to be used (int)
// MUN_LEVEL_<MOLD>_X = Level of skill required
void CreateMundaneRecipe(string sMoldTag, int iCraftSkill, int iSkillLevel, string sReagentList, string sOutputResRef)
{
	string sNewList = AppendGlobalList(VAR_RECIPE_RESREF_LIST, sMoldTag, TRUE);
	//output("new resref list:" + sNewList);
	//output("new resref list:" + AppendGlobalList(VAR_RECIPE_RESREF_LIST, sMoldTag, TRUE));
    string sVarRecipeCount = GetMundaneRecipeVar(VAR_RECIPE_COUNT, sMoldTag);
	int iCount = ModifyGlobalInt(sVarRecipeCount, 1);

    string sVarRecipeReagents   = GetMundaneRecipeVar(COL_CRAFTING_REAGENTS, sMoldTag);
    string sVarRecipeOutput   	= GetMundaneRecipeVar(COL_CRAFTING_OUTPUT, sMoldTag);
    string sVarRecipeCraftSkill = GetMundaneRecipeVar(COL_CRAFTING_CRAFT_SKILL, sMoldTag);
    string sVarRecipeSkillLevel	= GetMundaneRecipeVar(COL_CRAFTING_SKILL_LEVEL, sMoldTag);

	sReagentList += FormListElement(sMoldTag); // add mold Res Ref to the list of reagents
    sReagentList = Sort(sReagentList);
	//output("CreateMundaneRecipe: Add recipe [" + IntToString(iCount) + "] - " + sReagentList);

    SetGlobalArrayString(sVarRecipeReagents, iCount, sReagentList);
    SetGlobalArrayString(sVarRecipeOutput, iCount, sOutputResRef);
    SetGlobalArrayInt(sVarRecipeCraftSkill, iCount, iCraftSkill);
    SetGlobalArrayInt(sVarRecipeSkillLevel, iCount, iSkillLevel);
}


// Alchemy recipes have no index.  Note that this means searches will get slower as more and more 
// recipes are added, so it should be kept to less than 50 or so.
void CreateAlchemyRecipe(int iSkillLevel, string sReagentList, string sOutputResRef)
{
    string sVarRecipeCount = GetAlchemyRecipeVar(VAR_RECIPE_COUNT);
	int iCount = ModifyGlobalInt(sVarRecipeCount, 1);

    string sVarRecipeReagents   = GetAlchemyRecipeVar(COL_CRAFTING_REAGENTS);
    string sVarRecipeOutput   	= GetAlchemyRecipeVar(COL_CRAFTING_OUTPUT);
    string sVarRecipeSkillLevel	= GetAlchemyRecipeVar(COL_CRAFTING_SKILL_LEVEL);

    sReagentList = Sort(sReagentList);

    SetGlobalArrayString(sVarRecipeReagents, iCount, sReagentList);
    SetGlobalArrayString(sVarRecipeOutput, iCount, sOutputResRef);
    SetGlobalArrayInt(sVarRecipeSkillLevel, iCount, iSkillLevel);
}


// Distillation recipes have no index.
void CreateDistillationRecipe(int iSkillLevel, string sReagent, string sOutputResRefList)
{
    string sVarRecipeCount = GetDistillationRecipeVar(VAR_RECIPE_COUNT);
	int iCount = ModifyGlobalInt(sVarRecipeCount, 1);

    string sVarRecipeReagents   = GetDistillationRecipeVar(COL_CRAFTING_REAGENTS);
    string sVarRecipeOutput   	= GetDistillationRecipeVar(COL_CRAFTING_OUTPUT);
    string sVarRecipeSkillLevel	= GetDistillationRecipeVar(COL_CRAFTING_SKILL_LEVEL);

    SetGlobalArrayString(sVarRecipeReagents, iCount, sReagent);
    SetGlobalArrayString(sVarRecipeOutput, iCount, sOutputResRefList);
    SetGlobalArrayInt(sVarRecipeSkillLevel, iCount, iSkillLevel);
}

// ====================================================================================
// Output to 2DA
// ====================================================================================

// generate a row of info representing a recipe
string FormatHeaderRow()
{
	PrintString("2DA V2.0");
	PrintString(" ");
	SetGlobalInt(VAR_ROW_NUMBER, -1);

	string sOut = "";
	sOut += PadString(5, " ");   
	sOut += PadString(15, COL_CRAFTING_CATEGORY);   
	sOut += PadString(100,COL_CRAFTING_REAGENTS);   
	sOut += PadString(20, COL_CRAFTING_TAGS);
	sOut += PadString(20, COL_CRAFTING_EFFECTS);
	sOut += PadString(50, COL_CRAFTING_OUTPUT);
	sOut += PadString(10, COL_CRAFTING_CRAFT_SKILL);
	sOut += PadString(10, COL_CRAFTING_SKILL_LEVEL);
	PrintString(sOut);
	return(sOut);
}


// generate a row of info representing a recipe
string FormatRecipeRow(string sRecipePrefix, string sCategory, int iCount)
{
	//output ("*** *** FormatRecipeRow: sRecipePrefix: " + sRecipePrefix + " sCategory:" + sCategory + " iCount:" + IntToString(iCount));
	int iRow = ModifyGlobalInt(VAR_ROW_NUMBER, 1);
	string sOut = "";
	sOut += PadString(5, IntToString(iRow));   
	sOut += PadString(15, sCategory);   
	sOut += PadString(100, GetRecipeStringElement(sRecipePrefix, COL_CRAFTING_REAGENTS	, sCategory, iCount));   
	sOut += PadString(20, GetRecipeStringElement(sRecipePrefix, COL_CRAFTING_TAGS    	, sCategory, iCount));
	sOut += PadString(20, GetRecipeStringElement(sRecipePrefix, COL_CRAFTING_EFFECTS    , sCategory, iCount));
	sOut += PadString(50, GetRecipeStringElement(sRecipePrefix, COL_CRAFTING_OUTPUT		, sCategory, iCount));
	sOut += PadString(10, IntToString(GetRecipeIntElement(sRecipePrefix, COL_CRAFTING_CRAFT_SKILL, sCategory, iCount)));
	sOut += PadString(10, IntToString(GetRecipeIntElement(sRecipePrefix, COL_CRAFTING_SKILL_LEVEL, sCategory, iCount)));
	PrintString(sOut);
	return(sOut);
}


// output all recipes for sRecipePrefix of a specific sIndex
int OutputRecipeSet(string sRecipePrefix, string sIndex)
{
	//AppendGlobalList(VAR_RECIPE_2DA_INDEXES, IntToString(GetGlobalInt(VAR_ROW_NUMBER)));
	AppendGlobalList(VAR_RECIPE_2DA_INDEXES, sIndex);
	AppendGlobalList(VAR_RECIPE_2DA_INDEXES, IntToString(1+GetGlobalInt(VAR_ROW_NUMBER)));

	//output ("*** OutputRecipeSet: sRecipePrefix: " + sRecipePrefix + " sIndex:" + sIndex);
    int iCount = 1;
    string sVarRecipeList = GetRecipeVar(sRecipePrefix, COL_CRAFTING_REAGENTS, sIndex);
    string sRecipeList;
    int bMatch = FALSE;

    sRecipeList = GetGlobalArrayString(sVarRecipeList, iCount);
    //output ("sRecipeList[" + IntToString(iCount) + "] = " + sRecipeList);

    while (sRecipeList != "") 
    {
		FormatRecipeRow(sRecipePrefix, sIndex, iCount);
		iCount++;
		sRecipeList = GetGlobalArrayString(sVarRecipeList, iCount);
		//output ("sRecipeList[" + IntToString(iCount) + "] = " + sRecipeList);
    }
    return (iCount);
}

// output all recipes of specific type, using the list of indexes to find them all
int OutputRecipeType(string sRecipePrefix, string sIndexList)
{
	//output ("OutputRecipeType: sRecipePrefix: " + sRecipePrefix + " sIndexList:" + sIndexList);
	string sIndex;
    struct sStringTokenizer stTok = GetStringTokenizer(sIndexList, ",");
	// loop through recipe index list
    while (HasMoreTokens(stTok)) {
        stTok = AdvanceToNextToken(stTok);
        sIndex = GetNextToken(stTok);
		OutputRecipeSet(sRecipePrefix, sIndex);
    }
	return TRUE;
}


// Output all recipes
int OutputRecipes()
{
	PrintString("Save the following as 'crafting.2da'");
	PrintString("===================================================");

	FormatHeaderRow();
	OutputRecipeType(MAGICAL_RECIPE_PREFIX, GetGlobalString(VAR_RECIPE_SPELLID_LIST));  	
	OutputRecipeType(MUNDANE_RECIPE_PREFIX, GetGlobalString(VAR_RECIPE_RESREF_LIST));	
	OutputRecipeType(ALCHEMY_RECIPE_PREFIX, ALCHEMY_RECIPE_SUFFIX);
	OutputRecipeType(DISTILLATION_RECIPE_PREFIX, DISTILLATION_RECIPE_SUFFIX);

	PrintString("===================================================");
	return TRUE;
}

// generate a row of info representing a recipe
string FormatIndexHeaderRow()
{
	PrintString("2DA V2.0");
	PrintString(" ");

	string sOut = "";
	sOut += PadString(5, " ");   
	sOut += PadString(15, "CATEGORY");   
	sOut += PadString(10, "START_ROW");   
	PrintString(sOut);
	return(sOut);
}

// generate a row of info representing a recipe
string FormatIndexRecipeRow(int iRow, string sCategory, string sRowIndex)
{
	//output ("*** *** FormatRecipeRow: sRecipePrefix: " + sRecipePrefix + " sCategory:" + sCategory + " iCount:" + IntToString(iCount));
	string sOut = "";
	sOut += PadString(5, IntToString(iRow));   
	sOut += PadString(15, sCategory);   
	sOut += PadString(5, sRowIndex);   
	PrintString(sOut);
	return(sOut);
}


// Output all recipes
int OutputRecipeIndex()
{
	int iRow = 0;
	PrintString("Save the following as 'crafting_index.2da'");
	PrintString("===================================================");

	FormatIndexHeaderRow();
	string s2DAIndexList = GetGlobalString(VAR_RECIPE_2DA_INDEXES);
	string sCategory, sRowIndex;
    struct sStringTokenizer stTok = GetStringTokenizer(s2DAIndexList, ",");
	// loop through recipe index list
    while (HasMoreTokens(stTok)) {
        stTok = AdvanceToNextToken(stTok);
        sCategory = GetNextToken(stTok);

        stTok = AdvanceToNextToken(stTok);
        sRowIndex = GetNextToken(stTok);
		FormatIndexRecipeRow(iRow, sCategory, sRowIndex);
		iRow++;
    }
	
	PrintString("===================================================");
	return TRUE;
}


// ====================================================================================
// Helper Functions for Using Recipes
// ====================================================================================

// return a list of tags to represent a stack of items
// never starts or ends w/ a seperator, so can be use just like a single tag for list making
string GetExpandedTags(object oItem)
{
	string sTag = GetTag(oItem);
	int iStackSize = GetItemStackSize(oItem);
	
	if (iStackSize < 1)
		iStackSize = 1; // just in case...
		
	string sRet = MakeRepeatedItemList (sTag, iStackSize);
	return (sRet);
}

// these items can always be part of recipes and thus never the target of an effect
int GetInExceptionList(string sTag)
{
    return (sTag == "NW_IT_MNECK022"); // Gold necklace - for Mephasm charm
}
	
// get all items in specified categories and sort the tags into an alphabetical list
//string GetSortedItemList(int iIncludeCategories = ITEM_CATEGORY_ALL, object oTarget=OBJECT_SELF)
string GetSortedItemList(int bIsEnchanting = FALSE, object oTarget=OBJECT_SELF)
{
    object oItem =  GetFirstItemInInventory(oTarget);
    string sItemList = "";

    while (GetIsObjectValid(oItem))
    {
        if (!bIsEnchanting 				// if not enchanting, include everything
			|| !GetIsEquippable(oItem)	// if not equippable then must be part of recipe
            || GetInExceptionList(GetTag(oItem))) // equippable but in exception list
        {
            if (sItemList == "")
                sItemList += GetExpandedTags(oItem);
            else
                sItemList += FormListElement(GetExpandedTags(oItem));
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    sItemList = Sort(sItemList);
    return (sItemList);
}

// Get the first equippable item, if any.
object GetFirstEquippableItem(object oTarget=OBJECT_SELF)
{
    object oItem =  GetFirstItemInInventory(oTarget);

    while (GetIsObjectValid(oItem))
    {
        if (GetIsEquippable(oItem)	// if not equippable then must be part of recipe
            && !GetInExceptionList(GetTag(oItem))) // equippable but in exception list
        {
			break;
        }
        oItem = GetNextItemInInventory(oTarget);
    }
    return (oItem);
}


// Creates a sorted list from an inventory
// return index of the sorted list for this sRecipePrefix and sIndex, -1 if not found
//int GetInventoryRecipeMatch(string sRecipePrefix, string sIndex, int iIncludeCategories = ITEM_CATEGORY_ALL)
int GetInventoryRecipeMatch(string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID)
{
    // list of reagent items in forge
	int bIsEnchanting = GetIsObjectValid(oItem);
    string sSortedItemList = GetSortedItemList(bIsEnchanting);
	int iRecipeMatch;

	iRecipeMatch = GetRecipeMatch(sSortedItemList, sRecipePrefix, sIndex, oItem);
	
	return (iRecipeMatch);
}


// return index of sSortedItemList for this sRecipePrefix and sIndex, -1 if not found
int GetRecipeMatch(string sSortedItemList, string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID)
{
    //output ("sSortedItemList = " + sSortedItemList);
    int iCount;

	// do 2da look up instead if not using variables.
	if (!UsingVariables())
	{
		iCount = GetCrafting2DARecipeMatch(sSortedItemList, sRecipePrefix, sIndex, oItem);
		//return (iCount);
	}
    else 
    {
        iCount = GetGlobalVarRecipeMatch(sSortedItemList, sRecipePrefix, sIndex, oItem);
    }
    return (iCount);
}


// returns the start and end index rows for this category
struct IntVector GetRowIndexes(string sCategory)
{
	int iRow = -1;
	struct IntVector iv;
	iv.x = -1;
	iv.y = -1;
	int iIndexRow;
    
    if (sCategory == "1081") // the imbue spell works as a "key" for any spell based recipe.
    {
        int bLastSpellIndexColFound = FALSE; 
        int iCat;
        while (bLastSpellIndexColFound == FALSE)    
        {
		    iv.x = 0;
            iIndexRow++; // row 0 always has START_ROW == 0, so we start with Row 1 where START_ROW > 0. 
            iCat = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_CATEGORY, iIndexRow));
            if (iCat==0 && iIndexRow!=40)					// Lord Graves fix - do not check row #40 in the stock Crafting_Index.2da, (kevL)
            { // the previous one was the last spell index.	// the Acid Fog triggerspell: it *is* spellId 0, and should get a pass here.
                bLastSpellIndexColFound = TRUE;
		        iv.y = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iIndexRow))-1;
            }
        }
    }
    else
    {
    	iIndexRow = Search2DA(CRAFTING_INDEX_2DA, COL_CRAFTING_CATEGORY, sCategory);
    	if (iIndexRow == -1)
    	{
    		output ("index not found.");
    	}
    	else
    	{
    		iv.x = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iIndexRow));
     		// ending row is 1 less than the value of the next start row
    		iv.y = StringToInt(Get2DAString(CRAFTING_INDEX_2DA, COL_CRAFTING_START_ROW, iIndexRow+1))-1;
    		if (iv.y == -1)
    			iv.y = 10000; // go to the end.
    	}
    }        
	return (iv);
}

// return index of sSortedItemList for this sRecipePrefix and sIndex, -1 if not found
// if an iItenType is passed in then it must also match the AffectedItemsTypes (Column TAGS)
int GetCrafting2DARecipeMatch(string sSortedItemList, string sRecipePrefix, string sCategory, object oItem = OBJECT_INVALID)
{
    //output ("sSortedItemList = " + sSortedItemList);
	string sItemsAffected;
	struct IntVector iv = GetRowIndexes(sCategory);
	int iRow = iv.x;	// Crafting.2DA Row Number
	
	//if (iv.x != -1)	
	//	iCrafting2DARow = Search2DA(CRAFTING_2DA, COL_CRAFTING_REAGENTS, sSortedItemList, iv.x, iv.y);
	while (iRow != -1)
	{
		iRow = Search2DA(CRAFTING_2DA, COL_CRAFTING_REAGENTS, sSortedItemList, iRow, iv.y); // find a match for cat + rec.
		
		// check if itemtype is also a match (but don't bother if we passed the search returned no more matches) 
		if (iRow != -1)
		{
			sItemsAffected = Get2DAString(CRAFTING_2DA, COL_CRAFTING_TAGS, iRow);
			// note that if this is category 0 (ITEM_CATEGORY_NONE) then OBJECT_INVALID will match.
			if (GetMatchesAffectedItems(oItem, sItemsAffected))
			{
				// we found a matching row with an appropriate affected item!!!
				break;
			}
		}
		// we didn't break out, so lets go on to the next row (but not past the max)
		if(iRow >= 0)
		{
			iRow++;
		}	
		if (iRow > iv.y)	
			iRow = -1;
	}
	
    return (iRow);
}


int GetGlobalVarRecipeMatch(string sSortedItemList, string sRecipePrefix, string sIndex, object oItem = OBJECT_INVALID)
{
    int iCount = 1;
    string sVarRecipeList = GetRecipeVar(sRecipePrefix, COL_CRAFTING_REAGENTS, sIndex);
    string sVarAffectedItems = GetRecipeVar(sRecipePrefix, COL_CRAFTING_TAGS, sIndex);
    string sRecipeList;
    int bMatch = FALSE;
	string sItemsAffected;

    sRecipeList = GetGlobalArrayString(sVarRecipeList, iCount);
    //output ("sRecipeList[" + IntToString(iCount) + "] = " + sRecipeList);

    while ((sRecipeList != "") && (bMatch == FALSE))
    {
        if (sSortedItemList == sRecipeList)
		{	// check if itemtype is also a match 
    		sItemsAffected = GetGlobalArrayString(sVarAffectedItems, iCount);
			// note that if this is category 0 (ITEM_CATEGORY_NONE) then OBJECT_INVALID will match.
			if (GetMatchesAffectedItems(oItem, sItemsAffected))
			{
	            bMatch = TRUE;
				break;
			}
        }
        iCount++;
        sRecipeList = GetGlobalArrayString(sVarRecipeList, iCount);
        //output ("sRecipeList[" + IntToString(iCount) + "] = " + sRecipeList);
    }
    if (bMatch == FALSE)
        iCount = -1;
        
    return (iCount);
}

int GetIsItemOfBaseTypes(object oItem, string sListOfBaseTypes)
{
    int iBaseType = GetBaseItemType(oItem);
    string sElement = IntToString(iBaseType);
    return (GetIsInList(sListOfBaseTypes, sElement));
}

// object oItem: the item to check
// string sItemsAffected: will either be a number representing a category, or a list preceded with a "B" indicated a list of Base Item Types
int GetMatchesAffectedItems(object oItem, string sItemsAffected)
{
	int iRet = FALSE;

    int iItemCategory = StringToInt(sItemsAffected);
    string sListOfBaseTypes = "";
    int bIsBaseTypeList = FALSE;
	
    if (GetStringLeft(sItemsAffected, 1) == "B")
    {
        bIsBaseTypeList = TRUE;
        sListOfBaseTypes = GetStringRight(sItemsAffected, GetStringLength(sItemsAffected)-1);
		output ("GetMatchesAffectedItems(): sListOfBaseTypes=" + sListOfBaseTypes);
    }
    
	if (bIsBaseTypeList && GetIsItemOfBaseTypes(oItem, sListOfBaseTypes))
	    iRet = TRUE;
	else if (!bIsBaseTypeList && GetIsItemCategory(oItem, iItemCategory))
	    iRet = TRUE;
		
    return iRet;
}

// looks for first object in inventory with sTagSuffix and returns full tag.
string FindMundaneIndexTag(string sTagPrefix, object oObject=OBJECT_SELF)
{
    object oItem = GetFirstItemInInventory(oObject);
	int iItemCount=0;
	int bFound = FALSE;
	string sRet = "";
	int iPrefixSize = GetStringLength(sTagPrefix);

    while (GetIsObjectValid(oItem) && !bFound)
    {
       	if (GetStringLeft(GetTag(oItem), iPrefixSize) == sTagPrefix)
       	{
			bFound = TRUE;
			sRet = GetTag(oItem);
       	}
		else
       		oItem =  GetNextItemInInventory(oObject);
    }
    return sRet;
}

// Count the number of item properties
int GetNumberItemProperties(object oItem)
{
	int iItemPropCount = 0;
	//Get the first itemproperty
	itemproperty ipLoop=GetFirstItemProperty(oItem);
	
	while (GetIsItemPropertyValid(ipLoop))
	{
		iItemPropCount++;
	   	ipLoop=GetNextItemProperty(oItem);
	}
	return (iItemPropCount);
}


// Count the number of item properties
// Used slot costs assigned to the property type
// item restrictions, item penalties, and trivial properties will no longer count against the limit
int GetPropSlotsUsed(object oItem)
{
	int iItemPropCount = 0;
	int iPropCost = 0;
	int iType;
	itemproperty ipLoop = GetFirstItemProperty(oItem);
	
	while (GetIsItemPropertyValid(ipLoop))
	{
		iType = GetItemPropertyType(ipLoop);
		iPropCost = StringToInt(Get2DAString(ITEM_PROP_DEF_2DA, COL_ITEM_PROP_DEF_SLOTS, iType));
		iItemPropCount = iItemPropCount + iPropCost;
	   	ipLoop = GetNextItemProperty(oItem);
	}
	return (iItemPropCount);
}

// Determine Max number of item propertiew we'll allow to be placed on an item.
int GetMaxProperties(object oItem, int iSpellID, object oPC)
{
	int nRet;
	if (GetHitDice(oPC) < 20)
		nRet = 3;
	else
		nRet = 4;
		
	return (nRet);						
}


// ====================================================================================
// Functions for Using Recipes
// ====================================================================================

// Spell cast at workstation
// Notes: 
// This covers two types of crafting:
// 1. Enchanting Item requires a set of reagents, an item to work on, and a spell to activate it.	
// 2. Constructing Item requires a set of reagents and creates a new item.	
//	
// Reagents can not be equippable items including weapons, armor, shields, rings, amulets, etc.  These are ignored when looking at reagent components
// if more than 1 equippable item is included with the reagents, the one that will be inspected/affected is not defined.
void DoMagicCrafting(int iSpellID, object oPC)
{
	//SpawnScriptDebugger();
	string sIndexTag =  IntToString(iSpellID);
	object oItem = GetFirstEquippableItem(); // Enchanting will always occur on the first equippable item found
	
    // is there a match for this spell/reagent combo?
    //int iRecipeMatch = GetInventoryRecipeMatch(MAGICAL_RECIPE_PREFIX, sIndexTag, ITEM_CATEGORY_OTHER);
   	int iRecipeMatch = GetInventoryRecipeMatch(MAGICAL_RECIPE_PREFIX, sIndexTag, oItem);
    
    //output("iRecipeMatch = " + IntToString(iRecipeMatch));
    if (iRecipeMatch == -1)
    {
		ErrorNotify(oPC, ERROR_RECIPE_NOT_FOUND);
        return;
    }

	string sItemsAffected 		= GetCraftingStringData(MAGICAL_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_TAGS, iRecipeMatch);
	string sItemTemplateList 	= GetCraftingStringData(MAGICAL_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_OUTPUT, iRecipeMatch);
	int iReqFeat 				= GetCraftingIntData(MAGICAL_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_CRAFT_SKILL, iRecipeMatch);
	int iReqCasterLevel 		= GetCraftingIntData(MAGICAL_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_SKILL_LEVEL, iRecipeMatch);
 	string sEncodedEffects 		= GetCraftingStringData(MAGICAL_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_EFFECTS, iRecipeMatch);
 

	//output ("DoMagicCrafting() sItemTemplate = " + sItemTemplate);
    int bItemConstruction  = TRUE;
	if (sItemTemplateList == "")	// nothing listed to construct, so this must be enchanting.
		bItemConstruction = FALSE;
        
    int iItemCategory = StringToInt(sItemsAffected);  // enchanted wondrous items will start with a "B", causeing this to be 0.

	// Backwards semi-compatibility with older 2DAs
	if (iReqFeat == 0)
	{
		if ((iItemCategory == ITEM_CATEGORY_WEAPON) || (iItemCategory == ITEM_CATEGORY_ARMOR_SHIELD)) // wondrous items are any except categories 1 and 2 (weapons and armor)
			iReqFeat = FEAT_CRAFT_MAGIC_ARMS_AND_ARMOR;
		else			
			iReqFeat = FEAT_CRAFT_WONDROUS_ITEMS;
    }
	
	// +++ check additional criteria 
	
    // check caster has feat
    if(!GetHasFeat(iReqFeat,oPC))
	{		
		int iError;
		if (iReqFeat == FEAT_CRAFT_WONDROUS_ITEMS)
			iError	= ERROR_NO_CRAFT_WONDROUS_FEAT;
		else if (iReqFeat == FEAT_CRAFT_MAGIC_ARMS_AND_ARMOR)
			iError	= ERROR_NO_CRAFT_MAGICAL_FEAT;
		else
		{
			iError	= ERROR_RECIPE_NOT_FOUND;
		}			
  		ErrorNotify(oPC, iError);
		return;
	}
    
    // If enchanting an item, find the item.
	if (bItemConstruction == FALSE)
    {
	    // does the tag match requirements?
	    //oItem = GetTargetItem(sItemsAffected);
	    //output("oItem = " + GetName(oItem));
	
		// I don't think this will occur anymore.			
	    if (!GetIsObjectValid(oItem))
	    {
	        ErrorNotify(oPC, ERROR_TARGET_NOT_FOUND_FOR_RECIPE);
	        return;
	    }
		
		// is this prop legal for this item (just check the first prop)
		int nPropID = GetIntParam(sEncodedEffects, 0);
		int nBaseItemType = GetBaseItemType(oItem);
		if (!GetIsLegalItemProp(nBaseItemType, nPropID))
		{
	        ErrorNotify(oPC, ERROR_TARGET_NOT_LEGAL_FOR_EFFECT);
	        return;
		}
		
		// examine target - can more item props be placed?
		int iMaxPropCount = GetMaxProperties(oItem, iSpellID, oPC);
		int nMaxEnchantError = ERROR_TARGET_HAS_MAX_ENCHANTMENTS_NON_EPIC;
		int iItemPropCount = GetPropSlotsUsed(oItem); //GetNumberItemProperties(oItem);
		if (iItemPropCount >= iMaxPropCount)
	    {
			// can't add stuff, but can still replace an old effect.
			if (!GetAreAllEncodedEffectsAnUpgrade(oItem, sEncodedEffects))
			{
				//output("FAILURE");
				if (iMaxPropCount == 4)
					nMaxEnchantError = ERROR_TARGET_HAS_MAX_ENCHANTMENTS;
				
				ErrorNotify(oPC, nMaxEnchantError);
       			return;
			}
		}
		
	}
	int nCasterLevel = GetCasterLevel(oPC);
	if (GetGlobalInt(CAMPAIGN_SWITCH_CRAFTING_USE_TOTAL_LEVEL) == TRUE)
	{
		int nTotalLevel = GetTotalLevels(oPC, FALSE);
		if (nCasterLevel < nTotalLevel)
			nCasterLevel = nTotalLevel;
	}
	
	// check we are caster of sufficient level
    if(nCasterLevel < iReqCasterLevel)
	{		
  		ErrorNotify(oPC, ERROR_INSUFFICIENT_CASTER_LEVEL);
		return;
	}
		
	// +++ all criteria good to go, do effects
    DestroyItemsInInventory(TRUE); // TRUE = don't destroy equippable items (they can never be part of the recipe), so oItem is safe.

	if (bItemConstruction)
	{	
		CreateListOfItemsInInventory(sItemTemplateList, OBJECT_SELF); // this could be sucked up by DestroyItemsInInventory() so must be done after!
	}
	else
	{
		ApplyEncodedEffectsToItem(oItem, sEncodedEffects);
	}

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_MAGIC), OBJECT_SELF); // was GetLastSpellCaster()	
	SuccessNotify(oPC);
	
	// masterwork weapons can be renamed on each enchanting
	// everything else, only on the first enchanting
	// Renaming Item only applies to Magic weapons and armor
	// ChazM 6/29/06 - everything can be renamed upon enchanting, unless it has a special var.
	if (!bItemConstruction) // && 	
		//( (iItemPropCount <= 0) || (GetStringLeft(GetTag(oItem), 3) == "mst")) )
	{		
		SetEnchantedItemName(oPC, oItem);
	}		
}



// Smith Hammer used at workstation
// Notes: 
// Mundane crafting requires a set of reagents, a specific skill level, and a smith hammer to activate it. 
// Reagents can be of any item type.
void DoMundaneCrafting(object oPC)
{
    // is there a match for this recipe?
	string sIndexTag = FindMundaneIndexTag(MOLD_PREFIX);
    output("Index (Mold) is:" + sIndexTag);
	
	if (sIndexTag == "")
    {
  		ErrorNotify(oPC, ERROR_MISSING_REQUIRED_MOLD);
        return;
    }

    int iRecipeMatch = GetInventoryRecipeMatch(MUNDANE_RECIPE_PREFIX, sIndexTag);
    output("iRecipeMatch = " + IntToString(iRecipeMatch));
    if (iRecipeMatch == -1)
    {
  		ErrorNotify(oPC, ERROR_RECIPE_NOT_FOUND);
        return;
    }

    // meet required crafting skill?
	int iSkill 		= GetCraftingIntData(MUNDANE_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_CRAFT_SKILL, iRecipeMatch);
	int iSkillReq 	= GetCraftingIntData(MUNDANE_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_SKILL_LEVEL, iRecipeMatch);
	
	int iPCSkill = GetSkillRank(iSkill, oPC);		
	if (iPCSkill < iSkillReq)
	{	// has insufficient skill
		int iError = ERROR_INSUFFICIENT_CRAFT_WEAPON_SKILL;
		if (iSkill == SKILL_CRAFT_ARMOR) {
			iError = ERROR_INSUFFICIENT_CRAFT_ARMOR_SKILL;
		}
		else if(iSkill == SKILL_CRAFT_TRAP) {
			iError = ERROR_INSUFFICIENT_CRAFT_TRAP_SKILL;
		}
   		ErrorNotify(oPC, iError);
		return;
	}

    DestroyItemsInInventory();

	//CreateOutput(iRecipeMatch, OBJECT_SELF);
	string sItemTemplateList = GetCraftingStringData(MUNDANE_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_OUTPUT, iRecipeMatch);
	CreateListOfItemsInInventory(sItemTemplateList, OBJECT_SELF);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_BLACKSMITH), OBJECT_SELF);	// Charles, the parameter passed to EffectVisualEffect needs to be changed at your leisure
	SuccessNotify(oPC);
}


// Mortar and Pestle used at Alchemy workstation
// Notes: 
// Alchemy crafting requires a set of reagents, a specific skill level in Alchemy, and a Mortar & Pestle to activate it. 
// Reagents can be of any item type.
void DoAlchemyCrafting(object oPC)
{
    // is there a match for this recipe?
	string sIndexTag = ALCHEMY_RECIPE_SUFFIX; // alchemy has no index

    int iRecipeMatch = GetInventoryRecipeMatch(ALCHEMY_RECIPE_PREFIX, sIndexTag);
    output("iRecipeMatch = " + IntToString(iRecipeMatch));
    if (iRecipeMatch == -1)
    {
   		ErrorNotify(oPC, ERROR_RECIPE_NOT_FOUND);
        return;
    }

    // meet required crafting skill?
	int iSkillReq = GetCraftingIntData(DISTILLATION_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_SKILL_LEVEL, iRecipeMatch);
	int iPCSkill = GetSkillRank(SKILL_CRAFT_ALCHEMY, oPC);		
	if (iPCSkill < iSkillReq)
	{	// has insufficient skill
   		ErrorNotify(oPC, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		return;
	}
	
    DestroyItemsInInventory();

	//CreateOutput(iRecipeMatch, OBJECT_SELF);
	string sItemTemplateList = GetCraftingStringData(ALCHEMY_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_OUTPUT, iRecipeMatch);
	CreateListOfItemsInInventory(sItemTemplateList, OBJECT_SELF);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_ALCHEMY), OBJECT_SELF);	// Charles, the parameter passed to EffectVisualEffect needs to be changed at your leisure
	SuccessNotify(oPC);
}

// Mortar and Pestle used on an item
// Notes: 
// Distillation requires an acted upon item (reagent), a specific skill level in Alchemy, and a Mortar & Pestle to activate it. 
// Reagent can be of any item type.
void DoDistillation(object oItem, object oPC)
{
    // is there a match for this recipe?
	string sItemTag = GetTag(oItem);
	string sIndexTag = DISTILLATION_RECIPE_SUFFIX; // distillation has no index

    int iRecipeMatch = GetRecipeMatch(sItemTag, DISTILLATION_RECIPE_PREFIX, sIndexTag);
    output("iRecipeMatch = " + IntToString(iRecipeMatch));
    if (iRecipeMatch == -1)
    {
   		ErrorNotify(oPC, ERROR_ITEM_NOT_DISTILLABLE);
        // output("No match found for this item");
        return;
    }

	// lookup skill req
	int iSkillReq = GetCraftingIntData(DISTILLATION_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_SKILL_LEVEL, iRecipeMatch);

	string sItemTemplateList = GetCraftingStringData(DISTILLATION_RECIPE_PREFIX, sIndexTag, COL_CRAFTING_OUTPUT, iRecipeMatch);
	ExecuteDistillation(iSkillReq, oItem, oPC, sItemTemplateList);
}
	
void ExecuteDistillation(int iSkillReq, object oItem, object oPC, string sItemTemplateList)
{
	int iPCSkill = GetSkillRank(SKILL_CRAFT_ALCHEMY, oPC);		
	if (iPCSkill < iSkillReq)
	{	// has insufficient skill
   		ErrorNotify(oPC, ERROR_INSUFFICIENT_CRAFT_ALCHEMY_SKILL);
		return;
	}

	int iStackSize = GetItemStackSize(oItem); // we can distill multiple objects at once.
	DestroyObject(oItem);
	int i;
	for (i=1; i<= iStackSize; i++)
	{
		CreateListOfItemsInInventory(sItemTemplateList, oPC);
	}
			
    //ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_SELF), oPC);	
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_CRAFT_SELF), GetLocation(oPC));
	SuccessNotify(oPC);
}	

void SuccessNotify(object oPC, int iStrRef=OK_CRAFTING_SUCCESS)
{
	SendMessageToPCByStrRef(oPC, iStrRef);
}

void ErrorNotify(object oPC, int iErrorStrRef)
{
	SendMessageToPCByStrRef(oPC, iErrorStrRef);
}	


//PEH-OEI 05/24/06
//This script function displays a text input box popup on the client of the
//player passed in as the first parameter.
//////
// oPC           - The player object of the player to show this message box to
// nMessageStrRef- The STRREF for the Message Box message. 
// sMessage      - The text to display in the message box. Overrides anything 
//               - indicated by the nMessageStrRef
// sOkCB         - The callback script to call if the user clicks OK, defaults
//               - to none. The script name MUST start with 'gui'
// sCancelCB     - The callback script to call if the user clicks Cancel, defaults
//               - to none. The script name MUST start with 'gui'
// bShowCancel   - If TRUE, Cancel Button will appear on the message box.
// sScreenName   - The GUI SCREEN NAME to use in place of the default message box.
//               - The default is SCREEN_STRINGINPUT_MESSAGEBOX 
// nOkStrRef     - The STRREF to display in the OK button, defaults to OK
// sOkString     - The string to show in the OK button. Overrides anything that
//               - nOkStrRef indicates if it is not an empty string
// nCancelStrRef - The STRREF to dispaly in the Cancel button, defaults to Cancel.
// sCancelString - The string to display in the Cancel button. Overrides anything
//				 - that nCancelStrRef indicates if it is anything besides empty string
// sDefaultString- The text that gets copied into the input area,
//				 - used as a default answer
/*
void DisplayInputBox( object oPC, int nMessageStrRef,
						string sMessage, string sOkCB="", 
                        string sCancelCB="", int bShowCancel=FALSE, 
                        string sScreenName="",
                        int nOkStrRef=0, string sOkString="",
                        int nCancelStrRef=0, string sCancelString="",
                        string sDefaultString="", string sVariableString="" );
*/

// oPC = creator of the enchanted item.
// oItem = the enchanted item			
void SetEnchantedItemName(object oPC, object oItem)
{
	int nMessageStrRef 		= 181743;
	string sMessage 		= ""; // "Please rename the item.";
	string sOkCB			= "gui_name_enchanted_item";
	string sCancelCB		= "";
	int bShowCancel			= FALSE; 
	string sScreenName		= "";
	int nOkStrRef			= 181744;
	string sOkString		= "";
	int nCancelStrRef		= 181745;
	string sCancelString	= "";
	string sDefaultString 	= GetFirstName(oItem);
	string sVariableString	= "";
	

	// the gui script will always run on the owned PC, regardless of who the player has possessed.
	object oObj = GetOwnedCharacter(oPC);
	SetLocalObject(oObj, VAR_ENCHANTED_ITEM_OBJECT, oItem);

	DisplayInputBox( oPC, nMessageStrRef, sMessage, sOkCB, sCancelCB, bShowCancel, 
                     sScreenName, nOkStrRef, sOkString, nCancelStrRef, sCancelString,
                     sDefaultString, sVariableString);
}

//void main() {}
		