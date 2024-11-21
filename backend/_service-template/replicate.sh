#!/bin/bash

# text formatting
GRAY="\033[90m"
ITALIC_CYAN="\033[3;96m"
BOLD_CYAN="\033[1;96m"
LIGHT_CYAN="\033[0;38;5;123m"
YELLOW="\033[0;38;5;221m"
BOLD_YELLOW="\033[1;38;5;221m"
ITALIC_YELLOW="\033[3;38;5;221m"
RESET_COLOR="\033[0m"

function read_user_inputs {
    SRVNAME=''
    while [[ $SRVNAME == '' ]]; do
        echo -e "\n${LIGHT_CYAN}Please enter the desired name of the service.${BOLD_CYAN}"
        read SRVNAME
    done
    if [[ $SRVNAME =~ " " ]]; then # Check if SRVNAME contains any spaces
        echo -e "${BOLD_YELLOW}Invalid input!${RESET_COLOR} ${YELLOW}Service names must not contain any spaces.${RESET_COLOR}"
        read_user_inputs
        return
    fi

    SRVNAME="$(echo "$SRVNAME" | awk '{$1=tolower($1)}1')" # Transform to all lowercase
    FIRST_LETTER_CAPITAL_SRVNAME="$(echo "$SRVNAME" | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')" # Transform to first letter uppercase, remaining letters lowercase

    if [[ -d "../$SRVNAME-service" ]]; then # Check if service / folder already exists
        echo -e "${BOLD_YELLOW}Invalid input!${RESET_COLOR} ${YELLOW}There is already a service with that name (i.e. a folder named ${ITALIC_YELLOW}${SRVNAME}-service${YELLOW}).${RESET_COLOR}"
        read_user_inputs
        return
    fi

    echo -e "${RESET_COLOR}Your service  is going to be named ${ITALIC_CYAN}${SRVNAME}-service${RESET_COLOR}."

    PROCEED_ANSWER=''
    while [[ ! $PROCEED_ANSWER =~ ^[Yy](es)?$|^[Nn]o?$ ]]; do # eligible answers: y|Y|yes|Yes|n|N|no|No
        echo -e "\n${LIGHT_CYAN}Is everything correct and would you like to proceed? (Y/n)${BOLD_CYAN}"
        read PROCEED_ANSWER
    done
    if [[ $PROCEED_ANSWER =~ ^[Yy](es)?$ ]]; then # If y|Y|yes|Yes
        echo -e "${RESET_COLOR}Proceeding..."
    else
        read_user_inputs
        return
    fi

}

cd $(echo $BASH_SOURCE | sed "s#$(basename $BASH_SOURCE)##")
echo ''
echo -e "${GRAY}*---------------------------------------------------------------------------*${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}                                                                           ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     ${BOLD_CYAN}Welcome!${RESET_COLOR} This script is going to replicate the service template,      ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     place the desired service name where necessary and expand the         ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     files ${ITALIC_CYAN}../init-dbs.sh${RESET_COLOR} as well as ${ITALIC_CYAN}../docker-compose.yml${RESET_COLOR} in order to     ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     integrate the newly created service into the overall structure.       ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}                                                                           ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}*---------------------------------------------------------------------------*${RESET_COLOR}"
echo ''

read_user_inputs

COMPOSE_TEMPLATE="# Vapor: ${SRVNAME}-service
#
  ${SRVNAME}-service:
    image: kivop-${SRVNAME}-service:latest
    build:
      context: ./..
      dockerfile: backend/${SRVNAME}-service/Dockerfile
    container_name: kivop-${SRVNAME}-service
    depends_on:
     - config-service
    environment:
      <<: *shared_environment
    labels:
      traefik.enable: true
      traefik.http.routers.${SRVNAME}-service.rule: PathPrefix(\`/${SRVNAME}\`)

  ${SRVNAME}-service-migration:
    profiles:
      - migration
    image: kivop-${SRVNAME}-service:latest
    build:
      context: ./..
      dockerfile: backend/${SRVNAME}-service/Dockerfile
    container_name: kivop-${SRVNAME}-service-migration
    environment:
      <<: *shared_environment
    depends_on:
      - postgres
    command: [\"migrate\", \"--yes\"]

  ${SRVNAME}-service-revert:
    profiles:
      - revert
    image: kivop-${SRVNAME}-service:latest
    build:
      context: ./..
      dockerfile: backend/${SRVNAME}-service/Dockerfile
    container_name: kivop-${SRVNAME}-service-revert
    environment:
      <<: *shared_environment
    depends_on:
      - postgres
    command: [\"migrate\", \"--revert\", \"--yes\"]

#
# Volumes"

ESCAPED_COMPOSE_TEMPLATE=$(echo "$COMPOSE_TEMPLATE" | awk '{if (NR > 1) printf "\\n"; printf "%s", $0}')

cp -r . "../${SRVNAME}-service" && rm "../${SRVNAME}-service/replicate.sh" # Copy entire template to new service-folder and remove replicate.sh

# Replace every placeholder in newly created files' names
find "../${SRVNAME}-service/" -type f -name '*FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER*' | while read -r file; do
    mv "$file" "`echo $file | sed "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"`"
done

# Replace placeholders in files
find "../${SRVNAME}-service/" -type f -print0 | xargs -0 sed -i '' -e "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"
find "../${SRVNAME}-service/" -type f -print0 | xargs -0 sed -i '' -e "s/SRVNAME_PLACEHOLDER/${SRVNAME}/g"

# Add service  to /backend/docker-compose.yml
sed -i '' -e "s|^# Volumes$|${ESCAPED_COMPOSE_TEMPLATE}|" ../docker-compose.yml

echo ''
echo -e "${GRAY}>>>${RESET_COLOR} ${BOLD_CYAN}DONE${RESET_COLOR} ${GRAY}<<<${RESET_COLOR}"
