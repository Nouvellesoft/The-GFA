class MatchDayBannerForClub {
  String? clubIcon;
  String? clubName;
  String? teamName;
  dynamic id;

  MatchDayBannerForClub({
    this.clubName,
    this.teamName,
    this.clubIcon,
    this.id,
  });

  MatchDayBannerForClub.fromMap(Map<String?, dynamic> data) {
    id = data['id'];
    clubName = data['team_name'];
    teamName = data['team_name'];
    clubIcon = data['club_icon'];
  }

  void updateClubIcon(String icon) {
    clubIcon = icon;
  }
}
