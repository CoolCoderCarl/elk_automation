#!/bin/bash
##
###
###
###
###########################################
### CREATE EMPTY INDICES FOR REINDEXING ###
###########################################
echo -e '\e[34m\e[1m-------- CREATE EMPTY INDICES FOR REINDEXING --------'
cat $1 | xargs -i curl -k -XPUT "https://localhost:9200/{}-reindex" -u user:password

############################################
### BACKUP ORIGINAL INDICES TO REINDEXED ###
############################################
echo -e '\e[34m\e[1m-------- BACKUP ORIGINAL INDICES TO REINDEXED --------'

for index in `cat $1`; do

curl -k -XPOST "https://localhost:9200/_reindex" -H 'Content-Type: application/json' -d '{
 "source": {
   "index": "'$index'"
 },
 "dest": {
   "index": "'$index'-reindex"
 }
}' -u user:password

done

###############################
### DELETE ORIGINAL INDICES ###
###############################
echo -e '\e[34m\e[1m-------- DELETE ORIGINAL INDICES --------'
cat $1 | xargs -i curl -k -XDELETE "https://localhost:9200/{}" -u user:password

#####################################################
### CREATE NEW EMPTY INDICES FOR ORIGINAL INDICES ###
#####################################################
echo -e '\e[34m\e[1m-------- CREATE NEW EMPTY INDICES FOR ORIGINAL INDICES --------'
cat $1 | xargs -i curl -k -XPUT "https://localhost:9200/{}" -u user:password

##################################################################
### RETURN DATA FROM REINDEXED INDICES TO NEW ORIGINAL INDICES ###
##################################################################
echo -e '\e[34m\e[1m-------- RETURN DATA FROM REINDEXED INDICES TO NEW ORIGINAL INDICES --------'

for index in `cat $1`; do 

curl -k -XPOST "https://localhost:9200/_reindex" -H 'Content-Type: application/json' -d '{
 "source": {
   "index": "'$index'-reindex"
 },
 "dest": {
   "index": "'$index'"
 }
}' -u user:password

done

################################
### DELETE REINDEXED INDICES ###
################################
echo -e '\e[34m\e[1m-------- DELETE REINDEXED INDICES --------'
cat $1 | xargs -i curl -k -XDELETE "https://localhost:9200/{}-reindex" -u user:password

###
###
echo -e '\e[32m\e[1m-------- REINDEXING SUCCESSFUL --------'
### FINISH
###
###

