Based off of https://github.com/wolfbiters/hybrid_autosar_stm32f429_demo/blob/main/README.md


To run:

add alire index from repo above

then alr build and load onto board with openocd

```
openocd -f /usr/share/openocd/scripts/board/stm32f429disc1.cfg -c 'program bin/adc_standalone verify reset exit'