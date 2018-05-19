#!/usr/bin/python
# -*- coding: UTF-8 -*-
import RPi.GPIO as GPIO
import time
import subprocess

GPIO.setmode(GPIO.BOARD)

# la numérotation utilisé dans ce script correspont à la numérotation physique
# des broches du Raspberry PI, le pin 5 ici est l'équivalent du GPIO 3
GPIO.setup(5, GPIO.IN)

oldButtonState1 = True

while True:
    #conaitre l'état actuel du bouton
    buttonState1 = GPIO.input(5)

    # verifier si le bouton a été pressé
    if buttonState1 != oldButtonState1 and buttonState1 == False:
        # Arrêt
        subprocess.call("shutdown -h now", shell=True,
          stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        oldButtonState1 = buttonState1

    time.sleep(.5)
