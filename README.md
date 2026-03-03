# pagila-rental-api-inter
Proyecto base para trabajar con la base de datos de ejemplo *Pagila* usando *PostgreSQL en Docker*.

Actualmente este repositorio deja listo el entorno de base de datos para desarrollo local, con scripts de esquema y datos iniciales.

## Requisitos

- Docker Desktop
- Docker Compose (incluido en Docker Desktop)

## Estructura del proyecto

text
pagila-rental-api/
├── app/
│   ├── db.py
│   ├── main.py
│   ├── models.py
│   └── requirements.txt
├── docker/
│   ├── pagila-schema.sql
│   └── pagila-data.sql
├── docker-compose.yml
└── README.md


## Levantar la base de datos

Desde la raíz del proyecto:

bash
docker compose up -d


Esto inicia un contenedor PostgreSQL con:

- Usuario: postgres
- Contraseña: postgres
- Base de datos: pagila
- Puerto local: 5434

## Inicialización automática de Pagila

Al iniciar por primera vez, Docker ejecuta automáticamente los scripts montados en docker-entrypoint-initdb.d:

1. docker/pagila-schema.sql → crea la estructura (tablas, relaciones, etc.)
2. docker/pagila-data.sql → carga los datos de ejemplo

> Importante: estos scripts se ejecutan automáticamente solo cuando el volumen de datos está vacío.

## Conexión a PostgreSQL

Puedes conectarte con cualquier cliente SQL usando:

- Host: localhost
- Puerto: 5434
- Usuario: postgres
- Contraseña: postgres
- Base de datos: pagila

Ejemplo con psql:

bash
psql -h localhost -p 5434 -U postgres -d pagila


## Comandos útiles

Detener servicios:

bash
docker compose down


Detener y eliminar también el volumen de datos (reinicio completo):

bash
docker compose down -v


Ver logs de la base de datos:

bash
docker compose logs -f db