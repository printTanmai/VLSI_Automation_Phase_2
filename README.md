# RTL Gen Agent

`RTL Gen Agent` is a Python-based automation tool for converting synthesized Verilog gate-level netlists into higher-level behavioral RTL, generating self-checking testbenches, and validating the result with simulation.

The project is built around an LLM-assisted workflow:

1. Read a synthesized netlist from `Netlist/`
2. Ask an LLM to reconstruct equivalent RTL Verilog
3. Ask the LLM to generate a self-checking testbench
4. Compile and simulate the generated RTL with `iverilog` and `vvp`
5. If compilation or simulation fails, ask the LLM to repair the RTL or testbench
6. Save a waveform dump and optionally open it automatically

This makes the project useful for:

- reverse-engineering synthesized logic into more readable RTL
- quickly generating validation collateral for small and medium modules
- checking whether an inferred RTL implementation behaves like the input netlist
- building example datasets of `netlist -> RTL -> testbench -> simulation`

## Features

- Converts synthesized gate-level Verilog into behavioral RTL
- Generates self-checking Verilog testbenches
- Runs simulation using `iverilog` and `vvp`
- Retries failed runs by asking the model to repair generated code
- Validates model responses before writing them to disk
- Supports both `codex-cli` and OpenAI API backends
- Opens the generated waveform automatically after a successful run

## Project Structure

```text
RTL_gen_agent/
|-- agent.py
|-- .env
|-- Netlist/
|-- generated RTL/
|-- testbench/
|-- *.vcd
|-- sim_*
```

Key directories and files:

- `agent.py`
  Main entrypoint and workflow implementation.
- `Netlist/`
  Input synthesized Verilog netlists.
- `generated RTL/`
  Generated RTL outputs grouped by case.
- `testbench/`
  Generated testbenches grouped by case.
- `dump.vcd` or other `*.vcd`
  Waveform files generated after simulation.
- `sim_*`
  Compiled simulation binaries created by `iverilog`.

## How It Works

The script performs the following stages for each selected netlist:

### 1. Netlist read

The target netlist is loaded from the configured netlist directory.

### 2. RTL generation

The selected backend is prompted to convert the gate-level netlist into synthesizable RTL Verilog. The script then:

- extracts the Verilog module from the model response
- rejects non-Verilog responses
- fixes output declarations to `output reg` when the generated code assigns outputs procedurally

### 3. Testbench generation

The generated RTL is sent back to the model to create a self-checking Verilog testbench. The expected behavior is inferred from the module intent.

### 4. Simulation

The script compiles and simulates the generated files with:

```powershell
iverilog -o <binary> <testbench> <rtl>
vvp <binary>
```

### 5. Repair loop

If compilation fails or the self-checking testbench detects a mismatch, the script asks the model to repair either:

- the RTL, or
- the testbench

This loop continues until success or until the retry limit is reached.

### 6. Waveform generation

If simulation succeeds and the testbench dumps waveforms, the newest VCD file is detected and opened automatically.

## Requirements

You need the following installed:

- Python 3.10 or newer
- `iverilog`
- `vvp`
- `codex` CLI if using the `codex-cli` backend
- optional: `gtkwave` for opening VCD files directly

Python packages:

```powershell
pip install python-dotenv openai
```

Notes:

- `python-dotenv` is used to load `.env`
- `openai` is only required if you use `--backend openai`
- if `gtkwave` is not installed, Windows will try to open the VCD with the default associated application

## Environment Configuration

Create or edit `.env` in the project root:

```env
LLM_BACKEND=codex-cli
OPENAI_MODEL=gpt-5.4
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_BASE_URL=
```

Meaning of each variable:

- `LLM_BACKEND`
  Default backend. Supported values are `codex-cli` and `openai`.
- `OPENAI_MODEL`
  Default model name.
- `OPENAI_API_KEY`
  Required when using the OpenAI API backend.
- `OPENAI_BASE_URL`
  Optional custom API base URL.

## Supported Backends

### `codex-cli`

This is the current default in the repo.

Behavior:

- runs `codex exec`
- sends prompts through stdin
- parses JSON event output from the CLI
- extracts the final assistant text from the command output

Use this when:

- you already use the local Codex CLI
- you want the project to rely on the CLI instead of direct API calls

### `openai`

This backend uses the OpenAI Python SDK directly.

Use this when:

- you prefer API-based access
- you want explicit control through `OPENAI_API_KEY` and `OPENAI_BASE_URL`

## Usage

### Run one specific netlist

```powershell
python agent.py --netlist-name mux4to1.300.syn.v
```

### Run all netlists

```powershell
python agent.py
```

