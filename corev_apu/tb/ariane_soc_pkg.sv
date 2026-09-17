// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba, ETH Zurich
// Description: Contains SoC information as constants

/*verilator tracing_off*/

// APLIC delivery is a SoC integration choice. Define CVA6_APLIC_MSI_MODE in
// the SoC build to select MSI delivery; direct delivery is the default. This
// file is compiled before the AIA RTL, so the selected port set is fixed here
// rather than in the reusable AIA package.
`ifdef CVA6_APLIC_MSI_MODE
  `define MSI_MODE
  `define AIA_EMBEDDED
`else
  `define DIRECT_MODE
`endif

package ariane_soc;
  // M-Mode Hart, S-Mode Hart
  localparam int unsigned NumTargets = 2;
  // Uart, SPI, Ethernet, reserved
  localparam int unsigned NumSources = 32;
  localparam int unsigned MaxPriority = 7;
  localparam int unsigned AplicNrSources = NumSources;
  localparam int unsigned AplicNrHarts = 5;
`ifdef CVA6_APLIC_MSI_MODE
  localparam bit AplicMsiMode = 1'b1;
`else
  localparam bit AplicMsiMode = 1'b0;
`endif

  localparam NrSlaves = 2; // actually masters, but slaves on the crossbar

  typedef enum int unsigned {
    DRAM     = 0,
    GPIO     = 1,
    Ethernet = 2,
    IMSIC    = 3,
    SPI      = 4,
    Timer    = 5,
    UART     = 6,
    APLIC    = 7,
    CLINT    = 8,
    ROM      = 9,
    Debug    = 10
  } axi_slaves_t;

  localparam NB_PERIPHERALS = Debug + 1;

  typedef enum int unsigned {
    UART_IRQ        = 0,
    SPI_IRQ         = 1,
    ETH_IRQ         = 2,
    TIMER_FIRST_IRQ = 3,
    TIMER_LAST_IRQ  = 6
  } irq_id_t;

  // Modify accordingly when adding IRQ IDs
  localparam LAST_IRQ = TIMER_LAST_IRQ + 1;

  localparam logic[63:0] DebugLength    = 64'h1000;
  localparam logic[63:0] ROMLength      = 64'h10000;
  localparam logic[63:0] CLINTLength    = 64'hC0000;
  localparam logic[63:0] APLICLength    = 64'h3FF_FFFF;
  localparam logic[63:0] UARTLength     = 64'h1000;
  localparam logic[63:0] TimerLength    = 64'h1000;
  localparam logic[63:0] SPILength      = 64'h800000;
  localparam logic[63:0] IMSICLength    = 64'h800_0000;
  localparam logic[63:0] EthernetLength = 64'h10000;
  localparam logic[63:0] GPIOLength     = 64'h1000;
`ifdef NEXYS_VIDEO
  localparam logic[63:0] DRAMLength     = 64'h20000000; // 512MByte of DDR on Nexys video board
`else
  localparam logic[63:0] DRAMLength     = 64'h40000000; // 1GByte of DDR (split between two chips on Genesys2)
`endif
  localparam logic[63:0] SRAMLength     = 64'h1800000;  // 24 MByte of SRAM
  // Instantiate AXI protocol checkers
  localparam bit GenProtocolChecker = 1'b0;

  typedef enum logic [63:0] {
    DebugBase    = 64'h0000_0000,
    ROMBase      = 64'h0001_0000,
    CLINTBase    = 64'h0200_0000,
    APLICBase    = 64'h0C00_0000,
    UARTBase     = 64'h1000_0000,
    TimerBase    = 64'h1800_0000,
    SPIBase      = 64'h2000_0000,
    IMSICBase    = 64'h2400_0000,
    EthernetBase = 64'h3000_0000,
    GPIOBase     = 64'h4000_0000,
    DRAMBase     = 64'h8000_0000
  } soc_bus_start_t;

  localparam NrRegion = 1;
  localparam logic [NrRegion-1:0][NB_PERIPHERALS-1:0] ValidRule = {{NrRegion * NB_PERIPHERALS}{1'b1}};

endpackage

/*verilator tracing_on*/
