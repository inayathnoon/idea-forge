import requests

def test_parse():
    url = "http://127.0.0.1:8000/api/parse_resume"
    files = {'file': open('dummy_resume.pdf', 'rb')}
    
    try:
        print("Sending request to parse resume...")
        response = requests.post(url, files=files)
        if response.status_code == 200:
            print("Success!")
            print(response.json())
        else:
            print(f"Failed: {response.status_code}")
            print(response.text)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_parse()
