![TeleBASIC](https://raw.githubusercontent.com/telehack-foundation/.github/main/profile/svg/telebasic.svg)
# Doomsday
Command-line doomsday calculator.  

Copyright 2022, 2023 ZCJ
```
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 
```
## Written for [Telehack](https://telehack.com)

### Wuzzat? 

The doomsday algorithm was worked out by John Conway.  It makes use of the fact
that each year has specific dates that all fall on the same day of the week.  
This day of the week changes based on the year, obviously, or the calendar
would look rather dull.  There's a skip of one day each year and a skip of two
every leap year.  Once you figure out a year's doomsday, you can add and
subtract to get to the wanted date.  Neat shit.   

### 'Install':

`pub /get zcj/doomsday.bas`

### Usage:
```
$ doomsday --help

CLI Doomsday Calculator

Usage:
doomsday [ISO date]
doomsday t <timestamp>
doomsday for <year>
doomsday anchor <year>
```

### Examples:
```
$ doomsday 2018-08-15

15 August 2018 was on a Wednesday


$ doomsday for 1919

1919's doomsday was on a Friday


$ doomsday --timestamp 1676170892.09022

12 February 2023 is on a Sunday
```
