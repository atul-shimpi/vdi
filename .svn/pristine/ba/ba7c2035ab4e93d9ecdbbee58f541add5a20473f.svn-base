#!/bin/bash
# Connects slave VM to NB Jenkins, using slave.jar downloaded from this Jenkins host

script_dir="$(dirname "$0")"
parent_dir="$(dirname "$script_dir")"
jenkins_jars_dir="$parent_dir/jenkins_slave_jars"
if [[ ! -d "$jenkins_jars_dir" ]]; then
    echo "Cannot locate directory with Jenkins JAR files required to establish connection: '$jenkins_jars_dir'."
    echo "This may happen because your vdiclient is old and needs to be updated." 
    echo "Please run 'svn update' on vdiclient root directory and try re-running the script."
    exit 1
fi
    
nb_jenkins_slave_jar="$jenkins_jars_dir/nb_slave.jar"
java_classpath="$jenkins_jars_dir/commons-codec-1.5.jar"

java -jar "$nb_jenkins_slave_jar" -cp "$java_classpath" $*

