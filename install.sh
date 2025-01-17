#!/bin/bash
all_printers=$(lpstat -s | tail +2 | awk '{print $3}' | sed 's/.$//')

echo
echo "These are your installed printers:"
echo
declare printers_array
i=0
for p in $all_printers
do
  i=$(( $i + 1 ))
  echo $i. $p
  printers_array[$i]=$p
done
echo
echo "Type the number of the printer you want to add duplexing capabilities, then type ENTER:"
echo
read chosen_printer

first_printer=${printers_array[$chosen_printer]}

function setup_duplexer {
  first_printer=$1
  if [ -z "$first_printer" ]
  then
    echo "No printer submitted. You trickster!"
    exit 1
  else
    echo "found printer: "$first_printer
    echo going ahead.
  fi

  #create dir for files to be printed
  mkdir -p /var/spool/cups/duplex/
  chmod 777 /var/spool/cups/duplex/
  #create dir for our files
  mkdir -p /usr/share/manual_duplex_linux/
  cp printer.png /usr/share/manual_duplex_linux/
  cp document-print.svg /usr/share/manual_duplex_linux/

  #permit lp user to run zenity as the user running the installer
  zenity_user=$(logname)
  touch /etc/sudoers.d/lp
  chmod 640 /etc/sudoers.d/lp
  echo '#user	host = (runas user) command' > /etc/sudoers.d/lp
  echo "lp ALL=($zenity_user) NOPASSWD:/usr/bin/zenity" >> /etc/sudoers.d/lp
  chmod 440 /etc/sudoers.d/lp

  cp -rf usr/lib/cups/backend/duplex-print /usr/lib/cups/backend/duplex-print
  chown root:root /usr/lib/cups/backend/duplex-print
  chmod 700 /usr/lib/cups/backend/duplex-print
  cp -rf usr/lib/cups/backend/duplex-print /usr/lib/cups/backend-available/duplex-print
  chown root:root /usr/lib/cups/backend-available/duplex-print
  chmod 700 /usr/lib/cups/backend-available/duplex-print

  echo "Deleting printer if already exists"
  lpadmin -x Manual_Duplexer_$first_printer

  cp -praf /etc/cups/ppd/$first_printer.ppd /etc/cups/ppd/Manual_Duplexer_$first_printer.ppd

#  sed -i 's/"0 hpcups"/"duplex_print_filter"/g' /etc/cups/ppd/Manual_Duplexer_$first_printer.ppd
  sed -i '/^*cupsFilter/d' /etc/cups/ppd/Manual_Duplexer_$first_printer.ppd

  echo '*cupsFilter2: "application/pdf application/pdf 100 -"' >> /etc/cups/ppd/Manual_Duplexer_$first_printer.ppd

  sleep 1

  service cups restart

  #add duplexing printer
  lpadmin -p Manual_Duplexer_$first_printer -E -v duplex-print:$first_printer -P /etc/cups/ppd/Manual_Duplexer_$first_printer.ppd
  lpadmin -d Manual_Duplexer_$first_printer

  echo
  echo "Duplexer installed."
  echo
  exit 0
}

clear
if [ $(whoami) == root ]
then
  echo
  echo "This script assumes /var/spool/cups/ is the folder used by the printing system."
  echo
  echo "The script will add"
  echo "                        $first_printer "
  echo
  echo " printer with the duplex setup. Is this what you want?"
  echo
  echo "(Y/N) followed by [ENTER]:"
  read approve

  if [ $approve == "Y" ]
  then
	echo
	echo
	echo
      setup_duplexer $first_printer
  else
    echo
    echo "Nothing was changed."
    echo
    exit 0
  fi
else
  echo "This must be run as root."
  exit 1
fi
