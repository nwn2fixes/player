NWN2 Blueprint Fixes by Brendan Bellina aka Kaldor Silverwand


The following blueprints required Icon corrections:

nw_arhe003 Winged Helmet
- changed Icon from it_he_fullplate08 to it_he_fullplate07

x2_it_arhelm03
- changed Icon from it_he_fullplate05 to it_he_fullplate06


The following blueprints required Tint corrections:

x2_it_arhelm01 Paladin Helmet
- changed Tint from [255,255,255][125,167,217][245,241,196] to [255,255,255][247,249,250][247,247,245]

x2_helm_001 Lichskull
- changed Tint from [255,255,255][214,200,182][140,98,57] to [255,255,255][8,8,7][3,2,2]


The following blueprints were broken because Soak does not work in NWN2. Changed to use Behavior Damage Reduction.

nw_mcloth005 Asyferund Elven Chain (Armor Light)
- changed Damage Resistance +1/Soak 5 to Damage Reduction 5/Magical Weapons[+1]
- changed additional cost to -43050 to compensate for base cost increase

nw_mcloth011 Adventurer's Robe (Armor Clothing)
- changed Damage Resistance +1/Soak 5 to Damage Reduction 5/Magical Weapons[+1]
- changed additional cost to -22750 to compensate for base cost increase


The following blueprints were broken because Item Property Damage Resistance only applies to energy damage types. Changed to use Behavior Damage Reduction.

nw_it_mbelt009 Swordsman's Belt (Miscellaneous Clothing)
- changed Damage Resistance Slashing [5/-] to Damage Reduction 5/(Bludgeoning or Piercing)
- changed additional cost to -17090 to compensate for base cost increase

nw_it_mbelt012 Greater Swordsman's Belt (Miscellaneous Clothing)
- changed Damage Resistance Slashing [20/-] to Damage Reduction 20/(Bludgeoning or Piercing)
- changed additional cost to -23438 to compensate for base cost increase

nw_it_mbelt010 Brawler's Belt (Miscellaneous Clothing)
- changed Damage Resistance Bludgeoning [5/-] to Damage Reduction 5/(Slashing or Piercing)
- changed additional cost to -17090 to compensate for base cost increase

nw_it_mbelt013 Greater Brawler's Belt (Miscellaneous Clothing)
- changed Damage Resistance Bludgeoning [20/-] to Damage Reduction 20/(Slashing or Piercing)
- changed additional cost to -23438 to compensate for base cost increase

nw_it_mbelt011 Archer's Belt (Miscellaneous Clothing)
- changed Damage Resistance Piercing [5/-] to Damage Reduction 5/(Slashing or Bludgeoning)
- changed additional cost to -17090 to compensate for base cost increase

nw_it_mbelt014 Greater Archer's Belt (Miscellaneous Clothing)
- changed Damage Resistance Piercing [20/-] to Damage Reduction 20/(Slashing or Bludgeoning)
- changed additional cost to -23438 to compensate for base cost increase

x2_it_mring017 Ironskin Ring
- changed Damage Resistance Piercing [5/-] and Slashing [5/-] to Damage Reduction 5/Bludgeoning
- changed additional cost to 8301 to compensate for base cost decrease

nx1_ring06 Bone Dancer's Ring
- changed Damage Resistance Piercing [10/-] and Slashing [10/-] to Damage Reduction 10/Bludgeoning
- changed additional cost to 52122 to compensate for base cost decrease

n2_itset_mnk2 Grainstone Belt
- changed Damage Resistance Piercing [5/-] and Slashing [5/-] and Bludgeoning [5/-] to Damage Reduction 5/-
- changed additional cost to 60628 to compensate for base cost decrease

n2_itset_rog1 Balhoderie's Softer Skin
- changed Damage Resistance Piercing [5/-] to Damage Reduction 5/(Slashing or Bludgeoning)
- changed additional cost to -29778 to compensate for base cost increase

nw_it_mbelt006 Belt of Inertial Barrier (did not change tag which is probably mistakenly NW_ITEM_000)
- changed Damage Resistance Bludgeoning [5/-] and Slashing [5/-] to Damage Reduction 5/Piercing
- changed additional cost to 7765 to compensate for base cost decrease

x2_it_drowcl001 Drow Piwafi Cloak
- changed Damage Resistance Piercing [10/-] and Slashing [10/-] to Damage Reduction 10/Bludgeoning
- changed additional cost to 10078 to compensate for base cost decrease

