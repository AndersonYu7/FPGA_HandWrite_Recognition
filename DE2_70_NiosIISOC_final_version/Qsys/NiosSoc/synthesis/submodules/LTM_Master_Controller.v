//`default_nettype none
module LTM_Master_Controller(
  // Avalon clock interface siganals
  input             csi_clockreset_clk,
  input             csi_clockreset_reset_n,
  // Signals for Avalon-MM master port
  output reg [31:0] avm_m1_address,
  output [3:0]      avm_m1_byteenable,
  output reg        avm_m1_read,
  output reg        avm_m1_flush,
  input             avm_m1_readdatavalid,
  output     [9:0]  avm_m1_burstcount,
  input  [31:0]     avm_m1_readdata,
  input             avm_m1_waitrequest,
  // Signals for Avalon-MM slave port
  input             avs_s1_write,
  input [31:0]      avs_s1_writedata,
  input             avs_s1_read,
  output reg  [31:0]   avs_s1_readdata,
  input [3:0]       avs_s1_address,
  output reg        avs_s1_waitrequest_n,
  input [3:0]       avs_s1_byteenable,
//  input             avs_s1_begintransfer,
  
  // user logic inputs and outputs
  input             avm_m1_export_iVD,
  input             avm_m1_export_iRDCLK,
  input             avm_m1_export_iRDREQ,
  output     [31:0] avm_m1_export_oRDDATA,
  output reg        avm_m1_export_oRDVal,
  output [9:0]      avm_m1_export_oPixelX,
  output [9:0]      avm_m1_export_oPixelY,
  output            avm_m1_export_oFIFO_FULL, // for debug only
  output            avm_m1_export_oFIFO_EMPTY // for debug only
);
//===========================================================================
// PARAMETER declarations
//===========================================================================
// SDRAM frame buffer start address
parameter ADDRESS_BASE = 32'h0800_0000;
parameter Fifo_Depth  = 1024;
parameter RD_LENGTH  = 256;
// LTM width : 640, height = 480
parameter LTM_width = 800;
parameter LTM_height = 480;
parameter BMPLENGTH = 800 * 480;

//===========================================================================
// PORT declarations
//===========================================================================

///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================

reg  [9:0]  rPixelCntX, rPixelCntY;
wire [31:0] wRAWRGB;
reg         pre_vdh, mStart, pre_vd;
reg  [31:0] address;
//wire [31:0] end_address;
wire        address_sload, is_increment_address, fifo_full, wRSflag;

wire [$clog2(Fifo_Depth)-1:0] read_side_fifo_wusedw;
wire [$clog2(Fifo_Depth)-1:0] rRD_LENGTH;
reg  [$clog2(Fifo_Depth)-1:0] rRDDataCnt;

reg  [2:0]  state;
reg  [31:0] rBMPAddr, rTestdata;
reg         rLcmEn;
wire [31:0] end_address; 
reg		[31:0]	object01_1;
reg		[31:0]	object01_2;
reg		[31:0]	object02_1;
reg		[31:0]	object02_2;
reg		[31:0]	object03_1;
reg		[31:0]	object03_2;
reg		[31:0]	object04_1;
reg		[31:0]	object04_2;
reg		[31:0]	object05_1;
reg		[31:0]	object05_2;
reg		[31:0]	object06_1;
reg		[31:0]	object06_2;
//=============================================================================
// Structural coding
//=============================================================================
assign avm_m1_byteenable        = 4'b1111;
assign avm_m1_export_oFIFO_FULL = (read_side_fifo_wusedw > (Fifo_Depth - RD_LENGTH))? 1 : 0;
assign rRD_LENGTH = RD_LENGTH; // 256
//assign end_address  = rBMPAddr + LENGTH * 4 - 1;
always@(posedge csi_clockreset_clk or negedge csi_clockreset_reset_n) begin
    if (!csi_clockreset_reset_n) begin
        rBMPAddr <= ADDRESS_BASE;
        avs_s1_waitrequest_n <= 1;
        rLcmEn <= 0;
        avs_s1_readdata <= 0;
    end
    else begin
        avs_s1_waitrequest_n <= 1;
        rLcmEn <= rLcmEn;
        rBMPAddr <= rBMPAddr;
        avs_s1_readdata <= avs_s1_readdata;
         case({avs_s1_read,avs_s1_write})
            2'b01: begin /* write */
                case (avs_s1_address)
                     0:
                        rBMPAddr  <= avs_s1_writedata; 
                     1:
                        rTestdata <= avs_s1_writedata; 
                     2:
                        rLcmEn    <= avs_s1_writedata[0];
               default:
                        rBMPAddr <= avs_s1_writedata;
                endcase
            end
            2'b10: begin /* read */
                case (avs_s1_address)
                    0:
                        avs_s1_readdata <= rBMPAddr;   
                    2:
                        avs_s1_readdata[0] <= rLcmEn;  

              default:
                        avs_s1_readdata <= rBMPAddr;
                endcase
            end
            2'b11: begin
                case (avs_s1_address)
                     0: begin
                        avs_s1_readdata <= rBMPAddr;
                        rBMPAddr  <= avs_s1_writedata;  end
                     1:begin
                        avs_s1_readdata <= rTestdata;
                        rTestdata <= avs_s1_writedata; end
                     2:begin
                        avs_s1_readdata[0] <= rLcmEn; 
                        rLcmEn    <= avs_s1_writedata[0]; end
               default:
                        rBMPAddr <= avs_s1_writedata;
                endcase
            end
            default: begin
                // do nothing
            end
        endcase
 
    end
end

