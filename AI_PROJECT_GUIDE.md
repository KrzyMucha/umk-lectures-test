# AI Assistant Guide: Tworzenie Nowego Projektu

Ten dokument zawiera instrukcje dla asystentów AI dotyczące tworzenia nowych pod-projektów w tym repozytorium.

## Struktura Repozytorium

Repozytorium zawiera wiele niezależnych pod-projektów GCP, które dzielą wspólne ustawienia Terraform.

```
global/                      # Współdzielone zmienne Terraform (project, region)
  ├── variables.tf
  └── terraform.tfvars

project-name/                # Każdy pod-projekt
  ├── services/              # Kod aplikacji (Python, Node.js, etc.)
  ├── infra/                 # Infrastruktura Terraform
  └── README.md
```

## Krok po Kroku: Tworzenie Nowego Projektu

### 1. Utwórz strukturę folderów

```bash
PROJECT_NAME="nazwa-projektu"  # np. "symphony-crud"
mkdir -p ${PROJECT_NAME}/{services,infra}
```

### 2. Utwórz symlink do globalnych zmiennych

```bash
cd ${PROJECT_NAME}/infra
ln -s ../../global/terraform.tfvars global.auto.tfvars
cd ../..
```

**Wyjaśnienie**: Symlink `global.auto.tfvars` jest automatycznie ładowany przez Terraform. Dzięki temu nie trzeba używać `-var-file=../../global/terraform.tfvars` przy każdym `terraform apply`.

### 3. Utwórz pliki Terraform w `infra/`

#### `infra/main.tf`
```hcl
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

# Tutaj dodaj zasoby GCP (Cloud Functions, Cloud Run, etc.)
```

#### `infra/variables.tf`
```hcl
# Zmienne globalne (project, region) są w ../../global/variables.tf
# Tutaj definiuj tylko zmienne specyficzne dla tego projektu

variable "project" {
  description = "GCP project ID (from global)"
  type        = string
}

variable "region" {
  description = "GCP region (from global)"
  type        = string
}

variable "service_name" {
  description = "Nazwa serwisu"
  type        = string
  default     = "nazwa-projektu-service"
}
```

#### `infra/outputs.tf`
```hcl
output "service_url" {
  description = "URL deployed service"
  value       = google_cloudfunctions_function.function.https_trigger_url  # przykład
}
```

#### `infra/terraform.tfvars`
```hcl
# Zmienne specyficzne dla projektu
# Globalne zmienne są automatycznie ładowane z global.auto.tfvars (symlink)
```

### 4. Utwórz folder build w infra

```bash
mkdir -p ${PROJECT_NAME}/infra/build
```

**Wyjaśnienie**: Folder `build/` jest używany do pakowania funkcji/kodu (np. ZIP). Jest ignorowany w `.gitignore`.

### 5. Dodaj kod aplikacji w `services/`

Przykład dla Cloud Function (Python):

#### `services/main.py`
```python
def main_function(request):
    """Entry point for the Cloud Function."""
    return "Hello from project!"
```

#### `services/requirements.txt`
```
functions-framework==3.*
# Dodaj inne zależności
```

### 6. Utwórz README.md projektu

```markdown
# Nazwa Projektu

Krótki opis projektu.

## Struktura

\`\`\`
nazwa-projektu/
├── services/           # Kod aplikacji
│   ├── main.py
│   └── requirements.txt
└── infra/             # Infrastruktura Terraform
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── build/
\`\`\`

## Wymagania

- Terraform >= 1.0
- GCP CLI z autoryzacją
- Python 3.9+ (lub inny runtime)

## Instalacja i deployment

### 1. Ustaw zmienne globalne

Edytuj \`../../global/terraform.tfvars\`:

\`\`\`hcl
project = "your-gcp-project-id"
region  = "us-central1"
\`\`\`

### 2. Deploy infrastruktury

\`\`\`bash
cd infra
terraform init
terraform apply
\`\`\`

### 3. Testowanie

Po deploye otrzymasz URL w outputach:

\`\`\`bash
curl $(terraform output -raw service_url)
\`\`\`

## Usuwanie

\`\`\`bash
cd infra
terraform destroy
\`\`\`
```

### 7. Aktualizuj główny README.md

Dodaj nowy projekt do listy w głównym [README.md](README.md):

```markdown
### X. nazwa-projektu
Krótki opis. Zobacz [nazwa-projektu/README.md](nazwa-projektu/README.md).
```

## Ważne Zasady

1. **Nie duplikuj zmiennych** - `project` i `region` są tylko w `global/`
2. **Używaj symlinka** - każdy projekt potrzebuje `infra/global.auto.tfvars` → `../../global/terraform.tfvars`
3. **Build w .gitignore** - folder `build/` jest ignorowany
4. **Relatywne ścieżki** - w Terraform używaj `${path.module}/../services` do odniesienia do kodu
5. **Niezależność** - każdy projekt działa niezależnie, ma własne `terraform.tfstate`

## Przykładowe użycie w Terraform

### Pakowanie Cloud Function

```hcl
data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../services"
  output_path = "${path.module}/build/function.zip"
}
```

### Odniesienie do globalnych zmiennych

```hcl
provider "google" {
  project = var.project  # z global/terraform.tfvars przez symlink
  region  = var.region   # z global/terraform.tfvars przez symlink
}
```

## Checklist dla Nowego Projektu

- [ ] Utworzona struktura: `project-name/{services,infra}`
- [ ] Symlink: `infra/global.auto.tfvars` → `../../global/terraform.tfvars`
- [ ] Pliki Terraform: `main.tf`, `variables.tf`, `outputs.tf`, `terraform.tfvars`
- [ ] Folder: `infra/build/`
- [ ] Kod aplikacji w `services/`
- [ ] README.md projektu
- [ ] Aktualizacja głównego README.md
- [ ] Test: `cd infra && terraform init && terraform plan`

## Istniejące Projekty (Referencje)

- **hello-function** - prosta Cloud Function HTTP, dobry szablon do skopiowania
