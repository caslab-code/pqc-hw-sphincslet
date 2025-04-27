/*------------------------------------------------------------------------------
File        : shake256_top_tb.v
Description : testbench file for shake256_top module
//
//
// The MIT License (MIT)
//
// Copyright (c) 2024 Ma'muri
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
------------------------------------------------------------------------------*/

// `timescale 1 ns / 10 ps
module shake256_top_tb;
parameter PERIOD = 10; //100MHz
parameter DELAY  = 0.1*PERIOD;

parameter REF_BIT   = 2*1088;      //output reference bit size


reg                      clk_i;              //system clock
reg                      rst_ni;             //system reset, active low
reg                      start_i;            //start of SHAKE process, 1 clock pulse, assert before putting input data
reg    [63:0]            din_i;              //data input
reg                      din_valid_i;        //data input valid signal, transaction happens when both din_valid_i and din_ready_o HIGH
reg                      last_din_i;         //last data input, also used as first data output squeeze
reg    [3:0]             last_din_byte_i;    //byte length of last data input, 0 to 8 for DW=64
reg                      dout_ready_i;       //signal to request output data, transaction happens when both dout_ready_i and dout_valid_o HIGH
wire                     din_ready_o;        //signal showing shake module ready to receive input data, transaction happens when both din_valid_i and din_ready_o HIGH
wire   [63:0]            dout_o;             //data output
wire                     dout_valid_o;       //data output valid signal, transaction happens when both dout_ready_i and dout_valid_o HIGH
reg    [REF_BIT-1:0]     dout_ref;           //output reference

initial
begin
  clk_i = 0;
  rst_ni = 0;
  start_i = 0;
  din_valid_i = 0;
  last_din_i = 0;
  last_din_byte_i = 0;
  dout_ready_i = 0;

  #100 rst_ni = 1;

//==============================================================================

//--------------SHAKE-256------------------------

  #10 
  @(posedge clk_i) #(DELAY) start_i = 1;
  @(posedge clk_i) #(DELAY) start_i = 0;
  $display("\nTest SHAKE-256 with NULL (0 bytes input), and 2x136 bytes (2x17 of 64 bits) output\n");
  din_valid_i = 1;
  last_din_i = 1;
  last_din_byte_i = 0;
  $display("Input: NULL\n");
  @(posedge clk_i) #(DELAY);
  din_valid_i = 0;
  last_din_i = 0;
  dout_ref = 'h46b9dd2b0ba88d13233b3feb743eeb243fcd52ea62b81b82b50c27646ed5762fd75dc4ddd8c0f200cb05019d67b592f6fc821c49479ab48640292eacb3b7c4be141e96616fb13957692cc7edd0b45ae3dc07223c8e92937bef84bc0eab862853349ec75546f58fb7c2775c38462c5010d846c185c15111e595522a6bcd16cf86f3d122109e3b1fdd943b6aec468a2d621a7c06c6a957c62b54dafc3be87567d677231395f6147293b68ceab7a9e0c58d864e8efde4e1b9a46cbe854713672f5caaae314ed9083dab4b099f8e300f01b8650f1f4b1d8fcf3f3cb53fb8e9eb2ea203bdc970f50ae55428a91f7f53ac266b28419c3778a15fd248d339ede785fb7f5a1aaa96d313eacc890936c173cdcd0f;

  check_dout(2*1088/64);
  

//==============================================================================

  #50 
  @(posedge clk_i) #(DELAY) start_i = 1;
  @(posedge clk_i) #(DELAY) start_i = 0;
  $display("\nTest SHAKE-256 with 2*136+8+5 bytes input length, and 2x136 bytes (2x17 of 64 bits) output\nInput: ");
  din_valid_i = 1;
                                               din_i = {"blk1_d01"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d02"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d03"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d04"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d05"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d06"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d07"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d08"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d09"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d10"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d11"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d12"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d13"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d14"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d15"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d16"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk1_d17"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d01"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d02"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d03"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d04"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d05"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d06"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d07"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d08"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d09"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d10"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d11"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d12"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d13"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d14"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d15"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d16"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk2_d17"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk3_d01"}; $display("%s",din_i);
  wait(din_ready_o) @(posedge clk_i) #(DELAY); din_i = {"blk3_", 24'h0}; $display("%s\n",din_i);
  
  last_din_i = 1;
  last_din_byte_i = 5;
  @(posedge clk_i) #(DELAY);
  din_valid_i = 0;
  last_din_i = 0;   
  dout_ref = 'hd6847ff4ea82826e8b668fe4eb434d9f8ebbd4fa64503875cc789c7d7d9c880dcc3b170d6fda46d7b819df56e8fbff7ec4fc073c4a3e729f4039a9de0485d4ffe6ed238a2b27e3a79070712d524318dc9bcb688869385a905ce4d701ca2925ce8c597a27d5a4cb5b28ae313623df3e2be49476dfcf69368267a30c225f7e700d99f859ea8d0d687d9409174f45ed955304f0c2397440ebbbfa0159fe3a6ceb1420b76232f1952172374b17d0a1a7054c4df4f47c7b4aeb708e82ff256b5cfe6447ff4b99c202f6c85973c63dfd563aeb3ce770b79846668e13b024fa23924b9d728e8c3361138942394427d4638967622c38c2334a94f5c52907ee2f5cdb0330c21c72a2a95d4e26a85ce4af4cf317be;

  check_dout(2*1088/64);


//==============================================================================

//==============================================================================


  #100 $finish;
end

always #(PERIOD/2) clk_i = ~clk_i;

task automatic check_dout(input integer beat_number);
integer ii;
begin
    ii=0;
    if(beat_number != 0)
    begin
        while(ii != beat_number)
        begin
            @(posedge clk_i) #(DELAY) dout_ready_i = $random();
            if(dout_ready_i & dout_valid_o)
            begin
                $display("Beat [%d] ",ii);
                ii = ii+1;
            end
        end
        @(posedge clk_i) #(DELAY) dout_ready_i = 0;
    end
end    
endtask //automatic

always @(posedge clk_i)
if(dout_ready_i & dout_valid_o)
begin
    if(dout_o === dout_ref[REF_BIT-1 -: 64])
        $display("PASS - SHAKE-256: %x\n", dout_o);
    else
        $display("ERROR - SHAKE-256:\n out = %x ref: %x\n", dout_o, dout_ref[REF_BIT-1 -: 64]);

    dout_ref <= {dout_ref, 64'd0};
end


shake256_top shake256 (
  .clk_i             (clk_i          ),//system clock
  .rst_ni            (rst_ni         ),//system reset, active low
  .start_i           (start_i        ),//start of SHAKE process, 1 clock pulse, assert before putting input data
  .din_i             (din_i          ),//data input
  .din_valid_i       (din_valid_i    ),//data input valid signal, transaction happens when both din_valid_i and din_ready_o HIGH
  .last_din_i        (last_din_i     ),//last data input, also used as first data output squeeze
  .last_din_byte_i   (last_din_byte_i),//byte length of last data input, 0 to 8 for DW=64
  .dout_ready_i      (dout_ready_i   ),//signal to request output data, transaction happens when both dout_ready_i and dout_valid_o HIGH
  .din_ready_o       (din_ready_o    ),//signal showing shake module ready to receive input data, transaction happens when both din_valid_i and din_ready_o HIGH
  .dout_o            (dout_o         ),//data output
  .dout_valid_o      (dout_valid_o   ) //data output valid signal, transaction happens when both dout_ready_i and dout_valid_o HIGH
);

endmodule 
