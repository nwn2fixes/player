// ga_take_item
/*
    This takes an item from a player
        sItemTag    = This is the string name of the item's tag
        nQuantity   = The number of items (default is 1). -1 is all of the Player's items of that tag.
        bAllPartyMembers     = If set to 1 it gives the item to all PCs in party (MP only)
*/
// FAB 9/30
// MDiekmann 4/9/07 -- using GetFirst and NextFactionMember() instead of GetFirst and NextPC(), changed nAllPCs to bAllPartyMembers


#include "nw_i0_plot"

void main(string sItemTag, int nQuantity, int bAllPartyMembers)
{

    int nTotalItem;
    object oPC = (GetPCSpeaker()==OBJECT_INVALID?OBJECT_SELF:GetPCSpeaker());
	object oTarg;
    object oItem;       // Items in inventory

    if ( nQuantity == 0 ) nQuantity = 1;

    if ( bAllPartyMembers == 0 )
    {
        if ( nQuantity < 0 )    // Destroy all instances of the item
        {
            nTotalItem = GetNumItems( oPC,sItemTag );
            TakeNumItems( oPC,sItemTag,nTotalItem );
        }
        else
        {
            TakeNumItems( oPC,sItemTag,nQuantity );
        }
    }
    else    // For multiple players
    {
        oTarg = GetFirstFactionMember(oPC);
        while ( GetIsObjectValid(oTarg) )
        {
            if ( nQuantity < 0 )    // Destroy all instances of the item
            {
                nTotalItem = GetNumItems( oTarg,sItemTag );
                TakeNumItems( oTarg,sItemTag,nTotalItem );
            }
            else
            {
                TakeNumItems( oTarg,sItemTag,nQuantity );
            }
            oTarg = GetNextFactionMember(oPC);
        }
    }

}