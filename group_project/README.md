# Music Management System

A web-based music management system built with Java Web technologies (Servlet, JSP, JSTL) and SQL Server.

## Features

- User Authentication & Authorization
  - Login/Register with username and password
  - Remember me functionality using cookies
  - Role-based access control (User/Admin)

- Music Management
  - Browse and search songs
  - Play music with built-in audio player
  - Create and manage playlists
  - Upload and manage songs (Admin)

- User Management (Admin)
  - View all users
  - Edit user roles and status
  - Delete users

## Prerequisites

- JDK 8 or later
- Apache Tomcat 8.5 or later
- SQL Server 2014 or later
- NetBeans IDE (recommended)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/music-management.git
```

2. Create the database:
- Open SQL Server Management Studio
- Execute the SQL script in `database.sql`

3. Configure the database connection:
- Open `src/java/dao/DBContext.java`
- Update the connection parameters (url, username, password)

4. Configure the file upload location:
- Open `web/WEB-INF/web.xml`
- Update the `upload.location` parameter value

5. Add required libraries:
- JSTL 1.2.1
- SQL Server JDBC Driver
- Google Gson
- Commons FileUpload

6. Build and deploy:
- Open the project in NetBeans
- Right-click the project and select "Clean and Build"
- Right-click the project and select "Deploy"

## Usage

1. Start the application:
- Make sure Tomcat is running
- Access `http://localhost:8080/MusicManagement`

2. Default admin account:
- Username: admin
- Password: admin123

3. User functions:
- Browse and search songs
- Create playlists
- Play music
- Update profile

4. Admin functions:
- Manage songs (add, edit, delete)
- Manage users
- View statistics

## Project Structure

```
music-management/
├── src/
│   └── java/
│       ├── controller/    # Servlet controllers
│       ├── dao/          # Data Access Objects
│       ├── model/        # Java Beans
│       ├── filter/       # Security filters
│       └── utils/        # Utility classes
├── web/
│   ├── WEB-INF/
│   │   ├── views/       # JSP files
│   │   └── web.xml      # Web configuration
│   └── resources/       # Static resources
└── database.sql         # Database script
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 