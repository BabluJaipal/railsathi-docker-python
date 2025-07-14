# railsathi-docker-python

# RailSathi - A Simple Python Script Dockerized

**RailSathi** is a beginner-friendly Python project designed to simulate a basic railway assistant interaction.  
This project demonstrates how a simple CLI Python application can be containerized using **Docker**.

## 🚀 Features
- Command-line interaction with user input.
- Collects user name and destination.
- Greets the user and confirms their train status.
- Fully Dockerized – runs in an isolated container environment.

## 🛠️ Technologies Used
- Python 3.9
- Docker

## 📦 How to Run (Using Docker)
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/railsathi-docker-python.git
   cd railsathi-docker-python
docker build -t railsathi-app .
docker run -it railsathi-app



railsathi-docker-python/
│
├── app.py         # Main Python script
└── Dockerfile     # Docker configuration file
