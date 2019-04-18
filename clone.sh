#!/bin/bash
# The script clones all repositories of a GitHub user
# Author: Paul Romlow, based on
# Jens-Andre Koch's work here: http://www.madhur.co.in/blog/2017/02/12/git-bulk-clone.html 

# the github organization to fetch all repositories for
GITHUB_USER=$1

# the git clone cmd used for cloning each repository
# the parameter recursive is used to clone submodules, too.
GIT_CLONE_CMD="git clone "

# the number of repos to get/clone per page of results (v3 API max = 100)
PPAGE=100

# the base URL with repo info for the user
REPOS_URL="https://api.github.com/users/${GITHUB_USER}/repos?per_page=${PPAGE}"

# find max page number, given PPAGE/page
PAGES=`curl -I --silent "${REPOS_URL}" | awk '$5 ~ /last/ {print $4}' | sed -E 's/^.*page=([[:digit:]]*)>;/\1/'`

# for each page
for PAGE in `seq ${PAGES}`; do

    # use the correct page
    REPOS_URL_P="${REPOS_URL}&page=${PAGE}"

    # fetch repository list via github api
    # grep fetches the json object key clone_url, which contains the url for the repository to clone
    REPOLIST=`curl --silent ${REPOS_URL_P} | grep "\"clone_url\"" | awk -F': "' '{print $2}' | sed -e 's/",//g'`

    # loop over all repository urls and execute clone
    for REPO in $REPOLIST; do
        ${GIT_CLONE_CMD}${REPO}
    done
done
