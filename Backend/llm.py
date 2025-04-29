import os, sys, json, base64, requests
from pathlib import Path

API_KEY = os.getenv("GOOGLE_API_KEY")
if not API_KEY:
    print("API KEY Not Found or Invalid", file=sys.stderr)
    sys.exit(1)

MODEL    = "gemini-2.5-flash-preview-04-17"
ENDPOINT = (
    f"https://generativelanguage.googleapis.com/v1beta/"
    f"models/{MODEL}:generateContent?key={API_KEY}"
)

def analyze_user_image(img, location_id) -> dict:
    data = base64.b64encode(img.read()).decode('utf-8')

    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "inlineData": {
                            "mimeType": "image/jpeg",
                            "data": data
                        }
                    },
                    {
                        "text": (
                            """
                            You are an image analysis assistant.  When given a single image, you MUST
                            return *only* a JSON object with exactly these keys:

                            "image_id": string            // filename, e.g. "img123.jpg"
                            "location_id": string         // choose only from the following options - "Disney Land", "Eiffel Tower", "Anime Park", "Tower Bridge (London)"
                            "people_count": integer       // Focus only the main person/people in the image not anyone in the background
                            "ages": [int,…]
                            "genders": ["M" or "F", …]
                            "props": [string,…]          // e.g. ["backpack","sunglasses"]
                            "group_type": string          // "single","couple" or "family"

                            No extra text, no surrounding markdown—just the JSON.
                            """
                            f"Context: location_id={location_id}."
                        )
                    }
                ]
            }
        ]
    }

    resp = requests.post(ENDPOINT, json=payload)
    resp.raise_for_status()

    body = resp.json()
    if "candidates" in body:
        content = body["candidates"][0].get("content")
        if isinstance(content, str):
            return json.loads(content)
        elif isinstance(content, dict):
            return json.loads('\n'.join(content['parts'][0]['text'].split('\n')[1:-1]))
        else:
            raise ValueError(f"Unexpected content type: {type(content)}")
    return body


def analyze_location_image(img) -> str:
    data = base64.b64encode(img.read()).decode('utf-8')

    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "inlineData": {
                            "mimeType": "image/jpeg",
                            "data": data
                        }
                    },
                    {
                        "text": (
                            """
                            You are an image analysis assistant.  When given a single image, you MUST
                            return *only a specific sub location inside Disney Land, Florida* where the image is taken
                            select the sub location from the below given options which is most similar to the image:
                            No extra text, no surrounding markdown—just the string.

                            Sub Locations:
                            - disney_castle
                            - disney_pals
                            - pixar_pier
                            - adventure_park

                            Context: Analyse the attached Image.
                            """
                        )
                    }
                ]
            }
        ]
    }

    resp = requests.post(ENDPOINT, json=payload)
    resp.raise_for_status()

    body = resp.json()
    if "candidates" in body:
        content = body["candidates"][0].get("content")
        if isinstance(content, str):
            return content
        elif isinstance(content, dict):
            return content['parts'][0]['text']
        else:
            raise ValueError(f"Unexpected content type: {type(content)}")
    return str(body)



def generate_caption(data) -> str:

    payload = {
        "contents": [
            {
                "parts": [
                    {
                        "inlineData": {
                            "mimeType": "image/jpeg",
                            "data": data
                        }
                    },
                    {
                        "text": (
                            """
                            You are an image analysis assistant.  When given a single image, you MUST
                            return *only one or two word caption* to post on social media along with the image:
                            No extra text, no surrounding markdown—just the string.

                            Context: Analyse the attached Image.
                            """
                        )
                    }
                ]
            }
        ]
    }

    resp = requests.post(ENDPOINT, json=payload)
    resp.raise_for_status()

    body = resp.json()
    if "candidates" in body:
        content = body["candidates"][0].get("content")
        if isinstance(content, str):
            return content
        elif isinstance(content, dict):
            return content['parts'][0]['text']
        else:
            raise ValueError(f"Unexpected content type: {type(content)}")
    return str(body)