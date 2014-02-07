import 'dart:html';
import 'dart:convert' show JSON;
import 'dart:js';
import 'dart:async' show Timer;
import 'dart:async' show Future;

final SERVER_ADDRESS = "http://129.105.6.217:4040";
String userEmail = "";
String userId = "";
bool isLogin = false; 

void deleteConf(Event e) {
  var btn = e.target;
  var id = btn.id;
  var url = SERVER_ADDRESS + '/delConf';   
  var request = new HttpRequest();     
  request.onLoadEnd.listen(onDelConf);   
  request.open('POST', url, async: true);
  request.withCredentials = true;
  request.setRequestHeader("Content-type","application/json");
  String message = '{ "id": "' + id + '"} '; 
  request.send(message);
}

void onDelConf(_) {
  Conference.readyTheConferences();
}

class Conference {
  String _name;
  DateTime _deadline;
  String _id;
  static List<Conference> confs = [];
  Conference(String name, String deadline, String id) {
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
    _id = id;
  }

  static Future readyTheConferences() {
    var path = SERVER_ADDRESS + "/conferences";
    confs.clear();
    return HttpRequest.getString(path, withCredentials: true)
        .then(_parseConferencesFromJSON);
  }
  
  static _parseConferencesFromJSON(String jsonString) {
    List conf_strs = JSON.decode(jsonString);
    for (var conf_str in  conf_strs) {
      confs.add(new Conference(conf_str["name"], conf_str["deadline"], conf_str["_id"]));
    }
    confs.sort((x, y) => x.deadline.compareTo(y.deadline));
  }

  DivElement toHTML() {    
    var confDiv = new DivElement();   
    Duration diff = _deadline.difference(new DateTime.now());     
    confDiv.text = _name + " Deadline is " + diffString(diff) + " away.";
    confDiv.className = styleString(diff);
    ButtonElement button = new ButtonElement();
    button.className = "btn btn-danger";
    button.text = "Remove";
    button.style.float = "right";
    button.id = _id;
    button.onClick.listen(deleteConf);
    confDiv.children.add(button);
    return confDiv;
  }
  
