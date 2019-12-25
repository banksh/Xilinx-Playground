`timescale 1ns / 1ps

module top(
    input clk,
    input [7:0] red,
    input [7:0] green,
    input [7:0] blue,
    output reg red_out,
    output reg green_out,
    output reg blue_out
    );
    
    // Sawtooth generator
    reg[7:0] counter = 0;
    always @(posedge clk)
        begin
            if(counter < 256)
                counter <= counter + 1;
            else
                counter <= 0;
        end
    
    // Compare counter to setpoints
    always @(posedge clk)
        begin
            if(counter > red)
                red_out <= 1;
            else
                red_out <= 0;
            if(counter > green)
                green_out <= 1;
            else
                green_out <= 0;
            if(counter > blue)
                blue_out <= 1;
            else
                blue_out <= 0;
        end
endmodule
