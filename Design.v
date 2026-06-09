module VMC(
   input clk_i, 
   input rst_i, 
   //coin detected
   input coin5, 
   input coin10, 
   //Item selected
   input selA, 
   input selB, 
   input selC, 
   //Item dropped
   input itemSense, 
   //Stock availability - Products
   input stockA, 
   input stockB, 
   input stockC, 
   //Cancellation/ Finish purchase
   input cancel, 
   input finish, 
   //Stock availability - coins
   input stock5, 
   input stock10, 
   //Coin dropped
   input sense5, 
   input sense10,
   
   //Dispatch products
   output reg dispatchA, 
   output reg dispatchB, 
   output reg dispatchC, 
   //Dispatch coins
   output reg dispatch5, 
   output reg dispatch10, 
   //Remaining Balance
   output reg [7:0]balance,
   output reg no_fund
    );
    
    //intermediate net(s) or reg(s)
    reg [2:0]state;
    reg success_purchase;
    
    //parameters
    localparam
       //State(s)
       S0 = 3'b000,
       S1 = 3'b001,
       S2 = 3'b010,
       S3 = 3'b011,
       S4 = 3'b100, 
       S5 = 3'b101, 
       S6 = 3'b110,
       S7 = 3'b111;
       
    always@(posedge clk_i, posedge rst_i) begin
       
       if(rst_i) begin 
          state <= S0;
          //-----All signal rst -----
          balance <= 8'h00;
          no_fund <= 1'b1;
          success_purchase = 1'b0;
       end
       
       else begin
          case(state)
             //Idle
             S0: begin
                //-----All signal reset-----
                
                //Coin detected
                if(coin5) begin
                   state <= S1; 
                   balance <= balance + 8'd5;
                end
                else if(coin10) begin
                   state <= S1; 
                   balance <= balance + 8'd10;
                end
             end
             
             //Counting
             S1: begin
                //coin detected
                if(coin5) begin
                   balance <= balance + 8'd5;
                end
                else if(coin10) begin 
                   balance <= balance + 8'd10;
                end
                //selection detected
                if(selA) begin
                   state <= S2; 
                end
                else if(selB) begin
                   state <= S3; 
                end
                else if(selC) begin
                   state <= S4;
                end
             end
             
             //Selected A
             S2: begin
                //Verify and Dispatch
                if(itemSense) begin //=========== itemsense low time > clock ===========
                   if((stockA > 'd0) && (balance >= 'd10)) dispatchA <= 1'b1;
                   success_purchase <= 1'b1;
                end
                //Item dropped, Balance deduct
                else begin
                   dispatchA <= 1'b0;
                   state <= S1;
                   if(success_purchase) begin 
                      balance <= balance - 8'd10; 
                      success_purchase <= 1'b0;
                   end
                end
             end
             
             //Selected B
             S3: begin
                //Verify and Dispatch
                if(itemSense) begin
                   if((stockB > 'd0) && (balance >= 'd15)) dispatchB <= 1'b1;
                   success_purchase <= 1'b1;
                end
                //Item dropped, Balance deduct
                else begin
                   dispatchB <= 1'b0;
                   state <= S1;
                   if(success_purchase) begin 
                      balance <= balance - 8'd15; 
                      success_purchase <= 1'b0;
                   end
                end
             end
             
             //Selected C
             S4: begin
                //Verify and Dispatch
                if(itemSense) begin
                   if((stockC > 'd0) && (balance >= 'd20)) dispatchB <= 1'b1;
                   success_purchase <= 1'b1;
                end
                //Item dropped, Balance deduct
                else begin
                   dispatchC <= 1'b0;
                   state <= S1;
                   if(success_purchase) begin 
                      balance <= balance - 8'd20; 
                      success_purchase <= 1'b0;
                   end
                end
             end
             
             //Calculate Change - Greedy Algorithm
             S5: begin
                //dispatch coin
                if(stock10 && sense10 && (balance > 'd0) && (balance >= 'd10)) begin 
                   dispatch10 <= 1'b1;
                end
                else if(stock5 && sense5 && (balance > 'd0)) begin
                   dispatch5 <= 1'b1;
                end
                
                //coin dropped, balance deduct
                else if(~sense5) begin
                   balance <= balance - 'd5;
                end
                else if(~sense10) begin
                   balance <= balance - 'd10;
                end
                
                //no balance
                else if(~balance) begin 
                   state <= S0;
                end
             end
             
             //Remaining -- Connect Return/ Cancellation FSM (S5) to other stage(s)
             //          -- Stock and Coin availability Deduction
          endcase
       end
       
    end
    
endmodule
