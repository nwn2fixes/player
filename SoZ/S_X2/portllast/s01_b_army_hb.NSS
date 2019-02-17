//	s01_b_army_hb
/*
// 	If all Luskans are defeated the skeletons should walk to this waypoint. 
*/
//	Bobby Null-OEI 03/14/08

void main()

{
	object oExit = GetWaypointByTag("sp_s01_pyre");

	if  (GetGlobalInt("S_bLuskansGone") == 1)
	{
	ActionForceMoveToObject(oExit,0,1.0,30.0);
	DelayCommand(4.0, SetScriptHidden(OBJECT_SELF, TRUE));
	}
	else return;	
}




	