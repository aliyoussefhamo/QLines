# QLines

QLines is a modern rebuild of a 2019 graduation project for managing service
queues. The repository grows through small, tested vertical slices.

## First milestone

- Browse branches and see queue metrics.
- Choose a service and create a reservation.
- Receive a QR check-in token.
- Track queue position and estimated waiting time.
- Let an employee call, start, skip, and finish a ticket.

## Run and verify

```powershell
cd apps/qline_app
flutter run -d chrome
flutter analyze
flutter test
```
