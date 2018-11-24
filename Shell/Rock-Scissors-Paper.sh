#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

roll_round=1
roll_integral=10000
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
echo
echo -e "${red}提示：初始积分为10000积分，每次下注不得少于100积分。${plain}"
echo
while true
do
    echo "第$roll_round回合，游戏开始。"
    while true
    do
        read -p "请输入赌注：" roll_bet
        if [[ $roll_bet -lt 100 || $roll_bet -gt $roll_integral ]]
        then
            echo -e "${red}赌注不得小于100不得大于$roll_integral，请重新输入。${plain}"
            continue
        else
            break
        fi
    done
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
                echo "你还有$roll_integral积分。"
            elif [ $roll -eq 2 ]
            then
                roll_integral=$[$roll_integral-$roll_bet]
                echo -e "${red}很遗憾，你输了。${plain}"
                echo "扣除你$roll_bet积分，你还有$roll_integral积分。"
            elif [ $roll -eq 3 ]
            then
                roll_integral=$[$roll_integral+$roll_bet]
                echo -e "${green}恭喜你，你赢了。${plain}"
                echo "奖励你$roll_bet积分，你还有$roll_integral积分。"
            fi
            ;;
        2)
            echo -e "对方出：剪子"
            if [ $roll -eq 1 ]
            then
                roll_integral=$[$roll_integral+$roll_bet]
                echo -e "${green}恭喜你，你赢了。${plain}"
                echo "奖励你$roll_bet积分，你还有$roll_integral积分。"
            elif [ $roll -eq 2 ]
            then
                echo -e "${yellow}平局。${plain}"
                echo "你还有$roll_integral积分。"
            elif [ $roll -eq 3 ]
            then
                roll_integral=$[$roll_integral-$roll_bet]
                echo -e "${red}很遗憾，你输了。${plain}"
                echo "扣除你$roll_bet积分，你还有$roll_integral积分。"
            fi
            ;;
        3)
            echo -e "对方出：布"
            if [ $roll -eq 1 ]
            then
                roll_integral=$[$roll_integral-$roll_bet]
                echo -e "${red}很遗憾，你输了。${plain}"
                echo "扣除你$roll_bet积分，你还有$roll_integral积分。"
            elif [ $roll -eq 2 ]
            then
                roll_integral=$[$roll_integral+$roll_bet]
                echo -e "${green}恭喜你，你赢了。${plain}"
                echo "奖励你$roll_bet积分，你还有$roll_integral积分。"
            elif [ $roll -eq 3 ]
            then
                echo -e "${yellow}平局。${plain}"
                echo "你还有$roll_integral积分。"
            fi
            ;;
    esac
    let roll_round++
    if [ $roll_integral -lt 100 ]
    then
        echo
        echo -e "${red}积分不足，游戏结束。${plain}"
        exit 0
    fi
    echo
done
