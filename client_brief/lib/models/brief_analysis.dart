class Requirement {
  final String id;
  final String category;
  final String description;
  final String priority;

  const Requirement({
    required this.id,
    required this.category,
    required this.description,
    required this.priority,
  });

  factory Requirement.fromJson(Map<String, dynamic> json) {
    return Requirement(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'medium',
    );
  }
}

class DeveloperTicket {
  final String id;
  final String title;
  final String description;
  final List<String> acceptanceCriteria;
  final String priority;
  final String category;

  const DeveloperTicket({
    required this.id,
    required this.title,
    required this.description,
    required this.acceptanceCriteria,
    required this.priority,
    required this.category,
  });

  factory DeveloperTicket.fromJson(Map<String, dynamic> json) {
    final criteria = json['acceptance_criteria'];
    return DeveloperTicket(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      acceptanceCriteria: criteria is List
          ? criteria.map((e) => e.toString()).toList()
          : [],
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String? ?? 'General',
    );
  }
}

class BriefAnalysis {
  final String summary;
  final List<Requirement> requirements;
  final List<DeveloperTicket> tickets;
  final List<String> clarifications;

  const BriefAnalysis({
    required this.summary,
    required this.requirements,
    required this.tickets,
    required this.clarifications,
  });

  factory BriefAnalysis.fromJson(Map<String, dynamic> json) {
    final reqList = json['requirements'] as List<dynamic>? ?? [];
    final ticketList = json['tickets'] as List<dynamic>? ?? [];
    final clarList = json['clarifications'] as List<dynamic>? ?? [];

    return BriefAnalysis(
      summary: json['summary'] as String? ?? '',
      requirements: reqList
          .map((e) => Requirement.fromJson(e as Map<String, dynamic>))
          .toList(),
      tickets: ticketList
          .map((e) => DeveloperTicket.fromJson(e as Map<String, dynamic>))
          .toList(),
      clarifications: clarList.map((e) => e.toString()).toList(),
    );
  }
}
