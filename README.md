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

## CAN protocol

This information was put together from several sources, such as:
- own CAN dumping/testing
- https://github.com/craigpeacock/Huawei_R4850G2_CAN
- https://endless-sphere.com/sphere/threads/rectifier-huawei-r4850g2-48v-42-58v-3000w.86038/post-1809287
- https://endless-sphere.com/sphere/threads/rectifier-huawei-r4850g2-48v-42-58v-3000w.86038/post-1805865
- https://endless-sphere.com/sphere/threads/rectifier-huawei-r4850g2-48v-42-58v-3000w.86038/post-1807301
- https://github.com/BotoX/huawei-r48xx-esp32
- https://github.com/577fkj/PowerControl/blob/c6d06935af79fcdbf3e71d1ad7ea4a86cd0c756f/main/src/protocol/huawei_r48xx.c

### General

The CAN interface uses 125kbps rate with extended 29-bit identifiers.

The CAN message IDs do not specify a single value/parameter. Instead, the message ID is used as an address, function code, message direction and possibly more.

Examples:
- `108040FE`
- `1081407F`
- `108180FE`
- `1081807E`
- `100111FE`
- `1001117E`
- `1081D27F`
- `108250FE`
- `128250FE`

Interpretation:  
Bits: `000a aaaa abbb bbbb cccc cccc deee eeef`
- 0 (bit 31-29): always zero
- a (bit 28-23): protocol ID (always `21`)
- b (bit 22-16): address (0 = broadcase, 1 = first, ... - PSU IDs somehow get auto-assigned via bus)
- c (bit 15-8): command id
- d (bit 7): message source (0 = from PSU, 1 = to PSU)
- e (bit 6-1): rev (always `3F`)
- f (bit 0): finished marker (0 = finished, 1 = more data coming)

There are several known commands and responses:

### `40` Data Request
Example (to PSU):
`108140FE: 00 00 00 00 00 00 00 00`

Requests a status response.

### `40` Data Reponse
Example (from PSU):
```
1081407F: 01 0E 00 00 00 00 2A 01
1081407F: 01 70 00 00 00 00 00 00
1081407F: 01 71 00 00 00 00 C8 00
1081407F: 01 72 00 00 00 00 00 00
1081407F: 01 73 00 00 00 00 00 00
1081407F: 01 74 00 00 00 00 00 00
1081407F: 01 75 00 00 00 00 C7 92
1081407F: 01 76 00 00 00 00 00 00
1081407F: 01 78 00 00 00 03 B5 40
1081407F: 01 7F 00 00 00 00 70 00
1081407F: 01 80 00 00 00 00 7C 00
1081407F: 01 81 00 00 00 00 00 00
1081407F: 01 82 00 00 00 00 00 00
1081407E: 01 83 00 00 00 00 00 00
```

Data bytes:
- byte 0-1: parameter id?
- bytes 2-3: ? (always 0)
- bytes 4-7: int32 value

Parameter values:
- `01 0E`: Working Hours (?)
- `01 70`: Input Power ( / 1024)
- `01 71`: Input Frequency ( / 1024)
- `01 72`: Input Current ( / 1024)
- `01 73`: Output Power ( / 1024)
- `01 74`: Efficiency ( / 1024)
- `01 75`: Output Voltage ( / 1024)
- `01 76`: Output Current Setpoint ( / 1024)
    - Possibly percent value (0-1), can be converted by multiplying by nominal PSU current (~35 for R4830, ~53 for R4850)
    - The actual output current limit as determined by AC and output current limits (gets lower when AC limit is set)
- `01 78`: Input Voltage ( / 1024)
- `01 7F`: Output Temperature ( / 1024)
- `01 80`: Input Temperature ( / 1024)
- `01 81`: Output Current (seems to be more accurate) ( / 1024)
- `01 82`: Output Current(?) ( / 1024)

### `50` Info Request
Example (to PSU): `108150FE: 00 00 00 00 00 00 00 00`

### `50` Info Response
Example (from PSU):
```
1081507F: 00 01 00 00 40 46 12 67
1081507F: 00 02 64 46 85 50 02 AF
1081507F: 00 03 32 31 30 32 33 31
1081507F: 00 04 31 54 52 52 4C 55
1081507F: 00 05 05 00 01 0D 01 0D
1081507E: 00 06 01 01 00 00 00 00
```

Data bytes:
- byte 0-1: parameter id
- bytes 2-3: ? (always 0)
- bytes 2-7: data

Parameters:
- `00 01`: Rated Current: (>> 16 / 10)?
- `00 03`, `00 04`: Barcode (ASCII)

### `D2` E-Label Request
Example (to PSU): `1081D2FE: 00 00 00 00 00 00 00 00`

### `D2` E-Label Response

