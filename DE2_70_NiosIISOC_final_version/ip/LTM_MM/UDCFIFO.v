// Description: 
//     Generate DCFIFO module
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Shih-An Li        :| 06/15/2011:| Initial Revision
// --------------------------------------------------------------------
//`default_nettype none
module UDCFIFO ( 
                      aclr,
                      wrclk,
                      wrreq,
                      wrdata,
                      wrusedw,
                      wrfull,
                      rdclk,
                      rdreq,
                      rddata,
                      rdusedw,
                      rdempty
                 );
//===========================================================================
// PARAMETER declarations
//===========================================================================
parameter Fifo_Depth = 2024;
parameter DATAWIDTH  = 32;
//===========================================================================
// PORT declarations
//===========================================================================
// write side
input                          aclr;
input                          wrclk;
input                          wrreq;
input  [DATAWIDTH-1:0]         wrdata;
output [$clog2(Fifo_Depth)-1:0] wrusedw;
output                         wrfull;

// read side
input                          rdclk;
input                          rdreq;
output [DATAWIDTH-1:0]         rddata;
output [$clog2(Fifo_Depth)-1:0] rdusedw;
output                         rdempty;

//=============================================================================
// REG/WIRE declarations
//=============================================================================


dcfifo fifo0 (
  .aclr(aclr), 
// write side
  .wrclk(wrclk),
  .wrreq(wrreq),
  .data(wrdata),
  .wrusedw(wrusedw),
  .wrfull(wrfull),

// read side
  .rdclk(rdclk),
  .rdreq(rdreq),
  .q(rddata),  
  .rdusedw(rdusedw),
  .rdempty(rdempty)
);

defparam fifo0.intended_device_family = "Cyclone IV GX";
defparam fifo0.lpm_width = DATAWIDTH;
defparam fifo0.lpm_numwords = Fifo_Depth;
defparam fifo0.lpm_showahead = "ON";
defparam fifo0.use_eab = "ON";
defparam fifo0.add_ram_output_register = "ON";
defparam fifo0.underflow_checking = "OFF";
defparam fifo0.overflow_checking = "OFF";
defparam fifo0.rdsync_delaypipe = 4;
defparam fifo0.wrsync_delaypipe = 4;
endmodule 