//burst read operation
always@(posedge csi_clockreset_clk or negedge csi_clockreset_reset_n) begin
    if(!csi_clockreset_reset_n) begin    
        avm_m1_flush <= 0;
        mStart <= 0;
        pre_vdh <= 0;
    end 
    else begin
        pre_vdh <= avm_m1_export_iVD;
        avm_m1_flush <= avm_m1_flush;  //1
        if ( {pre_vdh, avm_m1_export_iVD}==2'b10) begin
            mStart <= rLcmEn;
//            if(rLcmEn) avm_m1_flush <= 1;
//            else avm_m1_flush <= 0;
        end
        else begin
            mStart <= mStart;
        end
    end
    
end


assign avm_m1_burstcount = rRD_LENGTH;  // read 256 word

reg [31:0] rBMPPixelCnt;
//burst read operation
always@(posedge csi_clockreset_clk or negedge csi_clockreset_reset_n) begin
    if(!csi_clockreset_reset_n) begin    
        avm_m1_address <= rBMPAddr;
        avm_m1_read <= 0;
        rRDDataCnt <= 0;
        state <= 3;
        rBMPPixelCnt <= 0;
    end
    else begin
        avm_m1_address <= avm_m1_address;        
        avm_m1_read <= avm_m1_read;
        rBMPPixelCnt <= rBMPPixelCnt;
        rRDDataCnt <= rRDDataCnt;
        state <= state;
            case (state)
               3: begin
                    avm_m1_address <= rBMPAddr;
                    rBMPPixelCnt <= 0;
                    rRDDataCnt <= 0;
                    avm_m1_read <= 0;
                    if(mStart) 
                        state <= 0;
                    else 
                        state <= state;
               end
               0: begin
                      rRDDataCnt <= 0;
                      if(rBMPPixelCnt > (BMPLENGTH-1)) begin
                          avm_m1_address <= rBMPAddr;//RD_LENGTH*4;
                          rBMPPixelCnt <= 0;
                      end
                      if(mStart)begin
                          if (read_side_fifo_wusedw < rRD_LENGTH) begin
                              avm_m1_read <= 1;
                              state <= 1; //burst read
                          end
                          else
                              avm_m1_read <= 0;
                      end
                      else begin
                        state <= 3; //burst read
                      end
                end
               1: begin  // wait burst read command finish
                      rRDDataCnt <= 0;
                      if (!avm_m1_waitrequest) begin // wait
                          avm_m1_read <= 0;
                          avm_m1_address <= avm_m1_address + RD_LENGTH*4;//RD_LENGTH*4;
                          state <= 2;
                      end
                  end
               2: begin  // wait read rRD_LENGTH data finish
                      if(avm_m1_readdatavalid) begin
                          rBMPPixelCnt <= rBMPPixelCnt + 1;
                          if (rRDDataCnt < (RD_LENGTH -1) ) begin
                              rRDDataCnt <= rRDDataCnt + 1;
                          end
                          else begin
                              state <= 0;
                              rRDDataCnt <= 0;
                          end
                      end
                      else begin
                          rRDDataCnt <= rRDDataCnt;
                      end
                  end
               default: begin
                      avm_m1_read <= 0;
                      rRDDataCnt <= 0;
                      state <= 0;
                      end
            endcase
    end
    
end


//assign avm_m1_export_oPixelX = rPixelCntX;
//assign avm_m1_export_oPixelY = rPixelCntY;
//
//reg     pre_Readvd;
//// calculate VGA pixel coordination
//always@(posedge avm_m1_export_iRDCLK or negedge csi_clockreset_reset_n) begin
//    if(!csi_clockreset_reset_n)begin
//        rPixelCntX <= 0;
//        rPixelCntY <= 0; pre_Readvd <= 0;
//    end
//    else begin
//        pre_Readvd <= avm_m1_export_iVD;
//        if({pre_Readvd, avm_m1_export_iVD}==2'b10) begin
//            rPixelCntX <= 0;
//            rPixelCntY <= 0;
//        end
//        else begin
//            if (avm_m1_export_iRDREQ) begin
//                if( rPixelCntX < LTM_width-1 ) begin
//                    rPixelCntX <= rPixelCntX + 1;
//                    rPixelCntY <= rPixelCntY;
//                end
//                else begin
//                    rPixelCntX <= 0;
//                    rPixelCntY <= rPixelCntY + 1;
//                end
//            end
//            else begin
//                rPixelCntX <= rPixelCntX;
//                rPixelCntY <= rPixelCntY;
//            end
//        end
//    end
//end

 

//always@(posedge csi_clockreset_clk or negedge csi_clockreset_reset_n) begin
//    if(!csi_clockreset_reset_n)begin
//        avm_m1_export_oRDDATA <= 0;
//    end
//    else begin
//        if(mStart) begin
////            if ((rPixelCntY<=3) && (rPixelCntX <=100))
////                avm_m1_export_oRDDATA <= 32'hFF0000ff;  //(X,Y)=(290, 295)~(340, 375)
////            else
//                avm_m1_export_oRDDATA <= wRGBData; // show red
//        end
//        else begin
//            avm_m1_export_oRDDATA <= 32'h0000ffff;
//        end
//    end
//end

wire [31:0] wRGBData;
// FIFO
UDCFIFO fifo0 (
  .aclr((~csi_clockreset_reset_n)|(~mStart)), // ~csi_clockreset_reset_n),  // avm_m1_flush
  .wrclk(csi_clockreset_clk),
  .wrreq(avm_m1_readdatavalid),
  .wrdata(avm_m1_readdata),
  .wrusedw(read_side_fifo_wusedw),
  
  .rdclk(avm_m1_export_iRDCLK),
  .rdreq(avm_m1_export_iRDREQ),
  .rddata(avm_m1_export_oRDDATA),  // avm_m1_export_oRDDATA wRGBData
  .rdempty(avm_m1_export_oFIFO_EMPTY)

);

endmodule
