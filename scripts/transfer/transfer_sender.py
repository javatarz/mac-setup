import os
import zipfile
import requests
import sys

# Files to be transferred
FILES_TO_TRANSFER = [
    os.path.expanduser("~/.ssh"),
    os.path.expanduser("~/.gnupg"),
    os.path.expanduser("~/.config/fish/conf.d/secrets.fish")
]

def create_zip_archive(output_filename="archive.zip"):
    with zipfile.ZipFile(output_filename, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in FILES_TO_TRANSFER:
            if os.path.exists(file_path):
                if os.path.isfile(file_path):
                    zipf.write(file_path, os.path.basename(file_path))
                elif os.path.isdir(file_path):
                    for root, _, files in os.walk(file_path):
                        for file in files:
                            full_path = os.path.join(root, file)
                            arcname = os.path.relpath(full_path, os.path.dirname(file_path))
                            zipf.write(full_path, arcname)
                print(f"Added {file_path} to archive.")
            else:
                print(f"Warning: {file_path} not found. Skipping.")
    return output_filename

def send_file(url, password, filename):
    headers = {
        'X-Password': password,
        'X-File-Name': os.path.basename(filename)
    }
    with open(filename, 'rb') as f:
        try:
            response = requests.post(url, data=f, headers=headers)
            response.raise_for_status() # Raise an exception for HTTP errors
            print(f"File sent successfully: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Error sending file: {e}")
            sys.exit(1)

if __name__ == "__main__":
    # Ensure the script is run with Python 3
    if sys.version_info[0] < 3:
        print("This script requires Python 3.")
        sys.exit(1)

    # Check if requests library is installed
    try:
        import requests
    except ImportError:
        print("The 'requests' library is not installed. Please install it using: pip install requests")
        sys.exit(1)

    archive_name = create_zip_archive()

    if not os.path.exists(archive_name):
        print("Error: Archive not created. Exiting.")
        sys.exit(1)

    print("\n--- Sender Setup ---")
    receiver_url = input("Enter the receiver's URL (e.g., http://192.168.1.100:8000): ").strip()
    temp_password = input("Enter the temporary password: ").strip()

    print(f"Sending '{archive_name}' to {receiver_url}...")
    send_file(receiver_url, temp_password, archive_name)

    # Clean up the created archive
    os.remove(archive_name)
    print(f"Cleaned up local archive: {archive_name}")
