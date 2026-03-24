from fpdf import FPDF

pdf = FPDF()
pdf.add_page()
pdf.set_font("Helvetica", size=12)
pdf.cell(200, 10, txt="Jane Doe", ln=1, align="C")
pdf.cell(200, 10, txt="jane.doe@example.com | 555-0199", ln=1, align="C")
pdf.ln(10)
pdf.cell(200, 10, txt="SKILLS", ln=1)
pdf.multi_cell(0, 10, txt="Python, JavaScript, React, Machine Learning, Data Analysis")
pdf.ln(5)
pdf.cell(200, 10, txt="EXPERIENCE", ln=1)
pdf.cell(200, 10, txt="Software Engineer at Tech Corp (2020-Present)", ln=1)
pdf.multi_cell(0, 10, txt="Developed scalable web applications using Django and React.")

pdf.output("dummy_resume.pdf")
print("Created dummy_resume.pdf")
