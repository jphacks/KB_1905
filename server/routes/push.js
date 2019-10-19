'use strict';

var express = require('express');
const aws = require('aws-sdk');
const apn = require('apn');
const docClient = new aws.DynamoDB.DocumentClient({region: 'ap-northeast-1'});
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
  res.send('push');
});

// 荷物から離れたときにpush通知
router.post('/leave', function(req, res) {
  console.log(req.body);

  // apns用のオプション
  let options = {
    token: {
      key: "public/key/AuthKey_BYM5DYZ9H3.p8",
      keyId: "BYM5DYZ9H3",
      teamId: "AT8T3Z96ZW"
    },
    production: false
  };
  let apnProvider = new apn.Provider(options);
  let deviceToken = "";
  let note = new apn.Notification();

  // apnsに送信するデータ
  // note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
  note.expiry = 0; // The notification expires immediately
  note.badge = 3;
  note.sound = "ping.aiff";
  note.alert = "荷物から離れました！";
  note.payload = {'messageFrom': 'John Appleseed'};
  note.topic = "jphacks.team-5.5G.kobe";
  
  
  // デバイストークンをデータベースから読み込む
  let params = {
    TableName : 'users',
    Key: {
      'name': 'akanda'
    }
  };
  docClient.get(params, function(err, data) {
    if (err){
      console.log(err);
      res.send(err);
    }
    // デバイストークンが読み取れればpush通知 
    else {
      deviceToken=data.Item.deviceToken;
      console.log(deviceToken);
      apnProvider.send(note, deviceToken).then( (result) => {
        // see documentation for an explanation of result
        console.log(result);
      });
      res.send('ok');
    }
  });
});


// 荷物が動いたときにpush通知
router.post('/move', function(req, res) {
  console.log(req.body);

  // apns用のオプション
  let options = {
    token: {
      key: "public/key/AuthKey_BYM5DYZ9H3.p8",
      keyId: "BYM5DYZ9H3",
      teamId: "AT8T3Z96ZW"
    },
    production: false
  };
  let apnProvider = new apn.Provider(options);
  let deviceToken = "";
  let note = new apn.Notification();

  // apnsに送信するデータ
  // note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
  note.expiry = 0; // The notification expires immediately
  note.badge = 3;
  note.sound = "ping.aiff";
  note.alert = "荷物が動いてます！";
  note.payload = {'messageFrom': 'John Appleseed'};
  note.topic = "jphacks.team-5.5G.kobe";
  
  
  // デバイストークンをデータベースから読み込む
  let params = {
    TableName : 'users',
    Key: {
      'name': 'akanda'
    }
  };
  docClient.get(params, function(err, data) {
    if (err){
      console.log(err);
      res.send(err);
    }
    // デバイストークンが読み取れればpush通知 
    else {
      deviceToken=data.Item.deviceToken;
      console.log(deviceToken);
      apnProvider.send(note, deviceToken).then( (result) => {
        // see documentation for an explanation of result
        console.log(result);
      });
      res.send('ok');
    }
  });
});

module.exports = router;