#!/bin/bash

#create path to redirect accounts.csv to same directory as accounts_new.csv
path=$(dirname $1)

awk '
BEGIN { FS="\""; OFS="," }                              # input is delimited by double qutoes
NR==1 { print; next }
      { line=""
        for (i=1;i<NF;i+=2) {                           # loop through odd numbered fields
            gsub(/,/,"|",$(i+1))                        # in even numbered double-quote-delimited fields replace commas with pipes
            line=line $i FS $(i+1) FS                   # rebuild the current line
        }
        line=line $NF                                   # add last field to new line

        split(line,a,",")                               # split new line on commas
        split(tolower(a[3]),b,/[[:space:]]+/)           # split tolower(name field) on white space

        # rebuild name with first characters of first/last names uppercased

        name=toupper(substr(b[1],1,1)) substr(b[1],2) " " toupper(substr(b[2],1,1)) substr(b[2],2)

        acct=substr(b[1],1,1) b[2]                      # build email acct name

        lines[NR]=a[1] OFS a[2] OFS name OFS a[4]       # rebuild current line based on first 4 fields
        locid[NR]=a[2]                                  # make note of location_id for current line
        dept[NR]=a[6]
        email[NR]=acct                                  # make note of email acct for current line
        count[acct]++                                   # keep count of number of times we see this email acct
      }

END   { for (i=2;i<=NR;i++) {                           # loop through our lines of output
            gsub(/\|/,",",lines[i])                     # replace pipes with original commas

            # print final line of output; if email acct has been seen more than once then append the location_id to the email acct; add the "@abc.com" domain and the trailing comma

            print lines[i] OFS email[i] (count[email[i]] > 1 ? locid[i] : "") "@abc.com" OFS dept[i]
        }
      }' $1 > $path"/accounts_new.csv"