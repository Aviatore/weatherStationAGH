# WReader - the terminal-based weather station reader
## Introduction
The Perl script downloads the source code of the webpage [http://meteo.ftj.agh.edu.pl/meteo/](http://meteo.ftj.agh.edu.pl/meteo/)  and extracts last readings of the user-defined parameter. The available parameters are as follows:

|Parameter name|Parameter description |
|--|--|
| pm | pm 10 [µg/m3]|
| rain_sum | total rain [mm]|
| rain | rain intensity [mm/h]|
|	wind_max | max wind speed [m/s]|
|	wind_direction | wind direction [°]|
|	wind | wind speed [m/s]|
|	pressure_QNH | atm. pressure reduced to the sea level [hPa]|
|	pressure | atm. pressure [hPa]|
|	humidity | relative humidity [%]|
|	dew_point_temp | dew point temperature [°C]|
| 	temp | air temperature [°C]|

The script displays the data in the ASCII-based graph.

## Usage

    perl reader.pl --parameter [parameter name]

**Available options:**
- `--parameter` - the parameter name,
- `--scale` - the number of scale ticks, default=10,
- `--help` - displays the usage.
