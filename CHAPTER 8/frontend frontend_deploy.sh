#!/bin/bash
set +e

cat > .env_docker_frontend <<EOF
CI_REGISTRY=${CI_REGISTRY}
GITLAB_DEPLOY_TOKEN=${GITLAB_DEPLOY_TOKEN}

EOF

#посмотрим что записалось в файл
cat .env_docker_frontend

#логинимся, чтобы можно было стянуть измененный контейнер с приватного репозитория
docker login -u anatolyprima -p $GITLAB_DEPLOY_TOKEN $CI_REGISTRY
docker pull $CI_REGISTRY/anatolyprima/sausage-store/sausage-frontend:latest
#запускаем ранее скачанный на машину docker-compose.yml
docker-compose up -d
