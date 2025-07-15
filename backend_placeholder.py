from flask import Flask, jsonify, request
app = Flask(__name__)

@app.route('/api/events', methods=['GET'])
def get_events():
    return jsonify({'events': []})

@app.route('/api/events', methods=['POST'])
def create_event():
    return jsonify({'message': 'Event created'}), 201

@app.route('/api/events/<event_id>', methods=['GET'])
def get_event_details(event_id):
    return jsonify({'event': {}})

@app.route('/api/events/join/<event_id>', methods=['POST'])
def join_event(event_id):
    return jsonify({'message': 'Joined event'})

@app.route('/api/events/user/<user_id>', methods=['GET'])
def get_user_events(user_id):
    return jsonify({'events': []})

@app.route('/api/events/confirm/<event_id>', methods=['GET'])
def confirm_event(event_id):
    return jsonify({'message': 'Event confirmed'})

if __name__ == '__main__':
    app.run(debug=True, port=5000) 