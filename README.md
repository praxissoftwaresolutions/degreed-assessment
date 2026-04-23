# degreed-assessment

## Project Overview

degreed-assessment is a programming assignment repository created to demonstrate a full-stack engineering solution for a technical evaluation. The project includes clean architecture, clearly organized source code, and implementation of the required features to solve the assessment problem statement.

## TODOs

- [ ] Modulize Terraform code and move to separate files for better organization and readability
- [ ] Automate the addition of the api managed identity used to query the database.
      -- 1. Create a database user mapped to your Managed Identity
            CREATE USER [mid-api] FROM EXTERNAL PROVIDER;

      -- 2. Grant the identity permission to read and write data
         -- For a demo, 'db_datareader' and 'db_datawriter' are perfect.
         ALTER ROLE db_datareader ADD MEMBER [mid-api];
         ALTER ROLE db_datawriter ADD MEMBER [mid-api];

      -- 3. (Optional) Grant DDL permissions if your C# app uses Entity Framework 
          -- to create tables (Migrations)
          ALTER ROLE db_ddladmin ADD MEMBER [mid-api];
      GO


Grant Permissions in SQL Server 
The SQL Server won't recognize your identity by default. You must manually add your user (for local testing) and the AKS Identity (for the cluster) as users in the database. 
- [ ] Write unit tests
- [ ] Deploy application

## Key Features

- Modular and maintainable code structure.
- Clear separation of concerns between application layers.
- Functional implementation of assessment requirements.
- Support for development and production workflows.
- Automated tests and validation logic.

## Repository Structure

- `README.md` - Project documentation and usage instructions.
- `src/` - Main source code for the application.
- `tests/` - Automated tests and validation logic.
- `package.json` / `requirements.txt` - Dependency definitions and scripts.
- `docs/` - Supplementary documentation and design notes, when available.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-org/degreed-assessment.git
   cd degreed-assessment
   ```

2. Install dependencies:

   - For Node.js projects:
     ```bash
     npm install
     ```

   - For Python projects:
     ```bash
     pip install -r requirements.txt
     ```

## Usage

1. Start the application:

   - Node.js:
     ```bash
     npm start
     ```

   - Python:
     ```bash
     python src/main.py
     ```

2. Open the local development environment in your browser if the project includes a web interface.

3. Run tests:

   - Node.js:
     ```bash
     npm test
     ```

   - Python:
     ```bash
     pytest
     ```

## Development Guidelines

- Extend the project by adding new features in the appropriate modules.
- Keep business logic separated from configuration and infrastructure code.
- Use consistent naming and formatting conventions.
- Write automated tests for new functionality and regressions.

## Notes

- Update the example commands based on the repository's actual language and package manager.
- The repository is designed to be easy to extend and adapt for future assessment enhancements.

## Contact

For questions about the project, reach out to the repository owner or the technical assessment contact.
