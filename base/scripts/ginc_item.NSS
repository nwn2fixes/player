// ginc_item
/*
    Item/Inventory/Store related functions
*/
// ChazM 9/29/05
// ChazM 10/12/05 - added Remember, Restore, and Give family of functions
// ChazM 1/20/06 - added EquipRandomArmorFromInventory(), ListInventory(), GetInventoryItemOfBaseType()
// ChazM 1/31/06 - included "x2_inc_itemprop", added GetItemCategory(), GetIsItemCategory(), GetIsWeapon(), GetIsShield(), GetIsArmorOrShield()  
// ChazM 3/15/06 - added TransferItem(), modified GiveEquippedItem(), GiveAllInventory(), GiveEverything()
// ChazM 6/27/06 - added UnequipSlot()
// ChazM 6/29/06 - fixed UnequipSlot()
// ChazM 8/8/06 - Moved GetState() & SetState() to ginc_math
// ChazM 8/18/06 - added GetSlotOfEquippedItem(), GetIsCreatureSlot()
// ChazM 8/30/06 - added N2_GetNPCEasyMark(), N2_AppraiseOpenStore()
// ChazM 9/29/06 - Modified GetItemCategory() - now uses IP functions
// ChazM 2/12/07 - added support for bDisplayFeedback
// ChazM 3/8/07 - RecreateItemsFromBlueprint() moved here
// ChazM 3/8/07 - Added IdentifyEquippedItems(), IdentifyInventory()
// ChazM 3/22/07 - fixes to GetIsItemCategory(), GetItemCategory()
// ChazM 5/16/07 - added VoidCreateItemOnObject()
// ChazM 6/22/07 - EquipNewItem() now identifies the item before equipping.
// ChazM 7/5/07 - added DestroyItemInSlot(), added new bDestroyPrev param to EquipNewItem()
// ChazM 7/11/07 - fix for RecreateItemsFromBlueprint() - prevent deletion of non full stacks.
// ChazM 7/20/07 - Added GetItemInInventory()

#include "ginc_debug"	
#include "x2_inc_itemprop"
#include "ginc_math"
// void main(){}

//-------------------------------------------------
// Constants
//-------------------------------------------------
	
const string LAST_SLOT_NUM	=	"LastSlotNum";
const string LAST_SLOT_OBJ	=	"LastSlotObj";

// item categories - weapon, armor/shield, other
const int ITEM_CATEGORY_NONE    		= 0;
const int ITEM_CATEGORY_WEAPON  		= 1;
const int ITEM_CATEGORY_ARMOR_SHIELD   	= 2;
const int ITEM_CATEGORY_OTHER   		= 4; // everything not armor & weapons
const int ITEM_CATEGORY_MISC_EQUIPPABLE = 8; // amulet, ring, cloak, etc.

// derived item categories
const int ITEM_CATEGORY_ALL   			= 7; // ITEM_CATEGORY_WEAPON + ITEM_CATEGORY_ARMOR_SHIELD + ITEM_CATEGORY_OTHER
const int ITEM_CATEGORY_EQUIPPABLE      = 11; // ITEM_CATEGORY_MISC_EQUIPPABLE + ITEM_CATEGORY_ARMOR_SHIELD + ITEM_CATEGORY_WEAPON


const string PARAM_NO_DRR               = "N2_NO_DRR"; // Set to true on irem to prevent item from being recreated from blueprint
const string VAR_PREFIX_RECREATE_LIST   = "N2_RecreateList";


//-------------------------------------------------
// Function Prototypes
//-------------------------------------------------
	
// item functions
int GetIsItemEquipped(string sItemTag, object oCreature, int bExactMatch = TRUE);
int GetPartyMemberHasEquipped(string sItemTag, object oPartyMember, int bPCOnly=TRUE, int bExactMatch = TRUE);
int RemoveItem (object oCreature, string sItemTag);
void CreateItemOnFaction(object oPC, string sItemResRef, int bPCOnly=TRUE);
void DestroyItemInSlot(object oTarget, int nEquipSlot);
void EquipNewItem(object oTarget, string sItemResRef, int iEquipSlot, int bDestroyPrev=FALSE);
//void EquipNewItem(object oTarget, string sItemResRef, int iEquipSlot);
void DoEquipmentUpgrade(string sTargetTag, string sItemResRef, int iEquipSlot);
void TransferItem(object oGiver, object oReceiver, object oInventoryItem, int bDisplayFeedback=TRUE);

void RememberEquippedItem(object oOwner, int iSlot);
void RememberEquippedItems(object oOwner);
void RestoreEquippedItem(object oOwner, object oInventoryItem, int bReset=TRUE);
void RestoreEquippedItems(object oOwner, int bReset=TRUE);

