// 12_a_bty_pay
/*
    Amount of money to give the player based on number of items turned in.
*/
// JYL 10/06
// ChazM 5/24 modified

#include "nw_i0_plot"

const int BOUNTY_BANDIT_SASH = 2;
const int BOUNTY_LIZARDMAN_HIDE = 5;

const int BOUNTY_LOW_QUANTITY = 70;

int	DetermineBountyPayment(string sBountyType, int nBountyCount)
{
	int nBountyUsed = GetLocalInt(GetModule(), sBountyType);
	int nPayment;
	int nGoingRate;
	
	if (sBountyType == "BanditSash")
    {
        if (nBountyUsed < 70)
		{
		    nGoingRate = 2;
		}
		else
        {
            nGoingRate = 1;
        }
    }
	
	if (sBountyType == "LizardmanHide")
    {
	    if (nBountyUsed < 70)
        {
            nGoingRate = 5;
        }
	    else
        {
            nGoingRate = 2;
        }
    }

	nPayment = (nBountyCount * nGoingRate);
	
/*
	if (nBountyUsed < 70)
    {
        nPayment = (nBountyCount * nGoingRate);
    }
	else if ((nBountyUsed >= 70) && (nBountyUsed < 100))
    {
        nPayment = (nBountyCount * nGoingRate);
    }
	else
    {
        nPayment = 0;
    }
*/	
	nBountyUsed = nBountyUsed + nBountyCount;
	SetLocalInt(GetModule(), sBountyType, nBountyUsed);
	
	return (nPayment);
}

void main(string sBountyType)
{
	object oPC = GetPCSpeaker();
	int nBountyCount = GetNumItems(oPC, sBountyType);
	int nPayment = DetermineBountyPayment(sBountyType, nBountyCount);
	
	TakeNumItems(oPC, sBountyType, nBountyCount);
	GiveGoldToCreature(oPC, nPayment);
}