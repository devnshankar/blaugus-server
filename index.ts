import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";
import dotenv from "dotenv";

dotenv.config(); // Load environment variables

const app = express();
const PORT = process.env.SERVER_PORT || 3050;
const CLIENT_URL = process.env.CLIENT_URL || "http://localhost:5173/";
const BLOGS_DIR = path.join(__dirname, "blogs");

// Middleware to parse JSON and handle CORS
app.use(express.json());
app.use(
  cors({
    origin: [CLIENT_URL, "http://localhost:5173/", "http://localhost"], // Allow only the specified client URLs
  })
);


// Ensure blogs directory exists
if (!fs.existsSync(BLOGS_DIR)) {
  fs.mkdirSync(BLOGS_DIR);
}

// API to create a blog
app.post("/api/blogs", (req, res) => {
  const { title, content } = req.body;

  if (!title || !content) {
    return res.status(400).json({ error: "Title and content are required." });
  }

  const blogId = Date.now().toString();
  const blogFilePath = path.join(BLOGS_DIR, `${blogId}.json`);

  const blogData = {
    id: blogId,
    title,
    content,
    createdAt: new Date().toISOString(),
  };

  fs.writeFileSync(blogFilePath, JSON.stringify(blogData, null, 2));
  res.status(201).json({ message: "Blog created successfully.", blog: blogData });
});

// API to get all blogs
app.get("/api/blogs", (req, res) => {
  const blogFiles = fs.readdirSync(BLOGS_DIR);
  const blogs = blogFiles.map((file) => {
    const filePath = path.join(BLOGS_DIR, file);
    const blogData = JSON.parse(fs.readFileSync(filePath, "utf-8"));
    return { id: blogData.id, title: blogData.title, createdAt: blogData.createdAt };
  });
  res.json(blogs);
});

// API to get a specific blog by ID
app.get("/api/blogs/:id", (req, res) => {
  const blogId = req.params.id;
  const blogFilePath = path.join(BLOGS_DIR, `${blogId}.json`);

  if (!fs.existsSync(blogFilePath)) {
    return res.status(404).json({ error: "Blog not found." });
  }

  const blogData = JSON.parse(fs.readFileSync(blogFilePath, "utf-8"));
  res.json(blogData);
});


app.get("/", (req, res) => {
  return res.status(200).send("Welcome to the blaugus server")
})
// Start the server
app.listen(PORT, () => {
  console.log(`Backend server is running at http://localhost:${PORT}`);
});
