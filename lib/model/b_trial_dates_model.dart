class TrialDates {
  String? day;
  String? fromTime;
  String? toTime;
  String? location;
  String? postCode;
  String? pleaseNote;

  TrialDates({this.day, this.fromTime, this.toTime, this.location, this.postCode, this.pleaseNote});

  // Factory constructor to create a TrialDates instance from a map entry
  factory TrialDates.fromMap(Map<String, dynamic> data) {
    return TrialDates(
      day: data['day'] as String?,
      fromTime: data['from_time'] as String?,
      toTime: data['to_time'] as String?,
      location: data['location'] as String?,
      postCode: data['post_code'] as String?,
      pleaseNote: data['please_note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'from_Time': fromTime,
      'to_time': toTime,
      'location': location,
      'post_code': postCode,
      'please_note': pleaseNote,
    };
  }
}
