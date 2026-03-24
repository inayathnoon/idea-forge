'use client';

import { useState } from 'react';
import axios from 'axios';
import { Search, MapPin, Briefcase, Filter, ChevronDown, ChevronUp } from 'lucide-react';
import JobCard from '@/components/JobCard';
import ApplicationModal from '@/components/ApplicationModal';
import JobDetailsModal from '@/components/JobDetailsModal';

// Define types locally for now
export interface Job {
  id: string;
  title: string;
  company: string;
  location: string;
  date_posted: string;
  description: string;
  job_url: string;
  job_type?: string;
}

export default function Home() {
  const [query, setQuery] = useState('');
  const [location, setLocation] = useState('');
  const [jobs, setJobs] = useState<Job[]>([]);
  const [loading, setLoading] = useState(false);

  // Modals
  const [selectedJob, setSelectedJob] = useState<Job | null>(null); // For Application
  const [viewingJob, setViewingJob] = useState<Job | null>(null);   // For Details

  const [userProfile, setUserProfile] = useState<any>(null);
  const [parsing, setParsing] = useState(false);

  // Advanced Search State
  const [showAdvanced, setShowAdvanced] = useState(false);
  const [filters, setFilters] = useState({
    site_name: ['linkedin', 'indeed', 'glassdoor'],
    hours_old: 72,
    is_remote: false,
    job_type: '',
    country: 'US'
  });

  const handleResumeUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setParsing(true);
    const formData = new FormData();
    formData.append('file', file);

    try {
      const res = await axios.post('http://127.0.0.1:8000/api/parse_resume', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      setUserProfile(res.data);
      alert("Resume parsed successfully! You can now apply to jobs faster.");
    } catch (err) {
      console.error(err);
      alert('Failed to parse resume');
    } finally {
      setParsing(false);
    }
  };

  const searchJobs = async () => {
    if (!query) return;
    setLoading(true);
    try {
      const res = await axios.post('http://127.0.0.1:8000/api/search_jobs', {
        query,
        location,
        site_name: filters.site_name,
        hours_old: filters.hours_old,
        is_remote: filters.is_remote,
        job_type: filters.job_type || null,
        country: filters.country
      });
      setJobs(res.data);
    } catch (err) {
      console.error(err);
      alert('Failed to fetch jobs');
    } finally {
      setLoading(false);
    }
  };

  const toggleSite = (site: string) => {
    setFilters(prev => {
      const sites = prev.site_name.includes(site)
        ? prev.site_name.filter(s => s !== site)
        : [...prev.site_name, site];
      return { ...prev, site_name: sites };
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-blue-900 to-gray-900 text-white p-8 font-sans">
      <div className="max-w-5xl mx-auto">
        <header className="text-center mb-12">
          <h1 className="text-5xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-emerald-400 mb-4">
            JobAgent AI
          </h1>
          <p className="text-gray-400 text-lg mb-6">Automate your job hunt with AI-powered search and tailored applications.</p>

          {/* Global Profile Upload */}
          <div className="flex justify-center">
            <label className="cursor-pointer bg-gray-800 hover:bg-gray-700 border border-gray-600 px-6 py-3 rounded-full flex items-center gap-3 transition shadow-lg">
              <Briefcase size={20} className="text-emerald-400" />
              <span className="text-gray-200 font-medium">
                {parsing ? "Parsing Resume..." : (userProfile ? `Profile Loaded: ${userProfile.name}` : "Upload Resume to Auto-fill")}
              </span>
              <input type="file" className="hidden" accept=".pdf" onChange={handleResumeUpload} disabled={parsing} />
            </label>
          </div>
        </header>

        {/* Search Bar */}
        <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-6 mb-10 shadow-xl">
          <div className="flex flex-col gap-4">
            <div className="flex flex-col md:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-4 top-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Job Title (e.g. Software Engineer)"
                  value={query}
                  onChange={(e) => setQuery(e.target.value)}
                  className="w-full bg-gray-800 border border-gray-700 rounded-xl pl-12 pr-6 py-4 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-white placeholder-gray-500"
                />
              </div>
              <div className="relative flex-1">
                <MapPin className="absolute left-4 top-4 text-gray-400" />
                <input
                  type="text"
                  placeholder="Location (e.g. Remote, SF)"
                  value={location}
                  onChange={(e) => setLocation(e.target.value)}
                  className="w-full bg-gray-800 border border-gray-700 rounded-xl pl-12 pr-6 py-4 focus:outline-none focus:ring-2 focus:ring-blue-500 transition text-white placeholder-gray-500"
                />
              </div>
              <button
                onClick={searchJobs}
                disabled={loading}
                className="bg-blue-600 hover:bg-blue-500 text-white font-bold py-4 px-8 rounded-xl transition transform hover:scale-105 shadow-lg flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Searching...' : 'Find Jobs'}
              </button>
            </div>

            {/* Advanced Search Toggle */}
            <button
              onClick={() => setShowAdvanced(!showAdvanced)}
              className="flex items-center gap-2 text-gray-400 hover:text-white text-sm font-medium self-start ml-2"
            >
              <Filter size={16} />
              Advanced Search
              {showAdvanced ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
            </button>

            {/* Advanced Filters */}
            {showAdvanced && (
              <div className="bg-gray-800/50 rounded-xl p-6 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 animate-in fade-in slide-in-from-top-4">
                {/* Job Boards */}
                <div className="space-y-2">
                  <label className="text-xs text-gray-400 uppercase font-bold">Job Boards</label>
                  <div className="flex flex-col gap-2">
                    {['linkedin', 'indeed', 'glassdoor', 'zip_recruiter'].map(site => (
                      <label key={site} className="flex items-center gap-2 cursor-pointer">
                        <input
                          type="checkbox"
                          checked={filters.site_name.includes(site)}
                          onChange={() => toggleSite(site)}
                          className="rounded border-gray-600 bg-gray-700 text-blue-500 focus:ring-blue-500"
                        />
                        <span className="text-sm capitalize">{site.replace('_', ' ')}</span>
                      </label>
                    ))}
                  </div>
                </div>

                {/* Date Posted */}
                <div className="space-y-2">
                  <label className="text-xs text-gray-400 uppercase font-bold">Date Posted</label>
                  <select
                    value={filters.hours_old}
                    onChange={(e) => setFilters({ ...filters, hours_old: Number(e.target.value) })}
                    className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-sm outline-none focus:border-blue-500"
                  >
                    <option value={24}>Past 24 Hours</option>
                    <option value={72}>Past 3 Days</option>
                    <option value={168}>Past Week</option>
                    <option value={720}>Past Month</option>
                  </select>
                </div>

                {/* Job Type & Remote */}
                <div className="space-y-4">
                  <div className="space-y-2">
                    <label className="text-xs text-gray-400 uppercase font-bold">Job Type</label>
                    <select
                      value={filters.job_type}
                      onChange={(e) => setFilters({ ...filters, job_type: e.target.value })}
                      className="w-full bg-gray-700 border border-gray-600 rounded-lg px-3 py-2 text-sm outline-none focus:border-blue-500"
                    >
                      <option value="">Any</option>
                      <option value="fulltime">Full-time</option>
                      <option value="parttime">Part-time</option>
                      <option value="contract">Contract</option>
                      <option value="internship">Internship</option>
                    </select>
                  </div>
                  <label className="flex items-center gap-2 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={filters.is_remote}
                      onChange={(e) => setFilters({ ...filters, is_remote: e.target.checked })}
                      className="rounded border-gray-600 bg-gray-700 text-blue-500 focus:ring-blue-500"
                    />
                    <span className="text-sm">Remote Only</span>
                  </label>
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Results */}
        <div className="grid gap-6">
          {jobs.map((job) => (
            <JobCard
              key={job.id}
              job={job}
              onSelect={() => setSelectedJob(job)}
              onView={() => setViewingJob(job)}
            />
          ))}
          {jobs.length === 0 && !loading && (
            <div className="text-center text-gray-500 mt-10">No jobs found. Try searching above.</div>
          )}
        </div>
      </div>

      {/* Application Modal */}
      {selectedJob && (
        <ApplicationModal
          job={selectedJob}
          onClose={() => setSelectedJob(null)}
          initialProfile={userProfile}
        />
      )}

      {/* Job Details Modal */}
      {viewingJob && (
        <JobDetailsModal
          job={viewingJob}
          onClose={() => setViewingJob(null)}
          onApply={() => {
            setViewingJob(null);
            setSelectedJob(viewingJob);
          }}
        />
      )}
    </div>
  );
}
