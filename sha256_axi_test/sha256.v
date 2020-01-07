`timescale 1ns / 1ps

module sha256_block (
    input [511:0] in,
    input start,
    input reset,
    output reg done,
    output reg [255:0] out
    );

    // Array for constants
    wire [31:0] k [0:63];
    assign k[0] =  'h428a2f98;
    assign k[1] =  'h71374491;
    assign k[2] =  'hb5c0fbcf;
    assign k[3] =  'he9b5dba5;
    assign k[4] =  'h3956c25b;
    assign k[5] =  'h59f111f1;
    assign k[6] =  'h923f82a4;
    assign k[7] =  'hab1c5ed5;
    assign k[8] =  'hd807aa98;
    assign k[9] =  'h12835b01;
    assign k[10] = 'h243185be;
    assign k[11] = 'h550c7dc3;
    assign k[12] = 'h72be5d74;
    assign k[13] = 'h80deb1fe;
    assign k[14] = 'h9bdc06a7;
    assign k[15] = 'hc19bf174;
    assign k[16] = 'he49b69c1;
    assign k[17] = 'hefbe4786;
    assign k[18] = 'h0fc19dc6;
    assign k[19] = 'h240ca1cc;
    assign k[20] = 'h2de92c6f;
    assign k[21] = 'h4a7484aa;
    assign k[22] = 'h5cb0a9dc;
    assign k[23] = 'h76f988da;
    assign k[24] = 'h983e5152;
    assign k[25] = 'ha831c66d;
    assign k[26] = 'hb00327c8;
    assign k[27] = 'hbf597fc7;
    assign k[28] = 'hc6e00bf3;
    assign k[29] = 'hd5a79147;
    assign k[30] = 'h06ca6351;
    assign k[31] = 'h14292967;
    assign k[32] = 'h27b70a85;
    assign k[33] = 'h2e1b2138;
    assign k[34] = 'h4d2c6dfc;
    assign k[35] = 'h53380d13;
    assign k[36] = 'h650a7354;
    assign k[37] = 'h766a0abb;
    assign k[38] = 'h81c2c92e;
    assign k[39] = 'h92722c85;
    assign k[40] = 'ha2bfe8a1;
    assign k[41] = 'ha81a664b;
    assign k[42] = 'hc24b8b70;
    assign k[43] = 'hc76c51a3;
    assign k[44] = 'hd192e819;
    assign k[45] = 'hd6990624;
    assign k[46] = 'hf40e3585;
    assign k[47] = 'h106aa070;
    assign k[48] = 'h19a4c116;
    assign k[49] = 'h1e376c08;
    assign k[50] = 'h2748774c;
    assign k[51] = 'h34b0bcb5;
    assign k[52] = 'h391c0cb3;
    assign k[53] = 'h4ed8aa4a;
    assign k[54] = 'h5b9cca4f;
    assign k[55] = 'h682e6ff3;
    assign k[56] = 'h748f82ee;
    assign k[57] = 'h78a5636f;
    assign k[58] = 'h84c87814;
    assign k[59] = 'h8cc70208;
    assign k[60] = 'h90befffa;
    assign k[61] = 'ha4506ceb;
    assign k[62] = 'hbef9a3f7;
    assign k[63] = 'hc67178f2;

    function automatic [31:0] rrot;
        input [31:0] x;
        input [7:0] n;
        begin: block
            reg [63:0] double_x;
            double_x = {x, x};
            rrot = double_x[n +: 32];
        end
    endfunction

    function automatic [31:0] s0;
        input [31:0] x;
        begin: block
            s0 = rrot(x, 7) ^ rrot(x, 18) ^ (x >> 3);
        end
    endfunction

    function automatic [31:0] s1;
        input [31:0] x;
        begin: block
            s1 = rrot(x, 17) ^ rrot(x, 19) ^ (x >> 10);
        end
    endfunction

    function automatic [31:0] e0;
        input [31:0] x;
        begin: block
            e0 = rrot(x, 2) ^ rrot(x, 13) ^ rrot(x, 22);
        end
    endfunction

    function automatic [31:0] e1;
        input [31:0] x;
        begin: block
            e1 = rrot(x, 6) ^ rrot(x, 11) ^ rrot(x, 25);
        end
    endfunction

    // Schedule array
    reg [31:0] w [63:0];

    // Working variables
    reg [31:0] out_chunk [0:7];
    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
    reg [31:0] e;
    reg [31:0] f;
    reg [31:0] g;
    reg [31:0] h;

    reg[31:0] temp1;
    reg[31:0] temp2;

    integer i;

    initial begin
        // Initial hash values
        out_chunk[0] = 'h6a09e667;
        out_chunk[1] = 'hbb67ae85;
        out_chunk[2] = 'h3c6ef372;
        out_chunk[3] = 'ha54ff53a;
        out_chunk[4] = 'h510e527f;
        out_chunk[5] = 'h9b05688c;
        out_chunk[6] = 'h1f83d9ab;
        out_chunk[7] = 'h5be0cd19;

        a = out_chunk[0];
        b = out_chunk[1];
        c = out_chunk[2];
        d = out_chunk[3];
        e = out_chunk[4];
        f = out_chunk[5];
        g = out_chunk[6];
        h = out_chunk[7];
        
        out = 0;
    end

    // Run SHA256 round at start signal
    // TODO: This block should also be subscribed to
    // the negedge reset signal, but for some reason that
    // crashes Vivado (?)
    always @(posedge start) begin
        if (reset) begin
            done = 0;
    
            for (i=0; i<16; i = i + 1) begin
                // Copy input buffer while correcting direction
                w[i] = in[511 - i*32 -: 32];
            end
    
            for (i=16; i<64; i = i + 1) begin
                w[i] = w[i-16] + s0(w[i-15]) + w[i-7] + s1(w[i-2]);
            end
    
            for (i=0; i<64; i = i + 1) begin
                temp1 = h + e1(e) + ((e & f) ^ ((~e) & g)) + k[i] + w[i];
                temp2 = e0(a) + ((a & b) ^ (a & c) ^ (b & c));
                h = g;
                g = f;
                f = e;
                e = d + temp1;
                d = c;
                c = b;
                b = a;
                a = temp1 + temp2;
            end
    
            out_chunk[0] = out_chunk[0] + a;
            out_chunk[1] = out_chunk[1] + b;
            out_chunk[2] = out_chunk[2] + c;
            out_chunk[3] = out_chunk[3] + d;
            out_chunk[4] = out_chunk[4] + e;
            out_chunk[5] = out_chunk[5] + f;
            out_chunk[6] = out_chunk[6] + g;
            out_chunk[7] = out_chunk[7] + h;
    
            for (i=0; i < 8; i = i + 1) begin
                out[255-i*32 -: 32] = out_chunk[i];
            end
            done = 1;
        end
        else if (~reset) begin
            done = 0;

            out_chunk[0] = 'h6a09e667;
            out_chunk[1] = 'hbb67ae85;
            out_chunk[2] = 'h3c6ef372;
            out_chunk[3] = 'ha54ff53a;
            out_chunk[4] = 'h510e527f;
            out_chunk[5] = 'h9b05688c;
            out_chunk[6] = 'h1f83d9ab;
            out_chunk[7] = 'h5be0cd19;
    
            a = out_chunk[0];
            b = out_chunk[1];
            c = out_chunk[2];
            d = out_chunk[3];
            e = out_chunk[4];
            f = out_chunk[5];
            g = out_chunk[6];
            h = out_chunk[7];

            for (i=0; i < 8; i = i + 1) begin
                out[255-i*32 -: 32] = out_chunk[i];
            end
        end
    end
endmodule
