import 'dart:collection';

import 'package:flutter/cupertino.dart';

import '../model/b_youtube_model.dart';

class YouTubeNotifier with ChangeNotifier {
  List<YouTube> _youTubeList = [];
  YouTube _currentYouTube = YouTube();

  UnmodifiableListView<YouTube> get youTubeList => UnmodifiableListView(_youTubeList);

  YouTube get currentYouTube => _currentYouTube;

  set youTubeList(List<YouTube> youTubeList) {
    _youTubeList = youTubeList;
    notifyListeners();
  }

  set currentYouTube(YouTube youTube) {
    _currentYouTube = youTube;
    notifyListeners();
  }
}
