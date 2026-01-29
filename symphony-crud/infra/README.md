# Symphony CRUD - Cloud Run Deployment

## Przegląd
Infrastruktura dla wdrożenia aplikacji Symfony na Google Cloud Run z użyciem Terraforma.

**Wersja bez bazy danych** - aplikacja zwraca tylko dummy data z endpoint GET /offers.

## Wymagania
- Terraform >= 1.0
- gcloud CLI
- Docker
- Dostęp do GCP projekt: `smart-quasar-485417-f4`

## Konfiguracja

### 1. Przygotowanie zmiennych globalnych
Zmienne są automatycznie ładowane przez symlink `global.auto.tfvars` → `../../global/terraform.tfvars`

### 2. Enable wymaganych API w GCP
```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com
```

### 3. Uwierzytelnienie Docker z Artifact Registry
```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

## Deployment

### Krok 1: Build i push obrazu Docker
```bash
cd ../services

# Build obrazu produkcyjnego
docker build --target prod -t us-central1-docker.pkg.dev/smart-quasar-485417-f4/symphony-crud/symphony-crud:latest .

# Push do Artifact Registry
docker push us-central1-docker.pkg.dev/smart-quasar-485417-f4/symphony-crud/symphony-crud:latest
```

### Krok 2: Deploy infrastruktury Terraform
```bash
cd ../infra

# Inicjalizacja Terraform
terraform init

# Plan zmian
terraform plan

# Apply zmian
terraform apply
```

### Krok 3: Weryfikacja
Po pomyślnym wdrożeniu, Terraform wyświetli URL serwisu:
```bash
terraform output service_url
```

Test endpoint:
```bash
curl $(terraform output -raw service_url)/offers
```

Oczekiwany wynik: JSON z 2 dummy offers.

## Aktualizacja aplikacji

1. Wprowadź zmiany w kodzie aplikacji
2. Zbuduj nowy obraz Docker z tym samym tagiem
3. Push obrazu do Artifact Registry
4. Cloud Run automatycznie użyje nowego obrazu przy następnym wdrożeniu lub:
```bash
terraform apply -replace="google_cloud_run_v2_service.symphony_crud"
```

## Koszty
- **Artifact Registry**: $0.10/GB/miesiąc (~$0.10 dla małej aplikacji)
- **Cloud Run**: 
  - Free tier: 2M requestów/miesiąc
  - 0 min instances = $0 gdy nie używane
  - Pay-per-use: ~$0.00002400 per request

**Szacunek miesięczny**: ~$0-1 dla lekkiego testowania

## Zasoby utworzone przez Terraform
- `google_artifact_registry_repository.symphony_crud` - repozytorium Docker
- `google_cloud_run_v2_service.symphony_crud` - serwis Cloud Run (0-10 instancji)
- `google_cloud_run_v2_service_iam_member.public_access` - publiczny dostęp bez autoryzacji

## Struktura
```
symphony-crud/
├── services/           # Kod aplikacji Symfony
│   ├── src/
│   ├── Dockerfile     # Multi-stage build (dev/prod)
│   └── .gcloudignore  # Pliki ignorowane przy deployu
└── infra/             # Terraform IaC
    ├── main.tf        # Cloud Run + Artifact Registry
    ├── variables.tf   # Zmienne wejściowe
    ├── outputs.tf     # URL serwisu i inne outputy
    └── global.auto.tfvars → ../../global/terraform.tfvars
```

## Troubleshooting

### Problem: Artifact Registry nie istnieje
```bash
terraform import google_artifact_registry_repository.symphony_crud \
  projects/smart-quasar-485417-f4/locations/us-central1/repositories/symphony-crud
```

### Problem: Permission denied podczas push obrazu
```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
gcloud auth login
```

### Problem: Cloud Run nie startuje kontenera
Sprawdź logi:
```bash
gcloud run services logs read symphony-crud --region us-central1
```

## Następne kroki (opcjonalne)
- Dodanie Cloud SQL PostgreSQL dla persystencji danych
- CI/CD pipeline z Cloud Build
- Monitoring i alerty
- Custom domain i SSL

