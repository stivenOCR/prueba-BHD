# 📄 INFORME DE EVIDENCIAS: PRUEBA TÉCNICA DEVOPS (FIRST-FILTER)

**Candidato:** Stiven Orozco  
**Repositorio GitHub:** https://github.com/stivenOCR/prueba-BHD  
**Docker Hub:** https://hub.docker.com/r/stivendevcr/devops-sample-app  
**Pipeline Azure DevOps:** https://dev.azure.com/bhdleon/BHDL-Practica-DevOps/_build/results?buildId=5251526  

---

## PASO 1: Descarga los archivos del repositorio elegido
**Explicación técnica:**  
Se seleccionó del catálogo oficial de muestras de Docker (`https://docs.docker.com/samples/`) el framework **Node.js con Express**, tomando la plantilla base de microservicio REST con su punto de entrada `src/index.js`, controlador `src/app.js` y definición de dependencias en `package.json`.

> 📷 **[AQUÍ PEGA LA CAPTURA DE: Tu editor de código mostrando la estructura de carpetas src/, package.json y Dockerfile en el proyecto prueba-BHD, o la captura de la página oficial de Docker Samples donde sale Express Samples]**

---

## PASO 2: Instala el framework necesario en caso de no tenerlo
**Explicación técnica:**  
Se instaló el entorno de ejecución Node.js (v20 LTS) y se gestionaron las dependencias del proyecto (`express`, y herramientas de prueba `jest` y `supertest`) mediante el gestor de paquetes NPM (`npm install`), validando que el entorno local y de integración continua cuente con las librerías necesarias.

> 📷 **[AQUÍ PEGA LA CAPTURA DE: La terminal ejecutando `node -v`, `npm -v` o el comando `npm test` donde se vean las pruebas unitarias pasando al 100%]**

---

## PASO 3: Compila la aplicación luego de pasar el análisis de SonarQube (2 Escenarios)
**Explicación técnica:**  
Se desplegó un servidor SonarQube Community dentro de Kubernetes en el namespace dedicado `sonarqube` y se configuró `sonar-project.properties`. Se evaluaron los dos escenarios exigidos:
1. **Escenario 1 (Fallido ❌):** Se introdujo intencionalmente código vulnerable con credenciales en duro y sin cobertura de pruebas, provocando que el Quality Gate fallara y bloqueara la promoción.
2. **Escenario 2 (Exitoso ✅):** Código refactorizado con 100% de cobertura en Jest, 0 vulnerabilidades y 0 bugs, logrando la aprobación del Quality Gate (`Passed`). Tras la aprobación, se ejecutó la compilación de la imagen Docker.

> 📷 **[AQUÍ PEGA LA CAPTURA 1 DE: Panel de SonarQube en ROJO mostrando "Failed" (Coverage 21.4% y 2 conditions failed)]**  
> *(La captura que tomaste con el cuadro rojo grande de Failed)*

> 📷 **[AQUÍ PEGA LA CAPTURA 2 DE: Panel de SonarQube en VERDE mostrando "Passed" (0 Bugs, 0 Vulnerabilities, 100% Coverage)]**  
> *(La captura que tomaste con el cuadro verde grande de Passed)*

> 📷 **[AQUÍ PEGA LA CAPTURA 3 DE: Terminal ejecutando `docker build -t devops-sample-app:v1.0.0 .` finalizando con éxito tras el análisis]**

---

## PASO 4: Genera una imagen de Docker y sube la imagen a Docker Hub desde el pipeline YAML
**Explicación técnica:**  
Se diseñó un `Dockerfile` multi-stage optimizado para producción ejecutándose bajo usuario sin privilegios (`node`). La imagen se construyó y etiquetó bajo el repositorio público `stivendevcr/devops-sample-app:v1.0.0` y `latest`, y se configuró la tarea de autenticación y `docker push` directamente en el Stage 3 del pipeline YAML (`azure-pipelines.yml`).