void UnequipSlot(object oOwner, int iSlot);
void GiveEquippedItem(object oGiver, object oReceiver, int iSlot, int bDisplayFeedback=TRUE);
void GiveAllEquippedItems(object oGiver, object oReceiver, int bDisplayFeedback=TRUE);
void GiveAllInventory(object oGiver, object oReceiver, int bDisplayFeedback=TRUE);
void GiveEverything(object oGiver, object oReceiver, int bDisplayFeedback=TRUE);

int GetItemCategory(object oItem);
int GetIsItemCategory(object oItem, int iItemCategory);
int GetIsWeapon(object oItem);
int GetIsShield(object oItem);
int GetIsArmorOrShield(object oItem);
int GetIsEquippable(object oItem);
int GetIsMiscEquippable(object oItem);

int GetSlotOfEquippedItem(object oItem, object oCreature);
int GetIsCreatureSlot(int iSlot);


// *** Store related
int N2_GetNPCEasyMark(object oTarget);
void N2_AppraiseOpenStore(object oStore, object oPC, int nBonusMarkUp = 0, int nBonusMarkDown = 0);

// Item Identification
void IdentifyEquippedItems(object oCreature=OBJECT_SELF);
void IdentifyInventory(object oCreature=OBJECT_SELF);

// Void converted functions
void VoidCreateItemOnObject(string sItemTemplate, object oTarget = OBJECT_SELF, int nStackSize = 1, int bInfinite = FALSE);


//-------------------------------------------------
// Function Definitions
//-------------------------------------------------

// returns true if item equipped
//  sItemTag - tag of the item to look for
//  oPartyMember - creature whose equipment is to be searched.
//  bExactMatch - whether or not to search tags with exact or partial matches
int GetIsItemEquipped(string sItemTag, object oCreature, int bExactMatch = TRUE)
{
    object oItem;
    string sFoundTag;
	int nSlot;
	
    for (nSlot=0; nSlot<NUM_INVENTORY_SLOTS; nSlot++)
    {
        oItem = GetItemInSlot(nSlot, oCreature);

        if (TRUE == GetIsObjectValid(oItem))
		{
			sFoundTag = GetTag(oItem);

			if (FALSE == bExactMatch)
			{
				if (FindSubString(sFoundTag, sItemTag) != -1)
					return TRUE;
			}
			else
			{
				if (sFoundTag == sItemTag)
					return TRUE;
			}
        }
    }
    return FALSE;
}

// returns true if any party member has item equipped
//  sItemTag - tag of the item to look for
//  oPartyMember - Any member of the party
//  bPCOnly - Include only PC's or everyone in the party.  Default is only the PCs.
int GetPartyMemberHasEquipped(string sItemTag, object oPartyMember, int bPCOnly=TRUE, int bExactMatch = TRUE)
{
    object oMember = GetFirstFactionMember(oPartyMember, bPCOnly); // Needed GetFirstPC() to run through PC List

    while (oMember != OBJECT_INVALID)
    {
        if (GetIsItemEquipped(sItemTag, oMember, bExactMatch))
            return TRUE;
        oMember = GetNextFactionMember(oPartyMember, bPCOnly);
    }
    return FALSE;
}

// Take item from player inventory if possessed
// currently if stackable, takes whole stack.
// return true if object was available to be removed
int RemoveItem (object oCreature, string sItemTag)
{
	int iRet = FALSE;
    object oItemToTake = GetItemPossessedBy(oCreature, sItemTag);
    if(GetIsObjectValid(oItemToTake))
	{
        DestroyObject(oItemToTake);
		iRet = TRUE;
	}
	return iRet;
}


void CreateItemOnFaction(object oPC, string sItemResRef, int bPCOnly=TRUE)
{
    object oPartyMem = GetFirstFactionMember(oPC, bPCOnly);
    while (GetIsObjectValid(oPartyMem)) 
	{
		CreateItemOnObject(sItemResRef, oPC);
        oPartyMem = GetNextFactionMember(oPC, bPCOnly);
    }
}

void DestroyItemInSlot(object oTarget, int nEquipSlot)
{
	object oItem = GetItemInSlot(nEquipSlot, oTarget);
	PrettyDebug("DestroyItemInSlot() slot =" + IntToString(nEquipSlot) + " item=" + GetName(oItem));
	if (GetIsObjectValid(oItem))
		DestroyObject(oItem);
}
	
		
// give oTarget specified equipment and put in specified slot
void EquipNewItem(object oTarget, string sItemResRef, int iEquipSlot, int bDestroyPrev=FALSE)
{
		
	object oItem = CreateItemOnObject(sItemResRef, oTarget, 1);
	PrettyDebug("EquipNewItem() slot =" + IntToString(iEquipSlot) + " item=" + GetName(oItem));
	
	// can't equip an unidentified item, so make sure it is identified.
	SetIdentified(oItem, TRUE);
	//Equip item (need time to allow item to appear)
	if (iEquipSlot >= 0)
	{
		if (bDestroyPrev)
			DestroyItemInSlot(oTarget, iEquipSlot);
		DelayCommand(0.5, AssignCommand(oTarget, ActionEquipItem(oItem, iEquipSlot)));
	}		
}



