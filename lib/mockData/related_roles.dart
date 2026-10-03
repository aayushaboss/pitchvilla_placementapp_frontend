// Prototype mock data — delete when real API is wired.
/// Adjacent-field recommendations — picking a role surfaces a few related
/// ones alongside it. Shared by onboarding's role picker (goals_screen.dart)
/// and the college Home feed's "related field" carousel backfill
/// (college_feed_screen.dart).
const Map<String, List<String>> relatedRoles = {
  'Software': ['Data', 'Product', 'Design', 'Research'],
  'Data': ['Software', 'Research', 'Finance', 'Product'],
  'Marketing': ['Content', 'Sales', 'Design', 'Product'],
  'Finance': ['Data', 'Consulting', 'Operations', 'Research'],
  'Design': ['Product', 'Software', 'Marketing', 'Content'],
  'Product': ['Software', 'Design', 'Data', 'Marketing'],
  'Content': ['Marketing', 'Design', 'Sales', 'Research'],
  'Sales': ['Marketing', 'Operations', 'Consulting', 'Content'],
  'Operations': ['Sales', 'Finance', 'Consulting', 'HR'],
  'HR': ['Operations', 'Consulting', 'Sales', 'Research'],
  'Consulting': ['Finance', 'Operations', 'Sales', 'Research'],
  'Research': ['Data', 'Software', 'Finance', 'Consulting'],
};
