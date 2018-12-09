DOMAIN="tencent.com"
SEARCHDOMAIN=$(networksetup -getsearchdomains Wi-Fi)
isEmpty=$(echo $SEARCHDOMAIN | grep "There aren't any Search Domains set on")
if [[ "$result" == "" ]]
then
    sudo networksetup -setsearchdomains Wi-Fi $DOMAIN
else
    result=$(echo $SEARCHDOMAIN | grep "${DOMAIN}")
    if [[ "$result" == "" ]]
    then
    sudo networksetup -setsearchdomains Wi-Fi $SEARCHDOMAIN $DOMAIN
    fi
fi


