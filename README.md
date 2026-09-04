# RaceDay API

## Project Overview
RaceDay is an event management system for running and racing events. It supports two roles: **Organiser** and **Participant**, with role-based access enforced at API level.

## User Roles

### Organiser
- Create, edit and delete events.
- Manage event categories.
- Manage event routes and weather snapshots.
- View enrolments for events.
- Capture, update and delete participant results.

### Participant
- Create an account and log in.
- Browse events and categories.
- Enrol in an event by selecting a category.
- View their own enrolments.
- Track their personal results.

## Database / ERD

The database contains seven entities:

1. **USERS** – organiser and participant accounts.
2. **EVENTS** – event information and organiser.
3. **CATEGORIES** – categories available within an event.
4. **EVENT_ROUTES** – optional route information for an event.
5. **WEATHER_SNAPSHOTS** – weather information for an event.
6. **ENROLMENTS** – participant event entries and selected categories.
7. **RESULTS** – result information for an enrolment.

Main relationships:
- One User organises many Events.
- One User has many Enrolments.
- One Event has many Categories.
- One Event has many Enrolments.
- One Category has many Enrolments.
- One Event has zero or one Route.
- One Event has many Weather Snapshots.
- One Enrolment has zero or one Result.

## API Base Route

All endpoints begin with `/api/` and use REST-style HTTP methods such as `GET`, `POST`, `PUT` and `DELETE`.

## Authentication

| Method | Route | Access | Description |
|---|---|---|---|
| POST | `/api/auth/register` | Public | Register a participant. |
| POST | `/api/auth/login` | Public | Authenticate a user. |

### Register request
```json
{
  "firstName": "John",
  "lastName": "Smith",
  "email": "john@example.com",
  "password": "Password123!",
  "phone": "0712345678"
}
```

### Login request
```json
{
  "email": "john@example.com",
  "password": "Password123!"
}
```

## User Profile

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/users/me` | Authenticated | Get the current user's profile. |
| PUT | `/api/users/me` | Authenticated | Update the current user's profile. |

## Events

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/events` | Public | List events. |
| GET | `/api/events/{id}` | Public | Get one event. |
| POST | `/api/events` | Organiser | Create an event. |
| PUT | `/api/events/{id}` | Organiser | Update an event. |
| DELETE | `/api/events/{id}` | Organiser | Delete an event. |

### Event request
```json
{
  "name": "Cape Town Race",
  "description": "Annual road race",
  "eventDate": "2026-10-15",
  "location": "Cape Town",
  "eventType": "Road",
  "status": "Open"
}
```

## Categories

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/events/{eventId}/categories` | Public | List event categories. |
| GET | `/api/categories/{id}` | Public | Get a category. |
| POST | `/api/events/{eventId}/categories` | Organiser | Create a category. |
| PUT | `/api/categories/{id}` | Organiser | Update a category. |
| DELETE | `/api/categories/{id}` | Organiser | Delete a category. |

### Category request
```json
{
  "name": "10 km",
  "distanceKm": 10.00,
  "maxParticipants": 500,
  "entryFee": 150.00,
  "minAge": 16,
  "maxAge": 99
}
```

## Event Routes

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/events/{eventId}/route` | Public | Get the event route. |
| POST | `/api/events/{eventId}/route` | Organiser | Create an event route. |
| PUT | `/api/events/{eventId}/route` | Organiser | Update the route. |
| DELETE | `/api/events/{eventId}/route` | Organiser | Delete the route. |

