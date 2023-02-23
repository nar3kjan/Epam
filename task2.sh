#!/bin/bash

#create path to redirect output.json to same directory as output.txt
path=$(dirname $1)

#create variables for name line, test lines and result line
firstline=$(cat $1 | head -n +1 | cut -d "[" -f2 | cut -d "]" -f1)
testname=$(echo $firstline)

tests=$(cat $1 | tail -n +3 | head -n -2)

results=$(cat $1 | tail -n1)

#create main JSON variable
json=$(jq -n --arg tn "$testname" '{testname:$tn,tests:[],summary:{}}')

#test's names, status, duration and updating JSON variable
IFS=$'\n'
for i in $tests
do
    if [[ $i == not* ]]
    then
        stat=false
    else
        stat=true
    fi

    if [[ $i =~ expecting(.+?)[0-9] ]]
    then
        var=${BASH_REMATCH[0]}
        name=${var%,*}
    fi

    if [[ $i =~ [0-9]*ms ]]
    then
        test_duration=${BASH_REMATCH[0]}
    fi

    json=$(echo $json | jq \
        --arg na "$name" \
        --arg st "$stat" \
        --arg dur "$test_duration" \
        '.tests += [{name:$na,status:$st|test("true"),duration:$dur}]')
done

#final success, failed, rating, duration and finishing JSON variable

IFS=$'\n'
for l in $results
do
    if [[ $l =~ [0-9]+ ]]
    then
        success=${BASH_REMATCH[0]}
    fi

    if [[ $l =~ ,.[0-9]+ ]]
    then
        v=${BASH_REMATCH[0]}
        failed=${v:2}
    fi

    if [[ $l =~ [0-9]+.[0-9]+% ]] || [[ $l =~ [0-9]+% ]]
    then
        va=${BASH_REMATCH[0]}
        rating=${va%%%}
    fi

    if [[ $l =~ [0-9]*ms ]]
    then
        duration=${BASH_REMATCH[0]}
    fi

    json=$(echo $json | jq \
                --arg suc "$success" \
                --arg fa "$failed" \
                --arg rat "$rating" \
            --arg dur "$duration" \
            '.summary += {success:$suc|tonumber,failed:$fa|tonumber,rating:$rat|tonumber,duration:$dur}')
done

#redirect variable's output to file
echo $json | jq "." > $path"/output.json"
