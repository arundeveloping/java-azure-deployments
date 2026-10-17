<<<<<<< HEAD
# Java Azure Deployments

Learning project: OAuth2 authentication microservice with CI/CD and Azure deployment.

## Projects

| Folder | Description |
|--------|-------------|
| [`auth-service/`](auth-service/) | Spring Boot OAuth2 auth microservice |
| [`auth-frontend/`](auth-frontend/) | Vue 3 web UI (deploy: [Azure Static Web Apps](auth-frontend/docs/AZURE-STATIC-WEB-APPS.md)) |
| [`.github/workflows/`](.github/workflows/) | GitHub Actions CI/CD |
| [`auth-service/azure-pipelines/`](auth-service/azure-pipelines/) | Azure DevOps pipelines for auth-service (optional) |

## Quick start (Phase 1 — local)

```bash
cd auth-service
docker compose up -d
# App: http://localhost:8080
# Swagger: http://localhost:8080/swagger-ui.html
```

## Docs

- [Auth Service README](auth-service/README.md)
- [Free Learning Guide](auth-service/docs/FREE-LEARNING-GUIDE.md)
- [Phase 3 — Azure Portal (no CLI)](auth-service/docs/PHASE-3-AZURE-PORTAL.md) ← deploy guide
- [Azure SDLC Master Roadmap](auth-service/docs/AZURE-SDLC-ROADMAP.md) ← interview prep (12 weeks)
- [AZ-900 Complete Roadmap](auth-service/docs/AZURE-900-ROADMAP.md) ← certification study guide
- [Phase 3 — Azure CLI](auth-service/docs/PHASE-3-AZURE.md) (optional)
- [Azure Deployment (CD automation)](auth-service/docs/AZURE-DEPLOYMENT.md) (Phase 4)

## Learning phases

1. **Local** — Docker + Postman
2. **CI** — GitHub Actions (build & test on push)
3. **Cloud** — Azure free trial (optional)
4. **CD** — Deploy to Azure Container Apps
=======
# Introduction 
TODO: Give a short introduction of your project. Let this section explain the objectives or the motivation behind this project. 

# Getting Started
TODO: Guide users through getting your code up and running on their own system. In this section you can talk about:
1.	Installation process
2.	Software dependencies
3.	Latest releases
4.	API references

# Build and Test
TODO: Describe and show how to build your code and run the tests. 

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

If you want to learn more about creating good readme files then refer the following [guidelines](https://docs.microsoft.com/en-us/azure/devops/repos/git/create-a-readme?view=azure-devops). You can also seek inspiration from the below readme files:
- [ASP.NET Core](https://github.com/aspnet/Home)
- [Visual Studio Code](https://github.com/Microsoft/vscode)
- [Chakra Core](https://github.com/Microsoft/ChakraCore)
>>>>>>> azure/main
