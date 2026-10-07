import 'package:flutter/widgets.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../models/opportunity.dart';

/// First meta line group for [OpportunityRow]: city and sector, the pay line
/// (monthly stipend for internships, otherwise the salary range) and duration.
List<String> opportunityMeta(Opportunity o) => [
      o.sector.isEmpty ? o.location : '${o.location} · ${o.sector}',
      o.stipend,
      o.duration,
    ];

/// The rest of the spreadsheet's fields for a job, as icon + text pairs:
/// experience, department, the LPA-equivalent for internships, startup ID and
/// the demo-opening flag. Empty values are skipped.
List<(IconData, String)> opportunityExtraMeta(Opportunity o) => [
      if (o.experience.isNotEmpty) (Ionicons.briefcase_outline, 'Experience: ${o.experience}'),
      if (o.department.isNotEmpty) (Ionicons.layers_outline, o.department),
      if (o.internStipend != null && o.salaryRange.isNotEmpty) (Ionicons.cash_outline, o.salaryRange),
      if (o.startupId.isNotEmpty) (Ionicons.business_outline, 'Startup ${o.startupId}'),
      if (o.demoOpening) (Ionicons.flag_outline, 'Demo opening'),
    ];
