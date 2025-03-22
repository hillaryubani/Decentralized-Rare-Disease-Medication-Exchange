;; Medication Registration Contract
;; Records details of unused prescription medications

(define-data-var last-id uint u0)

(define-map medications
  { id: uint }
  {
    name: (string-ascii 64),
    ndc: (string-ascii 20),
    expiration: uint,
    quantity: uint,
    donor: principal,
    status: (string-ascii 10)
  }
)

(define-read-only (get-medication (id uint))
  (map-get? medications { id: id })
)

(define-public (register-medication (name (string-ascii 64)) (ndc (string-ascii 20)) (expiration uint) (quantity uint))
  (let
    ((new-id (+ (var-get last-id) u1)))

    (map-set medications
      { id: new-id }
      {
        name: name,
        ndc: ndc,
        expiration: expiration,
        quantity: quantity,
        donor: tx-sender,
        status: "available"
      }
    )

    (var-set last-id new-id)
    (ok new-id)
  )
)

(define-public (update-status (id uint) (new-status (string-ascii 10)))
  (let
    ((med (unwrap! (map-get? medications { id: id }) (err u404))))

    (asserts! (is-eq tx-sender (get donor med)) (err u403))

    (map-set medications
      { id: id }
      (merge med { status: new-status })
    )
    (ok true)
  )
)
