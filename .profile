# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

export EDITOR=/usr/bin/vim

TMP_DIR=$HOME/tmp

BIN_BYOBU_BACKEND=/usr/bin/byobu-tmux
BIN_ZSH=/usr/bin/zsh


# Export Spark variables if we find spark
SPARK_HOME=/opt/spark-1.6.0-bin-hadoop2.6    
if ! [ -e $SPARK_HOME ]; then SPARK_HOME=/cs/work/scratch/spark-1.6.0-bin-hadoop2.6; fi
if ! [ -e $SPARK_HOME ]; then SPARK_HOME=""; fi

if [ -n "$SPARK_HOME" ]; then
    export SPARK_HOME
    export PATH=$PATH:$SPARK_HOME/bin   
    export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH   
    export PYTHONPATH=$SPARK_HOME/python/lib/py4j-0.9-src.zip:$PYTHONPATH
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Make sure we have a tempdirectory that we own
if [ ! -e $TMP_DIR ] || [ ! -O $TMP_DIR ]; then
    if [ -L $TMP_DIR ]; then
        rm $TMP_DIR
    fi
    ln -s $(mktemp -d) $TMP_DIR
    setfacl -d -m g::- $TMP_DIR/.
    setfacl -d -m o::- $TMP_DIR/.
    mkdir $TMP_DIR/vimbackup
fi

############################################################################################
# Any required stuff should be but above this, the next steps could result in launchiing
# other processes, skipping files, or sourcing all sorts of stuff.

if [ -n "$SSH_TTY" ]
then
    # Do some aditional setup for SSH sessions (since we probably cannot set this
    # stuff with system settings).

    if ! [ -n "$ZSH" ] && [ -e $BIN_ZSH ] && [ -x $BIN_ZSH ]
    then
        # Switch to ZSH if we're not already there...
        exec $BIN_ZSH
    elif [ -e $BIN_BYOBU_BACKEND ] && [ -x $BIN_BYOBU_BACKEND ]
    then
        # Tryo to launch byobu if we've got the correct backend
        _byobu_sourced=1 . /usr/bin/byobu-launch
    fi
fi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

