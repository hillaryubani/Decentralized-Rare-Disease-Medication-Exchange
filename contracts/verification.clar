;; Verification Contract
;; Validates medication authenticity and expiration dates

(define-constant contract-owner tx-sender)

(define-map verifiers principal bool)

(define-map verified-meds
  { med-id: uint }
  {
    verifier: principal,
    time: uint,
    notes: (string-ascii 64)
  }
)

(define-read-only (is-verifier (address principal))
  (default-to false (map-get? verifiers address))
)

(define-public (add-verifier (address principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (map-set verifiers address true)
    (ok true)
  )
)

(define-public (verify-medication (med-id uint) (notes (string-ascii 64)))
  (begin
    (asserts! (is-verifier tx-sender) (err u403))

    (map-set verified-meds
      { med-id: med-id }
      {
        verifier: tx-sender,
        time: block-height,
        notes: notes
      }
    )
    (ok true)
  )
)
