// i_nwn2_it_shard4_aq
/*
	On Acquire script for shard 4. Sets a variable once we pick it up.
*/
// JYL 06/06/06
// kevL 2017 feb 7 - fix typo "16_get_shard4" -> "16_got_shard4"

void main()
{
	SetGlobalInt("16_got_shard4", 1);
}