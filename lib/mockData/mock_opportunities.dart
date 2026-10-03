// Prototype mock data — delete when real API is wired.
// Mirrors frontend/src/mockData/mockOpportunities.ts.
import '../models/opportunity.dart';

/// Deadlines are generated relative to "now" (not baked-in absolute dates)
/// so the urgency indicator on cards always looks live, no matter when this
/// prototype is actually run/demoed.
String _deadlineIn(int days) => DateTime.now().add(Duration(days: days)).toIso8601String().substring(0, 10);

final List<Opportunity> mockOpportunities = [
  Opportunity(
    id: 'opp-frontend-intern',
    title: 'Frontend Developer Intern',
    company: 'Microsoft',
    type: 'Internship',
    location: 'Bengaluru',
    workMode: 'Hybrid',
    stipend: '₹25,000/mo',
    duration: '6 months',
    category: 'Software',
    image:
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about:
        'Join our product team to build delightful web experiences with React and TypeScript.',
    requirements: ['React & JavaScript basics', 'HTML/CSS fluency', 'Git workflow', 'Eye for detail'],
    prepCourses: ['course-coding-basics', 'course-interview-prep'],
    deadline: _deadlineIn(3),
    applicantCount: 86,
    screeningQuestions: const ['When can you start?', 'Comfortable with a hybrid role?'],
    screeningQuestionOptions: const [
      ['Immediately', 'In 2 weeks', 'In a month'],
      ['Yes', 'No', 'Need more details'],
    ],
  ),
  Opportunity(
    id: 'opp-data-analyst',
    title: 'Junior Data Analyst',
    company: 'Deloitte',
    type: 'Full-time',
    location: 'Pune',
    workMode: 'Onsite',
    stipend: '₹6.5 LPA',
    duration: 'Permanent',
    category: 'Data',
    employmentType: 'Full-time',
    image:
        'https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Turn raw data into decisions. Work with SQL, dashboards and stakeholders.',
    requirements: ['SQL proficiency', 'Excel / Sheets', 'Basic statistics', 'Communication'],
    prepCourses: ['course-data-analytics', 'course-interview-prep'],
    deadline: _deadlineIn(9),
    applicantCount: 142,
    screeningQuestions: const ['Total years of experience?', 'Willing to relocate to Pune?'],
    screeningQuestionOptions: const [
      ['Fresher', '0-1 years', '1-3 years'],
      ['Yes', 'No', 'Already in Pune'],
    ],
  ),
  Opportunity(
    id: 'opp-marketing-intern',
    title: 'Digital Marketing Intern',
    company: 'Dentsu',
    type: 'Internship',
    location: 'Remote',
    workMode: 'Remote',
    stipend: '₹15,000/mo',
    duration: '3 months',
    category: 'Marketing',
    image:
        'https://images.unsplash.com/photo-1460925895917-afdab827c52f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Run social campaigns, write copy and learn performance marketing hands-on.',
    requirements: ['Strong writing', 'Social media savvy', 'Canva basics', 'Curiosity'],
    prepCourses: ['course-design-thinking', 'course-resume-builder'],
    deadline: _deadlineIn(2),
    applicantCount: 58,
    screeningQuestions: const ['When can you start?', 'Do you have a laptop for remote work?'],
    screeningQuestionOptions: const [
      ['Immediately', 'In 2 weeks', 'In a month'],
      ['Yes', 'No'],
    ],
  ),
  Opportunity(
    id: 'opp-finance-analyst',
    title: 'Finance Analyst Trainee',
    company: 'Morgan Stanley',
    type: 'Full-time',
    location: 'Mumbai',
    workMode: 'Onsite',
    stipend: '₹7 LPA',
    duration: 'Permanent',
    category: 'Finance',
    employmentType: 'Full-time',
    image:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Support investment research and financial modeling for our analyst team.',
    requirements: [
      'Accounting fundamentals',
      'Excel modeling',
      'Analytical mindset',
      'Attention to detail',
    ],
    prepCourses: ['course-commerce-finance', 'course-interview-prep'],
    deadline: _deadlineIn(21),
    applicantCount: 97,
    screeningQuestions: const ['Total years of experience?', 'Willing to relocate to Mumbai?'],
    screeningQuestionOptions: const [
      ['Fresher', '0-1 years', '1-3 years'],
      ['Yes', 'No', 'Already in Mumbai'],
    ],
  ),
  Opportunity(
    id: 'opp-uiux-intern',
    title: 'UI/UX Design Intern',
    company: 'Adobe',
    type: 'Internship',
    location: 'Hyderabad',
    workMode: 'Hybrid',
    stipend: '₹20,000/mo',
    duration: '6 months',
    category: 'Design',
    image:
        'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Design mobile-first flows in Figma and ship pixel-perfect interfaces.',
    requirements: ['Figma', 'Design fundamentals', 'Portfolio', 'Collaboration'],
    prepCourses: ['course-design-thinking', 'course-resume-builder'],
    deadline: _deadlineIn(5),
    applicantCount: 73,
    screeningQuestions: const ['Do you have a portfolio ready?', 'Comfortable with a hybrid role?'],
    screeningQuestionOptions: const [
      ['Yes', 'No', 'Still building it'],
      ['Yes', 'No', 'Need more details'],
    ],
  ),
  Opportunity(
    id: 'opp-backend-engineer',
    title: 'Backend Engineer (Fresher)',
    company: 'Amazon',
    type: 'Full-time',
    location: 'Bengaluru',
    workMode: 'Hybrid',
    stipend: '₹9 LPA',
    duration: 'Permanent',
    category: 'Software',
    employmentType: 'Full-time',
    image:
        'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Build scalable APIs and services with Python and cloud infrastructure.',
    requirements: ['Python', 'REST APIs', 'Databases', 'Problem solving'],
    prepCourses: ['course-coding-basics', 'course-data-analytics'],
    deadline: _deadlineIn(14),
    applicantCount: 164,
    screeningQuestions: const ['Total years of experience?', 'When can you start?'],
    screeningQuestionOptions: const [
      ['Fresher', '0-1 years', '1-3 years'],
      ['Immediately', 'In 2 weeks', 'In a month'],
    ],
  ),
  Opportunity(
    id: 'opp-content-intern',
    title: 'Content Writer Intern',
    company: 'Ogilvy',
    type: 'Internship',
    location: 'Remote',
    workMode: 'Remote',
    stipend: '₹12,000/mo',
    duration: '4 months',
    category: 'Content',
    image:
        'https://images.unsplash.com/photo-1455390582262-044cdead277a?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Write blogs, scripts and social content for a fast-growing media brand.',
    requirements: ['Excellent English', 'Research skills', 'SEO basics', 'Creativity'],
    prepCourses: ['course-resume-builder', 'course-design-thinking'],
    deadline: _deadlineIn(30),
    applicantCount: 41,
    screeningQuestions: const ['When can you start?', 'Do you have writing samples to share?'],
    screeningQuestionOptions: const [
      ['Immediately', 'In 2 weeks', 'In a month'],
      ['Yes', 'No', 'Can prepare some'],
    ],
  ),
  Opportunity(
    id: 'opp-product-intern',
    title: 'Associate Product Manager Intern',
    company: 'Accenture',
    type: 'Internship',
    location: 'Gurugram',
    workMode: 'Onsite',
    stipend: '₹30,000/mo',
    duration: '6 months',
    category: 'Product',
    image:
        'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
    about: 'Own features end-to-end, talk to users and drive the roadmap with the team.',
    requirements: ['Structured thinking', 'Communication', 'Basic analytics', 'User empathy'],
    prepCourses: ['course-data-analytics', 'course-interview-prep'],
    deadline: _deadlineIn(7),
    applicantCount: 119,
    screeningQuestions: const ['When can you start?', 'Comfortable working onsite in Gurugram?'],
    screeningQuestionOptions: const [
      ['Immediately', 'In 2 weeks', 'In a month'],
      ['Yes', 'No', 'Already in Gurugram'],
    ],
  ),
  ..._extraOpportunities,
];

