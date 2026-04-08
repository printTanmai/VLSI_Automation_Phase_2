import argparse
import os
import re
import subprocess
from pathlib import Path
from dotenv import load_dotenv
from openai import OpenAI

BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / ".env")

LMSTUDIO_BASE_URL = os.getenv("LMSTUDIO_BASE_URL", "http://127.0.0.1:1234/v1")
DEFAULT_MODEL = os.getenv("MODEL_NAME")
NETLIST_DIR = BASE_DIR / "Netlist"
GENERATED_RTL_DIR = BASE_DIR / "generated RTL"
TESTBENCH_DIR = BASE_DIR / "testbench"


def get_llm_client() -> OpenAI:
    return OpenAI(base_url=LMSTUDIO_BASE_URL, api_key="lm-studio")


def ensure_path_exists(path: Path) -> None:
    if not path.exists():
        raise FileNotFoundError(f"Path does not exist: {path}")


def run_command(command: list[str], cwd: Path | None = None) -> tuple[int, str, str]:
    result = subprocess.run(command, cwd=cwd, capture_output=True, text=True)
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def extract_verilog_modules(text: str) -> str:
    # Find the start of the first module
    start = text.find('module ')
    if start == -1:
        return text.strip()
    # Find the end of the module
    end = text.find('endmodule', start)
    if end == -1:
        return text[start:].strip()
    end += len('endmodule')
    return text[start:end].strip()


def ensure_output_reg_for_assigned_signals(rtl_text: str) -> str:
    # If an output signal is assigned inside always blocks, declare it as output reg.
    outputs = re.findall(r"output\s+(?:reg\s+)?(?:\[[^\]]+\]\s*)?([A-Za-z_]\w*)", rtl_text)
    if not outputs:
        return rtl_text

    assigned_outputs = set()
    for signal in outputs:
        if re.search(rf"\b{re.escape(signal)}\b\s*=", rtl_text):
            assigned_outputs.add(signal)
        if re.search(rf"\b{re.escape(signal)}\b\s*\[", rtl_text):
            # avoid false matches, only detect direct assignments or bit-slice usage for output regs
            assigned_outputs.add(signal)

    if not assigned_outputs:
        return rtl_text

    def replace_decl(match: re.Match) -> str:
        decl = match.group(0)
        name = match.group(1)
        if name in assigned_outputs and "output reg" not in decl:
            return decl.replace("output", "output reg", 1)
        return decl

    rtl_text = re.sub(r"output\s+(?:reg\s+)?(?:\[[^\]]+\]\s*)?([A-Za-z_]\w*)", replace_decl, rtl_text)
    return rtl_text


def find_netlist_root(netlist_dir: Path) -> Path:
    if netlist_dir.exists():
        return netlist_dir
    raise FileNotFoundError(f"Netlist directory '{netlist_dir}' does not exist.")


