from fastapi import FastAPI, HTTPException, Body, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from typing import List
import os
from .models import Job, UserProfile, ApplicationPackage, JobSearchRequest
from .agents import JobSearchAgent, ResumeAgent, CoverLetterAgent, ResumeParserAgent

app = FastAPI(title="Job Application Agent")

# Allow CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Agents
job_agent = JobSearchAgent()
resume_agent = ResumeAgent()
cover_letter_agent = CoverLetterAgent()
parser_agent = ResumeParserAgent()

# In-memory storage
JOBS_DB = {}

# API Endpoints
@app.post("/api/search_jobs", response_model=List[Job])
def search_jobs(request: JobSearchRequest):
    jobs = job_agent.find_jobs(
        query=request.query, 
        location=request.location, 
        site_name=request.site_name,
        hours_old=request.hours_old,
        is_remote=request.is_remote,
        job_type=request.job_type,
        country=request.country
    )
    for job in jobs:
        if not job.id:
            job.id = f"{job.company}-{job.title}".replace(" ", "_")
        JOBS_DB[job.id] = job
    return jobs

@app.post("/api/parse_resume", response_model=UserProfile)
async def parse_resume(file: UploadFile = File(...)):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")
    
    contents = await file.read()
    try:
        profile = parser_agent.parse_pdf(contents)
        return profile
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to parse resume: {str(e)}")

@app.post("/api/generate_application", response_model=ApplicationPackage)
def generate_application(
    job_id: str,
    user_profile: UserProfile,
    generate_resume: bool = False,
    humanize_cover_letter: bool = False,
    language: str = "English"
):
    job = JOBS_DB.get(job_id)
    if not job:
        raise HTTPException(status_code=404, detail="Job not found. Search first.")

    output_dir = "static/generated"
    resume_pdf_path = None
    
    if generate_resume:
        try:
            resume_path = resume_agent.generate_resume(user_profile, job, output_dir)
            # Return relative path for frontend to access
            relative_path = os.path.relpath(resume_path, "static")
            resume_pdf_path = f"/static/{relative_path}"
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Resume generation failed: {str(e)}")

    cover_letter = cover_letter_agent.generate_cover_letter(user_profile, job, humanize=humanize_cover_letter, language=language)

    return ApplicationPackage(
        job_id=job_id,
        resume_pdf_path=resume_pdf_path,
        cover_letter_text=cover_letter
    )

# Serve Static Files (Frontend)
# Create static directory if it doesn't exist
os.makedirs("static/generated", exist_ok=True)

# Serve the generated files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Serve the frontend (index.html)
@app.get("/")
async def read_index():
    return FileResponse('static/index.html')
