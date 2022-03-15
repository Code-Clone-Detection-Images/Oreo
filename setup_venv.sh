#!/usr/bin/env bash

echo " - update configuration"
cd "$HOME/oreo/clone-detector"
sed -i "s|CANDIDATES_DIR=.*|CANDIDATES_DIR=$CANDIDATES_DIR|" sourcerer-cc.properties

# we have to replace this similar in the predictor
cd "$HOME/oreo/python_scripts"

mkdir -p "$OUTPUT_DIR"
mkdir -p "$CANDIDATES_DIR"


# 'TRAINED_MODEL' is part of the docker env
# sed -i "s|'../ml_model/oreo_model_fse.h5'|'$HOME/$TRAINED_MODEL'|" Predictor.py


echo " - doing venv"
python3 -m venv ./venv
source ./venv/bin/activate
cd dependencies/
# as it seems h5py (at least 2.7.1 i guess) has problems :)
# NOTETODO: disabled; sed -i "s/h5py==.*/h5py==2.9.0/" dependencies.txt
pip install -r dependencies.txt