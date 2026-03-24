import os
import google.generativeai as genai
from jobspy import scrape_jobs
from fpdf import FPDF
from .models import Job, UserProfile, ApplicationPackage
from datetime import datetime

class JobSearchAgent:
    def __init__(self):
        pass

    def find_jobs(self, query: str, location: str, limit: int = 5, 
                 site_name: list[str] = ["linkedin", "indeed", "glassdoor"],
                 hours_old: int = 72,
                 is_remote: bool = False,
                 job_type: str = None,
                 country: str = "US") -> list[Job]:
        """
        Searches for jobs using jobspy.
        """
        try:
            jobs_df = scrape_jobs(
                site_name=site_name,
                search_term=query,
                location=location,
                results_wanted=limit,
                hours_old=hours_old,
                is_remote=is_remote,
                job_type=job_type,
                country_watchlist=[country]
            )
            
            import pandas as pd
            
            jobs = []
            for _, row in jobs_df.iterrows():
                title = row.get('title')
                if not title: continue
                
                def safe_str(val):
                    if pd.isna(val):
                        return None
                    return str(val)

                job = Job(
                    id=str(row.get('id', '')) or f"{row.get('company')}-{title}".replace(" ", "_"),
                    title=title,
                    company=safe_str(row.get('company')) or "Unknown",
                    job_url=safe_str(row.get('job_url')) or "",
                    location=safe_str(row.get('location')),
                    description=safe_str(row.get('description')),
                    date_posted=safe_str(row.get('date_posted')),
                    job_type=safe_str(row.get('job_type'))
                )
                jobs.append(job)
            return jobs
        except Exception as e:
            print(f"Error searching jobs: {e}")
            import traceback
            traceback.print_exc()
            return []

class PDFResume(FPDF):
    def header(self):
        # We'll handle the header manually in the body to have more control
        pass

    def footer(self):
        self.set_y(-15)
        self.set_font('Helvetica', 'I', 8)
        self.cell(0, 10, f'Page {self.page_no()}', 0, 0, 'C')

class ResumeAgent:
    def __init__(self):
        pass

    def generate_resume(self, user: UserProfile, job: Job, output_dir: str) -> str:
        """
        Generates a tailored resume PDF using fpdf2.
        """
        os.makedirs(output_dir, exist_ok=True)
        
        pdf = PDFResume()
        pdf.add_page()
        
        # --- Header ---
        pdf.set_font('Helvetica', 'B', 24)
        pdf.cell(0, 10, user.name, new_x="LMARGIN", new_y="NEXT", align='C')
        
        pdf.set_font('Helvetica', '', 10)
        contact_info = f"{user.email} | {user.phone}"
        if user.linkedin_url:
            contact_info += f" | {user.linkedin_url}"
        if user.github_url:
            contact_info += f" | {user.github_url}"
        
        pdf.cell(0, 5, contact_info, new_x="LMARGIN", new_y="NEXT", align='C')
        pdf.ln(5)
        
        # --- Education ---
        if user.education:
            pdf.set_font('Helvetica', 'B', 14)
            pdf.cell(0, 8, "EDUCATION", border='B', new_x="LMARGIN", new_y="NEXT")
            pdf.ln(2)
            
            for edu in user.education:
                pdf.set_font('Helvetica', 'B', 11)
                pdf.cell(130, 6, edu.institution)
                pdf.set_font('Helvetica', '', 11)
                pdf.cell(0, 6, f"{edu.start_date} - {edu.end_date}", new_x="LMARGIN", new_y="NEXT", align='R')
                
                pdf.set_font('Helvetica', 'I', 11)
                pdf.cell(0, 6, edu.degree, new_x="LMARGIN", new_y="NEXT")
                pdf.ln(2)

        # --- Experience ---
        if user.experience:
            pdf.set_font('Helvetica', 'B', 14)
            pdf.cell(0, 8, "EXPERIENCE", border='B', new_x="LMARGIN", new_y="NEXT")
            pdf.ln(2)
            
            for exp in user.experience:
                pdf.set_font('Helvetica', 'B', 11)
                pdf.cell(130, 6, exp.company)
                pdf.set_font('Helvetica', '', 11)
                pdf.cell(0, 6, f"{exp.start_date} - {exp.end_date}", new_x="LMARGIN", new_y="NEXT", align='R')
                
                pdf.set_font('Helvetica', 'I', 11)
                pdf.cell(0, 6, exp.title, new_x="LMARGIN", new_y="NEXT")
                
                pdf.set_font('Helvetica', '', 10)
                # Simple bullet point handling
                if exp.description:
                    pdf.multi_cell(0, 5, exp.description)
                pdf.ln(3)

        # --- Skills ---
        if user.skills:
            pdf.set_font('Helvetica', 'B', 14)
            pdf.cell(0, 8, "SKILLS", border='B', new_x="LMARGIN", new_y="NEXT")
            pdf.ln(2)
            
            pdf.set_font('Helvetica', '', 10)
            pdf.multi_cell(0, 5, ", ".join(user.skills))
        
        # Save
        filename = f"resume_{user.name.replace(' ', '_')}_{job.company.replace(' ', '_')}.pdf"
        # Sanitize filename
        filename = "".join([c for c in filename if c.isalpha() or c.isdigit() or c in (' ', '.', '_')]).strip()
        pdf_path = os.path.join(output_dir, filename)
        pdf.output(pdf_path)
        
        return pdf_path

