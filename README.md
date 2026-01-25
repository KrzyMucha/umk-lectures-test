# Hello World — Terraform + Google Cloud Function

Krótkie instrukcje do uruchomienia projektu Hello World.

Wymagania:
- `terraform` (>= 1.0)
- konto GCP i ustawione poświadczenia (np. `gcloud auth application-default login` lub `GOOGLE_CREDENTIALS`)

Szybkie kroki:

1. Ustaw zmienną projektu (możesz edytować `terraform.tfvars` lub ustawić env):

```bash
export TF_VAR_project=your-gcp-project-id
```

2. Inicjalizuj i zastosuj:

```bash
terraform init
terraform apply
```

3. Po wdrożeniu w outputach pojawi się `function_url` — to publiczny endpoint funkcji Hello World.

Uwaga: upewnij się, że billing jest włączony w projekcie i że konta/usługi mają odpowiednie uprawnienia.
