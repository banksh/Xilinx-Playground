## RGBLEDs
set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { LEDS_tri_o[2] }];
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { LEDS_6bits_tri_o[1] }];
set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { LEDS_6bits_tri_o[0] }];

set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LEDS[0]}]
set_property PACKAGE_PIN L15 [get_ports {LEDS[2]}]
set_property PACKAGE_PIN G17 [get_ports {LEDS[1]}]
set_property PACKAGE_PIN N15 [get_ports {LEDS[0]}]
set_property DRIVE 12 [get_ports {LEDS[1]}]
