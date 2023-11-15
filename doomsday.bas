
'   DOOMSDAY.BAS -- Calculate the day of the week for any date

'   By ZCJ

'   Uses the doomsday algorithm, devised by John Conway

'   Copyright 2022, 2023 ZCJ, self-update code by UNDERWOOD


'   This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
'   This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
'   You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>. 


'   Notes:
'           Script is a tad bloaty, and there are parts that could certainly be pared down a bit
'           There are definitely parts in here that aren't optimised for speed, and could be improved upon a bit

    author$  = "zcj"
    package$ = "doomsday.bas"
    version$ = "1.4.12"
    tstamp   = 1699932042

    randomize th_time

    gosub 13 : ' self-update

    def fnChomp$( s$ ) = th_sed$( s$ , "^\s+|\s+$" ) : ' trim leading and trailing spaces
    crlf$ = chr$(13) + chr$(10) : ' guh

    ? ups$( package$ ) + " v" + version$ + " - by " + ups$( author$ )
    ?

    for i = 1 to argc% :

        argv$(i) = th_sed$( argv$(i) , "^(-?-|\/)" )
        
        if th_re( ups$( argv$(i) ) , "^T(IMESTAMP)?$" )       then : timestamp$ = th_localtime$( str$( argv$( i + 1 ) ) ) : date_from_timestamp = 1
        if th_re( ups$( argv$(i) ) , "^((H(ELP)?)|\?)$" )     then : help_me = 1
        if th_re( ups$( argv$(i) ) , "^F(OR)?$" )             then : just_get_doomsday = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$(i) ) , "^A(NCHOR)?$" )          then : just_get_anchor = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$(i) ) , "^(\d+[/\-\.]){2}\d+$" ) then : date_from_arg = 1 : parse_me$ = argv$(i)
        if th_re( ups$( argv$(i) ) , "^F(ORMAT)?$" )          then : format$ = th_sed$( th_sed$( th_sed$( ups$( argv$( i + 1 ) ) , "Y+" , "1" ) , "M+" , "2" ) , "D+" , "3" )
        if th_re( ups$( argv$(i) ) , "^TODAY$" )              then : timestamp$ = th_localtime$( th_time ) : date_from_timestamp = 1 : today = 1
        if th_re( ups$( argv$(i) ) , "^RANDOM$" )             then : timestamp$ = th_localtime$( rnd( th_time ) ) : date_from_timestamp = 1

    next

    if ( date_from_timestamp ) then : goto 8
    if ( just_get_doomsday )   then : goto 11
    if ( date_from_arg )       then : goto 10
    if ( help_me )             then : goto 9
    if ( just_get_anchor )     then : goto 3

  ' Manual input

    boring_old_regular_input = 1

    ? "Year? "  ; : year$  = fnChomp$( input$ )
    ? "Month? " ; : month$ = fnChomp$( input$ )
    ? "Day? "   ; : day$   = fnChomp$( input$ )

  ' i did inputs like this because doing 'normal' input statements would take up more space
  ' plus this just looks nicer

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
    timeframe_n = val( th_re$( th_localtime$ , "\d+" , 2 ) + th_re$( "0" + str$( th_localtime(4) + 1 ) , ".{2}$" ) + th_re$( "0" + th_re$( th_localtime$ , "\d{1,2}" ) , ".{2}$" ) ) : ' ditto but for today, whenever that is, 'now'

    if ( timeframe_t < timeframe_n ) then : timeframe$ = "was"     : ' then is before now
    if ( timeframe_t = timeframe_n ) then : timeframe$ = "is"      : ' then is during now
    if ( timeframe_t > timeframe_n ) then : timeframe$ = "will be" : ' then is after now

    day$ = th_re$( "0" + day$ , ".{2}$" )

    ? day$ + " " + revmonth$( th_sed$( month$ , "^0+" ) ) + " " + year$ + " " + timeframe$ + " on a " ; 

  ' above just prints out date in a pretty format
  ' it's not iso, really should be

  ' can't remember why I decided to print it like this, but I did

    ? days$(dd)

  ' day of the week that selected date falls on

    end


