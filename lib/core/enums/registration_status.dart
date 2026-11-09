/// Player attendance status for a specific football match.
enum RegistrationStatus {
  confirmed, // In the active match roster
  waiting, // In the queue waiting list
  cancelled; // Cancelled attendance

  String get labelArabic => switch (this) {
    RegistrationStatus.confirmed => 'أساسي مؤكد',
    RegistrationStatus.waiting => 'قائمة الانتظار',
    RegistrationStatus.cancelled => 'معتذر',
  };

  String get labelEnglish => switch (this) {
    RegistrationStatus.confirmed => 'Confirmed',
    RegistrationStatus.waiting => 'Waiting List',
    RegistrationStatus.cancelled => 'Cancelled',
  };
}
