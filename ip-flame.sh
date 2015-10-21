#!/bin/bash
# create whitelist (CSV) from whitelist.txt:
# using AWK and SED because QAWK programming is about as ugly as Perl with sigils.
log=$(egrep '^web-log' config-ip-flame.txt|sed -re 's/[^=]+=//')
printf "[ + ] WWW log location: $log\n"
path="$(egrep '^web-path' config-ip-flame.txt|sed -re 's/[^=]+=//')flamed-ips.html"
printf "[ + ] Using web-host path: $path\n"
whitelist=$(awk -vORS='' 'BEGIN {i=0}{if($1 ~ /^[0-9]/) a[$i]=$1 }END{for(j in a){print j"|"}}' whitelist.txt|sed -re 's/\|$//')
printf "[ + ] Generated IP white list: $whitelist\n"
offlines=$(egrep '^offending-lines' config-ip-flame.txt|sed -re 's/[^=]+=//')
printf "[ + ] Matching offending lines: $offlines\n"
# dump in top of HTML page, this initiates and overwrites:
cat templates/top.html > flamed-ips.html
shodan="<a title='Search Shodan for devices hosted by $ip' href='https://www.shodan.io/search?query="
shodan2="' target='_blank'>Shodan</a>"
spamcop="<a title='SpamCop.net - report $ip for Spam violation' target='_blank' href='https://www.spamcop.net/w3m?action=checkblock&ip="
spamcop2="'>SpamCop</a>"
infobyip="<a title='Detailed information for $ip' href='http://www.infobyip.com/ip-"
infobyip2=".html' target='_blank'>InfoByIp</a>"
sophos="<a title='Sophos Security' href='https://www.sophos.com/en-us/threat-center/ip-lookup.aspx?ip="
sophos2="' target='_blank'>Sophos</a>"
arin="<a title='American Registry for Internet Numbers - $ip' target='_blank' href='http://whois.arin.net/rest/nets;q="
arin2="?showDetails=true&showARIN=false&showNonArinTopLevelNet=false&ext=netref2'>ARIN</a>"
apnic="<a title='APNIC JSON Data for $ip' target='_blank' href='https://wq.apnic.net/whois-search/query?searchtext="
apnic2="'>APNIC</a>"
# run command:
n=0; # record counting
lines=($(egrep "$offlines" $log | awk '{print $1}'|egrep -v "($whitelist)"| sort -u))
for ip in "${lines[@]}"
	do
		echo -e "\t\t <tr><td class='count'>$n</td><td>$ip</td><td>$arin$ip$arin2</td><td>$apnic$ip$apnic2</td><td>$infobyip$ip$infobyip2</td><td>$spamcop$ip$spamcop2</td><td>$sophos$ip$sophos2</td><td>$shodan$ip$shodan2</td></tr>" >> flamed-ips.html
		n=$((n+1)) # expansion and increment
	done;
# dump in bottom of HTML page:
cat templates/bottom.html >> flamed-ips.html
cp flamed-ips.html $path
printf "[ + ] HTML file generation completed and stored in $path\n"
