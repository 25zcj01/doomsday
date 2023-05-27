
' DOOMSDAY.BAS -- Calculate the day of the week for any date

' By ZCJ

' Uses the doomsday algorithm, devised by John Conway

' Copyright 2022, 2023 ZCJ


'   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

'   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

'   You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 


    def fnChomp$( s$ ) = th_sed$( s$ , "^\s+|\s+$" ) : ' trim leading and trailing spaces
    crlf$ = chr$( 13 ) + chr$( 10 ) : ' guh

    ? ups$( argv$( 0 ) ) + " - by ZCJ"
    ?

    for i = 1 to argc% :
        argv$( i ) = th_sed$( argv$( i ) , "^(-?-|\/)" )
        if th_re( ups$( argv$( i ) ) , "^T(IMESTAMP)?$" )       then : timestamp$ = th_localtime$( str$( argv$( i + 1 ) ) ) : date_from_timestamp = 1
        if th_re( ups$( argv$( i ) ) , "^((H(ELP)?)|\?)$" )     then : help_me = 1
        if th_re( ups$( argv$( i ) ) , "^F(OR)?$" )             then : just_get_doomsday = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$( i ) ) , "^A(NCHOR)?$" )          then : just_get_anchor = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$( i ) ) , "^(\d+[/\-\.]){2}\d+$" ) then : date_from_arg = 1 : parse_me$ = argv$( i )
    next

    if ( date_from_timestamp ) then : goto 8
    if ( just_get_doomsday )   then : goto 11
    if ( date_from_arg )       then : goto 10
    if ( help_me )             then : goto 9
    if ( just_get_anchor )     then : goto 3

  ' Manual input

    boring_old_regular_input = 1

    input "Year? "  ; year$  : in$ = year$  : gosub 7
    input "Month? " ; month$ : in$ = month$ : gosub 7
    input "Day? "   ; day$   : in$ = day$   : gosub 7

    gosub 1
    gosub 2
    gosub 3
    gosub 4
    gosub 5
    gosub 6

0   dd = ( year_code + month_code + century_code + int( day$ ) - leap_code ) mod 7

    if ( dd < 0 ) then : dd = 0 : ' if I wrote this correctly then this should never be necessary, but it can't hurt

  ' the whole shebang

    if ( not ( date_from_timestamp = 1 ) and not ( date_from_arg ) and not ( just_get_doomsday ) and not ( boring_old_regular_input ) ) then : ?
  ' this is in here because I can't seem to write anything that has a consistent amount of vertical whitespace, so I just throw shit like this in to make it even
  ' basically if any arg things are in use there's an extra line of whitespace, which is ugly, so I add an equally ugly line of code to make sure that it's not printed
  ' of course, this would likely break if any new arg stuff is added, but not necessarily -- this is just a massive clusterfuck really

  ' the following figures out whether the date you're looking at is before, during, or after the current th_localtime$
  ' there's certainly a less convoluted way to do this, but this _should_ work
  ' I haven't tested it, but I'm 99% sure that a non-four digit date will break this part, because I can't write code that works universally

    gosub 12 : ' gen array for reverse month lookup

    timeframe_t = val( year$ + monthsn$( ups$( month$ ) ) + th_re$( "0" + day$ , ".{2}$" ) ) : ' iso date of whenever input is, 'then'
    timeframe_n = val( th_re$( th_localtime$ , "\d+" , 2 ) + th_re$( "0" + str$( th_localtime( 4 ) + 1 ) , ".{2}$" ) + th_re$( th_localtime$ , "\d+" ) ) : ' ditto but for today, whenever that is, 'now'

    if ( timeframe_t < timeframe_n ) then : timeframe$ = "was"     : ' then is before now
    if ( timeframe_t = timeframe_n ) then : timeframe$ = "is"      : ' then is during now
    if ( timeframe_t > timeframe_n ) then : timeframe$ = "will be" : ' then is after now

    ? day$ + " " + revmonth$( th_sed$( month$ , "^0+" ) ) + " " + year$ + " " + timeframe$ + " on a " ; 

  ' above just prints out date in a pretty format
  ' it's not iso, really should be

  ' can't remember why I decided to print it like this, but I did

    ? days$( dd )

  ' day of the week that selected date falls on

    end


