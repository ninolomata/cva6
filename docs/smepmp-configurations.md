# RV64 Smepmp configurations

## CLINT IPIs and APLIC direct mode

`EnableClintIpi` is enabled in both custom Smepmp targets below and in
`cv64a6_imafdch_spmp`. MSIP follows the CLINT `ipi_i` signal; clearing the
CLINT MSIP register clears that source. Other configurations explicitly
disable this option, making both MSIP and MSIE hardwired zero.

This option is independent of AIA/APLIC delivery mode. For the current
Bao setup use `APLIC_MODE=direct`; no IMSIC IPI backend is required.
The AIA specification permits legacy CLINT IPIs alongside IMSIC.

Rebuild and program the FPGA: a Bao rebuild cannot repair the old RTL.
The FPGA Makefile does not track RTL as bitstream prerequisites, so an
existing `.bit` must be explicitly forced to rebuild. Exact Genesys2
commands and boot checks are recorded in the sibling Bao demo repository's
`NOTES-CVA6-MMU.md`, under "Configurable CLINT IPI restoration".
Full-core lint passed for both custom targets, `cv64a6_imafdch_spmp`,
and disabled `cv64a6_imafdc_spmp`, with direct and MSI defines.
This is not functional APLIC/IMSIC regression coverage. Synthesis and
hardware validation of this change remain pending.

## Configuration selection

Select the configuration using the root Makefile's `target` argument. The
core file list resolves `core/include/${TARGET_CFG}_config_pkg.sv`.

| Target | MMU | H extension | Machine PMP entries | SPMP entries | Virtual SPMP entries | Smepmp |
| --- | --- | --- | --- | --- | --- | --- |
| `cv64a6_imafdch_mmu_smepmp` | Yes | Yes | 32 | 0 | 0 | Yes |
| `cv64a6_imafdc_spmp_smepmp` | No | No | 32 | 32 | 0 | Yes |

The MMU target copies the current MMU settings from
`cv64a6_imafdch_spmp_config_pkg.sv`. The SPMP target uses M/S/U privilege
modes and selects `gen_no_mmu.gen_spmp.gen_single_spmp` in the load/store
unit. Its 64 protection resources are split between machine PMP and
supervisor SPMP; `PMPNumHyp` is zero. Both retain the base configuration's
cache, ISA and peripheral settings except for the stated changes.

For FPGA builds, from the repository root:

```sh
make fpga target=cv64a6_imafdch_mmu_smepmp
make fpga target=cv64a6_imafdc_spmp_smepmp
```

Use your existing board and `APLIC_MODE` settings. Recreate the Vivado
project/source list when switching targets; an existing project can still
reference the previously selected package. Only one `cva6_config_pkg`
may be compiled per design. The single-stage SPMP target does not support
an H-extension guest setup or an MMU-dependent Linux image.

Validation: both packages were compiled with Verilator 5.022 and assertions
checked the derived privilege, Smepmp and protection-entry fields from
`build_config_pkg::build_config`. Root Makefile selection reports XLEN=64
for both targets. Full-core lint using `core/Flist.cva6` completed with
`--lint-only -Wno-fatal -Wno-BLKANDNBLK --top-module cva6`; the last
suppression is needed for existing FPU mixed-assignment diagnostics.
Other RTL warnings remain. These targets have not been synthesized or
tested on hardware.