## Weather Snapshots

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/events/{eventId}/weather` | Public | Get weather snapshots. |
| POST | `/api/events/{eventId}/weather` | Organiser | Record a weather snapshot. |

## Event Enrolments

| Method | Route | Access | Description |
|---|---|---|---|
| POST | `/api/events/{eventId}/enrolments` | Participant | Enrol in an event/category. |
| GET | `/api/events/{eventId}/enrolments` | Organiser | View event enrolments. |
| GET | `/api/enrolments/me` | Participant | View own enrolments. |
| GET | `/api/enrolments/{id}` | Participant/Organiser | View an enrolment when authorised. |
| PUT | `/api/enrolments/{id}` | Organiser | Update status or bib number. |
| DELETE | `/api/enrolments/{id}` | Participant | Cancel an enrolment when permitted. |

### Enrolment request
```json
{
  "categoryId": 1
}
```

## Results

| Method | Route | Access | Description |
|---|---|---|---|
| GET | `/api/events/{eventId}/results` | Authenticated | View event results. |
| GET | `/api/enrolments/{enrolmentId}/result` | Participant/Organiser | View an authorised result. |
| POST | `/api/enrolments/{enrolmentId}/result` | Organiser | Record a result. |
| PUT | `/api/enrolments/{enrolmentId}/result` | Organiser | Update a result. |
| DELETE | `/api/enrolments/{enrolmentId}/result` | Organiser | Delete a result. |

### Result request
```json
{
  "finishTime": "00:52:35",
  "position": 12,
  "resultStatus": "Finished",
  "recordedAt": "2026-10-15T14:30:00"
}
```

## HTTP Status Codes

| Status | Meaning |
|---|---|
| 200 | Successful request |
| 201 | Resource created |
| 204 | Successful request with no body |
| 400 | Invalid request |
| 401 | Authentication required/failed |
| 403 | Access denied |
| 404 | Resource not found |
| 409 | Conflict or duplicate resource |

## Security

Passwords must never be stored as plain text. The `USERS.PasswordHash` field stores a password hash.

Protected endpoints require authentication, followed by role-based authorisation. Participants should only access their own profile, enrolments and personal results. Organisers can access management functions for their events.

## Suggested Project Structure

```text
RaceDay/
├── Controllers/
│   ├── AuthController
│   ├── UsersController
│   ├── EventsController
│   ├── CategoriesController
│   ├── EnrolmentsController
│   └── ResultsController
├── Models/
│   ├── User
│   ├── Event
│   ├── Category
│   ├── EventRoute
│   ├── WeatherSnapshot
│   ├── Enrolment
│   └── Result
├── Data/
├── Views/
├── docs/
│   ├── ERD.png
│   └── API-Endpoint-Plan.md
└── README.md
```

## Development Setup

1. Configure the database connection.
2. Run the SQL script supplied with the project.
3. Confirm that the database matches the ERD.
4. Configure authentication and role-based authorisation.
5. Run the MVC/API application.
6. Test endpoints with Swagger/OpenAPI, Postman, or another API client.
7. Test both Organiser and Participant permissions.

## Testing Checklist

### Participant
- [ ] Register
- [ ] Login
- [ ] View profile
- [ ] Browse events
- [ ] View categories
- [ ] Enrol in an event
- [ ] View own enrolments
- [ ] View personal results
- [ ] Confirm organiser-only routes return `403`

### Organiser
- [ ] Login
- [ ] Create, edit and delete events
- [ ] Create and manage categories
- [ ] Manage event route
- [ ] Record weather
- [ ] View event enrolments
- [ ] Record, update and delete results

## Documentation Requirements

The project should include:
- ERD with entities, attributes, PKs, FKs and cardinalities.
- SQL script matching the ERD.
- API endpoint plan.
- Source code matching the planned endpoints.
- Evidence of role-based access control and API testing.

## References

Anglia Ruskin University (2024) *ARRO: A comprehensive guide to the Harvard referencing system* [online]. Available at: https://library.aru.ac.uk/academic/files/ARROguide-v4.pdf (Accessed: 4 September 2026).

IBM (2024) *What is an API endpoint?* [online]. Available at: https://www.ibm.com/think/topics/api-endpoint (Accessed: 4 September 2026).

IBM (2025) *What is a REST API (RESTful API)?* [online]. Available at: https://www.ibm.com/think/topics/rest-apis (Accessed: 4 September 2026).
