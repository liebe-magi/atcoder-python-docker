import json
import subprocess
import sys

contest_id = sys.argv[1]
task_id = sys.argv[2]
interpreter = sys.argv[3]

info = json.load(open(f"contents/{contest_id}/contest.acc.json", "r"))
data = {}
for task in info["tasks"]:
    if task_id == task["directory"]["path"]:
        data["id"] = task["id"]
        data["dir"] = task_id
        data["url"] = task["url"]
        break

if data == {}:
    print("Error: contest_id/task_idが不正です")
else:
    cmd = f"acc submit -c {contest_id} -t {data['id']} "
    cmd += f"contents/{contest_id}/{task_id}/main.py -- --guess-python-interpreter {interpreter}"
    subprocess.run(cmd.split(" "))