1 ' Get last two digits of year and get year code

    if ( len( year$ ) < 4 ) then : year$ = string$( 4 - len( year$ ) , "0" ) + year$

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

  ' the numbers for each month represent the difference from a multiple of seven
  ' e.g. march has doomsdays that are always multiples of seven (0, 7, 14, ...), so no change needs to be applied
  ' december, on the other hand, has doomsdays that fall two days behind multiples of seven (5, 12, 19, ...), so it has to be offset by two
  ' neat shit

    return


3 ' Generate century array and get century code
    
    centuries(0) = 2
    centuries(1) = 0
    centuries(2) = 5
    centuries(3) = 3

    ce$ = th_sed$( year$ , "\d{2}$" )
    century_code = centuries( int( ce$ ) mod 4 )

    if ( just_get_anchor ) then : gosub 1 : gosub 2 : gosub 4 : gosub 5 : gosub 6 : ' fuckin' data statements
    if ( just_get_anchor ) then : ? year$ + "'s anchor date is " ;
    if ( just_get_anchor ) then : ? days$( century_code )
    if ( just_get_anchor ) then : end

  ' these are the 'anchor days', or the doomsdays of each century
  ' it cycles around like this every four years, so `year mod 4` finds it quick 'n' easy

  ' the bottom bit just prints anchor, and ends

    return


4 ' Leap years (argh)

    n = val( year$ )
    is_leap = ( ( not ( n mod 4 ) ) and ( not ( n mod 100 = 0 ) ) ) or ( not ( n mod 400 ) )

'   if ( ups$( month$ ) = "JANUARY" ) or ( ups$( month$ ) = "FEBRUARY" ) or ( th_re( month$ , "^0*[12]$" ) ) then : jan_or_feb = 1
    jan_or_feb = ( ( ups$( month$ ) = "JANUARY" ) or ( ups$( month$ ) = "FEBRUARY" ) or ( th_re( month$ , "^0*[12]$" ) ) )

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
    
        read days$(i)

    next

  ' should be self-explanatory, index just points to that day of the week

    return


6 ' Reverse month table

    data "January"   , "February" , "March"    , "April"
    data "May"       , "June"     , "July"     , "August"
    data "September" , "October"  , "November" , "December"

    for i = 1 to 12 :

        read m$
        revmonth$( str$(i) ) = m$
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
    year$  = th_re$( timestamp$ , "\d{4}" )
    month$ = th_re$( timestamp$ , "[A-Z]\w+" , 2 )
    day$   = th_re$( timestamp$ , "\d{1,2}" )

    gosub 1
    gosub 2
    gosub 3
    gosub 4
    gosub 5
    gosub 6

    goto 0

  ' parse year, month, and day from th_localtime() output
  ' kinda hardcoded, yes, but timestamps will only have years from 1970 to 9999

    ? "%exec error" : stop : ' shouldn't hit this line
  ' if I was a competent programmer I wouldn't need that in here, but I am not, so no such luck


9 ' Help

    help$ = help$ + "%usage:" + crlf$ + crlf$
    help$ = help$ + spc$(4) + "doomsday [iso date]" + crlf$
    help$ = help$ + spc$(4) + "doomsday --timestamp <unix timestamp>" + crlf$
    help$ = help$ + spc$(4) + "doomsday --for <year>" + crlf$
    help$ = help$ + spc$(4) + "doomsday --anchor <year>" + crlf$
    help$ = help$ + spc$(4) + "doomsday --format <date format> <date>" + crlf$
    help$ = help$ + spc$(4) + "doomsday --today" + crlf$
    help$ = help$ + spc$(4) + "doomsday --random" + crlf$

  ' this way there shouldn't be any delay when printing lines
  ' not that it matters in the slightest, just gives me peace of mind

    ? help$

    end


