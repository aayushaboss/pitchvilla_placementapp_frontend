/// Mirrors frontend/src/mockData/mockOpportunities.ts `Opportunity`.
class Opportunity {
  final String id;
  final String title;
  final String company;
  final String type;
  final String location;
  final String workMode;
  final String stipend;
  final String duration;
  final String category;

  /// `Full-time`/`Part-time` — only ever meaningful when [type] is
  /// `'Full-time'`; every Internship leaves this null. Lets the Home
  /// filter's Employment Type facet actually narrow results, unlike
  /// [type] alone (Internship vs Full-time), which is a separate facet.
  final String? employmentType;
  final String image;
  final String about;
  final List<String> requirements;
  final List<String> prepCourses;

  /// ISO date (yyyy-MM-dd) the application window closes. Drives the
  /// urgency indicator on cards — prototype-only, replace with a real
  /// deadline from the API later.
  final String deadline;

  /// How many people have applied so far — shown on the detail page
  /// (Naukri-style social proof). Mocked; a real API would return this.
  final int applicantCount;

  /// Quick pre-apply screening questions, company-voice ("Are you willing
  /// to relocate?"). Paired index-for-index with [screeningQuestionOptions]
  /// — each question carries its own tappable quick-answer badges rather
  /// than one generic Yes/No set reused everywhere.
  final List<String> screeningQuestions;
  final List<List<String>> screeningQuestionOptions;

  const Opportunity({
    required this.id,
    required this.title,
    required this.company,
    required this.type,
    required this.location,
    required this.workMode,
    required this.stipend,
    required this.duration,
    required this.category,
    this.employmentType,
    required this.image,
    required this.about,
    required this.requirements,
    required this.prepCourses,
    required this.deadline,
    this.applicantCount = 0,
    this.screeningQuestions = const [],
    this.screeningQuestionOptions = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'type': type,
        'location': location,
        'workMode': workMode,
        'stipend': stipend,
        'duration': duration,
        'category': category,
        'employmentType': employmentType,
        'image': image,
        'about': about,
        'requirements': requirements,
        'prepCourses': prepCourses,
        'deadline': deadline,
        'applicantCount': applicantCount,
        'screeningQuestions': screeningQuestions,
        'screeningQuestionOptions': screeningQuestionOptions,
      };

  factory Opportunity.fromJson(Map<String, dynamic> json) => Opportunity(
        id: json['id'] as String,
        title: json['title'] as String,
        company: json['company'] as String,
        type: json['type'] as String,
        location: json['location'] as String,
        workMode: json['workMode'] as String,
        stipend: json['stipend'] as String,
        duration: json['duration'] as String,
        category: json['category'] as String,
        employmentType: json['employmentType'] as String?,
        image: json['image'] as String,
        about: json['about'] as String,
        requirements: (json['requirements'] as List).cast<String>(),
        prepCourses: (json['prepCourses'] as List).cast<String>(),
        deadline: json['deadline'] as String,
        applicantCount: json['applicantCount'] as int? ?? 0,
        screeningQuestions: (json['screeningQuestions'] as List?)?.cast<String>() ?? const [],
        screeningQuestionOptions: (json['screeningQuestionOptions'] as List?)
                ?.map((o) => (o as List).cast<String>())
                .toList() ??
            const [],
      );
}
