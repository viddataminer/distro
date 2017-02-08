#set -x
#ver 1.2
#appliance
# 
#
install_nagios_plugins()
{
echo "wget nagios-plugins"
wget http://nagios-plugins.org/download/nagios-plugins-2.1.2.tar.gz
#wget http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-2.1.2.tar.gz 2>&1 > /tmp/plugins.log
echo "Un-taring nagios-plugins-2.1.2.tar.gz . . . . "
tar xzf nagios-plugins-2.1.2.tar.gz 2>&1 >> /tmp/plugins.log
cd nagios-plugins-2.1.2
echo "./configure "
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl 2>&1 >> /tmp/plugins.log
bld_err=0
echo "make "
make 2>&1 >> /tmp/plugins.log
if [ $? -ne 0 ]; then
    echo "Nagios Pluging Build Error: make.  Review /tlocalmp/plugins.log. Hit return to continue"
    bld_err=1
    read junk
fi
echo "make >> /tmp/plugins.log"
make install 2>&1 >> /tmp/plugins.log
if [ $? -ne 0 ]; then
    echo "Nagios Pluging Build Error: make install.  Review /tmp/plugins.log. Hit return to continue"
    bld_err=1
    read junk
fi
if [ $bld_err -eq 0 ]; then
    echo "Nagios Plugins built successfully and now live in /usr/local/nagios/libexec"
    echo "Hit return to continue"
    read junk
fi
}

install_samba()
{
sudo aptitude install autoconf
#cd /data/tools/
#wget https://download.samba.org/pub/samba/stable/samba-4.5.3.tar.gz
wget http://www.openvas.org/download/wmi/wmi-1.3.14.tar.bz2
tar -xvf wmi-1.3.14.tar.bz2
cd wmi-1.3.14/
sudo apt-get install build-essential
sudo make "CPP=gcc -E -ffreestanding"
sudo cp Samba/source/bin/wmic /usr/local/bin/
}

do_ubuntu_install() 
{
    package=${1}
    dpkg --get-selections | grep ${package} 2>&1 > /dev/null
    if [ $? -eq 0 ]; then
        echo "Package ${package} is already installed"
        return 1
    fi 
    echo "Installing package ${package}.  Output being sent to /tmp/${package}.log"
    echo "Please be patient.  Download times vary."
    echo 'y' | apt-get install $package > /tmp/${package}.log
    if [ $? -ne 0 ]; then
        echo -e "Package $package FAILED TO INSTALL SUCCESSFULLY.\nCheck /tmp/${package}.log for details." 
    fi
    return 0
}


cat /proc/version | grep Ubuntu
if [ $? -eq 0 ]; then
   ROOT_CRON_FILE="/var/spool/cron/crontabs/root";
else 
   ROOT_CRON_FILE="/var/spool/cron/root";
fi


home_dir=`pwd`
echo home_dir is $home_dir

me=`whoami`

if [ "${me}" != "root" ]; then
    echo "[31mPlease run this script as root.[0m"
    exit 0
fi

# if arg1 is 'local', then we have already set up the aggregator, and hence 
# have already installed the following packages.... so Dont do it again!!
if [ "x${1}x" != "xlocalx" ]; then
    echo "running apt-get update, please be patient...  output sent to /tmp/update.log"
    apt-get update  2>&1 > /tmp/update.log
    echo "running apt-get upgrade, please be patient...  output sent to /tmp/upgrade.log"
    echo 'y' | apt-get upgrade  2>&1 > /tmp/upgrade.log
    do_ubuntu_install build-essential
    do_ubuntu_install smbclient
    do_ubuntu_install libssl-dev
fi

if [ "x${1}x" = "xplugins_onlyx" ]; then 
    clear
    echo "-------- INSTALLING NAGIOS PLUGINS ONLY!! ----------"
    install_nagios_plugins
    exit
fi