### Run a specific case directory

```powershell
python agent.py --case root
```

### Use a specific backend

```powershell
python agent.py --backend codex-cli --netlist-name bin2gray.syn.v
python agent.py --backend openai --netlist-name bin2gray.syn.v
```

### Use a specific model

```powershell
python agent.py --model gpt-5.4 --netlist-name priority_encoder_8bit.syn.v
```

### Disable automatic waveform opening

```powershell
python agent.py --netlist-name mux4to1.300.syn.v --no-open-waveform
```

## Command-Line Arguments

`agent.py` supports the following arguments:

- `--netlist-dir`
  Directory containing synthesized netlists.

- `--output-dir`
  Directory where generated RTL files are written.

- `--model`
  Model name for the selected backend.

- `--backend`
  Backend to use. Supported values:
  - `codex-cli`
  - `openai`

- `--open-waveform`
  Open the generated VCD automatically after successful simulation.

- `--no-open-waveform`
  Do not open the VCD after successful simulation.

- `--case`
  Select a specific case directory inside the netlist root.

- `--netlist-name`
  Run only one specific netlist file.

## Input Expectations

The tool works best when:

- the netlist is small or medium in size
- the top-level module is clear
- port names still reflect the original design intent
- the design is combinational or uses simple sequential logic

The script skips netlists larger than 100 KB when running in batch mode.

## Output Layout

When you run a specific netlist with `--netlist-name`, outputs are written under `specified/`.

Examples:

- RTL:
  `generated RTL/specified/mux4to1.300.syn.v`
- Testbench:
  `testbench/specified/tb_mux4to1.300.syn.v`
- Waveform:
  `dump.vcd`
- Compiled simulation binary:
  `sim_mux4to1.300.syn`

When you run directory-based cases, outputs are grouped by case name.

## Example Workflow

Example:

```powershell
python agent.py --netlist-name priority_encoder_8bit.syn.v
```

Typical console flow:

1. The script announces which netlist is being processed
2. RTL is generated and saved
3. The testbench is generated and saved
4. `iverilog` compiles both files
5. `vvp` runs the simulation
6. If all checks pass, the VCD file is reported and opened

## Error Handling

The project includes a repair loop for generated code.

If simulation fails:

- the script inspects the error
- it decides whether the problem is more likely in the RTL or testbench
- it asks the model to regenerate only the failing artifact
- it retries simulation

If the model returns invalid non-Verilog content:

- the response is rejected
- the script raises an explicit error instead of saving unusable text into `.v` files

## Current Limitations

- Functional equivalence depends on the LLM correctly inferring behavior from the netlist
- Complex sequential designs may need manual review
- Testbench quality depends on how clearly the module behavior can be inferred
- The repair loop is heuristic, not formally verified
- Waveform opening depends on `gtkwave` or system file association
- Large or heavily optimized netlists may be difficult for the model to reconstruct accurately

## Recommended Usage Pattern

For best results:

1. Start with one netlist at a time
2. Review the generated RTL manually
3. Review the generated testbench, especially expected-value logic
4. Inspect the waveform if behavior seems suspicious
5. Use batch mode only after confirming the flow works for your dataset

## Troubleshooting

### `Could not find 'codex' on PATH`

Install the Codex CLI and ensure `codex` is available in your shell.

### `The 'openai' package is not installed`

Install dependencies:

```powershell
pip install openai python-dotenv
```

### `OPENAI_MODEL or MODEL_NAME is not set`

Set `OPENAI_MODEL` in `.env` or pass `--model`.

### `Specified netlist file ... not found`

Check:

- the filename
- the `Netlist/` location
- whether you meant `--case` or `--netlist-name`

### Simulation fails repeatedly

Check the generated files:

- RTL in `generated RTL/...`
- testbench in `testbench/...`

Then inspect:

- port ordering
- inferred functionality
- self-checking expected-value logic
- waveform behavior in the generated VCD

## Files To Look At First

If you want to understand or modify the project, start here:

- [agent.py](c:\Users\tanma\RTL_gen_agent\agent.py)
- [Netlist](c:\Users\tanma\RTL_gen_agent\Netlist)
- [generated RTL](c:\Users\tanma\RTL_gen_agent\generated RTL)
- [testbench](c:\Users\tanma\RTL_gen_agent\testbench)

## Future Improvements

Possible next steps for the project:

- add structured logging
- add per-run output directories instead of reusing `dump.vcd`
- save simulation logs to disk
- add formal equivalence checks for supported designs
- support SystemVerilog testbench generation
- add unit tests for helper functions in `agent.py`
- add prompt templates or few-shot examples for common RTL blocks
