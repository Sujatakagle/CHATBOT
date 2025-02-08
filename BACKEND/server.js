const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const socketIo = require("socket.io");
const cors = require("cors");

// Initialize Express and HTTP Server
const app = express();
const server = http.createServer(app);
const io = socketIo(server, {
  cors: {
    origin: "*", // Allow all origins
    methods: ["GET", "POST"],
  },
});

// Middleware
app.use(cors());
app.use(express.json());

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/faqsDB", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB Connected"))
  .catch((err) => console.error("MongoDB Connection Error:", err));

// Define FAQ Schema & Model
const faqSchema = new mongoose.Schema({
  category: String,
  questions: [
    {
      question: String,
      answer: String,
    },
  ],
});

const FAQ = mongoose.model("FAQ", faqSchema);

// WebSocket Connection
io.on("connection", (socket) => {
  console.log("New client connected");

  // Send list of categories to the client when connected
  socket.on("getCategories", async () => {
    try {
      const categories = await FAQ.find({}, "category");
      socket.emit("categories", categories); // Send categories to client
    } catch (error) {
      console.error("Error fetching categories:", error);
      socket.emit("error", { message: "Error fetching categories" });
    }
  });

  // Insert FAQs via WebSocket
  socket.on("insertFAQ", async (data) => {
    try {
      console.log("Received insertFAQ data:", JSON.stringify(data, null, 2));

      if (!data || !data.category || !Array.isArray(data.questions)) {
        console.log("Invalid data format received");
        return socket.emit("error", { message: "Invalid data format" });
      }

      // Check MongoDB connection status
      if (mongoose.connection.readyState !== 1) {
        console.log("MongoDB not connected");
        return socket.emit("error", { message: "MongoDB not connected" });
      }

      console.log("Checking existing FAQ category in DB...");
      let existingCategory = await FAQ.findOne({ category: data.category });

      if (existingCategory) {
        console.log(`Found existing category: ${data.category}`);
        existingCategory.questions.push(...data.questions);
        await existingCategory.save();
        console.log(`FAQs updated in category: ${data.category}`);
      } else {
        console.log(`No existing category found, creating a new one...`);
        const newFAQ = new FAQ(data);
        await newFAQ.save();
        console.log(`New FAQ category added: ${data.category}`);
      }

      io.emit("faqInserted", { message: "FAQs added successfully" });
    } catch (error) {
      console.error("Error inserting FAQs:", error);
      socket.emit("error", { message: "Error inserting FAQs" });
    }
  });

  // Fetch FAQs by Category via WebSocket
  socket.on("getFaq", async (category) => {
    try {
      const faqData = await FAQ.findOne({ category });

      if (faqData) {
        socket.emit("faqList", faqData.questions);
      } else {
        socket.emit("faqList", []);
      }
    } catch (error) {
      console.error("Error fetching FAQs:", error);
      socket.emit("error", { message: "Error fetching FAQs" });
    }
  });

  // Fetch Answer for a Specific Question via WebSocket
  socket.on("getAnswer", async ({ category, question }) => {
    try {
      const faqData = await FAQ.findOne({ category });
  
      if (faqData) {
        const foundQuestion = faqData.questions.find((q) => q.question === question);
  
        if (foundQuestion) {
          socket.emit("answer", {
            question: foundQuestion.question,
            answer: foundQuestion.answer,
          });
        } else {
          // If question is not found, return "We will update soon."
          socket.emit("answer", { question, answer: "We will update soon." });
        }
      } else {
        // If category is not found, return "We will update soon."
        socket.emit("answer", { question, answer: "We will update soon." });
      }
    } catch (error) {
      console.error("Error fetching answer:", error);
      socket.emit("error", { message: "Error fetching answer" });
    }
  });
  

  socket.on("disconnect", () => {
    console.log("Client disconnected");
  });
});

// Start Server
const PORT = 5000;
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