class CoverLetterAgent:
    def __init__(self):
        api_key = os.environ.get("GEMINI_API_KEY")
        if api_key:
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel('gemini-2.0-flash')
        else:
            self.model = None
            print("Warning: GEMINI_API_KEY not set. Cover letter generation will fail.")

    def generate_cover_letter(self, user: UserProfile, job: Job, humanize: bool = False, language: str = "English") -> str:
        """
        Generates a cover letter using Gemini.
        """
        if not self.model:
            return "Error: Gemini API key not configured."

        # Disable humanization for non-English languages to prevent Quillbot from reverting to English
        if humanize and language != "English":
            print(f"Warning: Humanization is currently only supported for English. Skipping for {language}.")
            humanize = False

        prompt = f"""
        Write a professional, engaging, and "human-sounding" cover letter for the following job application.
        
        **Language**: Write the letter in {language}.
        
        Candidate: {user.name}
        Skills: {', '.join(user.skills)}
        Experience: {[f'{exp.title} at {exp.company}' for exp in user.experience]}
        Projects: {[p.get('title') for p in user.projects] if user.projects else "None"}
        Achievements: {user.achievements if user.achievements else "None"}
        
        Job Title: {job.title}
        Company: {job.company}
        Description: {job.description}
        
        **Instructions for Human-like Writing:**
        1. **Burstiness**: Vary sentence length and structure significantly. Mix short, punchy sentences with longer, flowing ones. Avoid monotonous rhythms.
        2. **Specific Evidence**: Use the Candidate's Projects and Achievements as concrete proof of skills. Don't just list skills; show how they were applied.
        3. **Tone**: Be confident but authentic. Avoid overly formal or robotic "AI" language (e.g., "I am writing to express my interest," "It aligns perfectly with my skills"). Instead, start with a strong hook or a personal connection to the field.
        4. **Avoid Clichés**: Do not use phrases like "thrilled to apply," "perfect match," or "testament to my ability." Use fresh, natural language.
        5. **Structure**:
           - **Hook**: Grab attention immediately.
           - **Body**: Connect specific past experiences/projects to the job requirements. Tell a mini-story if possible.
           - **Closing**: Professional call to action, but keep it brief.
        
        **CRITICAL INSTRUCTION**: The entire cover letter MUST be written in {language}. Do not output any English unless the specific term is untranslatable.
        
        Output ONLY the body of the letter.
        """
        
        try:
            response = self.model.generate_content(prompt)
            generated_text = response.text
            
            # --- Quillbot Integration ---
            if humanize:
                try:
                    from backend.quillbot import Quillbot
                    print("Starting Quillbot humanization...")
                    # Determine Chrome User Data Directory based on OS
                    import platform
                    system = platform.system()
                    user_data_dir = ""
                    
                    if system == "Darwin":  # macOS
                        user_data_dir = os.path.expanduser("~/Library/Application Support/Google/Chrome")
                    elif system == "Windows":
                        user_data_dir = os.path.expanduser("~\\AppData\\Local\\Google\\Chrome\\User Data")
                    else:  # Linux
                        user_data_dir = os.path.expanduser("~/.config/google-chrome")
                    
                    # Allow override via environment variable
                    if os.environ.get("CHROME_USER_DATA_DIR"):
                        user_data_dir = os.environ.get("CHROME_USER_DATA_DIR")

                    bot = Quillbot(
                        headless=True,
                        user_data_dir=user_data_dir,
                        profile_directory="Default",
                        copy_profile=True
                    )
                    humanized_text = bot.humanize(generated_text, mode="Basic")
                    bot.close()
                    
                    if humanized_text:
                        print("Quillbot humanization successful.")
                        return f"=== ORIGINAL (GEMINI) ===\n{generated_text}\n\n=== HUMANIZED (QUILLBOT) ===\n{humanized_text}"
                    else:
                        print("Quillbot returned empty text. Using original.")
                        return generated_text
                except Exception as e:
                    print(f"Quillbot humanization failed: {e}")
                    return generated_text
            else:
                return generated_text
                
        except Exception as e:
            return f"Error generating cover letter: {str(e)}"

