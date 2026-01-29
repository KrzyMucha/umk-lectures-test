# Symphony CRUD

Symfony 7 CRUD API for managing offers (oferty) with PostgreSQL and Docker.

## Struktura

```
symphony-crud/
├── services/              # Aplikacja Symfony
│   ├── bin/              # Console
│   ├── config/           # Konfiguracja
│   ├── migrations/       # Migracje bazy danych
│   ├── public/           # Punkt wejścia (index.php)
│   ├── src/
│   │   ├── Controller/   # Kontrolery API
│   │   ├── Entity/       # Encje Doctrine
│   │   └── Repository/   # Repozytoria
│   ├── composer.json
│   ├── Dockerfile        # Multi-stage (dev + prod)
│   └── docker-compose.yml
└── infra/                # Infrastruktura Terraform (Cloud Run)
    └── [w przygotowaniu]
```

## Wymagania

- Docker & Docker Compose
- PHP 8.3+ (dla lokalnego developmentu bez Dockera)
- PostgreSQL 15

## API Endpoints

### Lista ofert
```bash
GET /offers
```

### Pojedyncza oferta
```bash
GET /offers/{id}
```

### Dodaj ofertę
```bash
POST /offers
Content-Type: application/json

{
  "title": "Nowa oferta",
  "description": "Opis oferty",
  "price": "99.99"
}
```

### Aktualizuj ofertę
```bash
PUT /offers/{id}
Content-Type: application/json

{
  "title": "Zaktualizowany tytuł",
  "price": "149.99"
}
```

### Usuń ofertę
```bash
DELETE /offers/{id}
```

## Uruchomienie (Docker)

### 1. Sklonuj i przejdź do projektu

```bash
cd symphony-crud/services
```

### 2. Utwórz plik .env

```bash
cp .env.example .env
```

### 3. Uruchom kontenery

```bash
docker-compose up -d
```

### 4. Zainstaluj zależności

```bash
docker-compose exec app composer install
```

### 5. Uruchom migracje

```bash
docker-compose exec app php bin/console doctrine:migrations:migrate
```

### 6. Testuj API

```bash
# Dodaj ofertę
curl -X POST http://localhost:8080/offers \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Offer","description":"Test description","price":"99.99"}'

# Lista ofert
curl http://localhost:8080/offers

# Pojedyncza oferta
curl http://localhost:8080/offers/1

# Aktualizuj ofertę
curl -X PUT http://localhost:8080/offers/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Offer","price":"149.99"}'

# Usuń ofertę
curl -X DELETE http://localhost:8080/offers/1
```

## Development

### Logi

```bash
docker-compose logs -f app
```

### Zatrzymanie

```bash
docker-compose down
```

### Zatrzymanie z usunięciem danych

```bash
docker-compose down -v
```

## Budowa produkcyjna

```bash
docker build --target prod -t symphony-crud:prod .
docker run -p 8080:8080 -e DATABASE_URL="postgresql://user:pass@host:5432/db" symphony-crud:prod
```

## Struktura bazy danych

### Tabela: offers

| Kolumna      | Typ           | Opis                    |
|--------------|---------------|-------------------------|
| id           | SERIAL        | Primary key             |
| title        | VARCHAR(255)  | Tytuł oferty            |
| description  | TEXT          | Opis oferty (nullable)  |
| price        | DECIMAL(10,2) | Cena                    |
| created_at   | TIMESTAMP     | Data utworzenia         |
| updated_at   | TIMESTAMP     | Data aktualizacji       |

## Cloud Run Deployment

Infrastruktura Terraform dla Google Cloud Run będzie dodana w katalogu `infra/`.

## Troubleshooting

### Port już zajęty

Zmień port w `docker-compose.yml`:
```yaml
ports:
  - "8081:8080"  # zmień 8080 na 8081
```

### Problem z bazą danych

Usuń volume i utwórz ponownie:
```bash
docker-compose down -v
docker-compose up -d
docker-compose exec app php bin/console doctrine:migrations:migrate
```
