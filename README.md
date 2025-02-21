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
- https://max.book118.com/html/2022/0414/5230000111004213.shtm
    - see `docs/`
- https://tieba.baidu.com/p/7475319470

### General

The CAN interface uses 125kbps rate with extended 29-bit identifiers.

### CAN ID

The CAN message IDs do not specify a single value/register.
Instead, the message ID is used as an address, function code, message direction, etc..

Example: `1081407F`

Interpretation:  
Bits: `000a aaaa abbb bbbb cccc cccc deee eefg`
- 0 (bit 31-29): always zero (CAN ID is 29-bit)
- a (bit 28-23): protocol ID (always `21`)
- b (bit 22-16): address (0 = broadcast, 1 = first, ...)
- c (bit 15-8): command id
- d (bit 7): message source (0 = from PSU, 1 = to PSU)
- e (bit 6-2): group mask (always `1F`)
- f (bit 1): hardware / software address (0 = hw, 1 = sw, always 1)
- g (bit 0): finished marker (0 = finished, 1 = more data coming)

Apparently the PSU can have a "hardware address" and "software address"
but even the original "SMU02B" controller seems to use only the software address.

The "software address" seems to be negotiated automatically if multiple PSUs are on one CAN bus (starting at 1).

The "hardware address" might be fixed per slot, because the original PSU rack has a network of resistors
and dip switches on the two "slot detect" pins of the connector. Possibly, this allows the PSU to know
which slot it is in, which might set the PSU "hardware address", but I haven't tested this.

### `40` Data Request
Example (to PSU):
`108140FE: 00 00 00 00 00 00 00 00`

Requests a data response composed of multiple messages.

### `40` Data Reponse
Example (from PSU):
```
1081407F: 01 0E 00 00 00 00 2A 01
1081407F: 01 70 00 00 00 1C DC 31
1081407F: 01 71 00 00 00 00 C7 F5
1081407F: 01 72 00 00 00 00 20 91
1081407F: 01 73 00 00 00 1C 20 9A
1081407F: 01 74 00 00 00 00 03 E6
1081407F: 01 75 00 00 00 00 CD B1
1081407F: 01 76 00 00 00 00 04 00
1081407F: 01 78 00 00 00 03 8B 80
1081407F: 01 7F 00 00 00 00 84 00
1081407F: 01 80 00 00 00 00 6C 00
1081407F: 01 81 00 00 00 00 8C 11
1081407F: 01 82 00 00 00 00 8C 07
1081407E: 01 83 00 00 10 00 00 00
```

Data bytes:
- Byte 0-1: register id
- Bytes 2-3: ? (always 0)
- Bytes 4-7: int32 value

Register values:
| register id | example                         | description                                      |
| ----------- | ------------------------------- | ------------------------------------------------ |
| `01 0E`     | `00 00 00 00 2A 01` = 10753 Hrs | Operating Hours (?)                              |
| `01 70`     | `00 00 00 1C DC 31` = 1847W     | Input Power ( / 1024 = A)                        |
| `01 71`     | `00 00 00 00 C7 F5` = 49.99Hz   | Input Frequency ( / 1024 = Hz)                   |
| `01 72`     | `00 00 00 00 20 91` = 8.14A     | Input Current ( / 1024 = A)                      |
| `01 73`     | `00 00 00 1C 20 9A` = 1800W     | Output Power ( / 1024 = W)                       |
| `01 74`     | `00 00 00 00 03 E6` = 97%       | Efficiency ( / 1024 = 0-1)                       |
| `01 75`     | `00 00 00 00 CD B1` = 51.4V     | Output Voltage ( / 1024 = V)                     |
| `01 76`     | `00 00 00 00 04 00` = 100%      | Output Current Setpoint\* ( / 1024 = 0-1)        |
| `01 78`     | `00 00 00 03 8B 80` = 226.8V    | Input Voltage ( / 1024 = V)                      |
| `01 7F`     | `00 00 00 00 84 00` = 33°C      | Output Temperature ( / 1024 = °C)                |
| `01 80`     | `00 00 00 00 6C 00` = 27°C      | Input Temperature ( / 1024 = °C)                 |
| `01 81`     | `00 00 00 00 8C 11` = 35.02A    | Output Current 1 (fast/unfiltered) ( / 1024 = A) |
| `01 82`     | `00 00 00 00 8C 07` = 35.01A    | Output Current 2 (slow/filtered) ( / 1024 = A)   |

