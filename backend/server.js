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

// ─────────────────────────────────────────────
// Helper: Build Gemini Request
// ─────────────────────────────────────────────
function buildGeminiBody(input) {
  const promptText = input.prompt
    ? input.prompt
    : JSON.stringify(input);

  return {
    contents: [
      {
        parts: [{ text: promptText }],
      },
    ],
    generationConfig: {
      responseMimeType: "application/json", // 🔥 FORCE JSON OUTPUT
      temperature: 0.4,
      topP: 0.9,
    },
  };
}

// ─────────────────────────────────────────────
// Helper: Extract JSON safely
// ─────────────────────────────────────────────
function extractJson(text) {
  if (!text) return null;

  try {
    return JSON.parse(text);
  } catch {
    // fallback: try to extract JSON block
    const start = text.indexOf("{");
    const end = text.lastIndexOf("}");

    if (start !== -1 && end !== -1) {
      try {
        return JSON.parse(text.substring(start, end + 1));
      } catch {
        return null;
      }
    }

    return null;
  }
}

// ─────────────────────────────────────────────
// MAIN ROUTE
// ─────────────────────────────────────────────
app.post("/recommend", async (req, res) => {
  try {
    const body = buildGeminiBody(req.body);

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=${GEMINI_KEY}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      }
    );

    const data = await response.json();

    if (!response.ok) {
      console.error("❌ Gemini error:", data);
      return res.status(500).json({
        success: false,
        error: "Gemini API error",
        details: data,
      });
    }

    const text =
      data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

    const parsed = extractJson(text);

    if (!parsed) {
      console.error("❌ Invalid JSON from AI:", text);
      return res.status(500).json({
        success: false,
        error: "Invalid JSON from AI",
        raw: text,
      });
    }

    // ✅ FINAL RESPONSE (what your Flutter expects)
    res.json({
      success: true,
      data: parsed,
    });

  } catch (error) {
    console.error("❌ Server error:", error);

    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// ─────────────────────────────────────────────
// HEALTH CHECK
// ─────────────────────────────────────────────
app.get("/", (req, res) => {
  res.send("Backend is running 🚀");
});

// ─────────────────────────────────────────────
// START SERVER
// ─────────────────────────────────────────────
const PORT = process.env.PORT || 10000;

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});