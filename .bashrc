# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Source nexcess functions
if [ -f /etc/nexcess/bash_functions.sh ]; then
        . /etc/nexcess/bash_functions.sh
fi

export PATH=$PATH:/usr/local/sbin:/sbin:/usr/sbin:/var/qmail/bin/:/usr/nexkit/bin
export GREP_OPTIONS='--color=auto'
export PAGER=/usr/bin/less

# formatted at 2000-03-14 03:14:15
export HISTTIMEFORMAT="%F %T "

if [ -e /usr/bin/vim ]; then
    export EDITOR=/usr/bin/vim
    export VISUAL=/usr/bin/vim
else
    export EDITOR=/bin/vi
    export VISUAL=/bin/vi
fi

# lulz
alias rtfm=man

# protect myself from myself
alias rm='rm --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# With -F, on listings append the following
#    '*' for executable regular files
#    '/' for directories
#    '@' for symbolic links
#    '|' for FIFOs
#    '=' for sockets
alias ls='ls -F --color=auto'

# only append to bash history to prevent it from overwriting it when you have
# multiple ssh windows open
shopt -s histappend
# save all lines of a multiple-line command in the same history entry
shopt -s cmdhist
# correct minor errors in the spelling of a directory component
shopt -s cdspell
# check the window size after each command and, if necessary, updates the values of LINES and COLUMNS
shopt -s checkwinsize

txtblk='\[\e[0;30m\]' # Black - Regular
txtred='\[\e[0;31m\]' # Red
txtgrn='\[\e[0;32m\]' # Green
txtylw='\[\e[0;33m\]' # Yellow
txtblu='\[\e[0;34m\]' # Blue
txtpur='\[\e[0;35m\]' # Purple
txtcyn='\[\e[0;36m\]' # Cyan
txtwht='\[\e[0;37m\]' # White
bldblk='\[\e[1;30m\]' # Black - Bold
bldred='\[\e[1;31m\]' # Red
bldgrn='\[\e[1;32m\]' # Green
bldylw='\[\e[1;33m\]' # Yellow
bldblu='\[\e[1;34m\]' # Blue
bldpur='\[\e[1;35m\]' # Purple
bldcyn='\[\e[1;36m\]' # Cyan
bldwht='\[\e[1;37m\]' # White
unkblk='\[\e[4;30m\]' # Black - Underline
undred='\[\e[4;31m\]' # Red
undgrn='\[\e[4;32m\]' # Green
undylw='\[\e[4;33m\]' # Yellow
undblu='\[\e[4;34m\]' # Blue
undpur='\[\e[4;35m\]' # Purple
undcyn='\[\e[4;36m\]' # Cyan
undwht='\[\e[4;37m\]' # White
txtrst='\[\e[0m\]'    # Text Reset

if [ $UID = 0 ]; then
    # nexkit bash completion
     if [ -e '/etc/bash_completion.d/nexkit' ]; then
         source /etc/bash_completion.d/nexkit
     fi
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][${bldred}\u${txtrst}@\h \W]\$ "
else
    PS1="[${txtcyn}\$(date +%H%M)${txtrst}][\u@\h \W]\$ "
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
if [ -f /etc/bashrc.nexcess ]; then
        . /etc/bashrc.nexcess
fi

# User specific aliases and functions

# Disk Quotas
quotas ()
{
echo; for _user_ in $(grep -E ":/home/[^\:]+:" /etc/passwd | cut -d\: -f1); do echo -n
$_user_; quota -g $_user_ 2>/dev/null| perl -pe 's,\*,,g' | tail -n+3 | awk '{print "
"$2/$3*100,$2/1000/1024,$3/1000/1024}'; echo; done | grep '\.' | sort -grk2 | awk
'BEGIN{printf "%-15s %-10s %-10s %-10s\n","User","% Used","Used (G)","Total (G)"; for (x=1;
x<50; x++) {printf "-"}; printf "\n"} {printf "%-15s %-10.2f %-10.2f
%-10.2f\n",$1,$2,$3,$4}'; echo
}