1 ' Get last two digits of year and get year code

    if ( len( year$ ) < 4 ) then : year$ = string$( 4 - len( year$ ) , "0" ) + year$

    if ( len( year$ ) > 4 ) then : ? "%years over four digits aren't supported yet" : end 

    yy = int( th_re$( year$ , ".{2}$" ) )

    year_code = ( yy + ( yy / 4 ) ) mod 7

  ' all this does is get the doomsday for your year of choice without factoring in the anchor day
  ' we don't have that right now, but we will later, so it's not cause for concern

    return


2 ' Generate month hash table and get month code

    data "JANUARY"   , "1"  , 4
    data "FEBRUARY"  , "2"  , 0
    data "MARCH"     , "3"  , 0
    data "APRIL"     , "4"  , 3
    data "MAY"       , "5"  , 5
    data "JUNE"      , "6"  , 1
    data "JULY"      , "7"  , 3
    data "AUGUST"    , "8"  , 6
    data "SEPTEMBER" , "9"  , 2
    data "OCTOBER"   , "10" , 4
    data "NOVEMBER"  , "11" , 0
    data "DECEMBER"  , "12" , 2

    for i = 1 to 12 :
        read n$ , s$ , d
        months( n$ ) = d
        months( s$ ) = d
    next

    month_code = months( th_sed$( ups$( month$ ) , "^0+" ) )

  ' so:
  ' I'm not entirely sure how this bit works
  ' but I know that it does

  ' so I'll assume you, dear reader, are able to work a search engine of your choosing and find out what the hell is happening

    return


3 ' Generate century array and get century code
    
'   the century code isn't 100% accurate because it takes the top two numbers every time
'   fix that, zcj

    centuries( 0 ) = 2
    centuries( 1 ) = 0
    centuries( 2 ) = 5
    centuries( 3 ) = 3

    century_code = centuries( int( th_re$( year$ , "^.{2}" ) ) mod 4 )

    if ( just_get_anchor ) then : gosub 5
    if ( just_get_anchor ) then : ? year$ + "'s anchor date is " ;
    if ( just_get_anchor ) then : ? days$( century_code )
    if ( just_get_anchor ) then : end

  ' these are the 'anchor days', or the doomsdays of each century
  ' it cycles around like this every four years, so `year mod 4` finds it quick 'n' easy

  ' the bottom bit just sets up the days table, prints anchor, and ends

    return


4 ' Leap years (argh)

    n = val( year$ )
    is_leap = ( ( not ( n mod 4 ) ) and ( not ( n mod 100 = 0 ) ) ) or ( not ( n mod 400 ) )

    if ( ups$( month$ ) = "JANUARY" ) or ( ups$( month$ ) = "FEBRUARY" ) or ( th_re( month$ , "^(0+)?(1|2)$" ) ) then : jan_or_feb = 1

    leap_code = ( is_leap * jan_or_feb )

  ' if the year in question is a leap year, then the doomsdays in january and february are pushed forwards one day
  ' this means that you need to subtract one from the final product if it's january or february in a leap year

  ' is_leap and jan_or_feb multiply to zero if either is zero (duh)
  ' so zero plus their value will be either 0 or 1

  ' took me too long to think up a good way to do this heh

    return


5 ' Day table

    data "Sunday"    , "Monday"   , "Tuesday"
    data "Wednesday" , "Thursday" , "Friday"
    data "Saturday"

    for i = 0 to 6 :
        read days$( i )
    next

  ' should be self-explanatory, index just points to that day of the week

    return


6 ' Reverse month table

    data "January"   , "February" , "March"    , "April"
    data "May"       , "June"     , "July"     , "August"
    data "September" , "October"  , "November" , "December"

    for i = 1 to 12 :
        read m$
        revmonth$( str$( i ) ) = m$
        revmonth$( m$ ) = m$
    next

  ' this makes it possible to get the month name from whatever format the month was given it, be it the month's actual name or the number it's associated with
  ' this is useful later on

    return


7 ' Check for empty input

    if ( fnChomp$( in$ ) = "" ) then : ? "%cancel" : end

  ' check for empty args, if blank then end

    return


