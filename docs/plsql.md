# PL/SQL Procedures & Triggers Overview

This module contains the procedural and reactive logic of the Oracle Online Shop Database. It focuses on data generation, lifecycle automation, and system integrity enforcement.

---

## Key Objectives

* **Automated Data Generation:** Procedures simplify seeding for development/testing.
* **Bulk Performance:** Use of `BULK COLLECT` and `FORALL` to minimize context switches.
* **Error Logging:** Unified `record_error` procedure logs stack traces on any failure.
* **Soft Deletes:** Ensures data auditability with triggers instead of destructive deletes.

---

## Procedures

### Data Seeding

* **`generate_users`** – Creates test users with roles and audit fields
* **`generate_products`** – Randomized product entries with valid categories and dimensions
* **`generate_shipments`** – Generates shipments with randomized future shipping dates and limits
* **`generate_orders`** – Inserts orders then calls `generate_order_items`
* **`generate_order_items`** – Bulk inserts order lines with randomized products
* **`generate_cities`, `generate_addresses`** – Insert address-related entities

All follow:

* Use of sequences for IDs
* Proper FK population
* Randomized yet controlled data values
* Calls to `record_error` on exceptions

### Error Logging

* **`record_error`**

  * Uses `PRAGMA AUTONOMOUS_TRANSACTION`
  * Captures: `SQLERRM`, `SQLCODE`, `CALLSTACK`, `BACKTRACE`
  * Inserts into `error_log` table

---

## Triggers

### ID and Audit Triggers

* Assign IDs using `BEFORE INSERT` triggers on:

  * `users`, `products`, `orders`, `shipments`, `cities`, `addresses`

### Soft Delete Mechanism

* **Users / Customers:** `BEFORE DELETE` trigger updates `deleted = 'Y'`, then raises an error to cancel physical delete.
* **Products / Shipments:** Backup triggers insert the deleted row into `_deleted` tables with `deleted_on/by` metadata.

### Shipment Logic

* **`trg_check_shipment_capacity`**: Prevents inserting an order into a full shipment (before insert)
* **`trg_update_shipment_order_count`**: Increments order count on a shipment after insert

### Behavior Enforcement

* **`trg_create_customer`**: Automatically creates a customer record when a user places their first order

---

## Summary

This PL/SQL module ensures:

* Efficient test data population
* Safe and trackable data modifications
* Clean enforcement of business logic at the DB level

It prioritizes **performance**, **data integrity**, and **developer productivity** during testing and prototyping.