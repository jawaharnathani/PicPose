import os
import cv2
import numpy as np
import pandas as pd
import json
import mediapipe as mp
import tensorflow as tf
from keras.models import Model
from keras.layers import GlobalAveragePooling2D, Dropout, Dense
from keras.applications import MobileNet
from keras.preprocessing import image as keras_image


def build_nima_model():
    base_model = MobileNet(include_top=False, input_shape=(224, 224, 3))
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dropout(0.75)(x)
    outputs = Dense(10, activation='softmax')(x)
    return Model(inputs=base_model.input, outputs=outputs)

nima_model = build_nima_model()
nima_model.load_weights("mobilenet_weights.h5")
nima_model.trainable = False

def preprocess_image_for_nima(img_path):
    img = keras_image.load_img(img_path, target_size=(224, 224))
    img = keras_image.img_to_array(img)
    img = img / 255.0
    return np.expand_dims(img, axis=0)

def predict_aesthetic_score(img_path):
    img = preprocess_image_for_nima(img_path)
    preds = nima_model.predict(img, verbose=0)[0]
    return round(float(np.sum((np.arange(1, 11)) * preds)), 3)


mp_pose = mp.solutions.pose

def extract_keypoints(results, image_shape):
    if not results.pose_landmarks:
        return None
    h, w = image_shape[:2]
    return np.array([[lm.x * w, lm.y * h] for lm in results.pose_landmarks.landmark])

def pose_complexity_score(keypoints):
    valid = np.all(keypoints != 0, axis=1) & ~np.isnan(keypoints).any(axis=1)
    keypoints = keypoints[valid]
    if len(keypoints) < 5:
        return 0
    center = np.mean(keypoints, axis=0)
    spread = np.mean(np.linalg.norm(keypoints - center, axis=1))
    skeleton = [
        (11, 13), (13, 15), (12, 14), (14, 16),
        (23, 25), (25, 27), (24, 26), (26, 28),
        (11, 12), (23, 24)
    ]
    limb_lengths = [np.linalg.norm(keypoints[i] - keypoints[j])
                    for i, j in skeleton if i < len(keypoints) and j < len(keypoints)]
    return round(0.7 * spread + 0.3 * np.sum(limb_lengths), 2)


from collections import Counter

def is_candidate_match(candidate_meta, input_meta):
    if candidate_meta.get("group_type", "").lower().strip() != input_meta.get("group_type", "").lower().strip():
        return False

    if int(candidate_meta.get("people_count", -1)) != int(input_meta.get("people_count", -2)):
        return False

    candidate_gender_count = Counter(candidate_meta.get("genders", []))
    input_gender_count = Counter(input_meta.get("genders", []))
    if candidate_gender_count != input_gender_count:
        return False

    candidate_ages = candidate_meta.get("ages", [])
    input_ages = input_meta.get("ages", [])
    if len(candidate_ages) != len(input_ages):
        print("Failed at age")
        return False

    for a in input_ages:
        match_found = any(abs(a - c) <= 5 for c in candidate_ages)
        if not match_found:
            return False

    return True


def process_input_object(input_object, pose_min=100, pose_max=600):
    place_title = input_object["place_title"]
    input_meta = input_object["metadata"]
    sub_location = input_object.get("sub_location", "")
    energy_level = input_object.get("energy_level", 5)

    if sub_location:
        folder_path = os.path.join("images", place_title, sub_location)
    else:
        folder_path = os.path.join("images", place_title)

    if not os.path.exists(folder_path):
        print(f"Error: Folder {folder_path} not found.")
        return []

    metadata_path = os.path.join(folder_path, "images_metadata.json")
    if not os.path.exists(metadata_path):
        print(f"Metadata file not found: {metadata_path}")
        return []

    with open(metadata_path, 'r') as f:
        image_metadata = json.load(f)

    filtered_ids = [item['image_path'] for item in image_metadata if is_candidate_match(item, input_meta)]
    if not filtered_ids:
        print("No matching images based on metadata.")
        return []
    print(len(filtered_ids))
    image_files = filtered_ids

    if not image_files:
        print("No matching image files found.")
        return []

    pose_model = mp_pose.Pose(static_image_mode=True, model_complexity=2, min_detection_confidence=0.3)
    energy_level = np.clip(energy_level, 0, 10)
    pose_weight = energy_level / 10.0
    aesthetic_weight = 1.0 - pose_weight

    results = []
    for img_name in image_files:
        img_path = os.path.join(folder_path, img_name)
        try:
            image = cv2.imread(img_path)
            if image is None:
                continue
            if image.shape[1] > 1280:
                scale = 1280 / image.shape[1]
                image = cv2.resize(image, (0, 0), fx=scale, fy=scale)

            results_pose = pose_model.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
            keypoints = extract_keypoints(results_pose, image.shape)
            pose_score = pose_complexity_score(keypoints) if keypoints is not None else 0
            aesthetic_score = predict_aesthetic_score(img_path)

            norm_pose = np.clip((pose_score - pose_min) / (pose_max - pose_min), 0, 1)
            norm_aesthetic = (aesthetic_score - 1) / (10 - 1)
            final_score = aesthetic_weight * norm_aesthetic + pose_weight * norm_pose

            results.append({
                "id": os.path.splitext(img_name)[0],
                "path": img_path,
                "aesthetic_score": aesthetic_score,
                "pose_score": pose_score,
                "final_score": final_score
            })

        except Exception as e:
            print(f"Failed processing {img_name}: {e}")

    df = pd.DataFrame(results)
    df[['id', 'path', 'aesthetic_score', 'pose_score', 'final_score']].to_csv(
        os.path.join(folder_path, "final_scores.csv"), index=False
    )

    top5 = sorted(results, key=lambda x: x["final_score"], reverse=True)[:5]
    return [{"id": i, "path": r["path"]} for i, r in enumerate(top5, 1)]

if __name__ == "__main__":
    input_object = {
        "place_title": "disneyland",
        "metadata": {
            "people_count": "1",
            "genders": "F",
            "props": "glasses",
            "ages": [25],
            "group_type": "single"
        },
        "sub_location": "disney_castle",
        "energy_level": 7
    }
    top_images = process_input_object(input_object)
    print(top_images)
