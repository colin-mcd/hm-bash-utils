#!/usr/bin/env bash

# Globals

DEFAULTZIPFILE=$(dirname $0)/.weather_zip_default

if [ -f "$DEFAULTZIPFILE" ]
then ZIPCODE=$(cat "$DEFAULTZIPFILE")
else read -p "Default zipcode: " ZIPCODE
     echo "$ZIPCODE" > "$DEFAULTZIPFILE"
fi

CELSIUS=0
SEVENDAY=0

# Functions

usage() {
    cat 1>&2 <<EOF
Usage: $(basename $0) FLAGS... [zipcode]
-c    Use Celsius degrees instead of Fahrenheit for temperature
-7    Show 7-day forecast
If zipcode is not provided, then it defaults to $ZIPCODE.
EOF
    exit $1
}

weather_information() {
    curl -sL "https://forecast.weather.gov/zipcity.php?inputstring=$ZIPCODE"
}

temperature_select() {
    # Picks between °F ($1) and °C ($2), depending on the value of $CELSIUS
    if [ $CELSIUS -eq 1 ]; then
        echo $2
    else
        echo $1
    fi
}

current_conditions() {
    # Regex fields:
    # 1: current forecast (ex: light snow)
    # 2: temperature in °F (ex: 29)
    # 3: temperature in °C (ex: 2)
    # 4: humidity in % (ex: 69%)
    # 5: wind speed (ex: N 18 G 25 mpg)
    # 6: barometer (ex: 30.22 in (1024.0 mb))
    # 7: dewpoint in °F (ex: 20)
    # 8: depoint in °C (ex: -7)
    # 9: visibility (ex: 8.00 mi)
    # 11: wind chill in °F (ex: 17)
    # 12: wind chill in °C (ex: -8)
    # 13: location (ex: Notre Dame IN)
    SEARCHREGEX=$(cat <<EOF
.*
<div id="current_conditions-summary"
.*
<p class="myforecast-current">\s*([^<>]*)\s*</p>
.*
<p class="myforecast-current-lrg">\s*([^<>]*)&deg;F\s*</p>
.*
<p class="myforecast-current-sm">\s*([^<>]*)&deg;C\s*</p>
.*
<td class="text-right"><b>Humidity</b></td>\s*<td>([^<>]*)</td>
.*
<td class="text-right"><b>Wind Speed</b></td>\s*<td>([^<>]*)</td>
.*
<td class="text-right"><b>Barometer</b></td>\s*<td>([^<>]*)</td>
.*
<td class="text-right"><b>Dewpoint</b></td>\s*<td>([^<>]*)&deg;[CF]\s.([^<>]*)&deg;[CF].\s*</td>
.*
<td class="text-right"><b>Visibility</b></td>\s*<td>([^<>]*)</td>
(.*
<td class="text-right"><b>Wind Chill</b></td>\s*<td>([^<>]*)&deg;[CF]\s.([^<>]*)&deg;[CF].\s*</td>)?
.*
<b>Extended Forecast for</b>\s*<h2 class="panel-title">\s*([^<>]*[^<>\s])\s*</h2>
.*
EOF
)
    REPLACEREGEX=$(cat <<EOF
Location    \$13 $ZIPCODE
Temperature \$$(temperature_select "2°F" "3°C")
Wind Chill  \$$(temperature_select "11°F" "12°C")
Forecast    \$1
Wind Speed  \$5
Humidity    \$4
EOF
)
#Barometer: \$6
#Dewpoint: \$$(temperature_select "7°F" "8°C"),
#Visibility: \$9

    SEARCHREGEX=$(echo "$SEARCHREGEX" | tr -d '\n')
    tr '\n' ' ' | perl -pe "s|$SEARCHREGEX|$REPLACEREGEX\n|g" | sed -E '/^Wind Chill  °(F|C)$/d'
}

weekly_forecast() {
    sed -nE 's|.*title="([^"]*)" class="forecast-icon".*|\1|p' | sed -E -e 's|^(.*[nN]ight:.*)$|\1\n|gm' -e 's`^(This Afternoon|\w+( Night)?): (.*)$`\x1B[4m\1\x1B[0m: \3`g'
}

get_err_msg() {
    tr '\n' ' ' | perl -pe 's|.*<h4>([^<>]*).*|\1\n|g'
}

# Parse Command Line Options

while [ $# -gt 0 ]; do
    case $1 in
        -c) CELSIUS=1;;
        -h) usage 0;;
        -7) SEVENDAY=1;;
        [0-9][0-9][0-9][0-9][0-9]) ZIPCODE=$1;
                                   echo "$ZIPCODE" > "$DEFAULTZIPFILE";;
         *) usage 0;;
    esac
    shift
done

# Display Information
WEATHER_INFO=$(weather_information)

if echo $WEATHER_INFO | grep -qE 'An error has occurred in your search'; then
    echo "$WEATHER_INFO" | get_err_msg
    exit 1
fi

if [ $SEVENDAY -eq 1 ]; then
    echo "$WEATHER_INFO" | weekly_forecast
else
    echo "$WEATHER_INFO" | current_conditions
fi

