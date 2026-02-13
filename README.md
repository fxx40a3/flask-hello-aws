
# Flask → Docker → GitHub Actions → AWS EC2 (Ubuntu) 

Minimal, working CI/CD starter that builds a Docker image, pushes it to Docker Hub, then deploys to an EC2 instance via SSH and `docker compose`.

## Files
- `app.py` – simple Flask Hello World
- `requirements.txt` – Flask + Gunicorn
- `Dockerfile` – production-ready container
- `docker-compose.yml` – runs the container on EC2 (port 80 → 5000)
- `.github/workflows/deploy.yml` – CI/CD pipeline
- `.dockerignore`

## 1) EC2 one-time setup (Ubuntu)
SSH into EC2 (replace IP if needed):
```bash
ssh -i flask-hello-aws-cicd.pem ubuntu@13.158.55.37
```
Install Docker and compose plugin:
```bash
sudo apt update -y
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |           sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
exit
# reconnect
ssh -i flask-hello-aws-cicd.pem ubuntu@13.158.55.37
```
Prepare the compose folder on EC2:
```bash
mkdir -p ~/app && cd ~/app
# place docker-compose.yml here (already included in this repo)
```
Ensure the security group allows inbound HTTP 80.

## 2) Docker Hub
Create (or confirm) a repo named `fxx40a3/flask-hello-aws`. Public is easiest.

## 3) GitHub repository secrets
In **Settings → Secrets and variables → Actions** add:
- `DOCKERHUB_USERNAME` = `fxx40a3`
- `DOCKERHUB_TOKEN` = *Docker Hub Access Token*
- `EC2_HOST` = `13.158.55.37`
- `EC2_USER` = `ubuntu`
- `EC2_SSH_KEY` = *contents of your PEM private key*

## 4) Push to main → auto-deploy
Commit & push to `main`. The workflow will:
1. Build & push `fxx40a3/flask-hello-aws:latest`
2. SSH to EC2 and run `docker compose pull && docker compose up -d`

Visit: `http://13.158.55.37/`

## Manual first push (optional)
If you want to push once manually:
```bash
docker login
docker build -t fxx40a3/flask-hello-aws:latest .
docker push fxx40a3/flask-hello-aws:latest
# then on EC2
ssh -i flask-hello-aws-cicd.pem ubuntu@13.158.55.37
cd ~/app && docker compose pull && docker compose up -d
```
