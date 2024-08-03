`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2020 06:44:02
// Design Name: 
// Module Name: camellia_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module camellia_datapath(
    // INPUTS - EXTERNAL INTERFACE 
    input           i_clk,
    input           i_reset_n,
    input           i_kvalid,
    input           i_kready,
    input  [1:0]    i_key_size,
    input  [255:0]  i_key,
    input           i_encrypt,
    input  [127:0]  i_plaintext,
    // CONTROL SIGNALS FROM CONTROL PATH
    // --------SELECT LINES FOR DIFFERENT MUX 
    input  [1:0]    i_sel_key_func_f,
    input  [1:0]    i_sel_next_D1,
    input  [1:0]    i_sel_next_D2,
    input  [2:0]    i_sel_key_func_fl,
    input  [2:0]    i_sel_key_func_flinv,
    input  [1:0]    i_sel_prepostwhiteningkey_D1,
    input  [1:0]    i_sel_init_round_val_D1,
    input           i_sel_fout_0,
    input  [1:0]    i_sel_prepostwhiteningkey_D2,
    input  [1:0]    i_sel_init_round_val_D2,
    input           i_sel_round0_in1,
    input           i_sel_round0_in2,
    input  [4:0]    i_sel_roundkey,
    //-------LOAD SIGNALS FOR REGISTERS KA AND KB
    input           i_load_KA,
    input           i_load_KB,
    //-------CLEAR SIGNAL FOR REGISTERS D1 AND D2 AFTER EVERY BLOCK OF DATA
    input           i_clear_D,
    //-------LOAD SIGNAL FOR CIPHERTEXT IN THE LAST ROUND OF DATA RANDOMIZATION STATE
    input           i_load_ciphertext,
    //-------INCREMENT AND CLEAR SIGNALS FOR COUNTER - ROUND
    input           i_inc_round,
    input           i_clr_round,
    //STATUS OUTPUT FOR CONTROL PATH
    output [4:0]    o_round,
    // EXTERNAL OUTPUT
    output [127:0]  o_ciphertext
    );
    
    
    // REGISITER DECLARATION
    reg [127:0] r_KL;
    reg [127:0] r_KR;
    reg [127:0] r_KA;
    reg [127:0] r_KB;
    reg [127:0] r_Ciphertext;
    
    reg [63:0] r_D1;
    reg [63:0] r_D2;
    
        
    reg  [63:0] r_key_func_f;            //mux4 output
    reg  [63:0] r_next_D1;                   //mux5 output
    reg  [63:0] r_next_D2;                   //mux6 output
    reg  [63:0] r_key_func_fl;           //mux7 output
    reg  [63:0] r_key_func_flinv;        //mux8 output
    reg  [63:0] r_prepostwhiteningkey_D1;    //mux9 output
    reg  [63:0] r_init_round_val_D1;     //mux10 output
    reg  [63:0] r_prepostwhiteningkey_D2;    //mux12 output
    reg  [63:0] r_init_round_val_D2;     //mux13 output
    reg  [63:0] r_sigma_key_func_f;      //mux16 output
    reg  [63:0] r_round18_key_func_f;    //mux17 output
    reg  [63:0] r_round24_key_func_f;    //mux18 output
    
    reg [4:0] r_round;
    
        
    //WIRE DECLARATION
    wire [63:0] w_round0_fin;         //mux1 output
    wire [63:0] w_fin;                //mux2 output
    wire [63:0] w_mux3_out;           //
    wire [63:0] w_fout_0;             //mux11 output
    wire [63:0] w_round0_inp1;        //mux14 output
    wire [63:0] w_round0_inp2;        //mux15 output

    wire [63:0] w_fout;
    wire [63:0] w_flout;
    wire [63:0] w_flinvout;
    
    
    wire [63:0] w_XOR_1;
    wire [63:0] w_XOR_2;
    wire [63:0] w_XOR_3;
    wire [63:0] w_XOR_4;

    wire [127:0] w_KL;
    wire [127:0] w_KR;    
       
    //FUNCTION - F--------------------------------------------------------------------------------------------------- 
    camellia_F_function camellia_F_function_u1        (.i_fin(w_fin),       //[63:0]
                                                       .i_ke(r_key_func_f),        //[63:0]
                                                       .o_fout(w_fout)           //[63:0]
                                                       );
                                               
    // FUNCTION - FL-------------------------------------------------------------------------------------------------
    camellia_FL_function camellia_FL_function_u2      (.i_flin(w_XOR_2),         //[63:0]
                                                       .i_ke1(r_key_func_fl),       //[63:0]
                                                       .o_flout(w_flout)         //[63:0]
                                                       );

    // FUNCTION - FLINV-----------------------------------------------------------------------------------------------
    camellia_FLINV_function camellia_FLINV_function_u3(.i_flinvin(r_D2),         //[63:0]
                                                       .i_ke2(r_key_func_flinv),       //[63:0]
                                                       .o_flinvout(w_flinvout)   //[63:0]
                                                       );
    //----------------------------------------------------------------------------------------------------------------

    // DATAPATH REGISTER KA-128 BIT WIDE------------------------------------------------------------------------------   
    always@(posedge i_clk)
    begin
        if(!i_reset_n)          r_KA <= 128'b0;
        else if(i_load_KA)      r_KA <= {w_XOR_2,r_D2};
    end
    
    //DATAPATH REGISTER KB-128 BIT WIDE------------------------------------------------------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n)          r_KB <= 128'b0;
        else if(i_load_KB)      r_KB <= {w_XOR_2,r_D2};
    end
    
    // DATAPATH REGISTER KL-128 BIT WIDE------------------------------------------------------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n)           r_KL <= 128'b0;
        else if(i_kvalid && i_kready)        r_KL <= w_KL;
    end
    
    //DATAPATH REGISTER KR-128 BIT WIDE------------------------------------------------------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n)          r_KR <= 128'b0;
        else if(i_kvalid && i_kready)       r_KR <= w_KR;
    end
   
    //DATAPATH REGISTER CIPHERTEXT TO STORE THE ENCRYPTED VALUE, 128-BIT-------------------------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n)         r_Ciphertext <= 128'b0;
        else if(i_load_ciphertext)      r_Ciphertext <= {r_next_D2,r_next_D1};
    end
    
    //DATA PATH COUNTER(5 BIT) - ROUND, TO KEEP TRACK OF NUMBER OF ROUNDS FOR SPECIFIC KEY SIZE---------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n || i_clr_round)            r_round <= 5'b0;
        else if(i_inc_round)                     r_round <= r_round + 1;
    end
    
    //DATA PATH TEMPORARY REGISTERS D1 AND D2, 64-BIT----------------------------------------------------------------------
    always@(posedge i_clk)
    begin
        if(!i_reset_n || i_clear_D)
        begin
            r_D1 <= 64'b0;
            r_D2 <= 64'b0;
        end
        else 
        begin
            r_D1 <= r_next_D1;
            r_D2 <= r_next_D2;
        end
    end
   
    //MUX 5, NEXT STATE VALUE FOR REGISTER D1------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_next_D1)
        2'b00 : r_next_D1 = r_D1;
        2'b01 : r_next_D1 = w_flout;
        2'b10 : r_next_D1 = w_XOR_2;
        2'b11 : r_next_D1 = w_XOR_3;
        endcase
    end    
    
    //MUX 6, NEXT STATE VALUE FOR REGISTER D2------------------------------------------------------------------------------    
    always@(*)
    begin
        case(i_sel_next_D2)
        2'b00 : r_next_D2 = w_XOR_4;
        2'b01 : r_next_D2 = w_XOR_2;
        2'b10 : r_next_D2 = w_flinvout;
        2'b11 : r_next_D2 = r_D2;
        endcase
    end    
    
    //MUX 7, SUBKEYS - KE1 FOR FUNCTION - FL ------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_key_func_fl)
        3'b000   : if(i_encrypt) r_key_func_fl = r_KA[97:34]; else r_key_func_fl = r_KL[114:51]; 
        3'b001   : if(i_encrypt) r_key_func_fl = {r_KL[50:0],r_KL[127:115]}; else r_key_func_fl = {r_KA[33:0],r_KA[127:98]}; 
        3'b010   : if(i_encrypt) r_key_func_fl = r_KR[97:34]; else r_key_func_fl = r_KA[114:51];
        3'b011   : if(i_encrypt) r_key_func_fl = r_KL[67:4]; else r_key_func_fl = {r_KL[3:0],r_KL[127:68]};
        3'b100   : if(i_encrypt) r_key_func_fl = {r_KA[50:0],r_KA[127:115]}; else r_key_func_fl = {r_KR[33:0],r_KR[127:98]};
        default  : r_key_func_fl = 64'b0;
        endcase
    end
    
    //MUX 8,SUBKEYS - KE2 FOR FUNCTION - FLINV ------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_key_func_flinv)
        3'b000   : if(i_encrypt) r_key_func_flinv = {r_KA[33:0],r_KA[127:98]}; else r_key_func_flinv = {r_KL[50:0],r_KL[127:115]};
        3'b001   : if(i_encrypt) r_key_func_flinv = r_KL[114:51]; else r_key_func_flinv = r_KA[97:34];
        3'b010   : if(i_encrypt) r_key_func_flinv = {r_KR[33:0],r_KR[127:98]}; else r_key_func_flinv = {r_KA[50:0],r_KA[127:115]};
        3'b011   : if(i_encrypt) r_key_func_flinv = {r_KL[3:0],r_KL[127:68]}; else r_key_func_flinv = r_KL[67:4];
        3'b100   : if(i_encrypt) r_key_func_flinv = r_KA[114:51]; else r_key_func_flinv = r_KR[97:34];
        default  : if(i_encrypt) r_key_func_flinv = 64'b0;
        endcase
    end

    wire [63:0] temp;
    
     
    //MUX 9-----------------------------------------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_prepostwhiteningkey_D1)
        2'b00  : if(!i_encrypt) r_prepostwhiteningkey_D1 = r_KL[63:0];
                 else 
                 begin if(i_key_size == 2'b00) r_prepostwhiteningkey_D1 = r_KA[80:17]; 
                       else                    r_prepostwhiteningkey_D1 = r_KB[80:17]; 
                 end
                   
        2'b01  : if(!i_encrypt) 
                 begin
                    if(i_key_size == 2'b00) r_prepostwhiteningkey_D1 = {r_KA[16:0],r_KA[127:81]};
                    else                    r_prepostwhiteningkey_D1 = {r_KB[16:0],r_KB[127:81]};
                 end
                 else r_prepostwhiteningkey_D1 = r_KL[127:64];
        2'b10  : begin if(&(~r_round)) r_prepostwhiteningkey_D1 = w_KR[127:64]; else r_prepostwhiteningkey_D1 = r_KR[127:64]; end
        2'b11  : r_prepostwhiteningkey_D1 = r_KL[127:64];
        endcase
    end

    //MUX 10---------------------------------------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_init_round_val_D1)
        2'b00  : r_init_round_val_D1 = i_plaintext[127:64];   
        2'b01  : r_init_round_val_D1 = w_KL[127:64];
        2'b10  : r_init_round_val_D1 = w_XOR_2;
        2'b11  : r_init_round_val_D1 = 64'b0;
        endcase
    end
    
    //MUX 12-------------------------------------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_prepostwhiteningkey_D2)
        2'b00  : if(i_encrypt)
                 begin if(i_key_size == 2'b00) r_prepostwhiteningkey_D2 = {r_KA[16:0],r_KA[127:81]}; 
                       else r_prepostwhiteningkey_D2 = {r_KB[16:0],r_KB[127:81]}; 
                 end
                 else r_prepostwhiteningkey_D2 = r_KL[127:64];                 
        2'b01  : if (i_encrypt) r_prepostwhiteningkey_D2 = r_KL[63:0];
                 else
                 begin if(i_key_size == 2'b00) r_prepostwhiteningkey_D2 = r_KA[80:17]; 
                       else r_prepostwhiteningkey_D2 = r_KB[80:17]; 
                 end
        2'b10  : begin if(&(~r_round)) r_prepostwhiteningkey_D2 = w_KR[63:0]; else r_prepostwhiteningkey_D2 = r_KR[63:0]; end
        2'b11  : r_prepostwhiteningkey_D2 = r_KL[63:0];
        endcase
    end
    
    //MUX 13---------------------------------------------------------------------------------------------------------------------------------------------
    always@(*)
    begin
        case(i_sel_init_round_val_D2)
        2'b00  : r_init_round_val_D2 = i_plaintext[63:0];  
        2'b01  : r_init_round_val_D2 = w_KL[63:0];
        2'b10  : r_init_round_val_D2 = r_D2;
        2'b11  : r_init_round_val_D2 = 64'b0;
        endcase
    end
            
    //MUX 16, SUBKEYS FOR KEY PHASE TO FUNCTION -F -----------------------------------------------------------------------------------------------------        
    always@(*)
    begin
        case(r_round)
        3'b000   : r_sigma_key_func_f = 64'hA09E667F3BCC908B;
        3'b001   : r_sigma_key_func_f = 64'hB67AE8584CAA73B2;
        3'b010   : r_sigma_key_func_f = 64'hC6EF372FE94F82BE;
        3'b011   : r_sigma_key_func_f = 64'h54FF53A5F1D36F1C;
        3'b100   : r_sigma_key_func_f = 64'h10E527FADE682D1D;
        3'b101   : r_sigma_key_func_f = 64'hB05688C2B3E6C1FD;
        default  : r_sigma_key_func_f = 64'h0;
        endcase
    end
    
    // MUX 17, SUBKEYS FOR DATA RANDOMIZATION PART TO FUNCTION - F, DEPENDING ON THE ROUND, KEY SIZE- 00(128-BITS)-------------------------------------------
    always@(*)
    begin
        case(i_sel_roundkey)
        5'd0     : r_round18_key_func_f = r_KA[127:64];
        5'd1     : r_round18_key_func_f = r_KA[63:0];
        5'd2     : r_round18_key_func_f = r_KL[112:49];
        5'd3     : r_round18_key_func_f = {r_KL[48:0],r_KL[127:113]};
        5'd4     : r_round18_key_func_f = r_KA[112:49];
        5'd5     : r_round18_key_func_f = {r_KA[48:0],r_KA[127:113]};
        5'd6     : r_round18_key_func_f = r_KL[82:19];
        5'd7     : r_round18_key_func_f = {r_KL[18:0],r_KL[127:83]};
        5'd8     : r_round18_key_func_f = r_KA[82:19];
        5'd9     : r_round18_key_func_f = {r_KL[3:0],r_KL[127:68]};
        5'd10    : r_round18_key_func_f = r_KA[67:4];
        5'd11    : r_round18_key_func_f = {r_KA[3:0],r_KA[127:68]};
        5'd12    : r_round18_key_func_f = {r_KL[33:0],r_KL[127:98]};
        5'd13    : r_round18_key_func_f = r_KL[97:34];
        5'd14    : r_round18_key_func_f = {r_KA[33:0],r_KA[127:98]};
        5'd15    : r_round18_key_func_f = r_KA[97:34];
        5'd16    : r_round18_key_func_f = {r_KL[16:0],r_KL[127:81]};
        5'd17    : r_round18_key_func_f = r_KL[80:17];
        default  : r_round18_key_func_f = 64'b0;
        endcase
    end
    
    // MUX 18, SUBKEYS FOR DATA RANDOMIZATION PART TO FUNCTION - F, DEPENDING ON THE ROUND, KEY SIZE- 01/10(192/256-BITS)-------------------------------------------
    always@(*)
    begin
        case(i_sel_roundkey)
        5'd0     : r_round24_key_func_f = r_KB[127:64]; 
        5'd1     : r_round24_key_func_f = r_KB[63:0];
        5'd2     : r_round24_key_func_f = r_KR[112:49];
        5'd3     : r_round24_key_func_f = {r_KR[48:0],r_KR[127:113]};
        5'd4     : r_round24_key_func_f = r_KA[112:49];
        5'd5     : r_round24_key_func_f = {r_KA[48:0],r_KA[127:113]};
        5'd6     : r_round24_key_func_f = r_KB[97:34];
        5'd7     : r_round24_key_func_f = {r_KB[33:0],r_KB[127:98]};
        5'd8     : r_round24_key_func_f = r_KL[82:19];
        5'd9     : r_round24_key_func_f = {r_KL[18:0],r_KL[127:83]};
        5'd10    : r_round24_key_func_f = r_KA[82:19];
        5'd11    : r_round24_key_func_f = {r_KA[18:0],r_KA[127:83]};
        5'd12    : r_round24_key_func_f = r_KR[67:4];
        5'd13    : r_round24_key_func_f = {r_KR[3:0],r_KR[127:68]};
        5'd14    : r_round24_key_func_f = r_KB[67:4];
        5'd15    : r_round24_key_func_f = {r_KB[3:0],r_KB[127:68]};
        5'd16    : r_round24_key_func_f = {r_KL[50:0],r_KL[127:115]};
        5'd17    : r_round24_key_func_f = r_KL[114:51];
        5'd18    : r_round24_key_func_f = {r_KR[33:0],r_KR[127:98]};
        5'd19    : r_round24_key_func_f = r_KR[97:34];
        5'd20    : r_round24_key_func_f = {r_KA[33:0],r_KA[127:98]};
        5'd21    : r_round24_key_func_f = r_KA[97:34];
        5'd22    : r_round24_key_func_f = {r_KL[16:0],r_KL[127:81]};
        5'd23    : r_round24_key_func_f = r_KL[80:17];
        default  : r_round24_key_func_f = 64'd0;
        endcase
    end
    
    //MUX 4, SUBKEY FOR FUNCTION F, FROM MUX16, MUX17 AND MUX 18---------------------------------------------------------------------------------------------- 
    always@(*)
    begin
        case(i_sel_key_func_f)
        2'b00  : r_key_func_f = r_sigma_key_func_f;
        2'b01  : r_key_func_f = r_round18_key_func_f;
        2'b10  : r_key_func_f = r_round24_key_func_f;
        2'b11  : r_key_func_f = 64'b0;
        endcase
    end
        
    //W_KL IS THE VALUE OF KL, REQUIRED IN THE FIRST ROUND OF KEY PHASE, BEFORE IT IS STORED IN REGISTER KL-------------------------------------------------------    
    assign w_KL = (i_kvalid && i_kready) ? (i_key_size == 2'b00)? i_key[127:0]   :
                               (i_key_size == 2'b01)? i_key[191:64]  :
                               (i_key_size == 2'b10)? i_key[255:128] : 
                                128'b0 : 128'b0;    
    
    //W_KL IS THE VALUE OF KR, REQUIRED IN THE FIRST ROUND OF KEY PHASE, BEFORE IT IS STORED IN REGISTER KR-------------------------------------------------------    
    assign w_KR = (i_kvalid && i_kready) ? (i_key_size == 2'b00)? 128'b0   :
                              (i_key_size == 2'b01)? {i_key[63:0],~i_key[63:0]}  :
                              (i_key_size == 2'b10)? i_key[127:0] : 
                              128'b0 : 128'b0;    

    //MUX 1, ONLY IN ROUND VALUE - 0(ZERO), IT SELECTS THE XOR1 OUTPUT, ELSE REGISTER D1--------------------------------------------------------------------------    
    assign w_round0_fin = (&(~r_round)) ? w_XOR_1 : r_D1;
    
    //MUX 2, IN EVEN ROUNDS THE FIN IS D1 , IN ODD ROUNDS FIN IS D2-----------------------------------------------------------------------------------------------
    assign w_fin = (r_round[0])  ? r_D2    : w_round0_fin;
    
    //MUX 3, HAS A SELECT LINE COMPLEMENT TO MUX 2----------------------------------------------------------------------------------------------------------------- 
    assign w_mux3_out = (~r_round[0]) ? r_D2    : r_D1;
            
    //MUX 11-------------------------------------------------------------------------------------------------------------------------------------------------------        
    assign w_fout_0 = (i_sel_fout_0)? 64'b0 : w_XOR_2;
    
    //MUX 14-------------------------------------------------------------------------------------------------------------------------------------------------------
    assign w_round0_inp1 = (i_sel_round0_in1)? w_KL[127:64] : i_plaintext[127:64];
   
    //MUX 15-------------------------------------------------------------------------------------------------------------------------------------------------------
    assign w_round0_inp2 = (i_sel_round0_in2)? w_KR[127:64] : (i_encrypt)? r_KL[127:64] : (i_key_size == 2'b00)? {r_KA[16:0],r_KA[127:81]} : {r_KB[16:0],r_KB[127:81]};
    
    //COMBINATIONAL XOR - 1
    assign w_XOR_1 = w_round0_inp1 ^ w_round0_inp2;
    
    //COMBINATIONAL XOR - 2
    assign w_XOR_2 = w_mux3_out ^ w_fout;
    
    //COMBINATIONAL XOR - 3
    assign w_XOR_3 = r_prepostwhiteningkey_D1 ^ r_init_round_val_D1;
    
    //COMBINATIONAL XOR - 4
    assign w_XOR_4 = w_fout_0 ^ r_prepostwhiteningkey_D2 ^ r_init_round_val_D2;
    
    // ASSIGN THE REGISTER VALUES TO WIRE OUTPUTS
    assign o_round = r_round;

    assign o_ciphertext = r_Ciphertext;
        
endmodule

  