> 📷 **[AQUÍ PEGA LA CAPTURA DE: Tu terminal mostrando el comando `docker push stivendevcr/devops-sample-app:v1.0.0` con todas las capas en "Pushed", o la web de Docker Hub mostrando tu repositorio stivendevcr/devops-sample-app]**

---

## PASO 5: Tareas dentro del pipeline en Bash / PowerShell (5a y 5b)
**Explicación técnica:**  
Dentro del pipeline en Azure DevOps se implementaron las dos automatizaciones requeridas:
- **5a (Hola Mundo Paralelo):** Mediante la directiva `strategy: matrix` con `maxParallel: 10`, se orquestaron 10 jobs simultáneos (`Worker_01` a `Worker_10`), cada uno imprimiendo "Hola Mundo" con su ID y timestamp en paralelo.
- **5b (Script de 10 archivos con fecha):** Se ejecutó el script `scripts/create_files.sh` / `create_files.ps1` que genera dinámicamente 10 archivos con la fecha/hora en su nombre y contenido, imprimiendo su salida en la consola.

> 📷 **[AQUÍ PEGA LA CAPTURA DE: Azure DevOps en el Stage "2. Tareas de Automatización" mostrando los 10 workers paralelos completados y el job de los 10 archivos en verde]**

---

## PASO 6: Despliega la app a un clúster de Kubernetes (Docker Desktop K8s)
**Explicación técnica:**  
Se aprovisionó un clúster local de Kubernetes y se desplegó la aplicación mediante el manifiesto `environment/deployment.yaml` configurado con 2 réplicas de alta disponibilidad, límites de recursos de CPU/Memoria y sondas de salud activas (`livenessProbe` y `readinessProbe` apuntando a `/health`).

> 📷 **[AQUÍ PEGA LA CAPTURA DE: Terminal ejecutando `kubectl get pods` donde se vean los 2 pods `devops-sample-app-...` en estado `1/1 Running` y el pod de `sonarqube` en el namespace sonarqube]**

---

## PASO 7: Crea un endpoint externo accesible (Ingress) para la aplicación
**Explicación técnica:**  
Se implementó un recurso Ingress (`environment/ingress.yaml`) enrutando el host `devops-app.local` hacia el servicio `devops-sample-service` en el puerto HTTP 80. Se validó la conectividad externa y respuesta operativa del microservicio consultando el endpoint de diagnóstico de salud.

> 📷 **[AQUÍ PEGA LA CAPTURA 1 DE: Terminal ejecutando `kubectl get ingress` mostrando el host `devops-app.local` en el puerto 80]**

> 📷 **[AQUÍ PEGA LA CAPTURA 2 DE: Navegador web mostrando la respuesta JSON del endpoint: `{"status":"UP","uptime":...}`]**

---

## PASO 8: Sube al repo en una carpeta `environment` todos los YAML de K8s
**Explicación técnica:**  
Todos los manifiestos declarativos de Kubernetes fueron centralizados dentro de la carpeta `environment/` bajo el estándar de **Kustomize** (`kustomization.yaml`), incluyendo el deployment, service, ingress y sonarqube, y fueron versionados y publicados en el repositorio público de GitHub bajo la estrategia de ramas GitFlow.

> 📷 **[AQUÍ PEGA LA CAPTURA DE: Repositorio en GitHub mostrando la carpeta `environment/` con los archivos: `deployment.yaml`, `ingress.yaml`, `kustomization.yaml`, `service.yaml` y `sonarqube.yaml`]**

---

## RESUMEN GLOBAL DEL PIPELINE CI/CD
**Explicación técnica:**  
El pipeline completo en Azure DevOps (`azure-pipelines.yml`) ejecuta de manera secuencial y automatizada todas las fases: Quality & Testing -> Automatización paralela -> Docker Build & Push -> Validación de Kubernetes.

> 📷 **[AQUÍ PEGA LA CAPTURA DE: La vista general de Azure DevOps con la ejecución #5251526 en "Build Succeeded" y las 4 etapas con sus checks verdes]**
