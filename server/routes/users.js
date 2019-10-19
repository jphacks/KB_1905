'use strict';

var express = require('express');
const aws = require('aws-sdk');
const docClient = new aws.DynamoDB.DocumentClient({region: 'ap-northeast-1'});
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
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
    } else {
      console.log(data.Item);
      res.send(data.Item)
    }
  });
});

router.post('/', function(req, res) {
  if(req.body.name == null){
    res.send('format error');
  }

  let params = {
    TableName: 'users',
    Item:{//プライマリキーを必ず含める（ソートキーがある場合はソートキーも）
      name: req.body.name,
      deviceToken: req.body.deviceToken
    }
  };
  docClient.put(params, function(err,data){
    if(err){
      console.log(err);
    }else{
      console.log(data);
    }
  });
  res.send('ok')
});

module.exports = router;