\* Percent value (0-1), can be converted by dividing by nominal PSU current (~35 for R4830, ~53 for R4850).
The actual output current limit as determined by AC and output current limits (this number gets lower when AC limit is set)

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
- Byte 0-1: register id
- Bytes 2-7: data

Registers:
| register id | data                | example                                                                      | description                                                             |
| ----------- | ------------------- | ---------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `00 01`     | `?? ?? ?? ?? ?? ??` | `00 01 00 00 40 46 12 67` (R4830S1) /<br>`00 01 00 00 40 68 0E 2C` (R4850G6) | Module characteristic data(?)                                           |
| `00 02`     | `xx xx xx xx xx xx` | `00 02 64 46 85 50 02 AF` = ?                                                | Serial number                                                           |
| `00 03`     | `xx xx xx xx xx xx` | `00 03 32 31 30 32 33 31` = "210231"                                         | Barcode part 1 (ASCII)                                                  |
| `00 04`     | `xx xx xx xx xx xx` | `00 04 31 54 52 52 4C 55` = "1TRRLU"                                         | Barcode part 2 (ASCII)                                                  |
| `00 05`     | `xx xx yy yy zz zz` | `00 05 05 00 01 0D 01 0D`                                                    | `xx` = HW version,<br>`yy` = DC-DC SW version,<br>`zz` = PFC SW version |
| `00 06`     | `xx xx 00 00 00 00` | `00 06 01 01 00 00 00 00`                                                    | Hardware address                                                        |

### `D2` E-Label Request
Example (to PSU): `1081D2FE: 00 00 00 00 00 00 00 00`

### `D2` E-Label Response

Example (from PSU):
```
1081D27F: 00 01 2F 24 5B 41 72 63
1081D27F: 00 02 68 69 76 65 73 49
1081D27F: 00 03 6E 66 6F 20 56 65
1081D27F: 00 04 72 73 69 6F 6E 5D
[...]
1081D27F: 00 33 3D 30 30 0D 0A 43
1081D27F: 00 34 4C 45 49 43 6F 64
1081D27F: 00 35 65 3D 0D 0A 42 4F
1081D27E: 00 36 4D 3D 0D 0A 00 00
```

- Byte 0-1: Message part number
- Bytes 2-7: ASCII Data (null-terminated)

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

### `80` Register Set Request
Example (to PSU): `108180FE: 01 34 00 01 00 00 00 00`

Data bytes:
- Byte 0-1: register id
- Byte 2-7: data

