
// ============================================================================
// Top Module for SHAKE256 with variable inputs and outputs.
//
//
// The MIT License (MIT)
//
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

// `timescale 1 ns / 10 ps
module shake256_top
(
  input                     clk_i,              //system clock
  input                     rst_ni,             //system reset, active low
  input                     start_i,            //start of SHAKE process, 1 clock pulse, assert before putting input data
  input   [63:0]            din_i,              //data input
  input                     din_valid_i,        //data input valid signal, transaction happens when both din_valid_i and din_ready_o HIGH
  input                     last_din_i,         //last data input, also used as first data output squeeze
  input   [3:0]             last_din_byte_i,    //byte length of last data input, 0 to 8 for DW=64
  input                     dout_ready_i,       //signal to request output data, transaction happens when both dout_ready_i and dout_valid_o HIGH
  output                    din_ready_o,        //signal showing shake module ready to receive input data, transaction happens when both din_valid_i and din_ready_o HIGH
  output  [63:0]            dout_o,             //data output
  output                    dout_valid_o        //data output valid signal, transaction happens when both dout_ready_i and dout_valid_o HIGH
);

localparam  DELIMITER = 8'h1F; //SHAKE128/256 Delimiter

//state parameter
localparam  S_IDLE      = 3'd0;
localparam  S_ABSORB    = 3'd1;
localparam  S_FULL      = 3'd2;
localparam  S_APPEND    = 3'd3;
localparam  S_LAST_FULL = 3'd4;
localparam  S_SQUEEZE   = 3'd5;

reg     [2:0]   state, nstate;  //current and next FSM state
reg             last_data;
reg             first_append;
reg     [3:0]   last_din_byte;


wire            buf_overflow;     //input buffer full signal
wire    [63:0]  sampled_din;      //sampled data buffered to data_buf
reg     [63:0]  last_sampled_din; //sampled data buffered to data_buf on last din
wire            buf_en;           //signal showing when data is sampled into buffer
reg     [7:0]   byte_cnt;         //input byte counter
wire    [7:0]   byte_cnt_next;    //next input byte counter

reg             dout_buf_available; //output buffer available
wire            last_dout_buf;      //last data output buffer
reg     [4:0]   dout_buf_cnt;       //output buffer counter

reg     [1087:0]  data_buf;   //input/output data buffer


wire                keccak_start;
wire                keccak_squeeze;
wire                keccak_ready;
wire    [1599:0]    keccak_state_in;
wire    [1599:0]    keccak_state_out;


////////////////////////////////////////////////////////////////////////////////
//Input buffer data path
always @(posedge clk_i)
if(!rst_ni)
  data_buf <= 'h0;
else if(keccak_squeeze)
  data_buf <= keccak_state_out[1599-:1088];
else if(buf_en)
  data_buf <= {data_buf, sampled_din};
  
