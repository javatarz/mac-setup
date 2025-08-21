import http.server
import socketserver
import os
import random
import threading
import time
import sys

# List of words for generating memorable passwords
WORD_LIST = [
    "apple", "banana", "cherry", "date", "elder", "fig", "grape", "honeydew",
    "kiwi", "lemon", "mango", "nectarine", "orange", "papaya", "quince",
    "raspberry", "strawberry", "tangerine", "ugli", "vanilla", "watermelon",
    "xigua", "yellow", "zucchini"
]

class FileReceiverHandler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        # Verify password
        if 'X-Password' not in self.headers or self.headers['X-Password'] != self.server.temp_password:
            self.send_response(401) # Unauthorized
            self.end_headers()
            self.wfile.write(b"Unauthorized: Invalid password.")
            print("Unauthorized access attempt.")
            return

        content_length = int(self.headers['Content-Length'])
        file_content = self.rfile.read(content_length)

        filename = self.headers.get('X-File-Name', 'received_archive.zip')

        with open(filename, 'wb') as f:
            f.write(file_content)
        
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"File received successfully!")
        print(f"File '{filename}' received successfully.")
        
        # Signal the server to shut down after receiving the file
        self.server.shutdown()

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # doesn't matter if the host is reachable
        s.connect(('10.255.255.255', 1))
        IP = s.getsockname()[0]
    except Exception:
        IP = '127.0.0.1'
    finally:
        s.close()
    return IP

def generate_password(length=3):
    return "-".join(random.choice(WORD_LIST) for _ in range(length))

def run_server(port=0):
    # Use 0 to let the OS assign a random available port
    with socketserver.TCPServer(("", port), FileReceiverHandler) as httpd:
        httpd.allow_reuse_address = True # Allow immediate reuse of the address
        
        # Get the actual port assigned by the OS
        actual_port = httpd.socket.getsockname()[1]
        local_ip = get_local_ip()
        
        temp_password = generate_password()
        
        print(f"Server started at http://{local_ip}:{actual_port}")
        print(f"Temporary Password: {temp_password}")
        print("Waiting for file...")
        
        # Store password in the server instance for verification
        httpd.temp_password = temp_password

        # Start the server in a separate thread to allow shutdown
        server_thread = threading.Thread(target=httpd.serve_forever)
        server_thread.daemon = True # Allow main program to exit even if thread is running
        server_thread.start()

        # Wait for the server to be signaled to shut down
        # This loop is needed because serve_forever() is in a separate thread
        # and httpd.shutdown() needs to be called from the main thread or another thread
        # that is not httpd.serve_forever()
        while server_thread.is_alive():
            time.sleep(0.1) # Small delay to prevent busy-waiting

        print("Server shutting down.")

if __name__ == "__main__":
    # Ensure the script is run with Python 3
    if sys.version_info[0] < 3:
        print("This script requires Python 3.")
        sys.exit(1)
    
    run_server()
