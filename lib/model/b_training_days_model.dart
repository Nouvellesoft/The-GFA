class TrainingDays {
  String? day;
  String? fromTime;
  String? toTime;
  String? location;
  String? postCode;

  TrainingDays({this.day, this.fromTime, this.toTime, this.location, this.postCode});

  // Factory constructor to create a TrainingDays instance from a map entry
  factory TrainingDays.fromMap(Map<String, dynamic> data) {
    return TrainingDays(
      day: data['day'] as String?,
      fromTime: data['from_time'] as String?,
      toTime: data['to_time'] as String?,
      location: data['location'] as String?,
      postCode: data['post_code'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'from_Time': fromTime,
      'to_time': toTime,
      'location': location,
      'post_code': postCode,
    };
  }
}
