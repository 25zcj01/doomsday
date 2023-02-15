
' DOOMSDAY.BAS -- Calculate the day of the week for any date

' By ZCJ

' Uses the doomsday algorithm, devised by John Conway


    def fnChomp$( s$ ) = th_sed$( s$ , "^\s+|\s+$" )
    crlf$ = chr$( 13 ) + chr$( 10 )

    ? ups$( argv$( 0 ) ) " - by ZCJ"
    ?

    for i = 1 to argc%
        argv$( i ) = th_sed$( argv$( i ) , "^(-?-|\/)" )
        if th_re( ups$( argv$( i ) ) , "^T(IMESTAMP)?$" ) then : timestamp$ = th_localtime$( str$( argv$( i + 1 ) ) ) : date_from_timestamp = 1
        if th_re( ups$( argv$( i ) ) , "^((H(ELP)?)|\?)$" ) then : help_me = 1
        if th_re( ups$( argv$( i ) ) , "^F(OR)?$" ) then : just_get_doomsday = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$( i ) ) , "^(\d+[/\-\.]){2}\d+$" ) then : date_from_arg = 1 : parse_me$ = argv$( i )
    next

    if ( date_from_timestamp ) then : goto 8
    if ( just_get_doomsday )   then : goto 11
    if ( date_from_arg )       then : goto 10
    if ( help_me )             then : goto 9

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

0   dd = ( year_code + month_code + century_code + int( day$ ) + leap_code ) mod 7

    if ( dd < 0 ) then : dd = 0

  ' the whole shebang
  ' the IF statement shouldn't do anything _I think_ but it's a failsafe and those are always good

    if ( not ( date_from_timestamp = 1 ) and not ( date_from_arg ) and not ( just_get_doomsday ) and not ( boring_old_regular_input ) ) then : ?
  ' this is because I can't seem to write anything that has a consistent amount of vertical whitespace, so I just throw shit like this in to make it even
  ' basically if any arg things are in use there's an extra line of whitespace, which is ugly, so I add an equally ugly line of code to make sure that it's not printed
  ' of course, this would likely break if any new arg stuff is added, but not necessarily -- this is just a massive clusterfuck really

    th_exec "\when " + day$ + " " + month$ + " " + year$ ; when$ : when = val( when$ )
    th_exec "\when" ; now$ : now = val( now$ )

  ' the first WHEN gets the timestamp for whatever date we're looking at
  ' breaks with massive numbers, but then again most things do
  ' the second WHEN gets the current timestamp

  ' those are done for the below bit, which just finds which one came first

    if ( now > when ) then : timeframe$ = " was " : ' now is later than then
    if ( now < when ) then : timeframe$ = " will be " : ' then is later than now
    if ( th_re$( th_localtime$( when ) , "^.+\d{4}" ) = th_re$( th_localtime$( now ) , "^.+\d{4}" ) ) then : timeframe$ = " is " : ' then is now but with shenanigans because timestamps are annoying with stuff like this sometimes, and a plain = won't be right because they're too darn precise

    ? day$ " " revmonth$( th_sed$( month$ , "^0+" ) ) " " year$ timeframe$ "on a " ; 

  ' above just prints out date in a pretty format
  ' it's not iso, really should be

  ' can't remember why I decided to print it like this, but I did

    ? days$( dd )

  ' day of the week that selected date falls on

    end


1 ' Get last two digits of year and get year code

    yy = int( th_re$( year$ , ".{2}$" ) )

    year_code = ( yy + ( yy / 4 ) ) mod 7

  ' all this does is get the doomsday for your year of choice without factoring in the anchor day
  ' we don't have that right now, but we will later, so it's not cause for concern

    return


2 ' Generate month hash table and get month code

    months( "JANUARY"   ) = 4
    months( "FEBRUARY"  ) = 0
    months( "MARCH"     ) = 0
    months( "APRIL"     ) = 3
    months( "MAY"       ) = 5
    months( "JUNE"      ) = 1
    months( "JULY"      ) = 3
    months( "AUGUST"    ) = 6
    months( "SEPTEMBER" ) = 2
    months( "OCTOBER"   ) = 4
    months( "NOVEMBER"  ) = 0
    months( "DECEMBER"  ) = 2

    months( "1"  ) = 4
    months( "2"  ) = 0
    months( "3"  ) = 0
    months( "4"  ) = 3
    months( "5"  ) = 5
    months( "6"  ) = 1
    months( "7"  ) = 3
    months( "8"  ) = 6
    months( "9"  ) = 2
    months( "10" ) = 4
    months( "11" ) = 0
    months( "12" ) = 2

    month_code = months( th_sed$( ups$( month$ ) , "^0+" ) )

  ' so:
  ' I'm not entirely sure how this bit works
  ' but I know that it does

  ' so I'll assume you, dear reader, are able to work a search engine of your choosing and find out what the hell is happening

    return


