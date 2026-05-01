#!/usr/bin/env python3
import os
import subprocess
import re
import sys
import shutil
from datetime import datetime

# --- Configuration ---

PROJECTS_DIR = os.path.join(os.getcwd(), "projects")

# Number of runs per script
NUM_RUNS = int(sys.argv[1]) if len(sys.argv) > 1 else 5
REPORT = NUM_RUNS == 1

if REPORT:
    SUBDIRS = [
        "handwritten",
        "oreilly-bank",
        "escadatpc-c",
        "java-design-patterns",
        "jdbc-course",
        "opennms",
        "oscar"
    ]
else:
    SUBDIRS = [
        # "handwritten",
        # "oreilly-bank",
        # "escadatpc-c",
        # "java-design-patterns",
        # "jdbc-course",
        "opennms",
        # "oscar",
    ]

# Map folder names to "8" or "17" (default is 17)
PROJECT_JAVA_VERSIONS = {
    "oscar": "8"
}

JAVA_PATHS = {
    "8": "/usr/lib/jvm/java-8-openjdk-amd64",
    "17": "/usr/lib/jvm/java-17-openjdk-amd64"
}

# --- Helper Functions ---

def parse_time_ms(stdout_content):
    """Extracts 'Elapsed time (compilation): X milliseconds' from script output"""
    match = re.search(r"Elapsed time \(compilation\): (\d+) milliseconds", stdout_content)
    return int(match.group(1)) if match else None

def parse_max_rss(stderr_content):
    """Extracts 'Maximum resident set size (kbytes): X' from /usr/bin/time output"""
    match = re.search(r"Maximum resident set size \(kbytes\): (\d+)", stderr_content)
    return int(match.group(1)) if match else None

def calculate_trimmed_average(values):
    """Computes average excluding min and max values"""
    if len(values) < 3:
        return "NA"
    
    sorted_vals = sorted(values)
    # Remove min and max (first and last)
    trimmed = sorted_vals[1:-1]
    avg = sum(trimmed) / len(trimmed)
    
    # Return formatted string (int for memory, float for time if needed)
    return f"{int(avg)}" 

# --- Main Execution ---

# Create log directories if they don't exist
if not os.path.exists(os.path.join("logs", "output")):
    os.makedirs(os.path.join("logs", "output"), exist_ok=True)

if REPORT:
    # Delete old opslog if exists and create new
    opslog_path = os.path.join("logs", "opslog")
    if os.path.exists(opslog_path):
        shutil.rmtree(opslog_path)
    os.makedirs(opslog_path)

