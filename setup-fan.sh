#!/bin/bash
# setup-fan.sh 
# ce script installe un script python pour controler le ventillateur d'un Raspberry Pi avec le PIN22/GPIO25
# Auteur:  opendomotech.com
# Adapté depuis http://www.instructables.com/id/Control-a-Cooling-Fan-on-a-Raspberry-Pi-3/

# INSTRUCTIONS:
# télécharger et executer ce script dans le terminal en utilisant la commande suivante:
#  curl https://raw.githubusercontent.com/trarizakaria/rpi_scripts/master/setup-fan.sh | bash
##################################################################################################################################

set -u # en cas d'échec

echo; echo
echo -e "\e[96mce script installe un script python pour pour controler le ventillateur d'un Raspberry Pi avec le PIN22/GPIO25\e[0m"
echo; echo
echo -e "\e[96mVisitez \e[4;96mhttp://opendomotech.com\e[0;96m pour plus d'informations\e[0m"
echo; echo
sleep 5

#Mise à jour des  paquées et installation de python.gpio
echo -e "\033[31mMise à jour des  paquées\e[0m"
sudo apt-get -y update 

echo; echo
echo -e "\033[31mInstallation de python.gpio\e[0m"
sudo apt-get install --yes python-rpi.gpio python3-rpi.gpio </dev/null

#téléchargement des scripts etc
mkdir /home/pi/scripts &> /dev/null
echo; echo
echo -e "\033[31mTéléchargement du fan scripts\e[0m"
curl -# "https://raw.githubusercontent.com/trarizakaria/rpi_scripts/master/run-fan.py" > /home/pi/scripts/shutdown.py 
curl -# "https://raw.githubusercontent.com/trarizakaria/rpi_scripts/master/run-fan.rc" > /tmp/pi_fan
sudo mv /tmp/pi_fan  /etc/init.d/pi_fan; chmod +x /etc/init.d/pi_fan
#vérification pour voir si curl a réussi ou non, et options de réessaye.

echo; echo
echo -e "\033[31mAjout de pi_fan à rc.d\e[0m"
sudo update-rc.d pi_fan defaults

#démarrage de run-fan.py maintenant pour éviter un reboot.
echo; echo
echo -e "\033[31mexecution de run-fan\e[0m"
sudo python /home/pi/scripts/run-fan.py &> /dev/null &

echo; echo
echo -e "\033[31mle script run-fan est maintenant installé\e[0m"
echo; echo

exit 0
