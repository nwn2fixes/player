//kinc_trade_system
//Trade System - System sub-include
//NLC 7/21/08
//JSH-OEI 1/6/09: Fixed issue in ProcessCompanyIncome() which was causing
//the reserve to be multiplied with upgrade bonusesinstead of trading post income.
// kevL's 2016 aug 24
//	- fix prototype for ProcessCompanyIncome(). Changed return from int to void.

#include "ginc_debug"
#include "ginc_param_const"
#include "ginc_2da"
#include "kinc_trade_constants"

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
int TurnInBars(int nBarsToTurnIn, int bDonate);
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
void SetPartyStock(int nIndex, int nAmount, int bGood = TRUE, int bTemp = FALSE);
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
void ProcessCompanyIncome(); // kL
void AwardCompanyIncome();
int GetCompanyReserve();
void SetCompanyReserve(int nNewReserve);

/*--------------------------------------\
|	Trade System Function Definitions	|
\--------------------------------------*/

/*--------------------------\
|	Trading Post Functions	|
\--------------------------*/
int EstablishTradingPost(int iLocation)
{
	string sLocLabel = GetLocationLabel(iLocation);
	if(sLocLabel != "")
	{
		PrettyDebug(sLocLabel+ "_TRADEPOST = True");
		SetGlobalInt(sLocLabel+ "_TRADEPOST", TRUE);
		return TRUE;
	}
	
	else
	{
		PrettyDebug("location is invalid...");
		return FALSE;
	}
}
	
/*----------------------\
|	Location Functions	|
\----------------------*/
string GetLocationLabel(int nLocation)
{
	string sResult = Get2DAString(ECON_2DA, "LABEL", nLocation);
	return sResult;
}

string GetLocationName(int nLocation)
{
	int nStrRef = Get2DAInt(ECON_2DA, "STRREF", nLocation);
	string sResult = GetStringByStrRef(nStrRef);
	return sResult;
}

int GetLocationSize(int nLocation)
{
	string sSizeLevel = Get2DAString(ECON_2DA, "SIZE", nLocation);
	
	if(sSizeLevel == "SIZE_VILLAGE")
		return SIZE_VILLAGE;
		
	else if (sSizeLevel == "SIZE_TOWN")
		return SIZE_TOWN;
	
	else if (sSizeLevel == "SIZE_CITY")
		return SIZE_CITY;
		
	else
	{
		PrettyDebug("Invalid Size in 2DA");
		return 0;
	}
}

int GetHasTradingPost(int nLocation)
{
	if(GetLocationLabel(nLocation) == "LOC_CK" )
		return TRUE;
	
	string sLocLabel = GetLocationLabel(nLocation);
	int nResult = GetGlobalInt(sLocLabel + "_TRADEPOST");
	return nResult;
}

/*------------------\
|	Transactions	|
\------------------*/
int GiveCargo(int nIndex, int nAmount, int bGood = TRUE, int bCheck= FALSE, int bTemp = FALSE)
{
	PrettyDebug("Giving Cargo...");
	string sLookup = GOODS_2DA;			// By default, reference the Trade Good 2da.
	if( !bGood )						// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;				// Use the Rare Resources 2da.

	string sLabel = Get2DAString(sLookup, "LABEL", nIndex);
	int nPartyStockOfGood, nPartyCargo;
	
	if ( bTemp )
	{	
		nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel + TEMP_SUFFIX);
		nPartyCargo = GetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX);
	}
	else
	{
		nPartyStockOfGood = GetGlobalInt("PARTY_" + sLabel);
		nPartyCargo = GetGlobalInt ("PARTY_CARGO");
	}
	
	if( sLabel == "")						// If the good we're dealing with isn't in the 2DA, abort.
	{
		PrettyDebug("Error - Attempting to give Invalid Good/Resource.");
		return FALSE;
	}
	
	else if ( nAmount > GetPartyCargoFreeSpace(bTemp) )		// If the party's cargo is full, abort.
	{
		PrettyDebug("Party's cargo is full.  Transaction Failed.");
		return FALSE;
	}
	
	else if ( bCheck ) 					// If we're just checking, don't do it, just return true.
		return TRUE;
	
	else if ( bTemp )									//You've got the good - but we're only altering the TEMP value
	{
		//PrettyDebug("Temp Giving:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood += nAmount;		//Subtract the good/resource from the player's stock.
		nPartyCargo += nAmount;				//Subtract the space from the player's cargo.
		SetGlobalInt(PARTY_PREFIX + sLabel + TEMP_SUFFIX, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX, nPartyCargo);
		return TRUE;
	}
	
	else									//You've got the cargo space so you can accept the good.
	{
		//PrettyDebug("Giving:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood += nAmount;		//Add the amount of the good/resource to the player's stock
		nPartyCargo += nAmount;				//Add the space to the player's current cargo space total
		
		string sFeedback = GetStringByStrRef(STRREF_GAINED_CARGO_FEEDBACK);
		string sAmount = " " + IntToString(nAmount) + " ";
		string sName;
		if (bGood)
			sName = GetTradeGoodName(nIndex);
			
		else
			sName = GetRareResourceName(nIndex);
		
		sFeedback += sAmount;
		sFeedback += sName;
		
		object oPC = GetFirstPC(FALSE);
		while(GetIsObjectValid(oPC))
		{
			SendMessageToPC(oPC, sFeedback);
			oPC = GetNextPC(FALSE);
		}
		SetGlobalInt(PARTY_PREFIX + sLabel, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO", nPartyCargo);
		
		return TRUE;
	}
	return FALSE;
}

