import pandas as pd
import tensorflow as tf
import numpy as np
import json
from keras.models import Model
from keras.layers import Input, Dense, Subtract

df = pd.read_csv("images/disneyland/disney_castle_old/final_scores.csv")  # columns: id, path, aesthetic_score, pose_score, final_score

feedback_data = [
    {"id": "04dffd83-8ab9-4cf7-ba41-e760f0a2d653", "liked": True},
    {"id": "6aba04d2-74fc-4445-b5be-4cc57dd1ce03", "liked": True},
    {"id": "6d8ccf7a-c0b3-4a6e-86b3-f9446da63509", "liked": False},
    {"id": "28c6042a-7c2c-49c7-82a0-efee45a2fb1e", "liked": False},
    {"id": "98fb10eb-97c8-4477-bd6e-0c099c72b9ab", "liked": True}
]


positive_ids = [entry["id"] for entry in feedback_data if entry["liked"]]
negative_ids = [entry["id"] for entry in feedback_data if not entry["liked"]]

print(f"Positive images: {positive_ids}")
print(f"Negative images: {negative_ids}")

pairs = []
for pos_id in positive_ids:
    for neg_id in negative_ids:
        pairs.append((pos_id, neg_id))

print(f"Total training pairs: {len(pairs)}")

feature_map = {}
for idx, row in df.iterrows():
    features = np.array([row['aesthetic_score'], row['pose_score']])
    feature_map[row['id']] = features

X1, X2, y = [], [], []
for winner, loser in pairs:
    if winner in feature_map and loser in feature_map:
        X1.append(feature_map[winner])
        X2.append(feature_map[loser])
        y.append(1)  # winner > loser

X1 = np.array(X1)
X2 = np.array(X2)
y = np.array(y, dtype=np.float32)

print(f"Prepared {X1.shape[0]} training samples.")

feature_dim = 2 

def build_ranknet():
    input_features = Input(shape=(feature_dim,))
    x = Dense(16, activation='relu')(input_features)
    x = Dense(8, activation='relu')(x)
    x = Dense(1)(x)  # output = ranking score
    return Model(inputs=input_features, outputs=x)

ranknet_model = build_ranknet()
ranknet_model.summary()

input_1 = Input(shape=(feature_dim,))
input_2 = Input(shape=(feature_dim,))

score_1 = ranknet_model(input_1)
score_2 = ranknet_model(input_2)

score_diff = Subtract()([score_1, score_2])

#pairwise loss
def ranknet_loss(y_true, y_pred):
    return tf.reduce_mean(tf.nn.sigmoid_cross_entropy_with_logits(labels=y_true, logits=y_pred))

final_model = Model(inputs=[input_1, input_2], outputs=score_diff)
final_model.compile(optimizer='adam', loss=ranknet_loss)

final_model.summary()
final_model.fit([X1, X2], y, batch_size=16, epochs=30)

all_features = np.array([feature_map[name] for name in df['id']])
predicted_scores = ranknet_model.predict(all_features).squeeze()

df['RankNet Predicted Score'] = predicted_scores

df = df.sort_values("RankNet Predicted Score", ascending=False)
df.to_csv("ranknet_updated_scores.csv", index=False)
