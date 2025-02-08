const mongoose = require("mongoose"); // Add this line

const QuestionSchema = new mongoose.Schema({
  question: { type: String, required: true },
  answer: { type: String, required: true },
});

const FaqSchema = new mongoose.Schema({
  category: { type: String, required: true, unique: true },
  questions: [QuestionSchema], // Store multiple Q&A under each category
});

module.exports = mongoose.model("Faq", FaqSchema);