/// Same working image set as the hand-authored cards above, cycled — a
/// broken/placeholder image link would undercut the "does this feel like a
/// real feed" point of padding the list out in the first place.
const _extraOpportunityImages = [
  'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1460925895917-afdab827c52f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1554224155-6726b3ff858f?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1561070791-2526d30994b5?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1455390582262-044cdead277a?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
  'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?crop=entropy&cs=srgb&fm=jpg&q=85&w=800',
];

/// ~10 more listings per browsable category (on top of the hand-authored
/// heroes above) so every role carousel on the feed has enough volume to
/// show the trailing "View all" tile (which only appears past 5 cards) and
/// the "View all" grid is a real list, not a two-row screen.
const _fillCompanies = [
  'Microsoft', 'Deloitte', 'Dentsu', 'Adobe', 'IBM', 'EY', 'Infosys', 'Morgan Stanley',
  'JPMorgan Chase', 'Ogilvy', 'Accenture', 'Wipro', 'DHL', 'TCS', 'Cognizant', 'HCLTech',
  'Capgemini', 'KPMG', 'Amazon', 'Flipkart', 'Razorpay', 'Freshworks', 'Zoho', 'PhonePe', 'Swiggy',
];

/// (type, location, workMode, stipend, duration, employmentType) — cycled
/// across the generated listings so each carousel has a realistic mix of
/// internships / full-time / part-time and cities. employmentType is null
/// for every Internship (the distinction doesn't apply).
const _fillRotation = [
  ('Internship', 'Bengaluru', 'Hybrid', '₹22,000/mo', '6 months', null),
  ('Full-time', 'Pune', 'Onsite', '₹7 LPA', 'Permanent', 'Full-time'),
  ('Internship', 'Remote', 'Remote', '₹18,000/mo', '3 months', null),
  ('Full-time', 'Mumbai', 'Hybrid', '₹8.5 LPA', 'Permanent', 'Full-time'),
  ('Internship', 'Hyderabad', 'Onsite', '₹20,000/mo', '4 months', null),
  ('Full-time', 'Gurugram', 'Remote', '₹5.5 LPA', 'Permanent', 'Part-time'),
  ('Internship', 'Chennai', 'Hybrid', '₹15,000/mo', '6 months', null),
  ('Full-time', 'Delhi', 'Onsite', '₹6.5 LPA', 'Permanent', 'Full-time'),
  ('Internship', 'Noida', 'Remote', '₹25,000/mo', '3 months', null),
  ('Full-time', 'Bengaluru', 'Hybrid', '₹9 LPA', 'Permanent', 'Part-time'),
];

