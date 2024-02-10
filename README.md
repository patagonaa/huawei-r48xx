# Huawei R48xx
Documentation about Huawei 48V power supplies

## Existing information/documentation

- Review with lots of information (pinout, CAN, voltage range, etc.): https://www.beyondlogic.org/review-huawei-r4850g2-power-supply-53-5vdc-3kw/
- List of other related power supplies: https://www.ycict.net/de/products/huawei-r48100g1-rectifier-module/
- PHZ-F020304-BWxxx connector datasheets: https://www.medlonchina.com/FCI-connector-DC-120A-AC-40A.html

## Connectors
There seem to be a handful of connectors that are compatible with these power supplies.
I have not yet done an exact comparison between the different connectors / PSU card edges, but likely some of these connectors and card edges are cross-compatible with each other as they look at least similar.

### Jonhon [DP4SC0504-001](./connectors/Jonhon_DP4SC0504-001_Datasheet_for_Huawei_R4850.pdf), DP4SC0504-003
Fits at least R4850G2

### [PHZ-F020304-BW00x](./connectors/PHZ-F020304-BW001/PHZ-F020304-BW00X系列连接器（85A\).docx)
My R4830S1 came with one, so it does definitely fit that.
I've also created a basic OpenSCAD model for possibly integrating it into projects.
