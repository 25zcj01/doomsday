
' DOOMSDAY.BAS -- Calculate the day of the week for any date

' By ZCJ

' Uses the doomsday algorithm, devised by John Conway


    def fnChomp$( s$ ) = th_sed$( s$ , "^\s+|\s+$" )
    crlf$ = chr$( 13 ) + chr$( 10 )

    ? ups$( argv$( 0 ) ) " - by ZCJ"
    ?

    for i = 1 to argc%
        argv$( i ) = th_sed$( argv$( i ) , "^(-?-|\/)" )
        if th_re( ups$( argv$( i ) ) , "^V(ERBOSE)?$" ) then : v = 1 : ' this should probably always be first
        if th_re( ups$( argv$( i ) ) , "^T(IMESTAMP)?$" ) then : timestamp$ = th_localtime$( str$( argv$( argc% - 1 ) ) ) : t = 1 : goto 8
        if th_re( ups$( argv$( i ) ) , "^((H(ELP)?)|\?)$" ) then : goto 9
        if th_re( ups$( argv$( i ) ) , "^F(OR)?$" ) then : just_doomsday = 1 : year$ = argv$( i + 1 )
        if th_re( ups$( argv$( i ) ) , "^(\d+[/\-\.]){2}\d+$" ) then : from_arg = 1 : parse_me$ = argv$( i ) : goto 10
    next

    if ( just_doomsday ) then : goto 11

  ' Manual input

    overachiever = 1

    input "Year? "  ; year$  : x$ = year$  : gosub 7
    input "Month? " ; month$ : x$ = month$ : gosub 7
    input "Day? "   ; day$   : x$ = day$   : gosub 7

    gosub 1
    gosub 2
    gosub 3
    gosub 4
    gosub 5
    gosub 6

0   dd = ( year_code + month_code + century_code + int( day$ ) + leap_code ) mod 7

    if dd < 0 then : dd = 0

    if v then : ? "( " str$( year_code ) " + " str$( month_code ) " + " str$( century_code ) + " + ( " + day$ " mod 7 ) + " str$( leap_code ) " ) mod 7 = " + str$( ( year_code + month_code + century_code + ( int( day$ ) mod 7 ) + leap_code ) mod 7 ) : ?

    if ( t = 1 or v = 1 and not from_arg and not just_doomsday and not overachiever ) then : ?

    th_exec "\when " + day$ + " " + month$ + " " + year$ ; when$ : w = val( when$ )
    th_exec "\when" ; now$ : n = val( now$ )

    if ( n > w ) then : timeframe$ = " was "
    if ( n < w ) then : timeframe$ = " will be "
    if ( th_re$( th_gmtime$( w ) , "^.+\d{4}" ) = th_re$( th_gmtime$( n ) , "^.+\d{4}" ) ) then : timeframe$ = " is "

    ? day$ " " revmonth$( th_sed$( month$ , "^0+" ) ) " " year$ timeframe$ "on a " ; 

    ? days$( dd )

    end


1 ' Get last two digits of year and get year code

    yy = int( th_re$( year$ , ".{2}$" ) )

    year_code = ( yy + ( yy / 4 ) ) mod 7

    if v then : ? str$( yy ) " + ( " str$( yy ) " / 4 ) = " str$( year_code )

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

    if v then : ? th_sed$( month$ , "^0+" ) " --> " str$( month_code )

    return


3 ' Generate century array and get century code
    
    centuries( 0 ) = 2
    centuries( 1 ) = 0
    centuries( 2 ) = 5
    centuries( 3 ) = 3

    century_code = centuries( int( th_re$( year$ , "^.{2}" ) ) mod 4 )

    if v then : ? str$( int( th_re$( year$ , "^.{2}" ) ) ) " mod 4 = " str$( int( th_re$( year$ , "^.{2}" ) ) mod 4 ) " --> " str$( century_code )

    return


4 ' Leap years (argh)

    if ups$( month$ ) = "JANUARY" or ups$( month$ ) = "FEBRUARY" or th_re( month$ , "^(0+)?(1|2)$" ) then : jf = 1
    if ( val( year$ ) mod 400 ) then : leap = 1

    leap_code = 0 - ( leap * jf )

    if v then : if leap_code = -1 then : ? "month is jan or feb and " year$ " is a leap year, -1 from final"

    return


5 ' Day table

    days$( 0 ) = "Sunday"
    days$( 1 ) = "Monday"
    days$( 2 ) = "Tuesday"
    days$( 3 ) = "Wednesday"
    days$( 4 ) = "Thursday"
    days$( 5 ) = "Friday"
    days$( 6 ) = "Saturday"

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

    return


7 ' Check for empty input

    if fnChomp$( x$ ) = "" then : ? "%cancel" : end

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


9 ' Help me, you're my...

    only_hope$ = only_hope$ + "CLI Doomsday Calculator" + crlf$
    only_hope$ = only_hope$ +                             crlf$
    only_hope$ = only_hope$ + "Usage:"                  + crlf$
    only_hope$ = only_hope$ + "doomsday [ISO date]"     + crlf$
    only_hope$ = only_hope$ + "doomsday -t <timestamp>" + crlf$
    only_hope$ = only_hope$ + "doomsday for <year>"     + crlf$
    only_hope$ = only_hope$ +                             crlf$
    only_hope$ = only_hope$ + "Options:"                + crlf$
    only_hope$ = only_hope$ + "doomsday --verbose"      + crlf$
    only_hope$ = only_hope$ +                             crlf$
    only_hope$ = only_hope$ + "order of args is strict" + crlf$

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


11 ' Just doomsday

    gosub 1
    gosub 3
    gosub 5

    ? year$ "'s doomsday" ;
    
    wy = val( th_re$( year$ , ".{2}$" ) )
    cy = val( th_re$( th_gmtime( 5 ) , ".{2}$" ) )

    if ( wy = cy ) then : timeframe$ = " is "
    if ( wy < cy ) then : timeframe$ = " was "
    if ( wy > cy ) then : timeframe$ = " will be "

    ? timeframe$ "on a " days$( ( century_code + yy + int( yy / 4 ) ) mod 7 )

    end


TODO:

  add an arg check so invalid inputs don't break output
  doomsday --cal 1984
  doomsday --format=ddmmyyyy 13/04/2009
  curselib?