# Find the backupserver
backupsvr ()
{
echo -e "\n$(if [[ -e /var/db/buagent/serverurl ]]; then cat /var/db/buagent/serverurl; else
echo "https://$(host $(grep -Ei '/usr/sbin/r1soft/conf/server.allow/'
/usr/sbin/r1soft/log/cdp.log | awk -F/ '{print $NF}' | cut -d\' -f1 | grep -Pi "\d" | tail
-n1) | awk '{print $NF}' | perl -pe 's,\.$,,'):8001"; fi)\n"
}

###### END NEXCESS SPECIFIC ALIASES AND FUNCTIONS #######

###### BEGIN MY ALIASES AND FUNCTIONS ######

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"


# Create X mb file for testing purposes

function crapfile ()
{
    dd if=/dev/urandom of=$1 bs=1M count=$2
    md5sum $1 >> $1.md5
}


# Because http://xkcd.com/1168/
function compress ()
{
if [ $1 == "--help" }
then
  echo "$txtblu The syntax is compress archivename.tar.gz /path/to/compress $txtrst"
  return 1
fi

if [[ -z $1 ]]
then
  echo "$txtred You must specify an archive name $txtrst"
  return 1
fi

if [[ -z $2 ]]
then
  echo "$txtred You must specify a path or file to compress $txtrst"
  return 1
fi

    tar -cvzf $1 $2
}


# Move up X Directories - because I HATE ../../../..
function up ()
{
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}


# Because http://xkcd.com/1168/
function extract ()
{
    if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       rar x $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjf $1      ;;
             *.tgz)       tar xzf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}


# icanhazip - finds your current IP if you're connected to the internet
function icanhazip ()
{
lynx -dump -hiddenlinks=ignore -nolist http://checkip.dyndns.org:8245/ | awk '{ print $4 }' | sed '/^$/d; s/^[ ]*//g; s/[ ]*$//g'
}


# CP with a progress bar
function cp_p ()
{
   set -e
   strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
      | awk '{
        count += $NF
            if (count % 10 == 0) {
               percent = count / total_size * 100
               printf "%3d%% [", percent
               for (i=0;i<=percent;i++)
                  printf "="
               printf ">"
               for (i=percent;i<100;i++)
                  printf " "
               printf "]\r"
            }
         }
         END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}


# Do I really need to explain this?
function randpw ()
{
< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;
}


# Get Chain Certificate (Cause I'm a lazy bastard)
function getcc ()
{
printf "/n"| openssl s_client -showcerts -connect $1:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }'
printf "/n"| openssl s_client -showcerts -connect $1:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }' > /home/$USER/$1_chaincert.txt
}


# Because I keep fucking up SSH password issues.
function nxssh ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a user! $txtrst"
        return 1
fi

usermod -G sshusers $1 && usermod -s /bin/bash $1 && mkpasswd -l 12 $1 && pam_tally2 -u $1 -r
}


# Get Magento package direct download link based on version
function getmage ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a version number $txtrst"
        return 1
fi

if [ $1 == "--help"}
then
        echo "$txtblu The syntax of this command is getmage version, ex: 1.9.0.1 $txtrst"
        return 1
fi

echo "http://www.magentocommerce.com/downloads/assets/$1/magento-$1.tar.gz"
}


# Show all domains configured for user
function showAllDomains ()
{
nodeworx -u -n --controller Reseller --action listIds |
while read line; do
    echo -e "\n$line";
    IDNUM=$(echo $line | awk '{print $1}');
    nodeworx -unc DnsZone -a listZones --nodeworx_id $IDNUM | sed "1 d" | awk '{print "--"$2}';
done;
}


# Add flush_memcached and flush_redis to user, add user to NC group
function addflush ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a user! $txtrst"
        return 1
fi
if [[ -z $2 ]]
then
	echo "$txtred You must specify a domain! $txtrst"
	return 1
fi

printf "alias flush_memcached='echo "flush_all" | nc -U /var/tmp/memcached.$1.$2_sessions.sock'\n" >> /home/$1/.bashrc
printf "alias flush_redis='echo "flushall" | nc -U /var/tmp/redis-multi_$1.$2_cache.sock'\n" >> /home/$1/.bashrc
usermod -a -G nc $1
}


# Shitty little function to source another user's .bashrc
function sourcebash ()
{
source /home/nex$1/.bashrc
}