3 ' Generate century array and get century code
    
    centuries( 0 ) = 2
    centuries( 1 ) = 0
    centuries( 2 ) = 5
    centuries( 3 ) = 3

    century_code = centuries( int( th_re$( year$ , "^.{2}" ) ) mod 4 )

  ' these are the 'anchor days', or the doomsdays of each century
  ' it cycles around like this every four years, so `year mod 4` finds it quick 'n' easy

    return


4 ' Leap years (argh)

    if ( ups$( month$ ) = "JANUARY" ) or ( ups$( month$ ) = "FEBRUARY" ) or ( th_re( month$ , "^(0+)?(1|2)$" ) ) then : jan_or_feb = 1
    if not ( val( year$ ) mod 400 ) then : is_leap = 1

    leap_code = 0 - ( is_leap * jan_or_feb )

  ' if the year in question is a leap year, then the doomsdays in january and february are pushed forwards one day
  ' this means that you need to subtract one from the final product if it's january or february in a leap year

  ' is_leap and jan_or_feb multiply to zero if either is zero (duh)
  ' so zero minus their value will be either 0 or -1

  ' took me too long to think up a good way to do this heh

    return


5 ' Day table

    days$( 0 ) = "Sunday"
    days$( 1 ) = "Monday"
    days$( 2 ) = "Tuesday"
    days$( 3 ) = "Wednesday"
    days$( 4 ) = "Thursday"
    days$( 5 ) = "Friday"
    days$( 6 ) = "Saturday"

  ' should be self-explanatory, index just points to that day of the week

    return


6 ' Reverse month table

    revmonth$( "1"  ) = "January"
    revmonth$( "2"  ) = "February"
    revmonth$( "3"  ) = "March"
    revmonth$( "4"  ) = "April"
    revmonth$( "5"  ) = "May"
    revmonth$( "6"  ) = "June"
    revmonth$( "7"  ) = "July"
    revmonth$( "8"  ) = "August"
    revmonth$( "9"  ) = "September"
    revmonth$( "10" ) = "October"
    revmonth$( "11" ) = "November"
    revmonth$( "12" ) = "December"

    revmonth$( "January"   ) = "January"
    revmonth$( "February"  ) = "February"
    revmonth$( "March"     ) = "March"
    revmonth$( "April"     ) = "April"
    revmonth$( "May"       ) = "May"
    revmonth$( "June"      ) = "June"
    revmonth$( "July"      ) = "July"
    revmonth$( "August"    ) = "August"
    revmonth$( "September" ) = "September"
    revmonth$( "October"   ) = "October"
    revmonth$( "November"  ) = "November"
    revmonth$( "December"  ) = "December"

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

    ? "%exec error" : ' shouldn't hit this line
  ' if I was a competent programmer I wouldn't need that in here, but I am not, so no such luck


9 ' Help me, you're my...

    only_hope$ = only_hope$ + "CLI Doomsday Calculator" + crlf$
    only_hope$ = only_hope$ +                             crlf$
    only_hope$ = only_hope$ + "Usage:"                  + crlf$
    only_hope$ = only_hope$ + "doomsday [ISO date]"     + crlf$
    only_hope$ = only_hope$ + "doomsday -t <timestamp>" + crlf$
    only_hope$ = only_hope$ + "doomsday for <year>"     + crlf$

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

  ' get year, month, and day from the argument with the date in it by use of th_re$
  ' probably a more elegant way to do this, but that's a problem for somebody who wants elegant code


11 ' Just doomsday

    gosub 1 : ' get year code
    gosub 3 : ' generate century array
    gosub 5 : ' generate day array

    ? year$ "'s doomsday" ;
    
    wy = val( year$ ) : ' working year
    cy = val( th_re$( th_localtime$ , "\d+" , 2 ) ) : ' current year

    if ( wy = cy ) then : timeframe$ = " is " : ' working year and current year are the same
    if ( wy < cy ) then : timeframe$ = " was " : ' working year is before current year
    if ( wy > cy ) then : timeframe$ = " will be " : ' working year is after current year

    ? timeframe$ "on a " days$( ( century_code + yy + int( yy / 4 ) ) mod 7 )

    end


' TODO:

'    add an arg check so invalid inputs don't break output
'    doomsday --cal 1984
'    doomsday --format=ddmmyyyy 13/04/2009
'    curselib?