class SimpleAgent:
    def __init__(self, llm_client: OpenAI, model: str | None = None):
        self.llm = llm_client
        self.model = model or DEFAULT_MODEL
        if not self.model:
            raise RuntimeError("MODEL_NAME is not set in environment or .env")

    def ask(self, prompt: str) -> str:
        response = self.llm.chat.completions.create(
            model=self.model,
            messages=[
                {"role": "system", "content": "You are a helpful RTL and Verilog assistant."},
                {"role": "user", "content": prompt},
            ],
            temperature=0.2,
        )
        return response.choices[0].message.content or ""

    def read_file(self, path: Path) -> str:
        ensure_path_exists(path)
        return path.read_text(encoding="utf-8", errors="ignore")

    def analyze_netlist(self, netlist_path: Path) -> str:
        netlist_text = self.read_file(netlist_path)
        prompt = (
            "You are an RTL reverse-engineering assistant.\n"
            "Read this synthesized gate-level netlist and explain in simple terms what the design does, "
            "what the top-level ports are, and how the main logic is structured.\n\n"
            f"{netlist_text}"
        )
        return self.ask(prompt)

    def translate_netlist_to_rtl(self, netlist_path: Path, output_path: Path) -> Path:
        netlist_text = self.read_file(netlist_path)
        prompt = (
            "You are a Verilog RTL synthesis expert.\n"
            "Convert this gate-level synthesized netlist into equivalent behavioral RTL-level Verilog code.\n"
            "Use high-level constructs like always blocks, if-else statements, case statements, and operators.\n"
            "Avoid low-level gate instantiations and intermediate wire assignments.\n"
            "For outputs assigned in always blocks, declare them as 'output reg'.\n"
            "Keep the same module name, ports, and functionality.\n"
            "Produce only valid, synthesizable Verilog code without explanations or extra text.\n\n"
            f"{netlist_text}"
        )
        response = self.ask(prompt)
        rtl_text = extract_verilog_modules(response)
        rtl_text = ensure_output_reg_for_assigned_signals(rtl_text)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(rtl_text, encoding="utf-8")
        return output_path

    def generate_testbench(self, rtl_path: Path, tb_output_path: Path, netlist_path: Path = None) -> Path:
        rtl_text = self.read_file(rtl_path)
        module_name = rtl_path.stem.split('.')[0]
        prompt = (
            "You are a Verilog testbench expert.\n"
            f"Write a comprehensive SELF-CHECKING Verilog testbench for this RTL module roughly acting as '{module_name}'.\n"
            "Declare all module inputs as reg and all outputs as wire.\n"
            "Never assign a value to an output signal in the testbench.\n"
            "You MUST include self-checking logic. Calculate the expected output based on the standard intended behavior of this block (e.g., if it's bin2gray, calculate the exact gray code), and verify the RTL output matches.\n"
            "If the outputs do not match the expected behavior, use $display(\"ERROR: ...\") and invoke $fatal(1);\n"
            "Include: module instantiation, stimulus for all inputs (preferably exhaustively via a loop or comprehensive test vectors), \n"
            "monitoring outputs, $dumpfile(\"dump.vcd\") and $dumpvars for waveform viewing, and finally a $finish if all tests pass.\n"
            "Make it self-contained and runnable with iverilog.\n"
            "Produce only valid Verilog code without explanations.\n\n"
            f"{rtl_text}"
        )
        response = self.ask(prompt)
        tb_text = extract_verilog_modules(response)
        tb_output_path.parent.mkdir(parents=True, exist_ok=True)
        tb_output_path.write_text(tb_text, encoding="utf-8")
        return tb_output_path

    def fix_error(self, netlist_path: Path, rtl_path: Path, tb_path: Path, error_message: str, target_tb: bool = False) -> tuple[str, str]:
        netlist_text = self.read_file(netlist_path)
        rtl_text = self.read_file(rtl_path)
        tb_text = self.read_file(tb_path)
        file_to_fix = "Testbench" if target_tb else "RTL"
        prompt = (
            "You are a Verilog debugging expert.\n"
            f"Analyze the following error message from iverilog compilation/simulation.\n"
            f"The error is located in the {file_to_fix} code. Please provide the fully corrected Verilog code for the {file_to_fix} ONLY.\n"
            "Produce ONLY valid Verilog code without explanations. Make sure all procedural code (like 'for' or '#10') is inside an 'initial' or 'always' block.\n\n"
            f"Netlist:\n{netlist_text}\n\n"
            f"RTL:\n{rtl_text}\n\n"
            f"Testbench:\n{tb_text}\n\n"
            f"Error message:\n{error_message}\n"
        )
        response = self.ask(prompt)
        corrected_code = extract_verilog_modules(response)
        
        file_type = 'TESTBENCH' if target_tb else 'RTL'
        if file_type == 'RTL':
            corrected_code = ensure_output_reg_for_assigned_signals(corrected_code)
            rtl_path.write_text(corrected_code, encoding="utf-8")
        elif file_type == 'TESTBENCH':
            tb_path.write_text(corrected_code, encoding="utf-8")
        return file_type, corrected_code

    def list_netlist_files(self, root_dir: Path, extension: str = ".v") -> list[Path]:
        ensure_path_exists(root_dir)
        return sorted(root_dir.rglob(f"*{extension}"))


