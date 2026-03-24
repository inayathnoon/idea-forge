# 🤖 Job-Agent AI

**Automate your job hunt with AI-powered search, tailored resumes, and human-like cover letters.**

Job-Agent AI is a full-stack application designed to streamline the tedious process of applying for jobs. It aggregates job listings from multiple platforms, uses AI to tailor your resume for specific roles, and generates engaging cover letters in multiple languages.

---

## ✨ Features

-   **🔍 Multi-Platform Job Search**: Aggregates real-time job listings from LinkedIn, Indeed, Glassdoor, and ZipRecruiter.
-   **📄 AI Resume Tailoring**: Parses your existing PDF resume and re-generates a new, targeted version (PDF) highlighting skills relevant to the specific job description.
-   **✍️ Smart Cover Letters**: Generates professional cover letters using Google Gemini.
    -   **Multi-Language Support**: Generate letters in English, German, Spanish, French, or Italian.
    -   **Humanization (Experimental)**: Optional integration with Quillbot to make AI text sound more natural (English only).
-   **🖥️ Modern UI**: A clean, dark-mode React interface for managing searches and applications.

---

## ⚠️ Experimental Features Warning

### Quillbot Humanization
This project includes an **experimental** feature to "humanize" cover letters using Quillbot.
-   **Mechanism**: It uses Selenium to control a local Chrome browser instance to interact with Quillbot's web interface.
-   **Limitations**:
    -   **English Only**: This feature is automatically disabled for non-English languages.
    -   **Browser Control**: It requires a visible Chrome window to open on your machine. **Do not interfere with this window while it runs.**
    -   **Stability**: As it relies on web automation, changes to Quillbot's website may break this feature.

---

## 🚀 Getting Started

### Prerequisites

-   **Python 3.10+**
-   **Node.js 18+** (and `npm`)
-   **Google Chrome** (for Quillbot automation)
-   **Gemini API Key** (Get one [here](https://aistudio.google.com/app/apikey))

### 1. Installation

Clone the repository and navigate to the project folder:

```bash
git clone https://github.com/yourusername/Job-Agent-AI.git
cd Job-Agent-AI
```

### 2. Backend Setup

Create a virtual environment and install dependencies:

```bash
# Create venv
python3 -m venv venv

# Activate venv
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Frontend Setup

Install Node.js dependencies:

```bash
cd frontend
npm install
cd ..
```

---

## ⚙️ Configuration

### Environment Variables

You must set your Google Gemini API key for the AI features to work.

**Option 1: Export in Terminal (Temporary)**
```bash
export GEMINI_API_KEY="your_actual_api_key_here"
```

**Option 2: .env File (Recommended)**
Create a `.env` file in the `Job-Agent-AI` root directory:
```env
GEMINI_API_KEY=your_actual_api_key_here
# Optional: Override Chrome User Data Directory for Quillbot
# CHROME_USER_DATA_DIR=/path/to/your/chrome/user/data
```

---

## 🏃‍♂️ Usage

You need to run both the backend and frontend servers.

### 1. Start the Backend
In the root directory (`Job-Agent-AI`):
```bash
# Ensure venv is activated
source venv/bin/activate

# Run the server
uvicorn backend.main:app --reload
```
*The backend will start at `http://127.0.0.1:8000`*

### 2. Start the Frontend
Open a new terminal window, navigate to `frontend`:
```bash
cd frontend
npm run dev
```
*The frontend will start at `http://localhost:3000`*

### 3. Using the App
1.  Open `http://localhost:3000` in your browser.
2.  **Upload Resume**: Click the briefcase icon to upload your base PDF resume.
3.  **Search Jobs**: Enter a job title and location. Use "Advanced Search" for more filters.
4.  **Apply**: Click "Apply" on a job card.
5.  **Generate**: Select your options (Resume, Humanize, Language) and click "Generate".
6.  **Download**: Download your tailored resume and copy the cover letter.

---

## 👨‍💻 For Developers

### Project Structure

```
Job-Agent-AI/
├── backend/
│   ├── agents.py       # Core logic (Search, Resume, Cover Letter agents)
│   ├── main.py         # FastAPI endpoints
│   ├── models.py       # Pydantic data models
│   └── quillbot.py     # Selenium automation for Quillbot
├── frontend/
│   ├── src/
│   │   ├── app/        # Next.js pages
│   │   └── components/ # React components (Modals, Cards)
├── static/             # Generated artifacts (PDFs)
└── requirements.txt    # Python dependencies
```

### Contributing

We welcome contributions! Please follow these steps:
1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

**Code Style**:
-   **Backend**: Follow PEP 8.
-   **Frontend**: Use functional React components and TailwindCSS.

### Known Issues
-   **Quillbot Popups**: Occasionally, Quillbot may show a "Premium" popup that interrupts automation. The script attempts to handle this but may fail.
-   **Resume Parsing**: Complex PDF layouts (columns, graphics) may not parse perfectly. Simple text-based PDFs work best.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
