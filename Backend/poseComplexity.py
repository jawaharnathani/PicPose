import cv2
import numpy as np
import mediapipe as mp

# Load a single image
image = cv2.imread("images/couple.jpeg")

if image.shape[1] > 1280:
    scale = 1280 / image.shape[1]
    image = cv2.resize(image, (0, 0), fx=scale, fy=scale)

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True, model_complexity=2, min_detection_confidence=0.3)

results = pose.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

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
    limb_score = np.sum(limb_lengths)
    return round(0.7 * spread + 0.3 * limb_score, 2)

keypoints = extract_keypoints(results, image.shape)
score = pose_complexity_score(keypoints) if keypoints is not None else 0
print("Pose Complexity Score:", score)
