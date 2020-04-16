/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input [15:0] Addr;
   input [15:0] DataIn;
   input        Rd;
   input        Wr;
   input        createdump;
   input        clk;
   input        rst;
   
   output [15:0] DataOut;
   output Done;
   output reg Stall;
   output CacheHit;
   output err;

    localparam IDLE = 4'h0;
    localparam WR_0 = 4'h1;
    localparam WR_1 = 4'h2;
    localparam WR_2 = 4'h3;
    localparam WR_3 = 4'h4;
    localparam R_0 = 4'h5;
    localparam R_1 = 4'h6;
    localparam R_2 = 4'h7;
    localparam R_3 = 4'h8;
    localparam WB_2 = 4'h9;
    localparam WB_3 = 4'ha;
    localparam ERR = 4'hx;

    wire hit, valid, dirty;
    wire Action, trueHit, validWrite, trueMiss, invalidMiss, validNoWrite, READ, WRITE;
    wire MemErr, CacheErr;
    reg FSMErr;
    reg MemWr, MemRd;
    reg done, comp, wb, latch, cHit;
    reg [1:0] bank;
    reg [2:0] offset;
    reg [3:0] nstate;
    wire [4:0] tagOut;
    wire [3:0] state;
    wire [2:0] Offset;
    wire [15:0] MemAddr, data, MemOut, AddrLatch, DataInLatch, data_in;
    wire WrLatch, RdLatch, write;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tagOut),
                          .data_out             (data),
                          .hit                  (hit),
                          .dirty                (dirty),
                          .valid                (valid),
                          .err                  (CacheErr),
                          // Inputs
                          .enable               (1'b1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (AddrLatch[15:11]),
                          .index                (AddrLatch[10:3]),
                          .offset               (Offset),
                          .data_in              (data_in),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (1'b1));

   four_bank_mem mem(// Outputs
                     .data_out          (MemOut),
                     .stall             (),
                     .busy              (),
                     .err               (MemErr),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              (MemAddr),
                     .data_in           (data),
                     .wr                (MemWr),
                     .rd                (MemRd));

    dff doneff(.q(Done), .d(done), .clk(clk), .rst(rst));
    dff hitff(.q(CacheHit), .d(cHit), .clk(clk), .rst(rst));
    dff stateff[3:0](.q(state), .d(nstate), .clk(clk), .rst(rst));

    latch AddrLatchl[15:0](.q(AddrLatch), .d(Addr), .en(latch));
    latch DataInLatchl[15:0](.q(DataInLatch), .d(DataIn), .en(latch));
    latch WrLatchl(.q(WrLatch), .d(Wr), .en(latch));
    latch RdLatchl(.q(RdLatch), .d(Rd), .en(latch));

    assign err = MemErr | CacheErr | FSMErr;

    assign Action = WrLatch | RdLatch;
    assign trueHit = hit & valid;
    assign validWrite = ~hit & valid & dirty;
    assign trueMiss = ~hit & ~valid;
    assign invalidMiss = hit & ~valid;
    assign validNoWrite = ~hit & valid & ~dirty;
    assign WRITE = Action & validWrite;
    assign READ = Action & ((trueMiss) | (invalidMiss) | (validNoWrite));

    assign MemAddr = {(MemWr) ? tagOut : AddrLatch[15:11], AddrLatch[10:3], bank, 1'b0};
    assign Offset = (~comp | validWrite) ? offset : AddrLatch[2:0];
    assign data_in = (wb) ? MemOut : DataInLatch;
    assign DataOut = data;
    assign write = wb | (WrLatch & comp & ~validWrite);

    always @* begin
        FSMErr = 0; done = 0; cHit = 0; comp = 0; latch = 0; Stall = 0; MemWr = 0;
        MemRd = 0; wb = 0; bank = 2'b00; offset = 3'b000; nstate = state;
        case (state)
            IDLE: begin
                nstate = (~Action | (Action & trueHit)) ? IDLE : 
                        (WRITE) ? WR_0 : 
                        (READ) ? R_0 : ERR;
                done = Action & trueHit;
                cHit = Action & trueHit;
                Stall = READ | WRITE;
                bank = 2'b00;
                MemRd = READ;
                MemWr = WRITE;
                offset = 3'b000;
                comp = 1;
                latch = 1;
            end
            WR_0: begin
                nstate = WR_1;
                Stall = 1;
                MemWr = 1;
                bank = 2'b01;
                offset = 3'b010;
            end
            WR_1: begin
                nstate = WR_2;
                Stall = 1;
                MemWr = 1;
                bank = 2'b10;
                offset = 3'b100;
            end
            WR_2: begin
                nstate = WR_3;
                Stall = 1;
                MemWr = 1;
                bank = 2'b11;
                offset = 3'b110;
            end
            WR_3: begin
                nstate = R_0;
                Stall = 1;
                bank = 2'b00;
                MemRd = 1;
            end
            R_0: begin
                nstate = R_1;
                Stall = 1;
                bank = 2'b01;
                MemRd = 1;
            end
            R_1: begin
                nstate = R_2;
                Stall = 1;
                bank = 2'b10;
                MemRd = 1;
                wb = 1;
                offset = 3'b000;
            end
            R_2: begin
                nstate = R_3;
                Stall = 1;
                bank = 2'b11;
                MemRd = 1;
                wb = 1;
                offset = 3'b010;
            end
            R_3: begin
                nstate = WB_2;
                Stall = 1;
                wb = 1;
                offset = 3'b100;
            end
            WB_2: begin
                nstate = WB_3;
                Stall = 1;
                wb = 1;
                offset = 3'b110;
            end
            WB_3: begin
                nstate = IDLE;
                Stall = 1;
                done = 1;
                comp = 1;
            end
            ERR: FSMErr = 1;
            default: FSMErr = 1;
        endcase
    end
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
