# PostgreSQL JSON/JSONB demo

The key objectives is to demonstrate how to make use of ordered sets using JSON and JSONB documents in postgresql.

## Technologies Used

- **PostgreSQL**
- **Docker**
- **Migrate package**

## Installation

### Step 1:
Run a database in docker:
```bash
docker run -d --name demo -e POSTGRES_USER=postgres -e POSTGRES_DB=demo -e POSTGRES_PASSWORD=postgres -p 5433:5432 postgres
```

### Step 2:
Connect to database using the tool of your choice (I used Goland's database connection feature)

### Step 3:
Run migrations if need be:
```bash
migrate -path ./migrations -database "postgres://postgres:postgres@localhost:5433/demo?sslmode=disable" up
```

### Step 4:
Play around with the demo.sql file!
