`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2020 06:43:19
// Design Name: 
// Module Name: camellia
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


module camellia(
    // INPUT INTERFACE SIGNALS
    input          i_clk,
    input          i_reset_n,
    input          i_kvalid,
    input          i_pvalid,
    input          i_ready,
    input          i_encrypt,
    input [255:0]  i_key,
    input [1:0]    i_key_size,
    input [127:0]  i_plaintext,
    // OUTPUT INTERFACE SIGNALS
    output         o_kready,
    output         o_pready,
    output         o_valid,
    output [127:0] o_ciphertext

    );
    
    // WIRE DECLARATIONS
    wire w_sel_fout_0; 
    wire w_sel_round0_in1; 
    wire w_sel_round0_in2;
         
    wire [1:0] w_sel_key_func_f; 
    wire [1:0] w_sel_next_D1; 
    wire [1:0] w_sel_next_D2; 
    wire [1:0] w_sel_prepostwhiteningkey_D1; 
    wire [1:0] w_sel_init_round_val_D1; 
    wire [1:0] w_sel_init_round_val_D2; 
    wire [1:0] w_sel_prepostwhiteningkey_D2;
    
    wire [2:0] w_sel_key_func_fl; 
    wire [2:0] w_sel_key_func_flinv; 
    wire [1:0] w_key_size;
               
    wire w_encrypt;           
    wire w_load_KA; 
    wire w_load_KB; 
    wire w_clear_D; 
    wire w_load_ciphertext; 
    wire w_inc_round; 
    wire w_clr_round;
              
    wire [4:0]  w_round;    
    wire [4:0]  w_sel_roundkey;
    
    // DATA PATH INSTANTIATION ---------------------------------------------------------------------------------
    camellia_datapath     camellia_datapath_U1(
                                               .i_clk(i_clk),
                                               .i_reset_n(i_reset_n),
                                               .i_kvalid(i_kvalid),
                                               .i_kready(o_kready),
                                               .i_key_size(w_key_size),                                     //[1;0]
                                               .i_key(i_key),                                               //[255:0]
                                               .i_encrypt(w_encrypt),
                                               .i_plaintext(i_plaintext),                                   //[127:0]
                                               .i_sel_key_func_f(w_sel_key_func_f),                         //[1:0]
                                               .i_sel_next_D1(w_sel_next_D1),                               //[1:0]
                                               .i_sel_next_D2(w_sel_next_D2),                               //[1:0]
                                               .i_sel_key_func_fl(w_sel_key_func_fl),                       //[2:0]
                                               .i_sel_key_func_flinv(w_sel_key_func_flinv),                 //[2:0]
                                               .i_sel_prepostwhiteningkey_D1(w_sel_prepostwhiteningkey_D1), //[1:0]
                                               .i_sel_init_round_val_D1(w_sel_init_round_val_D1),           //[1:0]
                                               .i_sel_fout_0(w_sel_fout_0),         
                                               .i_sel_prepostwhiteningkey_D2(w_sel_prepostwhiteningkey_D2), //[1:0]
                                               .i_sel_init_round_val_D2(w_sel_init_round_val_D2),           //[1:0]
                                               .i_sel_round0_in1(w_sel_round0_in1),           
                                               .i_sel_round0_in2(w_sel_round0_in2),
                                               .i_sel_roundkey(w_sel_roundkey),
                                               .i_load_KA(w_load_KA),
                                               .i_load_KB(w_load_KB),
                                               .i_clear_D(w_clear_D),          
                                               .i_load_ciphertext(w_load_ciphertext),
                                               .i_inc_round(w_inc_round),
                                               .i_clr_round(w_clr_round),
                                               .o_round(w_round),                                           //[4:0]
                                               .o_ciphertext(o_ciphertext)                                  //[127:0]
                                              );
        
    //CONTROL PATH INSTANTIATION---------------------------------------------------------------------------------    
    camellia_controlpath camellia_controlpath_U2 (
                                               .i_clk(i_clk),
                                               .i_reset_n(i_reset_n),
                                               .i_kvalid(i_kvalid),
                                               .i_pvalid(i_pvalid),
                                               .i_ready(i_ready),
                                               .i_encrypt(i_encrypt),
                                               .i_key_size(i_key_size),                                     //[1:0]
                                               .i_round(w_round),                                           //[4:0]
                                               .o_sel_key_func_f(w_sel_key_func_f),                         //[1:0]
                                               .o_sel_next_D1(w_sel_next_D1),                               //[1:0]
                                               .o_sel_next_D2(w_sel_next_D2),                               //[1:0]
                                               .o_sel_key_func_fl(w_sel_key_func_fl),                       //[2:0]
                                               .o_sel_key_func_flinv(w_sel_key_func_flinv),                 //[2:0]
                                               .o_sel_prepostwhiteningkey_D1(w_sel_prepostwhiteningkey_D1), //[1:0]
                                               .o_sel_init_round_val_D1(w_sel_init_round_val_D1),            //[1:0]
                                               .o_sel_fout_0(w_sel_fout_0),
                                               .o_sel_prepostwhiteningkey_D2(w_sel_prepostwhiteningkey_D2),  //[1:0]
                                               .o_sel_init_round_val_D2(w_sel_init_round_val_D2),            //[1:0]
                                               .o_sel_round0_in1(w_sel_round0_in1),
                                               .o_sel_round0_in2(w_sel_round0_in2),
                                               .o_sel_roundkey(w_sel_roundkey),
                                               .o_load_KA(w_load_KA),
                                               .o_load_KB(w_load_KB),
                                               .o_clear_D(w_clear_D),
                                               .o_load_ciphertext(w_load_ciphertext),
                                               .o_inc_round(w_inc_round),
                                               .o_clr_round(w_clr_round),
                                               .o_kready(o_kready),
                                               .o_pready(o_pready),
                                               .o_valid(o_valid),
                                               .o_key_size(w_key_size),
                                               .o_encrypt(w_encrypt)
                                              );
    
     
endmodule

