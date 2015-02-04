#!/bin/bash

#
# kano-screenshot-tests.sh
#
# Copyright (C) 2014, 2015 Computing Ltd.
# License: http://www.gnu.org/licenses/gpl-2.0.txt GNU General Public License v2
#
# Runs kano-screenshot through a number of unit tests
# The script must be run on the RaspberryPI.
#

# Turn off error checking so we run and report through all tests
set +e

# Handy placeholder to call the kano-screenshot tool
ks=$(which kano-screenshot)
vcgencmd=$(which vcgencmd)

# Test function which asserts that the execution of $1 returns the subliteral $2,
# with a short message explaining the test titled $3.
function kassert()
{
    $1 | grep "$2" > /dev/null 2>&1
    if [ "$?" == "0" ]; then
        echo "Test passed: $3"
        return 0
    else
        echo "Test failed: $3 ('$1' does not contain: '$2')"
        return 1
    fi
}

# Start test: Remove all png test files from a previous test
rm test*png

# width and height mode tests
`$ks -w 320 -p test10.png`
kassert "file test10.png" "320" "width mode"
`$ks -h 200 -p test11.png`
kassert "file test11.png" "200" "height mode"
`$ks -w 320 -h 200 -p test12.png`
kassert "file test12.png" "320 x 200" "width/height mode"

# fullscreen mode test
# TODO: compare with "tvservice" to tell us the real display resolution
#`$ks -p test5.png`

# cropping
`$ks -c 10,10,175,300 -p test20.png`
kassert "file test20.png" "175 x 300" "even coordinates cropping mode"
`$ks -c 101,103,302,408 -p test21.png`
kassert "file test21.png" "302 x 408" "odd coordinates cropping mode"

echo "Warning: The tests below require the XServer running"

# application mode
wtitle="Kano Screenshot Test"
zenity --info --text "kano screenshot test application" --title "$wtitle"  --timeout=5 --width=150 --height=350 &
sleep 3
`$ks -a "$wtitle" -p test30.png`

# make sure the application screenshot is equal or greater than zenity dialog size (window decorations)
kassert "file test30.png" "1[5-9][0-9] x 3[5-9][0-9]" "application cropping mode"

# list applications
windowlist=`$ks -l`
kassert "echo \"$windowlist\"" "Window id" "list XServer applications"

