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

    wire hit0, valid0, dirty0, hit1, valid1, dirty1, hit, valid, dirty, write0, write1;
    wire Action, trueHit, validWrite, trueMiss, invalidMiss, validNoWrite, READ, WRITE, sel;
    wire MemErr, CacheErr0, CacheErr1;
    reg FSMErr;
    reg MemWr, MemRd;
    reg done, comp, latch, cHit, flip, write;
    reg [1:0] bank;
    reg [2:0] offset;
    reg [3:0] nstate;
    reg [15:0] data_in;
    wire [4:0] tagOut0, tagOut1, tagOut;
    wire [3:0] state;
    // wire [2:0] Offset;
    wire [15:0] MemAddr, data, data0, data1, MemOut, AddrLatch, DataInLatch;
    wire WrLatch, RdLatch;
    wire vic, victim;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tagOut0),
                          .data_out             (data0),
                          .hit                  (hit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (CacheErr0),
                          // Inputs
                          .enable               (1'b1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (AddrLatch[15:11]),
                          .index                (AddrLatch[10:3]),
                          .offset               (offset),
                          .data_in              (data_in),
                          .comp                 (comp),
                          .write                (write0),
                          .valid_in             (1'b1));
                          
    cache #(2 + memtype) c1(// Outputs
                            .tag_out              (tagOut1),
                            .data_out             (data1),
                            .hit                  (hit1),
                            .dirty                (dirty1),
                            .valid                (valid1),
                            .err                  (CacheErr1),
                            // Inputs
                            .enable               (1'b1),
                            .clk                  (clk),
                            .rst                  (rst),
                            .createdump           (createdump),
                            .tag_in               (AddrLatch[15:11]),
                            .index                (AddrLatch[10:3]),
                            .offset               (offset),
                            .data_in              (data_in),
                            .comp                 (comp),
                            .write                (write1),
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
    dff victimff(.q(victim), .d(vic), .clk(clk), .rst(rst));

    latch AddrLatchl[15:0](.q(AddrLatch), .d(Addr), .en(latch));
    latch DataInLatchl[15:0](.q(DataInLatch), .d(DataIn), .en(latch));
    latch WrLatchl(.q(WrLatch), .d(Wr), .en(latch));
    latch RdLatchl(.q(RdLatch), .d(Rd), .en(latch));

    assign err = MemErr | CacheErr0 | CacheErr1 | FSMErr;

    assign sel = (hit1) ? 1 :  // selected line will hit after access read
                (hit0) ? 0 : 
                (~valid0) ? 0 : 
                (~valid1) ? 1 : 
                vic;

    assign Action = WrLatch | RdLatch;
    assign hit = (sel) ? hit1 : hit0;
    assign valid = (sel) ? valid1 : valid0;
    assign dirty = (sel) ? dirty1 : dirty0;
    assign trueHit = hit & valid;
    assign validWrite = ~hit & valid & dirty;
    assign trueMiss = ~hit & ~valid;
    assign invalidMiss = hit & ~valid;
    assign validNoWrite = ~hit & valid & ~dirty;
    assign WRITE = Action & validWrite;
    assign READ = Action & ((trueMiss) | (invalidMiss) | (validNoWrite));

    assign MemAddr = {(MemWr) ? tagOut : AddrLatch[15:11], AddrLatch[10:3], bank, 1'b0};
    assign vic = (flip) ? ~victim : victim;
    assign data = (sel) ? data1 : data0;
    assign tagOut = (sel) ? tagOut1 : tagOut0;
    assign DataOut = data;
    assign write0 = ~sel & write;
    assign write1 = sel & write;

    always @* begin
        FSMErr = 0; done = 0; cHit = 0; comp = 0; latch = 0; Stall = 0; MemWr = 0; write = 0;
        MemRd = 0; bank = 2'b00; offset = AddrLatch[2:0]; nstate = state; data_in = DataInLatch; flip = 0;
        case (state)
            IDLE: begin
                nstate = (~Action | (Action & trueHit)) ? IDLE : 
                        (WRITE) ? WR_0 : 
                        (READ) ? R_0 : ERR;
                done = Action & trueHit;
                cHit = Action & trueHit;
                Stall = READ | WRITE;
                write = Action & trueHit & WrLatch;
                flip = Action;
                bank = 2'b00;
                MemRd = READ;
                MemWr = WRITE;
                offset = (WRITE) ? 3'b000 : AddrLatch[2:0];
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
                data_in = MemOut;
                write = 1;
                offset = 3'b000;
            end
            R_2: begin
                nstate = R_3;
                Stall = 1;
                bank = 2'b11;
                MemRd = 1;
                data_in = MemOut;
                write = 1;
                offset = 3'b010;
            end
            R_3: begin
                nstate = WB_2;
                Stall = 1;
                data_in = MemOut;
                write = 1;
                offset = 3'b100;
            end
            WB_2: begin
                nstate = WB_3;
                Stall = 1;
                data_in = MemOut;
                write = 1;
                offset = 3'b110;
            end
            WB_3: begin
                nstate = IDLE;
                Stall = 1;
                done = 1;
                comp = 1;
                write = WrLatch;
            end
            ERR: FSMErr = 1;
            default: FSMErr = 1;
        endcase
    end
   
endmodule // mem_system

// DUMMY LINE FOR REV CONTROL :9:
