#!/bin/bash
function random()
{
    min=$1
    max=$[$2-$min+1]
    num=`date +%s%N`
    echo $[$num%$max+$min]
}
random_num=`random 1 100`
echo "The random  number is : $random_num"