# Lists user's quota usage
function userquota ()
{
echo; for _user_ in $(grep -E ":/home/[^\:]+:" /etc/passwd | cut -d\: -f1); do echo -n $_user_; quota -g $_user_ 2>/dev/null| perl -pe 's,\*,,g' | tail -n+3 | awk '{print " "$2/$3*100,$2/1000/1024,$3/1000/1024}'; echo; done | grep '\.' | sort -grk2 | awk 'BEGIN{printf "%-15s %-10s %-10s %-10s\n","User","% Used","Used (G)","Total (G)"; for (x=1; x<50; x++) {printf "-"}; printf "\n"} {printf "%-15s %-10.2f %-10.2f %-10.2f\n",$1,$2,$3,$4}'; echo
}


# Fixes WordPress permissions for specified path
function fixwpperms ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a path $txtrst"
        return 1
fi

find $1 -type d -exec chmod 2755 {} \; && find $1 -type f -exec chmod 644 {} \;
}


# Sets folder permissions to 755 in specified directory
function fixdirperms ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a path $txtrst"
        return 1
fi

find $1 -type d -print -exec chmod 755 {} \;
}


# Sets file permissions to 644 in specified directory
function fixfileperms ()
{
if [[ -z $1 ]]
then
        echo "$txtred You must specify a path $txtrst"
        return 1
fi

find $1 -type f -print -exec chmod 644 {} \;
}


# Enables gzip compression for specified user
function enablegzip ()
{
if [ $1 == "--help" ]
then
        echo "$txtred Syntax is enablegzip username, this will set up gzip for a user and reload php-fpm $txtrst"
        return 1
fi

echo "php_admin_value[zlib.output_compression] = on" >> /etc/php-fpm.d/$1.conf
service php-fpm reload
}


# Kills all processes for specified user
function killuser ()
{
getuid = `id -u $1`
if [ $1 ==  "root" ]
then
        echo "$txtred I SAID DO NOT F***ING USE ROOT! $txtrst"
        return 1
fi

if [ $1 ==  "toor" ]
then
        echo "$txtred I SAID DO NOT F***ING USE ROOT! $txtrst"
        return 1
fi

if [ $1 ==  "0" ]
then
        echo "$txtred I SAID DO NOT F***ING USE ROOT! $txtrst"
        return 1
fi

if [ $1 == "theadmin" ]
then
        echo "$txtred I SAID DO NOT F***ING USE ROOT! $txtrst"
        return 1
fi

if [ $getuid == 0 ]
then
        echo "$txtred User has root privileges, you cannot use this command! $txtrst"
        return 1
fi

if [ $1 == "--help" ]
then
        echo "$txtblu Syntax is killuser username process name (ex php), it will terminate all processes owned by that user. DO NOT USE ROOT OR UID 0! $txtrst"
        return 1
fi

if [[ -z $1 ]]
then
        echo "$txtred You must specify a user $txtrst"
        return 1
fi

if [[ -z $2 ]]
then
        echo "$txtred You must specify a process name $txtrst"
        return 1
fi

if [ $2 == "*" ]
then
        pgrep -u $1 | xargs kill -9
        echo "$txtred $1's processes killed $txtrst"
        return 1
fi

pgrep -u $1 $2 | xargs kill -9
echo "$txtred $1's $2 processes killed $txtrst"
}


#Search entire mysql db for string
function searchdb ()
{
m 2>&1 -e'show databases' &&
echo -n "Please enter a database name: "
read DB
echo -n "Enter search string: "
read SEARCHTERM
echo -e "Searching $DB for \"$SEARCHTERM\"\n"
for i in $(m 2>&1 -e"show tables from ${DB}" | sed -n '1!p'); do
    TABLENAME=$i;
    NORESULTS=1;
    genQuery="SELECT * FROM ${DB}.${TABLENAME}\G";
    echo "$genQuery" | m 2>&1 | if grep -q "$SEARCHTERM"; then
        NUMBER=$(echo "$genQuery" | m 2>&1 | grep "$SEARCHTERM" | awk -F':' '{print $1}' | tr -d ' ' | awk '{print $1}' | wc -l)
        echo "$NUMBER results found in table \"$TABLENAME\""
    fi;
done;
}


# Gets database size
function getDbSize ()
{
m -e'SELECT table_schema "Data Base Name", sum( data_length + index_length ) / 1024 / 1024 "Data Base Size in MB" FROM information_schema.TABLES where table_schema like "'$1'%" GROUP BY table_schema';
}