if [ ! -d /opt/titan ]; then mkdir /opt/titan 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/bin ]; then mkdir /opt/titan/bin 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/bin/plugins ]; then mkdir /opt/titan/bin/plugins 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/log ]; then mkdir /opt/titan/log 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/cfg ]; then mkdir /opt/titan/cfg 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/cfg/ping ]; then mkdir /opt/titan/cfg/ping 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/cfg/nmap ]; then mkdir /opt/titan/cfg/nmap 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/les ]; then mkdir /opt/titan/les 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/les/ping ]; then mkdir /opt/titan/les/ping 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/src ]; then mkdir /opt/titan/src 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/out ]; then mkdir /opt/titan/out 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/out/trending ]; then mkdir /opt/titan/out/trending 2>&1 > /dev/null; fi
if [ ! -d /opt/titan/out/ping ]; then mkdir /opt/titan/out/ping 2>&1 > /dev/null; fi
if [ ! -d /usr/local/freetds ]; then 
    mkdir /usr/local/freetds 2>&1 > /dev/null; 
fi

egrep -i "^nagios" /etc/passwd > /dev/null
if [ $? -eq 0 ]; then
    echo nagios user already exists.
else 
    echo -e "\nAdded user nagios\n"
    useradd -m nagios 
    echo -e "\nUse of nagios plugins requires a nagios user.\n"
    while :; do
        echo -e "\nPlease enter the password for user 'nagios'\n"
        passwd nagios
        if [ $? -eq 0 ]; then
            break
        fi
        echo -e "\nThe passwords did NOT match meathead... try again\n"
    done
fi

#do_ubuntu_install gcc
#do_ubuntu_install make

#echo 'y' | apt-get install build-essential 2>&1 > /tmp/build.log
#echo "installing smbclient, please be patient...  output sent to /tmp/smbclient.log"
#echo 'y' | apt-get install smbclient 2>&1 > /tmp/smbclient.log
#echo "installing libssl, please be patient...  output sent to /tmp/libssl.log"
#echo 'y' | apt-get install libssl-dev 2>&1 > /tmp/libssl.log
#echo "installing gcc, please be patient...  output sent to /tmp/gcc.log"
#echo 'y' | apt-get install gcc 2>&1 > /tmp/gcc.log
#echo "installing make, please be patient...  output sent to /tmp/make.log"
#echo 'y' | apt-get install make 2>&1 > /tmp/make.log

install_nagios_plugins 
#cd $home_dir
#echo "Getting Nagios Plugins.... output sent to /tmp/plugins.log"
#echo "wget nagios-plugins-1.4.15.tar.gz"
#wget http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-1.4.15.tar.gz 2>&1 > /tmp/plugins.log
#echo "Un-taring nagios-plugins-1.4.15.tar.gz . . . . "
#tar xzf nagios-plugins-1.4.15.tar.gz 2>&1 >> /tmp/plugins.log
#cd nagios-plugins-1.4.15
#echo "./configure "
#./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl 2>&1 >> /tmp/plugins.log
#bld_err=0
#echo "make "
#make 2>&1 >> /tmp/plugins.log
#if [ $? -ne 0 ]; then
#    echo "Nagios Pluging Build Error: make.  Review /tlocalmp/plugins.log. Hit return to continue"
#    bld_err=1
#    read junk
#fi
#echo "make >> /tmp/plugins.log"
#make install 2>&1 >> /tmp/plugins.log
#if [ $? -ne 0 ]; then
#    echo "Nagios Pluging Build Error: make install.  Review /tmp/plugins.log. Hit return to continue"
#    bld_err=1
#    read junk
#fi
#if [ $bld_err -eq 0 ]; then
#    echo "Nagios Plugins build successfully and now live in /usr/local/nagios/libexec"
#fi


nmap -v 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    do_ubuntu_install nmap
    #echo -e "	[31mNO nmap... Installing nmap....[0m\c"
    #echo 'y' | apt-get install nmap
fi

#expect -v 2>&1 > /dev/null
#if [ $? -ne 0 ]; then
#    do_ubuntu_install expect
#    #echo -e "	[31mNO expect... Installing expect....[0m\c"
#    #echo 'y' | apt-get install expect
#fi

cd $home_dir
#cp ../cfg/* /opt/titan/cfg
#cp windows.cfg auto_services.cfg eventlog.hosts linux.cfg linux.hosts linux.services mssql.hosts nagadm_acct_info.dat acct_info.dat nagadm.cfg netck.cfg queck.cfg windows.hosts windows.services /opt/titan/cfg

