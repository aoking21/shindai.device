<?php

////////////////////////////////
//iBeaconを受信したあと、スマートフォンから、
//JSON形式で情報を受け取ったのち、①
//MySQLと照合して、あってる店があったら②
//対象の店の来店情報に登録して、④
//広告情報を返すプログラム③
////////////////////////////////////


//まずJSONを受けとって配列に変換する
$json = file_get_contents('php://input');
$json = mb_convert_encoding($json, 'UTF8', 'ASCII,JIS,UTF-8,EUC-JP,SJIS-WIN');
$visitorData = json_decode($json, true);

//次にデータベースに接続し、受信したmajorとminorと同じ組み合わせを持つ店を検索する。
//データベース接続開始
//ここはそれぞれのデータベース参照してください。
$adress = 'xxxxxxx';
$dbname = 'xxxxxx';
$charset = 'utf8';
$forceUser = 'xxxxxxx';
$password = 'xxxxxxxx';

//pdoオブジェクトに入れるときは
//$pdo = new pdo($pdostring, $forceUser, $password);って感じでお願いします。
$pdostring = 'mysql:host='.$adress.';dbname='.$dbname.';charset='.$charset;

//pdoオブジェクトを作成
try{
  $kokokuruDB = new PDO($pdostring, $forceUser, $password);
  $kokokuruDB -> setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
}catch(PDOException $e){
  exit('データベース接続失敗...'.$e->getMessage());
}

//storeIDの存在を探すために値を取り出してみる
//同じIDを探すクエリ発行
$query = 'SELECT * FROM `storeList` WHERE `major` LIKE :majorID AND `minor` LIKE :minorID';
$standby = $kokokuruDB -> prepare($query);
$standby -> bindParam(':majorID', $visitorData['majorID']);
$standby -> bindParam(':minorID', $visitorData['minorID']);
$standby -> execute();
//ここでselectして出てきた結果を配列として格納してる
//なかったらFALSEが帰ってくる
$result = $standby -> fetch(PDO::FETCH_ASSOC);

//見つかったら、広告内容を変数に代入
if($result){
  //返すJSONを作成する。
  $setJSON = array(
    "status" => "success",
    "storeID" => $result['storeID'],
    "storeName" => $result['storeName'],
    "adTitle" => $result['adTitle'],
    "adBody" => $result['adBody'],
    "picPass" => $result['picPass'],
    "updated_at" => $result['updated_at']
  );
}else{
  //見つからなかったらステータスに失敗を代入
  $setJSON = array(
    "status" => "fail",
    "storeID" => "fail",
    "storeName" => "fail",
    "adTitle" => "fail",
    "adBody" => "fail",
    "picPass" => "fail",
    "updated_at" => "fail"
  );
}


//作成した配列データをJSON文字列にして呼び出し元に返す
$returnJSON = json_encode($setJSON, JSON_UNESCAPED_UNICODE);
echo $returnJSON;


//次に登録指示があったら、来店情報を各店舗の来客データベースに登録する。
//データベースオブジェクトから店舗IDを取得
if ($visitorData['regist'] == "yes"){
  $targetID = $result['storeID'];

  //挿入先のテーブル名
  $targetTable = "visitor_".$targetID;
  //来客情報データベースに来客情報を登録する
  //データベースにinsertするクエリの生成
  $query = 'INSERT INTO `kokokuru`.`'.$targetTable.'` (`visitorBirthYear`, `visitorSex`, `interest1`, `visited_at`
                                                   ) VALUES (
                                                    \''.$visitorData['userData']['birthYear'].'\',
                                                    \''.$visitorData['userData']['sex'].'\',
                                                    \''.$visitorData['userData']['interest'].'\',
                                                    CURRENT_TIMESTAMP
                                                     );';
  //クエリ実行
  $kokokuruDB -> query($query);
}


 ?>