# Runs IP address check against major mail providers for blacklisting
function checkspam ()
{
echo; read -ep "IP ADDRESS: " _ip; for b in $_ip; do echo '++++++++++++++++++++++++++++'; echo $b;echo 'PHONE: 866-639-2377'; nslookup $b | grep addr;echo 'http://multirbl.valli.org/lookup/'$b'.html';echo 'http://www.senderbase.org/lookup/ip/?search_string='$b; echo 'https://www.senderscore.org/lookup.php?lookup='$b;echo '++++++++++++++++++++++++++++'; for x in hotmail.com yahoo.com aol.com earthlink.net verizon.net att.net comcast.net xmission.com cloudmark.com cox.net charter.net; do echo; echo $x;echo '--------------------'; swaks -q TO -t postmaster@$x -li $b| grep -iE 'block|rdns|550|521|554';done ;echo; echo 'gmail.com';echo '-----------------------'; swaks -4 -t iflcars.com@gmail.com -li $b| grep -iE 'block|rdns|550|521|554';echo; echo; done;
}


# Lists nameservers for current server
function nameservs ()
{
egrep '(ns1|ns2)' /home/interworx/iworx.ini
}


# Lists all databases
function listdbs ()
{
(for x in $(find /var/lib/mysql/ -maxdepth 1 -type d -name '*_*' | sed -e 's|_.*||' | sort | uniq); do mysqlusage=$(du -scBM $x* | awk 'END {print $1}'); mysqluser=$(basename $x); printf "%-9s $mysqlusage\n" $mysqluser; done; ) | sort -n -k2
}


# Lists top 20 IPs visiting site
function top20ip ()
{
if [ $1 == "--help" ]
then
  echo "$txtred Command must be run in /home/user/var/domain.com/logs/ $txtrst"
  return 1
fi

tail -5000 ./transfer.log | awk '{freq[$1]++} END {for (x in freq) {print freq[x], x}}' | sort -rn | head -20
}


# Lists hits per hour
function hitsperhour ()
{
if [ $1 == "--help" ]
then
  echo "$txtred Command must be run in /home/user/var/domain.com/logs/ $txtrst"
  return 1
fi

for x in $(seq -w 0 23); do echo -n "$x  "; grep -c "$(date +%d/%b/%Y:)$x" ./transfer.log; done;
}


# Sets UTF-8 Encoding in .htaccess for specified user and domain
function setutf8 ()
{
if [ $1 == "--help" ]
then
  echo "$txtblu yntax of command: setutf8 user domain.com $txtrst"
  return 1
fi

if [[ -z $1 ]]
then
  echo "$txtred You must specify a user! $txtrst"
  return 1
fi

if [[ -z $2 ]]
then
  echo "$txtred You must specify a domain! $txtrst"
  return 1
fi

echo "IndexOptions +Charset=UTF8" >> /home/$1/$2/html/.htaccess
}


# Grep error log for specified user and domain
function greperrlog ()
{
if [ $1 == "--help" ]
then
  echo "$txtblu Syntax of command: greperrlog user domain.com string $txtrst"
  return 1
fi

if [[ -z $1 ]]
then
  echo "$txtred You must specify a user! $txtrst"
  return 1
fi

if [[ -z $2 ]]
then
  echo "$txtred You must specify a domain! $txtrst"
  return 1
fi

if [[ -z $3 ]]
then
  echo "$txtred You must specify a search string! $txtrst"
  return 1
fi

cat /home/$1/var/$2/logs/error.log | grep $3
}


# Grep transfer log for specified user and domain
function greptranslog ()
{
if [ $1 == "--help" ]
then
  echo "$txtblu Syntax of command: greptranslog user domain.com string $txtrst"
  return 1
fi

if [[ -z $1 ]]
then
  echo "$txtred You must specify a user! $txtrst"
  return 1
fi

if [[ -z $2 ]]
then
  echo "$txtred You must specify a domain! $txtrst"
  return 1
fi

if [[ -z $3 ]]
then
  echo "$txtred You must specify a search string! $txtrst"
  return 1
fi

cat /home/$1/var/$2/logs/transfer.log | grep $3
}