8 ' Parse Unix timestamp
  ' Probably broken lol
    year$  = th_re$( timestamp$ , "\d{4}" )        : gosub 1
    month$ = th_re$( timestamp$ , "[A-Z]\w+" , 2 ) : gosub 2
    day$   = th_re$( timestamp$ , "\d{2}" )        : gosub 3
                                                     gosub 4
                                                     gosub 5
                                                     gosub 6
                                                     goto  0

  ' parse year, month, and day from th_localtime() output
  ' kinda hardcoded, yes, but timestamps will only have years from 1970 to 9999

    ? "%exec error" : stop : ' shouldn't hit this line
  ' if I was a competent programmer I wouldn't need that in here, but I am not, so no such luck


9 ' Help me Obi-wan Kenobi, you're my...

    only_hope$ = only_hope$ + "CLI Doomsday Calculator" + crlf$
    only_hope$ = only_hope$ +                             crlf$
    only_hope$ = only_hope$ + "Usage:"                  + crlf$
    only_hope$ = only_hope$ + "doomsday [ISO date]"     + crlf$
    only_hope$ = only_hope$ + "doomsday t <timestamp>"  + crlf$
    only_hope$ = only_hope$ + "doomsday for <year>"     + crlf$
    only_hope$ = only_hope$ + "doomsday anchor <year>"  + crlf$

    ? only_hope$

    end


10 ' Date from arg

    year$  = th_re$( parse_me$ , "\d+" , 1 ) : gosub 1
    month$ = th_re$( parse_me$ , "\d+" , 2 ) : gosub 2
    day$   = th_re$( parse_me$ , "\d+" , 3 ) : gosub 3
                                               gosub 4
                                               gosub 5
                                               gosub 6
                                               goto  0

    ? "%exec error" : stop : ' shouldn't hit this line, etc

  ' get year, month, and day from the argument with the date in it by use of th_re$
  ' probably a more elegant way to do this, but that's a problem for somebody who wants elegant code

11 ' Just doomsday

'   this is a lotta vestigial code, should be modernised to above

    gosub 1 : ' get year code
    gosub 2
    gosub 3 : ' generate century array
    gosub 4
    gosub 5 : ' generate day array
    gosub 6

  ' i dunno why, but not jumping to all of these subs breaks the days$() array
  ' i'll fix that eventually, but 'til then i'll just leave it like this

    ? year$ + "'s doomsday " ;
    
    wy = val( year$ ) : ' working year
    cy = val( th_re$( th_localtime$ , "\d+" , 2 ) ) : ' current year

    if ( wy < cy ) then : timeframe$ = "was"     : ' working year is before current year
    if ( wy = cy ) then : timeframe$ = "is"      : ' working year and current year are the same
    if ( wy > cy ) then : timeframe$ = "will be" : ' working year is after current year

    ? timeframe$ + " on a " + days$( ( century_code + yy + int( yy / 4 ) ) mod 7 )

    end


12 ' Generate reverse reverse month table

    data "JANUARY"   , "FEBRUARY" , "MARCH"    , "APRIL"
    data "MAY"       , "JUNE"     , "JULY"     , "AUGUST"
    data "SEPTEMBER" , "OCTOBER"  , "NOVEMBER" , "DECEMBER"

    data "01" , "02" , "03" , "04"
    data "05" , "06" , "07" , "08"
    data "09" , "10" , "11" , "12"

    for i = 0 to 23 :
        read s$
        monthsn$( s$ ) = th_re$( "0" + str$( ( i mod 12 ) + 1 ) , ".{2}$" )
    next

  ' this array takes a given month, either numeric like '01' or written out like 'February' and returns the index that gives you that month, if that makes any sense
  ' month logarithms?

  ' this makes it easy to find what numeric month you're talking about, which is necessary for calculating the timeframe later on

  ' the mod stuff just does 1-12 two times, if that's not clear

    return


' TODO:

'    add an arg check so invalid inputs don't break output
'    doomsday --cal 1984
'    doomsday --format=ddmmyyyy 13/04/2009
'    curselib?
'    dates that aren't four digits break some calculations, fix that