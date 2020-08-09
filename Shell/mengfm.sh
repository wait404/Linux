#!/usr/bin/env bash

function get_total_integral()
{
    while true
        read -p '请输入等级：' total_level
    do
        if grep '^[[:digit:]]*$' <<< ${total_level} &>/dev/null && [[ ${total_level} -gt 0 && ${total_level} -le 100 ]]
        then
            break
        else
            echo "输入错误，请重新输入。"
            continue
        fi
    done
    total_integral=0
    for ((i=1;i<${total_level};i++))
    do
        tmp_integral=$[${i}*10+5]
        total_integral=$[${total_integral}+${tmp_integral}]
    done
}

function get_level_integral()
{
    get_total_integral
    echo "升级至${total_level}级所需积分为：${total_integral}"
}

function update_level_integral()
{
    while true
    do
        read -p '请输入积分：' current_integral
        if grep '^[[:digit:]]*$' <<< ${current_integral} &>/dev/null && [[ ${current_integral} -ge 0 ]]
        then
            get_total_integral
            need_integral=$[${total_integral}-${current_integral}]
            if [[ ${need_integral} -gt 0 ]]
            then
                echo "升至${total_level}级需要的积分为：${need_integral}"
                break
            else
                echo "您已达到此等级"
                break
            fi
        else
            echo "输入错误，请重新输入。"
            continue
        fi
    done
}

function get_integral_level()
{
    while true
    do
        read -p '请输入积分：' current_integral
        if grep '^[[:digit:]]*$' <<< ${current_integral} &>/dev/null && [[ ${current_integral} -ge 0 ]]
        then
            total_integral=0
            total_level=1
            while true
            do
                tmp_integral=$[${total_level}*10+5]
                total_integral=$[${total_integral}+${tmp_integral}]
                if [[ ${total_integral} -le ${current_integral} ]]
                then
                    let total_level++
                else
                    if [ ${total_level} -ge 100 ]
                    then
                        echo "当前等级为：100"
                        break 2
                    else
                        echo "当前等级为：${total_level}"
                        break 2
                    fi
                fi
            done
        else
            echo "输入错误，请重新输入。"
            continue
        fi
    done
}

choise_menu=(
查询等级积分
查询升级所需积分
查询积分等级
)
while true
do
    for ((m=1;m<=${#choise_menu[@]};m++))
    do
        tmp_menu="${choise_menu[$m-1]}"
        echo "$m) ${tmp_menu}"
    done
    read -p '请选择：' choise_num
    if grep '^[[:digit:]]*$' <<< ${choise_num} &>/dev/null && [[ ${choise_num} -ge 1 && ${choise_num} -le ${#choise_menu[@]} ]]
    then
        break
    else
        echo "输入错误，请重新输入。"
        continue
    fi
done
case ${choise_num} in
    1)
        get_level_integral
        ;;
    2)
        update_level_integral
        ;;
    3)
        get_integral_level
        ;;
esac
