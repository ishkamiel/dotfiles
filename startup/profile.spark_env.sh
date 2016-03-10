#! /bin/sh
#
# profile.spark_env.sh
# Copyright (C) 2016 ishkamiel <ishkamiel@thigreal>
#
# Distributed under terms of the MIT license.
#


# Spark installation setup
SPARK_HOME=/opt/spark-1.6.0-bin-hadoop2.6
if ! [ -e $SPARK_HOME ]; then SPARK_HOME=/cs/work/scratch/spark-1.6.0-bin-hadoop2.6; fi
if ! [ -e $SPARK_HOME ]; then SPARK_HOME=""; fi

if [ -n "$SPARK_HOME" ]; then
    export SPARK_HOME
    AddToPath "$SPARK_HOME/bin"
    export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
    export PYTHONPATH=$SPARK_HOME/python/lib/py4j-0.9-src.zip:$PYTHONPATH
fi