Registers:
| register id | data                | example                                                                                  | description                                                                |
| ----------- | ------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `01 00`     | `00 00 xx xx xx xx` | 53.5V * 1024 = 0x0000D600<br>= `01 00 00 00 00 00 D6 00`                                 | Online output voltage (V * 1024)                                           |
| `01 01`     | `00 00 xx xx xx xx` |                                                                                          | Offline output voltage (V * 1024)                                          |
| `01 02`     | `00 00 xx xx xx xx` |                                                                                          | Overvoltage protection? (V * 1024)                                         |
| `01 03`     | `00 00 xx xx xx xx` | 3.5A / 35A (for R4830)<br>= 10% = 0.1 * 1024 ≈ 0x00000066<br>= `01 03 00 00 00 00 00 66` | Online current limit\* (0-1 * 1024)                                        |
| `01 04`     | `00 00 xx xx xx xx` |                                                                                          | Offline current limit\* (0-1 * 1024)                                       |
| `01 09`     | `00 xx yy yy yy yy` | 4A * 1024 = 0x00001000<br>= `01 09 00 01 00 00 10 00`<br> (active bit set)               | Input/AC current limit<br>`xx` = limit active<br>`yy` = current (A * 1024) |
| `01 14`     | `xx xx 00 00 00 00` | 50% = 0.5 * 25600 = 12800<br>= `01 14 32 00 00 00 00 00`                                 | Fan duty cycle (0-1 * 25600)                                               |
| `01 18`     | `00 00 xx xx xx xx` | 60s = `01 18 00 00 00 00 00 3C`                                                          | CAN timeout seconds (5-60)                                                 |
| `01 32`     | `00 xx 00 00 00 00` |                                                                                          | Standby<br>`00` = PSU on<br>`01` = standby                                 |
| `01 34`     | `00 xx 00 00 00 00` |                                                                                          | Fan mode<br>`00` = auto<br>`01` = max (online)<br>`02` = max (offline)     |

\* Percent value (0-1), can be converted by dividing by nominal PSU current (~35 for R4830, ~53 for R4850)  

### `80` Register Set Response
Example (from PSU): `1081807E: 01 34 00 01 00 00 00 00`

Data bytes:
- Byte 0 (low nibble): status (`0` = ok, `2` = parameter error)
- Byte 0 (high nibble) - 7: copied from request

### `82` Register Get Request
Example (to PSU):
`108182FE: 01 34 00 00 00 00 00 00`

Seems to work only for status registers (`01 70`, ...) not for config registers (`01 00`, ...).

Data bytes:
- Byte 0-1: register id
- Byte 2-7: zero

### `82` Register Get Response
Example (to PSU):
`1081827E: 01 34 00 01 00 00 00 00`

Data bytes:
- Byte 0 (low nibble): status (`0` = ok, `2` = parameter error)
- Byte 0 (high nibble) - 1: register id
- Byte 2-7: register value

Registers (in addition to ones from `40` data response);
| register id | data                | example                                                  | description                                                                    |
| ----------- | ------------------- | -------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `01 87`     | `xx xx yy yy zz zz` | `01 87 2D 00 64 00 4B 87` = calc 45%, set 100%, 19335RPM | `xx` = calculated\* duty cycle(?)<br>`yy` = duty cycle (/ 25600)<br>`zz` = RPM |

\* possibly the duty cycle the PSU requests to be set based on the temperature

### `11` Current (Unsolicited)
Example (from PSU):
```
1001117E: 00 01 00 00 00 00 04 00
108111FE: 00 03 00 00 00 01 00 00
```

Both `1001117E` (`00 01`) and `108111FE` (`00 03`) sent every 377ms without request.

Due to the message direction (to PSU) in one of the messages I think this might also be used for PSU address negotiation.

Data bytes:
- Byte 0-2: register id (?)
- Bytes 2-7: register values (?)

| register id | data                | example                                         | description                                                                                           |
| ----------- | ------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `00 01`     | `?? xx ?? ?? yy yy` | `00 01 00 00 00 00 04 00`<br>= ready, 100% load | `xx` = ready\*\* status (`00` = ready, `01` = not ready)<br>`yy` = Output current\* (0-1 / 1024)      |
| `00 03`     | `?? ?? ?? xx yy yy` | `00 03 00 00 00 01 00 00`<br>= active, 0% load  | `xx` = active\*\*\* status (`00` = not active, `01` = active)<br>`yy` = Output current\* (0-1 / 1024) |

\* Percent value (0-1), can be converted by dividing by nominal PSU current (~35 for R4830, ~53 for R4850)  
\*\* ready: PSU is ready to output voltage/power (AC input available, not faulted, ...)  
\*\*\* active: device is outputting voltage/power (not booting, not standby, ...)  
