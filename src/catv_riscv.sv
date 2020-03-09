// Copyright 2020 Robert Balas
// SPDX-License-Identifier: SHL-0.51

// single header rv32ie core
//
// inspired by Computer Architecture: A Quantitive Approach p. C-30,
// darkriscv.v, RI5CY and riscv-sodor
//
// We really don't care about modularization.
// CPI and longest path is just a number.
//
// Author: Robert Balas (balasr@iis.ee.ethz.ch)

module catv_riscv #(
  parameter logic [31:0] BOOT_ADDR = 32'h0000_2000
) (
  input logic         clk_i,
  input logic         rst_ni,

  // instruction fetch port
  output logic [31:0] insn_addr_o,
  output logic        insn_valid_o,
  input logic         insn_ready_i,
  input logic [31:0]  insn_data_i,
  input logic         insn_rvalid_i,

  // data interface
  output logic [31:0] data_addr_o,
  output logic        data_wen_o,
  output logic [31:0] data_wdata_o,
  input logic         data_rvalid_i,
  input logic [31:0]  data_rdata_i,
  output logic [3:0]  data_strb_o,
  output logic        data_valid_o,
  input logic         data_ready_i,

  // configuration
  input logic [19:0]  hartid_i
);

  // Automatically generated by parse_opcodes
  // rv32i
  localparam [31:0] BEQ                = 32'b?????????????????000?????1100011;
  localparam [31:0] BNE                = 32'b?????????????????001?????1100011;
  localparam [31:0] BLT                = 32'b?????????????????100?????1100011;
  localparam [31:0] BGE                = 32'b?????????????????101?????1100011;
  localparam [31:0] BLTU               = 32'b?????????????????110?????1100011;
  localparam [31:0] BGEU               = 32'b?????????????????111?????1100011;
  localparam [31:0] JALR               = 32'b?????????????????000?????1100111;
  localparam [31:0] JAL                = 32'b?????????????????????????1101111;
  localparam [31:0] LUI                = 32'b?????????????????????????0110111;
  localparam [31:0] AUIPC              = 32'b?????????????????????????0010111;
  localparam [31:0] ADDI               = 32'b?????????????????000?????0010011;
  localparam [31:0] SLLI               = 32'b000000???????????001?????0010011;
  localparam [31:0] SLTI               = 32'b?????????????????010?????0010011;
  localparam [31:0] SLTIU              = 32'b?????????????????011?????0010011;
  localparam [31:0] XORI               = 32'b?????????????????100?????0010011;
  localparam [31:0] SRLI               = 32'b000000???????????101?????0010011;
  localparam [31:0] SRAI               = 32'b010000???????????101?????0010011;
  localparam [31:0] ORI                = 32'b?????????????????110?????0010011;
  localparam [31:0] ANDI               = 32'b?????????????????111?????0010011;
  localparam [31:0] ADD                = 32'b0000000??????????000?????0110011;
  localparam [31:0] SUB                = 32'b0100000??????????000?????0110011;
  localparam [31:0] SLL                = 32'b0000000??????????001?????0110011;
  localparam [31:0] SLT                = 32'b0000000??????????010?????0110011;
  localparam [31:0] SLTU               = 32'b0000000??????????011?????0110011;
  localparam [31:0] XOR                = 32'b0000000??????????100?????0110011;
  localparam [31:0] SRL                = 32'b0000000??????????101?????0110011;
  localparam [31:0] SRA                = 32'b0100000??????????101?????0110011;
  localparam [31:0] OR                 = 32'b0000000??????????110?????0110011;
  localparam [31:0] AND                = 32'b0000000??????????111?????0110011;
  localparam [31:0] LB                 = 32'b?????????????????000?????0000011;
  localparam [31:0] LH                 = 32'b?????????????????001?????0000011;
  localparam [31:0] LW                 = 32'b?????????????????010?????0000011;
  localparam [31:0] LBU                = 32'b?????????????????100?????0000011;
  localparam [31:0] LHU                = 32'b?????????????????101?????0000011;
  localparam [31:0] SB                 = 32'b?????????????????000?????0100011;
  localparam [31:0] SH                 = 32'b?????????????????001?????0100011;
  localparam [31:0] SW                 = 32'b?????????????????010?????0100011;
  localparam [31:0] FENCE              = 32'b?????????????????000?????0001111;
  localparam [31:0] FENCE_I            = 32'b?????????????????001?????0001111;
  // system
  localparam [31:0] ECALL              = 32'b00000000000000000000000001110011;
  localparam [31:0] EBREAK             = 32'b00000000000100000000000001110011;
  localparam [31:0] URET               = 32'b00000000001000000000000001110011;
  localparam [31:0] SRET               = 32'b00010000001000000000000001110011;
  localparam [31:0] MRET               = 32'b00110000001000000000000001110011;
  localparam [31:0] DRET               = 32'b01111011001000000000000001110011;
  localparam [31:0] SFENCE_VMA         = 32'b0001001??????????000000001110011;
  localparam [31:0] WFI                = 32'b00010000010100000000000001110011;
  localparam [31:0] CSRRW              = 32'b?????????????????001?????1110011;
  localparam [31:0] CSRRS              = 32'b?????????????????010?????1110011;
  localparam [31:0] CSRRC              = 32'b?????????????????011?????1110011;
  localparam [31:0] CSRRWI             = 32'b?????????????????101?????1110011;
  localparam [31:0] CSRRSI             = 32'b?????????????????110?????1110011;
  localparam [31:0] CSRRCI             = 32'b?????????????????111?????1110011;
  localparam [31:0] HFENCE_VVMA        = 32'b0010001??????????000000001110011;
  localparam [31:0] HFENCE_GVMA        = 32'b0110001??????????000000001110011;


  // pc things
  logic [31:0] pc_q, pc_d;
  logic [31:0] pc_next;
  logic        insn_ok, stall;

  // gpr
  logic [31:0] regs [0:31];
  logic [31:0] reg_a, reg_b; // read ports
  logic        reg_write_valid;

  // alu
  logic [31:0] alu_op_a;
  logic [31:0] alu_op_b;
  logic [31:0] alu_result;
  enum logic [3:0] {
    OP_ADD, OP_SUB, OP_SLL,
    OP_SEQ, OP_SNE, OP_SLT,
    OP_SGE, OP_SLTU, OP_SGEU,
    OP_XOR, OP_SRL, OP_SRA,
    OP_OR, OP_AND
  } alu_op;

  // load store
  logic load_stall;
  logic store_stall;
  logic is_load;
  logic is_store;

  enum logic [3:0] {
    BYTE = 4'b0001, HALFWORD = 4'b0011, WORD = 4'b1111
  } ls_strobe;

  logic ls_signext;

  // writeback path
  logic commit;
  logic [31:0] wb_value;
  enum logic [3:0] {
    WB_RET_PC, WB_ALU, WB_LOAD
  } wb_mux;

  // exploded insn
  logic [4:0] rs1, rs2, rd;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [31:0] j_imm, u_imm, b_imm, s_imm, i_imm;

  // instruction fetching
  // For a certain pc_q, keep the insn_valid and insn_data stable.
  logic        insn_illegal;
  logic        insn_valid_q, insn_valid_d;
  logic [31:0] insn_data, insn_data_q, insn_data_d;

  // TODO: this only fetches every other cycle. Make it faster.
  assign fetch_ok = insn_valid_o & insn_ready_i;
  //assign insn_ok = insn_rvalid_i;

  // forward from insn port to save one cycle (hack)
  assign insn_ok   = insn_rvalid_i;
  assign insn_data = insn_rvalid_i ? insn_data_i : insn_data_q;
  assign stall = ~insn_rvalid_i | load_stall | store_stall;
  assign insn_addr_o = pc_q;

  typedef enum logic [3:0] {
    FETCH, WAIT
  } insn_fetch_e;
  insn_fetch_e insn_fetch_q, insn_fetch_d;

  always_comb begin : fetch_next
    insn_fetch_d = insn_fetch_q;
    insn_valid_o = 1'b0;
    insn_data_d  = insn_data_q;
    unique case (insn_fetch_q)
      FETCH: begin
        insn_valid_o = 1'b1;
        if (insn_valid_o && insn_ready_i) insn_fetch_d = WAIT;
      end
      WAIT: begin
        insn_valid_o = 1'b0;
        if (insn_rvalid_i) begin // latch insn data to keep it stable
          insn_valid_d = 1'b1;
          insn_data_d  = insn_data_i;
        end
        if (commit) begin
          insn_fetch_d = FETCH;
        end
      end
      default:;
    endcase // unique case (insn_fetch)
  end

  always_ff @(posedge clk_i, negedge rst_ni) begin : fetch
    if (!rst_ni) begin
      insn_fetch_q <= FETCH;
      insn_valid_q <= 1'b0;
      insn_data_q  <= 32'b0;
    end else begin
      insn_fetch_q <= insn_fetch_d;
      insn_valid_q <= insn_valid_d;
      insn_data_q  <= insn_data_d;
    end
  end : fetch

  // pc udpate logic
  logic pc_clear_lsb;
  enum logic [3:0] {
    PC_EXCEPTION, PC_NEXT, PC_ALU, PC_BRANCH
  } pc_mux;

  assign pc_next = pc_q + 32'd4;

  always_comb begin : program_counter_mux
    unique case (pc_mux)
      PC_EXCEPTION: pc_d = BOOT_ADDR; // TODO: fix nonsense
      PC_NEXT:      pc_d = pc_next;
      PC_ALU:       pc_d = alu_result & (32'hffff_fffe | ~pc_clear_lsb); // risc-v spec p.21 zero last bit
      PC_BRANCH:    pc_d = pc_q + (alu_result[0] ? b_imm : 32'd4); // annoying: either use alu for computing branch or computing condition. we choose later
    endcase // unique case (pc_mux)
  end : program_counter_mux

  always_ff @(posedge clk_i, negedge rst_ni) begin : pc_update
    if (!rst_ni) begin
      pc_q <= BOOT_ADDR;
    end else begin
      if (commit) begin
        pc_q <= pc_d;
      end
    end
  end : pc_update

  // operand mux states
  typedef enum logic [3:0] {
    MUX_ZERO, MUX_PC, MUX_REG, MUX_U_IMM, MUX_I_IMM, MUX_J_IMM, MUX_S_IMM
  } op_mux_e;
  op_mux_e op_a_mux, op_b_mux;

  // immediates, sign extended (risc-v spec p. 17)
  assign j_imm = $signed({insn_data[31], insn_data[19:12], insn_data[20], insn_data[30:21], 1'b0});
  assign u_imm =         {insn_data[31:12], 12'b0};
  assign b_imm = $signed({insn_data[31], insn_data[7], insn_data[30:25], insn_data[11:8], 1'b0});
  assign s_imm = $signed({insn_data[31:25], insn_data[11:7]});
  assign i_imm = $signed({insn_data[31:20]});

  // decoder (1)
  assign rs1    = insn_data[19:15];
  assign rs2    = insn_data[24:20];
  assign rd     = insn_data[11:7];
  assign funct3 = insn_data[14:12];
  assign funct7 = insn_data[31:25];

  // decoder (2)
  always_comb begin : decoder
    pc_clear_lsb = 1'b0;
    pc_mux   = PC_NEXT;
    wb_mux   = WB_ALU;
    op_a_mux = MUX_ZERO;
    op_b_mux = MUX_ZERO;
    reg_write_valid = 1'b0;
    is_load    = 1'b0;
    is_store   = 1'b0;
    ls_strobe  = WORD;
    ls_signext = 1'b0;

    insn_illegal = 1'b0;

    unique casez (insn_data)
      BEQ: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SEQ;
      end
      BNE: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SNE;
      end
      BLT: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SLT;
      end
      BGE: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SGE;
      end
      BLTU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SLTU;
      end
      BGEU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        pc_mux = PC_BRANCH;
        alu_op = OP_SGEU;
      end
      JALR: begin // rs1 + i_imm, zero lsb of result
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_RET_PC; pc_mux = PC_ALU;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
        pc_clear_lsb = 1'b1;
      end
      JAL: begin
        op_a_mux = MUX_PC; op_b_mux = MUX_J_IMM;
        wb_mux = WB_RET_PC; pc_mux = PC_ALU;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
      end
      LUI: begin
        op_a_mux = MUX_ZERO; op_b_mux = MUX_U_IMM;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
      end
      AUIPC: begin
        op_a_mux = MUX_PC; op_b_mux = MUX_U_IMM;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
      end
      ADDI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
      end
      SLLI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_SLL;
        reg_write_valid = 1'b1;
      end
      SLTI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_SLT;
        reg_write_valid = 1'b1;
      end
      SLTIU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_SLTU;
        reg_write_valid = 1'b1;
      end
      XORI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_XOR;
        reg_write_valid = 1'b1;
      end
      SRLI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_SRL;
        reg_write_valid = 1'b1;
      end
      SRAI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_SRA;
        reg_write_valid = 1'b1;
      end
      ORI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_OR;
        reg_write_valid = 1'b1;
      end
      ANDI: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        alu_op = OP_AND;
        reg_write_valid = 1'b1;
      end
      ADD: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_ADD;
        reg_write_valid = 1'b1;
      end
      SUB: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SUB;
        reg_write_valid = 1'b1;
      end
      SLL: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SLL;
        reg_write_valid = 1'b1;
      end
      SLT: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SLT;
        reg_write_valid = 1'b1;
      end
      SLTU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SLTU;
        reg_write_valid = 1'b1;
      end
      XOR: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_XOR;
        reg_write_valid = 1'b1;
      end
      SRL: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SRL;
        reg_write_valid = 1'b1;
      end
      SRA: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_SRA;
        reg_write_valid = 1'b1;
      end
      OR: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_OR;
        reg_write_valid = 1'b1;
      end
      AND: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_REG;
        alu_op = OP_AND;
        reg_write_valid = 1'b1;
      end
      LB: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_LOAD;
        alu_op = OP_ADD;
        is_load = 1'b1;
        ls_strobe = BYTE;
        ls_signext = 1'b1;
        reg_write_valid = 1'b1;
      end
      LH: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_LOAD;
        alu_op = OP_ADD;
        is_load = 1'b1;
        ls_strobe = HALFWORD;
        ls_signext = 1'b1;
        reg_write_valid = 1'b1;
      end
      LW: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_LOAD;
        alu_op = OP_ADD;
        is_load = 1'b1;
        ls_strobe = WORD;
        ls_signext = 1'b1;
        reg_write_valid = 1'b1;
      end
      LBU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_LOAD;
        alu_op = OP_ADD;
        is_load = 1'b1;
        ls_strobe = BYTE;
        reg_write_valid = 1'b1;
      end
      LHU: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_I_IMM;
        wb_mux = WB_LOAD;
        alu_op = OP_ADD;
        is_load = 1'b1;
        ls_strobe = HALFWORD;
        reg_write_valid = 1'b1;
      end
      SB: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_S_IMM;
        alu_op = OP_ADD;
        is_store = 1'b1;
        ls_strobe = BYTE;
      end
      SH: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_S_IMM;
        alu_op = OP_ADD;
        is_store = 1'b1;
        ls_strobe = HALFWORD;
      end
      SW: begin
        op_a_mux = MUX_REG; op_b_mux = MUX_S_IMM;
        alu_op = OP_ADD;
        is_store = 1'b1;
        ls_strobe = WORD;
      end
      FENCE: begin
      end
      FENCE_I: begin
      end
      CSRRW: begin
      end
      CSRRS: begin
      end
      CSRRC: begin
      end
      CSRRWI: begin
      end
      CSRRSI: begin
      end
      CSRRCI: begin
      end
      default: begin
        insn_illegal = 1'b1;
      end
    endcase // unique casez (insn_data)
  end : decoder

  // warn us (broken code or core)
  assert property (@(posedge clk_i) disable iff (!rst_ni)
    !(insn_illegal && insn_ok))
    else $error("[tb]: illegal instruction decoded value=%x", insn_data);

  // operand muxes for feeding alu
  always_comb begin : mux_op_a
    // pc or reg_a
    unique case (op_a_mux)
      MUX_ZERO: alu_op_a = 32'b0;
      MUX_PC:   alu_op_a = pc_q;
      MUX_REG:  alu_op_a = reg_a;
      default:  alu_op_a = 32'b0;
    endcase // unique case (op_a_mux)
  end : mux_op_a

  always_comb begin : mux_op_b
    // imm or reg_b
    unique case (op_b_mux)
      MUX_ZERO:  alu_op_b = 32'b0;
      MUX_REG:   alu_op_b = reg_b;
      MUX_U_IMM: alu_op_b = u_imm;
      MUX_I_IMM: alu_op_b = i_imm;
      MUX_J_IMM: alu_op_b = j_imm;
      MUX_S_IMM: alu_op_b = s_imm;
      default:  alu_op_b = 32'b0;
    endcase // unique case (op_b_mux)
  end : mux_op_b

  // alu
  always_comb begin : alu
    // TODO: remove this tmp assignment
    alu_result = 32'b0;

    // TODO: share adder for all operations
    // TODO: share shifter
    unique case (alu_op)
      OP_ADD: begin
        alu_result = alu_op_a + alu_op_b;
      end
      OP_SUB: begin
        alu_result = alu_op_a - alu_op_b;
      end
      OP_SLL: begin
        alu_result = alu_op_a << alu_op_b[4:0];
      end
      OP_SEQ: begin
        alu_result = alu_op_a == alu_op_b;
      end
      OP_SNE: begin
        alu_result = alu_op_a != alu_op_b;
      end
      OP_SLT: begin
        alu_result = $signed(alu_op_a) < $signed(alu_op_b);
      end
      OP_SGE: begin
        alu_result = $signed(alu_op_a) >= $signed(alu_op_b);
      end
      OP_SLTU: begin
        alu_result = alu_op_a < alu_op_b; // sv lrm 2017 p. 263
      end
      OP_SGEU: begin
        alu_result = alu_op_a >= alu_op_b; // sv lrm 2017 p. 263
      end
      OP_XOR: begin
        alu_result = alu_op_a ^ alu_op_b;
      end
      OP_SRL: begin
        alu_result = alu_op_a >> alu_op_b[4:0];  // sv lrm 2017 p. 269
      end
      OP_SRA: begin
        alu_result = $signed(alu_op_a) >>> alu_op_b[4:0];  // sv lrm 2017 p. 269 (!)
      end
      OP_OR: begin
        alu_result = alu_op_a | alu_op_b;
      end
      OP_AND: begin
        alu_result = alu_op_a & alu_op_b;
      end
      default: begin
        alu_result = 32'b0; //TODO: better default
      end
    endcase // unique case (alu_op)
  end : alu

  // load store logic
  logic [31:0] load_result;
  logic        load_commit;
  logic        load_valid;
  logic [4:0]  load_rd_q, load_rd_d;

  logic        store_commit;
  logic        store_valid;

  assign data_addr_o   = alu_result; //TODO: silence for debugging
  assign data_wen_o    = !is_load;
  assign data_wdata_o  = reg_b; // store is always from reg[rs2]
  // data_rvalid_i =
  always_comb begin : load_sext
    unique case (ls_strobe)
      WORD:     load_result = data_rdata_i[31:0];
      HALFWORD: load_result = ls_signext ? $signed(data_rdata_i[15:0]) : data_rdata_i[15:0];
      BYTE:     load_result = ls_signext ? $signed(data_rdata_i[7:0])  : data_rdata_i[7:0];
      default:  load_result = data_rdata_i[31:0];
    endcase // unique case (ls_strobe)
  end : load_sext
  assign data_strb_o   = ls_strobe;
  // stores are commited as soon as the ready goes high. This means in the next
  // cycle is_store automatically goes low
  // loads need seperate handling since they wait until the response returns
  assign data_valid_o  = load_valid | store_valid;
  // assign data_ready_i,

  typedef enum logic [3:0] {
    ADDRESS, WAIT_RESPONSE
  } load_state_e;
  load_state_e load_state_q, load_state_d;

  // We remember the target register and wait until we get the load value back.
  // Everything will then be committed to regs by raising load_commit. This also
  // means the core will always stall on loads (until loads fully complete).
  always_comb begin : handle_load
    load_state_d = load_state_q;
    load_rd_d    = load_rd_q;
    load_commit  = 1'b0;
    unique case (load_state_q)
      ADDRESS: begin
        load_stall = is_load;
        load_valid = is_load;
        if (data_valid_o && data_ready_i && is_load) begin
          load_rd_d    = rd; // latch current rd
          load_state_d = WAIT_RESPONSE;
        end
      end
      WAIT_RESPONSE: begin
        load_stall = 1'b1;
        load_valid = 1'b0;
        if (data_rvalid_i) begin
          load_stall = 1'b0;
          load_commit = 1'b1;
          load_state_d = ADDRESS;
        end
      end
      default:;
    endcase // unique case (load_state_q)
  end : handle_load

  always_ff @(posedge clk_i, negedge rst_ni) begin : load
    if (!rst_ni) begin
      load_state_q <= ADDRESS;
      load_rd_q    <= 5'b0;
    end else begin
      load_state_q <= load_state_d;
      load_rd_q    <= load_rd_d;
    end
  end : load

  assign store_valid  = is_store;
  assign store_stall  = data_valid_o & ~data_ready_i & is_store;
  assign store_commit = data_valid_o &  data_ready_i & is_store;

  // retiring instructions
  // regular instructions need a single cycle to finish
  // for loads we wait until the result returns
  // for stores we wait until the address handshake happened
  assign commit = (insn_ok & ~is_load & ~is_store) | load_commit | store_commit;

  // gprs
  assign reg_a = rs1 != 5'b0 ? regs[rs1] : 32'b0;
  assign reg_b = rs2 != 5'b0 ? regs[rs2] : 32'b0;

  // writeback to regs
  always_comb begin : writeback_mux
    unique case (wb_mux)
      WB_RET_PC: wb_value = pc_next;
      WB_ALU:    wb_value = alu_result;
      WB_LOAD:   wb_value = load_result;
      default:   wb_value = 32'b0; //TODO: after debugging replace with alu_result
    endcase // unique case (wb_mux)
  end : writeback_mux

  always_ff @(posedge clk_i, negedge rst_ni) begin : gpr
    if (!rst_ni) begin
      regs <= '{default:0};
    end else begin
      if (reg_write_valid && commit && (rd != 5'b0))
        regs[rd] <= wb_value;
      // if (load_commit && (load_rd_q != 5'b0)) // TODO: disambiguate between load and other commits
      //   regs[load_rd_q] <= wb_value;
    end
  end : gpr

endmodule // catv_riscv