def process_and_simulate(agent: SimpleAgent, netlist_file: Path, generated_rtl: Path, generated_tb: Path, binary_name: str, max_attempts: int = 15) -> bool:
    """
    Process netlist to RTL, generate testbench, and iteratively fix errors.
    """
    attempt = 0
    while attempt < max_attempts:
        attempt += 1
        print(f"\n  [Attempt {attempt}] Simulating with iverilog...")
        success, error_msg = compile_and_run(generated_rtl, generated_tb, binary_name=binary_name)
        
        if success:
            print(f"  ✓ Simulation PASSED on attempt {attempt}")
            return True
        
        if attempt >= max_attempts:
            print(f"  ✗ Simulation FAILED after {max_attempts} attempts. Giving up.")
            return False
        
        # Determine which file has the error and fix it
        print(f"  Compilation/simulation error detected. Asking model to analyze and fix...")
        target_tb = is_testbench_error(error_msg, generated_rtl, generated_tb)
        fixed_file, _ = agent.fix_error(netlist_file, generated_rtl, generated_tb, error_msg, target_tb)
        print(f"    {fixed_file} regenerated.")
    
    return False


def is_testbench_error(error_msg: str, rtl_path: Path, tb_path: Path) -> bool:
    if "syntax error" in error_msg.lower() or "error:" in error_msg.lower() and "file:" not in error_msg.lower():
        # If the testbench threw a self-checking logic mismatch error, the RTL is logically wrong.
        if "ERROR:" in error_msg:
             return False
    if tb_path.name in error_msg or str(tb_path) in error_msg:
        # If it's an explicit compilation error in the testbench
        if "ERROR:" not in error_msg:
             return True
    if rtl_path.name in error_msg or str(rtl_path) in error_msg:
        return False
    
    first_line = error_msg.splitlines()[0] if error_msg else ""
    if rtl_path.name in first_line:
        return False
    if tb_path.name in first_line:
        return True
    return False


def compile_and_run(rtl_file: Path, tb_file: Path, binary_name: str) -> tuple[bool, str]:
    compile_output = BASE_DIR / binary_name
    command = ["iverilog", "-o", str(compile_output), str(tb_file), str(rtl_file)]
    code, out, err = run_command(command, cwd=BASE_DIR)
    print(f"iverilog return code: {code}")
    if out:
        print("IVERILOG STDOUT:\n", out)
    if err:
        print("IVERILOG STDERR:\n", err)
    if code != 0:
        return False, err

    code, out, err = run_command(["vvp", str(compile_output)], cwd=BASE_DIR)
    print(f"vvp return code: {code}")
    if out:
        print("VVP STDOUT:\n", out)
    if err:
        print("VVP STDERR:\n", err)
    if code != 0:
        error_msg = f"{out}\n{err}".strip()
        return False, error_msg

    vcd_path = BASE_DIR / "dump.vcd"
    if vcd_path.exists():
        print(f"Waveform dump generated at: {vcd_path}")
        gtkwave_code, _, _ = run_command(["gtkwave", str(vcd_path)], cwd=BASE_DIR)
        if gtkwave_code != 0:
            print("Unable to launch GTKWave automatically. Open dump.vcd manually.")
    else:
        print("No dump.vcd file found after simulation.")
    return True, ""