make clean
##clear
##echo ""
##echo -e "Are you installing Appliance tools on the Aggregator? (y/n): \c"
##read junk
#
##if [ "${junk}" = "y" -o "${junk}" = "Y" ]; then

mkdir bin
echo "Building Appliance tools...."
make all 2>&1 > /tmp/make_titan_local.log

#if [ "x${1}x" = "xlocalx" ]; then
#    echo "Building Appliance tools to run Locally."
#    make local 2>&1 > /tmp/make_smg_local.log
#    local_install=1
#    aggro_name=localhost
#else 
#    echo "Building Appliance tools to run Remotely."
#    local_install=0
#    make remote 2>&1 > /tmp/make_smg_remote.log
#    echo -e "Enter the Name or IP of the Aggregator: \c"
#    read aggro_name 
#fi

cd /root
echo "Generating ssl cert..."
ssh-keygen -t rsa

cd $home_dir
#cd bin
echo "pwd returns `pwd`"
cp *.exp check_for_cluster_failover run_nagios_check add_host logger_evt logger logger_sql netck queck run_logger_evt pinger run_miner miner set_acct_info  /opt/titan/bin
cp setupssh.sh /root
cd $home_dir

if [ $? -ne 0 ]; then
    echo -e "	[31mSMG Build error... Review previous info...hit return continue[0m\c"
else
    echo "      [32mSMG Appliance biniaries built successfully. Hit return continue[0m."
fi
read junk

#cp add_host /usr/local/bin
cp add_host /opt/titan/bin
#cd ..

echo "The appliance code looks up account information for WINDOWS servers"
echo "in an encrypted file named /opt/titan/cfg/acct_info.dat. for user 'nagiosadmin'."
echo "If this is a standard University of Utah HOSPITAL install, this existing"
echo "file named acct_info.dat will contain approiate users and passwords."
echo ""
echo -e "Would you like to use the existing acct_info.dat file? (y/n):\c"
read junk

if [ "${junk}" != "y" -a "${junk}" != "Y" ]; then 
    echo -e "\nSetting up account info for Windoz Servers..."
    #echo -e "\nThe Account Info file is an encrypted file in which the "
    #echo -e "Nagios Administrators username and password will be stored."
echo ""
    echo -e "\nEnter account info file name [/opt/titan/cfg/acct_info.dat]: \c"
    read junk
    len=`echo $junk | wc -c`
    if [ $len -eq 1 ]; then
        file="/opt/titan/cfg/acct_info.dat"
    else
        file=$junk
    fi
    echo -n "Please enter account name[nagiosadmin]: "
    read account

    echo -n "Please enter password: "
stty -echo
    read password
stty echo
    echo set_acct_info $file $account $password
    /opt/titan/bin/set_acct_info $file $account $password
    cp $file /opt/titan/cfg
    echo -e "\nhit return to continue"
    read junk
fi

cp /usr/local/nagios/libexec/check_icmp /opt/titan/bin 2>&1 > /dev/null

cd $home_dir
echo -e "\n[32mAppliance tools built and copied to /opt/titan/bin[0m"
echo ""
echo "If you are planning on monitoring any Windoze hosts, you need Samba,"
echo "because when you use such depressing stuff, ya just gotta DANCE!!"
echo -e "Would you like to build and install Samba utilities (y/n)?: \c"
read junk

#wget http://web.mit.edu/kerberos/dist/krb5/1.4/krb5-1.4.3-signed.tar
#wget http://us2.samba.org/samba/ftp/samba-latest.tar.gz
#tar -xvzf samba-latest.tar.gz
#cd samba-2.2.8a/source
#./configure --with-winbind --with-winbind-auth-challenge
#make

#echo "untared wmi....."
#read junk
#autogen.sh will fail if automake and autoconf are not installed.

if [ "$junk" = "Y" -o "$junk" = 'y' ]; then
    echo "Review /tmp/samba.log for installation details."
    echo "calling install_samba."
    install_samba
