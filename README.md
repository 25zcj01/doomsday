# Doomsday
Command-line doomsday calculator.  

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
    doomsday -t <timestamp>
    doomsday for <year>

    Options:
    doomsday --verbose
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
