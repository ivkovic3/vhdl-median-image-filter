# Hardware 3×3 Median Filter in VHDL

FPGA implementation of a **3×3 median filter** for removing salt-and-pepper noise from a 256×256 grayscale image.
University project for the course **VLSI Systems** (VLSI sistemi).

| Input (salt-and-pepper noise) | Output (hardware simulation result) |
|:---:|:---:|
| ![input](images/input_noisy.png) | ![output](images/output_filtered.png) |

## Overview

The image is stored in on-chip Block RAM. A control FSM streams pixels out of the memory, two line buffers build a sliding 3×3 window, and a pipelined sorting network computes the median of the 9 pixels. The filtered pixel is written back to the same memory. After the pipeline fills, the design produces **one filtered pixel per clock cycle**.

```
          ┌──────────┐ pixel ┌──────────────────────────────┐ 3×3  ┌────────────────┐
          │  Image   │──────▶│  3×3 window registers        │─────▶│  Median        │
          │  RAM     │       │  + 2 line-buffer FIFOs       │      │  (9-stage      │
          │ 256×256  │◀──────│  (one image row each)        │      │   pipeline)    │
          └──────────┘       └──────────────────────────────┘      └───────┬────────┘
               ▲                                                           │
               └────────────────────── filtered pixel ─────────────────────┘
                         FSM: idle → read → read/write → write
```

## Design highlights

- **Pipelined median network** (`medijana.vhd`) – the median of 9 values is found with a network of min/max comparators split into 9 register stages, so a new 3×3 window can enter every clock cycle.
- **Line buffers** (`fifo_buffer.vhd`) – two circular FIFOs hold the previous two image rows, so each pixel is read from RAM only once.
- **Control FSM** (`Medijan_filtar.vhd`) – four states (`idle`, `read`, `readwrite`, `write`) coordinate RAM addressing, filling the window, accounting for pipeline latency and writing results back.
- **Border handling** – edge pixels are used only as padding and are not overwritten, so the result is 254×254.
- **Dual-port Block RAM** (`im_ram.vhd`) – inferred RAM with separate read/write ports, initialised from a file and with a selectable output register (`LOW_LATENCY` / `HIGH_PERFORMANCE`).

## Results

Implemented in **Xilinx Vivado 2021.1** for the **Zynq-7000 xc7z020clg400-1** FPGA:

| Resource | Used | Available | Utilisation |
|---|---:|---:|---:|
| Slice LUTs | 489 | 53 200 | 0.92 % |
| Flip-flops | 542 | 106 400 | 0.51 % |
| Block RAM tiles | 17 | 140 | 12.14 % |

The design was checked with behavioural simulation: the testbench writes the filtered pixels to a text file, and a Python script turns that file into the output image shown above.

## Repository structure

```
src/
  Medijan_filtar.vhd       top level: FSM, 3×3 window, connections
  medijana.vhd             pipelined median of 9 pixels
  fifo_buffer.vhd          line buffer (one image row)
  flag_generator.vhd       "FIFO full" flag
  im_ram.vhd               dual-port Block RAM initialised from a file
  RAM_definitions_PK.vhd   helper package (clogb2)
sim/
  Medijan_filtar_tb.vhd    full-system testbench, writes output_signal.txt
  medijana_tb.vhd          unit testbench for the median block
data/
  lenaCorrupted.dat        input image (256×256, one 8-bit binary value per line)
  output_signal.txt        simulation output (254×254 pixel values)
scripts/
  slika.py                 converts output_signal.txt to an image
images/                    input and output images used in this README
```

## How to run

1. Create a new project in Vivado and add the files from `src/` as design sources and the files from `sim/` as simulation sources.
2. Copy `data/lenaCorrupted.dat` to the simulation directory (`<project>.sim/sim_1/behav/xsim/`) so the RAM can be initialised.
3. Set `tb_Medijan_filtar` as the top simulation module and run behavioural simulation for at least **1.5 ms** (about 131 000 clock cycles at 100 MHz: one pass to read and one to write the whole image).
4. Copy the generated `output_signal.txt` next to `scripts/slika.py` and run:
   ```bash
   pip install numpy matplotlib
   python slika.py
   ```
   This produces `output_image.jpg`.

## Technologies

VHDL · Xilinx Vivado · XSim · FPGA (Zynq-7000) · Python (NumPy, Matplotlib)
