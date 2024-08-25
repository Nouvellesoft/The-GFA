class YouTube {
  String? toastURL;
  String? title;

  YouTube({this.toastURL, this.title});

  // Factory constructor to create a YouTube instance from a map entry
  factory YouTube.fromMap(Map<String, dynamic> data) {
    return YouTube(
      toastURL: data['url'] as String?,
      title: data['title'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'toast_name': toastURL,
      'yid': title,
    };
  }
}
