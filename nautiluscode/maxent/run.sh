#!/bin/sh

echo $(date) > start_time.txt
echo $(date +%s) > start_secs.txt
. /usr/share/modules/init/bash
module load eden
./do_run.sh ../maxent/speciesGreaterThanEqual30.csv 10 && \
./preprocess.sh && \
./maxent.sh && \
./postprocess.sh
#./postprocess.sh && \
#./visit.sh

#eval "qsub visit.pbs -W depend=afterok:$(cat current_eden_job.txt | grep nics.utk.edu) > current_eden_job.txt" && \