// give all w/ sTargetTag, specified equipment and put in specified slot
void DoEquipmentUpgrade(string sTargetTag, string sItemResRef, int iEquipSlot)
{
	int i = 0;
	object oTarget = GetObjectByTag(sTargetTag, i);
	while (GetIsObjectValid(oTarget))
	{
//		PrintString("Equiping NPC " + GetName(oTarget) + " - index " + IntToString(i));
		EquipNewItem(oTarget, sItemResRef, iEquipSlot);
		oTarget = GetObjectByTag(sTargetTag, ++i);
	}
	DebugMessage("Total number of creatures updated: " + IntToString(i));
}


// store info on item about current owner and slot equipped
void RememberEquippedItem(object oOwner, int iSlot)
{
	object oInventoryItem = GetItemInSlot(iSlot, oOwner);
	if (oInventoryItem != OBJECT_INVALID)
	{
		SetLocalInt(oInventoryItem, LAST_SLOT_NUM, iSlot + 1); // Nwn2Fix
		SetLocalObject(oInventoryItem, LAST_SLOT_OBJ, oOwner);
	}
}

// store info on all equipped items of owner
void RememberEquippedItems(object oOwner)
{
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
		RememberEquippedItem(oOwner, iSlot);
    }
}


// restore item to slot last remembered
void RestoreEquippedItem(object oOwner, object oInventoryItem, int bReset=TRUE)
{
	int iSlot = GetLocalInt(oInventoryItem, LAST_SLOT_NUM);
	//object oOrigOwner = GetLocalObject(oInventoryItem, LAST_SLOT_OBJ);

	if (iSlot > 0)
	{
	    AssignCommand(oOwner, ActionEquipItem(oInventoryItem, iSlot - 1)); // Nwn2Fix
		if (bReset)
		{
			DeleteLocalInt(oInventoryItem, LAST_SLOT_NUM);
			DeleteLocalObject(oInventoryItem, LAST_SLOT_OBJ);
		}
	}
}

// Restore all inventory items to equipment slot last remembered (if any)
void RestoreEquippedItems(object oOwner, int bReset=TRUE)
{
    object oInventoryItem = GetFirstItemInInventory(oOwner);
	object oLeftHandItem;
	int iSlot;
	
	while (oInventoryItem != OBJECT_INVALID)
    {
		iSlot = GetLocalInt(oInventoryItem, LAST_SLOT_NUM);
		
		//EPF 8/29/06 left hand must be equipped after right.  Otherwise the engine
		//    will shift it to the right hand slot automatically.
		if(iSlot - 1 != INVENTORY_SLOT_LEFTHAND) // Nwn2Fix
		{
			RestoreEquippedItem(oOwner, oInventoryItem, bReset);
		}
		else
		{
			oLeftHandItem = oInventoryItem;
		}
        oInventoryItem = GetNextItemInInventory(oOwner); // Nwn2Fix
    }
	
	if(GetIsObjectValid(oLeftHandItem))
	{
		RestoreEquippedItem(oOwner, oLeftHandItem, bReset);
	}
}

// unequip item in specified slot, if any
void UnequipSlot(object oOwner, int iSlot)
{
	object oInventoryItem = GetItemInSlot(iSlot, oOwner);
	if (oInventoryItem != OBJECT_INVALID)
	{		
		AssignCommand(oOwner, ActionUnequipItem(oInventoryItem));
	}		
}


// passing around carried stuff.
void GiveEquippedItem(object oGiver, object oReceiver, int iSlot, int bDisplayFeedback=TRUE)
{	
	if (GetObjectType(oGiver) != OBJECT_TYPE_CREATURE)
	{
		PrettyError("GiveEquippedItem(): Equipped Item Giver must be a creature!");		
		return;
	}

	object oInventoryItem = GetItemInSlot(iSlot, oGiver);

	if (oInventoryItem != OBJECT_INVALID)
	{
		AssignCommand(oGiver, ActionUnequipItem(oInventoryItem));
		//AssignCommand(oReceiver, ActionTakeItem(oInventoryItem, oGiver));
        //AssignCommand(oGiver, ActionGiveItem(oInventoryItem, oReceiver));
		TransferItem(oGiver, oReceiver, oInventoryItem, bDisplayFeedback);
	}
}
	