class ResumeParserAgent:
    def __init__(self):
        api_key = os.environ.get("GEMINI_API_KEY")
        if api_key:
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel('gemini-2.0-flash')
        else:
            self.model = None

    def parse_pdf(self, file_bytes: bytes) -> UserProfile:
        """
        Extracts text from PDF bytes and uses Gemini to parse it into a UserProfile.
        """
        import io
        from pypdf import PdfReader
        import json

        try:
            # Extract text
            reader = PdfReader(io.BytesIO(file_bytes))
            text = ""
            for page in reader.pages:
                text += page.extract_text() + "\n"
            
            if not self.model:
                raise Exception("Gemini API key not configured")

            # Parse with Gemini
            prompt = f"""
            Extract the following details from the resume text below and return ONLY a JSON object matching this structure:
            {{
                "name": "Full Name",
                "email": "email@example.com",
                "phone": "123-456-7890",
                "linkedin_url": "url or null",
                "github_url": "url or null",
                "skills": ["skill1", "skill2"],
                "education": [
                    {{ "institution": "Name", "degree": "Degree", "start_date": "YYYY", "end_date": "YYYY", "description": "optional" }}
                ],
                "experience": [
                    {{ "company": "Name", "title": "Title", "start_date": "YYYY", "end_date": "YYYY", "description": "summary" }}
                ],
                "projects": [
                    {{ "title": "Project Name", "description": "What you did, tech stack, impact" }}
                ],
                "achievements": ["Award 1", "Recognition 2"]
            }}

            Resume Text:
            {text[:15000]}  # Truncate if too long
            """
            
            response = self.model.generate_content(prompt)
            cleaned_text = response.text.strip()
            # Remove markdown code blocks if present
            if cleaned_text.startswith("```json"):
                cleaned_text = cleaned_text[7:]
            if cleaned_text.endswith("```"):
                cleaned_text = cleaned_text[:-3]
                
            data = json.loads(cleaned_text)
            
            # Convert to Pydantic model (handling potential missing fields safely)
            return UserProfile(
                name=data.get("name") or "Unknown",
                email=data.get("email") or "",
                phone=data.get("phone") or "",
                linkedin_url=data.get("linkedin_url"),
                github_url=data.get("github_url"),
                skills=data.get("skills") or [],
                education=data.get("education") or [],
                experience=data.get("experience") or [],
                projects=data.get("projects") or [],
                achievements=data.get("achievements") or []
            )

        except Exception as e:
            print(f"Error parsing resume: {e}")
            # Return empty profile on error
            return UserProfile(
                name="", email="", phone="", skills=[], education=[], experience=[]
            )
