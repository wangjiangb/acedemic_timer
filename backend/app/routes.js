var confControl = require('./controllers/conference');
module.exports = function(app, passport) {


    // =====================================
    // LOGOUT ==============================
    // =====================================
    app.get('/logout', function(req, res) {
	req.logout();
	return res.json({success: true});
    });

    app.get('/conferences', confControl.getConferences);

    app.get('/session', function(req, res) {
	if (req.isAuthenticated()) {
	    console.log(req.user);
	    return res.json(
		{ user: {
		    email: req.user.local.email,
		    id: req.user.id
		    },
		  success: true
		}
	    );
	} else
	    return res.json({success: false});
    });


    // process the signup form
    app.post('/signup',  function(req, res) {
	console.log(req.body);
	passport.authenticate('local-signup', function(err, user) {
	    if (err)   { return res.json({ success:false, error: err.message }); }
	    if (!user) { return res.json({success:false, error: req.flash("signupMessage")}); }
	    req.session.save();
	    return res.json(
		{ user: {
		    email: user.local.email,
		    id: user.id
		},
		  success: true
		});
	})(req, res);
    });

    app.post('/login', function(req, res) {
	console.log(req.xhr)
	console.log(req.body)
	passport.authenticate('local-login', function(err, user) {
	    if (err)   { return res.json({ success:false, error: err.message }); }
	    if (!user) { return res.json({success:false, error : req.flash("loginMessage")}); }
	    req.login(user, {}, function(err) {
		if (err) { return res.json({ success:false, error: err});}
		req.session.save();
		return res.json(
		{ user: {
		    email: user.local.email,
		    id: user.id
		},
		success: true
		});
	    })
	})(req, res);
    });
}


// route middleware to make sure a user is logged in
function isLoggedIn(req, res, next) {

    // if user is authenticated in the session, carry on
    if (req.isAuthenticated())
	return next();

    // if they aren't redirect them to the home page
    res.redirect('/');

    //process the login form
    //app.post('/login', do all our passport stuff here);
}
