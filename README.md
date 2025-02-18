# Huawei R48xx
Documentation about Huawei 48V power supplies

## Existing information/documentation

- Review with lots of information (pinout, CAN, voltage range, etc.): https://www.beyondlogic.org/review-huawei-r4850g2-power-supply-53-5vdc-3kw/
- List of other related power supplies: https://www.ycict.net/de/products/huawei-r48100g1-rectifier-module/
- PHZ-F020304-BWxxx connector datasheets: https://www.medlonchina.com/FCI-connector-DC-120A-AC-40A.html

## 3D Models

### R4830S1 PSU (`psu.scad`)

Should also fit R4830G2, R4850G2 and R4850N2 as these are all 40.8x105x281mm.

Is modeled with a bit of clearance so it can be used as a negative directly and fit when 3D printed.

![OpenSCAD screenshot of the back of the PSU](./img/psu.png)

### PHZ-F020304-BW001 Connector (`connectors/PHZ-F020304-BW001/huawei-r4850g-connector.scad`)

Might also be compatible with other connector manufacturers if they have the same dimensions.

Is modeled **without clearance** so it should be expanded a bit to use as a negative.

Fits the PSU card-edge when positioned at the bottom back of the PSU extrusion/profile (`translate([0,-frontDepth - profileLength,-profileHeight/2])`).

![OpenSCAD screenshot of the back of the connector](./img/connector.png)

### Case (`psu-case.scad`)

Parts to mount a Huawei R4830S1 PSU and PHZ-F020304-BW001 connector to a plate/board.

Mounts to the board using 4mm countersink screws, the connector is mounted to the part with M3 screws.

The PSU can slide in from the front and is held in place using the original metal handle/clip on the front of the PSU.

Also on [Printables](https://www.printables.com/model/1192666-huawei-r48xx-psu-mount).

![OpenSCAD screenshot of the two mounting parts](./img/psu-case.png)
![Photo of the PSU mounted with the parts](./img/psu-case-photo.jpg)
(Photo is of an old version with less space for the screwdriver and with steeper angles which was more fragile)

## Connectors
There seem to be a handful of connectors that are compatible with these power supplies.
I have not yet done an exact comparison between the different connectors / PSU card edges, but likely some of these connectors and card edges are cross-compatible with each other as they look at least similar.

### Jonhon [DP4SC0504-001](./connectors/Jonhon_DP4SC0504-001_Datasheet_for_Huawei_R4850.pdf), DP4SC0504-003
Fits at least R4850G2

### [PHZ-F020304-BW00x](./connectors/PHZ-F020304-BW001/PHZ-F020304-BW00X系列连接器（85A\).docx)
My R4830S1 came with one, so it does definitely fit that.
