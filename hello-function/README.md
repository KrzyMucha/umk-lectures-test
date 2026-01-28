# Hello Function

Prosta Cloud Function zwracająca "Hello, World!" przez HTTP trigger.

## Struktura

```
hello-function/
├── services/           # Kod aplikacji
│   ├── main.py        # Główna funkcja
│   └── requirements.txt
└── infra/             # Infrastruktura Terraform
    ├── main.tf        # Główna konfiguracja
    ├── variables.tf   # Zmienne projektu
    ├── outputs.tf     # Outputy (URL funkcji)
    └── build/         # Folder na spakowane ZIP (gitignored)
```

## Wymagania

- Terraform >= 1.0
- GCP CLI z autoryzacją
- Python 3.9+ (dla funkcji)

## Instalacja i deployment

### 1. Ustaw zmienne globalne

Edytuj `../../global/terraform.tfvars`:

```hcl
project = "your-gcp-project-id"
region  = "us-central1"
```

Zmienne globalne są automatycznie ładowane przez symlink `infra/global.auto.tfvars` → `../../global/terraform.tfvars`.

### 2. Deploy infrastruktury

```bash
cd infra
terraform init
terraform apply
```

### 3. Testowanie

Po deploye otrzymasz URL funkcji w outputach:

```bash
curl $(terraform output -raw function_url)
# Output: Hello, World!
```

### 4. Aktualizacja kodu

Po zmianie plików w `services/`:

```bash
cd infra
terraform apply -replace=google_cloudfunctions_function.function -auto-approve
```

Lub wymuszenie pełnej przebudowy:

```bash
rm -f build/function.zip
terraform apply -replace=google_storage_bucket_object.function_archive -replace=google_cloudfunctions_function.function -auto-approve
```

## Usuwanie

```bash
cd infra
terraform destroy
```

## Struktura kodu

**services/main.py** - główna funkcja:
```python
def hello_world(request):
    return "Hello, World!"
```

Entry point: `hello_world`
