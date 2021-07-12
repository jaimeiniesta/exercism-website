import React, { useCallback, useState } from 'react'
import { GenericForm } from './GenericForm'

export function SubscriptionForm({}: {}) {
  return (
    <>
      <h2>Subscribe!!</h2>
      <GenericForm
        paymentIntentEndpoint={'/api/v2/donations/subscriptions'}
        onSuccess={() => {}}
      />
    </>
  )
}
