# MarketHouse — Backend API Architecture & Modules

## Architecture Overview
- **Framework**: NestJS + TypeScript
- **Database ORM**: Prisma ORM with PostgreSQL (`mh-db` Docker container)
- **Authentication**: JWT Bearer token authentication with Passport
- **Security**: Global `AuthGuard` and `RolesGuard` protecting endpoints via `@Roles()` decorator.

## Backend Modules (`/backend/src/modules/`)
1. **auth**: Login authentication, password verification (bcrypt), JWT signing, refresh token rotation.
2. **users**: User CRUD, password reset, role assignment (`Cargo`).
3. **clientes**: Customer management, address & contact association.
4. **itens**: Product catalog, BOM item components, lead times, dimensions.
5. **pedidos**: Production order creation, status transitions (`StatusPedido`), order sequence generation.
6. **producao**: Production tracking, sector gate execution (`Etapa`), status updates (`StatusEtapa`).
7. **projetos**: Architectural & technical drawing file attachments.
8. **suprimentos**: Purchase orders (`Compra`), raw material stock rules, vendor lead times.
9. **jornada**: Work shift management (`JornadaPadrao`), overtime/holiday exceptions (`ExcecaoJornada`).

## Endpoint Route Standards
- Endpoints prefixed with `/api/v1/`.
- Strict validation pipes (`ValidationPipe` with `transform: true`).
- Soft deletes respected on all query filters (`where: { ativo: true }`).
