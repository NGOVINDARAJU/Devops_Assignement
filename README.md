# AWS DevOps Engineer – Demo Assignment (Static Website Deployment)

## 🚀 Project Overview
This project demonstrates deploying a **static website** (index.html ) on **AWS** using **Terraform** for Infrastructure as Code (IaC) and **GitHub Actions** for CI/CD automation.  

Whenever code is pushed to the `main` branch, the pipeline automatically:
1. Uploads the updated website files to **Amazon S3**.
2. Invalidates the **CloudFront CDN cache**, ensuring changes go live instantly.

---

## 🏗️ Architecture

```mermaid
flowchart TD
    Dev[Developer Push to GitHub] -->|Trigger Workflow| GA[GitHub Actions CI/CD]
    GA -->|Sync Files| S3[(Amazon S3 Bucket)]
    S3 --> CF[Amazon CloudFront]
    CF --> User[End Users]

-> GitHub Actions: Automates build & deployment.
-> S3 Bucket: Stores static website files (index.html, assets).
->CloudFront: CDN to deliver content globally with HT


🛠️ Tech Stack
AWS Services:
S3 → static file hosting
CloudFront → CDN + HTTPS
IAM → secure roles & permissions
Infrastructure as Code (IaC):
Terraform → reproducible environments
CI/CD:
GitHub Actions → automated deployments

📂 Repository Structure
/app         → Static website files (index.html)
/iac         → Terraform code for S3 + CloudFront
/pipeline    → Deployment workflow (copy of GitHub Actions YAML)
/.github/workflows/deploy.yml → Actual GitHub Actions pipeline
README.md    → Documentation

⚙️ Setup & Deployment Steps
1️⃣ Infrastructure Setup (Terraform)
cd iac
terraform init
terraform apply -auto-approve

This provisions:
  S3 bucket
  CloudFront distribution
  IAM policies

Outputs:
  bucket_name
  cloudfront_domain

2️⃣ CI/CD Pipeline (GitHub Actions)
Add the following GitHub Secrets under
Settings → Secrets and variables → Actions:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET_NAME
CLOUDFRONT_ID

Workflow file: .github/workflows/deploy.yml
Whenever code is pushed to main, GitHub Actions will:
Upload files from /app to S3
Invalidate CloudFront cache

3️⃣ Access the Website

After deployment, open your CloudFront URL:
👉 https://d2ietkfisya7mf.cloudfront.net/

🔒 Security Best Practices
No hardcoded AWS credentials (using GitHub Secrets).
S3 bucket access restricted to CloudFront only.
HTTPS enforced via CloudFront.

📊 Monitoring & Logging
CloudFront Access Logs → can be enabled for monitoring traffic.
S3 Access Logs → optional for auditing requests.

