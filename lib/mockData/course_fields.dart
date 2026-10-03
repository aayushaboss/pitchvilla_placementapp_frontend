// Prototype heuristic — buckets a chosen degree into a broad field so the
// resume builder and goals screen can suggest relevant skills/roles instead
// of showing the same generic list to every student.

enum CourseField { tech, business, humanities, design, science, law, medical, media, hospitality, general }

const _techCourses = {'B.Tech', 'B.E.', 'BCA', 'M.Tech', 'M.E.', 'MCA', 'Integrated M.Tech'};
const _businessCourses = {'B.Com', 'BBA', 'MBA', 'M.Com'};
const _humanitiesCourses = {'BA', 'MA', 'B.Ed'};
const _designCourses = {'B.Des', 'M.Des', 'B.Arch', 'M.Arch'};
const _scienceCourses = {'B.Sc', 'M.Sc', 'PhD', 'M.Phil'};
const _lawCourses = {'LLB', 'LLM', 'BA LLB'};
const _medicalCourses = {'B.Pharm', 'BDS', 'MBBS', 'M.Pharm', 'MD', 'MS'};
const _mediaCourses = {'BJMC'};
const _hospitalityCourses = {'BHM'};

CourseField courseFieldFor(String? course) {
  if (course == null || course.isEmpty) return CourseField.general;
  if (_techCourses.contains(course)) return CourseField.tech;
  if (_businessCourses.contains(course)) return CourseField.business;
  if (_humanitiesCourses.contains(course)) return CourseField.humanities;
  if (_designCourses.contains(course)) return CourseField.design;
  if (_scienceCourses.contains(course)) return CourseField.science;
  if (_lawCourses.contains(course)) return CourseField.law;
  if (_medicalCourses.contains(course)) return CourseField.medical;
  if (_mediaCourses.contains(course)) return CourseField.media;
  if (_hospitalityCourses.contains(course)) return CourseField.hospitality;
  return CourseField.general;
}

const Map<CourseField, List<String>> skillSuggestionsByField = {
  CourseField.tech: ['Python', 'Java', 'JavaScript', 'SQL', 'React', 'Git', 'C++', 'Data Structures'],
  CourseField.business: ['Excel', 'Financial Analysis', 'PowerPoint', 'Market Research', 'Accounting', 'Communication'],
  CourseField.humanities: ['Content Writing', 'Research', 'Communication', 'MS Office', 'Public Speaking'],
  CourseField.design: ['Figma', 'Adobe XD', 'Photoshop', 'Illustrator', 'UI Design', 'Prototyping'],
  CourseField.science: ['Research', 'Data Analysis', 'Lab Techniques', 'MS Office', 'Report Writing'],
  CourseField.law: ['Legal Research', 'Drafting', 'Communication', 'MS Office', 'Case Analysis'],
  CourseField.medical: ['Clinical Skills', 'Research', 'Patient Care', 'Data Analysis', 'Communication'],
  CourseField.media: ['Content Writing', 'Video Editing', 'Social Media', 'Journalism', 'Communication'],
  CourseField.hospitality: ['Customer Service', 'Event Management', 'Communication', 'Operations'],
  CourseField.general: ['Communication', 'MS Office', 'Problem Solving', 'Teamwork', 'Time Management'],
};

const Map<CourseField, List<String>> specializationsByField = {
  CourseField.tech: ['Web Development', 'Mobile Apps', 'AI/ML', 'Data Science', 'Cloud/DevOps', 'Cybersecurity'],
  CourseField.business: ['Finance', 'Marketing', 'Sales', 'Operations', 'Consulting', 'HR'],
  CourseField.humanities: ['Content', 'Research', 'Public Relations', 'Teaching'],
  CourseField.design: ['UI/UX Design', 'Graphic Design', 'Branding', 'Product Design'],
  CourseField.science: ['Research', 'Lab Work', 'Data Analysis', 'Academia'],
  CourseField.law: ['Corporate Law', 'Litigation', 'Legal Research', 'Compliance'],
  CourseField.medical: ['Clinical Practice', 'Research', 'Pharma', 'Healthcare Ops'],
  CourseField.media: ['Journalism', 'Content Creation', 'Social Media', 'Broadcasting'],
  CourseField.hospitality: ['Hotel Management', 'Event Planning', 'Guest Relations'],
  CourseField.general: ['Operations', 'Client Work', 'Administration'],
};

/// Keys match the `_allRoles` list on the Goals screen exactly.
const Map<CourseField, List<String>> rolesByField = {
  CourseField.tech: ['Software', 'Data', 'Product', 'Research'],
  CourseField.business: ['Finance', 'Sales', 'Operations', 'Consulting', 'HR', 'Marketing'],
  CourseField.humanities: ['Content', 'HR', 'Research', 'Marketing'],
  CourseField.design: ['Design', 'Product', 'Content'],
  CourseField.science: ['Research', 'Data', 'Operations'],
  CourseField.law: ['Consulting', 'Operations', 'Research'],
  CourseField.medical: ['Research', 'Operations'],
  CourseField.media: ['Content', 'Marketing', 'Sales'],
  CourseField.hospitality: ['Operations', 'Sales', 'HR'],
  CourseField.general: ['Software', 'Data', 'Marketing', 'Finance', 'Design', 'Product', 'Content', 'Sales', 'Operations', 'HR', 'Consulting', 'Research'],
};
