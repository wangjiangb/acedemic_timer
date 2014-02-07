// load the things we need
var mongoose = require('mongoose');

var conferenceSchema = mongoose.Schema({
    userId: String,
    conferenceName: String,
    deadline: String
});


module.exports = mongoose.model('Conference', conferenceSchema);