# -*- coding: utf-8 -*-

import argparse
import csv
import json
import math
import os
import sys

# input
parser = argparse.ArgumentParser()
parser.add_argument('-input', dest="INPUT_FILE", default="data/processed_data.json", help="Path to input file")
parser.add_argument('-output', dest="OUTPUT_FILE", default="data/instructions.json", help="Path to output json file")

# init input
args = parser.parse_args()
FPS = 30
DURATION = 30
FRAMES = DURATION * FPS
RANGE = [-1,2]

def norm(value, a, b):
    return 1.0 * (value - a) / (b - a)

def lerp(a, b, amount):
    return (b-a) * amount + a

data = {}
with open(args.INPUT_FILE) as f:
    data = json.load(f)

d1 = data["data"][5]["data"]
d2 = data["data"][3]["data"]

frameData = []
for frame in range(FRAMES):
    progress = 1.0 * frame / (FRAMES-1)
    if progress <= 0.5:
        progress = norm(progress, 0, 0.5)
    else:
        progress = 1.0 - norm(progress, 0.5, 1.0)

    addFrame = []
    for i, d in enumerate(d1):
        v1 = norm(d[1], RANGE[0], RANGE[1])
        v2 = norm(d2[i][1], RANGE[0], RANGE[1])
        value = lerp(v1, v2, progress)
        addFrame.append(value)

    frameData.append(addFrame)


refData = [norm(d[1], RANGE[0], RANGE[1]) for d in data["data"][0]["data"]]
jsonOut = {
    "frames": frameData,
    "ref": refData
}

with open(args.OUTPUT_FILE, 'w') as f:
    json.dump(jsonOut, f)
