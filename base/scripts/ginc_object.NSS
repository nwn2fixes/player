// ginc_object
/*
    object (creature and placeable) related functions
*/
// ChazM 9/29/05
// ChazM 9/30/05 added DestroyAllWithTag(), GetNumberOfObjects(), modified functions implementations and
//				added optional param bThisAreaOnly to SpawnCreaturesAtWPs, SpawnPlaceablesAtWPs and SpawnObjectsAtWPs
// BDF 10/10/05: added PlaceObjectAtTag(), PlaceCreatureAtTag(), PlacePlaceableAtTag(), and PlaceItemAtTag()
// kevL/Aqvilinus: fix loop iteration in SpawnObjectsAtWPs(), DestroyAllWithTag(), GetNumberOfObjects()

//void main (){}

//-------------------------------------------------
// Function Prototypes
//-------------------------------------------------
#include "ginc_param_const"	// Needed for GetTarget()
#include "ginc_debug"		// Needed for ErrorMessage()

object SpawnCreatureAtWP(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="");
object SpawnPlaceableAtWP(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="");
object SpawnObjectAtWP(int nObjectType, string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="");

int SpawnCreaturesAtWPs(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="", int bThisAreaOnly=TRUE);
int SpawnPlaceablesAtWPs(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="", int bThisAreaOnly=TRUE);
int SpawnObjectsAtWPs(int nObjectType, string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="", int bThisAreaOnly=TRUE);

int DestroyAllWithTag(string sTag, int bThisAreaOnly=FALSE);

int GetNumberOfObjects(string sTag, int bThisAreaOnly=FALSE);
int GetNumberOfObjectsInArea(string sTag);
object GetRandomObjectInArea(string sTag);

object PlaceObjectAtTag( int iObjectType, string sObjectTag, string sDestinationTag, string sObjectResRef );
object PlaceCreatureAtTag( string sCreatureTag, string sDestinationTag, string sCreatureResRef );
object PlacePlaceableAtTag( string sPlaceableTag, string sDestinationTag, string sPlaceableResRef );
object PlaceItemAtTag( string sItemTag, string sDestinationTag, string sItemResRef );
//-------------------------------------------------
// Function Definitions
//-------------------------------------------------

// Spawn in creature sTemplate at the location of the waypoint with tag sWPTag.
object SpawnCreatureAtWP(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="")
{
	return(SpawnObjectAtWP(OBJECT_TYPE_CREATURE, sTemplate, sWPTag, bUseAppearAnimation, sNewTag));
}

// Spawn in placeable sTemplate at the location of the waypoint with tag sWPTag.
object SpawnPlaceableAtWP(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="")
{
	return(SpawnObjectAtWP(OBJECT_TYPE_PLACEABLE, sTemplate, sWPTag, bUseAppearAnimation, sNewTag));
}

// Spawn in creature sTemplate at the location of the waypoint with tag sWPTag.
object SpawnObjectAtWP(int nObjectType, string sTemplate, string sWPTag, int bUseAppearAnimation=FALSE, string sNewTag="")
{
	object oObject = OBJECT_INVALID;

	//object oWP = GetWaypointByTag(sWPTag);
	object oWP = GetObjectByTag(sWPTag);

	if (GetIsObjectValid(oWP) == TRUE)
	{
		location lWP = GetLocation(oWP);
		oObject = CreateObject(nObjectType, sTemplate, lWP, bUseAppearAnimation, sNewTag);
		if (!GetIsObjectValid(oObject))
		{
			PrintString ("SpawnObjectAtWP: " + " Failed! " + sTemplate + "@" + sWPTag);
		}
	}
	else
	{
		PrintString ("SpawnObjectAtWP: " + " Waypoint invalid! " + sTemplate + "@" + sWPTag);
	}

	return (oObject);
}

// spawns creature at each wp with specified tag
int SpawnCreaturesAtWPs(string sTemplate, string sWPTag, int bUseAppearAnimation=FALSE, string sNewTag="", int bThisAreaOnly=TRUE)
{
	return(SpawnObjectsAtWPs(OBJECT_TYPE_CREATURE, sTemplate, sWPTag, bUseAppearAnimation, sNewTag, bThisAreaOnly));
}

// spawns placeable at each wp with specified tag
int SpawnPlaceablesAtWPs(string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="", int bThisAreaOnly=TRUE)
{
	return(SpawnObjectsAtWPs(OBJECT_TYPE_PLACEABLE, sTemplate, sWPTag, bUseAppearAnimation, sNewTag, bThisAreaOnly));
}

