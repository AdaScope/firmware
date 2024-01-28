## Introduction

This is the firmware portion of the Adascope project (a software oscilloscope). The compiled binary is made to be run on a STM32F429disc1 board.

We are essentially continuously sampling from three inputs and sending the data to a host pc with the help of the Min protocol.

To do this, we're using all three ADCs (ADC 1 with pin PA3, ADC 2 with pin PC3 and ADC 3 with pin PC1) in polling mode. To send the data, we use USART1, which is able to communicate using the mini-usb port.

## How to Run

### Download Alire

https://alire.ada.dev/

Make sure you add to Path

### Add Custom Alire Index

This project requires an alire index assembled by Olivier Henley.
The readme linked below explains how to add this index.
https://github.com/ohenley/hybrid_autosar_stm32f429_demo/blob/main/README.md#add-custom-alire-index-important

### Build the Project

   ```sh
   alr build
   ```

### Load Project onto STM Board

If you dont have openOCD installed:

   ```sh
   sudo apt install openocd
   ```

To load onto board

   ```sh
   openocd -f /usr/share/openocd/scripts/board/stm32f429disc1.cfg -c 'program bin/adc_standalone verify reset exit'
   ```


## Relevant Documentation


[STM32F429xx Datasheet](https://www.st.com/content/ccc/resource/technical/document/datasheet/03/b4/b2/36/4c/72/49/29/DM00071990.pdf/files/DM00071990.pdf/jcr:content/translations/en.DM00071990.pdf)

[Ada Drivers Library](https://github.com/AdaCore/Ada_Drivers_Library/tree/f607a9a7b7598da5e75e19d1ea720ec12954bccc/arch/ARM/STM32/driver_demos)