Example (from PSU):
```
1081D27F: 00 01 2F 24 5B 41 72 63
1081D27F: 00 02 68 69 76 65 73 49
1081D27F: 00 03 6E 66 6F 20 56 65
1081D27F: 00 04 72 73 69 6F 6E 5D
1081D27F: 00 05 0D 0A 2F 24 41 72
1081D27F: 00 06 63 68 69 76 65 73
1081D27F: 00 07 49 6E 66 6F 56 65
1081D27F: 00 08 72 73 69 6F 6E 3D
1081D27F: 00 09 33 2E 30 0D 0A 0D
1081D27F: 00 0A 0A 0D 0A 5B 42 6F
1081D27F: 00 0B 61 72 64 20 50 72
1081D27F: 00 0C 6F 70 65 72 74 69
1081D27F: 00 0D 65 73 5D 0D 0A 42
1081D27F: 00 0E 6F 61 72 64 54 79
1081D27F: 00 0F 70 65 3D 45 4E 31
1081D27F: 00 10 4D 52 43 33 53 31
1081D27F: 00 11 41 31 0D 0A 42 61
1081D27F: 00 12 72 43 6F 64 65 3D
1081D27F: 00 13 32 31 30 32 33 31
1081D27F: 00 14 31 54 52 52 4C 55
1081D27F: 00 15 4C 34 30 30 30 36
1081D27F: 00 16 38 37 0D 0A 49 74
1081D27F: 00 17 65 6D 3D 30 32 33
1081D27F: 00 18 31 31 54 52 52 0D
1081D27F: 00 19 0A 44 65 73 63 72
1081D27F: 00 1A 69 70 74 69 6F 6E
1081D27F: 00 1B 3D 46 75 6E 63 74
1081D27F: 00 1C 69 6F 6E 20 4D 6F
1081D27F: 00 1D 64 75 6C 65 2C 52
1081D27F: 00 1E 34 38 33 30 53 31
1081D27F: 00 1F 2C 45 4E 31 4D 52
1081D27F: 00 20 43 33 53 31 41 31
1081D27F: 00 21 2C 31 55 32 30 30
1081D27F: 00 22 30 57 20 53 75 70
1081D27F: 00 23 65 72 20 48 69 67
1081D27F: 00 24 68 20 45 66 66 69
1081D27F: 00 25 63 69 65 6E 63 79
1081D27F: 00 26 20 52 65 63 74 69
1081D27F: 00 27 66 69 65 72 2C 44
1081D27F: 00 28 53 20 53 70 65 63
1081D27F: 00 29 69 61 6C 0D 0A 4D
1081D27F: 00 2A 61 6E 75 66 61 63
1081D27F: 00 2B 74 75 72 65 64 3D
1081D27F: 00 2C 32 30 32 30 2D 30
1081D27F: 00 2D 35 2D 30 36 0D 0A
1081D27F: 00 2E 56 65 6E 64 6F 72
1081D27F: 00 2F 4E 61 6D 65 3D 48
1081D27F: 00 30 75 61 77 65 69 0D
1081D27F: 00 31 0A 49 73 73 75 65
1081D27F: 00 32 4E 75 6D 62 65 72
1081D27F: 00 33 3D 30 30 0D 0A 43
1081D27F: 00 34 4C 45 49 43 6F 64
1081D27F: 00 35 65 3D 0D 0A 42 4F
1081D27E: 00 36 4D 3D 0D 0A 00 00
```

Byte 0-1: Message part number
Bytes 2-7: ASCII Data (null-terminated)

Decodes to:
```
/$[ArchivesInfo Version]
/$ArchivesInfoVersion=3.0


[Board Properties]
BoardType=EN1MRC3S1A1
BarCode=2102311TRRLUL4000687
Item=02311TRR
Description=Function Module,R4830S1,EN1MRC3S1A1,1U2000W Super High Efficiency Rectifier,DS Special
Manufactured=2020-05-06
VendorName=Huawei
IssueNumber=00
CLEICode=
BOM=
```

### `80` Parameter Set Request
Example (to PSU): `108180FE: 01 34 00 00 00 00 00 00`

Data bytes:
- Byte 0-1: parameter id
- Byte 2-7: data

Parameters:
- int32 in bytes 4-7
    - `01 00`: Online output voltage (* 1024)
    - `01 01`: Offline output voltage (* 1024)
    - `01 02`: Overvoltage protection? (* 1024)
    - `01 03`: Online current limit (* 1024)
        - Possibly percent value (0-1), can be converted by dividing by nominal PSU current (~35 for R4830, ~53 for R4850)
    - `01 04`: Offline current limit (* 1024)
        - Possibly percent value (0-1), can be converted by dividing by nominal PSU current (~35 for R4830, ~53 for R4850)
- `01 09`: Input current limit (* 1024)
    - limit active in byte 3 (`00` = limit inactive, `01` = limit active)
    - value in bytes 4-7
- bool in byte 3
    - `01 32`: Standby (`00` = PSU on, `01` = PSU standby)
    - `01 34`: Online fan mode (`00` = auto, `01` = full speed)
    - `01 35`: Offline fan mode (`00` = auto, `01` = full speed)

### `80` Parameter Set Response
Example (from PSU): `1081807E: 01 34 00 00 00 00 00 00`

Data bytes:
- Byte 0: status (`01` = ok, `21` = error)
- Byte 1-7: copied from request

### `11` Current (Unsolicited)
Example (from PSU):
```
1001117E: 00 01 00 00 00 00 00 00
108111FE: 00 03 00 00 00 01 00 00
```

Message source bit in CAN ID has to be checked as the PSU publishes both directions(?).

Data bytes:
- Byte 0-2: ?
- Byte 3: Ready status (`00` = ready, ?? = not ready)
- Byte 5: Active status (`00` = off, `01` = on)
- Bytes 6-7: (u)int16 output current (/ 1024)
    - Possibly percent value (0-1), can be converted by multiplying by nominal PSU current (~35 for R4830, ~53 for R4850)