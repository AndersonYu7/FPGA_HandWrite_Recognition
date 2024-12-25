#!/bin/sh
#
# This file was automatically generated.
#
# It can be overwritten by nios2-flash-programmer-generate or nios2-flash-programmer-gui.
#

#
# Converting Binary File: C:\Users\USER\Desktop\DNN_Model_scaled\DNN_Model_scaled.zip to: "..\flash/DNN_Model_scaled_ext_flash.flash"
#
bin2flash --input="C:/Users/USER/Desktop/DNN_Model_scaled/DNN_Model_scaled.zip" --output="../flash/DNN_Model_scaled_ext_flash.flash" --location=0x100000 --verbose 

#
# Programming File: "..\flash/DNN_Model_scaled_ext_flash.flash" To Device: ext_flash
#
nios2-flash-programmer "../flash/DNN_Model_scaled_ext_flash.flash" --base=0x0 --accept-bad-sysid --device=1 --instance=0 '--cable=USB-Blaster on localhost [USB-0]' --program --verbose 

