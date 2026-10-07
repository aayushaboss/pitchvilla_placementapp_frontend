// Prototype mock data — delete when real API is wired.
//
// The job catalogue is the "Job Lists for Pitchvilla Hiring App" spreadsheet
// (1,000 jobs, 100 startups). It is loaded from assets/data/jobs.json by
// catalog_loader.dart before the app starts; this file keeps the same
// synchronous accessors the screens have always used.
import '../models/opportunity.dart';

List<Opportunity> _opportunities = const [];
Map<String, Opportunity> _byId = const {};

/// All jobs, in spreadsheet order. Empty until [installOpportunities] runs.
List<Opportunity> get mockOpportunities => _opportunities;

/// Called by catalog_loader.dart once the spreadsheet data is parsed.
void installOpportunities(List<Opportunity> items) {
  _opportunities = List.unmodifiable(items);
  _byId = {for (final o in items) o.id: o};
}

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
          o.sector.toLowerCase().contains(q) ||
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
    if (o.sector.isNotEmpty) terms.add(o.sector);
  }
  return terms.toList()..sort();
}

Opportunity? getOpportunityById(String id) => _byId[id];
