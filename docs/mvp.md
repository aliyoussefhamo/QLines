# QLines MVP

## Goal

Allow a customer to reserve a service queue ticket before arriving, check in
with a QR code, and follow their position while branch employees operate the
same queue.

## Actors

- Customer: browses, reserves, checks in, and tracks a ticket.
- Employee: calls, starts, skips, and completes a ticket.
- Branch manager: configures services, employees, counters, and opening state.

## In scope

- Organizations, branches, services, and opening status.
- One active ticket per customer and service.
- QR check-in and real-time ticket state.
- Estimated waiting time and basic daily branch statistics.
- Arabic-first UI with an English-ready structure.

## Out of scope for the first release

- Payments and organization billing.
- Traffic-aware travel time.
- Machine-learning predictions.
- Native printer and voice announcement integrations.

## Your first engineering exercise

Build the service list for a selected branch. Follow the existing branch
feature structure: domain model and repository interface, fake repository,
view-model states, UI, and unit tests.
