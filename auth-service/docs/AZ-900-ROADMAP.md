# AZ-900 Complete Study Roadmap

Microsoft Azure Fundamentals — full topic guide mapped to your auth-service learning journey.

**Exam:** AZ-900 Azure Fundamentals  
**Level:** Beginner (no prior Azure experience required)  
**Study time:** 3–5 weeks (2–3 hrs/week) or 1–2 weeks intensive  
**Cost:** ~$99 USD (often discounted)  
**Free study:** [Microsoft Learn AZ-900 path](https://learn.microsoft.com/training/paths/az-900-describe-cloud-concepts/)

---

## Exam structure (what Microsoft tests)

| Domain | Weight | # of focus areas |
|--------|--------|------------------|
| **1. Describe cloud concepts** | 25–30% | 5 areas |
| **2. Describe Azure architecture & services** | 35–40% | 8 areas |
| **3. Describe Azure management & governance** | 30–35% | 6 areas |

**Format:** 40–60 questions, 60 minutes, passing score ~700/1000  
**Question types:** Multiple choice, multi-select, drag-and-drop, yes/no scenarios

---

## Study plan overview

```
Week 1  → Domain 1: Cloud concepts
Week 2  → Domain 2a: Compute + Networking + Storage
Week 3  → Domain 2b: Databases + Identity + Security
Week 4  → Domain 3: Management, governance, pricing + practice exams
Week 5  → Exam day (optional buffer week)
```

---

# DOMAIN 1 — Describe Cloud Concepts (25–30%)

## 1.1 Cloud computing fundamentals

### Topics to master

| Topic | Key points | auth-service link |
|-------|------------|-------------------|
| **What is cloud computing** | On-demand, self-service, pay-per-use, internet-based | You deploy auth-service to Azure instead of buying servers |
| **Shared responsibility model** | IaaS: you manage OS+. PaaS: Azure manages OS. SaaS: Azure manages app | Container Apps = PaaS; VM = IaaS |
| **High availability (HA)** | Redundancy across zones/regions | Multi-replica Container App |
| **Scalability** | Scale up (bigger VM) vs scale out (more instances) | Container Apps HTTP scaling |
| **Elasticity** | Auto scale based on demand | Scale rules on login traffic spikes |
| **Fault tolerance** | System continues when components fail | Health probes remove bad replicas |
| **Disaster recovery (DR)** | Backup, geo-redundancy, RTO/RPO | PostgreSQL geo-backup (concept) |
| **Geographic distribution** | Regions, availability zones, region pairs | Deploy in Central India region |

### IaaS vs PaaS vs SaaS (MUST KNOW)

| Model | You manage | Azure manages | Example |
|-------|-----------|---------------|---------|
| **IaaS** | OS, runtime, app, data | Hardware, network, virtualization | Azure Virtual Machines |
| **PaaS** | App + data | OS, runtime, infrastructure | **Container Apps, Spring Apps, Azure SQL** |
| **SaaS** | Data, access | Everything else | Microsoft 365, Gmail |

**auth-service:** Runs on **PaaS** (Container Apps / Spring Apps). Database on **PaaS** (Azure PostgreSQL).

### Exam tip
> "Which model gives you most control?" → **IaaS**  
> "Which requires least management?" → **SaaS**  
> "Best for developers deploying apps without managing servers?" → **PaaS**

---

## 1.2 Benefits of cloud computing

| Benefit | Explanation | Example |
|---------|-------------|---------|
| **High availability** | SLA-backed uptime (99.9%+) | App stays up if one node fails |
| **Scalability** | Handle traffic spikes | Black Friday login surge |
| **Elasticity** | Auto scale down to save cost | Night-time scale to 1 replica |
| **Agility** | Deploy in minutes vs weeks | `az deployment` or portal click |
| **Geo-distribution** | Deploy close to users | India region for Indian users |
| **Disaster recovery** | Cross-region failover | Secondary region standby |
| **Capital expenditure (CapEx)** | Upfront hardware cost | Buying servers = CapEx |
| **Operational expenditure (OpEx)** | Pay as you go | Azure PAYG = OpEx |
| **Consumption-based model** | Pay only for what you use | Delete RG = stop billing |

### Exam tip
> Cloud shifts **CapEx → OpEx**

---

## 1.3 Cloud service models comparison

```
Responsibility stack:

YOU manage ▲
           │  Applications & Data        ← always yours
           │  Runtime
           │  Middleware
           │  O/S
           │  Virtualization
           │  Servers
           │  Storage
           │  Networking
AZURE      ▼

IaaS:  you manage from O/S up
PaaS:  you manage app + data only
SaaS:  you manage data/access only
```

---

## 1.4 Public, private, and hybrid cloud

| Model | Description | When |
|-------|-------------|------|
| **Public cloud** | Azure, AWS, GCP — shared infrastructure | Most apps, startups, learning |
| **Private cloud** | Dedicated cloud on-premises or hosted | Strict compliance, legacy |
| **Hybrid cloud** | Connect public + private | Enterprise gradual migration |

**Azure hybrid tools:** Azure Arc, Azure Stack, ExpressRoute, VPN Gateway

---

## 1.5 Consumption-based model & pricing concepts

| Concept | Explanation |
|---------|-------------|
| **Pay-as-you-go** | No upfront cost, billed monthly |
| **Reserved instances** | 1–3 year commit, up to 72% savings |
| **Spot instances** | Unused capacity, cheap, can be evicted |
| **Azure Free Account** | $200 credit, 30 days, 12-month free services |
| **TCO Calculator** | Compare on-prem cost vs Azure |
| **Pricing Calculator** | Estimate Azure service costs |

---

### Domain 1 — Practice questions

1. What cloud model does Azure Container Apps represent? → **PaaS**
2. CapEx vs OpEx — cloud is primarily? → **OpEx**
3. Scale out vs scale up? → **Out = more instances, Up = bigger machine**
4. What is elasticity? → **Auto scale based on demand**
5. Shared responsibility in PaaS — who manages the OS? → **Azure**

### Domain 1 — Microsoft Learn modules
- [Describe cloud computing](https://learn.microsoft.com/training/modules/describe-cloud-compute/)
- [Describe benefits of cloud services](https://learn.microsoft.com/training/modules/describe-benefits-use-cloud-services/)
- [Describe cloud service types](https://learn.microsoft.com/training/modules/describe-cloud-service-types/)

**✅ Checkpoint:** Score 80%+ on Domain 1 practice questions before moving on.

---

# DOMAIN 2 — Describe Azure Architecture & Services (35–40%)

## 2.1 Azure architecture components

### Hierarchy (MUST KNOW — frequently tested)

```
Management Group (optional, enterprise)
    └── Subscription (billing boundary)
            └── Resource Group (lifecycle boundary)
                    └── Resources (VM, DB, App, etc.)
```

| Component | Purpose | auth-service example |
|-----------|---------|---------------------|
| **Management group** | Organize multiple subscriptions | `Learning`, `Production` |
| **Subscription** | Billing unit, access boundary | Company Azure subscription |
| **Resource group** | Logical container, delete together | `rg-arun-learning-dev` |
| **Resource** | Individual Azure service | Container App, PostgreSQL |

### Regions & availability

| Concept | Explanation |
|---------|-------------|
| **Region** | Geographic area (Central India, East US) |
| **Availability Zone** | Separate datacenters within region (1, 2, 3) |
| **Region pair** | Cross-region DR (India Central ↔ India South) |
| **Sovereign regions** | Government clouds (Azure Government) |
| **Latency** | Choose region closest to users |

### Exam tip
> Resource groups are **regional** (metadata) but contain resources from **any region**  
> Delete resource group = delete **all** resources inside

---

## 2.2 Azure compute services

| Service | Type | Use case | auth-service |
|---------|------|----------|--------------|
| **Virtual Machines** | IaaS | Full control, lift-and-shift | Overkill for your app |
| **VM Scale Sets** | IaaS | Auto-scaling VMs | Legacy apps |
| **App Service** | PaaS | Web apps, APIs (no containers) | Alternative to Container Apps |
| **Container Instances (ACI)** | PaaS | Simple containers, no orchestration | Quick tests |
| **Container Apps** | PaaS | Microservices, serverless containers | **Your deploy target** |
| **Azure Spring Apps** | PaaS | Spring Boot optimized | **Week 11 lab** |
| **AKS (Kubernetes)** | PaaS | Full Kubernetes control | Large microservice estates |
| **Azure Functions** | Serverless | Event-driven, short tasks | Send email on register |
| **Batch** | PaaS | Large-scale parallel jobs | Not relevant |

### Comparison (interview + exam)

| Need | Choose |
|------|--------|
| Simple web API, no containers | App Service |
| Docker microservice, simple | **Container Apps** |
| Spring Boot Java app | **Spring Apps** |
| Full Kubernetes | AKS |
| Run code on event trigger | Azure Functions |
| Full OS control | Virtual Machines |

---

## 2.3 Azure networking services

| Service | Purpose | auth-service |
|---------|---------|--------------|
| **Virtual Network (VNet)** | Private network in Azure | Isolate backend services |
| **Subnet** | Segment within VNet | App subnet, DB subnet |
| **Network Security Group (NSG)** | Firewall rules (allow/deny ports) | Allow 8080, block rest |
| **Application Gateway** | Layer 7 LB + WAF | **Week 9–10 lab** |
| **Azure Load Balancer** | Layer 4 load balancing | Distribute traffic |
| **Azure Front Door** | Global CDN + WAF | Global apps |
| **VPN Gateway** | Hybrid cloud connectivity | Office ↔ Azure |
| **ExpressRoute** | Private dedicated connection | Enterprise |
| **Azure DNS** | Host DNS zones | `auth.mycompany.com` |
| **Private Endpoint** | Private access to PaaS services | DB not on public internet |
| **Service Endpoints** | VNet → Azure service traffic | Secure DB connection |

### Exam tip
> **NSG** = port/IP rules  
> **Application Gateway** = HTTP routing + WAF (Layer 7)  
> **Load Balancer** = TCP/UDP (Layer 4)  
> **Front Door** = global, **App Gateway** = regional

---

## 2.4 Azure storage services

| Service | Purpose | Type |
|---------|---------|------|
| **Blob Storage** | Objects: files, images, backups | Hot, Cool, Archive tiers |
| **Azure Files** | Managed file shares (SMB) | Shared drives |
| **Azure Queue Storage** | Simple message queue | Basic async |
| **Table Storage** | NoSQL key-value | Simple structured data |
| **Disk Storage** | VM disks (OS + data) | Managed/unmanaged |
| **Data Lake Storage** | Big data analytics | Hadoop compatible |

### Blob tiers (exam favorite)

| Tier | Access | Cost | Use |
|------|--------|------|-----|
| **Hot** | Frequent | Higher storage, lower access | Active data |
| **Cool** | Infrequent (30+ days) | Lower storage, higher access | Backups |
| **Archive** | Rare (180+ days) | Cheapest storage, highest retrieval | Long-term retention |

### Redundancy options (MUST KNOW)

| Option | Copies | Protection |
|--------|--------|------------|
| **LRS** | 3 in one datacenter | Local hardware failure |
| **ZRS** | 3 across availability zones | Datacenter failure |
| **GRS** | 6 (3 primary + 3 secondary region) | Regional disaster |
| **GZRS** | ZRS + geo-replication | Zone + regional disaster |

---

## 2.5 Azure database services

| Service | Type | Use case | auth-service |
|---------|------|----------|--------------|
| **Azure SQL Database** | Relational (SQL Server) | .NET apps, T-SQL | Alternative to PostgreSQL |
| **Azure Database for PostgreSQL** | Relational (open source) | Java/Spring apps | **Your DB choice** |
| **Azure Database for MySQL** | Relational (open source) | PHP, WordPress | — |
| **Azure Cosmos DB** | NoSQL (global) | Globally distributed, multi-model | User sessions at scale |
| **Azure Cache for Redis** | In-memory cache | Token blacklist, sessions | **Your Redis** |
| **Azure Synapse Analytics** | Data warehouse | Big data analytics | — |
| **Azure Database Migration Service** | Migration tool | On-prem → Azure DB | — |

### Exam tip
> PostgreSQL on Azure = **PaaS managed database** (not a VM you manage)  
> Cosmos DB = **globally distributed NoSQL**, 99.999% SLA option

---

## 2.6 Azure identity & security

### Microsoft Entra ID (formerly Azure Active Directory)

| Concept | Explanation |
|---------|-------------|
| **Entra ID** | Cloud identity service (users, groups, SSO) |
| **Tenant** | Entra ID instance (your organization) |
| **User** | Individual account |
| **Group** | Collection of users for RBAC |
| **Service Principal** | Identity for apps/automation |
| **Managed Identity** | Azure-managed identity for resources |
| **SSO** | Single sign-on across apps |
| **MFA** | Multi-factor authentication |

### Security services

| Service | Purpose | auth-service |
|---------|---------|--------------|
| **Microsoft Defender for Cloud** | Security posture, threat protection | Security score |
| **Key Vault** | Secrets, keys, certificates | **JWT secret, DB password** |
| **Azure DDoS Protection** | DDoS attack mitigation | Protect public endpoints |
| **Azure Firewall** | Managed network firewall | VNet traffic filtering |
| **Azure Sentinel / SIEM** | Security information & event management | Enterprise SOC |

### Defense in depth (exam favorite)

```
Layer 1: Physical security (datacenter)
Layer 2: Identity & access (Entra ID, RBAC)
Layer 3: Perimeter (DDoS, Firewall)
Layer 4: Network (NSG, VNet)
Layer 5: Compute (VM security, patches)
Layer 6: Application (Spring Security, OAuth)
Layer 7: Data (encryption at rest + in transit)
```

**auth-service spans layers 2, 6, 7** (identity, app security, data encryption)

---

## 2.7 Azure integration & messaging

| Service | Pattern | auth-service |
|---------|---------|--------------|
| **Azure Service Bus** | Enterprise messaging (queues, topics) | **UserRegistered event** |
| **Azure Event Hubs** | Big data streaming (millions/sec) | Login analytics stream |
| **Azure Event Grid** | Event routing (reactive) | React to blob upload |
| **Azure API Management** | API gateway | **Rate limit /login** |
| **Azure Logic Apps** | Workflow automation (low-code) | Connect systems |
| **Azure Service Connector** | Connect app to services easily | Simplify bindings |

### Service Bus vs Event Hubs vs Event Grid (exam favorite)

| | Service Bus | Event Hubs | Event Grid |
|--|-------------|------------|------------|
| **Pattern** | Message queue/topic | Event streaming | Event routing |
| **Volume** | Medium | Very high | Medium |
| **Consumers** | Competing consumers | Multiple consumer groups | Subscribers |
| **Use** | Order processing | IoT, analytics | React to Azure events |
| **auth-service** | ✅ User events | Analytics | Blob triggers |

---

## 2.8 Azure monitoring services

| Service | Purpose | auth-service |
|---------|---------|--------------|
| **Azure Monitor** | Platform for metrics, logs, alerts | Foundation |
| **Application Insights** | APM — app performance monitoring | **Login latency, errors** |
| **Log Analytics** | Query logs (KQL) | Search error logs |
| **Azure Advisor** | Cost + security + reliability recommendations | Free optimization tips |
| **Service Health** | Azure platform outage notifications | "Is Azure down?" |
| **Azure Monitor Alerts** | Notify on metric thresholds | Alert on 5xx errors |

### Exam tip
> **Azure Monitor** = platform  
> **Application Insights** = application-level (requests, dependencies, exceptions)  
> **Log Analytics** = log query workspace  
> **Advisor** = free recommendations

---

### Domain 2 — Practice questions

1. What contains Azure resources for billing? → **Subscription**
2. Container Apps is IaaS or PaaS? → **PaaS**
3. Store JWT secrets securely? → **Key Vault**
4. Layer 7 load balancer with WAF? → **Application Gateway**
5. Globally distributed NoSQL? → **Cosmos DB**
6. Message queue for microservices? → **Service Bus**
7. Monitor Spring Boot app performance? → **Application Insights**
8. Blob storage cheapest tier? → **Archive**
9. GRS vs LRS? → **GRS = geo-redundant**
10. Managed identity purpose? → **App accesses Azure services without stored credentials**

### Domain 2 — Microsoft Learn modules
- [Describe Azure architecture and services](https://learn.microsoft.com/training/paths/az-900-describe-azure-architecture-services/)

**✅ Checkpoint:** Draw Azure hierarchy from memory. Name 3 compute, 3 database, 3 networking services.

---

# DOMAIN 3 — Describe Azure Management & Governance (30–35%)

## 3.1 Core management tools

| Tool | Purpose | When to use |
|------|---------|-------------|
| **Azure Portal** | Web GUI | Learning, visual management |
| **Azure CLI** | Command line (`az`) | Automation, scripts |
| **Azure PowerShell** | PowerShell cmdlets | Windows automation |
| **Azure Cloud Shell** | Browser-based CLI/PowerShell | Quick commands in portal |
| **Azure Mobile App** | Manage from phone | Monitoring on the go |
| **ARM Templates** | Infrastructure as Code (JSON) | Repeatable deployments |
| **Bicep** | IaC language (simpler than ARM) | **Your `main.bicep`** |
| **Azure Terraform** | Multi-cloud IaC | Multi-cloud shops |

### Exam tip
> **ARM** = Azure Resource Manager (deployment engine for all tools)  
> **Bicep** compiles to ARM JSON  
> All tools (portal, CLI, PowerShell) use ARM under the hood

---

## 3.2 Governance & compliance

| Tool | Purpose |
|------|---------|
| **Azure Policy** | Enforce rules (e.g. "only allow Central India region") |
| **Resource locks** | Prevent accidental delete/modify |
| **Tags** | Metadata labels (Owner, Environment, CostCenter) |
| **Management groups** | Organize subscriptions + apply policies |
| **Azure Blueprints** | Repeatable environment setup (policy + RBAC + resources) |
| **Compliance Manager** | Track regulatory compliance (GDPR, ISO) |

### Policy vs RBAC (exam favorite)

| | Azure Policy | RBAC |
|--|-------------|------|
| **Controls** | What resources can be created/configured | Who can access resources |
| **Example** | "Only allow B1ms SKU" | "Dev team can read, not delete" |
| **Evaluated** | Resource creation/update | API calls |

### Resource locks

| Lock type | Can do | Cannot do |
|-----------|--------|-----------|
| **CanNotDelete** | Read, modify | Delete |
| **ReadOnly** | Read only | Modify or delete |

---

## 3.3 Identity, access & RBAC

### RBAC roles (MUST KNOW)

| Role | Permissions |
|------|-------------|
| **Owner** | Full access + grant access to others |
| **Contributor** | Full access, cannot grant access |
| **Reader** | View only |
| **User Access Administrator** | Manage user access only |

**Custom roles:** Define specific permissions for least privilege

### RBAC structure
```
Security Principal (user, group, service principal)
    + Role (Owner, Contributor, Reader)
    + Scope (management group, subscription, RG, resource)
    = Access assignment
```

**auth-service example:**
- You = **Contributor** on `rg-arun-learning-dev`
- Container App managed identity = **Key Vault Secrets User** on Key Vault

### Zero Trust principles
- Verify explicitly
- Use least privilege access
- Assume breach

---

## 3.4 Azure cost management

| Tool | Purpose |
|------|---------|
| **Pricing Calculator** | Estimate costs before deploying |
| **TCO Calculator** | Compare on-prem vs cloud total cost |
| **Cost Management + Billing** | Track actual spend, budgets, alerts |
| **Azure Advisor** | Cost optimization recommendations |
| **Reservations** | Pre-pay 1–3 years for discount |
| **Azure Hybrid Benefit** | Use existing Windows/SQL licenses |

### Cost saving strategies (exam + real life)

| Strategy | Saving |
|----------|--------|
| Delete unused resources | 100% on those resources |
| Right-size VMs/SKUs | 20–50% |
| Reserved instances (1–3 yr) | Up to 72% |
| Spot VMs | Up to 90% (interruptible) |
| Auto-shutdown dev VMs | Night/weekend savings |
| Budget alerts | Prevent surprise bills |
| Tags for cost tracking | Visibility by team/project |

### Exam tip
> **Budget alerts** notify you — they do NOT stop resources automatically  
> **Tags** don't reduce cost — they help **track** cost

---

## 3.5 Service Level Agreements (SLAs)

| Concept | Explanation |
|---------|-------------|
| **SLA** | Guaranteed uptime percentage |
| **Composite SLA** | Multiply SLAs of dependent services |
| **Service Credits** | Refund if Azure misses SLA |

### Common SLAs (approximate)

| Service | SLA |
|---------|-----|
| Virtual Machines (single) | 99.9% |
| App Service | 99.95% |
| Azure SQL Database | 99.99% |
| Storage (GRS) | 99.99% |
| Cosmos DB (multi-region) | 99.999% |

### SLA calculation (exam favorite)
```
99.9%  = ~8.7 hours downtime/year
99.95% = ~4.4 hours downtime/year
99.99% = ~52 minutes downtime/year
```

**Composite SLA:** Two services at 99.9% each = 0.999 × 0.999 = **99.8%**

---

## 3.6 Cloud adoption framework & Well-Architected Framework

### Cloud Adoption Framework (CAF)
Stages: Strategy → Plan → Ready → Adopt → Govern → Manage

### Well-Architected Framework — 5 pillars

| Pillar | Focus | auth-service example |
|--------|-------|---------------------|
| **Reliability** | Recover from failures | Health checks, multi-replica |
| **Security** | Protect data and systems | Key Vault, OAuth, HTTPS |
| **Cost Optimization** | Minimize cost | Delete RG after labs, right SKU |
| **Operational Excellence** | Monitor, automate | CI/CD, App Insights |
| **Performance Efficiency** | Scale to meet demand | Container Apps auto-scale |

---

### Domain 3 — Practice questions

1. Prevent accidental deletion of production RG? → **CanNotDelete lock**
2. Enforce "only East US region" rule? → **Azure Policy**
3. Who can create resources but not manage access? → **Contributor**
4. Estimate Azure costs before deploying? → **Pricing Calculator**
5. Compare on-prem vs cloud cost? → **TCO Calculator**
6. IaC tool native to Azure (simpler than JSON)? → **Bicep**
7. Two services 99.9% SLA composite? → **99.8%**
8. Tag purpose? → **Organize and track resources/cost**
9. Policy vs RBAC? → **Policy = what can be done, RBAC = who can do it**
10. Free cost optimization recommendations? → **Azure Advisor**

### Domain 3 — Microsoft Learn modules
- [Describe Azure management and governance](https://learn.microsoft.com/training/paths/az-900-describe-azure-management-governance/)

**✅ Checkpoint:** Explain RBAC vs Policy. Calculate composite SLA. List 3 cost-saving strategies.

---

# EXAM PREPARATION

## Free study resources

| Resource | URL |
|----------|-----|
| **Microsoft Learn path** | [AZ-900 learning path](https://learn.microsoft.com/training/paths/az-900-describe-cloud-concepts/) |
| **Practice assessment** | End of each Learn module |
| **Microsoft Official Practice Test** | [MeasureUp / Certiport](https://learn.microsoft.com/credentials/certifications/exams/az-900/) |
| **Azure free account** | [azure.microsoft.com/free](https://azure.microsoft.com/free/) |
| **Azure docs** | [learn.microsoft.com/azure](https://learn.microsoft.com/azure/) |

## Study schedule (4 weeks)

| Week | Focus | Hours | Activity |
|------|-------|-------|----------|
| 1 | Domain 1 — Cloud concepts | 6 hrs | Learn modules + flashcards |
| 2 | Domain 2a — Compute, Network, Storage | 8 hrs | Learn + portal exploration |
| 3 | Domain 2b — DB, Identity, Messaging + Domain 3 | 8 hrs | Learn + auth-service mapping |
| 4 | Practice exams + weak areas | 6 hrs | 2 practice exams, review misses |
| **Exam** | Schedule on Pearson VUE | — | [Schedule exam](https://learn.microsoft.com/credentials/certifications/exams/az-900/) |

## Exam day tips

1. **Read questions carefully** — "which is LEAST expensive", "which is NOT"
2. **Eliminate wrong answers** — IaaS vs PaaS confusion is common trap
3. **Know comparisons** — Service Bus vs Event Hubs, APIM vs App Gateway, Monitor vs App Insights
4. **SLA math** — composite SLA = multiply
5. **RBAC vs Policy** — comes up every exam
6. **Time:** 60 min for ~50 questions = ~1 min each, flag and return

---

# Map AZ-900 topics → auth-service project

Use your project to **remember** concepts:

| AZ-900 topic | See it in auth-service |
|--------------|------------------------|
| PaaS | Container Apps runs your app |
| Resource group | `rg-arun-learning-dev` |
| Subscription | Office Azure subscription |
| Key Vault | JWT + DB secrets |
| Application Insights | Login monitoring |
| Service Bus | UserRegistered event (Week 7) |
| API Management | Rate limit login (Week 5) |
| RBAC | You = Contributor on RG |
| Azure Policy | "Only allow Central India" |
| CI/CD concept | GitHub Actions pipeline |
| CapEx vs OpEx | PAYG = OpEx |
| SLA | Container Apps 99.95%+ |
| Bicep | `azure/main.bicep` in your repo |
| Well-Architected | Security pillar = OAuth + Key Vault |

---

# Flashcard quick reference

```
IaaS    = VM (you manage OS+)
PaaS    = Container Apps, Spring Apps, Azure SQL
SaaS    = Microsoft 365

LRS     = local redundancy
GRS     = geo-redundant
ZRS     = zone-redundant

Owner       = full + grant access
Contributor = full, no grant
Reader      = view only

Monitor         = platform metrics/logs
App Insights    = application APM
Advisor         = free recommendations
Service Health  = Azure outages

Service Bus  = enterprise messaging
Event Hubs   = big data streaming
Event Grid   = event routing

APIM            = API gateway (Layer 7 policies)
App Gateway     = load balancer + WAF (Layer 7)
Load Balancer   = Layer 4
Front Door      = global CDN + WAF

Policy = what is allowed (resources)
RBAC   = who is allowed (users)

Hot tier    = frequent access
Cool tier   = infrequent
Archive     = rare, cheapest

CapEx = upfront hardware
OpEx  = pay as you go
```

---

# After AZ-900 — what's next

| Certification | Focus | When |
|---------------|-------|------|
| **AZ-204** | Azure Developer (Java, deploy, integrate) | After Week 8 of SDLC roadmap |
| **AZ-305** | Azure Solutions Architect | Senior role |
| **AZ-400** | DevOps Engineer | CI/CD focus |

**AZ-900 + AZ-204 + auth-service GitHub repo = strong junior/mid Azure Java developer profile**

---

*Study 30 minutes daily. Map every concept to auth-service. Pass AZ-900 in 4 weeks.*
