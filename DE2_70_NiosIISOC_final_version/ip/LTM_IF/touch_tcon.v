// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	DE2 LTM module Timing control and output image data
//					form sdram 
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            		:| Mod. Date :| Changes Made:
//   V1.0 :| Johnny Fan				:| 07/06/30  :| Initial Revision
// --------------------------------------------------------------------

module touch_tcon (
  input             iCLK,             // LCD display clock
  input             iRST_n,           // systen reset
  // SDRAM SIDE 
//  input [15:0]      iREAD_DATA1,      // R and G  color data form sdram 	
//  input [15:0]      iREAD_DATA2,      // B color data form sdram
  input [7:0]       iRed,
  input [7:0]       iGreen,
  input [7:0]       iBlue,
  output            oREAD_SDRAM_EN,   // read sdram data control signal
  //LCD SIDE
  output  reg       oHD,              // LCD Horizontal sync
  output  reg       oVD,              // LCD Vertical sync
  output  reg       oDEN,             // LCD Data Enable
  output  reg [7:0] oLCD_R,           // LCD Red color data
  output  reg [7:0] oLCD_G,           // LCD Green color data
  output  reg [7:0] oLCD_B            // LCD Blue color data
);

parameter H_LINE = 1056;
parameter V_LINE = 525;
parameter Hsync_Blank = 216;
parameter Hsync_Front_Porch = 40;
parameter Vertical_Back_Porch = 35;
parameter Vertical_Front_Porch = 10;

reg   [10:0]  x_cnt;  
reg   [9:0]   y_cnt; 
wire  [7:0]   read_red;
wire  [7:0]   read_green;
wire  [7:0]   read_blue; 
wire          display_area;
reg           mhd;
reg           mvd;
reg           mden;

// This signal control reading data form SDRAM , if high read color data form sdram  .
assign  oREAD_SDRAM_EN = ( (x_cnt>Hsync_Blank-2)&&
                           (x_cnt<(H_LINE-Hsync_Front_Porch-1))&&
                           (y_cnt>(Vertical_Back_Porch-1))&&
                           (y_cnt<(V_LINE - Vertical_Front_Porch))
                         )?  1'b1 : 1'b0;

// This signal indicate the lcd display area .
assign  display_area = ((x_cnt>(Hsync_Blank-1)&& //>215
                        (x_cnt<(H_LINE-Hsync_Front_Porch))&& //< 1016
                        (y_cnt>(Vertical_Back_Porch-1))&& 
                        (y_cnt<(V_LINE - Vertical_Front_Porch))
                       ))  ? 1'b1 : 1'b0;

//assign  read_red    = display_area ? iREAD_DATA2[9:2] : 8'b0;
//assign  read_green  = display_area ? {iREAD_DATA1[14:10],iREAD_DATA2[14:12]}: 8'b0;
//assign  read_blue   = display_area ? iREAD_DATA1[9:2] : 8'b0;

//assign  read_red    = display_area ? iRed   : 8'b0;
//assign  read_green  = display_area ? iGreen : 8'b0;
//assign  read_blue   = display_area ? iBlue  : 8'b0;

///////////////////////// x  y counter  and lcd hd generator //////////////////
always@(posedge iCLK or negedge iRST_n) begin
  if (!iRST_n) begin
    x_cnt <= 11'd0;
    mhd   <= 1'd0;
  end
  else begin
    if (x_cnt == (H_LINE-1)) begin
        x_cnt <= 11'd0;
        mhd   <= 1'd0;
    end
    else begin
        x_cnt <= x_cnt + 11'd1;
        mhd  <= 1'd1;
    end
  end
end

always@(posedge iCLK or negedge iRST_n) begin
  if (!iRST_n)
    y_cnt <= 10'd0;
  else begin
    if (x_cnt == (H_LINE-1)) begin
        if (y_cnt == (V_LINE-1))
            y_cnt <= 10'd0;
        else
            y_cnt <= y_cnt + 10'd1;	
    end
    else
        y_cnt <= y_cnt;
  end
end

////////////////////////////// touch panel timing //////////////////
always@(posedge iCLK  or negedge iRST_n) begin
  if (!iRST_n)
    mvd  <= 1'b1;
  else if (y_cnt == 10'd0)
    mvd  <= 1'b0;
  else
    mvd  <= 1'b1;
end

always@(posedge iCLK  or negedge iRST_n) begin
  if (!iRST_n)
    mden  <= 1'b0;
  else if (display_area)
    mden  <= 1'b1;
  else
    mden  <= 1'b0;
end

always@(posedge iCLK or negedge iRST_n) begin
  if (!iRST_n) begin
    oHD     <= 1'd0;
    oVD     <= 1'd0;
    oDEN    <= 1'd0;
    oLCD_R  <= 8'd0;
    oLCD_G  <= 8'd0;
    oLCD_B  <= 8'd0;
  end
  else begin
    oHD     <= mhd;
    oVD     <= mvd;
    oDEN    <= mden;
    oLCD_R  <= iRed;
    oLCD_G  <= iGreen;
    oLCD_B  <= iBlue;
  end
end

endmodule
