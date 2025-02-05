from flask import Flask, request, jsonify
import face_recognition
from PIL import Image, ExifTags
import io
import numpy as np
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

def correct_image_orientation(image):
    try:
        for orientation in ExifTags.TAGS.keys():
            if ExifTags.TAGS[orientation] == 'Orientation':
                break
        exif = image._getexif()
        if exif is not None:
            orientation = exif.get(orientation, 1)
            if orientation == 3:
                image = image.rotate(180, expand=True)
            elif orientation == 6:
                image = image.rotate(270, expand=True)
            elif orientation == 8:
                image = image.rotate(90, expand=True)
    except (AttributeError, KeyError, IndexError):
        # Image does not have EXIF data
        pass
    return image

@app.route('/imagecompare', methods=['POST'])
def compare():
    if 'image1' not in request.files or 'image2' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file1 = request.files['image1']
    file2 = request.files['image2']

    if file1.filename == '' or file2.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    try:
        # Read image files
        image1 = Image.open(io.BytesIO(file1.read()))
        image2 = Image.open(io.BytesIO(file2.read()))

        # Correct orientation
        image1 = correct_image_orientation(image1)
        image2 = correct_image_orientation(image2)

        # Convert images to numpy arrays
        image1 = np.array(image1)
        image2 = np.array(image2)

        # Log image properties
        print("Image1 shape:", image1.shape)
        print("Image2 shape:", image2.shape)

        encodings1 = face_recognition.face_encodings(image1)
        encodings2 = face_recognition.face_encodings(image2)

        if len(encodings1) == 0 or len(encodings2) == 0:
            return jsonify({'error': 'No faces found in one or both images'}), 400

        result = face_recognition.compare_faces([encodings1[0]], encodings2[0])
        return jsonify({'match': bool(result[0])})  # Ensure the boolean value is serialized correctly
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/hello', methods=['GET'])
def hello():
    return "Hello"
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
