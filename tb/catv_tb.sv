// Copyright 2020 Robert Balas
// SPDX-License-Identifier: SHL-0.51

// test the catv_riscv core
//
// Author: Robert Balas (balasr@iis.ee.ethz.ch)

module catv_tb #(
  parameter int unsigned RAM_DATA_WIDTH = 32,
  parameter int unsigned RAM_NUM_BYTES = 1024 * 1024,
  parameter logic [31:0] BOOT_ADDR = 32'h0000_0180
);

  logic clk, rst_n;

  initial begin : clock
    clk = 1'b1;
    forever begin
      #1 clk = ~clk;
    end
  end : clock

  initial begin : reset
    rst_n = 1'b0;
    @(negedge clk);
    rst_n = 1'b1;
  end : reset

  initial begin : timing_format
    $timeformat(-9, 0, "ns", 9);
  end: timing_format

  logic [31:0] insn_addr;
  logic        insn_valid;
  logic        insn_ready;
  logic [31:0] insn_data;
  logic        insn_rvalid;

  logic [31:0] data_addr;
  logic        data_wen;
  logic [31:0] data_wdata;
  logic [3:0]  data_strb;
  logic        data_rvalid;
  logic [31:0] data_rdata;
  logic        data_valid;
  logic        data_ready;

  catv_riscv #(
    .BOOT_ADDR (BOOT_ADDR)
  ) i_catv_riscv (
    .clk_i                 (clk),
    .rst_ni                (rst_n),

    .insn_addr_o           (insn_addr),
    .insn_valid_o          (insn_valid),
    .insn_ready_i          (insn_ready),
    .insn_data_i           (insn_data),
    .insn_rvalid_i         (insn_rvalid),

    .data_addr_o           (data_addr),
    .data_wen_o            (data_wen),
    .data_wdata_o          (data_wdata),
    .data_strb_o           (data_strb),
    .data_rvalid_i         (data_rvalid),
    .data_rdata_i          (data_rdata),
    .data_valid_o          (data_valid),
    .data_ready_i          (data_ready),

    .hartid_i              (20'h0)
  );

  // bus with fixed priority arbitration (multiple master, multiple slaves)
  // response must always be one cycle later
  localparam int unsigned N_BUS_MASTERS = 2; // data bus, insn bus
  localparam int unsigned N_BUS_SLAVES = 2; // sram, pseudo stdout peripheral
  localparam int unsigned N_MASTER_BITS = N_BUS_MASTERS > 1 ? $clog2(N_BUS_MASTERS) : 1;
  localparam int unsigned N_SLAVE_BITS =  N_BUS_SLAVES  > 1 ? $clog2(N_BUS_SLAVES) : 1;

  logic        master_valid [N_BUS_MASTERS];
  logic        master_ready [N_BUS_MASTERS];
  logic [31:0] master_addr [N_BUS_MASTERS];
  logic        master_we [N_BUS_MASTERS];
  logic [3:0]  master_strb [N_BUS_MASTERS];
  logic [31:0] master_wdata [N_BUS_MASTERS];
  logic        master_rvalid [N_BUS_MASTERS];
  logic [31:0] master_rdata [N_BUS_MASTERS];

  logic [N_MASTER_BITS-1:0] master_sel_req;
  logic [N_MASTER_BITS-1:0] master_sel_resp;

  logic        slave_valid [N_BUS_SLAVES];
  logic        slave_ready [N_BUS_SLAVES];
  logic [31:0] slave_addr [N_BUS_SLAVES];
  logic        slave_we [N_BUS_SLAVES];
  logic [3:0]  slave_strb [N_BUS_SLAVES];
  logic [31:0] slave_wdata [N_BUS_SLAVES];
  logic        slave_rvalid [N_BUS_SLAVES];
  logic [31:0] slave_rdata [N_BUS_SLAVES];

  logic [N_SLAVE_BITS-1:0] slave_sel_req;
  logic [N_SLAVE_BITS-1:0] slave_sel_resp;

  logic [31:0] slave_addr_start [N_BUS_SLAVES];
  logic [31:0] slave_addr_end [N_BUS_SLAVES];

  always_comb begin : master_priority
    for (int i = N_BUS_MASTERS - 1; i >= 0; i--) begin
      if (master_valid[i]) begin
        master_sel_req = i;
      end
    end
  end : master_priority

  always_comb begin : slave_map
    for (int i = 0; i < N_BUS_SLAVES; i++) begin
      if ((master_addr[master_sel_req] >= slave_addr_start[i]) &&
          (master_addr[master_sel_req] <  slave_addr_end[i])) begin
        slave_sel_req = i;
      end
    end
  end : slave_map

  always_comb begin : route_request
    for (int i = 0; i < N_BUS_SLAVES; i++) begin
      if (i == slave_sel_req) begin
        slave_valid[i] = master_valid[master_sel_req];
        slave_we[i]    = master_we[master_sel_req];
        slave_addr[i]  = master_addr[master_sel_req];
        slave_wdata[i] = master_wdata[master_sel_req];
        slave_strb[i]  = master_strb[master_sel_req];
      end else begin
        slave_valid[i] = 1'b0;
        slave_we[i]    = 1'b0;
        slave_addr[i]  = 32'b0;
        slave_wdata[i] = 32'b0;
        slave_strb[i]  = 4'b0;
      end
    end
  end : route_request

  always_ff @(posedge clk, negedge rst_n) begin : resp_gen
    if (!rst_n) begin
      master_sel_resp <= '0;
      slave_sel_resp  <= '0;
    end else begin
      master_sel_resp <= master_sel_req;
      slave_sel_resp  <= slave_sel_req;
    end
  end : resp_gen

  always_comb begin : route_response
    for (int i = 0; i < N_BUS_MASTERS; i++) begin
      master_ready[i] = 1'b0;
      if (i == master_sel_resp) begin
        master_rvalid[i] = slave_rvalid[slave_sel_req];
        master_rdata[i]  = slave_rdata[slave_sel_req];
      end else begin
        master_rvalid[i] = 1'b0;
        master_rdata[i]  = 32'b0;
      end
    end
    master_ready[master_sel_req] = master_valid[master_sel_req]; // instant handshake
  end : route_response

  // ram (byte addressable, warns on misaligned access)
  localparam RAM_ADDR_WIDTH = $clog2(RAM_NUM_BYTES);
  logic [7:0] ram [RAM_NUM_BYTES-1:0];

  logic                        ram_req;
  logic                        ram_we;
  logic [RAM_ADDR_WIDTH-1:0]   ram_addr, ram_addr_q;
  logic [RAM_DATA_WIDTH-1:0]   ram_wdata;
  logic [RAM_DATA_WIDTH/8-1:0] ram_strb;
  logic [RAM_DATA_WIDTH-1:0]   ram_rdata;

  always_ff @(posedge clk) begin : ram_storage
    if (ram_req) begin
      // TODO: we allow misaligned accesses for now. In reality we should do
      // some realignment in the load store unit the core
      // assert (ram_addr[1:0] == 2'b0) else $error("attempting misaligned access to %0x8", ram_addr);
      if (!ram_we) begin
        ram_addr_q <= ram_addr;
      end else begin
        for (int i = 0; i < RAM_DATA_WIDTH/8; i++) begin
          if (ram_strb[i] == 1'b1) begin
            ram[ram_addr+i] <= ram_wdata[i*8 +: 8];
          end
        end
      end
    end
  end : ram_storage

  for (genvar i=0; i < RAM_DATA_WIDTH/8; i++) begin
    assign ram_rdata[i*8 +: 8] = ram[ram_addr_q+i];
  end


  initial begin : init_ram
    automatic string image;
    if ($value$plusargs("elf=%s", image)) begin
      $display("[tb] %t: loading elf dump %0s ...", $time, image);
      $readmemh(image, ram);
    end else begin
      $display("[tb] %t: no elf specified, stop", $time);
      $finish;
    end
  end : init_ram

  // peripherals (stdout, exit value)
  logic        periph_valid;
  logic        periph_we;
  logic [31:0] periph_wdata;
  logic [31:0] periph_addr;

  always_ff @(posedge clk, negedge rst_n) begin : peripheral
    if (periph_valid && periph_we) begin
      case (periph_addr)
        32'h8000_0000: begin // stdout
          if ($test$plusargs("verbose")) begin
            if (32 <= periph_wdata && periph_wdata < 128)
              $display("OUT: '%c'", periph_wdata[7:0]);
            else
              $display("OUT: %3d", periph_wdata);

          end else begin
            $write("%c", periph_wdata[7:0]);
`ifndef VERILATOR
            $fflush();
`endif
          end
        end

        32'h8000_0010: begin // result
        end

        32'h8000_0020: begin // exit
          if (periph_wdata == 32'b0) begin
            $display("[tb]: EXIT SUCCESS");
          end else begin
            $error("[tb]: EXIT FAILURE");
          end
          $finish();
        end

        default: begin
          $error("[tb]: out of bounds write to %08x", periph_addr);
          $fatal(2);
        end
      endcase // unique case (periph_addr)
    end
  end : peripheral

  // connect insn fetch to bus
  assign master_valid[0] = insn_valid;
  assign insn_ready      = master_ready[0];
  assign master_addr[0]  = insn_addr;
  assign master_we[0]    = 1'b0;  // always read
  assign master_strb[0]  = 4'hf;  // always full fetch
  assign master_wdata[0] = 32'b0; // never read
  assign insn_rvalid     = master_rvalid[0];
  assign insn_data       = master_rdata[0];

  // connect data fetch to bus
  assign master_valid[1] = data_valid;
  assign data_ready      = master_ready[1];
  assign master_addr[1]  = data_addr;
  assign master_we[1]    = data_wen;
  assign master_strb[1]  = data_strb;
  assign master_wdata[1] = data_wdata;
  assign data_rvalid     = master_rvalid[1];
  assign data_rdata      = master_rdata[1];

  // slave address map
  localparam logic [31:0] PERIPH_START = 32'h8000_0000;
  localparam logic [31:0] PERIPH_END   = 32'h9000_0000;

  localparam logic [31:0] RAM_START    = 32'h0000_0000;
  localparam logic [31:0] RAM_END      = 32'h8000_0000;

  assign slave_addr_start[0] = RAM_START;
  assign slave_addr_end[0]   = RAM_END;
  assign slave_addr_start[1] = PERIPH_START;
  assign slave_addr_end[1]   = PERIPH_END;

  // connect bus to ram
  assign ram_req        = slave_valid[0];
  assign slave_ready[0] = ram_req;
  assign ram_addr       = slave_addr[0];
  assign ram_we         = slave_we[0];
  assign ram_strb       = slave_strb[0];
  assign ram_wdata      = slave_wdata[0];
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      slave_rvalid[0] <= 1'b0;
    end else begin
      slave_rvalid[0] <= ram_req & ~ram_we;
    end
  end
  assign slave_rdata[0] = ram_rdata;

  // connect bus to stdout
  assign periph_valid    = slave_valid[1];
  assign slave_ready[1]  = periph_valid;
  assign periph_addr     = slave_addr[1];
  assign periph_we       = slave_we[1];
  // assign ...          = slave_strb[1];
  assign periph_wdata    = slave_wdata[1];
  assign slave_rvalid[1] = 1'b1;
  assign slave_rdata[1]  = 32'hdeadbeef;


endmodule // catv_tb

// Local Variables:
// verilog-library-flags:("-y . -y ../src/")
// End:
