from flask import Flask, request, jsonify, send_from_directory
import sqlite3
import counter_pb2

app = Flask(__name__, static_folder='.')

# Initialize database
def init_db():
    conn = sqlite3.connect('scores.db')
    cursor = conn.cursor()
    # Create table with SQL
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS user_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            score INTEGER NOT NULL
        )
    ''')
    conn.commit()
    conn.close()

# Initialize database on startup
init_db()

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/api/counter', methods=['POST'])
def counter():
    try:
        # Parse Protocol Buffer message from request
        request_data = counter_pb2.CounterRequest()
        request_data.ParseFromString(request.data)
        
        username = request_data.username
        next_score = request_data.next_score
        
        # INTENTIONAL SQL INJECTION VULNERABILITY - for testing scanners
        # DO NOT USE IN PRODUCTION
        # Note: Database connection is also not properly managed (no try-finally)
        conn = sqlite3.connect('scores.db')
        cursor = conn.cursor()
        
        # Vulnerable SQL query - username is not sanitized
        query = f"SELECT score FROM user_scores WHERE username = '{username}'"
        cursor.execute(query)
        result = cursor.fetchone()
        
        if result:
            # Update existing user's score
            current_score = result[0]
            new_score = next_score
            update_query = f"UPDATE user_scores SET score = {new_score} WHERE username = '{username}'"
            cursor.execute(update_query)
        else:
            # Insert new user
            new_score = next_score
            insert_query = f"INSERT INTO user_scores (username, score) VALUES ('{username}', {new_score})"
            cursor.execute(insert_query)
        
        conn.commit()
        conn.close()
        
        # Create response
        response = counter_pb2.CounterResponse()
        response.username = username
        response.current_score = new_score
        response.message = f"Score updated to {new_score}"
        
        # Return Protocol Buffer serialized response
        return response.SerializeToString(), 200, {'Content-Type': 'application/x-protobuf'}
        
    except Exception as e:
        # Return error as JSON for easier debugging
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    # Debug mode and 0.0.0.0 host are for testing only
    # DO NOT use these settings in production
    app.run(debug=True, host='0.0.0.0', port=5000)