const _fillTitles = <String, List<String>>{
  'Software': [
    'Backend Developer', 'Frontend Engineer', 'Full Stack Developer', 'DevOps Engineer',
    'Android Developer', 'iOS Developer', 'QA Automation Engineer', 'Site Reliability Engineer',
    'Cloud Engineer', 'Platform Engineer',
  ],
  'Data': [
    'Data Analyst', 'Data Engineer', 'Data Scientist', 'BI Developer', 'Analytics Engineer',
    'ML Engineer', 'Reporting Analyst', 'Database Developer', 'Quantitative Analyst', 'Insights Analyst',
  ],
  'Marketing': [
    'Digital Marketing Executive', 'SEO Specialist', 'Content Marketing Associate', 'Social Media Manager',
    'Brand Marketing Executive', 'Performance Marketing Analyst', 'Email Marketing Associate',
    'Marketing Operations Analyst', 'Growth Marketer', 'Campaign Manager',
  ],
  'Finance': [
    'Financial Analyst', 'Investment Analyst', 'Accounts Executive', 'Audit Associate', 'Tax Analyst',
    'Treasury Analyst', 'Risk Analyst', 'Equity Research Associate', 'FP&A Analyst', 'Credit Analyst',
  ],
  'Design': [
    'UI Designer', 'UX Designer', 'Product Designer', 'Graphic Designer', 'Visual Designer',
    'Motion Designer', 'Interaction Designer', 'Design Researcher', 'Brand Designer', 'UX Writer',
  ],
  'Product': [
    'Product Analyst', 'Associate Product Manager', 'Product Operations Associate', 'Technical Product Manager',
    'Product Marketing Manager', 'Growth Product Analyst', 'Product Researcher', 'Platform Product Analyst',
    'Product Strategy Associate', 'Junior Product Manager',
  ],
  'Content': [
    'Content Writer', 'Copywriter', 'Content Strategist', 'Technical Writer', 'Editorial Associate',
    'SEO Content Writer', 'Scriptwriter', 'Content Producer', 'Content Designer', 'Content Marketing Writer',
  ],
  'Sales': [
    'Business Development Executive', 'Inside Sales Associate', 'Sales Development Rep', 'Account Executive',
    'Partnerships Associate', 'Key Account Manager', 'Sales Operations Analyst', 'Client Success Associate',
    'Lead Generation Specialist', 'Territory Sales Executive',
  ],
  'Operations': [
    'Operations Associate', 'Supply Chain Analyst', 'Logistics Coordinator', 'Operations Analyst',
    'Process Excellence Associate', 'Vendor Operations Executive', 'City Operations Manager',
    'Fulfilment Associate', 'Business Operations Analyst', 'Category Operations Associate',
  ],
  'HR': [
    'HR Associate', 'Talent Acquisition Specialist', 'HR Operations Executive', 'Recruitment Coordinator',
    'People Operations Associate', 'Learning & Development Associate', 'Compensation Analyst',
    'Employee Experience Coordinator', 'HR Analyst', 'Campus Recruiter',
  ],
  'Consulting': [
    'Business Analyst', 'Strategy Associate', 'Management Consultant', 'Operations Consultant',
    'Consulting Analyst', 'Transformation Consultant', 'Technology Consultant', 'Associate Consultant',
    'Process Consultant', 'Strategy Analyst',
  ],
  'Research': [
    'Research Analyst', 'Market Research Associate', 'Research Assistant', 'Policy Research Associate',
    'User Research Associate', 'Quantitative Research Associate', 'Data Research Analyst',
    'Secondary Research Analyst', 'Consumer Insights Analyst', 'Research Operations Associate',
  ],
};

