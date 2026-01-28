# UMK Lectures - Runtime Test Projects

Repozytorium zawiera wiele pod-projektów testowych z różnymi rozwiązaniami chmury (GCP).

## Struktura projektu

```
global/                      # Wspólne ustawienia Terraform (project, region)
  ├── variables.tf
  └── terraform.tfvars

hello-function/              # Pierwszy projekt: prosta Cloud Function
  ├── services/              # Kod aplikacji
  │   ├── main.py
  │   └── requirements.txt
  ├── infra/                 # Infrastruktura Terraform
  │   ├── main.tf
  │   ├── variables.tf
  │   ├── outputs.tf
  │   └── terraform.tfvars
  └── README.md

symphony-crud/               # Drugi projekt (przyszły)
  ├── services/
  ├── infra/
  └── README.md
```

## Wymagania

- Terraform >= 1.0
- Konto GCP z włączonym billingiem
- `gcloud` CLI z autoryzacją: `gcloud auth application-default login`

## Konfiguracja globalna

Ustaw zmienne globalne w `global/terraform.tfvars`:

```hcl
project = "your-gcp-project-id"
region  = "us-central1"
```

## Tworzenie nowego projektu

Szablon struktury dla nowego projektu:

```bash
# Przykład: nowy projekt symphony-crud
mkdir -p symphony-crud/{services,infra}

# Utwórz symlink do globalnych zmiennych
cd symphony-crud/infra
ln -s ../../global/terraform.tfvars global.auto.tfvars

# Dodaj pliki Terraform (main.tf, variables.tf, outputs.tf)
# Dodaj kod aplikacji w services/
# Utwórz README.md
```

## Uruchamianie projektu

Każdy pod-projekt uruchamia się osobno. Zobacz README w odpowiednim folderze projektu.

## Projekty

### 1. hello-function
Prosta Cloud Function HTTP zwracająca "Hello, World!". Zobacz [hello-function/README.md](hello-function/README.md).

### 2. symphony-crud (w przygotowaniu)
CRUD API dla operacji danych.
