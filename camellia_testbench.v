`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2020 09:02:07
// Design Name: 
// Module Name: camellia_testbench
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


module camellia_testbench;

    reg i_clk = 0;
    reg i_reset_n;
    reg i_kvalid;
    reg i_pvalid;
    reg i_ready;
    reg i_encrypt;
    reg [255:0]  i_key;
    reg  [1:0]    i_key_size;
    reg  [127:0]  i_plaintext;

    wire o_kready;
    wire o_pready;
    wire o_valid;
    wire [127:0] o_ciphertext;
    wire [1:0] state;
    wire [63:0] D1;
    wire [63:0] D2;
    wire [127:0] KL,KR,KA,KB;
    wire [4:0] round;
    wire [1:0] w_key_size;
    wire w_encrypt;
    /*wire [63:0] fin,ke,fout;
    wire [63:0] w_XOR_2,w_XOR_3,w_XOR_4,r_mux9_out,r_mux10_out;
    wire [1:0] r_sel_9;
    */        
    camellia            camellia_U1(
                                   .i_clk(i_clk),
                                   .i_reset_n(i_reset_n),
                                   .i_kvalid(i_kvalid),
                                   .i_pvalid(i_pvalid),
                                   .i_ready(i_ready),
                                   .i_encrypt(i_encrypt),
                                   .i_key(i_key),
                                   .i_key_size(i_key_size),
                                   .i_plaintext(i_plaintext),
    
                                   .o_kready(o_kready),
                                   .o_pready(o_pready),
                                   .o_valid(o_valid),
                                   .o_ciphertext(o_ciphertext)

                                  );

    assign state = camellia.camellia_controlpath_U2.r_state;
    //assign r_sel_9 = camellia.camellia_datapath_U1.i_sel_9;
    assign D1 = camellia.camellia_datapath_U1.r_D1;
    assign D2 = camellia.camellia_datapath_U1.r_D2;
    assign KL = camellia.camellia_datapath_U1.r_KL;
    assign KR = camellia.camellia_datapath_U1.r_KR;
    assign KA = camellia.camellia_datapath_U1.r_KA;
    assign KB = camellia.camellia_datapath_U1.r_KB;
    assign round = camellia.w_round;
    assign w_key_size = camellia.w_key_size;
    assign w_encrypt = camellia.camellia_datapath_U1.i_encrypt;
    /*assign fin = camellia.camellia_datapath_U1.w_mux2_out;
    assign ke = camellia.camellia_datapath_U1.r_mux4_out;
    assign fout = camellia.camellia_datapath_U1.w_fout;
    assign w_XOR_2 = camellia.camellia_datapath_U1.w_XOR_2;
    assign w_XOR_3 = camellia.camellia_datapath_U1.w_XOR_3;
    assign w_XOR_4 = camellia.camellia_datapath_U1.w_XOR_4;
    assign r_mux9_out = camellia.camellia_datapath_U1.r_mux9_out;
    assign r_mux10_out = camellia.camellia_datapath_U1.r_mux10_out;
    */
    always
        #5 i_clk = ~ i_clk; 

    initial 
    begin
            i_reset_n = 1'b1;
            i_kvalid = 1'b0;
            i_pvalid = 1'b0;
            i_ready  = 1'b0;
            i_encrypt = 1'b0;
            i_key = 256'b0;
            i_key_size = 2'b0;
            i_plaintext = 128'b0;
        #5  i_reset_n = 1'b0;
        #10 i_reset_n = 1'b1;
        #3
            i_kvalid = 1'b1;
            i_encrypt = 1'b1;
            i_key = 256'h0123456789abcdeffedcba9876543210;
            i_key_size = 2'b00;
        #10 i_kvalid = 1'b0;
            i_key = 256'h0;
            i_key_size = 2'b00;
            
        #68 i_pvalid = 1'b1;
            i_encrypt = 1'b0;
            i_plaintext =128'h0123456789abcdeffedcba9876543210;
        #11 i_pvalid = 1'b0;
            i_plaintext = 128'h0;
            
        #168 i_ready = 1'b1;
        #12  i_ready = 1'b0;
        
             i_pvalid = 1'b1;
             i_plaintext =128'h00112233445566778899aabbccddeeff;
         #11 i_pvalid = 1'b0;
             i_plaintext = 128'h0;
                    
        #168 i_ready = 1'b1;
        #12  i_ready = 1'b0;
             i_pvalid = 1'b1;
             i_encrypt = 1'b0;
             i_plaintext =128'h00000000000000000000000000000000;
         #11 i_pvalid = 1'b0;
             i_plaintext = 128'h0;
                    
        #229 i_ready = 1'b1;
        #12  i_ready = 1'b0;

             i_encrypt = 1'b0;
             i_kvalid = 1'b1;
             
             i_key = 256'h0123456789abcdeffedcba9876543210;
             i_key_size = 2'b00;
         #10 i_kvalid = 1'b0;
             i_key = 256'h0;
             i_key_size = 2'b00;
             i_encrypt = 1'b1;
             
         #27 i_pvalid = 1'b1;
             i_plaintext = 128'h67673138549669730857065648eabe43;
         #12 i_pvalid = 1'b0;
             i_plaintext = 128'h0;
         #168 i_ready = 1'b1;
         #12  i_ready = 1'b0;
         
         #30  i_pvalid = 1'b1;
              i_plaintext = 128'hfc7efecb37257b7e770981b32c8c222b;
          #12 i_pvalid = 1'b0;
              i_plaintext = 128'h0;
         #168 i_ready = 1'b1;
         #12  i_ready = 1'b0;
                  
              i_pvalid = 1'b1;
              i_plaintext = 128'ha66b04401ed5f1aa85dd78ef5a31aeb8;
          #12 i_pvalid = 1'b0;
              i_plaintext = 128'h0;
         #168 i_ready = 1'b1;
         #12  i_ready = 1'b0;
                                    
         
         
             
              i_encrypt = 1'b1;
              i_kvalid = 1'b1;
                      
              i_key = 256'h0123456789abcdeffedcba98765432100011223344556677;
              i_key_size = 2'b01;
         #11  i_encrypt = 1'b1;
              i_kvalid = 1'b0;
                                    
              i_key = 256'h0;
              i_key_size = 2'b00; 
         
         
         #49  i_pvalid = 1'b1;
              i_plaintext =128'h0123456789abcdeffedcba9876543210;
         #11  i_pvalid = 1'b0;
              i_plaintext = 128'h0;
         #228 i_ready = 1'b1;
         #12  i_ready = 1'b0;    
              i_encrypt = 1'b0;
              i_kvalid = 1'b1;
                                    
              i_key = 256'h0123456789abcdeffedcba98765432100011223344556677;
              i_key_size = 2'b01;
         #11  i_encrypt = 1'b1;
              i_kvalid = 1'b0;
                                                  
              i_key = 256'h0;
              i_key_size = 2'b00; 
                       
                       
         #49  i_pvalid = 1'b1;
              i_plaintext =128'hb4993401b3e996f84ee5cee7d79b09b9;
         #11  i_pvalid = 1'b0;
              i_plaintext = 128'h0;     
         #228 i_ready = 1'b1;     
         #11  i_ready = 1'b0; 

              i_encrypt = 1'b1;
              i_kvalid = 1'b1;
                      
              i_key = 256'h0123456789abcdeffedcba987654321000112233445566778899aabbccddeeff;
              i_key_size = 2'b10;
         #11  i_encrypt = 1'b1;
              i_kvalid = 1'b0;
                                    
              i_key = 256'h0;
              i_key_size = 2'b00; 
         
         
         #49  i_pvalid = 1'b1;
              i_plaintext =128'h0123456789abcdeffedcba9876543210;
         #11  i_pvalid = 1'b0;
              i_plaintext = 128'h0;
         #220 i_ready = 1'b1;
         #12  i_ready = 1'b0;    
              i_encrypt = 1'b0;
              i_kvalid = 1'b1;
                                    
              i_key = 256'h0123456789abcdeffedcba987654321000112233445566778899aabbccddeeff;
              i_key_size = 2'b10;
         #11  i_encrypt = 1'b1;
              i_kvalid = 1'b0;
                                                  
              i_key = 256'h0;
              i_key_size = 2'b00; 
                       
                       
         #49  i_pvalid = 1'b1;
              i_plaintext =128'h9acc237dff16d76c20ef7c919e3a7509;
         #11  i_pvalid = 1'b0;
              i_plaintext = 128'h0;     
         #228 i_ready = 1'b1;     
         #12  i_ready = 1'b0;                  
    end


endmodule