void GiveAllEquippedItems(object oGiver, object oReceiver, int bDisplayFeedback=TRUE)
{	
    int iSlot;
    for (iSlot = 0; iSlot < NUM_INVENTORY_SLOTS; iSlot++)
    {
		GiveEquippedItem(oGiver, oReceiver, iSlot, bDisplayFeedback);
    }
}


// Transfer an item from giver to receiver.
// objects lack an action queue, so 
void TransferItem(object oGiver, object oReceiver, object oInventoryItem, int bDisplayFeedback=TRUE)
{
	// placeable give/take item commands are most dependable
	if (GetObjectType(oReceiver) == OBJECT_TYPE_PLACEABLE)
	{ // the receiver is a creature, so he can be assigned ActionTakeItem() commands to his queue
        AssignCommand(oReceiver, ActionTakeItem(oInventoryItem, oGiver, bDisplayFeedback));
	}
	else //if ((GetObjectType(oGiver) == OBJECT_TYPE_PLACEABLE)
	{ // if both are creatures, giving item better than taking since taking causes movement.
        AssignCommand(oGiver, ActionGiveItem(oInventoryItem, oReceiver, bDisplayFeedback));
	}
}

// are bags passed as full bags, or traversed?
// inventory space limits?
// stacked items?
void GiveAllInventory(object oGiver, object oReceiver, int bDisplayFeedback=TRUE)
{
	//if ((GetObjectType(oGiver) != OBJECT_TYPE_CREATURE) && (GetObjectType(oReceiver) != OBJECT_TYPE_CREATURE))
	//{
	//	PrettyError("GiveAllInventory(): At least one of Giver or Receiver must be a creature.");		
	//	return;
	//}

    object oInventoryItem = GetFirstItemInInventory(oGiver);
    while (oInventoryItem != OBJECT_INVALID)
    {
		TransferItem(oGiver, oReceiver, oInventoryItem, bDisplayFeedback);
        //AssignCommand(oGiver, ActionGiveItem(oInventoryItem, oReceiver));
        oInventoryItem = GetNextItemInInventory(oGiver);
    }
}

// give gold, equipped items, and inventory
void GiveEverything(object oGiver, object oReceiver, int bDisplayFeedback=TRUE)
{
	if (GetObjectType(oGiver) != OBJECT_TYPE_CREATURE)
	{
		PrettyError("GiveEverything(): Everything Giver must be a creature!");		
		return;
	}

    int iGold = GetGold(oGiver);// Remove gold to crate
    AssignCommand(oReceiver, TakeGoldFromCreature(iGold, oGiver, FALSE));
	GiveAllEquippedItems(oGiver, oReceiver, bDisplayFeedback);
	GiveAllInventory(oGiver, oReceiver, bDisplayFeedback);
}

// Return number of items of Base Type in inventory
int CountInventoryItemsOfBaseType(int nBaseType, object oCreature=OBJECT_SELF)
{
    object oItem =  GetFirstItemInInventory(oCreature);
	int iItemCount=0;

    while (GetIsObjectValid(oItem))
    {
       if (GetBaseItemType(oItem) == nBaseType)
       {
			iItemCount++;
       }
       oItem =  GetNextItemInInventory(oCreature);
    }
    return iItemCount;
}


object GetInventoryItemOfBaseType(int nBaseType, int nNth=1, object oCreature=OBJECT_SELF)
{
    object oItem =  GetFirstItemInInventory(oCreature);
	int iItemCount=0;

    while (GetIsObjectValid(oItem))
    {
       if (GetBaseItemType(oItem) == nBaseType)
       {
			iItemCount++;
			if (iItemCount == nNth)
			{
				//PrettyDebug("Found requested item in inventory: " + GetName(oItem));
				return (oItem);
			}
       }
       oItem =  GetNextItemInInventory(oCreature);
    }
	
    return OBJECT_INVALID;
}


// list items in inventory.  Should work for placeables too.
int ListInventory(object oCreature=OBJECT_SELF)
{
    object oItem = GetFirstItemInInventory(oCreature);
	int i;

	PrettyDebug("*** Items in the inventory of " + GetName(oCreature));
    while (GetIsObjectValid(oItem))
    {
		i++;
		PrettyDebug("Item " + IntToString(i) + ": " + GetName(oItem));
       	oItem =  GetNextItemInInventory(oCreature);
    }
    return i;
}

// Returns reference to item with Tag in inventory only (not equipped)
object GetItemInInventory(string sItemTag, object oCreature=OBJECT_SELF)
{
	object oRet = OBJECT_INVALID;
    object oItem = GetFirstItemInInventory(oCreature);

