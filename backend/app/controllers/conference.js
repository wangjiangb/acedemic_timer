
var mongoose = require('mongoose');
var Conference = require('../models/conference');


defaultConfs = [
    {
        "name":"ECCV 2014",
        "deadline":"2014-03-07 23:59:59"
    },
    {
        "name":"ICML 2014",
        "deadline":"2014-01-31 23:59:59"
    },
    {
        "name":"KDD 2014",
        "deadline":"2014-02-13 23:59:59"
    }
];

exports.getConferences = function(req, res, next) {
    if (req.isAuthenticated()) {
	userId  = req.user.id;
	conferences = [];
	Conference.find({"userId": userId}, function(err, conf) {
	    conferences.push(conf);
	});
	return res.json(conferences);
    } else {
	return res.json(defaultConfs);
    }
}