def main() -> None:
    parser = argparse.ArgumentParser(description="Translate synthesized netlist to RTL, generate testbench, and simulate.")
    parser.add_argument("--netlist-dir", type=Path, default=NETLIST_DIR, help="Directory containing synthesized netlists.")
    parser.add_argument("--output-dir", type=Path, default=GENERATED_RTL_DIR, help="Directory where generated RTL files are stored.")
    parser.add_argument("--model", type=str, default=DEFAULT_MODEL, help="LM Studio model name.")
    parser.add_argument("--case", type=str, default=None, help="Case directory name inside the netlist directory, e.g. aes_bug_v1.")
    parser.add_argument("--netlist-name", type=str, default=None, help="Specific netlist file name to process, e.g. magnitude_comparator.300.syn.v.")
    args = parser.parse_args()

    netlist_root = find_netlist_root(args.netlist_dir)
    agent = SimpleAgent(get_llm_client(), model=args.model)

    if args.netlist_name:
        # Process specific netlist file
        netlist_file = netlist_root / args.netlist_name
        if not netlist_file.exists():
            print(f"Specified netlist file '{args.netlist_name}' not found in {netlist_root}")
            return
        case_name = "specified"
        case_out_dir = args.output_dir / case_name
        case_tb_dir = TESTBENCH_DIR / case_name
        print(f"Processing specific netlist: {args.netlist_name}")
        relative_path = Path(args.netlist_name)
        output_path = case_out_dir / relative_path
        generated_rtl = agent.translate_netlist_to_rtl(netlist_file, output_path)
        print(f"  Generated RTL: {generated_rtl.relative_to(BASE_DIR)}")

        # Generate testbench
        tb_output_path = case_tb_dir / relative_path.with_name(f"tb_{relative_path.name}")
        generated_tb = agent.generate_testbench(generated_rtl, tb_output_path)
        print(f"  Generated Testbench: {generated_tb.relative_to(BASE_DIR)}")

        # Compile and run simulation with retry on errors
        success = process_and_simulate(agent, netlist_file, generated_rtl, generated_tb, binary_name=f"sim_{relative_path.stem}")
        print(f"  Simulation {'PASSED' if success else 'FAILED'} for {relative_path.stem}")
    else:
        # Process all netlists
        if args.case:
            target_dirs = [netlist_root / args.case]
        else:
            target_dirs = [p for p in netlist_root.iterdir() if p.is_dir()]
            if not target_dirs:
                # If no subdirs, treat the root as a case
                target_dirs = [netlist_root]

        generated_files = []
        for case_dir in target_dirs:
            if not case_dir.exists():
                print(f"Skipping missing case directory: {case_dir}")
                continue
            case_name = case_dir.name if case_dir != netlist_root else "root"
            print(f"Processing case: {case_name}")
            case_out_dir = args.output_dir / case_name
            case_tb_dir = TESTBENCH_DIR / case_name
            for netlist_file in agent.list_netlist_files(case_dir):
                if netlist_file.stat().st_size > 100 * 1024:
                    print(f"Skipping {netlist_file} due to size (>100KB)")
                    continue
                print(f"  Translating netlist: {netlist_file.relative_to(netlist_root)}")
                relative_path = netlist_file.relative_to(case_dir)
                output_path = case_out_dir / relative_path
                generated_rtl = agent.translate_netlist_to_rtl(netlist_file, output_path)
                generated_files.append(generated_rtl)
                print(f"    Generated RTL: {generated_rtl.relative_to(BASE_DIR)}")

                # Generate testbench
                tb_output_path = case_tb_dir / relative_path.with_name(f"tb_{relative_path.name}")
                generated_tb = agent.generate_testbench(generated_rtl, tb_output_path)
                print(f"    Generated Testbench: {generated_tb.relative_to(BASE_DIR)}")

                # Compile and run simulation with retry on errors
                success = process_and_simulate(agent, netlist_file, generated_rtl, generated_tb, binary_name=f"sim_{case_name}_{relative_path.stem}")
                print(f"  Simulation {'PASSED' if success else 'FAILED'} for {relative_path.stem}")

        if not generated_files:
            print("No netlist files were translated. Check the netlist directory and file extensions.")


if __name__ == "__main__":
    main()
