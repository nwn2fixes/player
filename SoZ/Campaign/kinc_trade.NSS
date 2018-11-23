//kinc_trade
/*
	NX2 Trading System Include File
*/
// nchapman 1/18/08
// kevL 2018.11.22 - match default par for 'nLevel' in GetCaravanIncome()

#include "ginc_vars"
#include "ginc_2da"
#include "ginc_wp"
#include "ginc_param_const"

#include "kinc_trade_constants"
#include "kinc_trade_crafting"
#include "kinc_trade_system"


/*The following functions are contained within Sub-Includes:
---kinc_trade_crafting---
int CheckCanCraft(int nIndex, object oPC);
int CheckCanEnchant(int nIndex, object oItem, object oPC);
int CheckLocalInts(int nIndex, object oPC);
int CheckGoldCost(int nIndex, object oPC);
int CheckTradeBars(int nIndex, object oPC);
int CheckItemReagents(int nIndex, object oPC);
int CheckGoodReagents(int nIndex, object oPC);
int CheckRareResReagents(int nIndex, object oPC);
int CheckCraftingSpellUses(int nIndex, object oPC);
int CheckItemPrereqs(int nIndex, object oPC);
int CheckSkillPrereqs(int nIndex, object oPC);
int CheckPlaceablePrereq(int nIndex, object oPC);
int CheckFeatPrereqs(int nIndex, object oPC);
int CheckEnchantingTargetValid(int nIndex, object oItem, object oPC);
int CheckEnchantmentNumber(int nIndex, object oItem, object oPC);
int CheckHasEnoughCasterLevels(int nIndex, object oPC);

void CraftItem(int nIndex, object oPC);
void EnchantItem(int nIndex, object oItem, object oPC);
void DeductGoldCost(int nIndex, object oPC);
void DeductTradeBarCost(int nIndex, object oPC);
void ConsumeItemReagents(int nIndex, object oPC);
void ConsumeGoodReagents(int nIndex, object oPC);
void ConsumeRareResReagents(int nIndex, object oPC);
void ConsumeCraftingSpellUse(int nIndex, object oPC);
void CreateCraftedItem(int nIndex, object oPC);
void EnchantTargetItem(int nIndex, object oItem);

void DoCraftingFailureFeedback(int nCraftingFailure, object oPC,  string sExtraFeedback = "");

---kinc_trade_system---

//Trading Post Functions
int EstablishTradingPost(int iLocation);

//Location Functions
int GetHasTradingPost(int iLocation);
string GetLocationLabel(int iLocation);
string GetLocationName(int iLocation);
int GetLocationSize(int nLocation);

/*----------------------------------------------------------------------------------------------\
|	Good/Resource Transactions.  Note - these all return FALSE if the player can't Buy, Sell,	|
|	Give or Take the good respectively...  you can use these not only to 						|
|	actually DO the buying/selling, but also to check whether you *can* do it. If bCheck is 	|
|	true it will just return true if it can perform the action - it won't actually do it.		|
\----------------------------------------------------------------------------------------------*/
/*
int GiveCargo(int iIndex, int nAmount, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int TakeCargo(int iIndex, int nAmount, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int BuyCargo(int iIndex, int nAmount, int iPrice, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int SellCargo(int iIndex, int nAmount, int iPrice, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int BuyScarceCargo(int iIndex, int nAmount, int iPrice, int nStock, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int SellScarceCargo(int iIndex, int nAmount, int iPrice, int nStock, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE);
int StoreCargo(int nIndex, int nAmount, int bGood = TRUE);
int WithdrawCargo(int nIndex, int nAmount, int bGood = TRUE);

//Trade Bar Functions
int GiveBars(int iBarsToGive, int bTemp = FALSE);
int TakeBars(int nBarsToTake, int bCheck = FALSE, int bTemp = FALSE);
int GiveCompanyBars(int nBarsToGive);
int TurnInBars(int nBarsToTurnIn);
int GetPartyBars();

//Wagon/Cargo Functions
int SetPartyWagon(int iWagon);
int GetWagonMaxCargo(int iWagon);	//This function pulls the data from the nx2_wagons.2da
string GetWagonName(int iWagon);	//As does this.  NOTE:  Should be converted to STRREFs once we have them!
int GetIsPartyCargoFull(int bTemp = FALSE);			//Checks to see if the Party's cargo is full. TRUE = Full, FALSE = Space Available.
int GetPartyCargoFreeSpace(int bTemp = FALSE);		//Returns the amount of empty/free cargo space that the party has.

//Storage Functions
int GetStorageStock(int nIndex, int bGood=TRUE);

//Commodity Functions
string GetTradeGoodLabel(int nGood);
string GetRareResourceLabel(int nResource);
string GetTradeGoodName (int nGood);
string GetRareResourceName(int nResource);
int GetPartyStock(int nIndex, int bGood = TRUE, int bTemp = FALSE);
int GetTradeGoodPrice(int nGood, int nLocation);
string GetTradeGoodPriceString(int nGood, int nLocation);
int GetRareResourcePrice(int nResource, int nLocation);
string GetRareResourcePriceString(int nGood, int nLocation);
int GetTradeGoodStock(int nGood, int nLocation, int bTemp = FALSE);
int GetRareResourceStock(int iResource, int iLocation, int bTemp = FALSE);
int SetTradeGoodStock(int nGood, int nLocation, int nAmount, int bTemp = FALSE);
int SetRareResourceStock(int iResource, int iLocation, int nAmount, int bTemp = FALSE);

//Rare Resource Node Functions
int GetResourceNodeDiscovered(int iIndex);


//CompanyFunctions
int GetCompanyBars();
int GetCompanyLevel();
int IncrementCompanyLevel();
int GetAvailableUpgrades();
int IncrementAvailableUpgrades();
int SpendAvailableUpgrade();
int LevelUpCompany();
int GetBarsRequiredForLevel(int nLevel);
int GetBarsToNextLevel();
int CompanyReadyToLevel();
int ProcessCompanyIncome();
void AwardCompanyIncome();
int GetCompanyReserve();
void SetCompanyReserve(int nNewReserve);
*/


//FUNCTION PROTOTYPES---------------------------
void InitTradeGoods();
void InitRareResources();
void InitWagon();

//UI Functions
void ShowMiniMarketUI(object oPC, int nLocation);
void ShowMarketUI(object oPC, int iLocation);
void ShowTradingInvUI(object oPC);
void ShowShippingUI(object oPC);
void ShowStorageUI(object oPC);
string GetMarketListBoxText(int nIndex, int nLocation, int bGood = TRUE);
string GetStorageListBoxText(int nIndex, int bGood = TRUE);
void InitializeTempVariables(int nLocation);
void UpdateMarketUI(object oPC, int nIndex, int nLocation, int bGood = TRUE);
void SetUIPriceText(object oPC, int iLocation);
void SetRareResourceUIText(object oPC, int iLocation);
void SetPartyCargoText(object oPC);
void SetRareResourceCargoText(object oPC);
int PopulatePriceUIObject(int iPrice, string sUIObjectName);
string GetCargoUIText(int bTemp = FALSE);
void ShowTurnInUI(object oPC, int bDonate);
void UpdateTurnInUI(object oPC, int bInit = FALSE);
void ShowCaravanUI(object oPC, int bConstruct = FALSE, int nLocation = 0);
void PopulateCaravanSourceListbox(object oPC, int bConstruct = FALSE, int nLocation = 0);
void PopulateCaravanDestinationListbox(object oPC, int nSourceIndex);
void PopulateCaravanTextListbox(object oPC, int nSourceIndex, int nDestinationIndex, int bConstruct);

//Caravan Functions
void ProcessCaravansOnEnter();
void CreateCaravanFromString(string sCaravanString);
string GetCaravanTag(int nStartingIndex, int nDestinationIndex);
void CreateCaravan(int nStartingIndex, int nDestinationIndex, int nLevel, int bReturn);
void AwardCaravanIncome(object oCaravan);
void ProcessCaravanOrigin();
void ProcessCaravanDestination(int nNodeNumber);
int GetCaravanState(int nSourceIndex, int nDestIndex);
string GetCaravanStateString(int nDestinationIndex, int nSourceIndex);
void SetCaravanState(int nSourceIndex, int nDestIndex, int nCaravanState);
void SetCaravanLevel(int nSourceIndex, int nDestIndex, int nCaravanLevel);
int GetCaravanLevel(int nSourceIndex, int nDestIndex);
int GetCanCreateCaravan(int nSourceIndex, int nDestIndex, object oPC = OBJECT_SELF);
int GetCanUpgradeCaravan(int nSourceIndex, int nDestIndex, object oPC = OBJECT_SELF);
int GetCaravanUpgradePrice(int nSourceIndex, int nDestIndex);
int GetCaravanIncome(int nSourceIndex, int nDestIndex, int nLevel = 0); // kL_Fix
int GetCaravanBasePrice(int nSourceIndex, int nDestIndex);
int GetCaravanBaseIncome(int nSourceIndex, int nDestIndex);