  static String styleString(Duration diff) {
    if (diff < new Duration(hours: 7* Duration.HOURS_PER_DAY)) {
      return "alert alert-danger";
    }
    if (diff < new Duration(hours: 30* Duration.HOURS_PER_DAY)) {
      return "alert alert-warning";
    }
    return "alert alert-info";
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
  DateTime currentTime = new DateTime.now();
  confs.retainWhere((x) => x.deadline.compareTo(currentTime) > 0);
  if (confs.length > 0) {
    querySelector('#timer').style.display = 'block';
    querySelector('#conf_name').text = confs[0].name;
    UListElement confList = querySelector('#deadlinesHead');
    confList.children.clear();
    confList.children.add(confs[0].toHTML());    
    //Duration diff = confs[0].deadline.difference(currentTime);
    //querySelector('#counter').text = diffString(diff);
    //querySelector('#counter').className = Conference.styleString(diff);    
  } else {
    querySelector('#timer').style.display = 'none';    
  }
  if (confs.length > 1) {
    querySelector('#other').style.display = 'block';
    UListElement confList = querySelector('#deadlines');
    confList.children.clear();
    for (int i = 1; i < confs.length; ++i) {
      var newConf = new LIElement();
      newConf.children.add(confs[i].toHTML());
      confList.children.add(newConf);
    }
  } else {
    querySelector('#other').style.display = 'none';
  }
}

void register(Event e) {
  e.preventDefault();           
  var url = SERVER_ADDRESS + '/signup';   
  var request = new HttpRequest();     
  request.onReadyStateChange.listen(onRegisterData);   
  request.open('POST', url, async: true);
  request.withCredentials = true;
  request.setRequestHeader("Content-type","application/json");
  InputElement emailInput = querySelector('#emailRegister');
  InputElement passInput = querySelector('#passwordRegister');
  var email = emailInput.value;
  var password = passInput.value;
  String message = '{ "email": " ' + email + '", "password": "' + password + '" } '; 
  request.send(message);  
}

void onRegisterData (ProgressEvent e) {
  var request = e.target;
  if (request.readyState == HttpRequest.DONE &&
      request.status == 200) {
    var responseJson = JSON.decode(request.responseText);    
    querySelector('#register_test_message').text = request.responseText;
    if (responseJson["success"] == true ) {
      querySelector('#register_test_message').text = "Success";
      querySelector('#register_test_message').className  = "alert alert-success";      
      setUser(responseJson);
      new Timer(new Duration(seconds: 1), () {
        JsObject element = context.callMethod("jQuery", ["#registerModal"]);
        element.callMethod("modal", ["hide"]);
      });      
    } else {    
      querySelector('#register_test_message').text = responseJson["error"];
      querySelector('#register_test_message').className  = "alert alert-danger";
    }
  }
}

void addConf(Event e) {
  e.preventDefault();           
  var url = SERVER_ADDRESS + '/addconf';   
  var request = new HttpRequest();     
  request.onLoadEnd.listen(onAddConf);   
  request.open('POST', url, async: true);
  request.withCredentials = true;
  request.setRequestHeader("Content-type","application/json");
  InputElement confInput = querySelector('#nameConf');
  InputElement deadlineInput = querySelector('#deadlineConf');
  var conf = confInput.value;
  var deadline = deadlineInput.value;  
  String message = '{ "conf": " ' + conf + '", "deadline": "' + deadline + '" } '; 
  request.send(message);  
}
void onAddConf (ProgressEvent e) {
  JsObject element = context.callMethod("jQuery", ["#addConfModal"]);
  element.callMethod("modal", ["hide"]);
  Conference.readyTheConferences();
}

void setUser(responseJson) {
  userEmail = responseJson["user"]["email"];
  userId = responseJson["user"]["id"];
  isLogin = true;
}
Future getUserSession() {
  var url = SERVER_ADDRESS + '/session';
  return HttpRequest.getString(url, withCredentials: true).then((String response) {
    var responseJson = JSON.decode(response);
    if (responseJson["success"] == true ) {
      setUser(responseJson);
      disableLogin();      
    } else {      
      enableLogin();
    }
  });
}

void logout(Event e) {
  e.preventDefault();
  var url = SERVER_ADDRESS + '/logout';
  HttpRequest.getString(url, withCredentials: true).then((_) {Conference.readyTheConferences(); enableLogin(); });
}


void login(Event e) {
  e.preventDefault();
  
  var request = new HttpRequest();  
  request.onReadyStateChange.listen(onLoginData);
  var url = SERVER_ADDRESS + '/login';  
  request.open('POST', url, async: true);
  request.withCredentials = true;
  request.setRequestHeader("Content-type","application/json");
  InputElement emailInput = querySelector('#emailLogin');
  InputElement passInput = querySelector('#passwordLogin');
  var email = emailInput.value;
  var password = passInput.value;  
  request.send('{ "email": " ' + email + '", "password": "' + password + '" } ');
}

void onLoginData(ProgressEvent e) {
  var request = e.target;
  if (request.readyState == HttpRequest.DONE &&
      request.status == 200) {
    var responseJson = JSON.decode(request.responseText);    
    querySelector('#login_message').text = request.responseText;
    if (responseJson["success"] == true ) {
      querySelector('#login_message').text = "Success";
      querySelector('#login_message').className  = "alert alert-success";
      setUser(responseJson);
      Conference.readyTheConferences();
      new Timer(new Duration(seconds: 1), () {
        JsObject element = context.callMethod("jQuery", ["#loginModal"]);
        element.callMethod("modal", ["hide"]);
        disableLogin();
      });      
    } else {    
      querySelector('#login_message').text = responseJson["error"];
      querySelector('#login_message').className  = "alert alert-danger";
    }
  }
}

void disableLogin() {
  querySelector("#registerLi").style.display = "none";
  querySelector("#loginLi").style.display = "none";
  querySelector("#addConfLi").style.display = "block";
  querySelector("#welcomeLi").text = "Welcome ! " + userEmail;
  querySelector("#welcomeLi").style.display = "block";
  querySelector("#logoutLi").style.display = "block";
}

void enableLogin() {
  querySelector("#registerLi").style.display = "block";
  querySelector("#loginLi").style.display = "block";
  querySelector("#addConfLi").style.display = "none";
  querySelector("#welcomeLi").style.display = "none";  
  querySelector("#logoutLi").style.display = "none";  
}

void setDatePick() {
  JsObject element = context.callMethod("jQuery", ["#deadlineConf"]);  
  element.callMethod("datetimepicker", [{"language": "en"}]);
}
void main() {
  setDatePick();
  ButtonElement regButton = querySelector('#register_button');
  regButton.onClick.listen(register);
  ButtonElement loginButton = querySelector('#login_button');
  loginButton.onClick.listen(login);
  ButtonElement addConfButton = querySelector('#add_conf_button');
  addConfButton.onClick.listen(addConf);
  querySelector('#logoutRefReal').onClick.listen(logout);
  getUserSession().then((_) {
    Conference.readyTheConferences()
      .then((_) {
        updateConfs(null);
        Timer timer = new Timer.periodic(new Duration(seconds:1), updateConfs);
      });
    });     
}