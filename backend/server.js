var express  = require('express');
var app      = express();
var port     = process.env.PORT || 4040;
var mongoose = require('mongoose');
var passport = require('passport');
var flash 	 = require('connect-flash');
var MongoStore = require('connect-mongo')(express);


var configDB = require('./config/database.js');

require('./config/passport')(passport);

var allowCrossDomain = function(req, res, next) {
    res.header('Access-Control-Allow-Credentials', true);
    res.header('Access-Control-Allow-Origin', 'http://127.0.0.1:3030');
    res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE');
    res.header('Access-Control-Allow-Headers', 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Accept');

    next();
}



// configuration ===============================================================
mongoose.connect(configDB.url); // connect to our database

app.configure(function() {
    // set up our express application
    app.use(express.logger('dev')); // log every request to the console
    app.use(express.cookieParser()); // read cookies (needed for auth)
    app.use(express.bodyParser()); // get information from html forms
    app.use(allowCrossDomain);
    app.set('view engine', 'ejs'); // set up ejs for templating
    // required for passport
    app.use(express.session({
	key: 'express.sid',
	secret: configDB.sessConf.secret,
	maxAge: 3600000,
	cookie: {maxAge: 60000 * 60 * 24 * 30, secure: false, httpOnly: false},
	store: new MongoStore(configDB.sessConf.db)
    }));
    app.use(flash()); // use connect-flash for flash messages stored in session
    app.use(passport.initialize());
    app.use(passport.session()); // persistent login sessions
});

// routes ======================================================================
require('./app/routes.js')(app, passport); // load our routes and pass in our app and fully configured passport

// launch ======================================================================
app.listen(port);
console.log('The magic happens on port ' + port);