# Shamelessly stolen from menders
function servercond ()
{
    printf '\E[35m'"\033[1mWho is on, Load, Uptime:\033[0m\n"
        w
            star 15; star 15
    printf '\E[35m'"\033[1mMemory Usage:\033[0m\n"
        free -m
            star 15; star 15
    printf '\E[35m'"\033[1mWho is using the resources:\033[0m\n"
        printf "%-15s%-15s%-10s%-10s%-10s\n" "User" "Memory (MB)" "Procs" "%CPU" "%MEM"
        ps aux |awk '{ mem[$1]+=$6; procs[$1]+=1; pcpu[$1]+=$3; pmem[$1]+=$4; } END { for (i in mem) { printf "%-15s%-15.2f%-10d%-10.1f%-10.1f\n", i, mem[i]/(1024), procs[i], pcpu[i], pmem[i] } }' |sort -nrk4,4 |head
            star 15; star 15
    printf '\E[35m'"\033[1mDisk Space and Inode Usage:\033[0m\n"
        for ((i=1 ; i<=$(df | wc -l) ; i++))
        do
            echo -n "$(df -h | head -n$i | tail -n1 | awk '{print $1,$2,$3,$4,$5}') | "
            df -i | head -n$i | tail -n1 | sed 's/ounted on/ounted_on/g' | awk '{print $2,$3,$4,$5,$6}'
        done |column -t
            star 15; star 15
    printf '\E[35m'"\033[1mhttpd\033[0m"
        for _a in $(pidof httpd |awk '{print $NF}')
        do
            ps -p $_a -o lstart
        done
        printf "Running httpd Processes: $(pidof httpd |wc -w)\n"
            star 15; star 15
    printf '\E[35m'"\033[1mphp-fpm\033[0m"
        for _p in $(pidof php-fpm |awk '{print $NF}')
        do
            ps -p $_p -o lstart
        done
        printf "Running php-fpm Processes: $(pidof php-fpm |wc -w)\n"
            star 15; star 15
    printf '\E[35m'"\033[1mmysqld\033[0m"
        for _m in $(pidof mysqld |awk '{print $NF}')
        do
            ps -p $_m -o lstart
        done
        printf "Current DB Connections: $( netstat -ulantp |grep -c :3306)\n"
            star 15; star 15
    printf '\E[35m'"\033[1mApache MaxClients:\033[0m\n"
        printf "$(grep -i maxc /var/log/httpd/error_log |cut -d " " -f2,3,4,6,8,9 |grep "$(date '+%b %d')")\n"
            star 15; star 15
    printf '\E[35m'"\033[1mphp-fpm max_children:\033[0m\n"
        printf "$(grep -i max_c /var/log/php-fpm/error.log |cut -d " " -f1,2,3,5,7,8 |sed -e 's/]//g' -e 's/\[//g' |grep "$(date +%d-%b-%Y)")\n"
            star 15; star 15
    printf '\E[35m'"\033[1mMail Info:\033[0m\n"
        qmqtool -s
}


