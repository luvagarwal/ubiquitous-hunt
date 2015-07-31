#!/usr/bin/env python
import os
data = []
with open('data.txt', 'r') as f:
    while True:
        tmp = f.readline()
        if tmp == '':
            break
        if "file" in tmp.lower() or "dir" in tmp.lower():
            data.append(tmp)

with open('kamkadata', 'w') as f:
    for i in data:
        f.write(i)
        f.write('\n')

