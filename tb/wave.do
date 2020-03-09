onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /catv_tb/RAM_DATA_WIDTH
add wave -noupdate -expand -group tb /catv_tb/RAM_NUM_BYTES
add wave -noupdate -expand -group tb /catv_tb/BOOT_ADDR
add wave -noupdate -expand -group tb /catv_tb/N_BUS_MASTERS
add wave -noupdate -expand -group tb /catv_tb/N_BUS_SLAVES
add wave -noupdate -expand -group tb /catv_tb/N_MASTER_BITS
add wave -noupdate -expand -group tb /catv_tb/N_SLAVE_BITS
add wave -noupdate -expand -group tb /catv_tb/RAM_ADDR_WIDTH
add wave -noupdate -expand -group tb /catv_tb/PERIPH_START
add wave -noupdate -expand -group tb /catv_tb/PERIPH_END
add wave -noupdate -expand -group tb /catv_tb/RAM_START
add wave -noupdate -expand -group tb /catv_tb/RAM_END
add wave -noupdate -expand -group tb /catv_tb/clk
add wave -noupdate -expand -group tb /catv_tb/rst_n
add wave -noupdate -expand -group tb /catv_tb/insn_addr
add wave -noupdate -expand -group tb /catv_tb/insn_valid
add wave -noupdate -expand -group tb /catv_tb/insn_ready
add wave -noupdate -expand -group tb /catv_tb/insn_data
add wave -noupdate -expand -group tb /catv_tb/insn_rvalid
add wave -noupdate -expand -group tb /catv_tb/data_addr
add wave -noupdate -expand -group tb /catv_tb/data_wen
add wave -noupdate -expand -group tb /catv_tb/data_wdata
add wave -noupdate -expand -group tb /catv_tb/data_strb
add wave -noupdate -expand -group tb /catv_tb/data_rvalid
add wave -noupdate -expand -group tb /catv_tb/data_rdata
add wave -noupdate -expand -group tb /catv_tb/data_valid
add wave -noupdate -expand -group tb /catv_tb/data_ready
add wave -noupdate -expand -group tb /catv_tb/master_valid
add wave -noupdate -expand -group tb /catv_tb/master_ready
add wave -noupdate -expand -group tb /catv_tb/master_addr
add wave -noupdate -expand -group tb /catv_tb/master_we
add wave -noupdate -expand -group tb /catv_tb/master_strb
add wave -noupdate -expand -group tb /catv_tb/master_wdata
add wave -noupdate -expand -group tb /catv_tb/master_rvalid
add wave -noupdate -expand -group tb /catv_tb/master_rdata
add wave -noupdate -expand -group tb /catv_tb/master_sel_req
add wave -noupdate -expand -group tb /catv_tb/master_sel_resp
add wave -noupdate -expand -group tb /catv_tb/slave_valid
add wave -noupdate -expand -group tb /catv_tb/slave_ready
add wave -noupdate -expand -group tb /catv_tb/slave_addr
add wave -noupdate -expand -group tb /catv_tb/slave_we
add wave -noupdate -expand -group tb /catv_tb/slave_strb
add wave -noupdate -expand -group tb /catv_tb/slave_wdata
add wave -noupdate -expand -group tb /catv_tb/slave_rvalid
add wave -noupdate -expand -group tb /catv_tb/slave_rdata
add wave -noupdate -expand -group tb /catv_tb/slave_sel_req
add wave -noupdate -expand -group tb /catv_tb/slave_sel_resp
add wave -noupdate -expand -group tb /catv_tb/slave_addr_start
add wave -noupdate -expand -group tb /catv_tb/slave_addr_end
add wave -noupdate -expand -group tb /catv_tb/ram_req
add wave -noupdate -expand -group tb /catv_tb/ram_we
add wave -noupdate -expand -group tb /catv_tb/ram_addr
add wave -noupdate -expand -group tb /catv_tb/ram_addr_q
add wave -noupdate -expand -group tb /catv_tb/ram_wdata
add wave -noupdate -expand -group tb /catv_tb/ram_strb
add wave -noupdate -expand -group tb /catv_tb/ram_rdata
add wave -noupdate -expand -group tb /catv_tb/periph_valid
add wave -noupdate -expand -group tb /catv_tb/periph_we
add wave -noupdate -expand -group tb /catv_tb/periph_wdata
add wave -noupdate -expand -group tb /catv_tb/periph_addr
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/clk_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/rst_ni
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_addr_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_valid_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_ready_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_data_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_rvalid_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_addr_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_wen_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_wdata_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_rvalid_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_rdata_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_strb_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_valid_o
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/data_ready_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/hartid_i
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/pc_q
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/pc_d
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/next_pc
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_ok
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/stall
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/reg_a
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/reg_b
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/reg_write_valid
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/alu_op_a
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/alu_op_b
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/alu_result
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/alu_op
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/wb_value
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/wb_mux
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/rs1
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/rs2
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/rd
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/funct3
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/funct7
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/j_imm
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/u_imm
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/b_imm
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/s_imm
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/i_imm
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/fetch_ok
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_fetch_q
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/insn_fetch_d
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/pc_clear_lsb
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/pc_mux
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/op_a_mux
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/op_b_mux
add wave -noupdate -expand -group core /catv_tb/i_catv_riscv/retire
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {32 ns}
