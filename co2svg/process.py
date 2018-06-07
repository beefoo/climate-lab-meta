# -*- coding: utf-8 -*-

import argparse
import csv
import json
import math
import os
from pprint import pprint
import svgwrite
import sys

import numpy as np
from scipy import interpolate

INPUT_FILE = "data/ice_core_annual.csv"
OUTPUT_FILE = "data/co2.svg"
WIDTH = 2000
HEIGHT = int(round(WIDTH / 5.3333333))
STROKE_WIDTH = 2
PAD = STROKE_WIDTH

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

def angleBetweenPoints(p1, p2):
    (x1, y1) = p1
    (x2, y2) = p2
    deltaX = x2 - x1
    deltaY = y2 - y1
    return math.atan2(deltaY, deltaX) * 180.0 / math.pi

def distance(p1, p2):
    (x1, y1) = p1
    (x2, y2) = p2
    return math.hypot(x2 - x1, y2 - y1)

def flattenTuples(tuples):
    return tuple([i for sub in tuples for i in sub])

def translatePoint(p, angle, distance):
    (x, y) = p
    r = math.radians(angle)
    x2 = x + distance * math.cos(r)
    y2 = y + distance * math.sin(r)
    return (x2, y2)

def pointsToCurve(points, curviness=0.3):
    commands = []
    for i, point in enumerate(points):
        # first point: move to point
        if i <= 0:
            commands.append("M%s,%s" % point)
        else:
            # get previous and next point
            p0 = points[i-1]
            d = distance(p0, point)
            cpd = d * curviness
            p2 = None
            if i < len(points)-1:
                p2 = points[i+1]
            # draw a straight line from previous to next
            if p2:
                a2 = angleBetweenPoints(p2, p0)
                cp2 = translatePoint(point, a2, cpd)
                # second point: curve to
                if i <= 1:
                    a0 = angleBetweenPoints(p0, point)
                    cp0 = translatePoint(p0, a0, cpd)
                    commands.append("C%s,%s %s,%s %s,%s" % flattenTuples([cp0, cp2, point]))
                # otherwise, shorthand curve to
                else:
                    commands.append("S%s,%s %s,%s" % flattenTuples([cp2, point]))
            # last point
            else:
                a2 = angleBetweenPoints(point, p0)
                cp2 = translatePoint(point, a2, cpd)
                commands.append("S%s,%s %s,%s" % flattenTuples([cp2, point]))
    return commands

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

# # plot data
# import matplotlib.pyplot as plt
# plt.plot(xs, ys)
# plt.show()
# sys.exit(1)

dDomain = [min(xs), max(xs)]
dRange = [min(ys), max(ys)]

# normalize
for i,d in enumerate(data):
    data[i]["x"] = norm(d["Year"], dDomain[0], dDomain[1]) * WIDTH + PAD
    data[i]["y"] = norm(d["Value"], dRange[1], dRange[0]) * HEIGHT + PAD
tuples = [(d["x"],d["y"]) for d in data]

# set up svg
dwg = svgwrite.Drawing(OUTPUT_FILE, size=(WIDTH+PAD*2, HEIGHT+PAD*2), profile='full')
pathCurve = pointsToCurve(tuples)
dwg.add(dwg.path(d=pathCurve, stroke_width=STROKE_WIDTH, stroke="#ffffff", fill="none"))
dwg.save()
