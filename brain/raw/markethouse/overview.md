# MarketHouse Overview

**Project**: PCP (Planejamento e Controle de Produção) Flow Manager for supermarket display & furniture industry.  
**Repository**: `https://github.com/josERPfilho/MarketHouse.git`  
**Location**: `/home/gilberto/Markethouse`

## Architecture & Stack
- **Backend**: NestJS + TypeScript + Prisma + PostgreSQL (`/backend`)
- **Frontend**: React + TypeScript + Vite + Tailwind v4 + shadcn/ui (`/frontend`)
- **Database**: PostgreSQL (Docker container `mh-db`)

## Core Domain Rules
- **Tracking**: Real-time visibility of parts from order to dispatch across sector gates.
- **Data Conventions**: BR Portuguese, measurements in `mm`, dates in `DD/MM/YY`.
- **Data Integrity**: Soft deletes (`ativo = false`).
