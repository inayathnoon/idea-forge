import os
from backend.models import UserProfile, Job, Education, Experience
from backend.agents import ResumeAgent

def test_resume_generation():
    print("Testing Resume Generation (FPDF2)...")
    
    user = UserProfile(
        name="John Doe",
        email="john@example.com",
        phone="123-456-7890",
        skills=["Python", "FastAPI", "AI"],
        education=[
            Education(institution="University of Tech", degree="BS CS", start_date="2018", end_date="2022")
        ],
        experience=[
            Experience(company="Tech Corp", title="Software Engineer", start_date="2022", end_date="Present", description="Built cool stuff.")
        ]
    )
    
    job = Job(
        title="Senior Python Dev",
        company="AI Startup",
        job_url="http://example.com",
        description="Need python expert."
    )
    
    agent = ResumeAgent()
    try:
        pdf_path = agent.generate_resume(user, job, "test_output")
        print(f"Success! PDF generated at: {pdf_path}")
        if os.path.exists(pdf_path):
            print("File exists.")
            print(f"File size: {os.path.getsize(pdf_path)} bytes")
        else:
            print("File does not exist!")
    except Exception as e:
        print(f"Failed: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_resume_generation()
