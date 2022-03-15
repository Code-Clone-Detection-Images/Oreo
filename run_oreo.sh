#!/usr/bin/env bash
cd "$HOME/oreo/java-parser"

echo "Step 1: setup metric"


# sed -i "s|BufferedReader br;|BufferedReader br;System.out.println(\"X-OUTPUT:\" + filename);|" "$HOME/oreo/java-parser/src/uci/mondego/JavaMetricParser.java"

# sed -i "s|String line = null;|String line = null;System.out.println(\"OUTPUT:\" + filename);|" "$HOME/oreo/java-parser/src/uci/mondego/JavaMetricParser.java"

# debugging bugs
sed -i "s|File dir|System.out.println(\"checking:\" + dirName);File dir|" "$HOME/oreo/java-parser/src/uci/mondego/DirExplorer.java"
sed -i "s|for (File file |if(dir.listFiles() == null) return results; for (File file |" "$HOME/oreo/java-parser/src/uci/mondego/DirExplorer.java"
sed -i "s|results.add(file);|results.add(file); System.out.println(\"Added: \"+ file);|" "$HOME/oreo/java-parser/src/uci/mondego/DirExplorer.java"
sed -i "s|finder(file.getName())|finder(file.getAbsolutePath())|" "$HOME/oreo/java-parser/src/uci/mondego/DirExplorer.java"

sed -i "s|FileWriters.metricsFileWriter|System.out.println(\"writing \" + line);FileWriters.metricsFileWriter|" "$HOME/oreo/java-parser/src/uci/mondego/CustomVisitor.java"
sed -i "s|FileWriters.metricsFileWriter =|System.out.println(\"Writing To: \" + (this.outputDirPath + File.separator + this.metricsFileName)); FileWriters.metricsFileWriter =|" "$HOME/oreo/java-parser/src/uci/mondego/JavaMetricParser.java"


sed -i "s|visitor.visitPreOrder(cu)|System.out.println(\"Visiting done.\"); visitor.visitPreOrder(cu)|" "$HOME/oreo/java-parser/src/uci/mondego/FolderInputProcessor.java"




# cat "$HOME/oreo/java-parser/src/uci/mondego/JavaMetricParser.java"

ant metric

cd "$HOME/oreo/python_scripts"
source ./venv/bin/activate

echo "Step 2: run the metric calculation [$1]"
# sed -i "s|f.is_dir()]|f.is_dir()];print('WUFF',main_dir,list(os.scandir(main_dir)));|" metricCalculationWorkManager.py
# sed -i "s|num_process = 2|num_process = 2; print(sys.argv)|" metricCalculationWorkManager.py
# get feedback on the files
sed -i "s|file.write|print(\">\", subdirs[j]);file.write|" metricCalculationWorkManager.py
# inject unicode
sed -i 's|, "w")|, "w", encoding="utf8")|' metricCalculationWorkManager.py

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

cat metric.out metric.err

echo "[Dummy wait for population]"
sleep 40 # we do wait a little bit to ensure the files are populated

if [ ! -d "$DIR" ]; then
   echo "[Error] no '$DIR' output found. Exiting."
   exit 1
fi

echo "Step 3: Setting Up Oreo"
echo "     3.1: file for clone-detector"
# note: the tutorial says to move to 'oreo/input/dataset' but this is wrong :)
TARGET=../clone-detector/input/dataset
cp "$DIR/mlcc_input.file" "$TARGET/blocks.file"
echo "Blocks file:"
cat "$DIR/mlcc_input.file"

echo "Step 4: Running Oreo"
cd "$HOME/oreo/clone-detector"
python controller.py 1


cd "$HOME/oreo/python_scripts"
# setting self.output_dir; we do this in case it differs
sed -i "s|os.path.join(os.path.dirname(__file__), '../results/candidates/')|'$CANDIDATES_DIR'|" Predictor.py

# setting self.output_dir
sed -i "s|os.path.join(os.path.dirname(__file__), '../results/predictions/')|'$OUTPUT_DIR'|" Predictor.py

# debug
# sed -i "s|self.loadModel()|print(\"loading model\");self.loadModel()|" Predictor.py
# sed -i "s|# load model|print(\"STARTING PREDICTOR\");|" Predictor.py
# sed -i "s|python Predictor.py \$i > out_\$i &|python Predictor.py \$i|" runPredictor.sh

counter=0
# COUNTER_MAX=100
COUNTER_MAX=10

# concurrent <3
FOLDER_SIZE=0
while [ $FOLDER_SIZE -lt 5 ] && [ $counter -lt $COUNTER_MAX ]; do
   echo "[Waiting] Waiting for '$CANDIDATES_DIR' [$counter/$COUNTER_MAX]"
   sleep 1
   FOLDER_SIZE=$(ls -l "$CANDIDATES_DIR" | grep -v ^d | wc -l)
   counter=$((counter + 1))
done

./runPredictor.sh

counter=0
# COUNTER_MAX=100
COUNTER_MAX=10

# concurrent <3
FOLDER_SIZE=0
while [ $FOLDER_SIZE -lt 5 ] && [ $counter -lt $COUNTER_MAX ]; do
   echo "[Waiting] Waiting for '$OUTPUT_DIR' [$counter/$COUNTER_MAX]"
   sleep 1
   FOLDER_SIZE=$(ls -l "$OUTPUT_DIR" | grep -v ^d | wc -l)
   counter=$((counter + 1))
done

# sleep 5


echo "Candidates Dir:"
ls "$CANDIDATES_DIR"

echo "Output Dir:"
for file in $(ls "$OUTPUT_DIR"); do
   echo "$file ======================"
   cat $file
done
