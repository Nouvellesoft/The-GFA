class MatchDayBannerForLocation {
  String? location;
  String? postCode;
  dynamic id;

  // Constructor
  MatchDayBannerForLocation({this.location, this.postCode});

  MatchDayBannerForLocation.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    location = data['location'];
    postCode = data['post_code'];
  }
}
