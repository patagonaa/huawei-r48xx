$fn = $preview ? 16 : 32;

intersectMargin=0.01;

module connector(includeScrew){
    connectorMainPartWidth = 85 + 0.35;
    connectorMainPartHeight = 9.7;
    
    connectorMaxDepth = 17.8 + 18.2;
    connectorMaxHeight = 14.97;
    connectorMaxWidth = 101 + 0.35;
    
    translate([-connectorMainPartWidth/2,0,0])
        cube([connectorMainPartWidth,connectorMaxDepth,connectorMainPartHeight]);
    
    module ear(){
        earWidth = (connectorMaxWidth - connectorMainPartWidth) / 2;
        earDepth = 10;
        earHeight = 14.97;
        earPos = 17.8-earDepth;
        
        holeDiameter = 3.5;
        holeInnerDistance = 90.6; // measured by hand
        holeCenterDistance = holeInnerDistance + holeDiameter;
        
        nubDiameter = 2.6;
        nubLength = 2.5;
        nubOuterDistance = 96.6; // measured by hand
        nubCenterDistance = nubOuterDistance - nubDiameter;
        
        earRadiusTop = 1.6; // measured by hand
        earRadiusBottom = 5; // measured by hand
        
        module earShape(){
            intersection(){
                square([earWidth, earHeight]);
                translate([earWidth-earRadiusBottom,earRadiusBottom]){
                        square(10);
                        translate([-10,-10])
                            square([10,20]);
                        circle(r=earRadiusBottom);
                }
                
                translate([earWidth-earRadiusTop,earHeight - earRadiusTop]){
                    translate([-10,-10+earRadiusTop])
                        square(10);
                    translate([-10+earRadiusTop,-20])
                        square([10,20]);
                    circle(r=earRadiusTop);
                }
            }
        }
        
        translate([connectorMainPartWidth/2 - intersectMargin,earPos,0]){            
            holePositionX = holeCenterDistance/2 - connectorMainPartWidth/2;
            holePositionY = 3.2 + holeDiameter/2; // measured by hand
            
            nubPositionX = nubCenterDistance/2 - connectorMainPartWidth/2;
            nubPositionY = 12.8 - nubDiameter/2; // measured by hand
            nubPositionZ = earDepth;
            
            difference(){
                union(){
                    translate([0,earDepth,0])
                        rotate([90,0,0])
                        linear_extrude(earDepth)
                        earShape();
                    
                    translate([nubPositionX,nubPositionZ,nubPositionY])
                        rotate([-90,0,0])
                        cylinder(nubLength, d=nubDiameter);
                    
                    if(includeScrew)
                    {
                        translate([holePositionX,0,holePositionY])
                            rotate([-90,0,0])
                            cylinder(80,d=holeDiameter,center=true);
                    }
                }
                if(!includeScrew)
                {
                    translate([holePositionX,0,holePositionY])
                        rotate([-90,0,0])
                        cylinder(40,d=holeDiameter,center=true);
                }
            }
        }
    }
    
    
    ear();
    mirror([1,0,0])
        ear();
}

connector(false);

//psuWidth = 105; // verify
//psuHeight = 40.8; // verify
//psuDepth = 281; // verify
//
//psuConnectorEarDistance = 7.8 + intersectMargin; // verify
//
//module psu(){
//    translate([-psuWidth/2,-psuDepth + psuConnectorEarDistance,0])
//        cube([psuWidth,psuDepth,psuHeight]);
//}

//if($preview && false){
////color("grey", 0.5)
//    //psu();
//color([0.4, 0.4, 0.4])
//    connector();
//}
//partDepth = 50;
//
//partHoleWidth = psuWidth - 18;
//partHoleDepth = partDepth - 2;
//partHoleHeight = psuHeight - 4;
//
//module part(){
//    difference(){
//        union(){
//            translate([-psuWidth/2,psuConnectorEarDistance,intersectMargin])
//                cube([psuWidth,partDepth,psuHeight]);
//        }
//        translate([-partHoleWidth/2, psuConnectorEarDistance - intersectMargin, (psuHeight / 2) - partHoleHeight/2])
//            cube([partHoleWidth,partHoleDepth,partHoleHeight]);
//        
//        minkowski(){
//            connector();
//            if(!$preview)
//                sphere(0.1);
//        }
//    }
//}
//
//part();