//Time Functions
void ProcessTimeUnit();
void ProcessTowns();
void ProcessGood(int nCurrentGood, int nCurrentLoc);
void ProcessRareResource(int nCurrentLoc, int nCurrentNode);
int GetStockSizeMultiplier(int nLocation);
int GetShortageAmount(int nGood, int nLocation);
int GetSurplusAmount(int nGood, int nLocation);
int GetEquilibriumPoint(int nGood, int nLocation);
int DriftToEquilibrium(int nCurrentGood, int nCurrentLocation);
void StartShortage(int nIndex, int nLocation, int bTradeGood = TRUE);
void StartSurplus(int nIndex, int nLocation, int bTradeGood = TRUE);
void StopShortage(int nIndex, int nLocation, int bTradeGood = TRUE);
void StopSurplus(int nIndex, int nLocation, int bTradeGood = TRUE);
int GetShortage(int nIndex, int nLocation);		//http://imdb.com/title/tt0113161/
int GetSurplus(int nIndex, int nLocation);
void ClearEvents();
void ResetRareResources(int bTemp = FALSE);
void PopulateRareResources(int bTemp = FALSE);
void PopulateTradeGoods(int bTemp = FALSE);
void GenerateEvents();
void GenerateRandomEvents();
void CausePanic(int nIndex, int nLocation);
void CauseOverage(int nIndex, int nLocation);

//Goodie Trade System rewards
void AwardGoodieGoods(object oUser, string sGoods);
void AwardGoodieResources(object oUser, string sRareRes);

// -------------------------------------------------------
// Function Definitions
// -------------------------------------------------------
/*----------------------------------\
|	Initialization Functions		|
\----------------------------------*/
void InitTradeGoods()
{
	int iNum = 1;
	string sLabel = Get2DAString(GOODS_2DA,"LABEL",iNum);
		
	while(sLabel != "")
	{
		SetGlobalInt("PARTY_" + sLabel, 0);
		PrettyDebug("PARTY_" + sLabel + "=" + IntToString(GetGlobalInt("PARTY_" + sLabel)));
		++iNum;
		sLabel = Get2DAString(GOODS_2DA,"LABEL",iNum);
	}
	
	PopulateTradeGoods();
}

void InitRareResources()
{
	int iNum = 1;
	string sLabel = Get2DAString(RES_2DA,"LABEL",iNum);
		
	while(sLabel != "")
	{
		SetGlobalInt("PARTY_" + sLabel, 0);
		PrettyDebug("PARTY_" + sLabel + "=" + IntToString(GetGlobalInt("PARTY_" + sLabel)));
		++iNum;
		sLabel = Get2DAString(RES_2DA,"LABEL",iNum);
	}
}

void InitWagon()
{
	SetGlobalInt("PARTY_WAGON", WAGON_1);
	SetGlobalInt("PARTY_CARGO", 0);			//Current Cargo 
}


/*----------------------\
|		UI Functions	|
\----------------------*/
void ShowMarketTutorial()
{
	SetPause(TRUE);
	object oPlayer = GetFirstFactionMember(GetFirstPC(), TRUE);
	
	//Add the Tutorial Journal Entries
	AddJournalQuestEntry("tut_trade_market", 900, oPlayer);
	
	while(GetIsObjectValid(oPlayer))
	{
		DisplayMessageBox(oPlayer, 234320, "", "gui_tutorial_close", "gui_tutorial_close", FALSE);
		oPlayer = GetNextFactionMember(GetFirstPC(), TRUE);
	}
}
void ShowMiniMarketUI(object oPC, int nLocation)
{
	string sMarketName = GetStringByStrRef(Get2DAInt(ECON_2DA, "STRREF", nLocation));
//	sMarketName += " Market";
	InitializeTempVariables(nLocation);
	DisplayGuiScreen( oPC, GUI_MARKET_SCREEN, TRUE, GUI_MARKET_XML);
	if(GetGlobalInt("bMarketTutorial") != TRUE)
	{
		ShowMarketTutorial();
		SetGlobalInt("bMarketTutorial", TRUE);
	}
	SetLocalGUIVariable(oPC, GUI_MARKET_SCREEN, 1000, IntToString(nLocation));
	ClearListBox(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB);
	SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "SHOW_GOODS", TRUE);
	SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "SHOW_RARE", TRUE);
	SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "GOODS_PAGE", TRUE);
	SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "RARE_PAGE", FALSE);
	
	int j;
	int bRareResFound = FALSE;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		if(GetPartyStock(j, FALSE) > 0 || GetRareResourceStock(j, nLocation) > 0)
		{
			PrettyDebug("Adding Row for " + GetRareResourceLabel(j) + " to " + GUI_MARKET_RARE_RES_LB);
			AddListBoxRow(	oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB, 
							GetRareResourceLabel(j), GetMarketListBoxText(j, nLocation, FALSE),"",
							"1=" + IntToString(j) + ";2=" + GetRareResourcePriceString(j, nLocation),"");
							
			bRareResFound = TRUE;
		}
	}
	
	if(bRareResFound ==  FALSE)
	{
		PrettyDebug("hiding irrelevant stuff");
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "TOWN_STOCK_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "PRICE_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "INVENTORY_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "RR_EMPTY_TEXT", FALSE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_GOODS_BUTTON, TRUE);
		SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_BUTTON, TRUE);
	}
	
	
	SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_BARS_TEXT, -1, IntToString(GetGlobalInt("PARTY_BARS_TEMP")));	
	SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText(TRUE));
	SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_TITLE, -1, sMarketName);
}

void ShowMarketUI(object oPC, int nLocation)
{

	if( GetGlobalInt("00_nStoryStep") < 2)
	{
		ShowMiniMarketUI(oPC, nLocation);
	}
	else
	{
		string sMarketName = GetStringByStrRef(Get2DAInt(ECON_2DA, "STRREF", nLocation));
//		sMarketName += " Market";
		InitializeTempVariables(nLocation);
		DisplayGuiScreen( oPC, GUI_MARKET_SCREEN, TRUE, GUI_MARKET_XML);
		if(GetGlobalInt("bMarketTutorial") != TRUE)
		{
			ShowMarketTutorial();
			SetGlobalInt("bMarketTutorial", TRUE);
		}
			
		SetLocalGUIVariable(oPC, GUI_MARKET_SCREEN, 1000, IntToString(nLocation));
		
		ClearListBox(oPC, GUI_MARKET_SCREEN, GUI_MARKET_TRADE_GOOD_LB); 
		ClearListBox(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB); 
		
		int i;
		int bTradeGoodFound = FALSE;
		for(i = 1; i <= NUM_TRADE_GOODS; i++)
		{
			if(GetPartyStock(i) > 0 || GetTradeGoodStock(i, nLocation) > 0)
			{
				PrettyDebug("Adding Row for " + GetTradeGoodLabel(i) + " to " + GUI_MARKET_TRADE_GOOD_LB);
				AddListBoxRow(	oPC, GUI_MARKET_SCREEN, GUI_MARKET_TRADE_GOOD_LB, 
								GetTradeGoodLabel(i), GetMarketListBoxText(i, nLocation),"",
								"1=" + IntToString(i) + ";2=" + GetTradeGoodPriceString(i, nLocation),"");
				bTradeGoodFound = TRUE;
			}
		} 
		
		if (bTradeGoodFound == FALSE)
		{
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_TRADE_GOOD_LB, TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "TOWN_STOCK_TG_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "PRICE_TG_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "INVENTORY_TG_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "TG_EMPTY_TEXT", FALSE);
		}
		
		int j;
		int bRResFound = FALSE;
		for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
		{
			if(GetPartyStock(j, FALSE) > 0 || GetRareResourceStock(j, nLocation) > 0)
			{
				bRResFound = TRUE;
				PrettyDebug("Adding Row for " + GetRareResourceLabel(j) + " to " + GUI_MARKET_RARE_RES_LB);
				AddListBoxRow(	oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB, 
								GetRareResourceLabel(j), GetMarketListBoxText(j, nLocation, FALSE),"",
								"1=" + IntToString(j) + ";2=" + GetRareResourcePriceString(j, nLocation),"");
			}
		}
		
		if(bRResFound ==  FALSE)
		{
			PrettyDebug("hiding irrelevant stuff");
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB, TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "TOWN_STOCK_RR_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "PRICE_RR_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "INVENTORY_RR_HEADER_TEXT", TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, "RR_EMPTY_TEXT", FALSE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_GOODS_BUTTON, TRUE);
			SetGUIObjectHidden(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_BUTTON, TRUE);
		}
		
		
		SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_BARS_TEXT, -1, IntToString(GetGlobalInt("PARTY_BARS_TEMP")));
		SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText(TRUE));
		SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_TITLE, -1, sMarketName);
	}
}

