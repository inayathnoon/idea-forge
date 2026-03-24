import { useState } from 'react';
import axios from 'axios';
import { X, Download, FileText, Loader2 } from 'lucide-react';
import { Job } from '@/app/page';

interface ApplicationModalProps {
    job: Job;
    onClose: () => void;
    initialProfile?: any;
}

export default function ApplicationModal({ job, onClose, initialProfile }: ApplicationModalProps) {
    const [loading, setLoading] = useState(false);
    const [result, setResult] = useState<{ resume_pdf_path: string; cover_letter_text: string } | null>(null);

    // Options
    const [generateResume, setGenerateResume] = useState(false);
    const [humanizeCoverLetter, setHumanizeCoverLetter] = useState(false);
    const [language, setLanguage] = useState("English");

    // Form State
    const [formData, setFormData] = useState({
        name: initialProfile?.name || 'Jane Doe',
        email: initialProfile?.email || 'jane@example.com',
        phone: initialProfile?.phone || '555-0123',
        linkedin_url: initialProfile?.linkedin_url || '',
        github_url: initialProfile?.github_url || '',
        skills: initialProfile?.skills ? initialProfile.skills.join(', ') : 'Python, React, AI, FastAPI, TailwindCSS',
        education: JSON.stringify(initialProfile?.education || [{
            institution: "Demo University",
            degree: "B.S. Computer Science",
            start_date: "2018",
            end_date: "2022",
            description: "Graduated with honors."
        }], null, 2),
        experience: JSON.stringify(initialProfile?.experience || [{
            company: "Tech Demo Corp",
            title: "Junior Developer",
            start_date: "2022",
            end_date: "Present",
            description: "Developed web applications using React and Python."
        }], null, 2),
        projects: JSON.stringify(initialProfile?.projects || [], null, 2),
        achievements: JSON.stringify(initialProfile?.achievements || [], null, 2)
    });

    const generateApp = async () => {
        setLoading(true);
        try {
            // Parse JSON fields
            let education = [];
            let experience = [];
            let projects = [];
            let achievements = [];
            try {
                education = JSON.parse(formData.education);
                experience = JSON.parse(formData.experience);
                projects = JSON.parse(formData.projects);
                achievements = JSON.parse(formData.achievements);
            } catch (e) {
                alert("Invalid JSON in one of the profile fields.");
                return;
            }

            // Construct profile object matching backend model
            const profile = {
                name: formData.name,
                email: formData.email,
                phone: formData.phone,
                linkedin_url: formData.linkedin_url || null,
                github_url: formData.github_url || null,
                skills: formData.skills.split(',').map((s: string) => s.trim()),
                education: education,
                experience: experience,
                projects: projects,
                achievements: achievements
            };

            const res = await axios.post(`http://127.0.0.1:8000/api/generate_application?job_id=${job.id}&generate_resume=${generateResume}&humanize_cover_letter=${humanizeCoverLetter}&language=${language}`, profile);
            setResult(res.data);
        } catch (err) {
            console.error(err);
            alert('Failed to generate application');
        } finally {
            setLoading(false);
        }
    };

    const [parsing, setParsing] = useState(false);

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        setParsing(true);
        const formDataUpload = new FormData();
        formDataUpload.append('file', file);

        try {
            const res = await axios.post('http://127.0.0.1:8000/api/parse_resume', formDataUpload, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });
            const data = res.data;
            setFormData({
                name: data.name || '',
                email: data.email || '',
                phone: data.phone || '',
                linkedin_url: data.linkedin_url || '',
                github_url: data.github_url || '',
                skills: data.skills?.join(', ') || '',
                education: JSON.stringify(data.education || [], null, 2),
                experience: JSON.stringify(data.experience || [], null, 2),
                projects: JSON.stringify(data.projects || [], null, 2),
                achievements: JSON.stringify(data.achievements || [], null, 2),
            });
        } catch (err) {
            console.error(err);
            alert('Failed to parse resume');
        } finally {
            setParsing(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
            <div className="bg-gray-900 border border-gray-700 rounded-2xl w-full max-w-6xl max-h-[90vh] overflow-y-auto p-8 relative shadow-2xl">
                <button onClick={onClose} className="absolute top-4 right-4 text-gray-400 hover:text-white transition">
                    <X size={24} />
                </button>

                <h2 className="text-3xl font-bold text-white mb-6">Create Application</h2>

                <div className="grid md:grid-cols-2 gap-8">
                    {/* Input Section */}
                    <div className="flex flex-col h-full">
                        <h3 className="text-xl font-semibold mb-4 text-gray-300">Your Profile</h3>

                        <div className="flex-1 overflow-y-auto custom-scrollbar pr-2">
                            {/* Resume Upload Override */}
                            <div className="mb-6">
                                <label className="flex flex-col items-center justify-center w-full h-16 border border-gray-600 border-dashed rounded-lg cursor-pointer bg-gray-800 hover:bg-gray-700 transition">
                                    <div className="flex items-center gap-2">
                                        {parsing ? (
                                            <Loader2 className="animate-spin text-blue-500" size={20} />
                                        ) : (
                                            <>
                                                <span className="text-sm text-gray-400">Override with new resume (PDF)</span>
                                            </>
                                        )}
                                    </div>
                                    <input type="file" className="hidden" accept=".pdf" onChange={handleFileUpload} disabled={parsing} />
                                </label>
                            </div>

                            <div className="space-y-4">
                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Full Name</label>
                                        <input
                                            type="text"
                                            value={formData.name}
                                            onChange={e => setFormData({ ...formData, name: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white outline-none focus:border-blue-500"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Phone</label>
                                        <input
                                            type="text"
                                            value={formData.phone}
                                            onChange={e => setFormData({ ...formData, phone: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white outline-none focus:border-blue-500"
                                        />
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Email</label>
                                        <input
                                            type="email"
                                            value={formData.email}
                                            onChange={e => setFormData({ ...formData, email: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white outline-none focus:border-blue-500"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">LinkedIn URL</label>
                                        <input
                                            type="text"
                                            value={formData.linkedin_url}
                                            onChange={e => setFormData({ ...formData, linkedin_url: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white outline-none focus:border-blue-500"
                                        />
                                    </div>
                                </div>

                                <div>
                                    <label className="block text-xs text-gray-400 mb-1">Skills (comma separated)</label>
                                    <textarea
                                        value={formData.skills}
                                        onChange={e => setFormData({ ...formData, skills: e.target.value })}
                                        className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white outline-none h-16 resize-none focus:border-blue-500"
                                    />
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Experience (JSON)</label>
                                        <textarea
                                            value={formData.experience}
                                            onChange={e => setFormData({ ...formData, experience: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white font-mono text-xs outline-none h-32 resize-none focus:border-blue-500"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Education (JSON)</label>
                                        <textarea
                                            value={formData.education}
                                            onChange={e => setFormData({ ...formData, education: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white font-mono text-xs outline-none h-32 resize-none focus:border-blue-500"
                                        />
                                    </div>
                                </div>

                                <div className="grid grid-cols-2 gap-4">
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Projects (JSON)</label>
                                        <textarea
                                            value={formData.projects}
                                            onChange={e => setFormData({ ...formData, projects: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white font-mono text-xs outline-none h-32 resize-none focus:border-blue-500"
                                        />
                                    </div>
                                    <div>
                                        <label className="block text-xs text-gray-400 mb-1">Achievements (JSON)</label>
                                        <textarea
                                            value={formData.achievements}
                                            onChange={e => setFormData({ ...formData, achievements: e.target.value })}
                                            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2 text-white font-mono text-xs outline-none h-32 resize-none focus:border-blue-500"
                                        />
                                    </div>
                                </div>
                            </div>

                            {/* Options */}
                            <div className="mt-6 space-y-4">
                                <div className="flex gap-6">
                                    <label className="flex items-center gap-2 cursor-pointer select-none">
                                        <input
                                            type="checkbox"
                                            checked={generateResume}
                                            onChange={e => setGenerateResume(e.target.checked)}
                                            className="w-5 h-5 rounded border-gray-600 bg-gray-700 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-gray-900"
                                        />
                                        <span className="text-gray-300">Generate Resume</span>
                                    </label>
                                    <label className="flex items-center gap-2 cursor-pointer select-none">
                                        <input
                                            type="checkbox"
                                            checked={humanizeCoverLetter}
                                            onChange={e => setHumanizeCoverLetter(e.target.checked)}
                                            className="w-5 h-5 rounded border-gray-600 bg-gray-700 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-gray-900"
                                        />
                                        <span className="text-gray-300">Humanize (Quillbot)</span>
                                    </label>
                                </div>

                                <div className="flex flex-col gap-2">
                                    <label className="text-sm text-gray-400 font-medium">Cover Letter Language</label>
                                    <select
                                        value={language}
                                        onChange={(e) => setLanguage(e.target.value)}
                                        className="bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-white outline-none focus:border-blue-500 transition w-full"
                                    >
                                        <option value="English">English</option>
                                        <option value="German">German</option>
                                        <option value="Spanish">Spanish</option>
                                        <option value="French">French</option>
                                        <option value="Italian">Italian</option>
                                    </select>
                                </div>
                            </div>

                            <button
                                onClick={generateApp}
                                disabled={loading}
                                className="mt-6 w-full bg-emerald-600 hover:bg-emerald-500 text-white font-bold py-4 rounded-xl transition shadow-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                {loading ? <Loader2 className="animate-spin" /> : 'Generate Resume & Cover Letter'}
                            </button>
                        </div>
                    </div>

                    {/* Output Section */}
                    <div className="bg-gray-800/50 rounded-xl p-6 border border-gray-700 flex flex-col h-full">
                        <h3 className="text-xl font-semibold mb-4 text-gray-300">Output</h3>

                        {result ? (
                            <div className="space-y-4 flex-1 overflow-hidden flex flex-col">
                                <div className="p-4 bg-gray-700/50 rounded-lg border border-gray-600">
                                    <h4 className="font-bold text-emerald-400 mb-2 flex items-center gap-2"><FileText size={18} /> Resume PDF</h4>
                                    {result.resume_pdf_path ? (
                                        <a
                                            href={`http://127.0.0.1:8000${result.resume_pdf_path}`}
                                            target="_blank"
                                            rel="noreferrer"
                                            className="text-blue-300 hover:text-blue-200 hover:underline break-all flex items-center gap-2"
                                        >
                                            <Download size={16} /> Download Resume
                                        </a>
                                    ) : (
                                        <span className="text-gray-500 italic">Not generated</span>
                                    )}
                                </div>
                                <div className="p-4 bg-gray-700/50 rounded-lg border border-gray-600 flex-1 flex flex-col min-h-0">
                                    <h4 className="font-bold text-emerald-400 mb-2 flex items-center gap-2"><FileText size={18} /> Cover Letter</h4>
                                    <pre className="whitespace-pre-wrap text-sm text-gray-300 font-mono overflow-y-auto custom-scrollbar flex-1 p-2 bg-gray-800 rounded">
                                        {result.cover_letter_text}
                                    </pre>
                                </div>
                            </div>
                        ) : (
                            <div className="flex-1 flex items-center justify-center text-gray-500">
                                Generated artifacts will appear here.
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div >
    );
}