// spawns creature at each wp with specified tag
int SpawnObjectsAtWPs(int nObjectType, string sTemplate, string sWPTag, int bUseAppearAnimation = FALSE, string sNewTag="", int bThisAreaOnly=TRUE)
{
	int iSpawned = 0;

	int i = 0;
	object oTargetWP = GetObjectByTag(sWPTag, i);
	location lTargetWP;
	object oThisArea = GetArea(OBJECT_SELF);
	while (GetIsObjectValid(oTargetWP))
	{
		if (!bThisAreaOnly || (GetArea(oTargetWP) == oThisArea))
		{
			lTargetWP = GetLocation(oTargetWP);
			CreateObject(nObjectType, sTemplate, lTargetWP, bUseAppearAnimation, sNewTag);
			++iSpawned;
		}
		i++;
		oTargetWP = GetObjectByTag(sWPTag,i);
	}
	//PrintString ("SpawnObjectsAtWPs: Created " + IntToString(i) + " of resref " + sTemplate);
	return(iSpawned);
}

// returns number destroyed
int DestroyAllWithTag(string sTag, int bThisAreaOnly=FALSE)
{
	int iDestroyed = 0;

	int i = 0;
	object oObject = GetObjectByTag(sTag, i);
	object oThisArea = GetArea(OBJECT_SELF);

	while (GetIsObjectValid(oObject))
	{
		if (!bThisAreaOnly || (GetArea(oObject) == oThisArea))
		{
			++iDestroyed;
			DestroyObject(oObject);
		}
		oObject = GetObjectByTag(sTag, ++i);
	}
	return (iDestroyed);
}


int GetNumberOfObjects(string sTag, int bThisAreaOnly=FALSE)
{
	int iObjects = 0;

	int i = 0;
	object oObject = GetObjectByTag(sTag, i);
	object oThisArea = GetArea(OBJECT_SELF);

	while (GetIsObjectValid(oObject))
	{
		if (!bThisAreaOnly || (GetArea(oObject) == oThisArea))
			++iObjects;

		oObject = GetObjectByTag(sTag, ++i);
	}
	return (iObjects);
}

int GetNumberOfObjectsInArea(string sTag)
{
	return (GetNumberOfObjects(sTag, TRUE));
/*	int i = 1;
	object oTarget = GetNearestObjectByTag(sTag, OBJECT_SELF, i);
	while (GetIsObjectValid(oTarget))
	{
		oTarget = GetNearestObjectByTag(sTag, OBJECT_SELF, ++i);
	}
	return (--i);
*/
}


object GetRandomObjectInArea(string sTag)
{
	int iNumObjects = GetNumberOfObjectsInArea(sTag);
	int iRandomIndex = Random(iNumObjects) + 1;
	return (GetNearestObjectByTag(sTag, OBJECT_SELF, iRandomIndex));
}

object PlaceObjectAtTag( int iObjectType, string sObjectTag, string sDestinationTag, string sObjectResRef )
{
	object oObject = GetTarget( sObjectTag );
	object oDest = GetTarget( sDestinationTag );
	location lDest;

	if ( !GetIsObjectValid(oDest) )
	{
		ErrorMessage( "Passed invalid destination tag to PlaceObjectAtTag" );
		return OBJECT_INVALID;
	}
	else lDest = GetLocation( oDest );

	if ( GetIsObjectValid(oObject) )
	{
		AssignCommand( oObject, JumpToObject(oDest) );
		return oObject;
	}
	else
	{
		if ( sObjectResRef != "" )
		{
			return CreateObject( iObjectType, sObjectResRef, lDest, FALSE, sObjectTag );
		}
		else
		{
			ErrorMessage( "Passed invalid object resref to PlaceObjectAtTag" );
			return OBJECT_INVALID;
		}
	}

	return OBJECT_INVALID;
}

object PlaceCreatureAtTag( string sCreatureTag, string sDestinationTag, string sCreatureResRef )
{
	return PlaceObjectAtTag( OBJECT_TYPE_CREATURE, sCreatureTag, sDestinationTag, sCreatureResRef );
}

object PlacePlaceableAtTag( string sPlaceableTag, string sDestinationTag, string sPlaceableResRef )
{
	return PlaceObjectAtTag( OBJECT_TYPE_PLACEABLE, sPlaceableTag, sDestinationTag, sPlaceableResRef );
}

object PlaceItemAtTag( string sItemTag, string sDestinationTag, string sItemResRef )
{
	return PlaceObjectAtTag( OBJECT_TYPE_ITEM, sItemTag, sDestinationTag, sItemResRef );
}
