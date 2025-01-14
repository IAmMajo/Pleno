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

    SRVNAME="$(echo "$SRVNAME" | awk '{$1=tolower($1)}1')" # Transform to all letters lowercase
    FIRST_LETTER_CAPITAL_SRVNAME="$(echo "$SRVNAME" | awk '{$1=toupper(substr($1,0,1))substr($1,2)}1')" # Transform to first letter uppercase, remaining letters lowercase
    ALL_LETTERS_CAPITAL_SRVNAME="$(echo "$SRVNAME" | awk '{$1=toupper($1)}1')" # Transform to all letters uppercase

    if [[ -d "../$SRVNAME-service" ]]; then # Check if service / folder already exists
        echo -e "${BOLD_YELLOW}Invalid input!${RESET_COLOR} ${YELLOW}There is already a service with that name (i.e. a folder named ${ITALIC_YELLOW}${SRVNAME}-service${YELLOW}).${RESET_COLOR}"
        read_user_inputs
        return
    fi

    SRV_DESCRIPTION=''
    while [[ $SRV_DESCRIPTION == '' || $SRV_DESCRIPTION =~ '#' ]]; do
        if [[ $SRV_DESCRIPTION =~ '#' ]]; then echo -e "${BOLD_YELLOW}Invalid input!${RESET_COLOR} ${YELLOW}The description must not contain any hash symbols (#).${RESET_COLOR}"; fi
        echo -e "\n${LIGHT_CYAN}Please enter a one-sentence description for the new service.${BOLD_CYAN}"
        read SRV_DESCRIPTION
    done

    echo -e "${RESET_COLOR}\n${GRAY}vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv${RESET_COLOR}\n"
    echo -e "${RESET_COLOR}Your service is going to be named ${ITALIC_CYAN}${SRVNAME}-service${RESET_COLOR}."
    echo -e "${RESET_COLOR}Your service is going to have the following description:"
    echo -e "${RESET_COLOR}\"${ITALIC_CYAN}${SRV_DESCRIPTION}${RESET_COLOR}\""

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
echo -e "${GRAY}|${RESET_COLOR}     files ${ITALIC_CYAN}../init-dbs.sh${RESET_COLOR}, ${ITALIC_CYAN}../docker-compose.yml${RESET_COLOR} and ${ITALIC_CYAN}../../docker-${RESET_COLOR}         ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     ${ITALIC_CYAN}compose.yml${RESET_COLOR} as well as ${ITALIC_CYAN}../../.env${RESET_COLOR} and ${ITALIC_CYAN}../../.env.example${RESET_COLOR} with ${ITALIC_CYAN}../${RESET_COLOR}     ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     ${ITALIC_CYAN}config-service/Sources/App/Migrations/CreateService.swift${RESET_COLOR} in order    ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}     to integrate the newly created service into the overall structure.    ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}|${RESET_COLOR}                                                                           ${GRAY}|${RESET_COLOR}"
echo -e "${GRAY}*---------------------------------------------------------------------------*${RESET_COLOR}"
echo ''

read_user_inputs

