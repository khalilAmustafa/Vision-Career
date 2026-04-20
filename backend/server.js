import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import dotenv from "dotenv";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

const GEMINI_KEY = process.env.GEMINI_API_KEY;

if (!GEMINI_KEY) {
  console.error("❌ GEMINI_API_KEY is missing");
}

// ✅ Helper to build request safely
function buildGeminiBody(input) {
  // Case 1: direct prompt
  if (input.prompt) {
    return {
      contents: [
        {
          parts: [{ text: input.prompt }],
        },
      ],
    };
  }

  // Case 2: structured input (future-safe)
  return {
    contents: [
      {
        parts: [
          {
            text: JSON.stringify(input),
          },
        ],
      },
    ],
  };
}

app.post("/recommend", async (req, res) => {
  try {
    const body = buildGeminiBody(req.body);

   const response = await fetch(
     `https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash-latest:generateContent?key=${GEMINI_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      }
    );

    const data = await response.json();

    // ✅ Fail loudly if Gemini error
    if (!response.ok) {
      console.error("Gemini error:", data);
      return res.status(500).json(data);
    }

    // ✅ Extract clean text response
    const text =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;

    res.json({
      success: true,
      text,
      raw: data, // keep for debugging
    });
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

app.get("/", (req, res) => {
  res.send("Backend is running 🚀");
});

const PORT = process.env.PORT || 10000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});