assign buf_en = din_ready_o & din_valid_i & (last_din_i? last_din_byte_i!=0 : 1'b1) | state==S_APPEND | dout_valid_o & dout_ready_i;
assign sampled_din = (din_ready_o & din_valid_i & last_din_i)? last_sampled_din :
                     state==S_APPEND? ((first_append & last_din_byte[2:0]==3'b000)? {DELIMITER, 56'd0} : 64'd0) :
                     state==S_SQUEEZE? 64'd0 :
                     din_i;


always @(*)
begin
  case(last_din_byte_i)
    1: last_sampled_din = {din_i[63-:1*8], DELIMITER, {6*8{1'b0}}};
    2: last_sampled_din = {din_i[63-:2*8], DELIMITER, {5*8{1'b0}}};
    3: last_sampled_din = {din_i[63-:3*8], DELIMITER, {4*8{1'b0}}};
    4: last_sampled_din = {din_i[63-:4*8], DELIMITER, {3*8{1'b0}}};
    5: last_sampled_din = {din_i[63-:5*8], DELIMITER, {2*8{1'b0}}};
    6: last_sampled_din = {din_i[63-:6*8], DELIMITER, {1*8{1'b0}}};
    7: last_sampled_din = {din_i[63-:7*8], DELIMITER             };
    default: last_sampled_din = din_i;
  endcase
end



//input byte counter
always @(posedge clk_i)
if(!rst_ni)
  byte_cnt <= 0;
else if(start_i | buf_overflow)
  byte_cnt <= 0;
else if(buf_en)
  byte_cnt <= byte_cnt_next;
  
assign byte_cnt_next = (state!=S_SQUEEZE & din_valid_i & last_din_i & last_din_byte_i==0)? byte_cnt : byte_cnt + 8;
assign buf_overflow  = buf_en & byte_cnt_next==136;

//Dout Buffer available signal
always @(posedge clk_i)
if(!rst_ni)
  dout_buf_available <= 0;
else if(start_i)
  dout_buf_available <= 0;
else if(keccak_squeeze)
  dout_buf_available <= 1;
else if(last_dout_buf & dout_ready_i)
  dout_buf_available <= 0;


assign last_dout_buf = buf_overflow;


////////////////////////////////////////////////////////////////////////////////
//shake FSM
always @(posedge clk_i)
if(!rst_ni)
  state <= S_IDLE;
else if(start_i)
  state <= S_ABSORB;
else
  state <= nstate;
  
always @(*)
begin
  nstate = state;
  case(state)
    S_IDLE      : if(start_i)
                    nstate = S_ABSORB;
    S_ABSORB    : if(din_valid_i & last_din_i & last_din_byte_i!=8 & byte_cnt==(136-8))
                    nstate = S_LAST_FULL;
                  else if(buf_overflow)
                    nstate = S_FULL;
                  else if(din_valid_i & last_din_i)
                    nstate = S_APPEND;
    S_FULL      : if(keccak_ready)
                    nstate = (last_data | last_din_i & din_valid_i)? S_APPEND : S_ABSORB;
    S_APPEND    : if(buf_overflow)
                    nstate = S_LAST_FULL;
    S_LAST_FULL : if(keccak_ready)
                    nstate = S_SQUEEZE;
    S_SQUEEZE   : if(start_i)
                    nstate = S_ABSORB;

    default     : nstate = S_IDLE;
  endcase
end


//last data signal, asserted when last din come, deasserted when reset or at start
always @(posedge clk_i)
if(!rst_ni) begin
  last_data     <= 0;
  first_append  <= 0;
  last_din_byte <= 0;
end
else if(start_i) begin
  last_data     <= 0;
  first_append  <= 0;
  last_din_byte <= 0;
end
else if(last_din_i & din_ready_o) begin
  last_data     <= 1;
  first_append  <= 1;
  last_din_byte <= last_din_byte_i;
end
else if (first_append & state==S_APPEND)
  first_append <= 0;

//data input ready
assign din_ready_o = state==S_ABSORB | state==S_FULL & keccak_ready & ~last_data;



////////////////////////////////////////////////////////////////////////////////
//keccak permutation interface
assign keccak_start     = (state==S_FULL | state==S_LAST_FULL) & keccak_ready;
assign keccak_squeeze   = state==S_SQUEEZE & keccak_ready & (~dout_buf_available | last_dout_buf & dout_ready_i);
assign keccak_state_in  = {keccak_state_out[1599-:1088]^ {data_buf[1087:8], data_buf[7]^(state==S_LAST_FULL), data_buf[6:0]}, keccak_state_out[1599-1088:0]};

assign dout_o       = data_buf[1087 -:64];
assign dout_valid_o = dout_buf_available;


keccak_top keccak_top (
    .Clock    (clk_i            ),      //System clock
    .Reset    (~rst_ni | start_i),      //Active HIGH reset signal
    .Start    (keccak_start     ),      //Start signal, valid on Ready
    .Din      (keccak_state_in  ),      //Data input byte stream, 200 bytes length. Valid during Start AND Ready
    .Req_more (keccak_squeeze   ),      //Request more data output, valid on Ready
    .Ready    (keccak_ready     ),      //keccak's ready signal
    .Dout     (keccak_state_out ));     //Data output byte stream, 200 bytes length



endmodule 
