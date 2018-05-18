#!/bin/bash
# setup-shutdown.sh 
# ce script installe un script python pour éteindre proprement son Raspberry Pi avec le PIN5/GPIO3 Logic LOW
# Auteur:  opendomotech.com
# Adapté depuis https://svn.nwesd.org/linuxdev/config_samples/lenny_setup/setup-denyhosts

# INSTRUCTIONS:
# télécharger et executer ce script dans le terminal en utilisant la commande suivante:
#  curl https://raw.githubusercontent.com/trarizakaria/rpi_scripts/blob/master/setup-shutdown.sh | bash
##################################################################################################################################

set -u # en cas d'échec

echo; echo
echo -e "\e[96mce script installe un script python pour éteindre proprement son Raspberry Pi avec le PIN5/GPIO3 Logic LOW\e[0m"
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
echo -e "\033[31mDownloading shutdown scripts\e[0m"
curl -# "https://raw.githubusercontent.com/trarizakaria/rpi_scripts/blob/master/shutdown.py" > /home/pi/scripts/shutdown.py 
curl -# "https://raw.githubusercontent.com/trarizakaria/rpi_scripts/master/shutdown.rc" > /tmp/pi_shutdown
sudo mv /tmp/pi_shutdown  /etc/init.d/pi_shutdown; chmod +x /etc/init.d/pi_shutdown
#vérification pour voir si curl a réussi ou non, et options de réessaye.

echo; echo
echo -e "\033[31mAjout de pi_shutdown à rc.d\e[0m"
sudo update-rc.d pi_shutdown defaults

#démarrage de shutdown.py maintenant pour éviter un reboot.
echo; echo
echo -e "\033[31mexecution de shutdown listener\e[0m"
sudo python /home/pi/scripts/shutdown.py &> /dev/null &

echo; echo
echo -e "\033[31mle script Shutdown est maintenant installé\e[0m"
echo; echo

exit 0
