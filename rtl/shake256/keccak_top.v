// ============================================================================
// Project:   SPHINCSLET
//
// Description:
//   Top-level module for the Keccak sponge function in Verilog.
//
// This code is modification of keccak.sv from https://github.com/jmoles/keccak-verilog/tree/main by Josh Moles,
// as top module of keccak permutation.
//
// The MIT License (MIT)
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
// ============================================================================


module keccak_top 
#(
    parameter N = 64,
    parameter IN_BUF_SIZE = 200,
    parameter OUT_BUF_SIZE = 200
)
(
    input                             Clock,       //System clock
    input                             Reset,       //Active HIGH reset signal
    input                             Start,       //Start signal, valid on Ready
    input   [200*8-1:0]               Din,         //Data input byte stream, 200 bytes length. Valid during Start AND Ready
    input                             Req_more,    //Request more data output, valid on Ready

    output  reg                       Ready,       //keccak's ready signal
    output  [200*8-1:0]               Dout
                );       //Data output byte stream, 200 bytes length


reg  [4:0]       counter_nr_rounds;
wire [N-1:0]    Round_constant_signal;
wire [1599:0]   state_in;
wire [1599:0]   state_out;
reg  [1599:0]    reg_data;
wire [1599:0]   swap_data_in, swap_data_out;
wire [1599:0]  Round_in, Round_out;


//Swapped input endiannes, byte streams to 64 bit data
genvar i;
generate
    for (i=0; i < 25; i=i+1)
    begin: swap_input

      
      assign swap_data_in[64*(i+1) -1:64*i] =   {   
                                                    Din[64*(i)+08-1:64*(i)+00], Din[64*(i)+16-1:64*(i)+08],
                                                    Din[64*(i)+24-1:64*(i)+16], Din[64*(i)+32-1:64*(i)+24],
                                                    Din[64*(i)+40-1:64*(i)+32], Din[64*(i)+48-1:64*(i)+40],
                                                    Din[64*(i)+56-1:64*(i)+48], Din[64*(i)+64-1:64*(i)+56]
                                                };
    end
endgenerate

assign state_in  = reg_data;
// assign Round_in  = bit_to_state(state_in);
assign Round_in  = state_in;

keccak_round 
keccak_round_i
    (
    .Round_in               (Round_in),
    .Round_constant_signal  (Round_constant_signal),
    .Round_out              (Round_out)
    );

keccak_round_constants_gen 
keccak_round_constants_gen_i
    (
    .round_number(counter_nr_rounds),
    .round_constant_signal_out(Round_constant_signal)
    );

assign state_out = Round_out;




genvar j;
generate
    for (j=0; j < 25; j=j+1)
    begin: swap_output

      
      assign swap_data_out[64*(j+1)-1:64*j] =   {   
                                                    reg_data[64*(j)+08-1:64*(j)+00], reg_data[64*(j)+16-1:64*(j)+08],
                                                    reg_data[64*(j)+24-1:64*(j)+16], reg_data[64*(j)+32-1:64*(j)+24],
                                                    reg_data[64*(j)+40-1:64*(j)+32], reg_data[64*(j)+48-1:64*(j)+40],
                                                    reg_data[64*(j)+56-1:64*(j)+48], reg_data[64*(j)+64-1:64*(j)+56]
                                                };
    end
endgenerate

assign Dout = swap_data_out;

//Data register
always @ (posedge Clock or posedge Reset) begin
    if(Reset) begin
        reg_data        <= 0;
    end else if(Start) begin
        reg_data        <= swap_data_in;
    end else if(~Ready) begin
        reg_data        <= state_out;
    end
end

//Counter and Ready assignments
always @ (posedge Clock or posedge Reset) begin
    if(Reset) begin
        counter_nr_rounds       <= 0;
        Ready                   <= 1;
    end else if((Start | Req_more) & Ready) begin
        counter_nr_rounds       <= 0;
        Ready                   <= 0;
    end else if(counter_nr_rounds == 23) begin
        counter_nr_rounds       <= 0;
        Ready                   <= 1;
    end else if(~Ready) begin
        counter_nr_rounds       <= counter_nr_rounds + 1;
    end
end


endmodule
