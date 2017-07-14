# -*- coding: utf-8 -*-

import argparse
import csv
import json
import math
import os
import sys

# input
parser = argparse.ArgumentParser()
# input source: https://www.ncdc.noaa.gov/monitoring-references/faq/anomalies.php
parser.add_argument('-input', dest="INPUT_FILE", default="data/1880-2017.csv", help="Path to input file")
parser.add_argument('-output', dest="OUTPUT_FILE", default="data/instructions.json", help="Path to output json file")

# init input
args = parser.parse_args()
FPS = 30
DURATION = 30
FRAMES = DURATION * FPS

def norm(value, a, b):
    return 1.0 * (value - a) / (b - a)

data = []
# read csv
with open(args.INPUT_FILE, 'rb') as f:
    r = csv.reader(f, delimiter=',')
    for skip in range(5):
        next(r, None)
    # for each row
    for _year,_value in r:
        value = {
            "year": int(_year[:4]),
            "month": int(_year[4:]),
            "value": float(_value)
        }
        data.append(value)

DATA_POINTS_START = 24
DATA_POINTS_END = len(data)
POINTS_PER_FRAME = int(math.ceil(1.0 * (DATA_POINTS_END - DATA_POINTS_START) / FRAMES))

values = [d["value"] for d in data]
minValue = min(values)
maxValue = max(values)

dataFrames = []
count = DATA_POINTS_START
for frame in range(FRAMES):
    subArr = data[0:count]
    dLen = len(subArr)



    frameData = []
    for i,d in enumerate(subArr):
        x = 1.0 * i / (dLen-1)
        y = norm(d["value"], minValue, maxValue)
        frameData.append((x,y))

    dataFrames.append(frameData)
    count += POINTS_PER_FRAME
    count = min(count, DATA_POINTS_END)

jsonOut = {
    "frames": dataFrames
}

with open(args.OUTPUT_FILE, 'w') as f:
    json.dump(jsonOut, f)