void ShowTradingInvUI(object oPC)
{
	DisplayGuiScreen(oPC, GUI_TRADE_INV_SCREEN, TRUE, GUI_TRADE_INV_XML);
			
	int i;
	int bTradeGoodFound = FALSE;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		if(GetPartyStock(i) > 0 && GetGlobalInt("00_nStoryStep") >= 2)
		{
			string sText;
			sText = "TRADE_GOOD_NAME=" + GetTradeGoodName(i) + ";";
			sText += "TRADE_GOOD_PARTY=" + IntToString(GetPartyStock(i, TRUE, FALSE)) + ";" ;

			PrettyDebug("Adding Row for " + GetTradeGoodLabel(i) + " to " + GUI_MARKET_TRADE_GOOD_LB);
			AddListBoxRow(	oPC, GUI_TRADE_INV_SCREEN, GUI_TRADE_INV_GOOD_LB, 
							GetTradeGoodLabel(i), sText,"","","");
							
			bTradeGoodFound = TRUE;
		}
	} 
	
	if (bTradeGoodFound == FALSE)
	{
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, GUI_TRADE_INV_GOOD_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, "INVENTORY_TG_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, "TG_EMPTY_TEXT", FALSE);
	}
	
	int j;
	int bRResFound = FALSE;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		if(GetPartyStock(j, FALSE) > 0)
		{
			bRResFound = TRUE;
			string sText;
			sText = "RARE_RES_NAME=" + GetRareResourceName(j) + ";";
			sText += "RARE_RES_PARTY=" + IntToString(GetPartyStock(j, FALSE, FALSE)) + ";" ;

			PrettyDebug("Adding Row for " + GetTradeGoodLabel(i) + " to " + GUI_MARKET_TRADE_GOOD_LB);
			AddListBoxRow(	oPC, GUI_TRADE_INV_SCREEN, GUI_TRADE_INV_RARE_LB, 
							GetRareResourceLabel(i), sText,"","","");
		}
	}
	
	if(bRResFound == FALSE)
	{
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, GUI_MARKET_GOODS_BUTTON, TRUE);
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, GUI_MARKET_RARE_BUTTON, TRUE);
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, "INVENTORY_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_TRADE_INV_SCREEN, "RR_EMPTY_TEXT", FALSE);
	}
	
	SetGUIObjectText( oPC, GUI_TRADE_INV_SCREEN, GUI_MARKET_PARTY_BARS_TEXT, -1, IntToString(GetGlobalInt("PARTY_BARS")));
	SetGUIObjectText( oPC, GUI_TRADE_INV_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText());
		
}

void ShowShippingUI(object oPC)
{
	InitializeTempVariables(0);
	DisplayGuiScreen( oPC, GUI_SHIPPING_SCREEN, TRUE, GUI_SHIPPING_XML);
	
	ClearListBox(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_TRADE_GOOD_LB); 
	ClearListBox(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_RES_LB); 
	
	int i;
	int bTradeGoodFound = FALSE;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		if(GetPartyStock(i) > 0)
		{
			string sText;
			sText = "TRADE_GOOD_NAME=" + GetTradeGoodName(i) + ";";
			sText += "TRADE_GOOD_PARTY=" + IntToString(GetPartyStock(i, TRUE, TRUE)) + ";" ;
			sText += "TRADE_GOOD_SHIPPING=" +  IntToString(GetGlobalInt(SHIPPING_PREFIX + GetTradeGoodLabel(i))) + ";";
			PrettyDebug("Adding Row for " + GetTradeGoodLabel(i) + " to " + GUI_MARKET_TRADE_GOOD_LB);
			AddListBoxRow(	oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_TRADE_GOOD_LB, 
								GetTradeGoodLabel(i), sText,"","1=" + IntToString(i) + ";","");
			
			bTradeGoodFound = TRUE;
		}
	} 
			
	if (bTradeGoodFound == FALSE)
	{
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_TRADE_GOOD_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "SHIPPING_TG_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "INVENTORY_TG_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "TG_EMPTY_TEXT", FALSE);
	}

	int j;
	int bRResFound = FALSE;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		if(GetPartyStock(j, FALSE) > 0)
		{
			bRResFound = TRUE;
			string sText;
			sText = "RARE_RES_NAME=" + GetRareResourceName(j) + ";";
			sText += "RARE_RES_PARTY=" + IntToString(GetPartyStock(j, FALSE, TRUE)) + ";" ;
			sText += "RARE_RES_SHIPPING=" +  IntToString(GetGlobalInt(SHIPPING_PREFIX + GetRareResourceLabel(j))) + ";";
			
			PrettyDebug("Adding Row for " + GetRareResourceLabel(j) + " to " + GUI_MARKET_RARE_RES_LB);
			AddListBoxRow(	oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_RES_LB, 
							GetRareResourceLabel(j), sText,"","1=" + IntToString(j) + ";","");
		}
	}
	
	if(bRResFound ==  FALSE)
	{
		PrettyDebug("hiding irrelevant stuff");
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_RES_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "SHIPPING_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "INVENTORY_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, "RR_EMPTY_TEXT", FALSE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_GOODS_BUTTON, TRUE);
		SetGUIObjectHidden(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_BUTTON, TRUE);
	}
	
	SetGUIObjectText( oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText(TRUE));

}

void CloseMarketUI(object oPC, int nLocation)
{
	int i;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		SetTradeGoodStock(i, nLocation, GetTradeGoodStock(i,nLocation, TRUE));
		SetGlobalInt(PARTY_PREFIX + GetTradeGoodLabel(i), GetPartyStock(i, TRUE, TRUE));
		PrettyDebug("Setting " + PARTY_PREFIX + GetTradeGoodLabel(i) + " to " + IntToString(GetPartyStock(i, TRUE, TRUE)));
	} 
	
	int j;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		SetRareResourceStock(j, nLocation, GetRareResourceStock(j,nLocation, TRUE));
		SetGlobalInt(PARTY_PREFIX + GetRareResourceLabel(j), GetPartyStock(j, FALSE, TRUE));
	}
	
	SetGlobalInt("PARTY_BARS", GetGlobalInt("PARTY_BARS" + TEMP_SUFFIX));
	SetGlobalInt("PARTY_CARGO", GetGlobalInt("PARTY_CARGO"  + TEMP_SUFFIX));
	
	ClearListBox(oPC, GUI_MARKET_SCREEN, GUI_MARKET_TRADE_GOOD_LB); 
	ClearListBox(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB); 
	
	CloseGUIScreen(oPC, GUI_MARKET_SCREEN);
}

void CloseShippingUI(object oPC)
{
	int i;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		StoreCargo(i, GetGlobalInt(SHIPPING_PREFIX + GetTradeGoodLabel(i)));
		SetGlobalInt(PARTY_PREFIX + GetTradeGoodLabel(i), GetPartyStock(i, TRUE, TRUE));
		PrettyDebug("Setting " + PARTY_PREFIX + GetTradeGoodLabel(i) + " to " + IntToString(GetPartyStock(i, TRUE, TRUE)));
	} 
	
	int j;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		StoreCargo(j, GetGlobalInt(SHIPPING_PREFIX + GetRareResourceLabel(j)), FALSE);
		SetGlobalInt(PARTY_PREFIX + GetRareResourceLabel(j), GetPartyStock(j, FALSE, TRUE));
	}
	
	SetGlobalInt("PARTY_CARGO", GetGlobalInt("PARTY_CARGO"  + TEMP_SUFFIX));
	
	ClearListBox(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_TRADE_GOOD_LB); 
	ClearListBox(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_RES_LB); 
	
	CloseGUIScreen(oPC, GUI_SHIPPING_SCREEN);	
}

void ShowStorageUI(object oPC)
{
	DisplayGuiScreen( oPC, GUI_STORAGE_SCREEN, TRUE, GUI_STORAGE_XML);
	
	ClearListBox(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_TRADE_GOOD_LB); 
	
	int i;
	int bTradeGoodFound = FALSE;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		if(GetPartyStock(i) > 0 || GetStorageStock(i) > 0)
		{
			PrettyDebug("Adding Row for " + GetTradeGoodLabel(i) + " to " + GUI_MARKET_TRADE_GOOD_LB);
			AddListBoxRow(	oPC, GUI_STORAGE_SCREEN, GUI_MARKET_TRADE_GOOD_LB, GetTradeGoodLabel(i), GetStorageListBoxText(i),"",
						"1=" + IntToString(i),"");
			
			bTradeGoodFound = TRUE;
		}
	} 
	
	if (bTradeGoodFound == FALSE)
	{
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_TRADE_GOOD_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "SHIPPING_TG_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "INVENTORY_TG_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "TG_EMPTY_TEXT", FALSE);		
	}
	
	int j;
	int bRResFound = FALSE;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		if(GetPartyStock(j, FALSE) > 0 || GetStorageStock(j, FALSE) > 0)
		{
			PrettyDebug("Adding Row for " + GetRareResourceLabel(j) + " to " + GUI_MARKET_RARE_RES_LB);
			AddListBoxRow(	oPC, GUI_STORAGE_SCREEN, GUI_MARKET_RARE_RES_LB, 
							GetRareResourceLabel(j), GetStorageListBoxText(j, FALSE),"",
							"1=" + IntToString(j),"");
							
			bRResFound = TRUE;
		}
	}

		if(bRResFound ==  FALSE)
	{
		PrettyDebug("hiding irrelevant stuff");
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_RARE_RES_LB, TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "SHIPPING_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "INVENTORY_RR_HEADER_TEXT", TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, "RR_EMPTY_TEXT", FALSE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_GOODS_BUTTON, TRUE);
		SetGUIObjectHidden(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_RARE_BUTTON, TRUE);
	}
	SetGUIObjectText( oPC, GUI_STORAGE_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText());
}

