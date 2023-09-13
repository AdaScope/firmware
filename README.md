## Introduction

Based off of https://github.com/wolfbiters/hybrid_autosar_stm32f429_demo/blob/main/README.md

Firmware to be run on STM32F429disc1 board. Set up to read analog input on pin PC3 and sends the values through UART1.

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