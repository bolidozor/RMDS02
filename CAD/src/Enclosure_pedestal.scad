pedestal_height = 130;  // height of pedestal
x_size = 250;           // horizontal outer size of the aquarium pedestal. 
y_size = 300;           // 
thickness = 10;         // thickness of walls
rim_height = 10;        // height of upper rim for fixing the aquarium in position.

difference () {
	cube([x_size, y_size ,pedestal_height]);
        translate ([thickness, thickness, pedestal_height - rim_height)
	        cube([x_size - 2* thickness, y_size - 2* thickness, thickness]);

	    cube([x_size - 2* thickness, y_size - 2* thickness, pedestal_height - rim_height - thickness]);
}


