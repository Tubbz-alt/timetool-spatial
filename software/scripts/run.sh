#!/bin/bash
python3 HostWrapper.py --dev sim --script --cliargs $@ 2>&1 | tee sim.log
