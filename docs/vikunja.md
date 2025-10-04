# Vikunja

Vikunja is a self-hosted to-do list application and project management tool. It provides a web interface for managing tasks, projects, and teams with features like task assignments, due dates, labels, and more.

The container is configured with SQLite as the database backend and stores files in `/opt/vikunja/files` on the host. After first startup, you'll need to register a new account - there is no default user or password.

## Features

- Task and project management
- Team collaboration
- CalDAV support
- REST API
- Mobile and desktop apps available
- Kanban boards
- Gantt charts
- Task attachments

## Configuration Notes

- Uses SQLite database stored in `/opt/vikunja/data`
- File uploads stored in `/opt/vikunja/files`
- Runs on port 3456 internally, exposed via Caddy reverse proxy
- No default credentials - register a new account on first access

# Useful links

- https://vikunja.io/
- https://vikunja.io/docs/
- https://github.com/go-vikunja/vikunja
- https://hub.docker.com/r/vikunja/vikunja
- https://vikunja.io/docs/installing/#docker

