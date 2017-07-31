=== RMDS Synchronization Tools ===

=   INFO

o   First, nice directory structure is created from jpg files, see tidyup.sh for description
o   Then complete sync of directory is done, this is repeated every 24 hours
o   The script then runs infinite loop watching for new files and syncing them to server every hour

=   USAGE

o   You must have working ssh public key based authentication to server
o   It is recommended to run the script in detachable screen
o   Run ./sync.sh /path/to/folder where path is the directory to which jpg's from Spectrum Lab are saved

