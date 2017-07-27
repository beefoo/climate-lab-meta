# -*- coding: utf-8 -*-

import argparse
import csv
import json
import math
import os
import random
import sys

# input
parser = argparse.ArgumentParser()
# input source: https://www.ncdc.noaa.gov/monitoring-references/faq/anomalies.php
parser.add_argument('-input', dest="INPUT_FILE", default="data/1880-2017.csv", help="Path to input file")
parser.add_argument('-output', dest="OUTPUT_FILE", default="data/instructions.json", help="Path to output json file")
parser.add_argument('-audio', dest="AUDIO_FILE", default="data/instructions.dat", help="Path to output audio file")

# init input
args = parser.parse_args()
FPS = 30
DURATION = 60
FRAMES = DURATION * FPS
FADE_DURATION = [1.0, 2.0]

# 20the century average temperature in °C
# https://www.ncdc.noaa.gov/sotc/global/201613
BASELINE = 13.9

def lerp(a, b, amount):
    return (b-a) * amount + a

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
            "year": int(_year),
            "value": float(_value)
        }
        data.append(value)

values = [d["value"] for d in data]
minValue = min(values)
maxValue = max(values)
count = len(values)
yearDuration = (1.0 * DURATION - FADE_DURATION[1]) / count

for i,d in enumerate(data):
    data[i]["start"] = int(i * yearDuration * 1000)
    dur = lerp(FADE_DURATION[0], FADE_DURATION[1], random.random())
    data[i]["end"] = data[i]["start"] + int(dur * 1000)
    data[i]["norm"] = norm(d["value"], minValue, maxValue)
    data[i]["label"] = str(round((d["value"] + BASELINE) * 9.0 / 5.0 + 32.0, 1)) + "°F"

jsonOut = {
    "data": data,
    "duration": data[-1]["end"],
    "count": count
}

with open(args.OUTPUT_FILE, 'w') as f:
    json.dump(jsonOut, f)