    while (GetIsObjectValid(oItem))
    {
		if (GetTag(oItem) == sItemTag)
			return oItem;
       	oItem =  GetNextItemInInventory(oCreature);
    }
    return oRet;
}

// returns TRUE if an item was found
int EquipRandomArmorFromInventory()
{
	int bRet = FALSE;
	//PrettyDebug("Looking for something to change into");
	int iCount = CountInventoryItemsOfBaseType(BASE_ITEM_ARMOR);
	int iChoice = Random(iCount)+1;
	object oArmor = GetInventoryItemOfBaseType(BASE_ITEM_ARMOR, iChoice);
	if (GetIsObjectValid(oArmor))
	{
		bRet = TRUE;
		ActionUnequipItem(GetItemInSlot(INVENTORY_SLOT_CHEST));
		ActionEquipItem(oArmor, INVENTORY_SLOT_CHEST);
	}
	return (bRet);
}


// **** Functions for Identifying Item Types
	
// Is this a weapon of any type (including ammunition).
int GetIsWeapon(object oItem)
{
	return(IPGetIsMeleeWeapon(oItem) || IPGetIsRangedWeapon(oItem) || IPGetIsProjectile(oItem));
}

// is this a shield?
int GetIsShield(object oItem)
{
    int iType = GetBaseItemType(oItem);
    int iRet = FALSE;
    switch (iType)
    {
        case BASE_ITEM_SMALLSHIELD      :
        case BASE_ITEM_LARGESHIELD      :
        case BASE_ITEM_TOWERSHIELD      :
            iRet = TRUE;
            break;
	}
	return iRet;
}

// Is this armor or shield?
int GetIsArmorOrShield(object oItem)
{
    int iType = GetBaseItemType(oItem);
	return ((iType == BASE_ITEM_ARMOR) || GetIsShield(oItem));
}

// Is item in specified (bit flag) category?
int GetIsItemCategory(object oItem, int iItemCategory)
{
	int iThisCategory = GetItemCategory(oItem);
	int iRet = GetState(iThisCategory, iItemCategory);
	
	// special case for matching ITEM_CATEGORY_NONE
	if ((iThisCategory == ITEM_CATEGORY_NONE) && (iItemCategory == ITEM_CATEGORY_NONE))
		iRet = TRUE;
	
	//PrettyDebug(GetName(oItem) + " is in Category " + IntToString(iThisCategory) + 
	//			" In passed category of [" + IntToString(iItemCategory) + "] = " + IntToString(iRet));
		
	return (iRet);
}


// any item that can be equipped
int GetIsEquippable(object oItem)
{
    int iRet = FALSE;
	if (GetIsWeapon(oItem)
        || GetIsArmorOrShield(oItem)
        || GetIsMiscEquippable(oItem))
        iRet = TRUE;

    return (iRet);                
}


// any item that can be equipped except armor and weapons
int GetIsMiscEquippable(object oItem)
{
    int iRet = FALSE;
    int iType = GetBaseItemType(oItem);
    switch (iType)
    {
		// equippable stuff
        case BASE_ITEM_HELMET           :
        case BASE_ITEM_BELT             :
        case BASE_ITEM_BOOTS            :
        case BASE_ITEM_GLOVES           :
        case BASE_ITEM_RING             :
        case BASE_ITEM_AMULET           :
        case BASE_ITEM_BRACER           :
        case BASE_ITEM_CLOAK            :
            iRet=TRUE;
            break;
    }
    return (iRet);
}    

