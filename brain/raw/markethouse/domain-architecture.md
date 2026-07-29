# MarketHouse — Domain Architecture & Data Models

## System Domain Overview
MarketHouse is a real-time PCP (Planejamento e Controle de Produção) flow management platform for supermarket display and furniture manufacturing.

## Key Data Enums & Rules
- **Cargo**: Role-based permissions (`ADMIN`, `GERENTE`, `OPERADOR`, `VENDEDOR`).
- **Processo**: Sector production gates (Corte, Furação, Colagem, Montagem, Embalagem, Expedição).
- **Dimensao**: Standard measurements in `mm` (Altura, Largura, Profundidade).
- **StatusEtapa**: Sector gate statuses (`PENDENTE`, `EM_ANDAMENTO`, `CONCLUIDO`, `BLOQUEADO`).
- **StatusPedido**: Order lifecycle (`RASCUNHO`, `APROVADO`, `EM_PRODUCAO`, `PRONTO_EXPEDICAO`, `ENTREGUE`, `CANCELADO`).

## Primary Prisma Database Models
1. **User**: Authentication, password hash, role (`Cargo`), active state (`ativo`).
2. **Cliente & Contato**: Customer profile, tax IDs (CNPJ/CPF), contact phone/email.
3. **Item**: Product items, BOM components (`ItemComponente`), lead times (`ItemLeadTime`), dimensions (`ItemMedida`).
4. **Pedido & PedidoItem**: Orders, auto-incrementing sequence (`PedidoSequence`), items, unit pricing, total amounts.
5. **Etapa**: Tracking sector gate progress for each order item across production stages.
6. **Compra**: Supply procurement orders, vendor details, lead time tracking.
7. **JornadaPadrao & ExcecaoJornada**: Standard work shifts and holiday/overtime calendar exceptions.

## Data Conventions & Soft Deletes
- All tables enforce soft deletes via `ativo Boolean @default(true)`.
- Measures in `mm`, currency in `BRL`, dates stored in UTC ISO-8601 formatted in `DD/MM/YY` for display.
