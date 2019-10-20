'use strict';

var express = require('express');
const aws = require('aws-sdk');
const docClient = new aws.DynamoDB.DocumentClient({region: 'ap-northeast-1'});
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {

  let params = {
    TableName : 'sensors',
    // Key: {
    //   'name': 'Tomoki'
    // }
  };

  // 加速度とRSSIを両方取得して返す
  docClient.scan(params, function(err, data) {
    if (err){
      console.log(err);
      res.send(err);
    } else {
      // console.log(data);
      let items = data.Items;
      items.sort(function(a,b){
        return b.timestamp-a.timestamp;
      });
      // res.send(items[0]);
      let move = items[0];

      // rssiを取得
      params = {
        TableName : 'rssi',
      };
      docClient.scan(params, function(err, data) {
        if (err){
          console.log(err);
          res.send(err);
        } else {
          // console.log(data);
          let items = data.Items;
          items.sort(function(a,b){
            return b.timestamp-a.timestamp;
          });
          // res.send(items[0]);
          let rssi = items[0]

          // クライアントが希望する形に変更
          let response_json = {}
          response_json['rssi_timestamp'] = rssi.timestamp
          response_json['dist'] = rssi.dist
          response_json['move'] = move.move
          response_json['move_timestamp'] = move.timestamp

          // console.log(acc)
          // console.log(rssi)
          console.log(response_json)

          res.send(response_json)
        }
      });
    }
  });
});

router.post('/', function(req, res) {
  console.log(req.body);
  // if(req.body.name == null){
  //   res.send('format error');
  // }
  
  let params = {
    TableName: 'sensors',
    Item://プライマリキーを必ず含める（ソートキーがある場合はソートキーも）
      req.body
  };
  docClient.put(params, function(err,data){
    if(err){
      console.log(err);
    }else{
      console.log(data);
    }
  });
  res.send('ok');
});

router.get('/rssi', function(req, res, next) {

  let params = {
    TableName : 'rssi',
    // Key: {
    //   'name': 'Tomoki'
    // }
  };

  docClient.scan(params, function(err, data) {
    if (err){
      console.log(err);
      res.send(err);
    } else {
      console.log(data);
      let items = data.Items;
      items.sort(function(a,b){
        return b.timestamp-a.timestamp;
      });
      res.send(items[0]);
    }
  });
});

router.post('/rssi', function(req, res) {
  console.log(req.body);
  // if(req.body.name == null){
  //   res.send('format error');
  // }
  
  let params = {
    TableName: 'rssi',
    Item://プライマリキーを必ず含める（ソートキーがある場合はソートキーも）
      req.body
  };
  docClient.put(params, function(err,data){
    if(err){
      console.log(err);
    }else{
      console.log(data);
    }
  });
  res.send('ok');
});

module.exports = router;
