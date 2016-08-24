// wp_3_to_7
/*
	Caravan Routing script
*/
// NLC 7/22/08
// kevL's, 2016 aug 23
//	- create file.

#include "ginc_wp"
#include "kinc_trade"

void main()
{
	SetLocalInt(OBJECT_SELF, "nEndpoint", 5);

	int iCurrentWP = GetCurrentWaypoint(); // the waypoint we just arrived at
	switch (iCurrentWP)
	{
		case 1:
			ProcessCaravanOrigin();
			break;
		case 2:
			if (GetLocalInt(OBJECT_SELF, "bReturn"))
				JumpToNextWP(1);
			else
				SetNextWaypoint(3);
			break;
		case 3:
		case 4:
			if (GetLocalInt(OBJECT_SELF, "bReturn"))
				SetNextWaypoint(iCurrentWP - 1);
			else
				SetNextWaypoint(iCurrentWP + 1);
			break;
		case 5:
			if (GetLocalInt(OBJECT_SELF, "bReturn"))
				SetNextWaypoint(iCurrentWP - 1);
			else
				JumpToNextWP(1);
			break;
	}
}