string GetMarketListBoxText(int nIndex, int nLocation, int bGood = TRUE)
{
	string sResult;
	if(bGood)
	{
			sResult = "TRADE_GOOD_NAME=" + GetTradeGoodName(nIndex) + ";" ;
			sResult += "TRADE_GOOD_TOWN=" + IntToString(GetTradeGoodStock(nIndex, nLocation, TRUE))+ ";";
			switch( GetTradeGoodPriceLevel(nIndex, nLocation))
			{
				case PRICE_LOW:
					sResult += "TRADE_GOOD_PRICE=<color=Blue>" + IntToString(GetTradeGoodPrice(nIndex, nLocation)) + "</color>;";
				break;
				case PRICE_MED:
					sResult += "TRADE_GOOD_PRICE=" + IntToString(GetTradeGoodPrice(nIndex, nLocation)) + ";";
				break;
				case PRICE_HIGH:
					sResult += "TRADE_GOOD_PRICE=<color=Gold>" + IntToString(GetTradeGoodPrice(nIndex, nLocation)) + "</color>;";
				break;
			}
			sResult += "TRADE_GOOD_PARTY=" + IntToString(GetPartyStock(nIndex, TRUE, TRUE)) + ";";
	}
	else
	{
			sResult = "RARE_RES_NAME=" + GetRareResourceName(nIndex) + ";" ;
			sResult += "RARE_RES_TOWN=" + IntToString(GetRareResourceStock(nIndex, nLocation, TRUE))+ ";";
			sResult += "RARE_RES_PRICE=" + IntToString(GetRareResourcePrice(nIndex, nLocation)) + ";";
			sResult += "RARE_RES_PARTY=" + IntToString(GetPartyStock(nIndex, FALSE, TRUE)) + ";";
	}
	
	//PrettyDebug(sResult);
	return sResult;
}

string GetStorageListBoxText(int nIndex, int bGood = TRUE)
{
	string sResult;
	if(bGood)
	{
			sResult = "TRADE_GOOD_NAME=" + GetTradeGoodName(nIndex) + ";" ;
			sResult += "TRADE_GOOD_STORAGE=" + IntToString(GetStorageStock(nIndex)) + ";";
			sResult += "TRADE_GOOD_PARTY=" + IntToString(GetPartyStock(nIndex)) + ";";
	}
	else
	{
			sResult = "RARE_RES_NAME=" + GetRareResourceName(nIndex) + ";" ;
			sResult += "RARE_RES_STORAGE=" + IntToString(GetStorageStock(nIndex, FALSE))+ ";";
			sResult += "RARE_RES_PARTY=" + IntToString(GetPartyStock(nIndex, FALSE)) + ";";
	}
	
	//PrettyDebug(sResult);
	return sResult;
}

void InitializeTempVariables(int nLocation)
{
	int i;
	for(i = 1; i <= NUM_TRADE_GOODS; i++)
	{
		SetTradeGoodStock(i, nLocation, GetTradeGoodStock(i,nLocation), TRUE);
		SetGlobalInt(PARTY_PREFIX + GetTradeGoodLabel(i) + TEMP_SUFFIX, GetPartyStock(i));
		SetGlobalInt(SHIPPING_PREFIX + GetTradeGoodLabel(i), 0);
	} 
	
	int j;
	for(j = 1; j <= GetNum2DARows(RES_2DA); j++)
	{
		SetRareResourceStock(j, nLocation, GetRareResourceStock(j,nLocation), TRUE);
		SetGlobalInt(PARTY_PREFIX + GetRareResourceLabel(j) + TEMP_SUFFIX, GetPartyStock(j, FALSE));
		SetGlobalInt(SHIPPING_PREFIX + GetRareResourceLabel(j), 0);
	}
	
	SetGlobalInt("PARTY_BARS" + TEMP_SUFFIX, GetGlobalInt("PARTY_BARS"));
	SetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX, GetGlobalInt("PARTY_CARGO"));
}

void UpdateMarketUI(object oPC, int nIndex, int nLocation, int bGood = TRUE)
{
	if(bGood)
	{
		ModifyListBoxRow(oPC, GUI_MARKET_SCREEN, GUI_MARKET_TRADE_GOOD_LB, 
			GetTradeGoodLabel(nIndex), GetMarketListBoxText(nIndex, nLocation),"","","");
	}
	else
	{
		ModifyListBoxRow(oPC, GUI_MARKET_SCREEN, GUI_MARKET_RARE_RES_LB, 
			GetRareResourceLabel(nIndex), GetMarketListBoxText(nIndex, nLocation, FALSE),"","","");
	}
	
	SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_BARS_TEXT, -1, IntToString(GetGlobalInt("PARTY_BARS_TEMP")));
	SetGUIObjectText( oPC, GUI_MARKET_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText(TRUE));
}

void UpdateStorageUI(object oPC, int nIndex, int bGood = TRUE)
{
	if(bGood)
	{
		ModifyListBoxRow(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_TRADE_GOOD_LB, 
			GetTradeGoodLabel(nIndex), GetStorageListBoxText(nIndex),"","","");
	}
	
	else
	{
		ModifyListBoxRow(oPC, GUI_STORAGE_SCREEN, GUI_MARKET_RARE_RES_LB, 
			GetRareResourceLabel(nIndex), GetStorageListBoxText(nIndex, FALSE),"","","");
	}
	
	SetGUIObjectText( oPC, GUI_STORAGE_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText());
}

void UpdateShippingUI(object oPC, int nIndex, int bGood = TRUE)
{
	if(bGood)
	{
		string sText;
		sText = "TRADE_GOOD_NAME=" + GetTradeGoodName(nIndex) + ";";
		sText += "TRADE_GOOD_PARTY=" + IntToString(GetPartyStock(nIndex, TRUE, TRUE)) + ";" ;
		sText += "TRADE_GOOD_SHIPPING=" +  IntToString(GetGlobalInt(SHIPPING_PREFIX + GetTradeGoodLabel(nIndex))) + ";";
		
		ModifyListBoxRow(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_TRADE_GOOD_LB, GetTradeGoodLabel(nIndex), sText,"","","");
	}
	
	else
	{
		string sText;
		sText = "RARE_RES_NAME=" + GetRareResourceName(nIndex) + ";";
		sText += "RARE_RES_PARTY=" + IntToString(GetPartyStock(nIndex, FALSE, TRUE)) + ";" ;
		sText += "RARE_RES_SHIPPING=" +  IntToString(GetGlobalInt(SHIPPING_PREFIX + GetRareResourceLabel(nIndex))) + ";";
		
		ModifyListBoxRow(oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_RARE_RES_LB, GetRareResourceLabel(nIndex), sText,"","","");
	}
	
	SetGUIObjectText( oPC, GUI_SHIPPING_SCREEN, GUI_MARKET_PARTY_CARGO_TEXT, -1, GetCargoUIText(TRUE));
}

string GetCargoUIText(int bTemp = FALSE)
{
	string sVar = "PARTY_CARGO";
	if (bTemp) 
		sVar += TEMP_SUFFIX;
	
	int nPartyCargo = (GetGlobalInt(sVar));
	int nMaxCargo = GetWagonMaxCargo(GetGlobalInt("PARTY_WAGON"));
	string sResult = IntToString(nPartyCargo) + "/" + IntToString(nMaxCargo);
	
	return sResult;
}

void ShowTurnInUI(object oPC, int bDonate)
{
	PrettyDebug("Showing Turn In UI for " + GetName(oPC));
	DisplayGuiScreen( oPC, GUI_TURNIN_SCREEN, TRUE, GUI_TURNIN_XML);
	SetLocalGUIVariable( oPC, GUI_TURNIN_SCREEN, 1000, IntToString(bDonate));
	UpdateTurnInUI(oPC, TRUE);
}

void UpdateTurnInUI(object oPC, int bInit = FALSE)
{
	int nMaxTurnIn = GetPartyBars();
	if(nMaxTurnIn > 0 || bInit)
	{
		SetGUIObjectText( oPC, GUI_TURNIN_SCREEN, GUI_TURNIN_PARTY_BARS_TEXT, -1, IntToString(GetGlobalInt("PARTY_BARS")));
		SetScrollBarRanges(oPC, GUI_TURNIN_SCREEN, GUI_TURNIN_SCROLLBAR, 0, nMaxTurnIn, 0, nMaxTurnIn);
		SetScrollBarValue(oPC, GUI_TURNIN_SCREEN, GUI_TURNIN_SCROLLBAR, 0);
	}
	if(nMaxTurnIn <= 0)
		CloseGUIScreen(oPC, GUI_TURNIN_SCREEN);
}

void ShowCaravanUI(object oPC, int bConstruct = FALSE, int nLocation = 0)
{
	DisplayGuiScreen( oPC, GUI_CARAVAN_SCREEN, TRUE, GUI_CARAVAN_XML);
	SetLocalGUIVariable( oPC, GUI_CARAVAN_SCREEN, 9000, IntToString(bConstruct));
	PopulateCaravanSourceListbox(oPC, bConstruct, nLocation);
}

