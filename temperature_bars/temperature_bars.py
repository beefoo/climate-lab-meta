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
RANGE = [54, 59]
COLDEST_COUNT = 10
HOTTEST_COUNT = 17

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
startYear = data[0]["year"]

runningMax = -999
for i,d in enumerate(data):
    data[i]["start"] = int(i * yearDuration * 1000)
    # dur = lerp(FADE_DURATION[0], FADE_DURATION[1], random.random())
    dur = FADE_DURATION[0]
    data[i]["end"] = data[i]["start"] + int(dur * 1000)
    data[i]["norm"] = norm(d["value"], minValue, maxValue)
    v = (d["value"] + BASELINE) * 9.0 / 5.0 + 32.0
    data[i]["label"] = str(round(v, 1)) + "°F"

    data[i]["height"] = norm(v, RANGE[0], RANGE[1])
    data[i]["record"] = 0
    if d["year"] > 1930 and d["value"] > runningMax:
        data[i]["record"] = 1
    if d["value"] > runningMax:
        runningMax = d["value"]

# add the 10 coldest
dataByValue = sorted(data, key=lambda k: k["value"])
for i,d in enumerate(dataByValue):
    j = d["year"] - startYear
    if i < COLDEST_COUNT:
        data[j]["coldest"] = 1
    else:
        data[j]["coldest"] = 0

# add the 17 hottest
dataByValue = sorted(data, key=lambda k: k["value"], reverse=True)
for i,d in enumerate(dataByValue):
    j = d["year"] - startYear
    if i < HOTTEST_COUNT:
        data[j]["hottest"] = 1
    else:
        data[j]["hottest"] = 0

jsonOut = {
    "data": data,
    "duration": data[-1]["end"],
    "count": count,
    "range": RANGE
}

with open(args.OUTPUT_FILE, 'w') as f:
    json.dump(jsonOut, f)
