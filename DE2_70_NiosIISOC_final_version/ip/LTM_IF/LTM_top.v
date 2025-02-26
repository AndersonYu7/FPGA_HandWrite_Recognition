// Description: This is D5M + LTM + Nios Demo Code
//              
//
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Shih-An Li        :| 03/10/2010:| Initial Revision
// --------------------------------------------------------------------

module LTM_top (
             iCLK50M,
             iRst_n,
             
             // lcd side
             iCLK_LTM,
             iLTMRGB,        // RGB color data
             oReadReq,
             oLTM_CLK,
             oLTM_VD,
             
             
             //  Export LTM signal
             iGPIO_CLKIN_N0,     // GPIO Connection 0 Clock Input 0
             iGPIO_CLKIN_P0,     // GPIO Connection 0 Clock Input 1
             GPIO_CLKOUT_N0,    // GPIO Connection 0 Clock Output 0
             GPIO_CLKOUT_P0,    // GPIO Connection 0 Clock Output 1
             GPIO_0,
             
             // Touch signal
            oX_COORD,
            oY_COORD,
            oNEW_COORD_DVAL

             );


//===========================================================================
// PARAMETER declarations
//===========================================================================


//===========================================================================
// PORT declarations
//===========================================================================


input           iCLK50M;
input           iRst_n;

             //  LTM signal
input           iCLK_LTM;
input  [23:0]   iLTMRGB;
output          oReadReq;
output          oLTM_CLK;
output          oLTM_VD;
             
input           iGPIO_CLKIN_N0;     // GPIO Connection 0 Clock Input 0
input           iGPIO_CLKIN_P0;     // GPIO Connection 0 Clock Input 1
inout           GPIO_CLKOUT_N0;    // GPIO Connection 0 Clock Output 0
inout           GPIO_CLKOUT_P0;    // GPIO Connection 0 Clock Output 1
inout  [31:0]   GPIO_0;

             // Touch Signals
output  [11:0]  oX_COORD;
output  [11:0]  oY_COORD;
output          oNEW_COORD_DVAL;

///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================

// Touch panel signal
wire  [7:0] ltm_r;    //  LTM Red Data 8 Bits
wire  [7:0] ltm_g;    //  LTM Green Data 8 Bits
wire  [7:0] ltm_b;    //  LTM Blue Data 8 Bits
wire        ltm_nclk; //  LTM Clcok
wire        ltm_hd;
wire        ltm_vd;
wire        ltm_den;
wire        adc_dclk;
wire        adc_cs;
wire        adc_penirq_n;
wire        adc_busy;
wire        adc_din;
wire        adc_dout;
wire        adc_ltm_sclk;
wire        ltm_grst;

// LTM Config
wire        ltm_sclk;
wire        ltm_sda;
wire        ltm_scen;
wire        ltm_3wirebusy_n;

reg   [2:0] rClk;

//=============================================================================
// Structural coding
//=============================================================================
assign oLTM_VD = ltm_vd;

////////////////////////////////////////////////////////////////////
/////   LTM signal
///////////////////////////////////////////////////////////////////
assign  adc_penirq_n    = iGPIO_CLKIN_N0;
assign  adc_dout        = GPIO_0[0];
assign  adc_busy        = iGPIO_CLKIN_P0;
assign  GPIO_0[1]       = adc_din;
assign  GPIO_0[2]       = adc_ltm_sclk;
assign  GPIO_0[3]       = ltm_b[3];
assign  GPIO_0[4]       = ltm_b[2];
assign  GPIO_0[5]       = ltm_b[1];
assign  GPIO_0[6]       = ltm_b[0];
assign  GPIO_0[7]       =~ltm_nclk;
assign  GPIO_0[8]       = ltm_den;
assign  GPIO_0[9]       = ltm_hd;
assign  GPIO_0[10]      = ltm_vd;
assign  GPIO_0[11]      = ltm_b[4];
assign  GPIO_0[12]      = ltm_b[5];
assign  GPIO_0[13]      = ltm_b[6];
assign  GPIO_CLKOUT_N0  = ltm_b[7];
assign  GPIO_0[14]      = ltm_g[0];
assign  GPIO_CLKOUT_P0  = ltm_g[1];
assign  GPIO_0[15]      = ltm_g[2];
assign  GPIO_0[16]      = ltm_g[3];
assign  GPIO_0[17]      = ltm_g[4];
assign  GPIO_0[18]      = ltm_g[5];
assign  GPIO_0[19]      = ltm_g[6];
assign  GPIO_0[20]      = ltm_g[7];
assign  GPIO_0[21]      = ltm_r[0];
assign  GPIO_0[22]      = ltm_r[1];
assign  GPIO_0[23]      = ltm_r[2];
assign  GPIO_0[24]      = ltm_r[3];
assign  GPIO_0[25]      = ltm_r[4];
assign  GPIO_0[26]      = ltm_r[5];
assign  GPIO_0[27]      = ltm_r[6];
assign  GPIO_0[28]      = ltm_r[7];
assign  GPIO_0[29]      = ltm_grst;
assign  GPIO_0[30]      = ltm_scen;
assign  GPIO_0[31]      = ltm_sda;

assign  ltm_grst = iRst_n;

always@(posedge iCLK50M) rClk <= rClk+1;
assign  ltm_nclk = rClk[2];  // Freq. 25M

assign  oLTM_CLK = rClk[2];
//assign ltm_grst = iKEY[0];
//assign adc_ltm_sclk     = ltm_sclk;
assign adc_ltm_sclk = ( adc_dclk & ltm_3wirebusy_n )  |  ( ~ltm_3wirebusy_n & ltm_sclk );

touch_tcon tcon0 (
  .iCLK(ltm_nclk),
  .iRST_n(iRst_n),
  // sdram side
  .iRed(iLTMRGB[7:0]),
  .iGreen(iLTMRGB[15:8]),
  .iBlue(iLTMRGB[23:16]),
  .oREAD_SDRAM_EN(oReadReq),
  // lcd side
  .oLCD_R(ltm_r),
  .oLCD_G(ltm_g),
  .oLCD_B(ltm_b),
  .oHD(ltm_hd),
  .oVD(ltm_vd),
  .oDEN(ltm_den)
);

lcd_3wire_config wire0 (
  // Host Side
  .iCLK(iCLK50M),
  .iRST_n(iRst_n),
  // 3 wire Side
  .o3WIRE_SCLK(ltm_sclk),
  .io3WIRE_SDAT(ltm_sda),
  .o3WIRE_SCEN(ltm_scen),
  .o3WIRE_BUSY_n(ltm_3wirebusy_n)
);

// Touch Screen Digitizer ADC configuration //
adc_spi_controller  u4 (
                    .iCLK(iCLK50M),
                    .iRST_n(iRst_n),
                    .oADC_DIN(adc_din),
                    .oADC_DCLK(adc_dclk),
                    .oADC_CS(adc_cs),
                    .iADC_DOUT(adc_dout),
                    .iADC_BUSY(adc_busy),
                    .iADC_PENIRQ_n(adc_penirq_n),
                    .oTOUCH_IRQ(oTOUCH_IRQ),
                    .oX_COORD(oX_COORD),
                    .oY_COORD(oY_COORD),
                    .oNEW_COORD(oNEW_COORD_DVAL)
                    );


endmodule 