SRV_CONFIG_SERVICE_UUID="$(echo "$(uuidgen)" | awk '{$1=tolower($1)}1')"
SRV_PSQL_PASSWORD="$(LC_CTYPE=C < /dev/urandom tr -dc '[:graph:]' | tr -d "'\`\"$\&\/\\\\" | head -c $((RANDOM % 84 + 16)))"

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
      DATABASE_USERNAME: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME:?error}
      DATABASE_PASSWORD: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD:?error}
    labels:
      traefik.enable: true
      traefik.http.routers.${SRVNAME}-service.rule: PathPrefix(\`/${SRVNAME}-service\`) || PathPrefix(\`/${SRVNAME}\`)
      traefik.http.routers.${SRVNAME}-service.middlewares: ${SRVNAME}-service-replace-path-regex
      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.regex: ^/${SRVNAME}-service(:/(.*))?
      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.replacement: /\$\$1

  ${SRVNAME}-service-migration:
    profiles:
      - not-default
    image: kivop-${SRVNAME}-service:latest
    build:
      context: ./..
      dockerfile: backend/${SRVNAME}-service/Dockerfile
    container_name: kivop-${SRVNAME}-service-migration
    environment:
      <<: *shared_environment
      DATABASE_USERNAME: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME:?error}
      DATABASE_PASSWORD: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD:?error}
    depends_on:
      - postgres
    command: [\"migrate\", \"--yes\"]

  ${SRVNAME}-service-revert:
    profiles:
      - not-default
    image: kivop-${SRVNAME}-service:latest
    build:
      context: ./..
      dockerfile: backend/${SRVNAME}-service/Dockerfile
    container_name: kivop-${SRVNAME}-service-revert
    environment:
      <<: *shared_environment
      DATABASE_USERNAME: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME:?error}
      DATABASE_PASSWORD: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD:?error}
    depends_on:
      - postgres
    command: [\"migrate\", \"--revert\", \"--yes\"]

#
# Volumes"

ROOT_COMPOSE_TEMPLATE="# Vapor: ${SRVNAME}-service
#
  ${SRVNAME}-service:
    extends:
      file: ./backend/docker-compose.yml
      service: ${SRVNAME}-service
    container_name: kivop-${SRVNAME}-service
    restart: unless-stopped
    labels:
      traefik.enable: true
      traefik.http.routers.${SRVNAME}-service.rule: Host(\`kivop.ipv64.net\`) \&\& (PathPrefix(\`/${SRVNAME}-service\`) || PathPrefix(\`/${SRVNAME}s\`))
      traefik.http.routers.${SRVNAME}-service.middlewares: ${SRVNAME}-service-replace-path-regex
      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.regex: ^/${SRVNAME}-service(:/(.*))?
      traefik.http.middlewares.${SRVNAME}-service-replace-path-regex.replacepathregex.replacement: /\$\$1
      traefik.http.routers.${SRVNAME}-service.entrypoints: https
      traefik.http.routers.${SRVNAME}-service.tls: true
      traefik.http.routers.${SRVNAME}-service.tls.certresolver: myresolver

  ${SRVNAME}-service-migration:
    profiles:
      - not-default
    extends:
      file: ./backend/docker-compose.yml
      service: ${SRVNAME}-service-migration

  ${SRVNAME}-service-revert:
    profiles:
      - not-default
    extends:
      file: ./backend/docker-compose.yml
      service: ${SRVNAME}-service-migration

#
# Volumes"

CONFIG_SERVICE_SERVICE_TEMPLATE=",
            Service(
                id: UUID(uuidString: \"${SRV_CONFIG_SERVICE_UUID}\")!,
                name: \"${FIRST_LETTER_CAPITAL_SRVNAME}-Service\",
                webhook_url: \"http://kivop-${SRVNAME}-service/webhook\",
                description: \"${SRV_DESCRIPTION}\",
                active: true
            ) // Initialdaten für die Services einfügen: END"

POSTGRES_CREDENTIAL_ENV_COMPOSE_TEMPLATE="# PostgreSQL-Credentials
      ${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME:?error}
      ${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD: \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD:?error}"

ESCAPED_COMPOSE_TEMPLATE=$(echo "$COMPOSE_TEMPLATE" | awk '{if (NR > 1) printf "\\n"; printf "%s", $0}')
ESCAPED_ROOT_COMPOSE_TEMPLATE=$(echo "$ROOT_COMPOSE_TEMPLATE" | awk '{if (NR > 1) printf "\\n"; printf "%s", $0}')
ESCAPED_CONFIG_SERVICE_SERVICE_TEMPLATE=$(echo "$CONFIG_SERVICE_SERVICE_TEMPLATE" | awk '{if (NR > 1) printf "\\n"; printf "%s", $0}')
ESCAPED_POSTGRES_CREDENTIAL_ENV_COMPOSE_TEMPLATE=$(echo "$POSTGRES_CREDENTIAL_ENV_COMPOSE_TEMPLATE" | awk '{if (NR > 1) printf "\\n"; printf "%s", $0}')

cp -r . "../${SRVNAME}-service" && rm "../${SRVNAME}-service/replicate.sh" # Copy entire template to new service-folder and remove replicate.sh

# Replace every placeholder in newly created files' names
find "../${SRVNAME}-service/" -type f -name '*FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER*' | while read -r file; do
    mv "$file" "`echo $file | sed "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"`"
done

# Replace placeholders in files
find "../${SRVNAME}-service/" -type f ! -name "*.png" ! -name ".*" ! -path "*swagger*" ! -path "*.swiftpm*" -print0 | xargs -0 sed -i '' -e "s/FIRST_LETTER_CAPITAL_SRVNAME_PLACEHOLDER/${FIRST_LETTER_CAPITAL_SRVNAME}/g"
find "../${SRVNAME}-service/" -type f ! -name "*.png" ! -name ".*" ! -path "*swagger*" ! -path "*.swiftpm*" -print0 | xargs -0 sed -i '' -e "s/SRVNAME_PLACEHOLDER/${SRVNAME}/g"
find "../${SRVNAME}-service/" -type f ! -name "*.png" ! -name ".*" ! -path "*swagger*" ! -path "*.swiftpm*" -print0 | xargs -0 sed -i '' -e "s/SRV_CONFIG_SERVICE_UUID_PLACEHOLDER/${SRV_CONFIG_SERVICE_UUID}/g"

# Add service to /backend/docker-compose.yml and /docker-compose.yml
sed -i '' -e "s;# PostgreSQL-Credentials$;${ESCAPED_POSTGRES_CREDENTIAL_ENV_COMPOSE_TEMPLATE};" ../docker-compose.yml
sed -i '' -e "s;^# Volumes$;${ESCAPED_COMPOSE_TEMPLATE};" ../docker-compose.yml
sed -i '' -e "s;^# Volumes$;${ESCAPED_ROOT_COMPOSE_TEMPLATE};" ../../docker-compose.yml

# Add service to OpenAPI description in /backend/models/Sources/Models/_misc/OpenAPIInfo.swift
sed -i '' -e "s;^\"\"\" \/\/ Description: END$;- [${FIRST_LETTER_CAPITAL_SRVNAME}-Service](/${SRVNAME}-service/swagger/#/)\n\"\"\" \/\/ Description: END;" ../models/Sources/Models/_misc/OpenAPIInfo.swift

# Add service's psql-user to /backend/init-dbs.sh
sed -i '' -e "s/^\t-- Service-Users$/\t-- Service-Users\n\tCREATE USER \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '\${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;/" ../init-dbs.sh
sed -i '' -e "s/^\t-- Service-User-Privileges$/\t-- Service-User-Privileges\n\tALTER DEFAULT PRIVILEGES FOR USER \${${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;/" ../init-dbs.sh

# Add service's psql-credentials to /.env and (without password to) /.env.example
echo "${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME=${SRVNAME}_service" >> ../../.env
echo "${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD='${SRV_PSQL_PASSWORD}'" >> ../../.env
echo "${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_USERNAME=${SRVNAME}_service" >> ../../.env.example
echo "${ALL_LETTERS_CAPITAL_SRVNAME}_SERVICE_POSTGRES_PASSWORD=" >> ../../.env.example

# Print password to user
echo ''
echo -e "${RESET_COLOR}A new password has been generated for the new service's PostgreSQL user ${ITALIC_CYAN}${SRVNAME}_service${RESET_COLOR}:"
echo -e "${ITALIC_CYAN}${SRV_PSQL_PASSWORD}${RESET_COLOR}"

# Add Config-Service UUID to ../config-service/Sources/App/Migrations/CreateService.swift
sed -i '' -e "s# \/\/ Initialdaten für die Services einfügen: END\$#${ESCAPED_CONFIG_SERVICE_SERVICE_TEMPLATE}#" ../config-service/Sources/App/Migrations/CreateService.swift

# Print Config-Service UUID to user
echo ''
echo -e "${RESET_COLOR}A new Config-Service UUID has been generated for the new service:"
echo -e "${ITALIC_CYAN}${SRV_CONFIG_SERVICE_UUID}${RESET_COLOR}"

# Confirm success to the user
echo ''
echo -e "${GRAY}>>>${RESET_COLOR} ${BOLD_CYAN}DONE${RESET_COLOR} ${GRAY}<<<${RESET_COLOR}"
