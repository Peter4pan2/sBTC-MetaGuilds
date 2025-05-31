
;; sBTC-MetaGuilds

;; title: health
;; version:
;; summary:
;; description:
(define-trait healthcare-product-tracking-trait
  (
    (onboard-product (uint uint) (response bool uint))
    (modify-product-phase (uint uint) (response bool uint))
    (retrieve-product-timeline (uint) (response (list 10 {phase: uint, moment: uint}) uint))
    (attach-validation (uint uint principal) (response bool uint))
    (confirm-validation (uint uint) (response bool uint))
  )
)

;; traits
;;
;; Define product phase constants
(define-constant PHASE_PRODUCED u1)
(define-constant PHASE_EVALUATION u2)
(define-constant PHASE_ACTIVE u3)
(define-constant PHASE_SERVICED u4)

;; token definitions
;;
;; Define validation type constants
(define-constant VALIDATION_TYPE_HEALTH_ADMIN u1)
(define-constant VALIDATION_TYPE_EUROPEAN u2)
(define-constant VALIDATION_TYPE_QUALITY u3)
(define-constant VALIDATION_TYPE_SECURITY u4)

;; constants
;;
;; Error constants
(define-constant ERR_NO_PERMISSION (err u1))
(define-constant ERR_PRODUCT_NOT_FOUND (err u2))
(define-constant ERR_PHASE_UPDATE_FAILED (err u3))
(define-constant ERR_INVALID_PHASE (err u4))
(define-constant ERR_INVALID_VALIDATION (err u5))
(define-constant ERR_VALIDATION_ALREADY_EXISTS (err u6))

;; data vars
;;
;; Contract administrator
(define-data-var admin-address principal tx-sender)

;; data maps
;;
;; Current moment counter
(define-data-var moment-counter uint u0)

;; public functions
;;
;; Product tracking map
(define-map product-data 
  {product-id: uint} 
  {
    creator: principal,
    current-phase: uint,
    timeline: (list 10 {phase: uint, moment: uint})
  }
)

;; read only functions
;;
;; Validation tracking map
(define-map product-validations
  {product-id: uint, validation-type: uint}
  {
    validator: principal,
    moment: uint,
    active: bool
  }
)

;; private functions
;;
;; Approved oversight entities
(define-map oversight-entities
  {entity: principal, validation-type: uint}
  {authorized: bool}
)


;; Only admin can perform certain actions
(define-read-only (is-admin (caller principal))
  (is-eq caller (var-get admin-address))
)


;; Get product timeline
(define-read-only (retrieve-product-timeline (product-id uint))
  (let 
    (
      (product (unwrap! (map-get? product-data {product-id: product-id}) ERR_PRODUCT_NOT_FOUND))
    )
    (ok (get timeline product))
  )
)

;; Get current product phase
(define-read-only (get-product-phase (product-id uint))
  (let 
    (
      (product (unwrap! (map-get? product-data {product-id: product-id}) ERR_PRODUCT_NOT_FOUND))
    )
    (ok (get current-phase product))
  )
)

;; Verify product validation
(define-read-only (confirm-validation (product-id uint) (validation-type uint))
  (let
    (
      (validation (unwrap! 
        (map-get? product-validations {product-id: product-id, validation-type: validation-type})
        ERR_INVALID_VALIDATION
      ))
    )
    (ok (get active validation))
  )
)

;; Get validation details
(define-read-only (get-validation-details (product-id uint) (validation-type uint))
  (ok (map-get? product-validations {product-id: product-id, validation-type: validation-type}))
)


;; Validate phase
(define-private (is-valid-phase (phase uint))
  (or 
    (is-eq phase PHASE_PRODUCED)
    (is-eq phase PHASE_EVALUATION)
    (is-eq phase PHASE_ACTIVE)
    (is-eq phase PHASE_SERVICED)
  )
)

;; Get current moment and increment counter
(define-private (get-current-moment)
  (begin
    (var-set moment-counter (+ (var-get moment-counter) u1))
    (var-get moment-counter)
  )
)

;; Validate validation type
(define-private (is-valid-validation-type (validation-type uint))
  (or
    (is-eq validation-type VALIDATION_TYPE_HEALTH_ADMIN)
    (is-eq validation-type VALIDATION_TYPE_EUROPEAN)
    (is-eq validation-type VALIDATION_TYPE_QUALITY)
    (is-eq validation-type VALIDATION_TYPE_SECURITY)
  )
)

;; Validate product ID
(define-private (is-valid-product-id (product-id uint))
  (and (> product-id u0) (<= product-id u1000000))
)

;; Validate entity principal
(define-private (is-valid-entity (entity principal))
  (and 
    (not (is-eq entity (var-get admin-address)))  ;; Entity can't be contract admin
    (not (is-eq entity tx-sender))                ;; Entity can't be the sender
    (not (is-eq entity 'SP000000000000000000002Q6VF78))  ;; Not zero address
  )
)


;; Check if sender is approved oversight entity
(define-private (is-oversight-entity (entity principal) (validation-type uint))
  (default-to 
    false
    (get authorized (map-get? oversight-entities {entity: entity, validation-type: validation-type}))
  )
)

;;;;;;;;; PUBLIC FUNCTION ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Register a new product
(define-public (onboard-product (product-id uint) (initial-phase uint))
  (begin
    (asserts! (is-valid-product-id product-id) ERR_PRODUCT_NOT_FOUND)
    (asserts! (is-valid-phase initial-phase) ERR_INVALID_PHASE)
    (asserts! (or (is-admin tx-sender) (is-eq initial-phase PHASE_PRODUCED)) ERR_NO_PERMISSION)

    (map-set product-data 
      {product-id: product-id}
      {
        creator: tx-sender,
        current-phase: initial-phase,
        timeline: (list {phase: initial-phase, moment: (get-current-moment)})
      }
    )
    (ok true)
  )
)