# Dump the crap in my home directory [intended to be called from other functions]
function clearhome ()
{
rm -r /home/nexdworsey/*
}

# Whitelist SSH and MySQL
function whitelist ()
{
if [ $1 == "--help" ]
then
    echo "$txtblu Syntax: whitelist --s for SSH, --m for MySQL, IP address $txtrst"
    return 1
fi

if [[ -z $1 ]]
then
    echo "$txtred syntax: whitelist --s for SSH, --m for MySQL, IP address $txtrst"
    return 1
fi

if [ $1 == "--s" ]
then
    echo "d=22:s=$2" >> /etc/apf/allow_hosts.rules
    service apf restart
fi

if [ $1 == "--m" ]
then
    echo "d=3306:s=$2" >> /etc/apf/allow_hosts.rules
    service apf restart
fi
}


# Install SSL Chain Cert
function fixchain ()
{
if [[ -z $1 ]]
then
    echo "$txtred You must specify a username $txtrst"
    return 1
fi

if [[ -z $2 ]]
then
    echo "$txtred You must specify a domain $txtrst"
    return 1
fi

if [ $1 == "--help" ]
then
    echo "$txtblu Syntax: fixchain username domain. Copies the existing chain certificate file to the user's home directory and replaces the file with the proper chain certificate $txtrst"
    return 1
fi

cp /home/$1/var/$2/ssl/$2.chain.crt /home/$1
printf "/n"| openssl s_client -showcerts -connect $2:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }' > /home/$1/var/$2/ssl/$2.chain.crt
echo "$txtgrn Original chain certificate copied to /home/$1/$2.chain.crt. New chain certificate installed in /home/$1/var/$2/ssl/$2.chain.crt $txtrst"
}

# Clone of Networking4All's site checker
function checkssl ()
{
printf "$txtpur Expiry date: \n $txtrst"
printf "/n" | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -dates | awk -F= ' /notAfter/ { printf("%s\n",$NF); } '
printf "\n"

printf "$txtpur Issuer: \n $txtrst"
printf "/n" | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -issuer | tr '/' '\n' | grep CN= | cut -c4-
printf "\n"

printf "$txtpur Issued to: \n $txtrst"
issuedto=`echo "q\n" | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -subject | tr '/' '\n' | grep CN= | cut -c4-`

if [ $issuedto == $1 ]
then
        echo -e "$txtblu $1 $txtrst Site is listed in certificate"
        #printf "/n" | openssl s_client -connect $1:443 >>/dev/null #| openssl x509 -noout -subject | tr '/' '\n' | grep CN= | cut -c4-
fi

if [ $issuedto != $1 ]
then
        echo -e "$txtred $1 Site is NOT listed in certificate! $txtrst"
fi

printf "\n"
printf "$txtpur Subject Alternative Names: \n $txtrst"
printf "/n" | openssl s_client -connect $1:443 2>/dev/null | openssl x509 -noout -text | awk '/X509v3 Subject Alternative Name/ {getline;gsub(/ /, "", $0); print}' | tr -d "DNS:"

printf "\n"
read -ep "$txtpur Do you want to [v]iew the chain cert or put it in a [f]ile (You may also answer [n]o)? $txtrst" viewcert

if [ $viewcert == "view" ]
then
        printf "\n"
        printf "/n"| openssl s_client -showcerts -connect $1:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }'
        printf "\n\n"
fi

if [ $viewcert == "f" ]
then
        read -ep "Specify the path where you wish to store the file: " chaincertpath
        printf "\n"
        printf "/n"| openssl s_client -showcerts -connect $1:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }' > $chaincertpath/$1.chain.crt
        printf "Chain cert file has been placed in $chaincertpath/$1.chain.crt"
        printf "\n\n"
fi

if [ $viewcert == "file" ]
then
        read -ep "Specify the path where you wish to store the file: " chaincertpath
        printf "\n"
        printf "/n"| openssl s_client -showcerts -connect $1:443 2>/dev/null | awk '/----BEGIN CERTIFICATE----/ { flag = 1; ++ctr } flag && ctr >= 2 { print } /-----END CERTIFICATE-----/ { flag = 0 }' > $chaincertpath/$1.chain.crt
        printf "Chain cert file has been placed in $chaincertpath/$1.chain.crt"
        printf "\n\n"
fi

if [ $viewcert == "n" ]
then
        return 1
fi

if [ $viewcert == "no" ]
then
        return 1
fi
}


function killqueries
{
echo -n "Which user are we killing queries for?: "
read USER
echo -n "Kill queries older than X seconds (leave blank for all queries): "
read TIME
if [ -z $USER ];
        then echo -e "$txtred ERROR: User not found $txtrst";
        return 1;
else
        if [ -z $TIME ];
                then
                mytop -b |
                grep $USER |
                awk '{print $2}' |
                while read line;
                        do m -e'kill '$line'' &&
                        echo "Killed process $line";
                done;

        else
                mytop -b |
                grep $USER |
                awk -v VAR=$TIME '{if ($6 >= VAR) {
print $2,$6}; }' |
                while read line;
                        do m -e'kill '$line'' &&
                        echo "Killed process $line";
                done;
        fi;
fi;
}

psa ()
{
if [[ $1 ]]
then
        echo "$bldred You must enter a search string! $txtrst"
        return 1
fi

ps aux | grep $1
}

function nkhtpass
{
#Use : nkhtpass <Path_for_htpasswd_file> <Username>

#Location variable for the .htpasswd file
HTPASSLOCATION="${1%/}/.htpasswd";

#Create the password
HTPASS_PASS=$(mkpasswd -l 10);

#Set the Error code
ERRORCODE=0;

if [ -z $HTPASSLOCATION ];
then
    	echo -e "$bldred Error: Missing path\n--Please specify a path where you want the .htpasswd file to be generated/modified $txtrst"
        exit 1;
else
    	if [ -e $HTPASSLOCATION ];
        then
            	#Check to see if the user already exists
                if grep -q "$2" $HTPASSLOCATION;
                then
                    	echo -e "$bldred Error: User \"$2\" already exists.\n--Please select a different username\n $txtrst";

               else
                    	#As long as the user does not already exist, add a new user to the already existing .htaccess file
                        htpasswd -b $HTPASSLOCATION $2 $HTPASS_PASS;
                        ERRORCODE=1;
                fi
        else
            	#Create .htpasswd file if it doesn't exist
                htpasswd -bc $HTPASSLOCATION $2 $HTPASS_PASS;
                ERRORCODE=1;
        fi

fi

if [ ! "$ERRORCODE" -eq 0 ];
then
        echo -e ".htpasswd successfully configured. Please copy the following code and paste it in your .htaccess file.\n###### Password protection ######\nAuthUserFile $HTPASSLOCATION\nAuthType Basic\nAuthName \"Restricted Access\"\nRequire valid-user\n#################################\n\nDirectory access informationBack
        \n--------------------------\nUser : $2\nPass : $HTPASS_PASS\n";
fi

}


function alldomains ()
{
ls -d /home/*/*/html | cut -d/ -f0,4
}


