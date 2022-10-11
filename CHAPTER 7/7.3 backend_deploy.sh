#убираем все лишние переменные, теперь они прописываются в vault
#добавим переменную SPRING_FLYWAY_ENABLED=false

#!/bin/bash
set +e

cat > .env_docker_backend <<EOF
SPRING_FLYWAY_ENABLED=${SPRING_FLYWAY_ENABLED}
REPORT_PATH=./logs
CI_REGISTRY=${CI_REGISTRY}
GITLAB_DEPLOY_TOKEN=${GITLAB_DEPLOY_TOKEN}
EOF

cat .env

docker login -u anatolyprima -p $GITLAB_DEPLOY_TOKEN $CI_REGISTRY
docker pull $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest
#docker images
#docker ps -a
docker stop sausage-backend || true
docker rm sausage-backend || true
docker rmi $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest
docker network rm sausage_network || true
docker network create -d bridge sausage_network || true

set -e
docker run -d --name sausage-backend \
    --network=sausage_network \
    --restart always \
    --pull always \
    --env-file .env_docker_backend \
    $CI_REGISTRY/anatolyprima/sausage-store/sausage-backend:latest
