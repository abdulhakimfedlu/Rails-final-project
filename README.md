# Restaurant Management System

A restaurant management platform with customer and admin interfaces.

## What it does

- **Customer App**: Browse menu, leave comments and ratings
- **Admin Dashboard**: Manage menu items, employees, and customer feedback
- **API Backend**: Handles all data and authentication

## How to run

**You need:** Ruby 3.x, Node.js 16+

### 1. Clone the project
```bash
git clone https://github.com/abdulhakimfedlu/Rails-final-project
cd Rails-final-project
```

### 2. Start the backend (Terminal 1)
```bash
cd backend
bundle install
cp .env.example .env
rails db:create db:migrate db:seed
rails server
```

### 3. Start customer app (Terminal 2)
```bash
cd client
npm install
npm run dev
```

### 4. Start admin app (Terminal 3)
```bash
cd admin
npm install
npm run dev
```

## Access the apps

- **Customer**: http://localhost:5173
- **Admin**: http://localhost:5174
- **Login**: Phone `0987654321`, Password `0987654321`

## How to test

```bash
cd backend
bundle exec rspec
```

---

Built by Jabez, Hakim, and Besee