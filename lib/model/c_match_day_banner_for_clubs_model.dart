class MatchDayBannerForClub {
  String? clubIcon;
  String? teamName;
  dynamic id;

  MatchDayBannerForClub({
    this.teamName,
    this.clubIcon,
    this.id,
  });

  MatchDayBannerForClub.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    teamName = data['team_name'];
    clubIcon = data['club_icon']; // Initially set from Firestore
  }

  void updateClubIcon(String icon) {
    clubIcon = icon;
  }
}
