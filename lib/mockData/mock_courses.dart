// Prototype mock data — delete when real API is wired.
// Mirrors frontend/src/mockData/mockCourses.ts.
import '../models/course.dart';
import '../models/opportunity.dart';

const Map<String, List<String>> _syllabusTemplates = {
  'Counseling': [
    'Understanding NEP 2020',
    'Streams & subject choices',
    'Careers of the future',
    'Mapping interests to paths',
    'Colleges & entrance exams',
    'Building your roadmap',
    'Parent & student alignment',
    'Action plan & next steps',
  ],
  'Technology': [
    'Getting started & setup',
    'Core programming concepts',
    'Data types & logic',
    'Functions & problem solving',
    'Working with data',
    'Mini project: build it',
    'Debugging & best practices',
    'Version control basics',
    'Capstone project',
    'Portfolio & next steps',
    'Career pathways',
    'Interview foundations',
  ],
  'Design': [
    'Design thinking mindset',
    'Empathise & define',
    'Ideation techniques',
    'Wireframing basics',
    'Prototyping in Figma',
    'Visual & type fundamentals',
    'Usability & feedback',
    'Building a portfolio',
    'Presenting your work',
    'Design careers',
  ],
  'Finance': [
    'Money & markets 101',
    'Accounting fundamentals',
    'Reading financial statements',
    'Budgeting & planning',
    'Intro to investing',
    'Excel for finance',
    'Careers in finance',
    'Cracking finance interviews',
    'Capstone case study',
  ],
  'Science': [
    'Foundations & scope',
    'Biology core concepts',
    'Chemistry essentials',
    'Physics for medicine',
    'NEET pattern & strategy',
    'Practice & mock tests',
    'Time management',
    'Revision techniques',
    'Application & counseling',
    'Colleges & specialisations',
    'Careers in healthcare',
    'Mentor guidance',
    'Mind & body wellness',
    'Ethics in medicine',
    'Final readiness check',
    'Next steps',
  ],
  'Placement': [
    'Where you stand today',
    'Resume that stands out',
    'LinkedIn & personal brand',
    'Aptitude & assessments',
    'Technical interview prep',
    'HR & behavioural rounds',
    'Mock interviews & feedback',
    'Negotiation & offers',
  ],
};

