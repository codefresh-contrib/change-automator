# TODO (workflows) - Trigger CI build:
#   1. clone random repo from list (/dev/urandom) select line=(rnd num % (len of list - 1)) + 1  --> using number $ head -$line $file | tail -1
#   2. replace tmpl files with random color from list (/dev/urandom)
#   3. replace commits.tmpl and select random commit message (/dev/urandom)
#   4. commit changes

# TODO (workflows) - Trigger CD build:
#   1. workflow to wait for multiple webhooks to be true to proceed with trio app deployment pipeline

# Execute relative to the script path
cd "$(dirname "$0")"

REPLACEMENTS_FILE=./res/colors.list
COMMITS_FILE=./res/commits.tmpl
REPOS_FILE=./res/repos.list

function getLine() {
    local input_file=$1
    local random=$(od -vAn -N2 -tu2 < /dev/urandom |tr -d ' ');
    # wc counts newlines, not lines. Each file should has a trialing new lines so modulo arithmetic will work correctly
    local number_of_lines=$(wc -l < ${input_file} | tr -d ' ')
    # Head read line starting at 1 not 0, so we add 1 to the result
    local selected_line=$(( ${random} % ${number_of_lines} + 1 ))
    local result=$(head -n${selected_line} ${input_file} | tail -n1)
    printf "${result}"
}

function splitRepoInfo() {
    local repo_arr=(${1})
    # Set globals
    REPO=${repo_arr[0]}
    BRANCH=${repo_arr[1]}
    TEMPLATE_PATH=${repo_arr[2]}
    OUTPUT_PATH=${repo_arr[3]}
    SEARCH_STRING=${repo_arr[4]}
}

# Text to replace search string with if found in files
REPLACEMENT_TEXT=$(getLine ${REPLACEMENTS_FILE})

# Repo, branch, file and search string in file to clone and replace
# Quotes preserve spaces we are passing
REPO_INFO=$(getLine ${REPOS_FILE})
splitRepoInfo "${REPO_INFO}"

# Commit message to set for committing files changs
COMMIT=$(getLine ${COMMITS_FILE} | sed "s/${SEARCH_STRING}/${REPLACEMENT_TEXT}/g")


# Could also output JSON and parse it with sprig templates in workflows
echo "Outputting info:"
echo "Repo info: ${REPO_INFO}"
echo "Commit: ${COMMIT}"
echo "Replacement text: ${REPLACEMENT_TEXT}"
# Output values to files to be read as outputs
printf "${REPO}" > target_repo.out
printf "${BRANCH}" > target_branch.out
printf "${TEMPLATE_PATH}" > target_template_filepath.out
printf "${OUTPUT_PATH}" > target_putput_filepath.out
printf "${SEARCH_STRING}" > target_search_string.out
printf "${REPLACEMENT_TEXT}" > target_replacement.out
printf "${COMMIT}" > target_commit_message.out