def run_experiments():
    base_dir = os.getcwd()

    subprocess.run(["bash", "scripts/buildOpsc.sh"], check=True)

    for project_dir in SUBDIRS:
        project_path = os.path.join(PROJECTS_DIR, project_dir)
        if not os.path.isdir(project_path):
            print(f"Skipping missing dir: {project_path}")
            continue

        # Determine Java Version
        java_version = PROJECT_JAVA_VERSIONS.get(project_dir, "17") # Default to 17
        java_home = JAVA_PATHS.get(java_version)
        
        if not java_home or not os.path.exists(java_home):
            print(f"Error: JAVA_HOME for version {java_version} not found at {java_home}")
            continue

        # Prepare Environment Variables
        env = os.environ.copy()
        env["JAVA_HOME"] = java_home
        env["PATH"] = f"{java_home}/bin:" + env["PATH"]

        print(f"=== Project: {project_dir} (Java {java_version}) ===", flush=True)

        prerun_path = os.path.join(project_path, "prerun.sh")
        if os.path.isfile(prerun_path) and os.access(prerun_path, os.X_OK):
            print("  Running prerun.sh...", flush=True)
            try:
                result = subprocess.run(
                    ["bash", "./prerun.sh"],
                    cwd=project_path,
                    env=env,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True,
                    check=False
                )
                if result.returncode != 0:
                    print(f"  prerun.sh failed with exit code {result.returncode}")
                    print(result.stdout)
                    print(result.stderr)
                    continue
                print("  prerun.sh completed successfully.")
                log_file = os.path.join("logs", "output", f"{project_dir}_prerun.log")
                with open(log_file, "w") as f:
                    f.write(f"=== Date/Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} ===\n")
                    f.write(f"=== CMD: bash ./prerun.sh ===\n\n")
                    f.write("--- STDOUT ---\n")
                    f.write(result.stdout)
                    f.write("\n\n--- STDERR ---\n")
                    f.write(result.stderr)

            except Exception as e:
                print(f"  prerun.sh failed with error: {e}")
                print(result.stdout)
                print(result.stderr)
                continue


        # Find and run all scripts matching run*.sh
        for script_name in os.listdir(project_path):
            if not script_name.startswith("run") or not script_name.endswith(".sh"):
                continue

            # In report mode, we only need runs with OPSC
            if REPORT and ("skipcf" in script_name or "nocf" in script_name or "value" in script_name):
                continue

            # In performance mode, skip manual annotation runs
            if not REPORT and ("-annos" in script_name or "-annotated" in script_name):
                continue

            script_path = os.path.join(project_path, script_name)
            
            if not os.path.isfile(script_path) or not os.access(script_path, os.X_OK):
                print(f"  Script {script_name} is not executable or missing.", flush=True)
                continue

            print(f"  Running {script_name} ({NUM_RUNS} runs)...", flush=True)
            
            times = []
            mems = []

            run_name = f"{project_dir}_{script_name.removesuffix('.sh')}"
            opslog_name = "opslog" if REPORT else "opslog_performance"
            opslogdir = os.path.join(base_dir, "logs", opslog_name, run_name)

            for i in range(1, NUM_RUNS + 1):
                # Construct command: /usr/bin/time -v ./run.sh
                # We use bash explicitly to ensure the script runs
                cmd = ["/usr/bin/time", "-v", "bash", f"{script_name}", "--opslogdir", opslogdir]
                
                try:
                    # Run process
                    result = subprocess.run(
                        cmd,
                        cwd=project_path,
                        env=env,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True, # Decode output to string
                        check=False # Don't crash python on script failure
                    )

                    script_basename, _ = os.path.splitext(script_name)
                    log_file = os.path.join("logs", "output", f"{project_dir}_{script_basename}_{i}.log")
                    with open(log_file, "w") as f:
                        f.write(f"=== Date/Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} ===\n")
                        f.write(f"=== CMD: {' '.join(cmd)} ===\n")
                        f.write(f"=== EXIT CODE: {result.returncode} ===\n\n")
                        f.write("--- STDOUT ---\n")
                        f.write(result.stdout)
                        f.write("\n\n--- STDERR ---\n")
                        f.write(result.stderr)

                    # Parse results
                    ms = parse_time_ms(result.stdout)
                    mem_kb = parse_max_rss(result.stderr)

                    if result.returncode != 0:
                        print(f"    Run {i}: FAILED (exit code {result.returncode})", flush=True)
                    elif ms is None or mem_kb is None:
                        print(f"    Run {i}: FAILED (parsing error)", flush=True)
                    else:
                        print(f"    Run {i}: {ms} ms, Max RSS: {mem_kb} KB", flush=True)
                        times.append(ms)
                        mems.append(mem_kb)

                except Exception as e:
                    print(f"    Run {i}: CRITICAL ERROR {e}")
                    raise e

            # Compute Statistics
            if len(times) >= 3:
                avg_time = calculate_trimmed_average(times)
                avg_mem = calculate_trimmed_average(mems)
                print(f"  -> Result: Time={avg_time} ms, RSS={avg_mem} KB (Trimmed Avg)")
            elif not REPORT:
                print(f"  -> Result: Not enough successful runs to compute average.")
            print("-" * 40)

if __name__ == "__main__":
    if REPORT:
        print("Running experiments in REPORT mode (1 run per script, generating paper results)...", flush=True)
    else:
        print(f"Running experiments in PERFORMANCE mode ({NUM_RUNS} runs per script, no paper results)...", flush=True)
    run_experiments()
    if REPORT:
        # Generate result data (generate_results.py)
        print("Experiments finished. Generating paper results...", flush=True)
        subprocess.run(["python3", "scripts/generate_results.py"], check=True)
    else:
        print("Experiments finished.")

