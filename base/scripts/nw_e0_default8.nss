// 'nw_e0_default8'
/*
	Many creatures in the stock blueprints have a nonexistent script slotted in
	their OnInventoryDisturbed events. This workaround forwards the event to the
	proper handler.
*/
// kevL 2019 feb 16

void main()
{
	ExecuteScript("nw_c2_default8", OBJECT_SELF);
}