const List<Course> mockCourses = [
  Course(
    id: 'course-nep-foundation',
    title: 'NEP 2020 Career Foundation',
    category: 'Counseling',
    cluster: 'Humanities & Law',
    duration: '4 weeks',
    modules: 8,
    image:
        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Understand streams, subjects and career pathways aligned to NEP 2020.',
  ),
  Course(
    id: 'course-coding-basics',
    title: 'Coding & Logic Bootcamp',
    category: 'Technology',
    cluster: 'Technology & Computer Science',
    duration: '6 weeks',
    modules: 12,
    image:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Build problem-solving skills with Python, logic and real projects.',
  ),
  Course(
    id: 'course-design-thinking',
    title: 'Design Thinking Studio',
    category: 'Design',
    cluster: 'Design & Creative',
    duration: '5 weeks',
    modules: 10,
    image:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Learn creative problem solving used by top designers and product teams.',
  ),
  Course(
    id: 'course-commerce-finance',
    title: 'Commerce & Finance Essentials',
    category: 'Finance',
    cluster: 'Commerce & Finance',
    duration: '4 weeks',
    modules: 9,
    image:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Accounting, markets and money skills for future finance leaders.',
  ),
  Course(
    id: 'course-biology-med',
    title: 'Medical Aspirant Track',
    category: 'Science',
    cluster: 'Medical & Healthcare',
    duration: '8 weeks',
    modules: 16,
    image:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Biology foundations and NEET-readiness for aspiring doctors.',
  ),
  Course(
    id: 'course-interview-prep',
    title: 'Interview Mastery',
    category: 'Placement',
    cluster: 'Technology & Computer Science',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1573497491208-6b1acb260507?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Ace technical and HR interviews with mock rounds and feedback.',
  ),
  Course(
    id: 'course-resume-builder',
    title: 'Standout Resume & LinkedIn',
    category: 'Placement',
    cluster: 'Commerce & Finance',
    duration: '2 weeks',
    modules: 5,
    image:
        'https://images.unsplash.com/photo-1586281380349-632531db7ed4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Craft a recruiter-ready resume and a magnetic LinkedIn profile.',
  ),
  Course(
    id: 'course-data-analytics',
    title: 'Data Analytics Launchpad',
    category: 'Technology',
    cluster: 'Technology & Computer Science',
    duration: '6 weeks',
    modules: 11,
    image:
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'SQL, Excel and dashboards — the most in-demand entry skills.',
  ),
  // 16 more added below (was 8 total) to give the Filter/Category-browse UI
  // enough per-category and per-cluster spread to actually demonstrate
  // filtering — 4 courses per category across all 6 categories.
  Course(
    id: 'course-stream-selection',
    title: 'Stream Selection Simplified',
    category: 'Counseling',
    cluster: 'Humanities & Law',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'A structured way to weigh Science, Commerce and Humanities before picking your stream.',
  ),
  Course(
    id: 'course-career-clusters-explained',
    title: 'Career Clusters Explained',
    category: 'Counseling',
    cluster: 'Technology & Computer Science',
    duration: '2 weeks',
    modules: 5,
    image:
        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'A plain-language tour of tech career clusters and what each one is actually like day-to-day.',
  ),
  Course(
    id: 'course-college-entrance-roadmap',
    title: 'College & Entrance Exam Roadmap',
    category: 'Counseling',
    cluster: 'Medical & Healthcare',
    duration: '5 weeks',
    modules: 10,
    image:
        'https://images.unsplash.com/photo-1523240795612-9a054b0db644?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Plan your entrance-exam timeline and shortlist colleges that fit your goals and budget.',
  ),
  Course(
    id: 'course-web-dev-foundations',
    title: 'Web Development Foundations',
    category: 'Technology',
    cluster: 'Technology & Computer Science',
    duration: '9 weeks',
    modules: 18,
    image:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'HTML, CSS and JavaScript from scratch, building toward a real portfolio site.',
  ),
  Course(
    id: 'course-ai-ml-intro',
    title: 'Intro to AI & Machine Learning',
    category: 'Technology',
    cluster: 'Technology & Computer Science',
    duration: '10 weeks',
    modules: 20,
    image:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'The core ideas behind machine learning, with hands-on Python notebooks throughout.',
  ),
  Course(
    id: 'course-ui-ux-sprint',
    title: 'UI/UX Design Sprint',
    category: 'Design',
    cluster: 'Design & Creative',
    duration: '4 weeks',
    modules: 8,
    image:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Research, wireframe and prototype a real app screen in a fast, guided sprint.',
  ),
  Course(
    id: 'course-graphic-design-essentials',
    title: 'Graphic Design Essentials',
    category: 'Design',
    cluster: 'Design & Creative',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Typography, colour and layout fundamentals for posters, social posts and branding.',
  ),
  Course(
    id: 'course-motion-graphics-starter',
    title: 'Motion Graphics Starter',
    category: 'Design',
    cluster: 'Design & Creative',
    duration: '6 weeks',
    modules: 12,
    image:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Bring static designs to life with the basics of animation and motion design.',
  ),
  Course(
    id: 'course-stock-market-beginners',
    title: 'Stock Market for Beginners',
    category: 'Finance',
    cluster: 'Commerce & Finance',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'How markets actually work, from your first demat account to reading a stock chart.',
  ),
  Course(
    id: 'course-excel-finance-pro',
    title: 'Excel for Finance Professionals',
    category: 'Finance',
    cluster: 'Commerce & Finance',
    duration: '2 weeks',
    modules: 5,
    image:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'The Excel formulas and models finance teams actually use, not just the basics.',
  ),
  Course(
    id: 'course-financial-modeling-basics',
    title: 'Financial Modeling Basics',
    category: 'Finance',
    cluster: 'Commerce & Finance',
    duration: '6 weeks',
    modules: 12,
    image:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Build your first 3-statement financial model from the ground up.',
  ),
  Course(
    id: 'course-neet-crash-course',
    title: 'NEET Crash Course',
    category: 'Science',
    cluster: 'Medical & Healthcare',
    duration: '12 weeks',
    modules: 24,
    image:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'A full-syllabus sprint through Biology, Chemistry and Physics for NEET aspirants.',
  ),
  Course(
    id: 'course-physics-engineering-aspirants',
    title: 'Physics for Engineering Aspirants',
    category: 'Science',
    cluster: 'Technology & Computer Science',
    duration: '6 weeks',
    modules: 12,
    image:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Mechanics, waves and electromagnetism, built for JEE-style problem solving.',
  ),
  Course(
    id: 'course-lab-skills-practical',
    title: 'Lab Skills & Practical Science',
    category: 'Science',
    cluster: 'Medical & Healthcare',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Hands-on lab technique and safety, the practical half most courses skip.',
  ),
  Course(
    id: 'course-group-discussion-comms',
    title: 'Group Discussion & Communication Skills',
    category: 'Placement',
    cluster: 'Humanities & Law',
    duration: '3 weeks',
    modules: 6,
    image:
        'https://images.unsplash.com/photo-1573497491208-6b1acb260507?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Structure your thoughts and speak with confidence in GDs and panel rounds.',
  ),
  Course(
    id: 'course-aptitude-reasoning-bootcamp',
    title: 'Aptitude & Reasoning Bootcamp',
    category: 'Placement',
    cluster: 'Technology & Computer Science',
    duration: '5 weeks',
    modules: 10,
    image:
        'https://images.unsplash.com/photo-1573497491208-6b1acb260507?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    summary: 'Quant, logical reasoning and verbal ability drills for placement-test season.',
  ),
];

