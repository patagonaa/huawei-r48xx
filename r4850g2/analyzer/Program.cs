// See https://aka.ms/new-console-template for more information
using System.Globalization;

Console.WriteLine("Hello, World!");


var csvLines = await File.ReadAllLinesAsync("../../../../param_get_sweep_ac_dann_batterie_an_dann_ac_aus.csv");


var validResponses = new List<(int, byte[])>();

foreach (var line in csvLines.Skip(1))
{
    var split = line.Split(',');
    var id = split[1];
    var dir = split[3];
    byte[] data = [
        byte.Parse(split[6], NumberStyles.HexNumber),
        byte.Parse(split[7], NumberStyles.HexNumber),
        byte.Parse(split[8], NumberStyles.HexNumber),
        byte.Parse(split[9], NumberStyles.HexNumber),
        byte.Parse(split[10], NumberStyles.HexNumber),
        byte.Parse(split[11], NumberStyles.HexNumber),
        byte.Parse(split[12], NumberStyles.HexNumber),
        byte.Parse(split[13], NumberStyles.HexNumber)
        ];

    if(id == "1081827E" && dir == "Rx" && ((data[0] & 0xF0) >> 4) != 2)
    {
        validResponses.Add(((data[0] & 0x0F) << 8 | data[1], data[2..]));
        //validResponses.Add(((data[0] & 0x0F) << 8 | data[1]).ToString("X3") + ": " + string.Join(' ', data[2..].Select(x => x.ToString("X2"))));
    }
}

var grouped = validResponses.GroupBy(x => x.Item1.ToString("X3")).Select(x => $"{x.Key}: {string.Join(", ", x.Select(y => $"{BitConverter.ToInt16(y.Item2)}|{BitConverter.ToInt16(y.Item2[2..])}|{BitConverter.ToInt16(y.Item2[4..])}"))}").ToList();
var grouped2 = validResponses.GroupBy(x => x.Item1.ToString("X3")).Select(x => $"{x.Key}: {string.Join(", ", x.Select(y => $"{BitConverter.ToInt32(((byte[])[0, 0, ..y.Item2]).Reverse().ToArray()) / 1024.0:F8}"))}").ToList();

Console.WriteLine(validResponses.Count);