function istherespam ()
{
echo "$txtcyn Top senders in the outgoing queue: $txtrst"
/var/qmail/bin/qmqtool -R | awk '/  From:/ {h[$0]++} END {for (x in h) {print h[x], x}}' | sort -rn | head -10
printf "/n/n"

echo "$txtcyn Top recipients of the outgoing queue: $txtrst"
/var/qmail/bin/qmqtool -R | awk '/  To:/ {h[$0]++} END {for (x in h) {print h[x], x}}' | sort -rn | head -10
printf "/n/n"

echo "$txtblu Top subjects of the outgoing queue: $txtrst"
/var/qmail/bin/qmqtool -R | awk '/  Subject:/ {h[$0]++} END {for (x in h) {print h[x], x}}' | sort -rn | head -10
printf "/n/n"
}

domaincheck ()
{
    vhost="$(echo /etc/httpd/conf.d/vhost_[^000]*.conf)";
    sub='';
    case $1 in
        -a)
            if [[ -n $2 ]]; then
                sub=$2;
            else
                sub='';
            fi;
            vhost="$(grep -l $(getusr) /etc/httpd/conf.d/vhost_[^000]*.conf)"
        ;;
        -r)
            if [[ -z $2 ]]; then
                read -p "ResellerID: " r_id;
            else
                r_id=$2;
            fi;
            vhost=$(for r_user in $(nodeworx -unc Siteworx -a listAccounts | awk "(\$5 ~ /^$r_id$/)"'{print $2}'); do grep -l $r_user /etc/httpd/conf.d/vhost_[^000]*.conf; done | sort | uniq)
        ;;
        -v)
            FMT=" %-15s  %-15s  %3s  %3s  %3s  %s\n";
            HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %3s  %s${NORMAL}\n"
        ;;
    esac;
    echo;
    FMT=" %-15s  %-15s  %3s  %3s  %s\n";
    HLT="${BRIGHT}${RED} %-15s  %-15s  %3s  %3s  %s${NORMAL}\n";
    printf "$FMT" " Server IP" " Live IP" "SSL" "FPM" " Domain";
    printf "$FMT" "$(dash 15)" "$(dash 15)" "---" "---" "$(dash 44)";
    for x in $vhost;
    do
        D=$(basename $x .conf | cut -d_ -f2);
        V=$(awk '/.irtual.ost/ {print $2}' $x | head -1 | cut -d: -f1);
        I=$(dig +short +time=1 +tries=1 ${sub}$D | grep -E '^[0-9]{1,3}\.' | head -1);
        S=$(if grep :443 $x &> /dev/null; then echo SSL; fi);
        F=$(if grep MAGE_RUN $x &> /dev/null; then echo FIX; fi);
        if [[ "$I" != "$V" ]]; then
            printf "$HLT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D";
        else
            printf "$FMT" "$V" "$I" "${S:- - }" "${F:- - }" "${sub}$D";
        fi;
    done;
    echo
}


###### EOF ######
