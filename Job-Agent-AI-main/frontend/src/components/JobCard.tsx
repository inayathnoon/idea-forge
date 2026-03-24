import { Briefcase, MapPin, Calendar } from 'lucide-react';
import { Job } from '@/app/page';

interface JobCardProps {
    job: Job;
    onSelect: () => void;
    onView: () => void;
}

export default function JobCard({ job, onSelect, onView }: JobCardProps) {
    return (
        <div className="bg-white/10 backdrop-blur-md border border-white/20 p-6 rounded-xl hover:bg-white/20 transition cursor-pointer shadow-lg" onClick={onSelect}>
            <div className="flex justify-between items-start">
                <div>
                    <h3 className="text-xl font-bold text-blue-300 mb-1">{job.title}</h3>
                    <p className="text-lg text-gray-200 font-semibold">{job.company}</p>
                    <div className="flex gap-4 mt-3 text-sm text-gray-400">
                        <span className="flex items-center gap-1"><MapPin size={14} /> {job.location || 'Remote'}</span>
                        <span className="flex items-center gap-1"><Calendar size={14} /> {job.date_posted || 'Recently'}</span>
                    </div>
                </div>
                <div className="flex flex-col gap-2 min-w-[120px]">
                    <button
                        onClick={(e) => { e.stopPropagation(); onSelect(); }}
                        className="bg-gray-700 hover:bg-gray-600 text-white px-4 py-2 rounded-lg text-sm transition font-medium w-full"
                    >
                        Select
                    </button>
                    <button
                        onClick={(e) => { e.stopPropagation(); onView(); }}
                        className="bg-gray-800 hover:bg-gray-700 text-blue-300 border border-gray-600 px-4 py-2 rounded-lg text-sm transition font-medium w-full"
                    >
                        View Details
                    </button>
                </div>
            </div>
        </div>
    );
}
