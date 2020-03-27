#!/usr/bin/env bash

function check_year()
{
    if [[ $[${year}%4] -eq 0 && $[${year}%100]  -ne 0 || $[${year}%400] -eq 0 ]]
    then
        return 0
    else
        return 1
    fi
}

function which_day()
{
    check_year
    if [ $? -eq 0 ]
    then
        days_of_month=(31 29 31 30 31 30 31 31 30 31 30 31)
    elif [ $? -eq 1 ]
    then
        days_of_month=(31 28 31 30 31 30 31 31 30 31 30 31)
    fi
    total=0
    for ((index=0;index<$[$month-1];index++))
    do
        let total+=${days_of_month[${index}]}
    done
}

year=`date +%Y-%m-%d|cut -d "-" -f 1`
month=`date +%Y-%m-%d|cut -d "-" -f 2`
day=`date +%Y-%m-%d|cut -d "-" -f 3`
which_day
echo "今天是${year}年${month}月${day}日，是${year}年的第$[${total}+${day}]天。"
