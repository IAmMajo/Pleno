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

    CREATE_DATABASE_ANSWER=''
    while [[ ! $CREATE_DATABASE_ANSWER =~ ^[Yy](es)?$|^[Nn]o?$ ]]; do # Eligible answers: y|Y|yes|Yes|n|N|no|No
        echo -e "\n${LIGHT_CYAN}Would you like to create a corresponding database as well? (Y/n)${BOLD_CYAN}"
        read CREATE_DATABASE_ANSWER
    done
    echo -e "${RESET_COLOR}Your service  is going to be named ${ITALIC_CYAN}${SRVNAME}-service${RESET_COLOR}."
    if [[ $CREATE_DATABASE_ANSWER =~ ^[Yy](es)?$ ]]; then # If y|Y|yes|Yes
        echo -e "${RESET_COLOR}Your database is going to be named ${ITALIC_CYAN}${SRVNAME}_db${RESET_COLOR}."
    else
        echo 'No database will be created.'
        echo ''
        echo -e "Please be aware, although no database is going to be created, that the service is going to be configured to try and connect to a database named ${ITALIC_CYAN}${SRVNAME}_db${RESET_COLOR} nevertheless."
        echo -e "A manual correction is necessary. The files ${ITALIC_CYAN}../docker-compose.yml${RESET_COLOR}, ${ITALIC_CYAN}../${SRVNAME}-service/docker-compose.yml${RESET_COLOR} and ${ITALIC_CYAN}../${SRVNAME}-service/Sources/App/configure.swift${RESET_COLOR} are going to be affected by this."
    fi

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

cp -r . "../${SRVNAME}-service" && rm "../${SRVNAME}-service/replicate.sh" # Copy entire template to new service-folder and remove replicate.sh

# Replace every placeholder in newly created files' names
find "../${SRVNAME}-service/" -type f -name '*FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER*' | while read -r file; do
    mv "$file" "`echo $file | sed "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"`"
done

# Replace placeholders in files
find "../${SRVNAME}-service/" -type f -print0 | xargs -0 sed -i '' -e "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"
find "../${SRVNAME}-service/" -type f -print0 | xargs -0 sed -i '' -e "s/SRVNAME_PLACEHOLDER/${SRVNAME}/g"

# Add service  to /backend/docker-compose.yml
#sed -i '' -e "s|^# Volumes$|# Vapor: ${SRVNAME}-service\n#\n  ${SRVNAME}-service:\n    extends:\n      file: ./${SRVNAME}-service/docker-compose.yml\n      service: app\n    container_name: kivop-${SRVNAME}-service\n    depends_on:\n      - config-service\n    environment:\n      <<: *shared_environment\n      DATABASE_NAME: ${SRVNAME}_db\n    labels:\n      traefik.enable: true\n      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.regex: ^/${SRVNAME}-service(:/(.*))?\n      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.replacement: /\$\$1\n      traefik.http.routers.${SRVNAME}-service.rule: PathPrefix(\`/${SRVNAME}-service\`)\n      traefik.http.routers.${SRVNAME}-service.middlewares: ${SRVNAME}-service-replace-path-regex\n\n#\n# Volumes|" ../docker-compose.yml
sed -i '' -e "s|^# Volumes$|# Vapor: ${SRVNAME}-service\n#\n  ${SRVNAME}-service:\n    image: kivop-${SRVNAME}-service:latest\n    build:\n      context: ./..\n      dockerfile: backend/${SRVNAME}-service/Dockerfile\n    container_name: kivop-${SRVNAME}-service\n    depends_on:\n     - config-service\n    environment:\n      <<: *shared_environment\n      DATABASE_NAME: ${SRVNAME}_db\n    labels:\n      traefik.enable: true\n      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.regex: ^/${SRVNAME}-service(:/(.*))?\n      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.replacement: /$$1\n      traefik.http.routers.${SRVNAME}-service.rule: PathPrefix(\`/${SRVNAME}-service\`)\n      traefik.http.routers.${SRVNAME}-service.middlewares: ${SRVNAME}-service-replace-path-regex\n\n#\n# Volumes|" ../docker-compose.yml

# Add database to /backend/init-dbs.sh
if [[ $CREATE_DATABASE_ANSWER =~ ^[Yy](es)?$ ]]; then # If y|Y|yes|Yes
    sed -i '' -e "s/^EOSQL$/\tCREATE DATABASE ${SRVNAME}_db;\n\tGRANT ALL PRIVILEGES ON DATABASE ${SRVNAME}_db TO vapor;\nEOSQL/" ../init-dbs.sh
fi

echo ''
echo -e "${GRAY}>>>${RESET_COLOR} ${BOLD_CYAN}DONE${RESET_COLOR} ${GRAY}<<<${RESET_COLOR}"
