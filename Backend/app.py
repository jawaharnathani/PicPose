from flask import Flask, request, jsonify, send_file
from io import BytesIO
from PIL import Image
import base64
from dotenv import load_dotenv
load_dotenv()

from llm import analyze_user_image, analyze_location_image, generate_caption
from initialScoring import process_input_object

app = Flask(__name__)


def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return encoded_string


def encode_metadata(metadata):
    result = []
    for key in metadata:
        result.append(f"{key.replace('_', ' ')}: {metadata[key]}")
    return result


@app.route('/process-images', methods=['POST'])
def process_images():
    if 'user_image' not in request.files:
        print("User Image not available")
        return jsonify({'error': 'user_image is required'}), 400
    elif 'place_title' not in request.form:
        print("Place title not available")
        return jsonify({'error': 'place_title is required'}), 400
    elif 'energy_level' not in request.form:
        print("Energy level not available")
        return jsonify({'error': 'energy_level is required'}), 400

    user_image = request.files['user_image']
    location_image = request.files.get('location_image')
    place_title = request.form.get('place_title')
    energy_level = int(float(request.form.get('energy_level')))

    search_input = {}

    user_metadata = analyze_user_image(user_image, place_title)
    if 'image_id' in user_metadata:
        user_metadata.pop('image_id')
    if 'location_id' in user_metadata:
        user_metadata.pop('location_id')
    search_input['metadata'] = user_metadata

    if location_image:
        sub_location = analyze_location_image(location_image)
        search_input['sub_location'] = sub_location
    
    search_input['place_title'] = place_title
    search_input['energy_level'] = energy_level

    result_images = []

    recommended_images = process_input_object(search_input)
    print(recommended_images)
    for image in recommended_images:
        image_data = encode_image(image['path'])
        caption = generate_caption(image_data)

        result_images.append({
            'id': str(image['id']),
            'caption': caption,
            'data': image_data
        })
    
    result = {
        "metadata": encode_metadata(user_metadata),
        "images": result_images
    }

    return jsonify(result)


if __name__ == '__main__':
    app.run(debug=True)
