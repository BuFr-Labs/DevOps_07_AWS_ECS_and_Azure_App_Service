# DevOps_07_AWS_ECS_and_Azure_App_Service
Repozitoř k 7. lekci

# DevOps Úkol 07: Automatizované nasazení ECS Fargate pomocí Terraformu a GitHub Actions

Tento repozitář obsahuje řešení domácího úkolu zaměřeného na automatizaci nasazení kontejnerizované aplikace Nginx do AWS služby ECS Fargate s využitím CI/CD pipeline v GitHub Actions.

## 🎯 Cíle projektu
* Automatické vytvoření AWS ECS Fargate clusteru a příslušné služby (Service).
* Nasazení oficiálního Docker obrazu `nginx:alpine` do bezserverového (serverless) prostředí.
* Vytvoření veřejně dostupného Application Load Balanceru (ALB) pro distribuci provozu.
* Dynamické načtení existující výchozí VPC a veřejných podsítí (public subnets) pomocí `data` bloků.
* Konfigurace dvojí úrovně zabezpečení pomocí Security Groups (ALB přístupný z internetu, ECS tasky přístupné výhradně z ALB).
* Nastavení centrálního sběru logů do služby AWS CloudWatch Log Group s retencí 7 dní.
* Kompletní automatizace celého lifecycle prostředí pomocí GitHub Actions workflow.

## 📂 Struktura projektu
Projekt striktně dodržuje modulární rozdělení podle "Best Practices" pro Terraform a CI/CD:

* `.github/workflows/deploy.yml` - Definice GitHub Actions pipeline (autentizace do AWS, inicializace, validace a automatické nasazení).
* `providers.tf` - Konfigurace AWS providera a vzdáleného ukládání stavu (S3 Backend).
* `variables.tf` - Definice vstupních proměnných (AWS region, project prefix).
* `network.tf` - Data zdroje pro vyhledání a využití výchozí síťové infrastruktury v AWS.
* `security.tf` - Definice bezpečnostních skupin pro striktní řízení síťového provozu.
* `alb.tf` - Konfigurace Application Load Balanceru, Target Groupy a HTTP Listeneru.
* `iam.tf` - Definice IAM role a politik pro správné provádění a exekuci ECS tasků.
* `ecs.tf` - Hlavní definice ECS Clusteru, CloudWatch Log Groupy, Task Definition a ECS Service.
* `outputs.tf` - Výstupní parametry obsahující čisté DNS a kompletní URL pro test aplikace.

## 🚀 Návod k použití

### 1. Prerekvizity
* Vytvořený S3 bucket v AWS pro ukládání stavového souboru (`tfstate-bufr-devops-ukol7`).
* Nastavené GitHub Secrets v repozitáři pro bezpečnou autentizaci pipeline:
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`

### 2. Spuštění a automatické nasazení
Pipeline se spouští automaticky při každém pushnutí kódu do větve `main`.
```bash
git add .
git commit -m "feat: inicialni nasazeni ECS Fargate infrastruktury"
git push origin main
```

Průběh a logy z provádění příkazů terraform init, terraform validate a terraform apply lze sledovat živě v záložce Actions ve tvém GitHub repozitáři.

### 3. Ověření funkčnosti
Po úspěšném doběhnutí pipeline vypíše krok Test Application a Outputs unikátní URL adresu Load Balanceru. Aplikaci lze ověřit v prohlížeči nebo pomocí terminálu:

```Bash
curl http://my-ecs-demo-alb-361138232.eu-central-1.elb.amazonaws.com
```

Výstupem úspěšného ověření je standardní uvítací stránka Nginx prostředí.

### 4. Úklid infrastruktury (Cleanup)
Pro zamezení zbytečných nákladů v AWS za běžící Application Load Balancer a Fargate zdroje je nutné po otestování celou infrastrukturu smazat lokálně z terminálu tvé virtuálky:

```Bash
terraform destroy
```

### Bezpečnost
Veškeré přístupové klíče k AWS jsou uloženy striktně v GitHub Secrets a nikdy se nenechávají v kódu. Soubory místního stavu a pomocné adresáře Terraformu (.terraform/, *.tfstate, terraform.tfvars) jsou zapsány v .gitignore, aby nedošlo k jejich nechtěnému pushnutí na server.