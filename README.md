

# sBTC-MetaGuild Smart Contract

**Version:** 1.0
**Language:** [Clarity](https://docs.stacks.co/write-smart-contracts/clarity-ref)
**Network:** Stacks Blockchain

---

## 📘 Overview

The  smart contract enables **transparent, secure, and auditable tracking of healthcare products** throughout their lifecycle. It supports product onboarding, phase transitions, and formal validations by authorized oversight entities. Every action is logged immutably, providing clear traceability.

---

## 🎯 Key Features

* 📦 **Product Lifecycle Management**
  Products go through defined phases: Produced → Evaluation → Active → Serviced

* 🛂 **Validation Mechanism**
  Authorized oversight entities can issue or revoke validations (e.g., Quality, Security, Regulatory)

* 🧑‍⚖️ **Admin Control**
  Contract administrator can onboard products and manage authorized validators

* ⏱️ **Immutable Timeline**
  Each product tracks a timestamped history of its phase changes and validations

---

## 🧱 Architecture

### 🔐 Access Roles

| Role      | Description                            |
| --------- | -------------------------------------- |
| `Admin`   | Full control over product & validators |
| `Entity`  | Authorized to attach validations       |
| `Creator` | Product owner; can update its phase    |

---

## 📦 Constants

### 📌 Product Phases

| Constant           | Value | Description         |
| ------------------ | ----- | ------------------- |
| `PHASE_PRODUCED`   | `u1`  | Product created     |
| `PHASE_EVALUATION` | `u2`  | Under review        |
| `PHASE_ACTIVE`     | `u3`  | Active on market    |
| `PHASE_SERVICED`   | `u4`  | Retired or serviced |

### 📌 Validation Types

| Constant                       | Value | Description                  |
| ------------------------------ | ----- | ---------------------------- |
| `VALIDATION_TYPE_HEALTH_ADMIN` | `u1`  | Regulatory agency validation |
| `VALIDATION_TYPE_EUROPEAN`     | `u2`  | EU compliance validation     |
| `VALIDATION_TYPE_QUALITY`      | `u3`  | Internal QA certification    |
| `VALIDATION_TYPE_SECURITY`     | `u4`  | Cybersecurity certification  |

---

## 🧾 Error Codes

| Constant                        | Value      | Description             |
| ------------------------------- | ---------- | ----------------------- |
| `ERR_NO_PERMISSION`             | `(err u1)` | Not authorized          |
| `ERR_PRODUCT_NOT_FOUND`         | `(err u2)` | Product not found       |
| `ERR_PHASE_UPDATE_FAILED`       | `(err u3)` | Timeline failure        |
| `ERR_INVALID_PHASE`             | `(err u4)` | Invalid phase           |
| `ERR_INVALID_VALIDATION`        | `(err u5)` | Unknown validation type |
| `ERR_VALIDATION_ALREADY_EXISTS` | `(err u6)` | Already validated       |

---

## 🗂️ Storage

### 🧍 `product-data`

Tracks individual product lifecycle.

```clarity
{ 
  product-id: uint, 
  creator: principal, 
  current-phase: uint, 
  timeline: (list 10 {phase: uint, moment: uint})
}
```

### 🏢 `product-validations`

Tracks validations applied to products.

```clarity
{
  product-id: uint,
  validation-type: uint,
  validator: principal,
  moment: uint,
  active: bool
}
```

### 🧑‍⚖️ `oversight-entities`

Authorized validators for each validation type.

```clarity
{
  entity: principal,
  validation-type: uint,
  authorized: bool
}
```

---

## 🔧 Public Functions

### ➕ `onboard-product (product-id uint, initial-phase uint)`

* Adds a new product with a starting phase
* Only admin can start with non-produced phases

### 🔁 `modify-product-phase (product-id uint, new-phase uint)`

* Product creator or admin can move product to a new phase

### 🧑‍⚖️ `add-oversight-entity (entity principal, validation-type uint)`

* Admin-only: Authorize an oversight entity to issue a validation

### ✅ `attach-validation (product-id uint, validation-type uint)`

* Adds validation to a product (by authorized entity)

### ❌ `withdraw-validation (product-id uint, validation-type uint)`

* Deactivates a validation (admin or original validator only)

---

## 📖 Read-Only Functions

| Function                                              | Description                            |
| ----------------------------------------------------- | -------------------------------------- |
| `is-admin(caller)`                                    | Returns true if caller is admin        |
| `retrieve-product-timeline(product-id)`               | Returns full lifecycle log             |
| `get-product-phase(product-id)`                       | Returns current phase                  |
| `confirm-validation(product-id, validation-type)`     | Returns `true` if validation is active |
| `get-validation-details(product-id, validation-type)` | Returns full validation record         |

---

## 🔐 Internal Validations

| Function                   | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| `is-valid-phase`           | Ensures phase is one of four known phases |
| `is-valid-validation-type` | Ensures validation type is defined        |
| `is-valid-product-id`      | Checks ID range (1–1,000,000)             |
| `is-valid-entity`          | Ensures entity isn’t zero or admin        |
| `is-oversight-entity`      | Checks validator permissions              |
| `get-current-moment`       | Increments and retrieves moment counter   |

---

## 🧪 Example Usage

```clarity
;; Onboard a new product (default phase = produced)
(onboard-product u101 u1)

;; Admin updates product to evaluation
(modify-product-phase u101 u2)

;; Admin approves validation entity for security checks
(add-oversight-entity 'SP123... VALIDATION_TYPE_SECURITY)

;; Validator confirms validation
(attach-validation u101 VALIDATION_TYPE_SECURITY)

;; Admin or validator can later withdraw validation
(withdraw-validation u101 VALIDATION_TYPE_SECURITY)

;; Read-only: View product lifecycle
(retrieve-product-timeline u101)
```

---

## 📌 Deployment Notes

Use [Clarinet](https://docs.hiro.so/clarinet) or Stacks CLI to test and deploy:

```bash
clarinet test  # Run tests
clarinet deploy  # Deploy to devnet
```

---

## 🔐 Security Considerations

* Strict access control for admin-only functions
* Immutable validation logs
* Timeline size is capped to avoid gas exhaustion
* Validators cannot validate or withdraw arbitrarily

---
