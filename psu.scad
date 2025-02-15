frontWidth = 107;
frontHeight = 42.1;
frontDepth = 5.4;

profileWidth = 105.5;
profileHeight = 41.2;
profileLength = 264;
railWidth = 4.2;
railHeightBottom = 2.1;
railHeightTop = 2.0;

connectorTabLength = 10;
connectorTab1Pos = 14.8;
connectorTab1Width = 34.6;
connectorTab2Pos = 55.3;
connectorTab2Width = 13.7;
connectorTabHeight = 1.1;

connectorTabClearance = 1;

keyLength = 4.5;
keyPos = 11;

module psuProfileHalf()
{
    polygon([
            [0,0],
            [0,profileHeight/2],
            [profileWidth/2 - railWidth,profileHeight/2],
            [profileWidth/2 - railWidth,profileHeight/2 - railHeightTop],
            [profileWidth/2,profileHeight/2 - railHeightTop],
            [profileWidth/2,-(profileHeight/2 - railHeightBottom)],
            [profileWidth/2 - railWidth,-(profileHeight/2 - railHeightBottom)],
            [profileWidth/2 - railWidth,-(profileHeight/2)],
            [0,-(profileHeight/2)],
        ]);
}
module psu()
{
    // front panel
    rotate([90,0,0])
        linear_extrude(frontDepth)
        {
            square([frontWidth, frontHeight], center=true);
        }
    // profile
    translate([0,-frontDepth+0.01,0])
        rotate([90,0,0])
        linear_extrude(profileLength)
        {
            psuProfileHalf();
            mirror([1,0])
                psuProfileHalf();
        }
    // metal tabs below connector
    translate([0, -frontDepth - profileLength, 0])
        rotate([90,0,0])
        linear_extrude(connectorTabLength)
        {
            translate([-profileWidth/2 + connectorTab1Pos - connectorTabClearance/2,-profileHeight/2])
                square([connectorTab1Width + connectorTabClearance,connectorTabHeight]);
            translate([-profileWidth/2 + connectorTab2Pos - connectorTabClearance/2,-profileHeight/2])
                square([connectorTab2Width + connectorTabClearance,connectorTabHeight]);
        }
    // locking nub
    translate([-profileWidth/2, -frontDepth - keyLength - keyPos, -profileHeight/2])
        cube([railWidth + 0.01,keyLength,railHeightBottom + 0.01]);
}

//psu();