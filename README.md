# protocol-buffer-vultest

A simple web application for testing whether security scanners can detect vulnerabilities in applications using Protocol Buffers.

## Overview

This application demonstrates a counter functionality where users can click a button to increment a score. The application uses Protocol Buffers for client-server communication and **intentionally contains SQL injection vulnerabilities** for testing security scanning tools.

## Features

- **Protocol Buffer Communication**: All API requests/responses use Protocol Buffer encoding
- **Counter Functionality**: Users can increment a counter by clicking a button
- **Vulnerable Username Field**: The username field is susceptible to SQL injection attacks (intentional)
- **Modifiable Score**: Users can set the next score to any value, including very large numbers

## Installation

1. Install dependencies:
```bash
pip3 install -r requirements.txt
```

2. Compile the Protocol Buffer definition:
```bash
protoc --python_out=. counter.proto
```

## Running the Application

Start the Flask server:
```bash
python3 app.py
```

The application will be available at `http://localhost:5000`

## Usage

1. Open your browser and navigate to `http://localhost:5000`
2. Enter a username (default: "testuser")
3. Set the next score value (default: 1)
4. Click "Increment Counter" to update the score
5. The current score will be displayed and stored in the database

## Security Testing

⚠️ **WARNING**: This application contains intentional security vulnerabilities for testing purposes only. **DO NOT deploy to production**.

### SQL Injection Vulnerability

The username field is vulnerable to SQL injection. Example payloads:
- `' OR '1'='1` - Bypass authentication
- `'; DROP TABLE user_scores; --` - Drop table
- `' UNION SELECT score FROM user_scores --` - Data extraction

### Modifiable Score

The next_score parameter can be modified to any value, allowing users to set arbitrary scores without proper validation.

## Files

- `counter.proto` - Protocol Buffer schema definition
- `counter_pb2.py` - Generated Python code from proto file
- `app.py` - Flask backend server with SQL injection vulnerability
- `index.html` - Frontend web interface
- `requirements.txt` - Python dependencies
