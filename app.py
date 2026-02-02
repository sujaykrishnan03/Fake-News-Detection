from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
from preprocess import preprocess_text

app = Flask(__name__)
CORS(app)

# Load trained model and vectorizer
model = joblib.load("fake_news_model.pkl")
vectorizer = joblib.load("tfidf_vectorizer.pkl")

@app.route("/predict", methods=["POST"])
def predict():
    data = request.json
    news_text = data.get("text", "")

    if not news_text.strip():
        return jsonify({"error": "Empty input"}), 400

    processed_text = preprocess_text(news_text)
    vectorized_text = vectorizer.transform([processed_text])

    prediction = model.predict(vectorized_text)[0]
    confidence = model.predict_proba(vectorized_text).max()

    return jsonify({
        "prediction": "REAL NEWS" if prediction == 1 else "FAKE NEWS",
        "confidence": round(confidence * 100, 2)
    })

if __name__ == "__main__":
    app.run(debug=True)