// Returns basic category which is includes weapon, armor, and other
int GetItemCategory(object oItem)
{
    int iRet = ITEM_CATEGORY_NONE;
	if (!GetIsObjectValid(oItem))
	{
    	return (iRet);
	}		
	
	if (GetIsWeapon(oItem)) 
    	iRet |= ITEM_CATEGORY_WEAPON;
	else if (GetIsArmorOrShield(oItem))
    	iRet |= ITEM_CATEGORY_ARMOR_SHIELD;
	else
		iRet |= ITEM_CATEGORY_OTHER;

    if (GetIsMiscEquippable(oItem))
		iRet |= ITEM_CATEGORY_MISC_EQUIPPABLE;
    
        
	/*
        
    int iType = GetBaseItemType(oItem);
    switch (iType)
    {
		// swords
        case BASE_ITEM_SHORTSWORD       :
        case BASE_ITEM_LONGSWORD        :
        case BASE_ITEM_TWOBLADEDSWORD   :
        case BASE_ITEM_BASTARDSWORD     :
        case BASE_ITEM_GREATSWORD       :
        case BASE_ITEM_GREATAXE         :
        case BASE_ITEM_KATANA           :
        case BASE_ITEM_RAPIER           :
        case BASE_ITEM_SCIMITAR         :

		// axes
        case BASE_ITEM_DOUBLEAXE        :
        case BASE_ITEM_BATTLEAXE        :
        case BASE_ITEM_HANDAXE          :
        case BASE_ITEM_DWARVENWARAXE    :

		// flails
        case BASE_ITEM_LIGHTFLAIL       :
        case BASE_ITEM_HEAVYFLAIL       :

		// hammers
        case BASE_ITEM_WARHAMMER        :
        case BASE_ITEM_LIGHTHAMMER      :

		// maces
        case BASE_ITEM_DIREMACE         :
       	case BASE_ITEM_LIGHTMACE        :

		// misc melee weapons
        case BASE_ITEM_HALBERD          :
        case BASE_ITEM_DAGGER           :
        case BASE_ITEM_KAMA             :
        case BASE_ITEM_KUKRI            :
        case BASE_ITEM_MORNINGSTAR      :
        case BASE_ITEM_QUARTERSTAFF     :
        case BASE_ITEM_SHORTSPEAR       :
        case BASE_ITEM_SICKLE           :
        case BASE_ITEM_SCYTHE           :
        case BASE_ITEM_WHIP             :
        case BASE_ITEM_CLUB             :

		// creature weapons
        case BASE_ITEM_CSLASHWEAPON     :
        case BASE_ITEM_CPIERCWEAPON     :
        case BASE_ITEM_CBLUDGWEAPON     :
        case BASE_ITEM_CSLSHPRCWEAP     :

		// ranged reapons
        case BASE_ITEM_HEAVYCROSSBOW    :
        case BASE_ITEM_LIGHTCROSSBOW    :
        case BASE_ITEM_LONGBOW          :
        case BASE_ITEM_SHORTBOW         :
        case BASE_ITEM_SLING            :

        case BASE_ITEM_DART             :
        case BASE_ITEM_THROWINGAXE      :
        case BASE_ITEM_GRENADE          :
        case BASE_ITEM_SHURIKEN         :

		// ammunition
        case BASE_ITEM_ARROW            :
        case BASE_ITEM_BULLET           :
        case BASE_ITEM_BOLT             :
            iRet = ITEM_CATEGORY_WEAPON;
            break;

		// armor/shield
        case BASE_ITEM_ARMOR            :

        case BASE_ITEM_SMALLSHIELD      :
        case BASE_ITEM_LARGESHIELD      :
        case BASE_ITEM_TOWERSHIELD      :
            iRet = ITEM_CATEGORY_ARMOR_SHIELD;
            break;
		
		// equippable stuff
        case BASE_ITEM_HELMET           :
        case BASE_ITEM_BELT             :
        case BASE_ITEM_BOOTS            :
        case BASE_ITEM_GLOVES           :
        case BASE_ITEM_RING             :
        case BASE_ITEM_AMULET           :
        case BASE_ITEM_BRACER           :
        case BASE_ITEM_CLOAK            :

		// misc items
        case BASE_ITEM_MISCSMALL        :
        case BASE_ITEM_MISCMEDIUM       :
        case BASE_ITEM_MISCLARGE        :
        case BASE_ITEM_MISCTALL         :
        case BASE_ITEM_MISCWIDE         :
        case BASE_ITEM_MISCTHIN         :

		// magic items
        case BASE_ITEM_MAGICROD         :
        case BASE_ITEM_MAGICSTAFF       :
        case BASE_ITEM_MAGICWAND        :
        case BASE_ITEM_SPELLSCROLL      :
        case BASE_ITEM_POTIONS          :

		// blank magic items
        case BASE_ITEM_BLANK_POTION     :
        case BASE_ITEM_BLANK_SCROLL     :
        case BASE_ITEM_BLANK_WAND       :
        case BASE_ITEM_ENCHANTED_POTION :
        case BASE_ITEM_ENCHANTED_SCROLL :
        case BASE_ITEM_ENCHANTED_WAND   :

		// mundane items
        case BASE_ITEM_HEALERSKIT       :
        case BASE_ITEM_BOOK             :
        case BASE_ITEM_SCROLL           :
        case BASE_ITEM_TORCH            :
        case BASE_ITEM_THIEVESTOOLS     :
        case BASE_ITEM_TRAPKIT          :
        case BASE_ITEM_KEY              :
        case BASE_ITEM_LARGEBOX         :
        case BASE_ITEM_CREATUREITEM     :
        case BASE_ITEM_GOLD             :
        case BASE_ITEM_GEM              :

		// crafting items
        case BASE_ITEM_CRAFTMATERIALMED :
        case BASE_ITEM_CRAFTMATERIALSML :

            iRet = ITEM_CATEGORY_OTHER;
            break;
    }
	*/
			
    return (iRet);
}


