#!/usr/bin/env bash
set -eo pipefail

REPO_DIR="${RIMAC_BPM_REPO:-/Users/ricardogenaro1999/Documents/GitHub/rimac/bpm-siniestro-credito-salud-api-proc-impl}"
REGION="us-east-1"
ACCOUNT_ID="438323272304"
ECR_REPO="bpm-siniestros-salud-api-proc"
CLUSTER="UE1TESTTESTCOMECSBPMFSS001"
SERVICE="UE1TESTTESTECSSVCBPMFSS001"
TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:us-east-1:438323272304:targetgroup/bpm-siniestros-salud-api-proc/204c7d3dccc92314"
BASE_BRANCH="origin/releaseado"

# Color helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_usage() {
  cat << EOF
Uso: $(basename "$0") [OPCIONES]

Script de despliegue local seguro para el microservicio Rimac BPM Siniestros Salud en AWS TEST.
Totalmente desacoplado del repositorio de trabajo.

Opciones:
  --check     Valida si tu rama actual tiene cambios en archivos .tf o schemas/ sin desplegar.
  --status    Consulta el estado del servicio ECS, tareas activas y Target Group en TEST.
  --force     Fuerza el despliegue del contenedor omitiendo la advertencia de cambios en .tf.
  --help      Muestra esta ayuda.
EOF
}

check_tf_drift() {
  cd "$REPO_DIR"
  local tf_files
  tf_files=$(git diff --name-only "$BASE_BRANCH"...HEAD -- "*.tf" "schemas/*" 2>/dev/null || true)
  if [ -n "$tf_files" ]; then
    echo -e "${RED}⚠️  ¡ALERTA DE INFRAESTRUCTURA DETECTADA (IaC)!${NC}"
    echo -e "${YELLOW}Se detectaron cambios en archivos de Terraform o Schemas en tu rama:${NC}"
    echo "$tf_files"
    echo ""
    echo -e "${RED}⛔ ADVERTENCIA DE SEGURIDAD:${NC}"
    echo "   Desplegar infraestructura manualmente colisionará con el .tfstate de Rimac"
    echo "   y causará que el pipeline de Azure DevOps falle con '409 ConflictException'."
    echo "   Los cambios en archivos .tf deben promoverse oficialmente vía Azure Pipeline."
    return 1
  else
    echo -e "${GREEN}✅ Check de infraestructura limpio: No hay cambios en archivos .tf ni schemas.${NC}"
    return 0
  fi
}

check_service_status() {
  echo -e "${BLUE}=== Estado del Servicio ECS en TEST ===${NC}"
  aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGION" \
    --query "services[0].[serviceName, status, runningCount, pendingCount, desiredCount, taskDefinition]" \
    --output table

  echo -e "\n${BLUE}=== Últimos 3 Eventos de ECS ===${NC}"
  aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGION" \
    --query "services[0].events[:3].[createdAt, message]" \
    --output text

  echo -e "\n${BLUE}=== Salud en el Target Group (ALB) ===${NC}"
  aws elbv2 describe-target-health \
    --target-group-arn "$TARGET_GROUP_ARN" \
    --region "$REGION" \
    --query "TargetHealthDescriptions[*].[Target.Id, Target.Port, TargetHealth.State]" \
    --output table
}

# Parse options
FORCE_DEPLOY=false
ACTION="deploy"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check)
      ACTION="check"
      shift
      ;;
    --status)
      ACTION="status"
      shift
      ;;
    --force)
      FORCE_DEPLOY=true
      shift
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1"
      show_usage
      exit 1
      ;;
  esac
done

if [ "$ACTION" = "status" ]; then
  check_service_status
  exit 0
fi

if [ "$ACTION" = "check" ]; then
  if check_tf_drift; then
    exit 0
  else
    exit 2
  fi
fi

# Main Deployment Flow
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   Despliegue Local Rimac BPM Siniestros (TEST)       ${NC}"
echo -e "${BLUE}======================================================${NC}"

