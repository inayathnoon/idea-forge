from pydantic import BaseModel
from typing import List, Optional
from datetime import date

class Job(BaseModel):
    id: Optional[str] = None
    title: str
    company: str
    job_url: str
    location: Optional[str] = None
    description: Optional[str] = None
    date_posted: Optional[date] = None
    job_type: Optional[str] = None  # e.g., Full-time, Contract

class Education(BaseModel):
    institution: str
    degree: str
    start_date: str
    end_date: str
    description: Optional[str] = None

class Experience(BaseModel):
    company: str
    title: str
    start_date: str
    end_date: str
    description: str  # Bullet points or paragraph

class UserProfile(BaseModel):
    name: str = "Unknown"
    email: str = ""
    phone: str = ""
    linkedin_url: Optional[str] = None
    github_url: Optional[str] = None
    skills: List[str] = []
    education: List[Education] = []
    experience: List[Experience] = []
    projects: List[dict] = []
    achievements: List[str] = []

class ApplicationPackage(BaseModel):
    job_id: str
    resume_pdf_path: Optional[str] = None
    cover_letter_text: str

class JobSearchRequest(BaseModel):
    query: str
    location: str
    site_name: List[str] = ["linkedin", "indeed", "glassdoor"]
    hours_old: int = 72
    is_remote: bool = False
    job_type: Optional[str] = None
    country: str = "US"
