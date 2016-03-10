#! /bin/sh

# This checks looks for nvm and loads it, otherwise logs error
if [ -s "${NVM_DIR}/nvm.sh" ]; then
    . "${NVM_DIR}/nvm.sh"
else
    ErrorLog "Couldn't find nvm at ${NVM_DIR}"
fi
