# Data Model Overview

This document outlines the core relational design used in `oracle-enterprise-db-lab`, emphasizing scalability, clean engineering practices, and production-readiness (with an online shop sample domain).

The model is structured to support:

* Expansion across regions and product lines
* Clear separation of concerns (auth, behavior, logistics)
* Maintainable audit and lifecycle management

---

## User Identity and Roles

### Roles

The `roles` table defines distinct types of application-level users (e.g., admin, developer, customer). These are extensible and used via foreign key references in the `users` table.

### Users

All actors in the platform (including customers and staff) originate from the `users` table.

* Unique login information and metadata
* Includes audit fields (created\_by, updated\_on, etc.)
* Linked to a role for behavior distinction

### Customers

Customers are a subset of users identified by their presence in the `customers` table.

* Enables behavioral modeling without affecting authentication
* Allows customer-specific extensions

---

## Geography: Country → Wilaya → City → Address

Geographical data is normalized into:

* `countries` (e.g., Algeria)
* `wilayas` (Algerian provinces, FK to country)
* `cities` (FK to wilaya)
* `addresses` (FK to users and cities)

This structure enables:

* Multi-country delivery support
* Cascading logic for address resolution
* Integration with real-world postal standards

---

## Orders and Transaction Flow

### Orders

* Linked to a customer, shipment, and address
* Contains total price and status tracking
* Lifecycle audit: created\_by, updated\_by

### Order Items

* Composite key (order\_id + item\_no)
* Quantity, product reference
* Audited like other transactional tables

---

## Products

Each product includes:

* Basic data: name, price, image, weight, volume
* FK to product category
* Full audit traceability

A separate `products_deleted` table exists to preserve deleted products with metadata (deleted\_on, deleted\_by).

---

## Shipments

Tracks dispatches and logistical state:

* Capacity: weight, volume, max orders
* Linked to shipment types and statuses
* Full audit trail

Deleted shipments are tracked in `shipments_deleted`.

---

## Lookup Tables (Enumerations)

Used for referential integrity and filtering:

* `roles`
* `product_categories`
* `shipment_statuses`
* `order_statuses`
* `shipment_types`

All have enforced codes and labels for consistent use across interfaces and procedures.

---

## Audit and Error Handling

### Audit Columns (Common Pattern)

Most tables include:

* `created_on`, `updated_on`
* `created_by`, `updated_by`
* `deleted` flags where applicable

### Error Log Table

From Oracle best practices:

```sql
CREATE TABLE error_log (
    ERROR_CODE    INTEGER,
    error_message VARCHAR2(4000),
    backtrace     CLOB,
    callstack     CLOB,
    created_on    DATE,
    created_by    VARCHAR2(30)
);
```

This captures runtime and PL/SQL exceptions.

---

## Backup and Lifecycle Tables

### Deleted Product Backup

```sql
CREATE TABLE products_deleted AS SELECT * FROM products WHERE 1=0;
ALTER TABLE products_deleted ADD deleted_on DATE DEFAULT SYSDATE;
ALTER TABLE products_deleted ADD deleted_by NUMBER;
```

### Deleted Shipment Backup

```sql
CREATE TABLE shipments_deleted AS SELECT * FROM shipments WHERE 1=0;
ALTER TABLE shipments_deleted ADD deleted_on DATE DEFAULT SYSDATE;
ALTER TABLE shipments_deleted ADD deleted_by NUMBER;
```

These allow soft-deletion and future restoration workflows.

---

This data model is designed to evolve with new roles, business logic, regional setups, and integration with external systems, all while remaining stable and maintainable.