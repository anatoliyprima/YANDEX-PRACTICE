#!/bin/bash
set +e

#добавим переменные для построения секрета внутрь файла, пусть будет видно, что они передаются при деплое
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


#обновляем секреты для vault
#{ cat <<EOF | docker exec -i vault ash
#  sleep 10;
#  vault login ${VAULT_TOKEN}
#
#  vault secrets enable -path=secret kv
#
#  vault kv put sausage-store/secret spring.datasource.password="${SPRING_DATASOURCE_PASSWORD}" spring.datasource.username="${SPRING_DATASOURCE_USERNAME}" spring.data.mongodb.uri="mongodb://${SPRING_DATA_MONGODB_USERNAME}:${SPRING_DATA_MONGODB_PASSWORD}@${SPRING_DATA_MONGODB_HOST}:${SPRING_DATA_MONGODB_PORT}/${SPRING_DATA_MONGODB_DATABASE}?tls=true "
#EOF

#изменяем скрипт накатки бэкенда:
#проверяем запущен ли blue
docker-compose ps | grep blue
#проверяем запущен ли green
docker-compose ps | grep green
#eсли есть запущенные green контейнеры, остановите их
docker-compose stop backend-green
#cкачайте новую версию образа бэкенда
#docker login -u anatolyprima -p $GITLAB_DEPLOY_TOKEN $CI_REGISTRY
#docker pull $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest

#хардкод
docker login -u anatolyprima -p aktwCaPYoCFkiFu2aHkA gitlab.praktikum-services.ru:5050
docker pull gitlab.praktikum-services.ru:5050/anatolyprima/sausage-store/sausage-backend:latest
#запустите обновлённый green контейнер
docker-compose up -d --force-recreate backend-green
#Дождитесь статуса healthy у нового контейнера
while [ true ]; do
  docker ps --filter health=healthy | grep green > /dev/null
  if [ $? -eq 0 ]; then break; fi
  sleep 10
done
echo "Stop old backend-blue"
#Остановите blue контейнер
docker-compose stop backend-blue
