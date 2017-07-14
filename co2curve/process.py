# -*- coding: utf-8 -*-

import argparse
import csv
from datetime import datetime, timedelta
import json
import math
import matplotlib.pyplot as plt
import os
from pprint import pprint
import sys

import numpy as np
from scipy import interpolate

INPUT_FILE = "data/ice_core_annual.csv"
OUTPUT_FILE = "data/processed.json"

FPS = 30
DURATION = 30
FRAMES = DURATION * FPS

def norm(value, a, b):
    return 1.0 * (value - a) / (b - a)

def parseNumber(string):
    try:
        num = float(string)
        if "." not in string:
            num = int(string)
        return num
    except ValueError:
        return string

def parseRows(arr):
    for i, item in enumerate(arr):
        for key in item:
            arr[i][key] = parseNumber(item[key])
    return arr

def readCSV(filename):
    rows = []
    if os.path.isfile(filename):
        with open(filename, 'rb') as f:
            lines = [line for line in f if not line.startswith("#")]
            reader = csv.DictReader(lines, skipinitialspace=True)
            rows = list(reader)
            rows = parseRows(rows)
    return rows

# read data
data = readCSV(INPUT_FILE)
xs = [d["Year"] for d in data]
ys = [d["Value"] for d in data]

# plot data
plt.plot(xs, ys)
plt.show()
sys.exit(1)

dDomain = [min(xs), max(xs)]
dRange = [min(ys), max(ys)]

# normalize
for i,d in enumerate(data):
    data[i]["x"] = norm(d["Year"], dDomain[0], dDomain[1])
    data[i]["y"] = norm(d["Value"], dRange[0], dRange[1])
tuples = [(d["x"],d["y"]) for d in data]

dataFrames = []
dataLen = len(data)
for frame in range(FRAMES):
    progress = 1.0 * frame / (FRAMES-1)
    end = int(round(dataLen * progress))
    subArr = tuples[0:end]
    dataFrames.append(subArr)

jsonOut = {
    "frames": dataFrames
}

with open(OUTPUT_FILE, 'w') as f:
    json.dump(jsonOut, f)

print "Done"
