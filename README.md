# Netlist-to-RTL Automation Pipeline

## 1. Introduction

This project provides a fully automated pipeline to reverse-engineer
synthesized gate-level Verilog netlists into high-level RTL, generate
self-checking testbenches, and validate correctness through simulation.

It leverages Large Language Models (LLMs) to: - Understand structural
netlists - Reconstruct behavioral RTL - Generate verification logic -
Iteratively debug until correctness is achieved

This is especially useful for: - Hardware reverse engineering - Design
recovery from synthesized outputs - Educational purposes (understanding
synthesis results) - Automated verification workflows

------------------------------------------------------------------------

## 2. Key Capabilities

### 2.1 Netlist → RTL Translation

-   Converts low-level gate instantiations into:
    -   `always` blocks
    -   `if/else` logic
    -   `case` statements
-   Preserves:
    -   Module name
    -   Port interface
    -   Functional behavior

### 2.2 Intelligent Testbench Generation

-   Fully self-checking testbenches
-   Automatically computes expected outputs
-   Uses:
    -   Exhaustive or near-exhaustive stimulus
    -   `$fatal` on mismatch
    -   `$dumpfile` and `$dumpvars` for waveform generation

### 2.3 Iterative Debug Loop

-   Detects whether failure is in:
    -   RTL
    -   Testbench
-   Automatically prompts LLM to fix issues
-   Retries up to configurable attempts (default: 15)

### 2.4 Simulation Integration

-   Uses:
    -   `iverilog` for compilation
    -   `vvp` for execution
    -   `gtkwave` for visualization

------------------------------------------------------------------------

## 3. Architecture Overview

    Netlist → LLM → RTL → LLM → Testbench → Icarus Verilog → Debug Loop → PASS

### Components:

-   **SimpleAgent** → Core LLM interface
-   **Pipeline Engine** → Orchestrates translation, testing, debugging
-   **Simulation Layer** → Handles compilation and execution

------------------------------------------------------------------------

## 4. Directory Structure

    project_root/
    │
    ├── Netlist/                  # Input netlists (organized in cases or flat)
    ├── generated RTL/            # Output RTL files
    ├── testbench/                # Generated testbenches
    ├── .env                      # API + model configuration
    ├── agent.py                  # Entry point

------------------------------------------------------------------------

## 5. Environment Setup

### 5.1 Python Requirements

-   Python ≥ 3.10

Install dependencies:

``` bash
pip install openai python-dotenv pypandoc
```

### 5.2 Install Simulation Tools

#### Ubuntu / Debian:

``` bash
sudo apt install iverilog gtkwave
```

#### macOS (Homebrew):

``` bash
brew install icarus-verilog gtkwave
```

------------------------------------------------------------------------

## 6. Environment Variables

Create `.env` file:

    OPENAI_API_KEY=your_api_key
    OPENAI_MODEL=gpt-5.3
    OPENAI_BASE_URL=optional_custom_endpoint

### Notes:

-   `OPENAI_MODEL` must be set
-   `OPENAI_BASE_URL` is optional (for proxy/self-hosted APIs)

------------------------------------------------------------------------

## 7. Core Modules Explained

### 7.1 SimpleAgent

Handles all LLM interactions.

#### Methods:

-   `ask(prompt)`
    -   Sends prompt to LLM
    -   Returns generated response
-   `analyze_netlist()`
    -   Explains functionality of netlist
-   `translate_netlist_to_rtl()`
    -   Converts gate-level → RTL
    -   Ensures synthesizable output
-   `generate_testbench()`
    -   Produces self-checking testbench
-   `fix_error()`
    -   Debugs RTL or testbench using error logs

------------------------------------------------------------------------

### 7.2 Utility Functions

#### `extract_verilog_modules()`

-   Extracts valid Verilog module from noisy LLM output

#### `ensure_output_reg_for_assigned_signals()`

-   Fixes incorrect `output` declarations
-   Converts to `output reg` if assigned in procedural blocks

#### `run_command()`

-   Wrapper for subprocess execution

------------------------------------------------------------------------

### 7.3 Simulation Engine

#### `compile_and_run()`

Steps: 1. Compile with `iverilog` 2. Run with `vvp` 3. Generate waveform
(`dump.vcd`) 4. Launch GTKWave (optional)

------------------------------------------------------------------------

### 7.4 Debug Logic

#### `process_and_simulate()`

-   Runs simulation loop
-   On failure:
    -   Detects error origin
    -   Calls LLM to fix
    -   Re-runs simulation

#### `is_testbench_error()`

-   Heuristically determines:
    -   RTL bug vs Testbench bug

------------------------------------------------------------------------

## 8. Execution Modes

### 8.1 Process Entire Dataset

``` bash
python main.py
```

### 8.2 Process Specific Case Folder

``` bash
python main.py --case aes_bug_v1
```

### 8.3 Process Single Netlist

``` bash
python main.py --netlist-name comparator.v
```

------------------------------------------------------------------------

## 9. Detailed Workflow

### Step 1: Load Netlist

-   Reads `.v` file from Netlist directory

### Step 2: RTL Generation

-   LLM reconstructs behavioral logic
-   Cleans output

### Step 3: Testbench Generation

-   Builds self-checking verification

### Step 4: Compilation

``` bash
iverilog -o sim tb.v rtl.v
```

### Step 5: Simulation

``` bash
vvp sim
```

### Step 6: Debug Loop

-   If failure:
    -   Capture error
    -   Send to LLM
    -   Replace faulty file
    -   Retry

------------------------------------------------------------------------

## 10. Output Artifacts

  File        Description
  ----------- --------------------
  RTL         Behavioral Verilog
  Testbench   Self-checking TB
  dump.vcd    Waveform
  sim\_\*     Compiled binaries

------------------------------------------------------------------------

## 11. Design Decisions

### Why LLM?

-   Netlists lose semantic structure
-   Traditional tools cannot reconstruct intent easily
-   LLM infers:
    -   Patterns (MUX, ALU, FSM)
    -   Arithmetic operations
    -   Control logic

### Why Self-Checking TB?

-   Enables automated correctness validation
-   Eliminates manual inspection

------------------------------------------------------------------------

## 12. Limitations

-   Large netlists (\>100KB) are skipped
-   LLM may:
    -   Misinterpret complex logic
    -   Generate syntactically valid but incorrect RTL
-   Debug loop is heuristic-based (not guaranteed)

------------------------------------------------------------------------

## 13. Future Improvements

-   Multi-module netlist support
-   Formal verification integration
-   Better error classification
-   Parallel processing
-   Coverage metrics

------------------------------------------------------------------------

## 14. Troubleshooting

### Error: `OPENAI_MODEL not set`

→ Ensure `.env` is configured

### Error: `iverilog not found`

→ Install Icarus Verilog

### Infinite failures

→ Increase `max_attempts` or inspect manually

------------------------------------------------------------------------