int TakeCargo(int nIndex, int nAmount, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE)
{
	string sLookup = GOODS_2DA;			// By default, reference the Trade Good 2da.
	if( !bGood )						// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;				// Use the Rare Resources 2da.
	
	string sLabel = Get2DAString(sLookup, "LABEL", nIndex);
	int nPartyStockOfGood, nPartyCargo;
	
	if ( bTemp )
	{	
		nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel + TEMP_SUFFIX);
		nPartyCargo = GetGlobalInt ("PARTY_CARGO" + TEMP_SUFFIX);
	}
	else
	{
		nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel);
		nPartyCargo = GetGlobalInt ("PARTY_CARGO");
	}
	
	if( sLabel == "")						// If the good we're dealing with isn't in the 2DA, abort.
	{
		PrettyDebug("Error - Attempting to give Invalid Good/Resource.");
		return FALSE;
	}
	
	else if ( nPartyStockOfGood < nAmount)	// If the party doesn't have any of the good, you can't take it.
	{
		PrettyDebug("Party does not have any of this resource.  Transaction Failed.");
		return FALSE;
	}

	else if ( bCheck ) 					// If we're just checking, don't do it, just return true.
		return TRUE;
	
	else if ( bTemp )									//You've got the good - but we're only altering the TEMP value
	{
		nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel + TEMP_SUFFIX);
		nPartyCargo = GetGlobalInt ("PARTY_CARGO" + TEMP_SUFFIX);
		PrettyDebug("Temp Taking:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood -= nAmount;		//Subtract the good/resource from the player's stock.
		nPartyCargo -= nAmount;				//Subtract the space from the player's cargo.
		SetGlobalInt(PARTY_PREFIX + sLabel + TEMP_SUFFIX, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX, nPartyCargo);
		return TRUE;
	}
	
	else									//You've got the good so we're taking it.
	{
		PrettyDebug("Taking:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood -= nAmount;		//Subtract the good/resource from the player's stock.
		nPartyCargo -= nAmount;				//Subtract the space from the player's cargo.
	
		string sFeedback = GetStringByStrRef(STRREF_LOST_CARGO_FEEDBACK);
		string sAmount = " " + IntToString(nAmount) + " ";
		string sName;
		if (bGood)
			sName = GetTradeGoodName(nIndex);
			
		else
			sName = GetRareResourceName(nIndex);
		
		sFeedback += sAmount;
		sFeedback += sName;
		
		object oPC = GetFirstPC();
		object oFM = GetFirstFactionMember(oPC);
		while(GetIsObjectValid(oFM))
		{
			SendMessageToPC(oFM, sFeedback);
			oFM = GetNextFactionMember(oPC);
		}
		SetGlobalInt("PARTY_" + sLabel, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO", nPartyCargo);
		return TRUE;
	}
	return FALSE;
}

int BuyCargo(int iIndex, int nAmount, int iPrice, int bGood = TRUE, int bCheck= FALSE, int bTemp = FALSE)
{
	PrettyDebug("Buying Cargo...");
	string sLookup = GOODS_2DA;					// By default, reference the Trade Good 2da.
	if( !bGood )								// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;						// Use the Rare Resources 2da.
	
	int iTotalPrice = nAmount * iPrice;
	int iPartyBars = GetGlobalInt("PARTY_BARS");
	
	if (bTemp)
		iPartyBars = GetGlobalInt("PARTY_BARS" + TEMP_SUFFIX);
		
	string sLabel = Get2DAString(sLookup, "LABEL", iIndex);

	if ( iTotalPrice > iPartyBars )								// If the party doesn't have enough bars, abort.
	{
		PrettyDebug("Party does not have enough Trade Bars.  Transaction Failed.");
		return FALSE;
	}
	
	if ( GiveCargo(iIndex, nAmount, bGood, TRUE, bTemp) == FALSE)	// Or, If you can't receive the cargo, abort.
	{
		PrettyDebug("GiveCargo returned False. Aborting BuyCargo");
		return FALSE;
	}
	
	else if ( bCheck )											// If we're just checking, don't perform the transaction...
		return TRUE;											// Instead, just return TRUE.
	
	else										// You can recieve the cargo and you have the bars, so complete the transaction.
	{
		PrettyDebug("Buying:" + IntToString(nAmount) + " " + sLabel + " for " + IntToString(iTotalPrice) + " bars.");
		GiveCargo(iIndex, nAmount, bGood, FALSE, bTemp); 		// Add the good to the player's cargo.
		TakeBars(iTotalPrice, FALSE, bTemp);					// Subtract the price in bars from the player's stock.
						
		return TRUE;
	}
	
	return FALSE;
}
		
int SellCargo(int iIndex, int nAmount, int iPrice, int bGood = TRUE, int bCheck= FALSE, int bTemp = FALSE)
{
	string sLookup = GOODS_2DA;			// By default, reference the Trade Good 2da.
	if( !bGood )						// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;				// Use the Rare Resources 2da.
	
	int iTotalPrice = nAmount * iPrice;
	string sLabel = Get2DAString(sLookup, "LABEL", iIndex);
	
	if (TakeCargo(iIndex, nAmount, bGood, TRUE, bTemp) == FALSE)	//If the party can't deliver the cargo, abort.
		return FALSE;
	
	else if ( bCheck ) 										//Or if we're just checking, don't perform the transaction...
		return TRUE;										//Just return TRUE.
	
	else													//You've got the goods so sell them.
	{
		PrettyDebug("Selling:" + IntToString(nAmount) + " " + sLabel + " for " + IntToString(iTotalPrice) + " bars.");
		TakeCargo(iIndex, nAmount, bGood, FALSE, bTemp);		//Remove the good from the player's cargo.
		GiveBars(iTotalPrice, bTemp);					//Add the bars to the player's stock.
				
		return TRUE;
	}
	return FALSE;
}

int BuyScarceCargo(int nIndex, int nAmount, int nPrice, int nLocation, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE)
{
	int nStock, bCanBuy;
	if (bGood)
		nStock = GetTradeGoodStock(nIndex, nLocation, bTemp);
	
	else
		nStock = GetRareResourceStock(nIndex, nLocation, bTemp);
		
	bCanBuy = BuyCargo(nIndex, nAmount, nPrice, bGood, TRUE, bTemp);		//Will the buy operation work?

	if(bCanBuy == FALSE)
	{
		PrettyDebug("bCanBuy is False.");
		return FALSE;
	}
	
	if(nStock < nAmount)
	{
		PrettyDebug("Seller is out of stock.  Cannot purchase.");
		return FALSE;
	}
	
	else if(bCheck)
		return TRUE;

	else
	{
		BuyCargo(nIndex, nAmount, nPrice, bGood, FALSE, bTemp); 	 		// Add the good to the player's cargo.
		
		nStock -= nAmount;
		if (bGood)
			SetTradeGoodStock(nIndex, nLocation, nStock, bTemp);
		else
			SetRareResourceStock(nIndex, nLocation, nStock, bTemp);// Subtract the price in bars from the player's stock.
		
		return TRUE;
						
	}
	
	return FALSE;
}

int SellScarceCargo(int nIndex, int nAmount, int nPrice, int nLocation, int bGood = TRUE, int bCheck = FALSE, int bTemp = FALSE)
{
	int nStock, bCanSell;
	if (bGood)
		nStock = GetTradeGoodStock(nIndex, nLocation, bTemp);
	
	else
		nStock = GetRareResourceStock(nIndex, nLocation, bTemp);
		
	bCanSell = SellCargo(nIndex, nAmount, nPrice, bGood, TRUE, bTemp);		//Will the buy operation work?
	
	if(bCanSell == FALSE)
	{
		PrettyDebug("bCanSell is false, Returning False");
		return FALSE;
	}
	else if(bCheck)
		return TRUE;

	else
	{
		SellCargo(nIndex, nAmount, nPrice, bGood, FALSE, bTemp); 	 		// Add the good to the player's cargo.
		
		nStock += nAmount;
		if (bGood)
			SetTradeGoodStock(nIndex, nLocation, nStock, bTemp);
		else
			SetRareResourceStock(nIndex, nLocation, nStock, bTemp);// Subtract the price in bars from the player's stock.
		
		return TRUE;				
	}
	
	return FALSE;
}

int StoreCargo(int nIndex, int nAmount, int bGood = TRUE)
{
	string sLookup = GOODS_2DA;			// By default, reference the Trade Good 2da.
	if( !bGood )						// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;				// Use the Rare Resources 2da.

	string sLabel = Get2DAString(sLookup, "LABEL", nIndex);
	int nPartyStockOfGood, nPartyCargo, nStorageStock;
	
	nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel);
	nStorageStock = GetGlobalInt(STORAGE_PREFIX + sLabel);
	nPartyCargo = GetGlobalInt ("PARTY_CARGO");
		
	if( sLabel == "")						// If the good we're dealing with isn't in the 2DA, abort.
	{
		PrettyDebug("Error - Attempting to store Invalid Good/Resource.");
		return FALSE;
	}
	
	if (nPartyStockOfGood < nAmount)
	{
		PrettyDebug("Not enough of resource in cargo.");
		return FALSE;
	}
	
	else									
	{
		PrettyDebug("Storing:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood -= nAmount;		
		nPartyCargo -= nAmount;
		nStorageStock += nAmount;				
		SetGlobalInt(PARTY_PREFIX + sLabel, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO", nPartyCargo);
		SetGlobalInt(STORAGE_PREFIX + sLabel, nStorageStock);
		
		return TRUE;
	}
	return FALSE;
}

int WithdrawCargo(int nIndex, int nAmount, int bGood = TRUE)
{
	string sLookup = GOODS_2DA;			// By default, reference the Trade Good 2da.
	if( !bGood )						// But, If we're not dealing with Trade Goods,
		sLookup = RES_2DA;				// Use the Rare Resources 2da.

	string sLabel = Get2DAString(sLookup, "LABEL", nIndex);
	int nPartyStockOfGood, nPartyCargo, nStorageStock;
	
	nPartyStockOfGood = GetGlobalInt(PARTY_PREFIX + sLabel);
	nStorageStock = GetGlobalInt(STORAGE_PREFIX + sLabel);
	nPartyCargo = GetGlobalInt ("PARTY_CARGO");
		
	if( sLabel == "")						// If the good we're dealing with isn't in the 2DA, abort.
	{
		PrettyDebug("Error - Attempting to store Invalid Good/Resource.");
		return FALSE;
	}
	
	if (nStorageStock < nAmount)
	{
		PrettyDebug("Storage does not have enough of the given resource");
		return FALSE;
	}
	
	else if (nAmount > GetPartyCargoFreeSpace())
	{
		PrettyDebug("Party doesn't have enough space");
		return FALSE;
	}
	
	else									
	{
		PrettyDebug("Withdrawing:" + IntToString(nAmount) + " " + sLabel );
		nPartyStockOfGood += nAmount;		
		nPartyCargo += nAmount;
		nStorageStock -= nAmount;				
		SetGlobalInt(PARTY_PREFIX + sLabel, nPartyStockOfGood);
		SetGlobalInt("PARTY_CARGO", nPartyCargo);
		SetGlobalInt(STORAGE_PREFIX + sLabel, nStorageStock);
		
		return TRUE;
	}
	return FALSE;
}
/*--------------------------\
|	Trade Bar Functions		|
\--------------------------*/
int GiveBars(int nBarsToGive, int bTemp = FALSE)
{
	if (bTemp)
	{
		int nPartyBars = GetGlobalInt("PARTY_BARS" + TEMP_SUFFIX);
		nPartyBars += nBarsToGive;
		SetGlobalInt("PARTY_BARS" + TEMP_SUFFIX, nPartyBars);
		return nPartyBars;
	}
	
	else
	{
		int nPartyBars = GetGlobalInt("PARTY_BARS");
		nPartyBars += nBarsToGive;
		SetGlobalInt("PARTY_BARS", nPartyBars);
		
		string sFeedback = GetStringByStrRef(STRREF_GAINED_CARGO_FEEDBACK);
		string sAmount = " " + IntToString(nBarsToGive) + " ";
		string sBars = GetStringByStrRef(STRREF_TRADE_BARS);
		
		sFeedback += sAmount;
		sFeedback += sBars;
				
		object oPC = GetFirstPC();
		object oFM = GetFirstFactionMember(oPC);
		while(GetIsObjectValid(oFM))
		{
			SendMessageToPC(oFM, sFeedback);
			oFM = GetNextFactionMember(oPC);
		}
		
		return nPartyBars;
	}
	
	
}

int TakeBars(int nBarsToTake, int bCheck = FALSE, int bTemp = FALSE)
{

	
	if(bTemp)
	{
		int nPartyBars = GetGlobalInt("PARTY_BARS" + TEMP_SUFFIX);
		
		if (nPartyBars < nBarsToTake)
			return FALSE;
		
		else if (bCheck)
			return TRUE;
			
		else
		{
			nPartyBars -= nBarsToTake;
			SetGlobalInt("PARTY_BARS" + TEMP_SUFFIX, nPartyBars);
			return nPartyBars;
		}
		
	}
	
	else
	{
		int nPartyBars = GetGlobalInt("PARTY_BARS");

		if (nPartyBars < nBarsToTake)
			return FALSE;
		
		if (bCheck)
			return TRUE;
	
		else
		{
			nPartyBars -= nBarsToTake;
			SetGlobalInt("PARTY_BARS", nPartyBars);
			return nPartyBars;
		}
	}
}

int GiveCompanyBars(int nBarsToGive)
{
	int nCompanyBars = GetGlobalInt("COMPANY_BARS");
	nCompanyBars += nBarsToGive;
	SetGlobalInt("COMPANY_BARS", nCompanyBars);
	return nCompanyBars;
}

int TurnInBars(int nBarsToTurnIn, int bDonate)
{
	int nPartyBars = GetPartyBars();
	int nCompanyBars = GetCompanyBars();
	
	if (nPartyBars < nBarsToTurnIn)
		return FALSE;
	
	else
	{
		TakeBars(nBarsToTurnIn);
		if(!bDonate)
			GiveGoldToCreature( GetFactionLeader(GetFirstPC()), nBarsToTurnIn * TRADE_BAR_EXCHANGE_RATE);
		
		else if(GetGlobalInt("00_nStoryStep") >= 2)
		{
			GiveCompanyBars(nBarsToTurnIn);
			while(CompanyReadyToLevel())
			{
				LevelUpCompany();
			}
		}
		return nPartyBars;
	}
}

int GetPartyBars()
{
	int nResult = GetGlobalInt("PARTY_BARS");
	return nResult;
}

/*----------------------\
|	Wagon Functions		|
\----------------------*/
int SetWagon(int iNewWagon)
{
	int iCurrent = GetGlobalInt("PARTY_WAGON");
	
	if (iCurrent > iNewWagon) //Players cannot downgrade their wagon.
	{
		return FALSE;
	}
	
	else
	{
		if( Get2DAString(WAGON_2DA, "LABEL", iNewWagon) != "" )	//If the choice is a valid entry in the nx2_wagons.2da...
		{
			SetGlobalInt("PARTY_WAGON", iNewWagon);					//set the player's wagon to the new value.	
			return iNewWagon;
		}
		else														//Otherwise, don't do it.
			return FALSE;
	}
}
int GetWagonMaxCargo(int iWagon)
{
	if( Get2DAString(WAGON_2DA, "LABEL", iWagon) == "" )	//validating input
		return FALSE;		
	
	int iResult = Get2DAInt(WAGON_2DA, "CARGO_CAPACITY", iWagon);	//Pulls the wagon cargo data from the 2da
	return iResult;
}



string GetWagonName(int iWagon) //NOTE:  This will need to be converted to use STRREFs at some point!
{
	if( Get2DAString(WAGON_2DA, "LABEL", iWagon) == "" )	//validating input
		return "Error";
	
	string sResult = Get2DAString(WAGON_2DA, "NAME", iWagon);
	return sResult;
}

int GetIsPartyCargoFull(int bTemp = FALSE)
{
	int iPartyWagon = GetGlobalInt("PARTY_WAGON");
	int iMaxCargo = GetWagonMaxCargo(iPartyWagon);
	int iPartyCargo;
	if(bTemp)
		iPartyCargo = GetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX);
	
	else
		iPartyCargo = GetGlobalInt("PARTY_CARGO");
		
	if (iPartyCargo >= iMaxCargo)			//If the player has no more space, return TRUE (The cargo IS full)
		return TRUE;
	
	else
		return FALSE;
}

int GetPartyCargoFreeSpace(int bTemp = FALSE)
{
	int iPartyWagon = GetGlobalInt("PARTY_WAGON");
	int iMaxCargo = GetWagonMaxCargo(iPartyWagon);
	int iPartyCargo;
	
	if(bTemp)
		iPartyCargo = GetGlobalInt("PARTY_CARGO" + TEMP_SUFFIX);
	
	else
		iPartyCargo = GetGlobalInt("PARTY_CARGO");
	
	int iResult = iMaxCargo - iPartyCargo;
	return iResult;
}

/*--------------------------\
|	Storage		Functions	|
\--------------------------*/
int GetStorageStock(int nIndex, int bGood=TRUE)
{
	string sLabel;
	if(bGood)
		sLabel = GetTradeGoodLabel(nIndex);
	else
		sLabel = GetRareResourceLabel(nIndex);
		
	int nResult = GetGlobalInt(STORAGE_PREFIX + sLabel);
	
	return nResult;
}

/*--------------------------\
|	Commodity	Functions	|
\--------------------------*/
string GetTradeGoodLabel(int nGood)
{
	string sLabel = Get2DAString(GOODS_2DA, "LABEL", nGood);
	return sLabel;
}
string GetRareResourceLabel(int nResource)
{
	string sLabel = Get2DAString(RES_2DA, "LABEL", nResource);
	return sLabel;
}

string GetTradeGoodName(int nGood)
{
	string sName = GetStringByStrRef(Get2DAInt(GOODS_2DA, "STRREF", nGood));
	return sName;
}

string GetRareResourceName(int nResource)
{
	string sName = GetStringByStrRef(Get2DAInt(RES_2DA, "STRREF", nResource));
	return sName;
}

int GetPartyStock(int nIndex, int bGood = TRUE, int bTemp = FALSE)
{
	string sResult;
	if(bGood)
		sResult = PARTY_PREFIX + GetTradeGoodLabel(nIndex);
	else
		sResult = PARTY_PREFIX + GetRareResourceLabel(nIndex);
	
	if(bTemp)
		sResult += TEMP_SUFFIX;
	
	int nResult = GetGlobalInt(sResult);	
	return nResult;
}

void SetPartyStock(int nIndex, int nAmount, int bGood = TRUE, int bTemp = FALSE)
{
	string sCargo;
	if(bGood)
		sCargo = PARTY_PREFIX + GetTradeGoodLabel(nIndex);
	else
		sCargo = PARTY_PREFIX + GetRareResourceLabel(nIndex);
	
	if(bTemp)
		sCargo += TEMP_SUFFIX;
	
	SetGlobalInt(sCargo, nAmount);
}

int GetTradeGoodPrice(int iGood, int iLocation)
{
	string sPriceColumn = "";
	//PrettyDebug(IntToString(iGood));
	switch(iGood)											// We need to determine which column to access in the economy 2DA
	{														// based on the good passed into the function.
		case GOOD_ORE: sPriceColumn = "PRICE_ORE"; break;
		case GOOD_TIMBER: sPriceColumn = "PRICE_TIMBER"; break;
		case GOOD_SKINS: sPriceColumn = "PRICE_SKINS"; break;
/*		case GOOD_INGOTS: sPriceColumn = "PRICE_INGOTS"; break;
		case GOOD_LUMBER: sPriceColumn = "PRICE_LUMBER"; break;
		case GOOD_LEATHER: sPriceColumn = "PRICE_LEATHER"; break; */
	}
	
	string sPriceLevel = Get2DAString(ECON_2DA, sPriceColumn, iLocation);	//First we get the Price Level, then we cross-reference 
	PrettyDebug (sPriceColumn + ":" + sPriceLevel);						//with the column in GOODS_2DA with the same name to get
	int iResult = Get2DAInt(GOODS_2DA, sPriceLevel, iGood);					//the actual price value.
	
	return iResult;
}

int GetTradeGoodPriceLevel(int iGood, int iLocation)
{
	string sPriceColumn = "";
	//PrettyDebug(IntToString(iGood));
	switch(iGood)											// We need to determine which column to access in the economy 2DA
	{														// based on the good passed into the function.
		case GOOD_ORE: sPriceColumn = "PRICE_ORE"; break;
		case GOOD_TIMBER: sPriceColumn = "PRICE_TIMBER"; break;
		case GOOD_SKINS: sPriceColumn = "PRICE_SKINS"; break;
/*		case GOOD_INGOTS: sPriceColumn = "PRICE_INGOTS"; break;
		case GOOD_LUMBER: sPriceColumn = "PRICE_LUMBER"; break;
		case GOOD_LEATHER: sPriceColumn = "PRICE_LEATHER"; break; */
	}
	
	string sPriceLevel = Get2DAString(ECON_2DA, sPriceColumn, iLocation);	//First we get the Price Level, then we cross-reference 
	if(sPriceLevel == "PRICE_LOW")
		return 1;
	
	else if(sPriceLevel == "PRICE_MED")
		return 2;
			
	else if(sPriceLevel == "PRICE_HIGH")
		return 3;
	
	else return FALSE;
}

void ClearTradeGoodEventsAtLocation(int nGood, int nLocation)
{
	string sGoodLabel = Get2DAString(GOODS_2DA, "LABEL", nGood);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
	
	SetGlobalInt(sLocationLabel + "_" + sGoodLabel + "_SURPLUS", FALSE);
	SetGlobalInt(sLocationLabel + "_" + sGoodLabel + "_SHORTAGE", FALSE);
}

void ClearRareResourceEventsAtLocation(int nResource, int nLocation)
{
	string sResourceLabel = Get2DAString(RES_2DA, "LABEL", nResource);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
			
	SetGlobalInt(sLocationLabel + "_" + sResourceLabel + "_SURPLUS", FALSE);
	SetGlobalInt(sLocationLabel + "_" + sResourceLabel + "_SHORTAGE", FALSE);
}

string GetTradeGoodPriceString(int nGood, int nLocation)
{
	int nPrice = GetTradeGoodPrice(nGood, nLocation);
	string sResult = IntToString(nPrice);
	
	return sResult;
}
	
int GetRareResourcePrice(int nResource, int nLocation)
{
	string sPriceLevel = Get2DAString(ECON_2DA, "SIZE", nLocation);			//First we get the city size, then we cross-reference 
																			//with the column in RES_2DA with the same name to get
	int nResult = Get2DAInt(RES_2DA, sPriceLevel, nResource);				//the actual price value.
	
	return nResult;
}

string GetRareResourcePriceString(int nGood, int nLocation)
{
	int nPrice = GetRareResourcePrice(nGood, nLocation);
	string sResult = IntToString(nPrice);
	
	return sResult;
}

int GetTradeGoodStock(int nGood, int nLocation, int bTemp = FALSE)
{
	string sGoodLabel = Get2DAString(GOODS_2DA, "LABEL", nGood);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
	
	if (bTemp)
		sLocationLabel = sLocationLabel + TEMP_SUFFIX;
	int nResult = GetGlobalInt(sLocationLabel + "_" + sGoodLabel);
	return nResult;
}

int GetRareResourceStock(int nResource, int nLocation, int bTemp = FALSE)
{
	string sResourceLabel = Get2DAString(RES_2DA, "LABEL", nResource);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
	if (bTemp)
		sLocationLabel = sLocationLabel + TEMP_SUFFIX;
			
	int nResult = GetGlobalInt(sLocationLabel + "_" + sResourceLabel);
	return nResult;
}

int SetTradeGoodStock(int nGood, int nLocation, int nAmount, int bTemp = FALSE)
{
	string sGoodLabel = Get2DAString(GOODS_2DA, "LABEL", nGood);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
	if (bTemp)
		sLocationLabel = sLocationLabel + TEMP_SUFFIX;
	
	PrettyDebug("Setting " + sLocationLabel + "_" + sGoodLabel + " to " + IntToString(nAmount));
			
	SetGlobalInt(sLocationLabel + "_" + sGoodLabel, nAmount);
	return nAmount;
}

int SetRareResourceStock(int nResource, int nLocation, int nAmount, int bTemp = FALSE)
{
	string sResourceLabel = Get2DAString(RES_2DA, "LABEL", nResource);
	string sLocationLabel = Get2DAString(ECON_2DA, "LABEL", nLocation);
	if(bTemp)
		sLocationLabel = sLocationLabel + TEMP_SUFFIX;
	
	PrettyDebug("Setting " + sLocationLabel + "_" + sResourceLabel + " to " + IntToString(nAmount));
	
	SetGlobalInt(sLocationLabel + "_" + sResourceLabel, nAmount);
	return nAmount;
}
/*------------------------------\
|	Rare Resource Functions		|
\------------------------------*/
int GetResourceNodeDiscovered(int iIndex)
{
	string sNodeTag = Get2DAString(RES_NODE_2DA, "TAG", iIndex);
	string sVarName = sNodeTag + "_DISCOVERED";						//The variable name = the node tag + _DISCOVERED
	int bNodeDiscovered = GetGlobalInt(sVarName);
	
	if(bNodeDiscovered)
		return TRUE;
	
	else
		return FALSE;
}		

int SetResourceNodeDiscovered(int iIndex)
{
	string sNodeTag = Get2DAString(RES_NODE_2DA, "TAG", iIndex);
	string sVarName = sNodeTag + "_DISCOVERED";						//The variable name = the node tag + _DISCOVERED
	int bNodeDiscovered = GetGlobalInt(sVarName);
	
	if(bNodeDiscovered)
	{
		return FALSE;
	}
	
	else
	{
		SetGlobalInt(sVarName, 1);
		return TRUE;
	}
}

/*----------------------\
|	Company Functions	|
\----------------------*/
int GetCompanyBars()
{
	int nResult = GetGlobalInt("COMPANY_BARS");
	return nResult;
}

int GetCompanyLevel()
{
	int nResult = GetGlobalInt(VAR_COMPANY_LEVEL);
	return nResult;
}

int IncrementCompanyLevel()
{
	int nCurrentLevel = GetCompanyLevel();
	int nNewLevel = nCurrentLevel + 1;
	SetGlobalInt(VAR_COMPANY_LEVEL, nNewLevel);
	return nNewLevel;
}

int GetAvailableUpgrades()
{
	int nResult = GetGlobalInt("00_nAvailableUpgrades");
	return nResult;
}

int IncrementAvailableUpgrades()
{
	int nCurrentUpgrades = GetAvailableUpgrades();
	int nNewUpgrades = nCurrentUpgrades + 1;
	SetGlobalInt("00_nAvailableUpgrades", nNewUpgrades);
	return nNewUpgrades;
}


int SpendAvailableUpgrade()
{
	int nCurrentUpgrades = GetAvailableUpgrades();
	int nNewUpgrades = nCurrentUpgrades - 1;
	SetGlobalInt("00_nAvailableUpgrades", nNewUpgrades);
	return nNewUpgrades;
}

int LevelUpCompany()
{
	int nCurrentLevel = GetCompanyLevel();
	
	switch(nCurrentLevel)
	{
		case 0:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_1:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_2:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();

		case COMPANY_LEVEL_3:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_4:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_5:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_6:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case COMPANY_LEVEL_7:
			IncrementAvailableUpgrades();
			IncrementCompanyLevel();
		break;
		case 8:
			PrettyDebug("Already at Max Level");
		default:
			PrettyDebug("Error attempting to Level Company");
		break;
	}
	return TRUE;
}

int GetBarsRequiredForLevel(int nLevel)
{
	int nResult = StringToInt(Get2DAString(COMPANY_LEVEL_2DA, "BARS_REQUIRED", nLevel));
	return nResult;
}

int GetBarsToNextLevel()
{
	int nCurrentLevel = GetCompanyLevel();
	int nNextLevel = nCurrentLevel + 1;
	
	int nNextLevelBars = GetBarsRequiredForLevel(nNextLevel);
	int nCompanyBars = GetCompanyBars();
	
	int nResult = nNextLevelBars - nCompanyBars;
	return nResult;
}

int CompanyReadyToLevel()
{ 
	int nCurrentLevel = GetCompanyLevel();
	int nNextLevel = nCurrentLevel + 1;
	
	if (nCurrentLevel > 6)
		return FALSE;
		
	else if (GetBarsToNextLevel() <= 0)
		return TRUE;
	
	else
		return FALSE;
}

void ProcessCompanyIncome()
{
	int nReserve = GetGlobalInt(VAR_COMPANY_RESERVE);
	int nIncome;
	int nTradingPostIncome = 5*GetGlobalInt("00_nTradingPosts");
	
	nIncome += BASE_INCOME;				//The company always receives the base income each month.
		
	nReserve += nTradingPostIncome;
	
	//	20% increase for Shrine of Waukeen at Crossroad Keep.
	if (GetGlobalInt("00_bShrineUpgraded")==TRUE)
		nIncome += (nTradingPostIncome/5);
	
	//	10% increase for Greycloak patrol weapon upgrades.
	if (GetGlobalInt("00_bWeaponsUpgraded")==TRUE)
		nIncome += (nTradingPostIncome/10);
		
	//	Another 10% increase for Greycloak patrol armor upgrades.
	if (GetGlobalInt("00_bArmorUpgraded")==TRUE)
		nIncome += (nTradingPostIncome/10);
		
	//	Another 10% increase for a modified portal.
	if (GetGlobalInt("00_bPortalUpgraded")==TRUE)
		nIncome += (nTradingPostIncome/10);
		
	//	20% increase for propaganda campaign.
	if (GetGlobalInt("00_bPropagandaUpgraded")==TRUE)
		nIncome += (nTradingPostIncome/5);
	
	nReserve += nIncome;	
		
	PrettyDebug("Income: " + IntToString(nIncome) + " Company Reserve:" + IntToString(nReserve));
	SetCompanyReserve(nReserve);
}

void AwardCompanyIncome()
{
	int nReserve = GetGlobalInt(VAR_COMPANY_RESERVE);
	PrettyDebug("Awarding " + IntToString(nReserve) + " bars of income.");
	GiveBars(nReserve);
	SetCompanyReserve(0);
}

int GetCompanyReserve()
{
	int nResult = GetGlobalInt(VAR_COMPANY_RESERVE);
	return nResult;
}

void AddToIncome(int nIncome)
{
	int nReserve = GetGlobalInt(VAR_COMPANY_RESERVE);
	nReserve += nIncome;
	SetGlobalInt(VAR_COMPANY_RESERVE, nReserve);
}

void SetCompanyReserve(int nNewReserve)
{
	SetGlobalInt(VAR_COMPANY_RESERVE, nNewReserve);
}