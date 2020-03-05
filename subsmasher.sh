#!/usr/bin/env bas

if [ ! -x "$(command -v jq)" ]; then
	echo "[-] This script requires jq. Exiting."
	exit 1
fi
echo


echo "	  _________    ___.                                .__                  "
echo "	 /   _____/__ _\_ |__   ______ _____ _____    _____|  |__   ___________ "
echo "	 \_____  \|  |  \ __ \ /  ___//     \\__  \  /  ___/  |  \_/ __ \_  __ \ "
echo "	 /        \  |  / \_\ \\___ \|  v v  \/ __ \_\___ \|   v  \  ___/|  | \/ "
echo "	/_______  /____/|___  /____  >__|_|  (____  /____  >___|  /\___  >__|   "
echo "  --     	\/          \/     \/      \/     \/     \/     \/     \/------- "
echo
echo

echo "Warning.. if you don't have amass, subfinder, and sublist3r in some kind of command this will not work. Adjust it so it does or refer to the code "
echo "---------------------------------------------------------------------------------------------------------------------------------------------------- "
echo

certdata(){
		echo "Lets get some of that Certs data first "
		echo "------------------------------------------ "
		echo
		crtsh=$(curl -s https://crt.sh/\?q\=%25.$1\&output\=json | jq -r '.[].name_value' | sed 's/\*\.//g' | sort -u | tee -a rawdata/$1-crtsh.txt)
		#get a list of domains from certspotter
		certspotter=$(curl -s https://certspotter.com/api/v0/certs\?domain\=$1 | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep -w $1\$ | tee rawdata/$1-certspotter.txt)
		#get a list of domains from digicert
		#digicert=$(curl -s https://ssltools.digicert.com/chainTester/webservice/ctsearch/search?keyword=$1 -o rawdata/$1-digicert.json)
		echo " Lets do some amass!!I know why?? it takes to long but I just like it "
		echo "-------------------------------------------------------------------------------- "
		echo
		am=$(amass intel -whois -d $1 | tee rawdata/$1-am.txt)
		echo
		echo "Next Subfinder "
		echo "------------------- "
		echo
		sub=$(subfinder -d $1 -o rawdata/$1-sub.txt)
		echo
		echo "And now Sublister!! "
		echo "---------------------- "
		echo
		subl=$(python ~/tools/Sublist3r/sublist3r.py -d $1 -o rawdata/$1-subl.txt)
		#echo "$crtsh"
		#echo "$certspotter"
		#echo "$digicert"
}


rootdomains() { #this creates a list of all unique root sub domains
	cat rawdata/$1-crtsh.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | grep -v '@' | grep -v '<br>' > ./$1-temp.txt
	cat rawdata/$1-certspotter.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | grep -v '@' | grep -v '<br>' >> ./$1-temp.txt
	cat rawdata/$1-amass.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | grep -v '@' | grep -v '<br>' >> ./$1-temp.txt >> ./$1-temp.txt
	cat rawdata/$1-subfinder.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | grep -v '@' | grep -v '<br>' >> ./$1-temp.txt
	cat rawdata/$1-sublist3r.txt | rev | cut -d "."  -f 1,2,3 | sort -u | rev | grep -v '@' | grep -v '<br>' >> ./$1-temp.txt
	cat $1-temp.txt | tr '[:upper:]' '[:lower:]' | sort -u | tee ./data/$1-$(date "+%Y.%m.%d-%H.%M").txt; rm $1-temp.txt
	echo "[+] Number of domains found: $(cat ./data/$1-$(date "+%Y.%m.%d-%H.%M").txt | wc -l)"
}


certdata $1
rootdomains $1