if [ ! -d "$REPO_DIR" ]; then
  echo -e "${RED}Error: No se encontró el repositorio en $REPO_DIR${NC}"
  exit 1
fi

cd "$REPO_DIR"

# 1. Check Docker status
if ! docker info >/dev/null 2>&1; then
  echo -e "${RED}Error: Docker daemon no está corriendo. Por favor inicia Docker Desktop.${NC}"
  exit 1
fi

# 2. Check AWS Credentials
CALLER_ACCOUNT=$(aws sts get-caller-identity --query "Account" --output text 2>/dev/null || echo "")
if [ "$CALLER_ACCOUNT" != "$ACCOUNT_ID" ]; then
  echo -e "${RED}Error: Tus credenciales de AWS no apuntan a la cuenta TEST ($ACCOUNT_ID).${NC}"
  echo "Cuenta actual detectada: $CALLER_ACCOUNT"
  exit 1
fi

# 3. Check for .tf drift
if ! check_tf_drift; then
  if [ "$FORCE_DEPLOY" = true ]; then
    echo -e "${YELLOW}⚠️  Flag --force detectado. Continuando despliegue de contenedor bajo tu responsabilidad...${NC}"
  elif [ -t 0 ]; then
    read -p "¿Deseas ignorar esta alerta y continuar con el despliegue del contenedor? (escribe 'SI'): " CONFIRM
    if [ "$CONFIRM" != "SI" ]; then
      echo -e "${RED}❌ Despliegue cancelado por seguridad.${NC}"
      exit 1
    fi
  else
    echo -e "${RED}❌ Despliegue abortado. Para forzar el despliegue sin terminal interactiva ejecuta con --force.${NC}"
    exit 2
  fi
fi

# 4. Clean-up trap on exit (ensure ZERO commits and zero modified repo files)
cleanup() {
  echo -e "\n${BLUE}🧹 Limpiando archivos temporales en el repositorio...${NC}"
  cd "$REPO_DIR"
  git checkout Dockerfile .mvn/settings.xml >/dev/null 2>&1 || true
  rm -f camunda-license.txt
  echo -e "${GREEN}✨ Repositorio de trabajo limpio y sin cambios residuales.${NC}"
}
trap cleanup EXIT INT TERM

# 5. Prepare build prerequisites
echo -e "${BLUE}📥 [1/5] Descargando licencia Camunda de SSM...${NC}"
aws ssm get-parameter --name "/CAMUNDA/LICENSE" --with-decryption --query "Parameter.Value" --output text --region "$REGION" > camunda-license.txt

echo -e "${BLUE}⚙️  [2/5] Inyectando configuración Maven temporal (~/.m2/settings.xml)...${NC}"
if [ -f "$HOME/.m2/settings.xml" ]; then
  cp "$HOME/.m2/settings.xml" .mvn/settings.xml
fi

# Multi-arch patch for Dockerfile on Mac Apple Silicon
sed -i '' 's/FROM maven:3.9.8-eclipse-temurin-17-alpine AS build/FROM --platform=$BUILDPLATFORM maven:3.9.8-eclipse-temurin-17 AS build/' Dockerfile

# 6. Build Docker image
echo -e "${BLUE}🐳 [3/5] Construyendo imagen Docker (linux/amd64)...${NC}"
docker build --platform linux/amd64 \
  -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:1.0.0" \
  -t "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:latest" .

# 7. Push to ECR
echo -e "${BLUE}🔑 [4/5] Login y push a Amazon ECR...${NC}"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
docker push "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:1.0.0"
docker push "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO}:latest"

# 8. Force ECS Service deployment
echo -e "${BLUE}🚀 [5/5] Forzando nuevo despliegue en ECS Fargate...${NC}"
aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --force-new-deployment \
  --region "$REGION" > /dev/null

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}🎉 ¡Despliegue local enviado exitosamente a ECS TEST! ${NC}"
echo -e "${GREEN}======================================================${NC}"
echo "Para monitorear el rollout ejecuta: $(basename "$0") --status"