10 'Date from arg

    if ( format$ = "" ) then : format$ = "123"

    year$  = th_re$( parse_me$ , "\d+" , pos( format$ , "1" ) )
    month$ = th_re$( parse_me$ , "\d+" , pos( format$ , "2" ) )
    day$   = th_re$( parse_me$ , "\d+" , pos( format$ , "3" ) )

  ' format$ is just the order of years, months, and days: 1 is years, 2 is months, 3 is days
  ' then it just takes the values in that order

    gosub 1
    gosub 2
    gosub 3
    gosub 4
    gosub 5
    gosub 6

    goto 0

    ? "%exec error" : stop : ' shouldn't hit this line, etc

  ' get year, month, and day from the argument with the date in it by use of th_re$
  ' probably a more elegant way to do this, but that's a problem for somebody who wants elegant code


11 'Just doomsday

    gosub 1
    gosub 2
    gosub 3
    gosub 4
    gosub 5
    gosub 6

'   not jumping to all of those breaks array stuff because data statements are jank

    timestamp_t = val( year$ ) : ' then
    timestamp_n = val( th_re$( th_localtime$ , "\d+" , 2 ) ) : ' now

    if ( timestamp_t < timestamp_n ) then : timeframe$ = "was"     : ' then is before now
    if ( timestamp_t = timestamp_n ) then : timeframe$ = "is"      : ' then is during now
    if ( timestamp_t > timestamp_n ) then : timeframe$ = "will be" : ' then is after now

    ? year$ + "'s doomsday " + timeframe$ + " on a " + days$( ( century_code + yy + int( yy / 4 ) ) mod 7 )

    end


12 'Generate reverse reverse month table

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
  ' this makes it easy to find what numeric month you're talking about, which is necessary for calculating the timeframe later on

  ' the mod stuff just does 1-12 two times, if that's not clear

    return


13 'self-update, courtesy of underwood

    rpkg$ = th_sed$( package$ , "\." , "\." )
    th_exec "\pub /raw | grep '([^\s]+[\s]+){2}" + rpkg$ + "'" ; rstamp$ : rstamp = val(th_re$(rstamp$, "([^\s]+\s+){2}(\d+)", "%2"))
    if rstamp < tstamp then return
    ? "Checking for updates..."
    udcmd$ = "\pub /less " + author$ + "/" + package$ + "|head -n 10"
    th_exec udcmd$ ; fh$
    latest$ = th_re$(th_re$(fh$,"version\$\s*=\s*\S+"),"\d+\.\d+\.\d+")
    if latest$ > version$ then ? "%an update is available (" + latest$ + ", you have " + version$ + ")" : gosub 14
    if version$ >= latest$ then ? "You have the latest version: " + version$ + ". (Remote: " + latest$ + ")"
    if version$ = latest$ then th_exec "\pub /raw|grep '([^\s]+[\s]+){2}" + rpkg$ + "'" ; stamp$ : stamp$ = th_re$(stamp$, "[^\s]+\s")

    return


14 'offer to update

    ? "view diff? [y/N] " ;
    yn$ = inkey$ : ? yn$
    if yn$ = "y" then gosub 16
    ? "update to " + latest$ + "? [y/N] " ;
    yn$ = inkey$ : ? yn$
    if yn$ = "y" then goto 15

    return


15 'update

    ? "updating..."
    udcmd$ = "\pub /get /y " + author$ + "/" + package$
    ? udcmd$
    th_exec udcmd$ ; update_status$
    if not th_re(update_status$,"File saved") then ? "%an error occurred while updating" : end
    th_exec "\run " + package$ + " " + ARG$

    end


16 'show diff

    tmp$ = th_re$( th_md5hex$( package$ ) , "^.{2}" ) + ".latest.tmp"
    th_exec "\pub /get /y /to=" + tmp$ + " " + author$ + "/" + package$ ; out$
    th_exec "\diff /colour " + package$ + " " + tmp$
    scratch tmp$ ; out$

    return


  ' recommended reading:

  ' https://en.wikipedia.org/wiki/Doomsday_rule
  ' https://telehack.com/r/wHhdu
  ' https://telehack.com/r/KnACf
  ' https://telehack.com/r/P5m4o


'   TODO:

'   allow for options to use = where applicable, e.g. `doomsday --format=mmddyyyy 10-31-1963`, currently that just fucks it up completely
'   make --format options actually representative of numbers of things, i.e. mmmddddy would be invalid
'   add an arg check so invalid inputs don't break output
'   doomsday --cal 1984
'   optimise for speed a bit more