// return slot item is equipped in on creature.  -1 if not found
int GetSlotOfEquippedItem(object oItem, object oCreature)
{
	int iSlot;
	object oItemInSlot;
	
	for (iSlot=0; iSlot<NUM_INVENTORY_SLOTS; iSlot++)
	{
		oItemInSlot = GetItemInSlot(iSlot, oCreature);
		if (oItemInSlot == oItem)
		{
			return iSlot;
		}
	}
	return -1;
}

int GetIsCreatureSlot(int iSlot)
{
	int iRet = FALSE;
	if ((iSlot == INVENTORY_SLOT_CWEAPON_B) ||
		(iSlot == INVENTORY_SLOT_CWEAPON_L) ||
		(iSlot == INVENTORY_SLOT_CWEAPON_R) ||
		(iSlot == INVENTORY_SLOT_CARMOUR))
		iRet = TRUE;

	return (iRet);			
}

//===========================================================================
// Store related
//===========================================================================

// * returns a value that will be subtracted from the
// * oTarget's DC to resist APpraise or Persuasion
int N2_GetNPCEasyMark(object oTarget)
{
    int nCharmMod = 0;
    if (GetHasSpellEffect(SPELL_CHARM_PERSON, oTarget))
    {
        nCharmMod = 10;
    }
    else
    if (GetHasSpellEffect(SPELL_CHARM_MONSTER, oTarget))
    {
        nCharmMod = 10;
    }
    else
    if (GetHasSpellEffect(SPELL_CHARM_PERSON_OR_ANIMAL, oTarget))
    {
        nCharmMod = 10;
    }
    else if (GetHasSpellEffect(SPELL_MASS_CHARM, oTarget))
    {
            nCharmMod = 15;
    }
    else if (GetHasSpellEffect(SPELL_DOMINATE_MONSTER, oTarget))
    {
            nCharmMod = 20;
    }
    else if (GetHasSpellEffect(SPELL_DOMINATE_ANIMAL, oTarget))
    {
            nCharmMod = 20;
    }
    else if (GetHasSpellEffect(SPELL_DOMINATE_PERSON, oTarget))
    {
        nCharmMod = 20;
    }
    return nCharmMod;
}

// Open Store taking Appraise skill into account.
// changed from gplotAppraiseOpenStore() in NW_IO_PLOT - no longer random
/*
        An opposed skill ccomparison. Your appraise skill versus the shopkeepers appraise skill.
        Possible Results:
        Percentage Rebate/Penalty: The 'difference'
        Feedback: [Appraise Skill]: Merchant's reaction is unfavorable.
                  [Appraise Skill]: Merchant's reaction is neutral.
                  [Appraise Skill]: Merchant's reaction is favorable.
*/
void N2_AppraiseOpenStore(object oStore, object oPC, int nBonusMarkUp = 0, int nBonusMarkDown = 0)
{
    int STATE_FAILED = 1;
    int STATE_TIE = 2;
    int STATE_WON = 3;

    int nPlayerSkillRank = GetSkillRank(SKILL_APPRAISE, oPC);

    int nNPCSkillRank = GetSkillRank(SKILL_APPRAISE, OBJECT_SELF) - N2_GetNPCEasyMark(OBJECT_SELF);


    if (nNPCSkillRank < 1 )
        nNPCSkillRank = 1;


    int nState = 0;
	int nAdjust = nNPCSkillRank - nPlayerSkillRank; // * determines the level of price modification

	if (nNPCSkillRank > nPlayerSkillRank)
	{
	    nState = STATE_FAILED;
	}
	else
	if (nNPCSkillRank < nPlayerSkillRank)
	{
	    nState = STATE_WON;
	}
	else
	if (nNPCSkillRank == nPlayerSkillRank)
	{
	    nState = STATE_TIE;
	}

    if (nState == STATE_FAILED  )
    {
        FloatingTextStrRefOnCreature(182468, oPC, FALSE);
    }
    else
    if (nState == STATE_WON)
    {
        FloatingTextStrRefOnCreature(182470, oPC, FALSE);
    }
    else
    if (nState == STATE_TIE)
    {
        FloatingTextStrRefOnCreature(182469, oPC, FALSE);
    }


    // * Hard cap of 30% max up or down
    if (nAdjust > 30)
        nAdjust = 30;
    if (nAdjust < -30)
        nAdjust = -30;

	// nBonusMarkUp is added to the stores default mark up percentage on items sold (-100 to 100)
	// (positive is good for player)
	// Effect on selling items is only half of effect on buying items.
    nBonusMarkUp = nBonusMarkUp + nAdjust/2;
	
	// nBonusMarkDown is added to the stores default mark down percentage on items bought (-100 to 100)
	// (negative is good for player)
	nBonusMarkDown = nBonusMarkDown - nAdjust;
    OpenStore(oStore, oPC, nBonusMarkUp, nBonusMarkDown);
}


