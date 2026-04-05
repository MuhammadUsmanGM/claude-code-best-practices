# Cloud Platform Integration

Claude Code works with any cloud platform you can control from the terminal. This guide covers practical patterns for using Claude Code with AWS, GCP, Azure, serverless frameworks, Docker, and Kubernetes -- from local development to production deployment workflows.

## General Principles

- **Claude Code operates through your CLI tools.** It uses `aws`, `gcloud`, `az`, `kubectl`, `terraform`, and other CLIs you have installed. Make sure they are authenticated and configured before starting a session.
- **Document your cloud setup in CLAUDE.md.** Tell Claude which cloud provider you use, which regions, and which CLI tools are available.
- **Use plan mode for infrastructure changes.** Cloud operations can be expensive or irreversible. Always review plans before applying.

### CLAUDE.md cloud context example

```markdown
## Infrastructure

- Cloud: AWS (us-east-1)
- IaC: Terraform in infra/ directory
- Container registry: ECR at 123456789.dkr.ecr.us-east-1.amazonaws.com
- Kubernetes: EKS cluster "production" (kubectl configured)
- CI/CD: GitHub Actions deploys to staging on merge to main
- Serverless: Lambda functions in lambdas/ directory, deployed via SAM
```

## AWS Patterns

### Working with Lambda functions

```
Review the Lambda function in lambdas/process-orders/. Check the handler,
IAM permissions in the SAM template, and environment variables. Identify
any issues with cold start performance or error handling.
```

```
Add a new Lambda function that processes S3 upload events. It should
validate the uploaded file, transform it, and write the result to DynamoDB.
Add the function to the SAM template with appropriate IAM permissions.
```

### Infrastructure as Code with Terraform

```
Review the Terraform configuration in infra/. List all resources being
created, check for security misconfigurations (open security groups,
unencrypted storage, overly broad IAM policies), and suggest improvements.
```

```
Add a new RDS PostgreSQL instance to the Terraform config. Use the
existing VPC and subnet group. Enable encryption at rest, automated
backups, and Multi-AZ for the production workspace.
```

### Debugging with CloudWatch

```
I'm getting 5xx errors on the /api/orders endpoint. Here is the
CloudWatch log group name: /aws/lambda/process-orders. Help me
write a CloudWatch Insights query to find the error patterns, then
fix the root cause in the Lambda handler.
```

## GCP Patterns

### Cloud Functions and Cloud Run

```
Create a new Cloud Run service for the image processing API in
services/image-processor/. Write the Dockerfile, cloudbuild.yaml,
and the service.yaml for deployment. Use the existing Artifact Registry
for the container image.
```

### BigQuery integration

```
Write a data pipeline that exports user analytics from our PostgreSQL
database to BigQuery. Create the BigQuery schema, write the export
script, and add it as a Cloud Scheduler job that runs daily at 2 AM UTC.
```

## Azure Patterns

### Azure Functions

```
Migrate the Express.js webhook handler in src/webhooks/ to an Azure
Function. Keep the same request/response contract. Add the function
configuration, host.json, and local.settings.json for development.
```

### Azure DevOps integration

```
Write an Azure Pipelines YAML file that builds, tests, and deploys
this .NET service to Azure App Service. Include staging and production
environments with manual approval gates for production.
```

## Serverless Framework Patterns

### SAM (AWS)

```
Add a new API Gateway endpoint backed by a Lambda function. The endpoint
should accept POST /api/webhooks, validate the payload signature, and
queue the event in SQS for async processing. Update template.yaml with
all required resources.
```

### Serverless Framework

```
Review the serverless.yml configuration. Check for:
- Functions with timeout > 30s that should be Step Functions instead
- Missing dead letter queues on async functions
- Security group configurations that are too open
- Missing CloudWatch alarms for error rates
```

## Docker and Container Workflows

### Writing Dockerfiles

```
Write a production Dockerfile for this Node.js API. Use multi-stage builds,
run as non-root, minimize image size, and handle signals properly for
graceful shutdown. Follow the existing patterns in the other Dockerfiles
in this repo.
```

### Docker Compose for local development

```
Create a docker-compose.yml for local development that runs:
- The API server with hot reload
- PostgreSQL with seed data
- Redis for caching
- LocalStack for S3 and SQS emulation
Ensure all services can communicate and the API connects to local
versions of cloud services.
```

### Debugging containers

```
The API container keeps crashing with exit code 137 (OOM killed).
Review the Dockerfile and the application code for memory issues.
Check if the memory limit in docker-compose.yml is appropriate for
the workload.
```

## Kubernetes Patterns

### Writing manifests

```
Create Kubernetes manifests for deploying this service:
- Deployment with 3 replicas, resource limits, health checks, and
  graceful shutdown
- Service (ClusterIP)
- HorizontalPodAutoscaler (target 70% CPU)
- ConfigMap for non-secret configuration
- Use the existing namespace and service account patterns from k8s/
```

### Helm charts

```
Convert the raw Kubernetes manifests in k8s/ into a Helm chart.
Parameterize the image tag, replica count, resource limits, and
environment-specific values. Create values files for staging and
production.
```

### Debugging pods

```
Pods for the order-service are in CrashLoopBackOff. Help me debug:
1. What kubectl commands should I run to get logs and events?
2. Review the deployment manifest for configuration issues
3. Check the health check endpoints in the application code
```

## Terraform Workflows

### Planning and reviewing

Always use plan mode for Terraform work:

```
Review the Terraform changes I am about to apply. Run terraform plan
and analyze the output. Flag any destructive changes (resource deletions
or replacements), security concerns, or cost implications.
```

### Module development

```
Create a reusable Terraform module for provisioning an ECS Fargate service.
Inputs: service name, container image, port, CPU/memory, VPC ID, subnet IDs.
Outputs: service URL, log group name, task definition ARN. Follow the
module structure conventions in modules/.
```

### State management

```
We need to import an existing S3 bucket into Terraform state. Write the
resource block that matches the current bucket configuration, then give
me the terraform import command to run. Do not run it -- I will execute
it manually.
```

## Cost-Aware Cloud Prompting

Cloud operations can incur real costs. Use these patterns to stay safe:

- **Always ask for plans first.** "Show me the terraform plan" before "apply it."
- **Request cost estimates.** "How much will this RDS instance cost per month in us-east-1?"
- **Use dry-run flags.** `--dry-run` for kubectl, `plan` for Terraform, `--dryrun` for AWS CLI.
- **Restrict Claude's tools.** Use `--allowedTools` to limit Claude to read-only operations when exploring infrastructure.
- **Never give Claude production credentials interactively.** Use environment variables and scoped IAM roles.

## See Also

- [CI and Automation](ci-and-automation.md) -- Running Claude Code in CI/CD pipelines
- [Security Practices](security-practices.md) -- Managing credentials and access safely
- [CLAUDE.md Guide](claude-md-guide.md) -- Documenting your infrastructure context
- [Workflow Patterns](workflow-patterns.md) -- General workflow patterns that apply to cloud work
