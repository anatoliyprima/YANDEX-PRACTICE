#!/bin/bash
set +e

#одбавим переменные для построения секрета внутрь файла, пусть будет видно, что они передаются при деплое
cat > .env_docker_backend <<EOF

SPRING_FLYWAY_ENABLED=${SPRING_FLYWAY_ENABLED}

SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}
SPRING_DATASOURCE_PASSWORD=${SPRING_DATASOURCE_PASSWORD}
SPRING_DATASOURCE_USERNAME=${SPRING_DATASOURCE_USERNAME}

SPRING_DATA_MONGODB_USERNAME=${SPRING_DATA_MONGODB_USERNAME}
SPRING_DATA_MONGODB_PASSWORD=${SPRING_DATA_MONGODB_PASSWORD}
SPRING_DATA_MONGODB_HOST=${SPRING_DATA_MONGODB_HOST}
SPRING_DATA_MONGODB_PORT=${SPRING_DATA_MONGODB_PORT}
SPRING_DATA_MONGODB_DATABASE=${SPRING_DATA_MONGODB_DATABASE}

CI_REGISTRY=${CI_REGISTRY}
GITLAB_DEPLOY_TOKEN=${GITLAB_DEPLOY_TOKEN}
VAULT_TOKEN=${VAULT_TOKEN}
REPORT_PATH=./logs

EOF

#посмотрим что записалось в файл
cat .env_docker_backend

#обновляем секреты для vault
cat <<EOF | docker exec -i vault ash
  sleep 10;
  vault login ${VAULT_TOKEN}

  vault secrets enable -path=secret kv

  vault kv put sausage-store/secret spring.datasource.password="${SPRING_DATASOURCE_PASSWORD}" spring.data.mongodb.uri="mongodb://${SPRING_DATA_MONGODB_USERNAME}:${SPRING_DATA_MONGODB_PASSWORD}@${SPRING_DATA_MONGODB_HOST}:${SPRING_DATA_MONGODB_PORT}/${SPRING_DATA_MONGODB_DATABASE}?tls=true"
EOF


#логинимся, чтобы можно было стянуть измененный контейнер с приватного репозитория
docker login -u anatolyprima -p $GITLAB_DEPLOY_TOKEN $CI_REGISTRY
docker pull $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest
#запускаем ранее скачанный на машину docker-compose.yml
docker-compose up -d