void PopulateCaravanSourceListbox(object oPC, int bConstruct = FALSE, int nLocation = 0)
{
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_SOURCE_LB);
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_DEST_LB);
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_TEXT_LB);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "UPGRADE_BUTTON", TRUE);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "ESTABLISH_BUTTON", TRUE);
	
	if ( !bConstruct )
	{
		AddListBoxRow(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_SOURCE_LB, 
			  GetLocationLabel(14), "SOURCE_NAME=" + GetLocationName(14),"", "1=14","");
	}

	if (bConstruct)			//If we are building a new caravan, we only want to show the current location as a source.
	{
		AddListBoxRow(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_SOURCE_LB, 
					  "SOURCE_" + GetLocationLabel(nLocation), "SOURCE_NAME=" + GetLocationName(nLocation),"", "1=" + IntToString(nLocation),"");
	}
	
	else					//Otherwise, we are checking our status, so we want to show all available locations.
	{
		int i=1;
		for (i=1; i < ( GetNum2DARows( ECON_2DA ) - 1); i++)		//This is -1 because Crossroad Keep got added at the end but we want it showing up first.
		{
			string sConnections = Get2DAString(ECON_2DA, "CONNECTIONS", i);
			if(sConnections != "")									//Only towns w/ connections are valid sources for the caravan system.
			{
				AddListBoxRow(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_SOURCE_LB, 
					  "SOURCE_" + GetLocationLabel(i), "SOURCE_NAME=" + GetLocationName(i),"", "1=" + IntToString(i),"");
				if(!GetHasTradingPost(i))
				{
					SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "SOURCE_" + GetLocationLabel(i), TRUE);
				}
			}
		}
	}
}

void PopulateCaravanDestinationListbox(object oPC, int nSourceIndex)
{
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_DEST_LB);
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_TEXT_LB);
	string sDestConnections = Get2DAString(ECON_2DA, "CONNECTIONS", nSourceIndex);
	PrettyDebug("Connections to " + GetLocationLabel(nSourceIndex) +":" + sDestConnections);
	int nParam = GetIntParam(sDestConnections, 0);
	int i=0;
	
	while (nParam != 0)
	{
		AddListBoxRow(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_DEST_LB, 
		 				  "DEST_" + GetLocationLabel(nParam), "DEST_NAME=" + GetLocationName(nParam),"", "1=" + IntToString(nParam),"");
		
		if(!GetHasTradingPost(nParam))
		{
			SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "DEST_" + GetLocationLabel(nParam), TRUE);
		}
		++i;
						  
		nParam = GetIntParam(sDestConnections, i);
	}
}

void PopulateCaravanTextListbox(object oPC, int nSourceIndex, int nDestinationIndex, int bConstruct)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	ClearListBox(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_TEXT_LB);
	
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "UPGRADE_BUTTON", TRUE);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "ESTABLISH_BUTTON", TRUE);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_INCOME_TEXT", TRUE);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_PRICE_TEXT", TRUE);
	
	string sDescription = GetStringByStrRef(Get2DAInt( CARAVAN_DESC_2DA, GetLocationLabel(nDestinationIndex), nSourceIndex));
	string sCaravanStatus = GetCaravanStateString(nDestinationIndex, nSourceIndex);
	string sCaravanIncome = GetStringByStrRef(234503);
	int nIncome = GetCaravanIncome(nSourceIndex, nDestinationIndex, GetCaravanLevel(nSourceIndex, nDestinationIndex));
	
	sCaravanIncome += " ";
	sCaravanIncome += IntToString(nIncome);
	
	AddListBoxRow(oPC, GUI_CARAVAN_SCREEN, GUI_CARAVAN_TEXT_LB,
				  "DESC_TEXT", "CARAVAN_DESC_TEXT=" + sDescription,"","","");
	
	if(nIncome > 0)
	{
		SetGUIObjectText(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_INCOME_TEXT",  -1, sCaravanIncome);
		SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_INCOME_TEXT", FALSE);
	}
				  
	SetGUIObjectText(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_STATUS_TEXT",  -1, sCaravanStatus);
	SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_STATUS_TEXT", FALSE);
	int nCanCreate = GetCanCreateCaravan(nSourceIndex, nDestinationIndex, oPC);
	int nCanUpgrade = GetCanUpgradeCaravan(nSourceIndex, nDestinationIndex, oPC);
	
	if(nCanCreate >= 0 && bConstruct)
	{
		string sPrice = GetStringByStrRef(234504);
		sPrice += " ";
		sPrice += IntToString(GetCaravanBasePrice(nSourceIndex, nDestinationIndex));
		sPrice += GetStringByStrRef(184760);
		
		SetGUIObjectText(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_PRICE_TEXT",  -1, sPrice);
		SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_PRICE_TEXT", FALSE);
		SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "ESTABLISH_BUTTON", FALSE);
		
		if(nCanCreate == 0)
			SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "ESTABLISH_BUTTON", TRUE);
			
		else
			SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "ESTABLISH_BUTTON", FALSE);
	}
	
	else if (nCanUpgrade >= 0 && bConstruct)
	{
		SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "UPGRADE_BUTTON", FALSE);
				
		string sPrice = GetStringByStrRef(234505);
		sPrice += " ";
		sPrice += IntToString(GetCaravanUpgradePrice(nSourceIndex, nDestinationIndex));
		sPrice += GetStringByStrRef(184760);
		
		SetGUIObjectText(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_PRICE_TEXT",  -1, sPrice);
		SetGUIObjectHidden(oPC, GUI_CARAVAN_SCREEN, "CARAVAN_PRICE_TEXT", FALSE);
		
		if(nCanUpgrade == 0)
			SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "UPGRADE_BUTTON", TRUE);
			
		else
			SetGUIObjectDisabled(oPC, GUI_CARAVAN_SCREEN, "UPGRADE_BUTTON", FALSE);
	}
}


/*----------------------\
|	Caravan Functions	|
\----------------------*/
string AppendCaravanAsString(int nSourceIndex, int nDestinationIndex, int nLevel)
{
	int bReturn = FALSE;
	if(nSourceIndex > nDestinationIndex)
	{
		bReturn = TRUE;
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
		
	if(GetCaravanState(nSourceIndex, nDestinationIndex) == CARAVAN_STATE_NONE)
		SetCaravanState(nSourceIndex, nDestinationIndex, CARAVAN_STATE_CONSTRUCTING);
	
	else
	{
		if( GetCaravanState(nSourceIndex, nDestinationIndex) == CARAVAN_STATE_CONSTRUCTING )
			SetCaravanState(nSourceIndex, nDestinationIndex, CARAVAN_STATE_UPGRADING_2);
			
		else if(GetCaravanState(nSourceIndex, nDestinationIndex) == CARAVAN_STATE_UPGRADING_2)
			SetCaravanState(nSourceIndex, nDestinationIndex, CARAVAN_STATE_UPGRADING_3);
		
		else
		{
			int nLevel = GetCaravanLevel(nSourceIndex, nDestinationIndex);
			switch(nLevel)
			{
				case 1:
					SetCaravanState(nSourceIndex, nDestinationIndex, CARAVAN_STATE_UPGRADING_2);
					break;
				
				case 2:
					SetCaravanState(nSourceIndex, nDestinationIndex, CARAVAN_STATE_UPGRADING_3);
					break;
			}
		}
	}
	
	string sCurrentCaravans = GetGlobalString(VAR_CARAVAN_SPAWN_STRING);
	
	//Caravan strings are in the format x1,y1,z1;x2,z2,z3;etc... X, Y, and Z correspond to the parameters to the CreateCaravan function.
	
	string sAppend = ( IntToString(nSourceIndex) + "," +  IntToString(nDestinationIndex) + "," + IntToString(nLevel) + "," + IntToString(bReturn) + ";"  );
	
	sCurrentCaravans += sAppend;
	PrettyDebug(sCurrentCaravans);
	SetGlobalString(VAR_CARAVAN_SPAWN_STRING, sCurrentCaravans);
	return sCurrentCaravans;
}

void ProcessCaravansOnEnter()
{
	string sCaravansToSpawn = GetGlobalString(VAR_CARAVAN_SPAWN_STRING);
	int i=0;
	string sParam = GetStringParam(sCaravansToSpawn, i, ";");
	
	while(sParam != "")
	{
		CreateCaravanFromString(sParam);
		++i;
		sParam = GetStringParam(sCaravansToSpawn, i, ";");
	}
	
	SetGlobalString(VAR_CARAVAN_SPAWN_STRING, "");
}

void CreateCaravanFromString(string sCaravanString)
{
	int nStartingIndex = GetIntParam(sCaravanString, 0);
	int nDestinationIndex = GetIntParam(sCaravanString, 1);
	int nLevel = GetIntParam(sCaravanString, 2);
	int bReturn = GetIntParam(sCaravanString, 3);
	CreateCaravan(nStartingIndex, nDestinationIndex, nLevel, bReturn);
}

string GetCaravanTag(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	string sRet = "nx2_caravan_" + IntToString(nSourceIndex) + "_" + IntToString(nDestinationIndex);
	return sRet;
}

void CreateCaravan(int nSourceIndex, int nDestinationIndex, int nLevel, int bReturn)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	int nCaravanState = GetCaravanState(nSourceIndex, nDestinationIndex);
	if( !GetIsObjectValid(GetObjectByTag(GetCaravanTag(nSourceIndex, nDestinationIndex))))
	{
		//Set up the Caravan's starting route. It is in the format:
		//WP_X_to_Y - where X is the nStartingIndex and Y is the nDestinationIndex.
		string sRoute = IntToString(nSourceIndex);
		sRoute += "_to_";
		sRoute += IntToString(nDestinationIndex);
	
		string sResRef = "nx2_ac_caravan";
		sResRef += IntToString(nLevel);
	
		PrettyDebug("sRoute:" + sRoute);
		PrettyDebug("sResref:" + sResRef);
		object oWP = GetWaypointByTag("WP_" + sRoute + "_01");
		object oCaravan = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oWP), FALSE, GetCaravanTag(nSourceIndex, nDestinationIndex));
		SetWWPController(sRoute, oCaravan);
		AssignCommand(oCaravan, WalkWayPoints(TRUE));
		
		SetWalkCondition(NW_WALK_FLAG_CONSTANT, TRUE);
		SetCaravanLevel(nSourceIndex, nDestinationIndex, nLevel);
		SetLocalInt(oCaravan, "nSourceIndex", nSourceIndex);
		SetLocalInt(oCaravan, "nDestinationIndex", nDestinationIndex);
		if(!bReturn)			//This is a little weird... but if I am making a return trip, I want to process WP 1 as if I had just completed a NON-return trip.
			SetLocalInt(oCaravan, "bReturn", TRUE);
		
		SetLocalInt(oCaravan, "bNeutral", TRUE);
		MarkAsDone(oCaravan);	//This is done to avoid giving me income.
		JumpToNextWP(1);		//And this starts us on our route.
	}
	
	else if (nLevel > GetCaravanLevel(nSourceIndex, nDestinationIndex))
	{
		//Set up the Caravan's starting route. It is in the format:
		//WP_X_to_Y - where X is the nStartingIndex and Y is the nDestinationIndex.
		string sRoute = IntToString(nSourceIndex);
		sRoute += "_to_";
		sRoute += IntToString(nDestinationIndex);
	
		string sResRef = "nx2_ac_caravan";
		sResRef += IntToString(nLevel);
	
		PrettyDebug("sRoute:" + sRoute);
		PrettyDebug("sResref:" + sResRef);
		
		object oOldCaravan = GetObjectByTag(GetCaravanTag(nSourceIndex, nDestinationIndex));
		location lLoc = GetLocation(oOldCaravan);
		int nNextWP = GetLocalInt(oOldCaravan, VAR_WP_NEXT);	
		object oCaravan = CreateObject(OBJECT_TYPE_CREATURE, sResRef, lLoc, FALSE, GetCaravanTag(nSourceIndex, nDestinationIndex));
		DestroyObject(oOldCaravan);
		
		SetWWPController(sRoute, oCaravan);
		AssignCommand(oCaravan, SetNextWaypoint(nNextWP));
		AssignCommand(oCaravan, WalkWayPoints(TRUE));
		
		SetCaravanLevel(nSourceIndex, nDestinationIndex, nLevel);
		SetLocalInt(oCaravan, "nSourceIndex", nSourceIndex);
		SetLocalInt(oCaravan, "nDestinationIndex", nDestinationIndex);
	}
}

