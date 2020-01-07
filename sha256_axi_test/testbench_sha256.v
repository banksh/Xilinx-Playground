`timescale 1ns / 1ps

module test;
    wire [511:0] in;

    assign in = 'h6d736780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;

    wire [255:0] out;
    wire done;
    reg reset = 0;
    reg start = 0;

    sha256_block sha256sum (in, start, reset, done, out);
    initial begin
        reset = #1 1;
        $display("%t: reset->1\tstart=0", $time);
        start = #1 1;
        $display("%t: reset=1\tstart->1", $time);
        reset = #1 0;
        $display("%t: reset->0\tstart=1", $time);
        start = #1 0;
        $display("%t: reset=0\tstart->0", $time);
        start = #1 1;
        $display("%t: reset=0\tstart->1", $time);
        reset = #1 1;
        $display("%t: reset->1\tstart=1", $time);
        start = #1 0;
        $display("%t: reset=1\tstart=->0", $time);
        start = #1 1;
        $display("%t: reset=1\tstart->1", $time);
        start = #1 0;
        $display("%t: reset=1\tstart=->0", $time);
        start = #1 1;
        $display("%t: reset=1\tstart->1", $time);
        #10 $finish;
    end

    always @(posedge done) $display("New output at time %t: %h", $time, out);

endmodule
