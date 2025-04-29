<p align="center">
  <img src="https://github.com/user-attachments/assets/3ab20da2-a2a3-40ee-8a47-3b8557dc2402" alt="PicPose Logo" width="200"/>
</p>

# PicPose: Intelligent Pose Suggestion for Better Photos

PicPose is an AI-powered photo suggestion tool that recommends creative and personalized poses based on a group photo, location, and desired energy level. It uses a combination of aesthetic scoring (NIMA), pose complexity estimation (MediaPipe), and learning-to-rank models (RankNet, Bayesian updates) to rank and refine photo suggestions.

---

## Repository Structure
```bash
Frontend
├── PicPose_app                  # Contains all views, assets and function calls required to communicate with the backend server

Backend
├── images/                      # Folder containing images categorized by location/sub-location
├── mobilenet_weights.h5         # Pretrained NIMA MobileNet weights (for aesthetic score prediction)
├── neural-image-assessment/     # clone of official NIMA model repo for training
├── initialScoring.py            # Initial ranking using aesthetic + pose complexity scores
├── poseComplexity.py            # Helper for pose complexity score using MediaPipe
├── nima.py                      # Loads and scores images using NIMA model (Keras)
├── betaDistributionTuning.py    # Bayesian re-ranking of poses based on user swipe feedback
├── fineTuning.py                # RankNet re-ranking using pairwise training based on user preferences
├── app.py                       # Flask routers to communicate with the app (Frontend)
├── llm.py                       # Uses Gemini LLM for metadata extraction
```

---

## File Descriptions

### `initialScoring.py`
- Core module to **compute initial rankings** of images using:
  - Aesthetic score (via NIMA)
  - Pose complexity score (via MediaPipe)
  - Energy level to balance between aesthetics and complexity
- Saves all scores to `final_scores.csv` for future re-ranking.

### `poseComplexity.py`
- Computes **pose complexity score** for a given image using MediaPipe's body landmarks.
- Used internally by `initialScoring.py`.

### `nima.py`
- Loads the MobileNet-based NIMA model.
- Computes **aesthetic quality scores** on images.
- Used internally by `initialScoring.py`.

### `betaDistributionTuning.py`
- Re-ranks images using **Bayesian updates** based on swipe data (likes/dislikes).
- Each image gets a Beta(α, β) distribution; posterior mean is used as updated score.

### `fineTuning.py`
- Uses **RankNet (pairwise neural network)** to fine-tune pose rankings.
- Reads `final_scores.csv` and a JSON of swipe feedback to learn preference order.
- Outputs `ranknet_updated_scores.csv`.

### Running fineTuning.py
####  Inputs
•⁠  ⁠*images/* folder (organized by location)
•⁠  ⁠⁠final_scores.csv ⁠ (contains: ⁠ id ⁠, ⁠ aesthetic_score ⁠, ⁠ pose_score ⁠, ⁠ final_score⁠)
•⁠  ⁠User feedback (likes/dislikes per image)
#### Output
•⁠  `⁠ranknet_updated_scores.csv` - final rankings after batch processing

### `app.py`
- Receives the user image, location image, and desired energy level from the PicPose iOS app.
- Uses a large language model (LLM) to generate metadata and calls the `process_input_object` function to retrieve the top 5 recommended images.
- Sends the recommended images back to the app for display.

### `llm.py`
- Handles three separate LLM API calls:
- 1: Generates metadata for the user's image.
- 2: Identifies sub-locations within Disneyland (currently specific to Disneyland only).
- 3: Generates engaging and context-appropriate social media captions for the recommended images.
---

## Input Format

```json
{
  "place_title": "disneyland",
  "metadata": {
    "people_count": 1,
    "genders": "F",
    "props": "glasses",
    "ages": [25],
    "group_type": "single"
  },
  "sub_location": "disney_castle",
  "energy_level": 7
}
```

## How to Install and Run

### Backend

- Install all the Backend requirements using
```Python
pip install -r requirements.txt
```

- Run Backend server
```Python
python app.py
```

### Frontend
- Xcode is required for compiling on macOS.
- Open Terminal and run:

```bash
xcode-select --install
```

- Load the PicPose_app project into xcode ide and run the app.
- Change backend server address and port (in `UploadPageView.swift` at line 315) accordingly if needed.

# Installing PicPose App (iOS)

This project provides an ⁠ .ipa ⁠ file for manual installation.

---

## How to Install App on iOS device

1.⁠ ⁠Download the ⁠ PicPose.ipa ⁠ file from this repository.

2.⁠ ⁠Install it using one of the following:
   - *AltStore*
   - *Xcode*

3.⁠ ⁠Trust the app developer if prompted under:  
   *Settings → General → Device Management*

We didn’t publish in the Appstore because of several restrictions.

## Credits
MediaPipe Pose Estimation

NIMA (Neural Image Assessment) by Titu1994

RankNet paper (Burges et al., Microsoft Research)