void AwardCaravanIncome(object oCaravan)
{
	int nStartingLocation = GetLocalInt(OBJECT_SELF, "nSourceIndex");
	int nDestLoc = GetLocalInt(OBJECT_SELF, "nDestinationIndex");
	int nCaravanLevel = GetCaravanLevel(nStartingLocation, nDestLoc);
	int nIncome = GetCaravanIncome(nStartingLocation, nDestLoc, nCaravanLevel);
	PrettyDebug("Awarding Trade Bars: " + IntToString(nIncome));
	AddToIncome(nIncome);
}

void ProcessCaravanOrigin()
{
	int bReturn = GetLocalInt(OBJECT_SELF, "bReturn");
	
	if(GetCurrentHitPoints() < GetMaxHitPoints())
	{
		PrettyDebug("Waiting to restore HP...");
		ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(1), OBJECT_SELF);
		int nStartingLocation = GetLocalInt(OBJECT_SELF, "nSourceIndex");
		int nDestLoc = GetLocalInt(OBJECT_SELF, "nDestinationIndex");
		SetCaravanState(nStartingLocation, nDestLoc, CARAVAN_STATE_REFILL);
		FaceAndPause(GetCurrentWaypoint(), 6.0f);
		SetNextWaypoint(GetCurrentWaypoint());
	}
				
	else
    {
		PrettyDebug("HP Full, starting route");
		
		if(bReturn)	 //If I have just completed a return trip... 
		{
			AwardCaravanIncome(OBJECT_SELF);
			SetLocalInt(OBJECT_SELF, "bReturn", FALSE);
			int nStartingLocation = GetLocalInt(OBJECT_SELF, "nSourceIndex");
			int nDestLoc = GetLocalInt(OBJECT_SELF, "nDestinationIndex");
			SetCaravanState(nStartingLocation, nDestLoc, CARAVAN_STATE_IN_TRANSIT_HIGHER);
			JumpToNextWP(2);
		}
		
		else
		{
			AwardCaravanIncome(OBJECT_SELF);
			SetLocalInt(OBJECT_SELF, "bReturn", TRUE);
			int nStartingLocation = GetLocalInt(OBJECT_SELF, "nSourceIndex");
			int nDestLoc = GetLocalInt(OBJECT_SELF, "nDestinationIndex");			
			int nEndpoint = GetLocalInt(OBJECT_SELF, "nEndpoint");
			SetCaravanState(nStartingLocation, nDestLoc, CARAVAN_STATE_IN_TRANSIT_LOWER);
			JumpToNextWP(nEndpoint);
		}
	}  
}

void ProcessCaravanDestination(int nNodeNumber)
{
	ActionWait(12.0f);
	DelayCommand(12.0f, SetNextWaypoint(nNodeNumber - 1));
    DelayCommand(12.0f, SetLocalInt(OBJECT_SELF, "bReturn", TRUE));
}

int GetCaravanState(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	int nRet = GetGlobalInt( VAR_CARAVAN_PREFIX + IntToString(nSourceIndex) + "_" + IntToString(nDestinationIndex)+ "_STATE" );
	return nRet;
}

string GetCaravanStateString(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	int nState = GetCaravanState(nSourceIndex, nDestinationIndex);
	string sRet = GetStringByStrRef(234507);
	sRet += " ";
	switch (nState)
	{
		case CARAVAN_STATE_NONE:
			sRet += GetStringByStrRef(183997);
			break;
		
		case CARAVAN_STATE_CONSTRUCTING:
			sRet += GetStringByStrRef(234508);
			break;
		
		case CARAVAN_STATE_UPGRADING_2:
			sRet += GetStringByStrRef(234509);
			break;
		
		case CARAVAN_STATE_UPGRADING_3:
			sRet += GetStringByStrRef(234510);
			break;			
		
		case CARAVAN_STATE_IN_TRANSIT_LOWER:
		{
			string sDestination = GetLocationName(nSourceIndex);
			sRet += GetStringByStrRef(234511);
			sRet += " ";
			sRet += sDestination;
			break;
		}
		
		case CARAVAN_STATE_IN_TRANSIT_HIGHER:
		{
			string sDestination = GetLocationName(nDestinationIndex);
			sRet += GetStringByStrRef(234511);
			sRet += " ";
			sRet += sDestination;
			break;
		}
		
		case CARAVAN_STATE_REFILL:
			sRet += GetStringByStrRef(234512);
			break;
		
		case CARAVAN_STATE_WAYLAID:
			sRet += GetStringByStrRef(234513);
			break;
	}
	
	return sRet;
}

void SetCaravanState(int nSourceIndex, int nDestinationIndex, int nCaravanState)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	string sVarName = VAR_CARAVAN_PREFIX + IntToString(nSourceIndex) + "_" + IntToString(nDestinationIndex)+ "_STATE";
	SetGlobalInt(sVarName, nCaravanState);
}

void SetCaravanLevel(int nSourceIndex, int nDestinationIndex, int nCaravanLevel)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	string sVarName = VAR_CARAVAN_PREFIX + IntToString(nSourceIndex) + "_" + IntToString(nDestinationIndex)+ "_LEVEL";
	SetGlobalInt(sVarName, nCaravanLevel);
}

int GetCaravanLevel(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	int nRet = GetGlobalInt(VAR_CARAVAN_PREFIX + IntToString(nSourceIndex) + "_" + IntToString(nDestinationIndex)+ "_LEVEL");
	return nRet;
}

int GetCanCreateCaravan(int nSourceIndex, int nDestinationIndex, object oPC = OBJECT_SELF)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	int nState = GetCaravanState(nSourceIndex, nDestinationIndex);
	PrettyDebug(IntToString(nState));
	
	if (nState == CARAVAN_STATE_NONE)
	{
		int nGoldCost = GetCaravanBasePrice(nSourceIndex, nDestinationIndex);
		if(GetGold(oPC) >= nGoldCost)
			return TRUE;
			
		else return 0;
	}	
	return -1;
}