/// The 6 course categories, in the order shown throughout the app (Filter
/// screen, category picker, and the default carousel stack).
const courseCategories = ['Counseling', 'Technology', 'Design', 'Finance', 'Science', 'Placement'];

/// Duration buckets shown in the Filter screen's Duration row, derived from
/// the existing free-text `duration` field (e.g. "6 weeks") rather than a
/// new schema field. Kept in sync with [_matchesDurationBucket] below.
const courseDurationBuckets = ['Under 4 weeks', '4–8 weeks', '8+ weeks'];

/// Weeks parsed out of a course's [Course.duration] string (e.g. "6 weeks"
/// -> 6). Falls back to 0 for anything that doesn't parse, so an
/// unexpected format just never matches a duration filter instead of
/// throwing.
int _durationWeeks(String duration) {
  final match = RegExp(r'(\d+)').firstMatch(duration);
  return match != null ? int.parse(match.group(1)!) : 0;
}

bool _matchesDurationBucket(Course c, String bucket) {
  final weeks = _durationWeeks(c.duration);
  switch (bucket) {
    case 'Under 4 weeks':
      return weeks > 0 && weeks < 4;
    case '4–8 weeks':
      return weeks >= 4 && weeks <= 8;
    case '8+ weeks':
      return weeks > 8;
    default:
      return false;
  }
}

List<Course> filterCourses([String? category]) {
  if (category == null || category.toLowerCase() == 'all') return mockCourses;
  return mockCourses.where((c) => c.category.toLowerCase() == category.toLowerCase()).toList();
}

/// Multi-facet filter for the Courses tab's Filter screen — category and
/// duration-bucket are each optional and AND-combined (an empty list for a
/// facet means "don't filter on this facet"). Kept alongside the simpler
/// [filterCourses] rather than replacing it — search and the per-category
/// carousels only ever need a single category and have no reason to pull in
/// this richer shape.
///
/// [query] (Round V) lets a text search combine with the same facets
/// instead of being a separate, mutually-exclusive mode — matches title and
/// category, mirroring filterOpportunities' own multi-field `.contains()`
/// approach.
List<Course> filterCoursesAdvanced({
  List<String> categories = const [],
  List<String> durationBuckets = const [],
  String? query,
}) {
  final q = query?.trim().toLowerCase();
  return mockCourses.where((c) {
    if (categories.isNotEmpty && !categories.contains(c.category)) return false;
    if (durationBuckets.isNotEmpty && !durationBuckets.any((b) => _matchesDurationBucket(c, b))) return false;
    if (q != null && q.isNotEmpty && !c.title.toLowerCase().contains(q) && !c.category.toLowerCase().contains(q)) return false;
    return true;
  }).toList();
}

Course? getCourseById(String id) {
  try {
    return mockCourses.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
}

List<SyllabusModule> courseSyllabus(Course course) {
  final template = _syllabusTemplates[course.category] ?? const <String>[];
  final count = course.modules > 0 ? course.modules : (template.isNotEmpty ? template.length : 6);
  return List.generate(
    count,
    (i) => SyllabusModule(index: i + 1, title: i < template.length ? template[i] : 'Module ${i + 1}'),
  );
}

List<Course> recommendedCourses([List<String> clusters = const []]) {
  final recs = mockCourses.where((c) => clusters.contains(c.cluster)).toList();
  // Fallback also takes 6 (not 4) — the final .take(6) below is a no-op
  // ceiling if the fallback itself already capped lower, which meant a
  // user with no cluster match (or none yet) could never see enough
  // courses here to reach CourseCarouselSection's own >=5 "View all" tile
  // threshold.
  final list = recs.isNotEmpty ? recs : mockCourses.take(6).toList();
  return list.take(6).toList();
}

List<Course> prepCoursesFor(List<String> ids) {
  return mockCourses.where((c) => ids.contains(c.id)).toList();
}

/// Every prep course tied to a set of opportunities, deduped and falling
/// back to the general catalog so the result is never empty — shared by
/// the applications tracker's "prep for this interview" sheet and the
/// college Home feed's end-of-scroll "Courses to boost your profile" carousel.
List<Course> prepCoursesForOpportunities(Iterable<Opportunity> opportunities, {int take = 4}) {
  final ids = <String>[];
  for (final opp in opportunities) {
    for (final courseId in opp.prepCourses) {
      if (!ids.contains(courseId)) ids.add(courseId);
    }
  }
  final courses = prepCoursesFor(ids);
  if (courses.length >= take) return courses.take(take).toList();
  // Top up with the general catalog (deduped) rather than stopping short —
  // a small real-matched pool otherwise permanently keeps this carousel
  // under CourseCarouselSection's own >=5 "View all" tile threshold.
  final result = [...courses];
  for (final c in mockCourses) {
    if (result.length >= take) break;
    if (!result.any((r) => r.id == c.id)) result.add(c);
  }
  return result;
}
