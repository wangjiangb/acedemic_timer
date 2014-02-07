// config/database.js
module.exports = {
    'url' : 'mongodb://jiang:wangjiang@127.0.0.1:27017/test', // looks like mongodb://<user>:<pass>@mongo.onmodulus.net:27017/Mikha4ot
    'sessConf' : {
	db: {
	    db: "test",
	    host: "127.0.0.1",
	    user: "jiang",
	    port: "27017",
	    password: "wangjiang"
	},
	secret: 'ioudrhgowiehgio'
    }
};
