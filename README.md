# Restaurant Management System

A modern, full-stack restaurant management system built with Ruby on Rails API backend and React frontend. This application provides a complete solution for managing restaurant operations, including menu management, employee management, and customer interactions.

## 🚀 Features

- **User Authentication** - Secure login and registration system
- **Menu Management** - Add, edit, and manage menu items with categories
- **Employee Portal** - Manage staff information and roles
- **Customer Feedback** - Collect and manage customer reviews and ratings
- **Responsive Design** - Works seamlessly on desktop and mobile devices
- **Admin Dashboard** - Comprehensive admin interface for restaurant management

## 🛠️ Prerequisites

- Ruby 3.x
- Rails 7.x
- Node.js 16+
- SQLite 3+
- Yarn package manager

## 🚀 Getting Started

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install Ruby dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: Load sample data
   ```

4. Start the Rails server:
   ```bash
   rails s
   ```

### Frontend Setup (Client)

1. Navigate to the client directory:
   ```bash
   cd client
   ```

2. Install JavaScript dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

### Admin Panel Setup

1. Navigate to the admin directory:
   ```bash
   cd admin
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the admin development server:
   ```bash
   npm run dev
   ```

## 🔒 Environment Variables

Create a `.env` file in the backend directory with the following variables:

```
DATABASE_USERNAME=your_db_username
DATABASE_PASSWORD=your_db_password
JWT_SECRET=your_jwt_secret_key
```

## 🧪 Running Tests

### Backend Tests

```bash
cd backend
bundle exec rspec
```

### Frontend Tests

```bash
cd client
npm test
```

## 🏗️ Project Structure

```
Rails-final-project/
├── backend/           # Rails API
├── client/            # React Frontend
├── admin/             # Admin Dashboard
└── README.md          # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Made with ❤️ by Jabez, Hakim, and Besee
</div>
