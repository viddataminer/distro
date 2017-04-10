#!/bin/bash 
# : << 'APOCALYPSE' 
#echo "
echo "
                 ___________.___________________    _______   
                 \__    ___/|   \__    ___/  _  \   \      \  
                   |    |   |   | |    | /  /_\  \  /   |   \ 
                   |    |   |   | |    |/    |    \/    |    \ 
                   |____|   |___| |____|\____|__  /\____|__  / 
     
                    Titan Master Installation Script Ver 1.1 
"
homedir=`pwd` 
me=`whoami`
if [ "${me}" != "root" ]; then
    echo "[31mPlease run this script as root.[0m"
    exit 0
fi

#wget http://google.com
#if [ $? -ne 0 ]; then
#    echo "[31mYou must have an established internet connection to use this installer. Bye.[0m"
#    exit 0
#fi

#ls /usr/local/nagios > /dev/null
#if [ $? -ne 0 ]; then
#   echo "------------first time-------------"
#   first_time=1
#else
#   echo "NOT first time"
#    first_time=0
#    ls /smg/bin > /dev/null
#    if [ $? -ne 0 ]; then
#       nagios_but_no_smg=1
#    else
#       nagios_but_no_smg=0
#    fi
#fi
#clear

#echo ""
echo "This script will set up the Titan Logging, Mining and Monitoring tools"
echo ""
#echo "The 'Aggregator' is designed as a 'backend' to Nagios, and"
#echo "aids in the management and scalability of the Core Nagios Installation."
#echo ""
#echo "The 'Appliance' is a group of monitoring tools which can be installed"
#echo "anywhere, and does not rely on Nagios.  "
#echo ""
#if [ $first_time -eq 1 ]; then
#echo "As this appears to be an Initial Installation, it is recommened that you"
#echo "select option 1.  Installing the Appliance and Aggregator on the same"
#echo "node gives you the advantage of being able to write directly to the "
#echo "Nagios Command Pipe, as opposed to using NACA.  See documentation for details."
#echo ""
#fi

echo "Please select one of the following options:"
echo ""
echo "  0) Setup the Aggregator and Appliance Bins Only"
echo "  1) Setup the Aggregator and Appliance - Build from Source"
#echo ""
echo "  2) Setup the Aggregator - including Nagios and associated tools."
#echo ""
echo "  3) Setup the Appliance  - Loggers, Miners and Pingers"
#echo ""
echo "  4) Setup Pinger Only"
#echo ""
echo "  5) Setup Loggers Only"
#echo ""
echo "  6) Setup Miners Only"
#echo ""
echo "  7) Setup Core Nagios Only"
#echo ""
echo "  8) Install Only Nagios Plugins"
#echo ""
echo "  9) WHAT IS THIS?? Documentaion Please!....."
echo ""
echo -e "Please select a numeric option: \c"
read junk
if [ "${junk}" = "3" ]; then
    cd app
    ./install_app.sh remote
    cd ${homedir}
elif [ "${junk}" = "4" ]; then
    cd pinger
    ./install_pinger.sh local
    cd ${homedir}
elif [ "${junk}" = "2" ]; then
    cd agg
    ./install_agg.sh
    cd ${homedir}
elif [ "${junk}" = "5" ]; then
    cd logger
    ./install_logger.sh
    cd ${homedir}
#    echo -e "Would you also like to install the plugins?: \c"
#    read junk
#    if [ "x${junk}x" = "xyx" -o "x${junk}x" = "xYx" ]; then
#        cd app
#        ./install_app.sh plugins_only
#    fi
elif [ "${junk}" = "6" ]; then
    cd miner
    ./install_miner.sh
    cd ${homedir}
    echo -e "Would you also like to install the plugins?: \c"
    read junk
    if [ "x${junk}x" = "xyx" -o "x${junk}x" = "xYx" ]; then
        cd app
        ./install_app.sh plugins_only
    fi
elif [ "${junk}" = "7" ]; then
    cd app
    ./install_app.sh plugins_only
    cd ${homedir}
elif [ "${junk}" = "8" ]; then
    cd app
    ./install_app.sh plugins_only
    cd ${homedir}
elif [ "${junk}" = "1" ]; then
    mkdir agg
    cd agg
    git init
    git clone https://viddataminer:datamine1@github.com/viddataminer/aggregator.git v1
    cp v1/* .
echo "ready to install ??"
read junk
    chmod +x ./install_agg.sh
    ./install_agg.sh
    cd ${homedir}
    mkdir app
    cd app
    git clone https://viddataminer:datamine1@github.com/viddataminer/appliance.git v1
    cp v1/* .
    chmod +x ./install_app.sh
    ./install_app.sh all full
    cd ${homedir}
elif [ "${junk}" = "0" ]; then
    echo "What is you base path for install?"
    read base_path
    mkdir aggbin
    cd aggbin
    git init
    git clone https://viddataminer:datamine1@github.com/viddataminer/aggbin v1
    cp v1/* $base_path/bin
    cd ${homedir}
    mkdir appbin
    cd appbin
    git clone https://viddataminer:datamine1@github.com/viddataminer/appbin.git v1
    cp v1/* $base_path/bin
    cd ${homedir}
    mkdir scripts
    cd scripts
    git clone https://viddataminer:datamine1@github.com/viddataminer/shell_dependencies v1
    cp v1/* $base_path/bin
    cd ${homedir}
    mkdir other_bins
    cd other_bins
    git clone https://viddataminer:datamine1@github.com/viddataminer/other_bins v1
    cp v1/* $base_path/bin
elif [ "${junk}" = "9" ]; then
    #./show_documentation.sh
    echo "This would be a nice feature, since you requested it... but alas.."
    exit 2
else
    echo ""
    echo "  [31mUse of this setup code requires superior brain power and typing skills..."
    echo "       [31myou are not yet ready grasshopper... come back tomorrow[0m"
    echo ""
fi
