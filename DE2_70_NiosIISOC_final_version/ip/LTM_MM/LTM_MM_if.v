/*:
	a Avalon-MM interface, connect PSO module to Nios II.
*/

module LTM_MM_if(
                // avalon bus clock_reset IF
                csi_clockreset_clk,
                csi_clockreset_reset_n,
                // avalon bus master IF
                avm_m1_address,
                avm_m1_burstcount,
                avm_m1_byteenable,
                avm_m1_waitrequest,
                avm_m1_read,
                avm_m1_flush,
                avm_m1_readdatavalid,
                avm_m1_readdata,
                // avalon bus slave IF
                avs_s1_write,
                avs_s1_writedata,
                avs_s1_read,
                avs_s1_readdata,
                avs_s1_address,
                avs_s1_waitrequest_n,
                avs_s1_byteenable,
             // user logic inputs and outputs
                avm_m1_export_iVD,
                avm_m1_export_iRDCLK,
                avm_m1_export_iRDREQ,
                avm_m1_export_oRDDATA,
                avm_m1_export_oRDVal,
                avm_m1_export_oPixelX,
                avm_m1_export_oPixelY,
                avm_m1_export_oFIFO_FULL, // for debug only
                avm_m1_export_oFIFO_EMPTY // for debug only

);

//===========================================================================
// PARAMETER declarations
//===========================================================================
parameter LTM_ADDRESS = 32'h0800_0000;

//===========================================================================
// PORT declarations
//===========================================================================
  // Avalon clock interface siganals
  input             csi_clockreset_clk;
  input             csi_clockreset_reset_n;
  // Signals for Avalon-MM master port
  output     [31:0] avm_m1_address;
  output     [9:0]  avm_m1_burstcount;
  output     [3:0]  avm_m1_byteenable;

  output            avm_m1_read;
  output            avm_m1_flush;
  input             avm_m1_readdatavalid;
  input      [31:0] avm_m1_readdata;
  input             avm_m1_waitrequest;
  // Signals for Avalon-MM slave port
  input             avs_s1_write;
  input      [31:0] avs_s1_writedata;
  input             avs_s1_read;
  output     [31:0] avs_s1_readdata;
  input      [3:0]  avs_s1_address;
  output            avs_s1_waitrequest_n;
  input      [3:0]  avs_s1_byteenable;
  // user logic inputs and outputs
  input             avm_m1_export_iVD;
  input             avm_m1_export_iRDCLK;
  input             avm_m1_export_iRDREQ;
  output     [31:0] avm_m1_export_oRDDATA;
  output            avm_m1_export_oRDVal;
  output     [9:0]  avm_m1_export_oPixelX;
  output     [9:0]  avm_m1_export_oPixelY;
  output            avm_m1_export_oFIFO_FULL; // for debug only
  output            avm_m1_export_oFIFO_EMPTY; // for debug only

///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================

//=============================================================================
// Structural coding
//=============================================================================

LTM_Master_Controller # (.ADDRESS_BASE(LTM_ADDRESS)) 
  U1(
  // Avalon clock interface siganals
                .csi_clockreset_clk(csi_clockreset_clk),
                .csi_clockreset_reset_n(csi_clockreset_reset_n),
  // Signals for Avalon-MM master port
                .avm_m1_address     (avm_m1_address),
                .avm_m1_byteenable  (avm_m1_byteenable),
                .avm_m1_read        (avm_m1_read),
                .avm_m1_flush       (avm_m1_flush),
                .avm_m1_readdatavalid(avm_m1_readdatavalid),
                .avm_m1_burstcount  (avm_m1_burstcount),
                .avm_m1_readdata    (avm_m1_readdata),
                .avm_m1_waitrequest (avm_m1_waitrequest),
  // Signals for Avalon-MM slave port
                .avs_s1_write       (avs_s1_write),
                .avs_s1_writedata   (avs_s1_writedata),
                .avs_s1_read        (avs_s1_read),
                .avs_s1_readdata    (avs_s1_readdata),
                .avs_s1_address     (avs_s1_address),
                .avs_s1_waitrequest_n(avs_s1_waitrequest_n),
                .avs_s1_byteenable  (avs_s1_byteenable),
//  input             avs_s1_begintransfer,
  
  // user logic inputs and outputs
                .avm_m1_export_iVD  (avm_m1_export_iVD),
                .avm_m1_export_iRDCLK(avm_m1_export_iRDCLK),
                .avm_m1_export_iRDREQ(avm_m1_export_iRDREQ),
                .avm_m1_export_oRDDATA(avm_m1_export_oRDDATA),
                .avm_m1_export_oRDVal(avm_m1_export_oRDVal),
                .avm_m1_export_oPixelX(avm_m1_export_oPixelX),
                .avm_m1_export_oPixelY(avm_m1_export_oPixelY),
                .avm_m1_export_oFIFO_FULL(avm_m1_export_oFIFO_FULL), // for debug only
                .avm_m1_export_oFIFO_EMPTY(avm_m1_export_oFIFO_EMPTY) // for debug only
);

endmodule
