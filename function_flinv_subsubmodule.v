`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.06.2020 09:40:25
// Design Name: 
// Module Name: function_flinv_subsubmodule
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


module camellia_FLINV_function(
    // input is a 64-bit FLINVIN and a subkey KE2
    input  [63:0] i_flinvin,
    input  [63:0] i_ke2,
    // output is 64-bit FLINVOUT
    output [63:0] o_flinvout
    );
    
    wire [31:0] w_n1,w_n2,w_n3;
    
    assign w_n1 = i_flinvin[63:32] ^ ( i_flinvin[31:0] | i_ke2[31:0]);
    assign w_n2 = w_n1 & i_ke2[63:32];
    assign w_n3 = i_flinvin[31:0] ^ {w_n2[30:0],w_n2[31]};
    assign o_flinvout = {w_n1,w_n3};
    
endmodule
