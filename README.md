# Airport Hazard Lights
Airport Hazard Lights Simulator on the FPGA DE1-SoC

The landing lights at Sea-Tac are busted, so I had to come up with a new set. In order to show pilots the wind direction across the runways, I simulated special wind indicators to put at the ends of all the runways at Sea-Tac onto my FPGA. The integrated circuit is given two inputs (SW[0] and SW[1]) to indicate wind direction, and three lights to display the corresponding sequence of lights:

Calm
{SW[1], SW[0]} = 00
LEDR[2:0] -> 101 > 010

Right to Left
{SW[1], SW[0]} = 01
LEDR[2:0] -> 001 > 010 > 100

Left to Right
{SW[1], SW[0]} = 00
LEDR[2:0] -> 100 > 010 > 001

For each situation, the lights should cycle through the given pattern. 
If the wind is calm, the lights will cycle between the outside lights and the center light, over and over.
The right to left and left to right crosswind indicators repeatedly cycle through three patterns each, which has the light moving from right to left or left to right, respectively. 
