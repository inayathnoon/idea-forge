import { X, ExternalLink, FileText } from 'lucide-react';
import { Job } from '@/app/page';

import ReactMarkdown from 'react-markdown';

interface JobDetailsModalProps {
    job: Job;
    onClose: () => void;
    onApply: () => void;
}

export default function JobDetailsModal({ job, onClose, onApply }: JobDetailsModalProps) {
    return (
        <div className="fixed inset-0 bg-black/80 flex items-center justify-center z-50 p-4 backdrop-blur-sm">
            <div className="bg-gray-900 border border-gray-700 rounded-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto p-8 relative shadow-2xl flex flex-col">
                <button onClick={onClose} className="absolute top-4 right-4 text-gray-400 hover:text-white transition">
                    <X size={24} />
                </button>

                <div className="mb-6">
                    <h2 className="text-3xl font-bold text-white mb-2">{job.title}</h2>
                    <div className="flex flex-wrap gap-4 text-gray-400 text-sm">
                        <span className="flex items-center gap-1 text-emerald-400 font-medium">
                            {job.company}
                        </span>
                        <span>•</span>
                        <span>{job.location}</span>
                        <span>•</span>
                        <span>{job.job_type || 'Full-time'}</span>
                        <span>•</span>
                        <span>Posted: {job.date_posted || 'Recently'}</span>
                    </div>
                </div>

                <div className="flex-1 overflow-y-auto custom-scrollbar bg-gray-800/50 rounded-xl p-6 border border-gray-700 mb-6">
                    <h3 className="text-lg font-semibold text-gray-200 mb-4">Job Description</h3>
                    <div className="text-gray-300 prose prose-invert prose-sm max-w-none">
                        <ReactMarkdown>
                            {job.description || "No description available."}
                        </ReactMarkdown>
                    </div>
                </div>

                <div className="flex gap-4 mt-auto pt-4 border-t border-gray-800">
                    <a
                        href={job.job_url}
                        target="_blank"
                        rel="noreferrer"
                        className="flex-1 bg-gray-800 hover:bg-gray-700 text-white font-semibold py-3 rounded-xl transition flex items-center justify-center gap-2 border border-gray-600"
                    >
                        <ExternalLink size={18} />
                        Apply on Company Site
                    </a>
                    <button
                        onClick={onApply}
                        className="flex-1 bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-3 rounded-xl transition shadow-lg flex items-center justify-center gap-2"
                    >
                        <FileText size={18} />
                        Create Application
                    </button>
                </div>
            </div>
        </div>
    );
}
