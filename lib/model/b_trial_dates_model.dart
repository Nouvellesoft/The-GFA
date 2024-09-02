class TrialDates {
  String? date;
  String? fromTime;
  String? toTime;
  String? location;
  String? postCode;
  String? pleaseNote;

  TrialDates({this.date, this.fromTime, this.toTime, this.location, this.postCode, this.pleaseNote});

  // Factory constructor to create a TrialDates instance from a map entry
  factory TrialDates.fromMap(Map<String, dynamic> data) {
    return TrialDates(
      date: data['date'] as String?,
      fromTime: data['from_time'] as String?,
      toTime: data['to_time'] as String?,
      location: data['location'] as String?,
      postCode: data['post_code'] as String?,
      pleaseNote: data['please_note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'from_Time': fromTime,
      'to_time': toTime,
      'location': location,
      'post_code': postCode,
      'please_note': pleaseNote,
    };
  }
}
