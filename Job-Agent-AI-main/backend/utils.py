import os
import subprocess
import re
from pathlib import Path

def escape_latex(text: str) -> str:
    """Escapes special characters for LaTeX."""
    if not text:
        return ""
    
    replacements = {
        '&': r'\&',
        '%': r'\%',
        '$': r'\$',
        '#': r'\#',
        '_': r'\_',
        '{': r'\{',
        '}': r'\}',
        '~': r'\textasciitilde{}',
        '^': r'\textasciicircum{}',
        '\\': r'\textbackslash{}',
    }
    
    # Use regex to replace all occurrences
    pattern = re.compile('|'.join(re.escape(key) for key in replacements.keys()))
    return pattern.sub(lambda m: replacements[m.group(0)], text)

def generate_pdf(latex_content: str, output_dir: str, filename: str) -> str:
    """
    Compiles LaTeX content to PDF using pdflatex.
    Returns the path to the generated PDF.
    """
    os.makedirs(output_dir, exist_ok=True)
    
    tex_file = os.path.join(output_dir, f"{filename}.tex")
    
    with open(tex_file, "w") as f:
        f.write(latex_content)
    
    # Run pdflatex twice to ensure references are correct (though not strictly needed for simple resumes)
    # We run it in the output directory to keep auxiliary files contained
    try:
        subprocess.run(
            ["pdflatex", "-interaction=nonstopmode", f"{filename}.tex"],
            cwd=output_dir,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
    except subprocess.CalledProcessError as e:
        print(f"Error compiling LaTeX: {e.stdout.decode()} {e.stderr.decode()}")
        raise RuntimeError("Failed to compile PDF")
        
    return os.path.join(output_dir, f"{filename}.pdf")