int GetCanUpgradeCaravan(int nSourceIndex, int nDestinationIndex, object oPC = OBJECT_SELF)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	int nState = GetCaravanState(nSourceIndex, nDestinationIndex);
	int nLevel = GetCaravanLevel(nSourceIndex, nDestinationIndex);
	if (nState == CARAVAN_STATE_NONE || nState == CARAVAN_STATE_WAYLAID || nState == CARAVAN_STATE_UPGRADING_3 )
		return FALSE;
		
	else if (nLevel <3)
	{
		int nGoldCost = GetCaravanUpgradePrice(nSourceIndex, nDestinationIndex);
		if(GetGold(oPC) >= nGoldCost)
			return TRUE;
			
		else return 0;
	}
		
	return -1;
}

int GetCaravanUpgradePrice(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	int nLevel = 0;
	
	if( GetCaravanState(nSourceIndex, nDestinationIndex) == CARAVAN_STATE_CONSTRUCTING )
		nLevel = 2;

	else if(GetCaravanState(nSourceIndex, nDestinationIndex) == CARAVAN_STATE_UPGRADING_2)
		nLevel = 3;
		
	else
	{
		int nExistingLevel = GetCaravanLevel(nSourceIndex, nDestinationIndex);
		switch(nExistingLevel)
		{
			case 1:
				nLevel = 2;
				break;
				
			case 2:
				nLevel = 3;
				break;
		}
	}
	
	int nBasePrice = GetCaravanBasePrice(nSourceIndex, nDestinationIndex);
	
	int nUpgrade = nBasePrice * nLevel;
	return nUpgrade;
}

int GetCaravanIncome(int nSourceIndex, int nDestinationIndex, int nLevel = 0)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	if (nLevel == 0)
		return -1;

	int nBaseIncome = GetCaravanBaseIncome(nSourceIndex, nDestinationIndex);
	float fBaseIncome = IntToFloat(nBaseIncome);
	
	if(nLevel == 2)
		fBaseIncome *= 1.5;
		
	else if (nLevel == 3)
		fBaseIncome *= 2;
		
	int nIncome = FloatToInt(fBaseIncome);
	return nIncome;
		
}

int GetCaravanBasePrice(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	int nPrice = Get2DAInt( CARAVAN_PRICE_2DA, GetLocationLabel(nDestinationIndex), nSourceIndex);
	return nPrice;
}

int GetCaravanBaseIncome(int nSourceIndex, int nDestinationIndex)
{
	if(nSourceIndex > nDestinationIndex)
	{
		int nTemp = nDestinationIndex;
		nDestinationIndex = nSourceIndex;
		nSourceIndex = nTemp;
	}
	
	int nIncome = Get2DAInt( CARAVAN_INCOME_2DA, GetLocationLabel(nDestinationIndex), nSourceIndex);
	return nIncome;
}
/*----------------------\
|	Time Functions		|
\----------------------*/
void ProcessTimeUnit()
{
	ProcessTowns();
	ProcessCompanyIncome();
}

void ProcessTowns()
{
	int nNumLocations = GetNum2DARows(ECON_2DA);
	
	int nCurrentLoc;
	for(nCurrentLoc = 0; nCurrentLoc < nNumLocations; nCurrentLoc++)
	{
		int nCurrentGood;
	
		for(nCurrentGood = 1; nCurrentGood <= NUM_TRADE_GOODS; nCurrentGood++)
		{
			ProcessGood(nCurrentGood, nCurrentLoc);
		}
		
		int nResourceNodes = GetNum2DARows(RES_NODE_2DA);
		int nCurrentNode;
		
		for(nCurrentNode = 0; nCurrentNode < nResourceNodes; nCurrentNode++)		
		{																			
			ProcessRareResource(nCurrentLoc, nCurrentNode);
		}
	}
}

void ProcessGood(int nCurrentGood, int nCurrentLoc)
{
/*	if (GetShortage(nCurrentGood, nCurrentLoc))
		CausePanic(nCurrentGood, nCurrentLoc);
				
	else if(GetSurplus(nCurrentGood, nCurrentLoc))
		CauseOverage(nCurrentGood, nCurrentLoc);
*/			
	int nStock = DriftToEquilibrium(nCurrentGood, nCurrentLoc);
	int nEQ = GetEquilibriumPoint(nCurrentGood, nCurrentLoc);
			
	PrettyDebug("LOCATION: " + GetLocationLabel(nCurrentLoc) + " STOCK:" + IntToString(nStock) + " EQ:" + IntToString(nEQ));
	SetTradeGoodStock(nCurrentGood, nCurrentLoc, nStock);
/*	
	if( nStock <= GetShortageAmount(nCurrentGood, nCurrentLoc) )
		StartShortage(nCurrentGood, nCurrentLoc);
			
	else if( nStock >= GetSurplusAmount(nCurrentGood, nCurrentLoc) )
		StartSurplus(nCurrentGood, nCurrentLoc);
*/
}

void ProcessRareResource(int nCurrentLoc, int nCurrentNode)
{
	int nNodeLocation = Get2DAInt(RES_NODE_2DA, "LOCATION", nCurrentNode);
						
	if((nNodeLocation == nCurrentLoc) && GetResourceNodeDiscovered(nCurrentNode))
	{
		int nNodeAmount = Get2DAInt(RES_NODE_2DA, "AMOUNT", nCurrentNode);
				
		int nNodeResource = Get2DAInt(RES_NODE_2DA, "RESOURCE", nCurrentNode);
								
		SetRareResourceStock(nNodeResource, nNodeLocation, nNodeAmount);		//We reset the value to what's in the 2DA
	}
}			

int GetStockSizeMultiplier(int nLocation)
{
	int nSizeMult;
	switch (GetLocationSize(nLocation))
	{
		case SIZE_VILLAGE:
			nSizeMult = 1;
		break;
		case SIZE_TOWN:
			nSizeMult = TOWN_STOCK_MULT;
		break;
		case SIZE_CITY:
			nSizeMult = CITY_STOCK_MULT;
		break;
	}
	
	return nSizeMult;
}
int GetStockRegenRate(int nGood, int nLocation)
{
	int nRegenBase;
	switch(GetTradeGoodPriceLevel(nGood, nLocation))
	{
		case PRICE_HIGH:
			nRegenBase = BASE_REGEN_LOW;
		break;
		case PRICE_MED:
			nRegenBase = BASE_REGEN_MED;
		break;
		case PRICE_LOW:
			nRegenBase = BASE_REGEN_HIGH;
		break;
	}
	
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	
	return nRegenBase * nSizeMult;
}

int GetEquilibriumPoint(int nGood, int nLocation)
{
	int nEQBase;
	switch(GetTradeGoodPriceLevel(nGood, nLocation))
	{
		case PRICE_HIGH:
			nEQBase = BASE_EQ_LOW;
		break;
		case PRICE_MED:
			nEQBase = BASE_EQ_MED;
		break;
		case PRICE_LOW:
			nEQBase = BASE_EQ_HIGH;
		break;
	}
	
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	
	return nEQBase * nSizeMult;
}

int GetShortageAmount(int nGood, int nLocation)
{
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	int nResult = BASE_SHORTAGE_AMT * nSizeMult;
	return nResult;
}

int GetSurplusAmount(int nGood, int nLocation)
{
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	int nResult = BASE_SURPLUS_AMT * nSizeMult;
	return nResult;
}

int DriftToEquilibrium(int nGood, int nLocation)
{
	int nStock = GetTradeGoodStock(nGood, nLocation);
	int nEQPoint = GetEquilibriumPoint(nGood, nLocation);
	int nRegen = GetStockRegenRate(nGood, nLocation);
//	PrettyDebug("loc:" + GetLocationLabel(nLocation) + "stock:" + IntToString(nStock) + " EQPoint:" + IntToString(nEQPoint)+ " regen:" + IntToString(nRegen));
	
	if (nStock == nEQPoint)
		return nStock;
		
	else if (nStock < nEQPoint)
	{
		nStock = nStock + nRegen;
		if(nStock > nEQPoint)
			nStock = nEQPoint;
	}
	
	else if (nStock > nEQPoint)
	{
		nStock = nStock - nRegen;
		if(nStock < nEQPoint)
			nStock = nEQPoint;
	}
	
	return nStock;
}

void StartShortage(int nIndex, int nLoc, int bTradeGood = TRUE)
{
	string sLoc = GetLocationLabel(nLoc);
	string sGood;
	if (bTradeGood)	sGood = GetTradeGoodLabel(nIndex);
	else sGood = GetRareResourceLabel(nIndex);
	
	string sVar = sLoc + "_" + sGood + SHORTAGE_SUFFIX;
	PrettyDebug ("Setting " + sVar + " to TRUE");
	SetGlobalInt(sVar, TRUE);
}

void StartSurplus(int nIndex, int nLoc, int bTradeGood = TRUE)
{
	string sLoc = GetLocationLabel(nIndex);
	string sGood;
	if (bTradeGood)	
		sGood = GetTradeGoodLabel(nIndex);
	
	else 
		sGood = GetRareResourceLabel(nIndex);
	
	string sVar = sLoc + "_" + sGood + SURPLUS_SUFFIX;
	PrettyDebug ("Setting " + sVar + " to TRUE");
	SetGlobalInt(sVar, TRUE);
}

