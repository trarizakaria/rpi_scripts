
#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import os
import time
import signal
import sys
import RPi.GPIO as GPIO
import datetime
#########################
sleepTime = 30  # Temps entre deux relevés de température
                # écriture d'un journal d'évenements
fileLog = open('/home/pi/run-fan.log', 'w+', 0)

#########################
# Horodatage des messages de journal
def timeStamp():
    t = time.time()
    s = datetime.datetime.fromtimestamp(t).strftime('%Y/%m/%d %H:%M:%S - ')
    return s

# Ecriture de message au format standard
def printMsg(s):
    fileLog.write(timeStamp() + s + "\n")

#########################
class Pin(object):
    pin = 25        # numéro du GPIO ou BCM pin pour piloter le ventilateur on/off

    def __init__(self):
        try:
            GPIO.setmode(GPIO.BCM)
            GPIO.setup(self.pin, GPIO.OUT)
            GPIO.setwarnings(False)
            printMsg("Initialized: run-fan using GPIO pin: " + str(self.pin))
        except:
            printMsg("If method setup doesn't work, need to run script as sudo")
            exit

    # resets de tout les GPIO ports utilisés par ce programe
    def exitPin(self):
        GPIO.cleanup()

    def set(self, state):
        GPIO.output(self.pin, state)

# Ventilateur 
class Fan(object):
    fanOff = True

    def __init__(self):
        self.fanOff = True

    # Mettre le ventilateur sur on ou off
    def setFan(self, temp, on, myPin):
        if on:
            printMsg("Turning fan on " + str(temp))
        else:
            printMsg("Turning fan off " + str(temp))
        myPin.set(on)
        self.fanOff = not on

# Temperature
class Temperature(object):
    cpuTemperature = 0.0
    startTemperature = 0.0
    stopTemperature = 0.0

    def __init__(self):
        # Relevé de temperature en Celsius
        #   Température opérationelle maximum du Raspberry Pi 3 est 85°C
        #   les performances de CPU sont ralenties à 82°C
        #   faire fonctionner le CPU à des basses températures prolonge sa durée de vie
        self.startTemperature = 48.0

        # Attendre que la température est inférieure de M degrées en dessous du Max avant d'éteindre le ventilateur
        self.stopTemperature = self.startTemperature - 2.0

        printMsg("Start fan at: " + str(self.startTemperature))
        printMsg("Stop fan at: " + str(self.stopTemperature))

    def getTemperature(self):
        # il faut spécifier le path pour vcgencmd
        res = os.popen('/opt/vc/bin/vcgencmd measure_temp').readline()
        self.cpuTemperature = float((res.replace("temp=","").replace("'C\n","")))

    # Mettre le ventilateur sur on ou off en fonction de la température CPU
    def checkTemperature(self, myFan, myPin):
        self.getTemperature()
        if self.cpuTemperature > self.startTemperature:
            # Mettre le ventilateur sur on, mais seulement s'il est en off
            if myFan.fanOff:
                myFan.setFan(self.cpuTemperature, True, myPin)
        elif self.cpuTemperature <= self.stopTemperature:
            # Mettre le ventilateur sur off, mais seulement s'il est en on
            if not myFan.fanOff:
                myFan.setFan(self.cpuTemperature, False, myPin)

#########################
printMsg("Starting: run-fan")
try:
    myPin = Pin()
    myFan = Fan()
    myTemp = Temperature()
    while True:
        myTemp.checkTemperature(myFan, myPin)

        # Lecture de température chaque N sec (sleepTime)
        # Allumer et éteindre un appareil peut l'épuiser (choisir de bonnes valeur pour N et M)
        time.sleep(sleepTime)

except KeyboardInterrupt: # intercepter une interruption de clavier CTRL + C
    printMsg("keyboard exception occurred")
    myPin.exitPin()
    fileLog.close()

except:
    printMsg("ERROR: an unhandled exception occurred")
    myPin.exitPin()
    fileLog.close()
