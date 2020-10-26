#!/usr/bin/env python3
"""Download and setup problems from Competitive Companion
Usage:
  download_prob.py prob [<name>]
  download_prob.py contest [<name>... | -n <number>]
  download_prob.py samples
  download_prob.py echo
Options:
  -h --help     Show this screen.
Contest flags:
  -n COUNT, --number COUNT   Number of problems.
"""

from docopt import docopt

import sys
import http.server
import json
from pathlib import Path
import subprocess
import re

# Returns unmarshalled or None
def listen_once(*, timeout=None):
    json_data = None

    class CompetitiveCompanionHandler(http.server.BaseHTTPRequestHandler):
        def do_POST(self):
            nonlocal json_data
            json_data = json.load(self.rfile)

    with http.server.HTTPServer(('127.0.0.1', 10046), CompetitiveCompanionHandler) as server:
        server.timeout = timeout
        server.handle_request()

    if json_data is not None:
        print(f"Got data {json.dumps(json_data)}")
    else:
        print("Got no data")
    return json_data

def listen_many(*, num_items=None, timeout=None):
    if num_items is not None:
        return [listen_once(timeout=None) for _ in range(num_items)]
    res = [listen_once(timeout=None)]
    while True:
        cnd = listen_once(timeout=timeout)
        if cnd is None:
            break
        res.append(cnd)
    return res

NAME_PATTERN = re.compile(r'^[A-Z][0-9]*\b')

def get_prob_name(data):
    if 'USACO' in data['group']:
        names = [data['input']['fileName'].rstrip('.in'), data['output']['fileName'].rstrip('.out')]
        if len(set(names)) == 1:
            return names[0]

    patternMatch = NAME_PATTERN.search(data['name'])
    if patternMatch is not None:
        return patternMatch.group(0)

    return input("What name to give? ")

def save_samples(data, probDir):
    with open(probDir / 'problem.json', 'w') as f:
        json.dump(data, f)

    for i, t in enumerate(data['tests'], start=1):
        with open(probDir / f'sample{i}.in', 'w') as f:
            f.write(t['input'])
        with open(probDir / f'sample{i}.out', 'w') as f:
            f.write(t['output'])

def make_prob(data, name):
    if name is None:
        name = get_prob_name(data)

    print(f"Creating problem {name}...")

    MAKE_PROB = Path(sys.path[0]) / 'make_prob.sh'
    try:
        subprocess.check_call([MAKE_PROB, name], stdout=sys.stdout, stderr=sys.stderr)
    except subprocess.CalledProcessError as e:
        print(f"Got error {e}")
        return

    probDir = Path('.')/name

    print("Saving samples...")
    save_samples(data, probDir)

    print()

def main():
    arguments = docopt(__doc__)

    if arguments['echo']:
        while True:
            print(listen_once())
    elif arguments['prob']:
        data = listen_once()
        names = arguments['<name>']
        name = names[0] if names else None
        make_prob(data, name)
    elif arguments['contest']:
        if names := arguments['<name>']:
            datas = listen_many(num_items=len(names))
            for data, name in zip(datas, names):
                make_prob(data, name)
        elif cnt := arguments['--number']:
            cnt = int(cnt[0])
            datas = listen_many(num_items=cnt)
            for data in datas:
                make_prob(data, None)
        else:
            datas = listen_many(timeout=5)
            for data in datas:
                make_prob(data, None)
    elif arguments['samples']:
        data = listen_once()
        save_samples(data, Path('.'))

if __name__ == '__main__':
    main()
