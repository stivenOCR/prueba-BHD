# 🚀 Solución Prueba Técnica DevOps - CI/CD & Kubernetes

Repositorio público con la solución completa para la evaluación técnica DevOps (**first-filter / Prueba-Dummy**).

---

## 📑 Tabla de Contenidos

- [Arquitectura de la Solución](#-arquitectura-de-la-solución)
- [Componentes Entregados](#-componentes-entregados)
- [1. Aplicación Base y Pruebas Unitarias](#1-aplicación-base-y-pruebas-unitarias)
- [2. Control de Calidad con SonarQube (2 Escenarios)](#2-control-de-calidad-con-sonarqube-2-escenarios)
- [3. Contenerización con Docker](#3-contenerización-con-docker)
- [4. Tareas de Automatización en Pipeline (5a y 5b)](#4-tareas-de-automatización-en-pipeline-5a-y-5b)
- [5. Orquestación y Despliegue en Kubernetes](#5-orquestación-y-despliegue-en-kubernetes)
- [6. Pipeline CI/CD en Azure DevOps (`azure-pipelines.yml`)](#6-pipeline-cicd-en-azure-devops-azure-pipelinesyml)
- [7. Guía de Ejecución Local](#7-guía-de-ejecución-local)

---

## 🏛️ Arquitectura de la Solución

```
                                      +---------------------------------------------+
                                      |            Azure DevOps Pipeline            |
                                      +---------------------------------------------+
                                                             |
            +---------------------------+--------------------+---------------------+---------------------------+
            |                           |                                          |                           |
            v                           v                                          v                           v
   [ 1. Test & SonarQube ]    [ 2. Automatización ]                      [ 3. Docker Build & Push ]     [ 4. K8s Deploy ]
   - Jest Unit Tests          - 5a: Matrix 10x "Hola Mundo" en paralelo   - Multi-stage build           - Deployment (2 pods)
   - Quality Gate validation  - 5b: Script 10 archivos con timestamp      - Push a DockerHub / ACR      - NodePort Service
                                                                                                        - Ingress Controller
```

---

## 📦 Componentes Entregados

| Componente | Ruta en el Repositorio | Descripción |
| :--- | :--- | :--- |
| **API REST** | [`src/app.js`](src/app.js), [`src/index.js`](src/index.js) | Microservicio Node.js / Express con endpoints `/` y `/health`. |
| **Pruebas Unitarias** | [`src/app.test.js`](src/app.test.js) | Suite de pruebas unitarias Jest con cobertura de código > 90%. |
| **Dockerfile** | [`Dockerfile`](Dockerfile) | Multi-stage build seguro con usuario no-root y healthcheck. |
| **K8s Manifests** | [`environment/`](environment/) | `deployment.yaml`, `service.yaml`, `ingress.yaml` y `kustomization.yaml`. |
| **Scripts** | [`scripts/`](scripts/) | Automatización en Bash (`create_files.sh`) y PowerShell (`create_files.ps1`). |
| **Pipeline CI/CD** | [`azure-pipelines.yml`](azure-pipelines.yml) | Pipeline multi-etapa orquestado para Azure DevOps. |
| **SonarQube Config** | [`sonar-project.properties`](sonar-project.properties) | Parámetros de análisis estático y umbrales de Quality Gate. |

---

## 1. Aplicación Base y Pruebas Unitarias

La aplicación implementa los estándares oficiales de contenedores web:
- **`GET /`**: Retorna el estado general de la API REST.
- **`GET /health`**: Endpoint de diagnóstico utilizado por las sondas de Kubernetes (`livenessProbe` y `readinessProbe`).
- **`GET /api/info`**: Retorna metadatos de entorno y versión.

### Ejecución de Pruebas:
```bash
npm install
npm test
```
*Cobertura alcanzada: 100% de statements y funciones.*

---

## 2. Control de Calidad con SonarQube (2 Escenarios)

La prueba requiere la demostración de dos escenarios de análisis estático:

### Escenario 1: Análisis Fallido (Quality Gate Failed) ❌
- **Causa**: Introducción de código con cobertura de pruebas insuficiente (< 80%), duplicación excesiva o "code smells" bloqueantes.
- **Comportamiento en Pipeline**: El paso `SonarQubePublish` detecta el fallo del Quality Gate y detiene la ejecución del pipeline para evitar el paso a producción.

### Escenario 2: Análisis Exitoso (Quality Gate Passed) ✅
- **Causa**: Código con 100% de cobertura de pruebas unitarias, 0 vulnerabilidades, 0 bugs y 0 duplicaciones.
- **Comportamiento en Pipeline**: El Quality Gate aprueba el paso y se procede inmediatamente a las etapas de automatización, construcción de imagen y despliegue.

---

## 3. Contenerización con Docker

El archivo [`Dockerfile`](Dockerfile) utiliza el patrón **Multi-Stage Build** para maximizar la seguridad y minimizar el tamaño de la imagen:
1. **Etapa 1 (`builder`)**: Instala únicamente dependencias de producción (`npm ci --only=production`).
2. **Etapa 2 (`final`)**: Basada en `node:20-alpine`, se ejecuta bajo el usuario sin privilegios `node` (no-root).

### Construcción y Prueba Local:
```bash
# Construir imagen
docker build -t devops-sample-app:v1.0.0 .

# Ejecutar contenedor
docker run -d -p 3000:3000 --name devops-app devops-sample-app:v1.0.0

# Validar healthcheck
curl http://localhost:3000/health
```

---

## 4. Tareas de Automatización en Pipeline (5a y 5b)

### 4a. 10 "Hola Mundo" en Paralelo (Job Concurrente)
Configurado en `azure-pipelines.yml` mediante la directiva `strategy: matrix` con `maxParallel: 10`:
- Se generan 10 workers simultáneos (`Worker_01` a `Worker_10`), cada uno imprimiendo su mensaje con timestamp.

### 4b. Script de Generación de 10 Archivos con Fecha
Implementado en [`scripts/create_files.sh`](scripts/create_files.sh) (Bash para agentes Linux) y [`scripts/create_files.ps1`](scripts/create_files.ps1) (PowerShell para agentes Windows):
- Genera 10 archivos independientes con el formato `archivo_{i}_{yyyy-MM-dd_HH-mm-ss}.txt`.
- Escribe el timestamp detallado en su contenido.
- Itera e imprime el contenido de cada uno en la salida estándar de la consola.

---

## 5. Orquestación y Despliegue en Kubernetes

Los manifiestos se encuentran organizados dentro del directorio [`environment/`](environment/):

1. **`deployment.yaml`**:
   - 2 réplicas con estrategia `RollingUpdate`.
   - Límites y reservas de recursos (`requests` y `limits` de CPU y Memoria).
   - `readinessProbe` y `livenessProbe` apuntando a `/health`.
2. **`service.yaml`**:
   - Servicio tipo `NodePort` mapeando el puerto interno `3000` al puerto externo `30080`.
3. **`ingress.yaml`**:
   - Enrutador HTTP basado en Ingress Controller hacia el dominio `devops-app.local`.
4. **`kustomization.yaml`**:
   - Gestión declarativa del conjunto de manifiestos (Buenas prácticas K8s).

### Despliegue en el Clúster:
```bash
# Aplicar todos los manifiestos
kubectl apply -k environment/

# Verificar estado de pods y servicios
kubectl get pods -l app=devops-sample-app
kubectl get svc devops-sample-service
kubectl get ingress devops-sample-ingress
```

---

## 6. Pipeline CI/CD en Azure DevOps (`azure-pipelines.yml`)

El pipeline se encuentra estructurado en 4 etapas secuenciales con dependencias declarativas:

```yaml
stages:
  - stage: Quality_And_Test       # Pruebas Jest + SonarQube Quality Gate
  - stage: Automation_Tasks       # Matrix 10x Hola Mundo + Script 10 archivos
  - stage: Build_And_Push_Docker  # Docker build y push al registro
  - stage: Kubernetes_Deploy      # Despliegue declarativo en K8s
```

---

## 7. Guía de Ejecución Local

Si deseas probar la solución completa localmente:

```bash
# 1. Clonar repositorio
git clone https://github.com/stivenOCR/prueba-BHD.git
cd prueba-BHD

# 2. Instalar y probar aplicación
npm install
npm test

# 3. Probar script de automatización
./scripts/create_files.sh      # En Linux / macOS
# o en PowerShell:
.\scripts\create_files.ps1     # En Windows

# 4. Desplegar en Kubernetes local
kubectl apply -k environment/
```
