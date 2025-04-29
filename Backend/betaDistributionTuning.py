import pandas as pd

initial_scores_df = pd.read_csv("final_scores.csv")

# load likes, sample data below
likes_data = {
    "couple.jpeg": (15, 5),
    "family.jpeg": (7, 2),
    "solo_jump.jpeg": (10, 1),
    "boring_stand.jpeg": (1, 9),
}

def bayesian_score(likes, dislikes, prior_alpha=1, prior_beta=1):
    alpha = likes + prior_alpha
    beta = dislikes + prior_beta
    return alpha / (alpha + beta)

updated_scores = []
for idx, row in initial_scores_df.iterrows():
    img_name = row['Image Name']
    init_score = row['Final Combined Score']
    
    if img_name in likes_data:
        likes, dislikes = likes_data[img_name]
        bayes_like_prob = bayesian_score(likes, dislikes)
        
        final_updated_score = 0.7 * init_score + 0.3 * bayes_like_prob
    else:
        # If no feedback, retain original score
        final_updated_score = init_score

    updated_scores.append((img_name, init_score, final_updated_score))

updated_df = pd.DataFrame(updated_scores, columns=["Image Name", "Initial Score", "Updated Score"])
updated_df = updated_df.sort_values("Updated Score", ascending=False)

print(updated_df)

updated_df.to_csv("updated_final_scores.csv", index=False)
