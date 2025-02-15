$fn = $preview ? 16 : 64;
include <psu.scad>
use <connectors/PHZ-F020304-BW001/huawei-r4850g-connector.scad>

// do not use stable version (2021.01) to render this
// use nightly builds and set backend to "Manifold"
// or this will take forever to render.

holderDepth = 35;
holderWidth = 3;

mountScrewHeadDiameter = 8.5; // nominal 8
mountScrewDiameter = 4.5; // nominal 4
mountScrewSinkDepth = (mountScrewHeadDiameter-mountScrewDiameter)*sqrt(2);

module mountHole()
{
    translate([0,0,-100 + 0.01])
        cylinder(h=100, d=mountScrewDiameter);
    translate([0,0,-0.01])
        cylinder(h=100, d=11);
    translate([0,0,-mountScrewSinkDepth])
        cylinder(h=mountScrewSinkDepth, d1=0, d2=mountScrewHeadDiameter);
    
}

mountWidth = 15;
mountHolePos = 8;
mountScrewHeight = 6;

module holderMount()
{
    translate([(frontWidth+holderWidth*2)/2, 0, -(frontHeight+holderWidth*2)/2])
    {
        difference()
        {
            rotate([90,0,0])
                linear_extrude(holderDepth)
                {
                    polygon([
                        [0,0],
                        [mountWidth,0],
                        [0,frontHeight+holderWidth*2],
                    ]);
                }
            translate([mountWidth/2,-holderDepth/2,mountScrewHeight])
                mountHole();
        }
    }
}
    
module holderFront()
{
    difference(){
        translate([0,-holderDepth/2 - 0.01,0])
            cube([frontWidth+holderWidth*2, holderDepth, frontHeight+holderWidth*2], center=true);

        psu();
        
        translate([0,-1,0])
            rotate([-90,0,0])
            minkowski()
            {
                linear_extrude(0.001)
                    square([frontWidth,frontHeight], center=true);
                cylinder(h=4, r1=0, r2=4);
            }
    }


    
    holderMount();
    mirror([1,0,0])
        holderMount();
}

connectorTolerance = 0.2;

holderBackPosition = 12;

module holderBack()
{
    difference(){
        translate([0,- frontDepth - profileLength ,0])
        {
            translate([0, holderBackPosition, 0])
            {
                holderMount();
                mirror([1,0,0])
                    holderMount();
            }
        
            difference()
            {
                translate([0,-holderDepth/2 + holderBackPosition,0])
                    cube([frontWidth+holderWidth*2, holderDepth, frontHeight+holderWidth*2], center=true);
                translate([0,-holderDepth/2,0])
                    cube([86, holderDepth+1, profileHeight], center=true);
                
                translate([0,0.5,-profileHeight/2])
                    rotate([0,0,180])
                    minkowski()
                    {
                        connector(true);
                        sphere(r=connectorTolerance);
                    }
                
                translate([0,-holderDepth/2,-profileHeight/2])
                    minkowski()
                    {
                        rotate([-90,0,0])
                            linear_extrude(30)
                            projection()
                            {
                                rotate([90,0,0])
                                    connector(true);
                            }
                        sphere(r=connectorTolerance);
                    }
            }
        }


        psu();
    }
}


if($preview)
{
    color("grey", 0.5)
        psu();
}

holderFront();
holderBack();