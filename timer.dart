import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Timer;
import 'dart:async' show Future;

class Conference {
  String _name;
  DateTime _deadline;
  static List<Conference> confs = [];
  Conference(String name, String deadline) {
    if (name == null) {
      _name = "";
    } else {
      _name = name;
    }
    if (deadline == null) {
      _deadline = new DateTime.now();
    } else {
      _deadline = DateTime.parse(deadline);
    }
  }

  static Future readyTheConferences() {
    var path = 'conferences.json';
    return HttpRequest.getString(path)
        .then(_parseConferencesFromJSON);
  }
  
  static _parseConferencesFromJSON(String jsonString) {
    List conf_strs = JSON.decode(jsonString);
    for (var conf_str in  conf_strs) {
      confs.add(new Conference(conf_str["name"], conf_str["deadline"]));
    }
    confs.sort((x, y) => x.deadline.compareTo(y.deadline));
  }

  String get jsonString => '{ "name": "$_name", "deadline": "$_deadline.ToString()" } ';

  String get name => _name;

  DateTime get deadline => _deadline;
}

String diffString(Duration diff) {
  int days = diff.inDays;
  diff -= new Duration(hours: days * Duration.HOURS_PER_DAY);
  int hours = diff.inHours;
  diff -= new Duration(hours: hours);
  int minutes = diff.inMinutes;
  diff -= new Duration( minutes: minutes);
  int seconds = diff.inSeconds;
  return days.toString() + " Days "  + hours.toString() + " Hours " +  minutes.toString() +
      " Minutes "  + seconds.toString() + " Seconds";
}

String styleString(Duration diff) {
  if (diff < new Duration(hours: 7* Duration.HOURS_PER_DAY)) {
    return "alert alert-danger";
  }
  if (diff < new Duration(hours: 30* Duration.HOURS_PER_DAY)) {
    return "alert alert-warning";
  }
  return "alert alert-info";
}
void updateConfs(Timer _)
{
  List<Conference> confs = Conference.confs;
  if (confs.length > 0) {
    querySelector('#timer').style.display = 'block';
    Duration diff = confs[0].deadline.difference(new DateTime.now());
    querySelector('#counter').text = diffString(diff);
    querySelector('#counter').className = styleString(diff);
    querySelector('#conf_name').text = confs[0].name;
  } else {
    return;
  }
  if (confs.length > 1) {
    querySelector('#other').style.display = 'block';
    UListElement confList = querySelector('#deadlines');
    confList.children.clear();
    for (int i = 1; i < confs.length; ++i) {
      var newConf = new LIElement();
      Duration diff = confs[i].deadline.difference(new DateTime.now());
      newConf.text = confs[i].name + " Deadline is " + diffString(diff) + " away.";
      confList.children.add(newConf);
    }
  }
}

void main() {
  Conference.readyTheConferences()
    .then((_) {
      updateConfs(null);
      Timer timer = new Timer.periodic(new Duration(seconds:1), updateConfs);
  });     
}