#    echo 'y' | apt-get install automake autoconf > /tmp/samba.log
#    echo "tar -xvf wmi-1.3.5.tar"
#    tar -xvf wmi-1.3.5.tar 2>&1 >> /tmp/samba.log
#    cd wmi-1.3.5/Samba/source 2>&1 >> /tmp/samba.log
#    echo "./autogen.sh"
#    ./autogen.sh 2>&1 >> /tmp/samba.log
#    echo "./configure "
#    ./configure 2>&1 >> /tmp/samba.log
#    echo "make "
#    make "CPP=gcc -E -ffreestanding" 2>&1 >> /tmp/samba.log
#    make 2>&1 >> /tmp/samba.log
#    cp bin/wmic /opt/titan/bin
#
#    if [ $? != 0 ]; then
#        echo -e "\n[31mBuild ERROR: Check wmic Build results[0m"
#    else
#        echo -e "\n[32mWMIC built successfully. Copied to /opt/titan/bin[0m "
#    fi
    cp bin/winexe /opt/titan/bin
    if [ $? != 0 ]; then
        echo -e "\n[31mBuild ERROR: Check winexe Build results[0m"
    else
        echo -e "\n[32mWINEXE built successfully and was copied to /opt/titan/bin[0m"
    fi
    cp bin/smbclient /opt/titan/bin
    if [ $? != 0 ]; then
        echo -e "\n[31mBuild ERROR: Check smbclient Build results[0m"
    else
        echo -e "\n[32mSMBCLIENT built successfully and was copied to /opt/titan/bin[0m"
    fi
fi

#if [ ${local_install} -eq 0 ]; then
#    echo Hit return to install NSCA... 
#else 
#    echo Hit return to continue
#fi

echo ""

#INstallation of the modified nsca.c is done in the aggreagator
#if [ ${local_install} -eq 0 ]; then
#    ls /etc/*nsca*
#    if [ $? -ne 0 ]; then
#        #echo "Installing NSCA...  "
#        #echo 'y' | apt-get install nsca
#        do_ubuntu_install nsca
#        cp /etc/send_nsca.cfg /opt/titan/cfg > /dev/null
#        cp /usr/sbin/send_nsca /opt/titan/bin > /dev/null
#    fi
#fi

echo "The SMG Appliance  has been successfully setup.  The last thing to do is to"
echo "schedule events in the root crontable.  Note that all lines that are entered"
echo "into the crontable will be prceeded with the comment character '#' so "
echo "if you need to remove the # from any line you wish to activate"
echo ""
echo ""
echo -e "Modify the Crontable (y/n):\c"
read junk
if [ $junk != 'y' -a $junk != 'Y' ]; then
    echo "crontab will NOT be modified...."
    exit
fi

echo "This completes the Appliance Setup"
echo "Please keep your arms and legs inside the ride at all times, and... HAVE FUN!!"

echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                         Appliance                             ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                      Nagios Checks                             ######" >> $ROOT_CRON_FILE
echo "#  run_nagios_check is our command rapper.  Arg 1 is the name of " >> $ROOT_CRON_FILE
echo "# the Nagios command you want to run.  On a standard Nagios install, " >> $ROOT_CRON_FILE
echo "# these commands will be found in /usr/local/nagios/libexec. Arg 2 is " >> $ROOT_CRON_FILE
echo "#  a file containing a list of hosts and command line arguments for " >> $ROOT_CRON_FILE
echo "#  the command listed in Arg 1. " >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#5 */6 * * * /opt/titan/bin/run_nagios_check check_snmp snmp_uptime.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#* * * * * /opt/titan/bin/run_nagios_check check_http1 hscwebjava.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#*/5 * * * * /opt/titan/bin/run_nagios_check check_http http_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#* * * * * /opt/titan/bin/run_nagios_check check_http_secure http_secure.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#*/2 * * * * /opt/titan/bin/run_nagios_check check_ntp ntp_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#*/3 * * * * /opt/titan/bin/run_nagios_check check_dns dns_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#*/3 * * * * /opt/titan/bin/run_nagios_check check_imap imap_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#*/4 * * * * /opt/titan/bin/run_nagios_check check_pop pop3_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#4,9,14,19,24,29,34,39,44,49,54,59 * * * * /opt/titan/bin/run_nagios_check check_tcp tcp_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#4,9,14,19,24,29,34,39,44,49,54,59 * * * * /opt/titan/bin/run_nagios_check check_dhcp dhcp_hosts.cfg $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####             MicroSoft Monitoring -  WMI queries               ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#--------microsloth basic monitoring - disk cpu memory auto_services etc-------" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# start_cmd_prsr opens /opt/titan/cfg/windows.hosts and /opt/titan/cfg/windows.services," >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#1,6,11,16,21,26,31,36,41,46,51,56 * * * * /opt/titan/bin/start_cmd_prsr /opt/titan/cfg/windows.hosts /opt/titan/cfg/windows.services $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#------------------microsloth eventlog monitoring--------------------" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# start_eventlog systems eventlog(domain, node)" >> $ROOT_CRON_FILE
echo "# eventlog tails the event log on hosts" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#3,8,13,18,23,28,33,38,43,48,53,58 * * * * /opt/titan/bin/start_eventlog /opt/titan/cfg/eventlog.hosts $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#----------------- microsloth SQL ERRORLOG monitoring -------------------" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# mssql_logck opens SQL Server logs and looks for ERRORs with a" >> $ROOT_CRON_FILE
echo "# SEVERITY between 1 and 25. If found, next line is returned (error text)" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#4,9,14,19,24,29,34,39,44,49,54,59 * * * *  /opt/titan/bin/mssql_logck /opt/titan/cfg/mssql.hosts $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                     UNIX/LINUX/AIX/SUN                        ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#2,7,12,17,22,27,32,37,42,47,52,57 * * * * /opt/titan/bin/start_cmd_prsr /opt/titan/cfg/linux.hosts /opt/titan/cfg/linux.services $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#4,9,14,19,24,29,34,39,44,49,54,59 * * * * /opt/titan/bin/start_cmd_prsr /opt/titan/cfg/aix.hosts /opt/titan/cfg/aix.services $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#*/5 * * * * /opt/titan/bin/start_cmd_prsr /opt/titan/cfg/sun.hosts /opt/titan/cfg/sun_partition.services $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
##
echo "#-----------------------   LOG monitoring   -----------------------" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# logck searchs logs for patterns defined in logck_<os>" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# 1,6,11,16,21,26,31,36,41,46,51,56 * * * *  /opt/titan/bin/logck logck_aix  > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "# 2,7,12,17,22,27,32,37,42,47,52,57 * * * * /opt/titan/bin/logck logck_linux $aggro_name > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "# 3,8,13,18,23,28,33,38,43,48,53,58 * * * * /opt/titan/bin/logck logck_sun  > /dev/null 2>&1" >> $ROOT_CRON_FILE
* 2 * * *  /opt/titan/bin/logck_lssrc /opt/titan/cfg/logck_lssrc.cfg  > /dev/null 2>&1
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                         netstat stuff                         ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "# netck looks for desired states for specific ports defined in netck.cfg" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#*/5 * * * *  /opt/titan/bin/netck /opt/titan/cfg/netck.cfg > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                     printer queue                             ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# queck goes through the output from "wmic select caption from Win32_printjog"" >> $ROOT_CRON_FILE
echo "# and alerts if queue count exceeds the 3rd command line argument (argv[3])" >> $ROOT_CRON_FILE
echo "#*/5 * * * *  /opt/titan/bin/queck /opt/titan/cfg/queck.cfg > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                           the  pinger                         ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "# thats one fast pinger" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "#* * * * * for i in /opt/titan/cfg/ping/subnet*; do /opt/titan/bin/start_icmp_ping \${i} $aggro_name & done > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#####                           Cluster Failover                    ######" >> $ROOT_CRON_FILE
echo "##########################################################################" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
echo "* * * * * /opt/titan/bin/check_for_cluster_failover /opt/titan/cfg/check_for_cluster_failover.cfg  > /dev/null 2>&1" >> $ROOT_CRON_FILE
echo "#" >> $ROOT_CRON_FILE
