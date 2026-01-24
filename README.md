# ✅ Task Flow (Full Stack App)
Task Flow is a Full Stack task management application developed with Flutter on the frontend and Node.js/Express on the backend.

This project goes beyond a simple to-do list; it is a reference implementation of a modern and scalable architecture. It demonstrates how to connect a reactive mobile interface with a custom backend and a relational database, handling secure authentication and real-time data synchronization.

## 📱 Gallery
<p align="center"> <img src="/screenshots/login.png" alt="Login Screen" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/home.png" alt="Home Screen" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/home2.png" alt="Home Screen 2" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/add_task.png" alt="Edit Task Screen" width="22%"> </p>

## 🚀 Main Features
Secure JWT Authentication: Complete Registration and Login system with session persistence using tokens (x-auth-token).

Real-Time Full CRUD: Create, Read, Update, and Delete tasks with instant server synchronization.

Precise Time Management (UTC): Robust solution for Timezone handling. Tasks are saved in pure UTC and displayed correctly in the user's local time, preventing the "previous day" error.

Swipe-to-Delete: Native user experience allowing task deletion by swiping the card, with immediate visual feedback.

Advanced Editing: Ability to edit title, description, color, and time, with pre-loading of existing data in the form.

Customizable UI: Hexadecimal Color Picker and native Date and Time pickers.

## 🛠️ Tech Stack
This project uses a modern stack divided into two parts:

## 📱 Frontend (Mobile)
Framework: Flutter

State Management: BLoC (Business Logic Component)

Architecture: Clean Architecture

Functional Programming: fpdart (Error handling with Either)

Http Client: http

Utilities: intl (Dates), uuid, flex_color_picker

## 🔙 Backend (Server & DB)
Runtime: Node.js & TypeScript

Framework: Express.js

ORM: Prisma

Database: PostgreSQL

Infrastructure: Docker (Database Containerization)

Security: jsonwebtoken (JWT), bcryptjs (Password Hashing)

## 🏗️ Project Architecture
The frontend strictly follows Clean Architecture principles, dividing code into layers to ensure testability and maintainability.

Directory Structure (Frontend)

```text

lib/
├── core/                  # Base configuration (Theme, UseCase interface, Failures)
├── features/
│   ├── auth/              # Authentication Feature
│   │   ├── data/          # Remote data sources and repositories
│   │   ├── domain/        # Entities and use cases
│   │   └── presentation/  # BLoC, Pages, and Widgets
│   └── task/              # Task Feature (Full CRUD)
│       ├── data/          # Models and API calls
│       ├── domain/        # Pure business logic
│       └── presentation/  # UI for cards, forms, and state
└── main.dart              # Dependency injection and entry point

```

## 📐 Implemented Design Patterns
BLoC Pattern
Used for predictable state management. It separates UI from business logic, allowing the interface to react to states like TaskLoading, TaskSuccess, or TaskFailure.

Repository Pattern
Abstracts communication with the Backend. The Domain layer doesn't know data comes from a REST API, allowing data source swapping (e.g., to Firebase or SQLite) without breaking business logic.

Functional Error Handling
Thanks to fpdart, we don't use messy try-catch blocks. Errors are handled as return values (Either<Failure, Success>), forcing the UI to handle failures explicitly.

##💡 Key Technical Highlights
1. Timezone Neutrality
One of the biggest challenges in agenda apps is date handling.

Problem: Sending "Jan 25 00:00" from Spain (+1) resulted in the server receiving "Jan 24 23:00", saving the task on the previous day.

Solution: We implemented a strict conversion to UTC (DateTime.utc) before sending to the server and a local reconstruction upon receipt, guaranteeing absolute precision regardless of user location.

2. Docker & Prisma
The backend does not depend on complex local installations.

The PostgreSQL database runs isolated in a Docker container.

Prisma ORM manages the schema and migrations, providing Type Safety between the DB and TypeScript code.

3. Dependency Injection
We use get_it to inject repositories, use cases, and BLoCs. This decouples classes and facilitates mock creation for testing.

## ⚙️ How to Run the Project

1. Backend
Bash
### Enter server folder
cd backend

### Install dependencies
npm install

### Start Database (Docker must be running)
docker-compose up -d

### Generate Prisma client
npx prisma generate

### Start server in dev mode
npm run dev
2. Frontend (Flutter)
Bash
### Install dependencies
flutter pub get

### Run the App
flutter run

---

Made with 💙 and lots of clean code.

---
---

# ✅ Task Flow (Full Stack App)
Task Flow es una aplicación de gestión de tareas Full Stack desarrollada con Flutter en el frontend y Node.js/Express en el backend.

Este proyecto va más allá de una simple lista de tareas; es una implementación de referencia de una arquitectura moderna y escalable. Demuestra cómo conectar una interfaz móvil reactiva con un backend personalizado y una base de datos relacional, manejando autenticación segura y sincronización de datos en tiempo real.

