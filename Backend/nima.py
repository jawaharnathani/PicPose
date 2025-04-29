import os
import numpy as np
import tensorflow as tf
from keras.models import Model
from keras.layers import GlobalAveragePooling2D, Dropout, Dense
from keras.applications import MobileNet
from keras.preprocessing import image as keras_image
import pandas as pd

def build_nima_model():
    base_model = MobileNet(include_top=False, input_shape=(224, 224, 3))
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.75)(x)
    outputs = Dense(10, activation='softmax')(x)  # 10 classes for score distribution
    model = Model(inputs=base_model.input, outputs=outputs)
    return model

device = "gpu" if tf.config.list_physical_devices('GPU') else "cpu"

nima_model = build_nima_model()
nima_model.load_weights("mobilenet_weights.h5")  

def preprocess_image(img_path):
    img = keras_image.load_img(img_path, target_size=(224, 224))
    img = keras_image.img_to_array(img)
    img = img / 255.0
    img = np.expand_dims(img, axis=0)
    return img

def predict_aesthetic_score(img_path):
    img = preprocess_image(img_path)
    preds = nima_model.predict(img, verbose=0)[0]  
    mean_score = np.sum((np.arange(1, 11)) * preds)  
    return round(float(mean_score), 3)

def score_images_in_folder(folder_path, output_csv="aesthetic_scores.csv"):
    image_files = [f for f in os.listdir(folder_path) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
    scores = []

    for img_name in image_files:
        img_path = os.path.join(folder_path, img_name)
        try:
            score = predict_aesthetic_score(img_path)
            print(f"{img_name}: {score}")
            scores.append((img_name, score))
        except Exception as e:
            print(f"Failed to process {img_name}: {e}")

    df = pd.DataFrame(scores, columns=["Image Name", "Aesthetic Score"])
    df.to_csv(output_csv, index=False)

if __name__ == "__main__":
    folder_path = "images/"  
    score_images_in_folder(folder_path)
