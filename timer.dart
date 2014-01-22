import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:async' show Timer;

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

  static _parsePirateNamesFromJSON(String jsonString) {
    Map conf = JSON.decode(jsonString);
    confs = conf['names'];
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

void updateConfs(Timer _)
{
  List<Conference> confs = Conference.confs;
  if (confs.length > 0) {
    querySelector('#timer').style.display = 'block';
    Duration diff = confs[0].deadline.difference(new DateTime.now());
    querySelector('#counter').text = diffString(diff);
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
  List<Conference> confs = Conference.confs;
  confs.add(new Conference("ICML", "2014-01-31 23:59:59"));
  confs.add(new Conference("ECCV", "2014-03-07 23:59:59"));
  confs.sort((x, y) => x.deadline.compareTo(y.deadline));
  Timer timer = new Timer.periodic(new Duration(seconds:1), updateConfs);
}