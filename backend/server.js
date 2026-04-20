import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 10000;
const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

// ─────────────────────────────────────────────
// HEALTH CHECK
// ─────────────────────────────────────────────
app.get("/", (req, res) => {
  res.send("Backend is running");
});

// ─────────────────────────────────────────────
// RECOMMENDATION ENDPOINT
// ─────────────────────────────────────────────
app.post("/recommend", async (req, res) => {
  try {
    const { prompt } = req.body;

    // Basic validation
    if (!prompt || typeof prompt !== "string") {
      return res.status(400).json({
        error: "Valid 'prompt' is required",
      });
    }

    // Call Gemini API
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          contents: [
            {
              parts: [{ text: prompt }],
            },
          ],
        }),
      }
    );

    const data = await response.json();

    // Handle API errors cleanly
    if (!response.ok) {
      console.error("Gemini error:", data);
      return res.status(500).json({
        error: "AI request failed",
        details: data,
      });
    }

    res.json(data);
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({
      error: "Internal server error",
    });
  }
});

// ─────────────────────────────────────────────
// START SERVER
// ─────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});