## 📱 Galería
<p align="center"> <img src="/screenshots/login.png" alt="Login Screen" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/home.png" alt="Home Screen" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/home2.png" alt="Home Screen 2" width="22%" style="margin-right: 10px"> &nbsp;&nbsp;&nbsp;&nbsp; <img src="/screenshots/add_task.png" alt="Edit Task Screen" width="22%"> </p>


##🚀 Características Principales
Autenticación JWT Segura: Sistema completo de Registro y Login con persistencia de sesión mediante tokens (x-auth-token).

CRUD Completo en Tiempo Real: Crear, Leer, Actualizar y Eliminar tareas con sincronización instantánea con el servidor.

Gestión Temporal Precisa (UTC): Solución robusta para el manejo de Zonas Horarias. Las tareas se guardan en UTC puro y se visualizan correctamente en la hora local del usuario, evitando el error del "día anterior".

Swipe-to-Delete: Experiencia de usuario nativa permitiendo eliminar tareas deslizando la tarjeta, con feedback visual inmediato.

Edición Avanzada: Capacidad de editar título, descripción, color y hora, precargando los datos existentes en el formulario.

UI Personalizable: Selector de colores hexadecimales (Color Picker) y selectores nativos de Fecha y Hora.

## 🛠️ Stack Tecnológico
Este proyecto utiliza un stack moderno dividido en dos partes:

### 📱 Frontend (Mobile)
Framework: Flutter

State Management: BLoC (Business Logic Component)

Architecture: Clean Architecture

Functional Programming: fpdart (Manejo de errores con Either)

Http Client: http

Utilities: intl (Fechas), uuid, flex_color_picker

### 🔙 Backend (Server & DB)
Runtime: Node.js & TypeScript

Framework: Express.js

ORM: Prisma

Database: PostgreSQL

Infrastructure: Docker (Containerización de la Base de Datos)

Security: jsonwebtoken (JWT), bcryptjs (Hashing de contraseñas)

## 🏗️ Arquitectura del Proyecto
El frontend sigue estrictamente los principios de Clean Architecture, dividiendo el código en capas para asegurar la testabilidad y el mantenimiento.

Estructura de Directorios (Frontend)

```text
lib/
├── core/                  # Configuración base (Theme, UseCase interface, Failures)
├── features/
│   ├── auth/              # Feature de Autenticación
│   │   ├── data/          # Fuentes de datos remotas y repositorios
│   │   ├── domain/        # Entidades y casos de uso
│   │   └── presentation/  # BLoC, Páginas y Widgets
│   └── task/              # Feature de Tareas (CRUD completo)
│       ├── data/          # Modelos y llamadas a API
│       ├── domain/        # Lógica de negocio pura
│       └── presentation/  # UI de tarjetas, formularios y estado
└── main.dart              # Inyección de dependencias y arranque
```

## 📐 Patrones de Diseño Implementados
BLoC Pattern
Utilizado para la gestión de estado predecible. Separa la UI de la lógica de negocio, permitiendo que la interfaz reaccione a estados como TaskLoading, TaskSuccess o TaskFailure.

Repository Pattern
Abstrae la comunicación con el Backend. La capa de Dominio no sabe que los datos vienen de una API REST, lo que permite cambiar la fuente de datos (ej: a Firebase o SQLite) sin romper la lógica de negocio.

Functional Error Handling
Gracias a fpdart, no utilizamos try-catch desordenados. Los errores se manejan como valores de retorno (Either<Failure, Success>), obligando a la UI a gestionar los fallos explícitamente.

## 💡 Detalles Técnicos Destacados
### 1. Neutralidad de Zona Horaria (Timezone Neutrality)
Uno de los mayores retos en apps de agenda es el manejo de fechas.

Problema: Al enviar "25 Ene 00:00" desde España (+1), el servidor recibía "24 Ene 23:00", guardando la tarea el día anterior.

Solución: Implementamos una conversión estricta a UTC (DateTime.utc) antes de enviar al servidor y una reconstrucción local al recibir, garantizando precisión absoluta sin importar dónde esté el usuario.

### 2. Docker & Prisma
El backend no depende de instalaciones locales complejas.

La base de datos PostgreSQL corre aislada en un contenedor Docker.

Prisma ORM gestiona el esquema y las migraciones, proporcionando seguridad de tipos (Type Safety) entre la DB y el código TypeScript.

###3. Inyección de Dependencias
Usamos get_it para inyectar repositorios, casos de uso y BLoCs. Esto desacopla las clases y facilita la creación de mocks para testing.

## ⚙️ Cómo ejecutar el proyecto
1. Backend
Bash
### Entrar a la carpeta del servidor
cd backend

### Instalar dependencias
npm install

### Levantar Base de Datos (Docker debe estar abierto)
docker-compose up -d

### Generar cliente de Prisma
npx prisma generate

### Iniciar servidor en modo desarrollo
npm run dev
2. Frontend (Flutter)
Bash
### Instalar dependencias
flutter pub get

### Ejecutar la App
flutter run

---

Hecho con 💙 y mucho código limpio.