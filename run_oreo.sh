#!/usr/bin/env bash
cd "$HOME/oreo-FSE_Artifact/java-parser"

echo "Step 1: setup metric"
ant metric

cd "$HOME/oreo-FSE_Artifact/python_scripts"
echo "Step 2: run the metric calculation [$1]"
# d maps to directory

python3 metricCalculationWorkManager.py 1 d "$1"

counter=0
COUNTER_MAX=20
DIR=./1_metric_output

# concurrent <3
while [ ! -d "$DIR" ] && [ $counter -lt $COUNTER_MAX ]; do
   echo "[Waiting] Waiting for '$DIR' [$counter/$COUNTER_MAX]"
   sleep 1
   counter=$((counter + 1))
done

if [ ! -d "$DIR" ]; then
   echo "[Error] no '$DIR' output found. Exiting."
   exit 1
fi

echo "Step 3: Setting Up Oreo"
echo "     3.1: file for clone-detector"
# note: the tutorial says to move to 'oreo/input/dataset' but this is wrong :)
TARGET=../clone-detector/input/dataset
cp "$DIR/mlcc_input.file" "$TARGET/blocks.file"
cd "$TARGET"

echo "Step 4: Running Oreo"
cd "$HOME/oreo-FSE_Artifact/clone-detector"
python controller.py 1
cd "$HOME/oreo-FSE_Artifact/python_scripts"
ls "/home/oreo-user/oreo-FSE_Artifact/python_scripts/output"
./runPredictor.sh

cat "/home/oreo-user/oreo-FSE_Artifact/python_scripts/output/1.txt"
# TODO: save the output file!