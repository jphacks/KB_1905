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

// 履歴表示用(前後30秒)
// router.get('/moveHistory', function(req, res, next) {
//   let start_time = Number(req.query.timestamp);

//   let params = {
//     TableName : 'sensors'
//   };

//   docClient.scan(params, function(err, data) {
//     if (err){
//       console.log(err);
//       res.send(err);
//     } else {
//       let items = data.Items;
//       // 前後30秒を抽出
//       let filtered = items.filter(item => {
//         if(start_time - 30 < item.timestamp && item.timestamp < start_time + 30){
//           return item
//         }
//       });
//       // timestampで降順ソート
//       filtered.sort(function(a,b){
//         return b.timestamp-a.timestamp;
//       });
//       res.send(filtered);
//     }
//   });
// });

// 履歴表示用（前後30秒以降で揺れが落ち着くまで（/moveHistoryにmoveの判定を追加）)
router.get('/move/history', function(req, res, next) {
  let start_time = Number(req.query.timestamp);

  let params = {
    TableName : 'sensors'
  };

  docClient.scan(params, function(err, data) {
    if (err){
      console.log(err);
      res.send(err);
    } else {
      let items = data.Items;

      // timestampで降順ソート
      items.sort(function(a,b){
        return b.timestamp-a.timestamp;
      });
      // 対象のインデックスを取得
      let targetIndex = items.findIndex(item=>item.timestamp == start_time);

      let response = [];
      // 時間と動いているかの閾値
      let time_th = 30;
      let move_th = 30;
      // push前の履歴
      for(var i=targetIndex;i<items.length;i++){
        if(items[i].move < move_th && Math.abs(items[i].timestamp - items[targetIndex].timestamp) > time_th ){
          break;
        }
        response.push(items[i]);
      }
      // push後の履歴
      if(i>0){
        for(var i=targetIndex-1;i>0;i--){
          if(items[i].move < move_th && Math.abs(items[i].timestamp - items[targetIndex].timestamp) > time_th ){
            break;
          }
          response.unshift(items[i]);
        }
      }
      res.send(response);
    }
  });
});
// 履歴削除
router.post('/move/delete', function(req, res, next) {
  let delete_time = req.body.timestamp;

  var params = {
    TableName: 'move',
    Key:{//削除したい項目をプライマリキー(及びソートキー)によって１つ指定
         timestamp: delete_time
    }
  };
  docClient.delete(params, function(err, data){
    if(err){
      res.send(err);
    }else{
      res.send(data);
    }
  });
});

module.exports = router;
