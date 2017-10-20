// 'ga_door_open_gawatha'
//
// kevL 2017 oct 19
// Opens Gawatha's north door so his party can exit if Kepob is ransomed.
// module: D_X1
// area: d03_coveya_kurgannis
//
// sTag - The tag of the nearest door to open.

void main(string sTag)
{
    object oDoor = GetNearestObjectByTag(sTag);

    SetLocked(oDoor, FALSE);
    DelayCommand(0.1f, AssignCommand(oDoor, ActionOpenDoor(oDoor)));
}
