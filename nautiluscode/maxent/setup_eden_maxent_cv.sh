#!/bin/sh

# This should be called from maxent.sh (which is produced by do_run.sh)

# Sets up eden run in eden_maxent/.
# MaxEnt output will go into maxent_results/

samples_dir=$RUN_DIR/training
output_dir=$RUN_DIR/maxent_results

mkdir eden_maxent
mkdir maxent_results

# Create commands list for running MaxEnt via eden
i=0
for f in $(ls by_species); do
   species=$(echo $f | cut -d'.' -f1)
   fold=0
   while test $fold -lt $CV_NUM_FOLDS; do

      flags="togglelayertype=cat \
perspeciesresults=true \
askoverwrite=false \
visible=false \
skipifexists \
plots=false \
pictures=false \
writebackgroundpredictions=false \
removeduplicates=false \
testsamplesfile=$RUN_DIR/test/${species}_${fold}.csv \
autorun"

	   maxent_cmd="java -Xms512m -Xmx512m -XX:-UsePerfData -jar $MAXENT_JAR environmentallayers=$ENV_DIR samplesfile=$samples_dir/${species}_$fold.csv outputdirectory=$output_dir/$species/fold$fold $flags"
      #echo "mkdir -p $output_dir/$species/fold$fold && $maxent_cmd && cd $output_dir/$species/fold$fold && $TOOL_DIR/asc2bov $species.asc $species && rm $species.asc" >> eden_maxent/commands
      echo "mkdir -p $output_dir/$species/fold$fold && $maxent_cmd && cd $output_dir/$species/fold$fold && $TOOL_DIR/asc2bov $species.asc $species" >> eden_maxent/commands
      #echo "mkdir -p $output_dir/$species/fold$fold && $maxent_cmd" >> eden_maxent/commands

      fold=$(($fold + 1))
      i=$(( $i + 1 ))
   done
done

# calculate appropriate ncpus; cap at 256
if test $i -gt 256; then
   ncpus=256
elif test $i -gt 32; then
   ncpus=$(( $i+ (8-$i)%8+8 ))
else
   ncpus=32
fi

# Create PBS header file for eden run
echo "#!/bin/sh
#PBS -l ncpus=$ncpus,walltime=6:00:00
#PBS -j oe
#PBS -N eden_maxent
#PBS -A $ACCOUNT
" > eden_maxent/header.pbs

# Create PBS footer file for eden run
echo "module load java" > eden_maxent/footer.pbs
