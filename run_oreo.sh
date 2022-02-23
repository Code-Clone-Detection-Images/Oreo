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
echo "     3.2: file for clone-detector"
# note: the tutorial says to move to 'oreo/input/dataset' but this is wrong :)
TARGET=../clone-detector/input/dataset
cp "$DIR/mlcc_input.file" "$TARGET/blocks.file"
cd "$TARGET"

echo "     3.2: update configuration"
cd ../../ # stay in the clone-detector

CANDIDATES_DIR=../results/candidates
sed -i "s|CANDIDATES_DIR=.*|CANDIDATES_DIR=$CANDIDATES_DIR|" sourcerer-cc.properties

# we have to replace this similar in the predictor
cd ../python_scripts

# setting self.output_dir; we do this in case it differs
sed -i "s|'../results/candidates/'|'$CANDIDATES_DIR'|" Predictor.py

# setting self.output_dir
OUTPUT_DIR=../results/predictions/
sed -i "s|'../results/predictions/'|'$OUTPUT_DIR'|" Predictor.py

# 'TRAINED_MODEL' is part of the docker env
sed -i "s|'../ml_model/oreo_model_fse.h5'|'$HOME/$TRAINED_MODEL'|" Predictor.py

# TODO: find out which of this to move to docker (most of it should be there)
echo "     3.3: doing venv"
python3 -m venv ./venv
source ./venv/bin/activate
cd dependencies/
# as it seems h5py (at least 2.7.1 i guess) has problems :)
sed -i "s/h5py==.*/h5py==2.9.0/" dependencies.txt
pip install -r dependencies.txt

echo "Step 3: Running Oreo"
cd ../../clone-detector
python controller.py 1
cd ../python_scripts
./runPredictor.sh