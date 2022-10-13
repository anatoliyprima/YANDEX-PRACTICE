#!/bin/bash
set +e

cat > .env_docker_backend <<EOF

SPRING_FLYWAY_ENABLED=${SPRING_FLYWAY_ENABLED}
SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}
CI_REGISTRY=${CI_REGISTRY}
GITLAB_DEPLOY_TOKEN=${GITLAB_DEPLOY_TOKEN}
VAULT_TOKEN=${VAULT_TOKEN}
REPORT_PATH=./logs

EOF

#посмотрим что записалось в файл
cat .env_docker_backend

#логинимся, чтобы можно было стянуть измененный контейнер с приватного репозитория
docker login -u anatolyprima -p $GITLAB_DEPLOY_TOKEN $CI_REGISTRY
docker pull $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest
#запускаем ранее скачанный на машину docker-compose.yml
docker-compose up -d