// Goes through an object's inventory and recreates the items from the blueprint.
// only applies to droppable items in inventory (not equipped).
void RecreateItemsFromBlueprint(object oObject=OBJECT_SELF)
{
    int nRecreateItemsCount = 0;
    string sVarName;
    int nStackSize;
	int bInfinite;
    string sItemTemplate;
   
    // create list of items to recreate.
    // We delay creating and deleting objects so as to avoid 
    // porblems with the iterator used by GetFirst/NextItemInInventory()
    object oItem = GetFirstItemInInventory(oObject);
    while (GetIsObjectValid(oItem) == TRUE)
    {
        if ((GetLocalInt(oItem, "NO_DRR") == FALSE)
            && ((GetDroppableFlag(oItem) == TRUE)
                || GetObjectType(oObject) != OBJECT_TYPE_CREATURE))
        {
            nRecreateItemsCount++;
            sVarName = VAR_PREFIX_RECREATE_LIST + IntToString(nRecreateItemsCount);
            SetLocalObject(oObject, sVarName, oItem); // save item to delete
			
            nStackSize = GetNumStackedItems(oItem);
            sItemTemplate = GetResRef(oItem);
			bInfinite = GetInfiniteFlag(oItem);
			
			// ok to use same var name 
			SetLocalInt(oObject, sVarName, nStackSize);
			SetLocalString(oObject, sVarName, sItemTemplate);
			SetLocalInt(oObject, sVarName + "IF", bInfinite);
        }
        oItem = GetNextItemInInventory(oObject);
    }
    
    int i;
    // Destory and recreate the "list of items"
	// Destroy before create, because creating new stackable items will cause them to merge,
	// and then DestroyObject would destroy	the merged items as well		
	
    for (i=1; i<= nRecreateItemsCount; i++)
    {
        sVarName = VAR_PREFIX_RECREATE_LIST + IntToString(i);
        oItem = GetLocalObject(oObject, sVarName);
        if (GetIsObjectValid(oItem))
        {
            //nStackSize = GetNumStackedItems(oItem);
            //sItemTemplate = GetResRef(oItem);
           	DestroyObject(oItem);
            //CreateItemOnObject(sItemTemplate, oObject, nStackSize);
            DeleteLocalObject(oObject, sVarName); // clean up the var name.
        }            
    }
	
	// create the items
    for (i=1; i<= nRecreateItemsCount; i++)
    {
        sVarName = VAR_PREFIX_RECREATE_LIST + IntToString(i);
		nStackSize = GetLocalInt(oObject, sVarName);
		sItemTemplate = GetLocalString(oObject, sVarName);
		bInfinite = GetLocalInt(oObject, sVarName + "IF");
		// Create has to be delayed long enough to ensure destroy has occured
		DelayCommand(0.01f, VoidCreateItemOnObject(sItemTemplate, oObject, nStackSize, bInfinite));
		
		DeleteLocalInt(oObject, sVarName); // clean up the var name.
		DeleteLocalString(oObject, sVarName); // clean up the var name.
    }
	
}

//---------------------------------------------------------------
// Item Identification

void IdentifyEquippedItems(object oCreature=OBJECT_SELF)
{
	int i = 0;
	object oItem;
	for (i = 0; i< NUM_INVENTORY_SLOTS; i++)
	{
		oItem = GetItemInSlot(i, oCreature);
		if (GetIsObjectValid(oItem) == TRUE)
			SetIdentified( oItem, TRUE);
	}
}

void IdentifyInventory(object oCreature=OBJECT_SELF)
{
    object oInventoryItem = GetFirstItemInInventory(oCreature);
    while (oInventoryItem != OBJECT_INVALID)
    {
	    SetIdentified(oInventoryItem, TRUE);
        oInventoryItem = GetNextItemInInventory(oCreature);
    }
}

//---------------------------------------------------------------
// Void converted functions
void VoidCreateItemOnObject(string sItemTemplate, object oTarget = OBJECT_SELF, int nStackSize = 1, int bInfinite = FALSE)
{
	//CreateItemOnObject(sItemTemplate, oTarget, nStackSize);
	PrettyDebug("Creating " + IntToString(nStackSize) + " of res ref: " + sItemTemplate);
	object oItem = CreateItemOnObject(sItemTemplate, oTarget, nStackSize);
	
	if(bInfinite)
		SetInfiniteFlag(oItem, TRUE);
	
	nStackSize = GetNumStackedItems(oItem);
	sItemTemplate = GetResRef(oItem);
	PrettyDebug("Item created: " + IntToString(nStackSize) + " of res ref: " + sItemTemplate);
	
	
}