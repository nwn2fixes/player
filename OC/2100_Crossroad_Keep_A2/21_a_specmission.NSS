// 21_a_specmission

// Modified by Brendan Bellina, Dec 2009, for the OC Makeover SoZ Edition
// - Give Nasher's Gloves as a reward rather than Nasher's Ring

/*
	Special Mission Rewards
*/
// FAB 7-29-05
// ChazM - modified to do item/gold rewards only 
	
#include "nw_i0_plot"

// Res Refs of item rewards	
const string RR_ITEM_MORRIS_NECKLACE 	= "it_21_morris_nec";
const string RR_ITEM_OGRE_WEAPON		= "nw_wblmcl004";		// Will of the Lost
//const string RR_ITEM_NASHER				= "x2_nash_ring";		// Nasher's Ring
const string RR_ITEM_NASHER				= "x2_nash_glove";		// Nasher's Gloves
const string RR_ITEM_REWARD_SPEAR		= "n2_wplmss001";		// The Captain's Spear
const string RR_ITEM_REWARD_HELM		= "nw_armhe006";		// Watchman's Helm
const string RR_ITEM_REWARD_EVIL		= "nw_it_mneck002";		// Talisman of Pure Evil
const string RR_ITEM_REWARD_GOOD		= "x0_it_mneck004";		// Luckstone
		
void main( int nMission, int nResult )
{
	object oPC = GetPCSpeaker();

	if ( nMission == 1 )		// Old Man Morris mission
	{
		switch (nResult)
		{
			case 1:		// Total Success
				CreateItemOnObject(RR_ITEM_MORRIS_NECKLACE,oPC,1 );		// Morris' Necklace
				RewardGP( 500,oPC );
				break;
		
			case 2:		// Success
				RewardGP( 500,oPC );
				break;
		
			case 3:		// Failure
				break;
			}
	}	

	if ( nMission == 2 )		// Ogre's Revenge mission
	{
		switch (nResult)
		{
			case 1:		// Total Success
				//3000g, Cool loot + magic items
				CreateItemOnObject(RR_ITEM_OGRE_WEAPON,oPC,1 );	
				RewardGP( 3000,oPC );
				break;

			case 2:		// Success
				RewardGP( 3000,oPC );
				break;
		
			case 3:		// Failure
				break;
			}
	}	

	if ( nMission == 3 ) // Tax Collector (nResult not used in the calculations for the reward)
	{
		// no reward - Nasher Gold updated during TIME UNIT update.
	}

	if ( nMission == 4 )		// Eastern Bugbears
	{
		switch (nResult)
		{
			case 1:		// Total Success
				// Gives set item from Nasher
				CreateItemOnObject(RR_ITEM_NASHER,oPC,1 );

				RewardGP( 5000,oPC );
				break;
		
			case 2:		// Success
				RewardGP( 5000,oPC );
				break;
		
			case 3:		// Failure
				break;
			}
	}

	if ( nMission == 5 )		// Scout Patrol
	{
		switch (nResult)
		{
			case 1:		//  Success
				// Gives the PC some cool item, should be the best reward
				CreateItemOnObject(RR_ITEM_REWARD_HELM,oPC,1 );
				RewardGP(2000, oPC);
				break;
		
			case 2:		// Failure
				break;
		
			case 3:		// Total Failure
				break;
			}
	}
	if ( nMission == 6 )		// Undead Rising
	{
		switch (nResult)
		{
			case 1:		//  Total Success
				// Best item from all the special missions
				CreateItemOnObject(RR_ITEM_REWARD_SPEAR,oPC,1 );
				CreateItemOnObject(RR_ITEM_REWARD_GOOD,oPC,1 );
				RewardGP(3000, oPC);
				break;
		
			case 2:		// Success
				// OK item and 3000 gold for the PC
				CreateItemOnObject(RR_ITEM_REWARD_GOOD,oPC,1 );
				RewardGP(3000, oPC);
				break;
		
			case 3:		// Failure
				break;
			}
	}
	if ( nMission == 7 )		// Shadow Reaver
	{
		switch (nResult)
		{
			case 1:		//  Success
				CreateItemOnObject(RR_ITEM_REWARD_EVIL,oPC,1 );
				RewardGP(5000, oPC);
				break;
		
			case 2:		// Failure
				break;
		
			case 3:		// Total Failure
				break;
		}
	}
}