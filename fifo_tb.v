`timescale 1ns/1ns
module tb_fifo();

  // Parameters
  parameter FIFO_DEPTH = 8;
  parameter DATA_WIDTH = 32;

  // Testbench signals
  reg clk = 0;
  reg rst;
  reg cs;
  reg wr_en;
  reg rd_en;
  reg [DATA_WIDTH-1:0] din;
  wire [DATA_WIDTH-1:0] dout;
  wire empty;
  wire full;

  integer i;

  // Instantiate the FIFO design
  fifo #(
      .FIFO_DEPTH(FIFO_DEPTH),
      .DATA_WIDTH(DATA_WIDTH)
  ) dut (
      .clk(clk),
      .rst(rst),
      .cs(cs),
      .wr_en(wr_en),
      .rd_en(rd_en),
      .din(din),
      .dout(dout),
      .empty(empty),
      .full(full)
  );

  // Clock generation
  always begin
      #5 clk = ~clk;  // 10ns clock period
  end

  // Task to write data into FIFO
  task write_data(input [DATA_WIDTH-1:0] d_in);
      begin
          @(posedge clk);
          cs = 1;
          wr_en = 1;
          data_in = d_in;
          @(posedge clk);
          wr_en = 0;
          cs = 1;
      end
  endtask

  // Task to read data from FIFO
  task read_data();
      begin
          @(posedge clk);
          cs = 1;
          rd_en = 1;
          @(posedge clk);
          rd_en = 0;
          cs = 1;
      end
  endtask

  // Main stimulus block
  initial begin
      // Initial reset
      #1;
      rst = 0;
      wr_en = 0;
      rd_en = 0;
      cs = 0;

      @(posedge clk)
      rst = 1;

      $display("%0t: scenario 1", $time);
      write_data(1);
      write_data(10);
      write_data(100);
      read_data();
      read_data();
      read_data();

      $display("%0t: scenario 2", $time);
      for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
          write_data(2**i);
          read_data();
      end

      $display("%0t: scenario 3", $time);
      for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
          write_data(2**i);
      end

      for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
          read_data();
      end

      #40;
      $finish;
  end

  // Dump VCD file
  initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
  end

endmodule
