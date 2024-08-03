`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.06.2020 06:44:33
// Design Name: 
// Module Name: camellia_controlpath
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


module camellia_controlpath(
    //EXTERNAL INTERFACE INPUTS
    input            i_clk,
    input            i_reset_n,
    input            i_kvalid,
    input            i_pvalid,
    input            i_ready,
    input            i_encrypt,
    input [1:0]      i_key_size,
    //STATUS SIGNALS FROM DATA PATH REGISTERS    
    input [4:0]      i_round,
    //CONTROL SIGNALS FOR DATA PATH
    //------SELECT LINES FOR MUX
    output  [1:0]    o_sel_key_func_f,
    output  [1:0]    o_sel_next_D1,
    output  [1:0]    o_sel_next_D2,
    output  [2:0]    o_sel_key_func_fl,
    output  [2:0]    o_sel_key_func_flinv,
    output  [1:0]    o_sel_prepostwhiteningkey_D1,
    output  [1:0]    o_sel_init_round_val_D1,
    output           o_sel_fout_0,
    output  [1:0]    o_sel_prepostwhiteningkey_D2,
    output  [1:0]    o_sel_init_round_val_D2,
    output           o_sel_round0_in1,
    output           o_sel_round0_in2,
    output  [4:0]    o_sel_roundkey,
    //------LOAD SIGNALS FOR REGISTERS KA AND KB
    output           o_load_KA,
    output           o_load_KB,
    //------CLEAR SIGNAL FOR REGISTERS D1 AND D2
    output           o_clear_D,
    //-----LOAD SIGNAL FOR REGISTER CIPHERTEXT
    output           o_load_ciphertext,
    //-----INCREMENT AND CLEAR SIGNALS FOR COUNTER - ROUND
    output           o_inc_round,
    output           o_clr_round,
    //EXTERNAL OUTPUTS FROM CONTROL PATH FSM
    output           o_kready,
    output           o_pready,
    output           o_valid,
    output  [1:0]    o_key_size,
    output           o_encrypt 
           
    );
    
    reg r_kready;
    reg r_pready;
    reg r_valid;
        
    reg r_sel_fout_0;
    reg r_sel_round0_in1;
    reg r_sel_round0_in2;
        
    reg [1:0] r_sel_key_func_f;
    reg [1:0] r_sel_next_D1;
    reg [1:0] r_sel_next_D2; 
    reg [1:0] r_sel_prepostwhiteningkey_D1;
    reg [1:0] r_sel_init_round_val_D1;  
    reg [1:0] r_sel_init_round_val_D2; 
    reg [1:0] r_sel_prepostwhiteningkey_D2;
    
    reg [4:0] r_sel_roundkey;
    
    reg [1:0] r_key_size;
    reg r_encrypt;
              
    reg [2:0] r_sel_key_func_fl; 
    reg [2:0] r_sel_key_func_flinv;
    
    reg r_load_KA;
    reg r_load_KB; 
    reg r_load_ciphertext;
    reg r_clear_D; 
    reg r_inc_round; 
    reg r_clr_round;
    
    
    //CONTROL PATH FSM STATE ENCODING
    localparam [1:0] START              = 2'b00,
                     KEY_PHASE          = 2'b01,
                     DATA_RANDOMIZATION = 2'b10,
                     DONE               = 2'b11;
    
    // REGISTER DECLARATION FOR CURRENT STATE AND NEXT STATE VALUES
    reg [1:0] r_state, r_next;
    
    // UPDATE STATE REGISTER 
    always@(posedge i_clk)
    begin
        if(!i_reset_n)
            r_state <= START;                                                          // ON RESET THE FSM IS COMES BACK TO START STATE
        else
            r_state <= r_next;                                                         // CURRENT STATE IS UPDATED WITH NEXT STATE VALUE ON CLK EDGE
    end
    
    // NEXT STATE LOGIC FOR CONTROL PATH FSM
    always@(*)
    begin
        r_next = 2'bxx;                                                                 // DEFAULT VALUE
        case(r_state)
        START              : begin    
                                if(i_kvalid)       r_next = KEY_PHASE;                  // IF A VALID KEY, KEYSIZE IS GIVEN, GO TO KEY PHASE STATE( HIGHER PRIORITY FOR KVALID)
                                else if(i_pvalid)  r_next = DATA_RANDOMIZATION;         // IF A VALID PLAINTEXT IS GIVEN, GO TO DATA RANDOMIZATION STATE
                                else               r_next = START;                      // ELSE STAY IN THE SAME STATE UNTILL YOU GET A VALID SIGNAL
                             end
        KEY_PHASE          : begin
                                if(r_key_size == 2'b00 && i_round == 5'd3)              // IF IT IS A 128-BIT KEY, KEY PHASE IS FOR 3 CYCLES
                                                   r_next = START;                      
                                else if((r_key_size == 2'b01 || r_key_size == 2'b10) && i_round == 5'd5)
                                                   r_next = START;                      // IF THE KEY IS 192/256 BIT, KEY PHASE IS FOR 5 CYCLES
                                else               r_next = KEY_PHASE;                  // ....AFTER THE SPECIFIED NUMBER OF CYCLES THE FSM ENTERS START STATE
                             end
        DATA_RANDOMIZATION : begin
                                if(r_key_size == 2'b00 && i_round == 5'd17)             // FOR A 128-BIT KEY THE DATA RANDOMIZATIO STATE IS FOR 17 CYCLES
                                                   r_next = DONE;
                                else if((r_key_size == 2'b01 || r_key_size == 2'b10) && i_round == 5'd23)
                                                   r_next = DONE;                       // FOR A 192/256-BIT KEY THE DATA RANDOMIZATION STATE IS FOR 23 CYCLES
                                else               r_next = DATA_RANDOMIZATION;         // ....AFTER THE DATA RANDOMIZATION STATE THE FSM ENTERS DONE STATE
                             end
        DONE               : begin
                                if(i_ready)        r_next = START;                      // AFTER THE USER TAKES THE VALID CIPHERTEXT WITH A READY SIGNAL
                                else               r_next = DONE;                       //  ...THE FSM ENTERS THE START STATE
                             end
        endcase
    end
    
    // COMBINATIONAL LOGIC FOR CONTROL SIGNALS OUTPUT FROM CONTROL PATH FSM
    always@(*)
    begin
        //default control signals values
        r_kready = 1'b0;
        r_pready = 1'b0;
        r_valid  = 1'b0;
        r_sel_fout_0 = 1'b0;
        r_sel_round0_in1 = 1'b0;
        r_sel_round0_in2 = 1'b0;
        r_sel_key_func_f  = 2'b00;
        r_sel_next_D1  = 2'b00; 
        r_sel_next_D2  = 2'b11;
        r_sel_prepostwhiteningkey_D1 = 2'b01;
        r_sel_init_round_val_D1 = 2'b00;
        r_sel_init_round_val_D2 = 2'b00;
        r_sel_prepostwhiteningkey_D2 = 2'b00;
        r_sel_key_func_fl  = 3'b000;
        r_sel_key_func_flinv  = 3'b000;
        r_sel_roundkey = 5'b00000;
        r_load_KA= 1'b0;
        r_load_KB= 1'b0;
        r_clear_D= 1'b0; 
        r_load_ciphertext = 1'b0;
        r_inc_round = 1'b0;
        r_clr_round = 1'b0;
        //r_key_size = 2'b00;
        //r_encrypt = 1'b0;
        
        case(r_state)
        START              : begin
                                r_kready = 1'b1;                  
                                r_pready = 1'b1;
                                if(i_kvalid)
                                begin                               //FIRST ROUND OF KEY PHASE
                                    //r_key_size = i_key_size;
                                    r_inc_round = 1'b1;
                                    r_sel_key_func_f = 2'b00;
                                    r_sel_next_D1 = 2'b11;
                                    r_sel_next_D2 = 2'b00;
                                    r_sel_prepostwhiteningkey_D1 = 2'b10;
                                    r_sel_init_round_val_D1 = 2'b01;
                                    r_sel_fout_0 = 1'b0;
                                    r_sel_prepostwhiteningkey_D2 = 2'b10;
                                    r_sel_init_round_val_D2 = 2'b01;
                                    r_sel_round0_in1 = 1'b1;
                                    r_sel_round0_in2 = 1'b1; 
                                end
                                else if(i_pvalid)
                                begin
                                    //r_encrypt = i_encrypt;         // FIRST ROUND OF DATA RANDOMIZATION
                                    if(r_encrypt) 
                                        r_sel_roundkey = i_round;
                                    else    
                                        begin 
                                        if(r_key_size == 2'b00) r_sel_roundkey = 17 - i_round;
                                        else                    r_sel_roundkey = 23 - i_round;
                                    end                       
                                    if (r_key_size == 2'b00) r_sel_key_func_f = 2'b01; else r_sel_key_func_f = 2'b10;
                                    r_sel_next_D1 = 2'b11;
                                    r_sel_next_D2 = 2'b00;
                                    r_sel_prepostwhiteningkey_D1 = 2'b01;
                                    r_sel_init_round_val_D1 = 2'b00;
                                    r_sel_fout_0 = 1'b0;
                                    r_sel_prepostwhiteningkey_D2 = 2'b01;
                                    r_sel_init_round_val_D2 = 2'b00;
                                    r_sel_round0_in1 = 1'b0;
                                    r_sel_round0_in2 = 1'b0;   
                                    r_inc_round = 1'b1;                             
                                end
                             end
        KEY_PHASE          : begin                              // SUBSEQUENT ROUNDS OF KEY PHASE
                                r_inc_round = 1'b1;
                                case(i_round)
                                5'd1    : begin
                                              r_sel_key_func_f = 2'b00; 
                                              r_sel_next_D1 = 2'b11;
                                              r_sel_next_D2 = 2'b00;
                                              r_sel_prepostwhiteningkey_D1 = 2'b11;
                                              r_sel_init_round_val_D1 = 2'b10;
                                              r_sel_fout_0 = 1'b1;
                                              r_sel_prepostwhiteningkey_D2 = 2'b11;
                                              r_sel_init_round_val_D2 = 2'b10;
                                           end
                                5'd2,5'd4
                                        : begin
                                              r_sel_key_func_f = 2'b00; 
                                              r_sel_next_D1 = 2'b00;
                                              r_sel_next_D2 = 2'b01;
                                          end
                                5'd3    : begin
                                              r_load_KA = 1'b1;
                                              r_sel_key_func_f = 2'b00; 
                                              if (r_key_size == 2'b00) r_sel_next_D1 = 2'b10; else r_sel_next_D1 = 2'b11;
                                              if (r_key_size == 2'b00) r_sel_next_D2 = 2'b11; else r_sel_next_D2 = 2'b00;
                                              r_sel_prepostwhiteningkey_D1 = 2'b10;
                                              r_sel_init_round_val_D1 = 2'b10;
                                              r_sel_fout_0 = 1'b1;
                                              r_sel_prepostwhiteningkey_D2 = 2'b10;
                                              r_sel_init_round_val_D2 = 2'b10;
                                              if (r_key_size == 2'b00) r_clear_D = 1'b1; else r_clear_D = 1'b0;
                                              if (r_key_size == 2'b00) r_clr_round = 1'b1; else r_clr_round = 1'b0;
                                          end
                                5'd5    : begin
                                              r_load_KB = 1'b1;
                                              r_sel_key_func_f = 2'b00;
                                              r_sel_next_D1 = 2'b10;
                                              r_sel_next_D2 = 2'b11;
                                              r_clear_D = 1'b1;
                                              r_clr_round = 1'b1;
                                          end
                                endcase
                             end
        DATA_RANDOMIZATION : begin                                          // SUBSEQUENT ROUNDS OF DATA RANDOMIZATION PHASE
                                if(r_encrypt) 
                                    r_sel_roundkey = i_round;
                                else    
                                begin 
                                    if(r_key_size == 2'b00) r_sel_roundkey = 17 - i_round;
                                    else                    r_sel_roundkey = 23 - i_round;
                                end
                                if(r_key_size == 2'b00) r_sel_key_func_f = 2'b01; else r_sel_key_func_f = 2'b10;
                                case(i_round)
                                5'd1,5'd3,5'd7,5'd9,5'd13,5'd15,5'd19,5'd21  :
                                        begin
                                            r_inc_round = 1'b1;
                                            r_sel_next_D1 = 2'b10;
                                            r_sel_next_D2 = 2'b11; 
                                        end
                                5'd2,5'd4,5'd6,5'd8,5'd10,5'd12,5'd14,5'd16,5'd18,5'd20,5'd22  :
                                        begin
                                            r_inc_round = 1'b1;
                                            r_sel_next_D1 = 2'b00;
                                            r_sel_next_D2 = 2'b01;                               
                                        end
                                5'd5 :
                                        begin
                                            r_inc_round = 1'b1;
                                            r_sel_next_D1 = 2'b01;
                                            r_sel_next_D2 = 2'b10;
                                            if(r_key_size == 2'b00) r_sel_key_func_fl = 3'b000; else r_sel_key_func_fl = 3'b010;
                                            if(r_key_size == 2'b00) r_sel_key_func_flinv = 3'b000; else r_sel_key_func_flinv = 3'b010;
                                        end
                                5'd11 :
                                        begin
                                            r_inc_round = 1'b1;
                                            r_sel_next_D1 = 2'b01;
                                            r_sel_next_D2 = 2'b10;
                                            if(r_key_size == 2'b00) r_sel_key_func_fl = 3'b001; else r_sel_key_func_fl = 3'b011;
                                            if(r_key_size == 2'b00) r_sel_key_func_flinv = 3'b001; else r_sel_key_func_flinv = 3'b011;
                                        end                
                                5'd17 :
                                        begin
                                            if(r_key_size == 2'b00) r_sel_next_D1 = 2'b11; else r_sel_next_D1 = 2'b01;
                                            if(r_key_size == 2'b00) r_sel_next_D2 = 2'b00; else r_sel_next_D2 = 2'b10;
                                            r_sel_key_func_fl = 3'b100;
                                            r_sel_key_func_flinv = 3'b100; 
                                            r_sel_prepostwhiteningkey_D1 = 2'b00;
                                            r_sel_init_round_val_D1 = 2'b10;
                                            r_sel_fout_0 = 1'b1;
                                            r_sel_prepostwhiteningkey_D2 = 2'b00;
                                            r_sel_init_round_val_D2 = 2'b10;
                                            if(r_key_size == 2'b00) r_load_ciphertext = 1'b1; else r_load_ciphertext = 1'b0;
                                            r_inc_round = 1'b1;
                                        end
                                5'd23 :
                                        begin
                                            r_sel_next_D1 = 2'b11;
                                            r_sel_next_D2 = 2'b00;
                                            r_sel_prepostwhiteningkey_D1 = 2'b00;
                                            r_sel_init_round_val_D1 = 2'b10;
                                            r_sel_fout_0 = 1'b1;
                                            r_sel_prepostwhiteningkey_D2 = 2'b00;
                                            r_sel_init_round_val_D2 = 2'b10;
                                            r_load_ciphertext = 1'b1;
                                            r_inc_round = 1'b1;
                                        end
                                        
                                endcase
                             end
        DONE               : begin                                               //DONE STATE TO GIVE THE OUTPUT CIPHERTEXT
                                    r_valid = 1'b1;
                                    r_clear_D = 1'b1;
                                    r_clr_round = 1'b1;
                             end
        endcase
    end

    always@(i_kvalid & o_kready)
    begin
       r_encrypt <= i_encrypt;
    end
    
    

    always@(i_kvalid & o_kready)
    begin
        r_key_size <= i_key_size;
    end
        
    
 
    // ASSIGNING REGISTER VALUES TO OUTPUT WIRES
    
    assign o_encrypt = r_encrypt;
    assign o_key_size = r_key_size;
    
    assign o_kready = r_kready;
    assign o_pready = r_pready;
    assign o_valid = r_valid;
        
    assign o_sel_fout_0 = r_sel_fout_0;
    assign o_sel_round0_in1 = r_sel_round0_in1;
    assign o_sel_round0_in2 = r_sel_round0_in2;
        
    assign o_sel_key_func_f  = r_sel_key_func_f;
    assign o_sel_next_D1  = r_sel_next_D1;
    assign o_sel_next_D2  = r_sel_next_D2; 
    assign o_sel_prepostwhiteningkey_D1  = r_sel_prepostwhiteningkey_D1;
    assign o_sel_init_round_val_D1 = r_sel_init_round_val_D1; 
    assign o_sel_init_round_val_D2 = r_sel_init_round_val_D2; 
    assign o_sel_prepostwhiteningkey_D2 = r_sel_prepostwhiteningkey_D2;
    assign o_sel_roundkey = r_sel_roundkey;
              
    assign o_sel_key_func_fl = r_sel_key_func_fl;
    assign o_sel_key_func_flinv = r_sel_key_func_flinv;
    
    assign o_load_KA = r_load_KA;
    assign o_load_KB = r_load_KB; 
    assign o_load_ciphertext  = r_load_ciphertext;
    assign o_clear_D = r_clear_D; 
    assign o_inc_round = r_inc_round; 
    assign o_clr_round = r_clr_round;
    
    

            
endmodule

