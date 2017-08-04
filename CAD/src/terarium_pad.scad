x_size = 23;           // horizontal outer size of the aquarium pedestal. 
y_size = 20;           // 
thickness = 10;         // thickness of the pad bellow aquarium. hairs lenght is 12mm. 
rim_height = 7;        // height of upper rim for fixing the aquarium in position.

mount_hole = 3.7;
clear = 0.175;
axis_offset = -1.5;

// aquarium pad

module bottom () {
    difference () {
        intersection() {
            union(){    // bottom part with rim/fixing pin
                    rotate([0,0,45])
                        translate ([ axis_offset, 0, 0])    
                            cube([x_size, y_size ,thickness], center = true);
                    translate ([sqrt(pow(x_size,2) + pow(x_size,2))/4, sqrt(pow(x_size,2) + pow(x_size,2))/4, thickness/2 + rim_height/2])
                        cube([sqrt(pow(x_size,2) + pow(x_size,2))/2, sqrt(pow(x_size,2) + pow(x_size,2))/2, rim_height], center = true);

                };

            rotate([0,0,45])
                translate ([ axis_offset, 0, 0])
                    cube([x_size, y_size ,4*thickness], center = true); // cut out half of top tip 
        }
        cylinder (h = thickness + rim_height, r= mount_hole, $fn=20);   // hole for screw head    
        translate ([0, 0, -thickness])      // hole for the screw 
            cylinder (h = thickness + rim_height, r= mount_hole/2, $fn=20);
        
        
        rotate([0,0,-45])       // hole for top part mounting nut
            translate ([ 0, -y_size/3, thickness/3])    
                cube([6, 3, thickness], center = true);

        rotate([90,0,-45])      // hole for top part mounting screw.
            translate ([ 0, 1.8, 0])    
                cylinder (h = thickness + rim_height, r= mount_hole/2, $fn=20);

        rotate([0,-45,-45])       // hole for top part mounting nut
            translate ([ 0, 0, -11])    
                cube([30, 30, 1], center = true);

        rotate([0,45,-45])       // hole for top part mounting nut
            translate ([ 0, 0, -11])    
                cube([30, 30, 1], center = true);

        rotate([0,45,45])       // hole for top part mounting nut
            translate ([ 0, 0, -13])    
                cube([30, 30, 1], center = true);

        rotate([0,-45,45])       // hole for top part mounting nut
            translate ([ 0, 0, -11])    
                cube([30, 30, 1], center = true);
    }
}


//Top part
module top () {
    union () {

    wall_thickness = 3;

    rotate([0,0,45])
    translate ([-wall_thickness, 0, 0]) 

        difference () {
            translate ([wall_thickness/2, 0, thickness/2 + 1.5*wall_thickness])    
                    cube([x_size - wall_thickness, y_size , wall_thickness ], center = true);

            rotate([0,0,-45])
                translate ([sqrt(pow(x_size,2) + pow(x_size,2))/4, sqrt(pow(x_size,2) + pow(x_size,2))/4 ,  rim_height])
                    cube([sqrt(pow(x_size,2) + pow(x_size,2))/2, sqrt(pow(x_size,2) + pow(x_size,2))/2, 2*rim_height], center = true);
        };    

    rotate([0,0,45])
    translate ([-8.3, 0, 0]) 

        difference () {
            translate ([8.3/2, 0, thickness/2 + wall_thickness/2])    
                    cube([x_size - 8.3, y_size , wall_thickness ], center = true);

            rotate([0,0,-45])
                translate ([sqrt(pow(x_size,2) + pow(x_size,2))/4, sqrt(pow(x_size,2) + pow(x_size,2))/4 ,  rim_height])
                    cube([sqrt(pow(x_size,2) + pow(x_size,2))/2, sqrt(pow(x_size,2) + pow(x_size,2))/2, rim_height], center = true);
        };      

        
    rotate([0,0,-45])

        difference  () {

            translate ([0, -y_size/2 - wall_thickness/2 , 1.25 * wall_thickness])    
                cube([y_size, wall_thickness , thickness + 1.5*wall_thickness ], center = true);
            
            
                rotate([90,0,0])
                    translate ([-0.5/2, 0, rim_height/3])    
                        minkowski() {
                            cube([0.5,3.1,10]);
                            cylinder(r=1.5,h=1,$fn=50);
                        }
                }


        
    }
}

//translate ([0, 0, thickness])    // separate two parts

//bottom ();

rotate([180,0,0])       // hole for top part mounting nut
top ();