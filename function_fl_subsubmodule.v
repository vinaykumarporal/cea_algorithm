`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2020 09:48:47
// Design Name: 
// Module Name: function_fl_subsubmodule
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


module camellia_FL_function(
    // input is a 64-bit FLIN and a subkey KE1
    input  [63:0] i_flin,
    input  [63:0] i_ke1,
    // output is 64-bit FLOUT
    output [63:0] o_flout 
    );
    
    wire [31:0] w_m1,w_m2,w_m3;
    
    assign w_m1 = i_flin[63:32] & i_ke1[63:32];
    assign w_m2 = i_flin[31:0] ^ {w_m1[30:0],w_m1[31]};
    assign w_m3 = i_flin[63:32] ^ (i_ke1[31:0] | w_m2);
    assign o_flout = {w_m3,w_m2};
    
endmodule
