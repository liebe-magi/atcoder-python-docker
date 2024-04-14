import json
import os
import subprocess
import sys

use_pypy = os.environ.get("PYPY", False)

subcommands = ["new", "run"]
flags = ["-s", "--submit", "--pypy", "--cpython"]

if len(sys.argv) == 1:
    print("Usage: atc [subcommand] [contest or problem id] [flag]")
    exit()
if sys.argv[1] not in subcommands:
    print(f"Error: Invalid subcommand {sys.argv[1]}")
    print("Subcommands must be one of the following: [new, run]")
    exit()

if sys.argv[1] == "new":
    if len(sys.argv) != 3:
        print("Usage: atc new [contest id]")
        exit()
    contest_id = sys.argv[2]
    cmd = f"acc new {contest_id}"
    subprocess.run(cmd.split(" "))
    exit()
else:
    if len(sys.argv) == 3 or len(sys.argv) == 4 or len(sys.argv) == 5:
        if len(sys.argv[2].split("-")) != 2:
            print("Error: Invalid problem id")
            print("Problem id must be in the format [contest_id]-[task_id]")
            exit()
        contest_id, task_id = sys.argv[2].split("-")
        flag = []
        if len(sys.argv) >= 4:
            if sys.argv[3] in flags:
                if sys.argv[3] == "-s":
                    flag.append("--submit")
                else:
                    flag.append(sys.argv[3])
            else:
                print("Error: Invalid flag")
                print("Flag must be one of the following: [-s, --submit, --pypy]")
                exit()
        if len(sys.argv) == 5:
            if sys.argv[4] in flags:
                if sys.argv[4] == "-s":
                    flag.append("--submit")
                else:
                    flag.append(sys.argv[4])
            else:
                print("Error: Invalid flag")
                print("Flag must be one of the following: [-s, --submit, --pypy]")
                exit()
        if "--cpython" in flag and "--pypy" in flag:
            print("Error: --cpython and --pypy cannot be used together")
            exit()
        if "--cpython" not in flag and "--pypy" not in flag:
            if use_pypy:
                flag.append("--pypy")
            else:
                flag.append("--cpython")
        if "--submit" not in flag:
            if "--cpython" in flag:
                cmd = [
                    "oj",
                    "test",
                    "-d",
                    f"contents/{contest_id}/{task_id}/tests",
                    "-c",
                    f"python3.11 contents/{contest_id}/{task_id}/main.py",
                ]
            else:
                cmd = [
                    "oj",
                    "test",
                    "-d",
                    f"contents/{contest_id}/{task_id}/tests",
                    "-c",
                    f"pypy3 contents/{contest_id}/{task_id}/main.py",
                ]
            subprocess.run(cmd)
        else:
            info = json.load(open(f"contents/{contest_id}/contest.acc.json", "r"))
            data = {}
            for task in info["tasks"]:
                if task_id == task["directory"]["path"]:
                    data["id"] = task["id"]
                    data["dir"] = task_id
                    data["url"] = task["url"]
                    break
            if data == {}:
                print(f"Error: {sys.argv[2]} is not found in the contest")
                exit()
            else:
                cmd = f"acc submit -c {contest_id} -t {data['id']} "
                if "--cpython" in flag:
                    cmd += (
                        f"contents/{contest_id}/{task_id}/main.py -- --no-guess -l 5055"
                    )
                else:
                    cmd += (
                        f"contents/{contest_id}/{task_id}/main.py -- --no-guess -l 5078"
                    )

                subprocess.run(cmd.split(" "))
    else:
        print("Usage: atc run [problem id] [flag]")
        exit()
