// Prototype mock data — delete when real API is wired.
// Mirrors frontend/src/mockData/mockNotifications.ts.
import '../models/notification_item.dart';

/// College/default segment.
const List<NotificationItem> mockNotifications = [
  NotificationItem(
    id: 'n1',
    group: 'Today',
    title: '3 new internships match your goals',
    body: 'Fresh Software roles just opened — take a look.',
    type: 'opportunity',
    unread: true,
    // The exact 3 Software internships this notification promised — not a
    // live category filter, since that would silently drift out of sync
    // with "3" as the mock catalog changes. See OpportunityListScreen.ids.
    // (Deliberately none of these is 'opp-frontend-intern' — the seed data
    // in mock_applications.dart already has an application in for that one,
    // and OpportunityListScreen hides already-applied roles, which would
    // quietly shrink this to 2 cards.)
    route: '/opportunities?title=New%20internships%20for%20you'
        '&ids=opp-extra-0-software-engineer-intern,opp-extra-2-mobile-app-developer-intern,opp-extra-3-qa-engineer-intern',
  ),
  NotificationItem(
    id: 'n2',
    group: 'Today',
    title: "You're shortlisted! 🎉",
    body: 'Microsoft wants to interview you for Frontend Developer Intern.',
    type: 'application',
    unread: true,
    route: '/application/app-seed-interview',
  ),
  NotificationItem(
    id: 'n3',
    group: 'Earlier',
    title: 'Welcome to Pitchvilla',
    body: 'Your journey to the right next step starts here.',
    type: 'system',
    unread: false,
  ),
];

/// School segment — same shape/grouping as [mockNotifications], but n1/n2
/// there are internship/job-application copy that doesn't fit a segment
/// with no Applications tab and no job listings. Swapped for the school
/// equivalents of the same two moments: new course recommendations, and a
/// booked-session confirmation.
const List<NotificationItem> mockSchoolNotifications = [
  NotificationItem(
    id: 'sn1',
    group: 'Today',
    title: '3 new courses match your interests',
    body: 'Fresh picks based on your aptitude results.',
    type: 'course',
    unread: true,
    route: '/tabs/browse',
  ),
  NotificationItem(
    id: 'sn2',
    group: 'Today',
    title: 'Your counseling session is confirmed',
    body: 'Ms. Ananya Rao will see you Thu, 14 Aug at 02:30 PM.',
    type: 'application',
    unread: true,
    route: '/tabs/sessions',
  ),
  NotificationItem(
    id: 'n3',
    group: 'Earlier',
    title: 'Welcome to Pitchvilla',
    body: 'Your journey to the right next step starts here.',
    type: 'system',
    unread: false,
  ),
];
