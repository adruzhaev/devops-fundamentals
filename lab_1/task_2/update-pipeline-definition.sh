#!/usr/bin/env bash
CURRENT_DIRECTORY=`dirname "$(readlink -f "$BASH_SOURCE")"`
source $CURRENT_DIRECTORY/helpers

BRANCH_NAME="main"
OWNER_NAME=
REPOSITORY=
NEW_POLL_FOR_SOURCE_CHANGES=
BUILD_CONFIG=
INPUT="$1"
OUTPUT=pipeline-`date +%d-%m-%Y`.json

checkJQ
validateFile $1

# Default behaviour without arguments
if [ ! $2 ]; then
    jq '.pipeline.version = .pipeline.version + 1' $INPUT |
    jq 'del(.metadata)' > $CURRENT_DIRECTORY/$OUTPUT
    exit 0
fi

while [[ ! -z $2 ]]; do
    case $2 in
        --help) getInfo; exit 0 ;;
        --branch)
            shift 
            BRANCH_NAME=$2 
            ;;
        --owner) 
            shift
            OWNER_NAME=$2
            ;;
        --repo) 
            shift 
            REPOSITORY=$2
            ;;
        --poll-for-source-changes) 
            shift 
            NEW_POLL_FOR_SOURCE_CHANGES=$2
            ;;
        --configuration) 
            shift
            BUILD_CONFIG=$2
            ;;
        *) 
            echo "Unknown argument is passed."
            exit 1 
            ;;
    esac
    shift
done

jq --arg branch $BRANCH_NAME --arg owner $OWNER_NAME --arg repo $REPOSITORY --argjson poll $NEW_POLL_FOR_SOURCE_CHANGES --arg config $BUILD_CONFIG \
'
    walk(
        if type == "object" and has("Branch") then .Branch = $branch else . end |
        if type == "object" and has("Owner") then .Owner = $owner else . end |
        if type == "object" and has("Repo") then .Repo = $repo else . end | 
        if type == "object" and has("PollForSourceChanges") then .PollForSourceChanges = $poll else . end |
        if type == "object" and has("EnvironmentVariables") then (.EnvironmentVariables |=
            (fromjson | map(if .name == "BUILD_CONFIGURATION" then .value = $config else . end) | tojson)) else .
        end
    )
' $INPUT |
jq '.pipeline.version = .pipeline.version + 1' |
jq 'del(.metadata)' > $CURRENT_DIRECTORY/$OUTPUT