final List<Opportunity> _extraOpportunities = () {
  final out = <Opportunity>[];
  var n = 0;
  for (final entry in _fillTitles.entries) {
    final category = entry.key;
    // Each title twice (with different rotation/company via the flat
    // counter) — ~20 per category so that even after the feed's
    // goal-type filter (Internship-only / Full-time-only), every role
    // carousel comfortably exceeds the 5-card cap and shows "View all".
    for (final baseTitle in [...entry.value, ...entry.value]) {
      final (type, location, workMode, stipend, duration, employmentType) = _fillRotation[n % _fillRotation.length];
      final company = _fillCompanies[n % _fillCompanies.length];
      final title = type == 'Internship' ? '$baseTitle Intern' : baseTitle;
      final slug = title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      out.add(Opportunity(
        id: 'opp-fill-$n-$slug',
        title: title,
        company: company,
        type: type,
        location: location,
        workMode: workMode,
        stipend: stipend,
        duration: duration,
        category: category,
        employmentType: employmentType,
        image: _extraOpportunityImages[n % _extraOpportunityImages.length],
        about: 'Join $company as a $title, working with a small team that moves fast and ships often.',
        requirements: const ['Strong fundamentals', 'Good communication', 'Ownership mindset', 'Eagerness to learn'],
        prepCourses: const ['course-interview-prep'],
        deadline: _deadlineIn(4 + (n % 12)),
        applicantCount: 18 + (n * 11) % 160,
      ));
      n++;
    }
  }
  return out;
}();

List<Opportunity> filterOpportunities({
  String? type,
  String? workMode,
  String? query,
  List<String>? categories,
  String? location,
  String? employmentType,
  List<String>? locations,
}) {
  var items = mockOpportunities;
  if (type != null && type.toLowerCase() != 'all') {
    items = items.where((o) => o.type.toLowerCase() == type.toLowerCase()).toList();
  }
  if (workMode != null && workMode.toLowerCase() != 'all') {
    items = items.where((o) => o.workMode.toLowerCase() == workMode.toLowerCase()).toList();
  }
  // Null on every Internship (see Opportunity.employmentType), so filtering
  // by this while Internship is also selected correctly excludes
  // everything rather than silently matching nothing for an unclear reason.
  if (employmentType != null) {
    items = items.where((o) => (o.employmentType ?? '').toLowerCase() == employmentType.toLowerCase()).toList();
  }
  if (categories != null && categories.isNotEmpty) {
    final wanted = categories.map((c) => c.toLowerCase()).toSet();
    items = items.where((o) => wanted.contains(o.category.toLowerCase())).toList();
  }
  // Independent of `query` below — a search screen with a dedicated
  // Location field needs "React AND Bengaluru" (both must match), not
  // "React OR Bengaluru" the way a single free-text query treats location.
  final loc = location?.trim().toLowerCase();
  if (loc != null && loc.isNotEmpty) {
    items = items.where((o) => o.location.toLowerCase().contains(loc)).toList();
  }
  // Preferred-cities facet — OR-matched (any one of several saved cities
  // is a match), additive to (not a replacement for) the single `location`
  // param above, which search_screen.dart's dedicated Location field still
  // uses unchanged.
  if (locations != null && locations.isNotEmpty) {
    final wanted = locations.map((c) => c.trim().toLowerCase()).where((c) => c.isNotEmpty).toList();
    if (wanted.isNotEmpty) {
      items = items.where((o) => wanted.any((c) => o.location.toLowerCase().contains(c))).toList();
    }
  }
  final q = query?.trim().toLowerCase();
  if (q != null && q.isNotEmpty) {
    items = items.where((o) {
      return o.title.toLowerCase().contains(q) ||
          o.company.toLowerCase().contains(q) ||
          o.category.toLowerCase().contains(q) ||
          o.location.toLowerCase().contains(q);
    }).toList();
  }
  // Always hand back a fresh, independently-sortable copy — callers must
  // never be able to mutate the shared mockOpportunities order in place.
  return List.of(items);
}

/// Distinct company/category/title strings — the type-ahead suggestion
/// pool for the search screen's query box, mirroring Naukri's own mixed
/// company/skill/designation suggestions instead of only matching titles.
List<String> searchSuggestionTerms() {
  final terms = <String>{};
  for (final o in mockOpportunities) {
    terms.add(o.company);
    terms.add(o.category);
    terms.add(o.title);
  }
  return terms.toList()..sort();
}

Opportunity? getOpportunityById(String id) {
  try {
    return mockOpportunities.firstWhere((o) => o.id == id);
  } catch (_) {
    return null;
  }
}
