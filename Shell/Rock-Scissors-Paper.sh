#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

function get_char()
{
    SAVEDSTTY=`stty -g`
    stty -echo
    stty cbreak
    dd if=/dev/tty bs=1 count=1 2> /dev/null
    stty -raw
    stty echo
    stty $SAVEDSTTY
}
echo "按任意键开始游戏或Ctrl+C退出游戏。"
cmd=`get_char`
while true
do
    echo "游戏开始。"
    roll_type=("石头" "剪子" "布")
    while true
    do
        for ((i=1;i<=${#roll_type[@]};i++))
        do
            roll_menu="${roll_type[$i-1]}"
            echo "$i) $roll_menu"
        done
        read -s -p "我方出：" roll
        case $roll in
            1)
                echo "石头"
                break
                ;;
            2)
                echo "剪子"
                break
                ;;
            3)
                echo "布"
                break
                ;;
            *)
                echo -e "${red}选择错误,请重新选择。${plain}"
                continue
        esac
    done
    random_num=`date +%s%N`
    roll_num=$[$random_num%3+1]
    case $roll_num in
        1)
            echo -e "对方出：石头"
            if [ $roll -eq 1 ]
            then
                echo -e "${yellow}平局。${plain}"
            elif [ $roll -eq 2 ]
            then
                echo -e "${red}很遗憾，你输了。${plain}"
            elif [ $roll -eq 3 ]
            then
                echo -e "${green}恭喜你，你赢了。${plain}"
            fi
            ;;
        2)
            echo -e "对方出：剪子"
            if [ $roll -eq 1 ]
            then
                echo -e "${green}恭喜你，你赢了。${plain}"
            elif [ $roll -eq 2 ]
            then
                echo -e "${yellow}平局。${plain}"
            elif [ $roll -eq 3 ]
            then
                echo -e "${red}很遗憾，你输了。${plain}"
            fi
            ;;
        3)
            echo -e "对方出：布"
            if [ $roll -eq 1 ]
            then
                echo -e "${red}很遗憾，你输了。${plain}"
            elif [ $roll -eq 2 ]
            then
                echo -e "${green}恭喜你，你赢了。${plain}"
            elif [ $roll -eq 3 ]
            then
                echo -e "${yellow}平局。${plain}"
            fi
            ;;
    esac
    echo
done
