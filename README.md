# DevOps_07_AWS_ECS_and_Azure_App_Service
Repozitoř k 7. lekci

# DevOps Ukol 07: Automatizovane nasazeni ECS Fargate pomoci Terraform a GitHub Actions

Tento repozitar obsahuje reseni domaciho ukolu zamereneho na automatizaci nasazeni kontejnerizovane aplikace Nginx do AWS sluzby ECS Fargate s vyuzitim CI/CD pipeline v GitHub Actions.

## 🎯 Cile projektu
* Automaticke vytvoreni AWS ECS Fargate clusteru a prislusne sluzby (Service).
* Nasazeni oficialniho Docker obrazu `nginx:alpine` do bezserveroveho (serverless) prostredi.
* Vytvoreni verejne dostupneho Application Load Balanceru (ALB) pro distribuci provozu.
* Dynamicke nacteni existujici vychozi VPC a public subnetu pomoci `data` bloku.
* Konfigurace dvoji urovne zabezpeceni pomoci Security Groups (ALB pristupny z internetu, ECS tasky pristupne vyhradne z ALB).
* Nastaveni centralniho sberu logu do sluzby AWS CloudWatch Log Group s retenci 7 dni.
* Kompletní automatizace celeho lifecycle prostredi pomoci GitHub Actions workflow.

## 📂 Struktura projektu
Projekt striktne dodrzuje modularni rozdeleni podle "Best Practices" pro Terraform a CI/CD:

* `.github/workflows/deploy.yml` - Definice GitHub Actions pipeline (autentizace do AWS, inicializace, validace a automaticky apply).
* `providers.tf` - Konfigurace AWS providera a vzdaleneho ukladani stavu (S3 Backend).
* `variables.tf` - Definice vstupnich promennych (AWS region, project prefix).
* `network.tf` - Data zdroje pro vyhledani a vyuziti vychozi sitove infrastruktury v AWS.
* `security.tf` - Definice bezpecnostnich skupin pro striktni rizeni sitoveho provozu.
* `alb.tf` - Konfigurace Application Load Balanceru, Target Groupy a HTTP Listeneru.
* `iam.tf` - Definice IAM role a politik pro spravne provadeni a exekuci ECS tasku.
* `ecs.tf` - Hlavni definice ECS Clusteru, CloudWatch Log Groupy, Task Definition a ECS Service.
* `outputs.tf` - Vystupni parametry obsahujici ciste DNS a kompletni URL pro test aplikace.

## 🚀 Navod k pouziti

### 1. Prerekvizity
* Vytvoreny S3 bucket v AWS pro ukladani stavoveho souboru (`tfstate-bufr-devops-ukol7`).
* Nastavene GitHub Secrets v repozitari pro bezpecnou autentizaci pipeline:
  * `AWS_ACCESS_KEY_ID`
  * `AWS_SECRET_ACCESS_KEY`

### 2. Spusteni a automaticke nasazeni
Pipeline se spousti automaticky pri kazdem pushnuti kodu do vetve `main`.
```bash
git add .
git commit -m "feat: inicialni nasazeni ECS Fargate infrastruktury"
git push origin main
```

Prubeh a logy z provadeni prikazu terraform init, validate a apply lze sledovat live v zalozce Actions ve tvem GitHub repozitari.


### 3. Overeni funkcnosti
Po uspesnem dobehnuti pipeline vypise krok Test Application a Outputs unikatni URL adresu Load Balanceru. Aplikaci lze overit v prohlizeci nebo pomoci terminalu:

```Bash
curl [http://my-ecs-demo-alb-XXXXXXXXX.eu-central-1.elb.amazonaws.com](http://my-ecs-demo-alb-XXXXXXXXX.eu-central-1.elb.amazonaws.com)
```

Vystupem uspesneho overeni je standardni uvitaci stranka Nginx prostredi.

### 4. Uklid infrastruktury (Cleanup)
Pro zamezeni zbytecnych nakladu v AWS za bezici Application Load Balancer a Fargate zdroje je nutne po otestovani celou infrastrukturu smazat lokalne z terminalu tve virtualky:

```Bash
terraform destroy
```

### Bezpecnost
Veskere pristupove klice k AWS jsou ulozeny striktne v GitHub Secrets a nikdy se nenechavaji v kodu. Soubory mistniho stavu a pomocne adresare Terraformu (.terraform/, *.tfstate, terraform.tfvars) jsou zapsany v .gitignore, aby nedoslo k jejich nechtenemu pushnuti na server.