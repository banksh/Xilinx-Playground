`timescale 1ns / 1ps

module testbench;

reg clk = 0;
reg[7:0] red = 50;
reg[7:0] green = 100;
reg[7:0] blue = 200;
wire red_out;
wire green_out;
wire blue_out;

top UUT (
    clk,
    red,
    green,
    blue,
    red_out,
    green_out,
    blue_out
    );
    
always #5 clk = ~clk;
endmodule
