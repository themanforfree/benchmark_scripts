local=$(curl -s ifconfig.me)
echo $local
if [[ $local != "182.118.236.149" ]]; then
    echo tttt
fi
