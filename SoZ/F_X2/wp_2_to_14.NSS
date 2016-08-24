// wp_0_to_1
/* 
Caravan Routing script
*/
// NLC 7/22/08
// kevL's 2016 aug 23
//	- set endpoint.

#include "ginc_wp"
#include "kinc_trade"

void main()
{
	SetLocalInt(OBJECT_SELF, "nEndpoint", 14); // kL
	int iCurrentWP = GetCurrentWaypoint();// the waypoint we just arrived at
    //FaceAndPause (iCurrentWP, 1.0); // causes NPC to face direction of WP and wait 1 second
    int iNextWP;
	int bReturn = GetLocalInt(OBJECT_SELF, "bReturn");
	
    switch (iCurrentWP)
    {
        case 1:
			ProcessCaravanOrigin();
            break;
			
        case 2:
			if(bReturn)
				JumpToNextWP(1);
			else
				SetNextWaypoint(3);
            
			break;
        
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
		case 11:
		case 12:
		case 13:
			if(bReturn)
				SetNextWaypoint(iCurrentWP - 1);
			else
				SetNextWaypoint(iCurrentWP + 1);
				
			break;
		
		case 14:
			if(bReturn)
				SetNextWaypoint(iCurrentWP -1);
			else
			{
				JumpToNextWP(1);
			}
			break;
    }
}