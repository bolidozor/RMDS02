hrana=50;
vzdalenost_od_rohu=37;
sila_materialu=2;

pad_sirka=21;
pad_delka=50;

difference()
{
//základní materiál
cube([hrana,hrana,sila_materialu],false);

rotate([0, 0, -45])
translate([0,vzdalenost_od_rohu+ pad_delka/2, 0])
cube([pad_sirka,pad_delka,2*sila_materialu+0.1],true);
    }