void StopShortage(int nIndex, int nLoc, int bTradeGood = TRUE)
{
	string sLoc = GetLocationLabel(nIndex);
	string sGood;
	if (bTradeGood)	sGood = GetTradeGoodLabel(nIndex);
	else sGood = GetRareResourceLabel(nIndex);
	
	string sVar = sLoc + "_" + sGood + SHORTAGE_SUFFIX;
	PrettyDebug ("Setting " + sVar + " to FALSE");
	SetGlobalInt(sVar, FALSE);
}

void StopSurplus(int nIndex, int nLoc, int bTradeGood = TRUE)
{
	string sLoc = GetLocationLabel(nIndex);
	string sGood;
	if (bTradeGood)	sGood = GetTradeGoodLabel(nIndex);
	else sGood = GetRareResourceLabel(nIndex);
	
	string sVar = sLoc + "_" + sGood + SURPLUS_SUFFIX;
	PrettyDebug ("Setting " + sVar + " to FALSE");
	SetGlobalInt(sVar, FALSE);
}

int GetSurplus(int nIndex, int nLoc)
{
 	string sLoc = GetLocationLabel(nLoc);
	string sGood = GetTradeGoodLabel(nIndex);
	string sResult = sLoc + "_" + sGood + SURPLUS_SUFFIX;
	return GetGlobalInt(sResult);
}

int GetShortage(int nIndex, int nLoc)
{
 	string sLoc = GetLocationLabel(nLoc);
	string sGood = GetTradeGoodLabel(nIndex);
	string sResult = sLoc + "_" + sGood + SHORTAGE_SUFFIX;
	return GetGlobalInt(sResult);
}

void CausePanic(int nIndex, int nLocation) 
{
	PrettyDebug("Checking for panics spawned from " + GetLocationLabel(nLocation));
	string sConnect = Get2DAString(ECON_2DA, "CONNECTIONS", nLocation);
	//PrettyDebug(sConnect);
	int nSpreadLoc = GetIntParam(sConnect, 0);
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	
	int nPanicChance = nSizeMult * PANIC_CHANCE;										//The chance of a panic is determined by the town
																						//that is starting the panic.
	int i = 0;			
	while(nSpreadLoc)																	//This loop should be iterating through the list of towns connected to
	{	//the current town.
		PrettyDebug("Rolling for panic at " + GetLocationLabel(nSpreadLoc));
		if(d100(1) < nPanicChance)
		{
			PrettyDebug("Panic Spawning!");
			int nPanicSize = BASE_PANIC_LOSS * GetStockSizeMultiplier(nLocation);		//The SIZE of the panic is determined by the town spawning the panic.
			int nStock = GetTradeGoodStock(nIndex, nLocation) - nPanicSize;				//Subtract the panic value...
			
			if(nStock < 0) nStock = 0;
			
			SetTradeGoodStock(nIndex, nSpreadLoc, nStock);								//And adjust the stock appropriately
		}			
		i++;
		nSpreadLoc = GetIntParam(sConnect, i);
	}
}

void CauseOverage(int nIndex, int nLocation) 
{
	PrettyDebug("Checking for overages spawned from " + GetLocationLabel(nLocation));
	string sConnect = Get2DAString(ECON_2DA, "CONNECTIONS", nLocation);
	int nSpreadLoc = GetIntParam(sConnect, 0);
	int nSizeMult = GetStockSizeMultiplier(nLocation);
	
	int nOverageChance = nSizeMult * OVERAGE_CHANCE;									//The chance of an overage is determined by the town
																						//that is starting the overage.
	int i = 0;			
	while(nSpreadLoc)
	{
		PrettyDebug("Rolling for overage in " + GetLocationLabel(nSpreadLoc) + "...");
		if(d100(1) < nOverageChance)
		{
			PrettyDebug("Overage Spawning!");
			int nOverageSize = BASE_OVERAGE_GAIN * GetStockSizeMultiplier(nLocation);		//The SIZE of the overage is determined by the town spawning the overage.
			int nStock = GetTradeGoodStock(nIndex, nLocation) + nOverageSize;				//Add the overage value...
			
			SetTradeGoodStock(nIndex, nSpreadLoc, nStock);
		}			
		i++;
		nSpreadLoc = GetIntParam(sConnect, i);
	}
}

void PopulateTradeGoods(int bTemp = FALSE)
{
	int nNumLocations = GetNum2DARows(ECON_2DA);
	
	int nCurrentLoc;
	for(nCurrentLoc = 0; nCurrentLoc < nNumLocations; nCurrentLoc++)		//We take each town...
	{
		string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nCurrentLoc);
		
		int nCurrentGood;
		
		for(nCurrentGood = 1; nCurrentGood <= NUM_TRADE_GOODS; nCurrentGood++)		//And then search the list of resource
		{
			int nEQPoint = GetEquilibriumPoint(nCurrentGood, nCurrentLoc);
			SetTradeGoodStock(nCurrentGood, nCurrentLoc, nEQPoint, bTemp);		//We reset the value to the EQ point
		}
	}
}



/*----------------------\
|	Goodie Functions	|
\----------------------*/
int CheckGoodieAwards(object oUser, string sGoods, string sResources)
{
	string sParam = GetStringParam(sGoods, 0);
	int i=0;
	
	while(sParam != "")
	{
		int nNum = StringToInt( GetStringParam(sGoods, i+1) );	//The NEXT parameter we are setting equal to the number to create.
		
		if ( nNum != 0 )										//if nNum is a valid int, we are going to use it as an iterator.
		{
			int nGoodIndex = Search2DA(GOODS_2DA, "LABEL", sParam);
			if(GiveCargo(nGoodIndex, nNum, TRUE, TRUE) != TRUE)				//If the give fails, we want to drop out and return false.
			{
				return FALSE;
			}
			i += 2;												//We want to increment i by 2 in this case to skip the iterator.
		}
		
		else
		{
			int nGoodIndex = Search2DA(GOODS_2DA, "LABEL", sParam);
			if(GiveCargo(nGoodIndex, 1, TRUE, TRUE) != TRUE)				//If the give fails, we want to drop out and return false.
			{
				return FALSE;
			}
			i++;
		}
		
		sParam = GetStringParam(sGoods, i);
	}
	
	sParam = GetStringParam(sResources, 0);
	i=0;
	
	while(sParam != "")
	{
		int nNum = StringToInt( GetStringParam(sResources, i+1) );	//The NEXT parameter we are setting equal to the number to create.
		
		if ( nNum != 0 )										//if nNum is a valid int, we are going to use it as an iterator.
		{
			int nGoodIndex = Search2DA(RES_2DA, "LABEL", sParam);
			if(GiveCargo(nGoodIndex, nNum, FALSE, TRUE) != TRUE)				//If the give fails, we want to drop out and return false.
			{
				return FALSE;
			}			
						
			i += 2;												//We want to increment i by 2 in this case to skip the iterator.
		}
		
		else
		{
			int nGoodIndex = Search2DA(RES_2DA, "LABEL", sParam);
			if(GiveCargo(nGoodIndex, 1, FALSE, TRUE) != TRUE)
			{
				return FALSE;
			}
			i++;
		}
		
		sParam = GetStringParam(sResources, i);
	}
	
	return TRUE;
}

void AwardGoodieGoods(object oUser, string sGoods)
{
	string sParam = GetStringParam(sGoods, 0);
	int i=0;
	
	while(sParam != "")
	{
		int nNum = StringToInt( GetStringParam(sGoods, i+1) );	//The NEXT parameter we are setting equal to the number to create.
		
		if ( nNum != 0 )										//if nNum is a valid int, we are going to use it as an iterator.
		{
			int nGoodIndex = Search2DA(GOODS_2DA, "LABEL", sParam);
			GiveCargo(nGoodIndex, nNum);
						
			i += 2;												//We want to increment i by 2 in this case to skip the iterator.
		}
		
		else
		{
			int nGoodIndex = Search2DA(GOODS_2DA, "LABEL", sParam);
			GiveCargo(nGoodIndex, 1);
			i++;
		}
		
		sParam = GetStringParam(sGoods, i);
	}
}

void AwardGoodieResources(object oUser, string sRareRes)
{
	string sParam = GetStringParam(sRareRes, 0);
	int i=0;
	
	while(sParam != "")
	{
		int nNum = StringToInt( GetStringParam(sRareRes, i+1) );	//The NEXT parameter we are setting equal to the number to create.
		
		if ( nNum != 0 )										//if nNum is a valid int, we are going to use it as an iterator.
		{
			int nGoodIndex = Search2DA(RES_2DA, "LABEL", sParam);
			GiveCargo(nGoodIndex, nNum, FALSE);
						
			i += 2;												//We want to increment i by 2 in this case to skip the iterator.
		}
		
		else
		{
			int nGoodIndex = Search2DA(RES_2DA, "LABEL", sParam);
			GiveCargo(nGoodIndex, 1, FALSE);
			i++;
		}
		
		sParam = GetStringParam(sRareRes, i);
	}
}