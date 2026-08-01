# Java Azure Deployments

Learning project: OAuth2 authentication microservice with CI/CD and Azure deployment.

## Projects

| Folder | Description |
|--------|-------------|
| [`auth-service/`](auth-service/) | Spring Boot OAuth2 auth microservice |
| [`.github/workflows/`](.github/workflows/) | GitHub Actions CI/CD |
| [`azure-pipelines/`](azure-pipelines/) | Azure DevOps pipelines (optional) |

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
- [Azure Deployment](auth-service/docs/AZURE-DEPLOYMENT.md) (Phase 3+)

## Learning phases

1. **Local** — Docker + Postman
2. **CI** — GitHub Actions (build & test on push)
3. **Cloud** — Azure free trial (optional)
4. **CD** — Deploy to Azure Container Apps
