<!--DOCTYPE HTML-->
<html>
<head>
  <meta charset="utf-8">
  <title>login</title>
</head>

<body>

<?php
  session_start();
//インクルード
include('GoogleCharts.class.php');
$GoogleCharts = new GoogleCharts;
////////////////////////////////////////
//ログイン情報をデータベースと確認して
//タイトルページに飛ばすプログラム
//グラフも作るよ
//////////////////////////////////////

////////////////////////////
//ログイン状況を取得
////////////////////////////
  //logintestform.phpからstoreIDとパスワードを取得
  $storeID = $_SESSION['storeID'];
  $password = $_SESSION['password'];
  $keyhash = $_SESSION['keyhash'];

  //IDとパスワードが入力されてなかったら
  if($storeID == "" || $password == ""){
    $_SESSION['Error_str'] = "Form not enough";
    header("location: ../index.php");
    exit();
  }

  //データベース接続開始
  $adress = 'xxxxxxxxx';
  $dbname = 'xxxxxxxxx';
  $charset = 'utf8';
  $forceUser = 'xxxxxxxx';
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
  $query = 'SELECT * FROM `storeList` WHERE `storeID` LIKE :storeID';
  $standby = $kokokuruDB -> prepare($query);
  $standby -> bindParam(':storeID', $storeID);
  $standby -> execute();
  //ここでselectして出てきた結果を配列として格納してる
  $result = $standby -> fetch(PDO::FETCH_ASSOC);
  //今回欲しいのはstoreIDの結果なので$result[storeID]の結果を代入する
  //なかったらboolean型のFALSEが入ってます
  $targetID = $result[storeID];

  //同じように念のためkyehashも取り出す
  //同じkeyhashを探すクエリ発行
  $query = 'SELECT * FROM `storeList` WHERE `keyhash` LIKE :keyhash';
  $standby = $kokokuruDB -> prepare($query);
  $standby -> bindParam(':keyhash', $keyhash);
  $standby -> execute();
  //ここでselectして出てきた結果を配列として格納してる
  $result = $standby -> fetch(PDO::FETCH_ASSOC);
  //今回欲しいのはkeyhashの結果なので$result[keyhash]の結果を代入する
  //なかったらboolean型のFALSEが入ってます
  $targethash = $result[keyhash];

  /////////////////////////////
  //グラフを作成して画像データを作成
  /////////////////////////////

  $data = array(
  Array('時間', '男性', '女性'),
  Array('10時',  serchFromVisitorMen(10, $targetID),serchFromVisitorWomen(10, $targetID)),
  Array('11時',  serchFromVisitorMen(11, $targetID),serchFromVisitorWomen(11, $targetID)),
  Array('12時',  serchFromVisitorMen(12, $targetID),serchFromVisitorWomen(12, $targetID)),
  Array('13時',  serchFromVisitorMen(13, $targetID),serchFromVisitorWomen(13, $targetID)),
  Array('14時',  serchFromVisitorMen(14, $targetID),serchFromVisitorWomen(14, $targetID)),
  Array('15時',  serchFromVisitorMen(15, $targetID),serchFromVisitorWomen(15, $targetID)),
  Array('16時',  serchFromVisitorMen(16, $targetID),serchFromVisitorWomen(16, $targetID)),
  Array('17時',  serchFromVisitorMen(17, $targetID),serchFromVisitorWomen(17, $targetID)),
  Array('18時',  serchFromVisitorMen(18, $targetID),serchFromVisitorWomen(18, $targetID)),
  Array('19時',  serchFromVisitorMen(19, $targetID),serchFromVisitorWomen(19, $targetID)),
  Array('20時',  serchFromVisitorMen(20, $targetID),serchFromVisitorWomen(20, $targetID)),
  );

  /**
  *	OPTIONS
  */
  $options = Array(
  'title' => '本日の来客数',
  'vAxis'	=> Array('title' => "人数"),
  'hAxis'	=> Array('title' => "曜日"),
  'seriesType' =>"bars",
  //↓この数字をいじると、該当番目のグラフが指定形式になる。
  //無くしたら全部普通の棒グラフ
  //'series' => Array( 1 => Array( 'type' => "line")),
  );



  /**
  *	CHART
  */
  $chart = $GoogleCharts->load( 'combo' , 'chart_div' )->get( $data , $options );


  //あったら代入されてるので、応じたURLを返す
  //データベースのstoreIDと受け取ったstoreIDと同じなら、
  //もしくはデータベースのhashと受け取ったhashが衝突したら作成させない
  if($targetID != $storeID || $targethash == NULL){
    //storeIDとハッシュが見つからなかったのでログイン失敗ページに飛ばす
    $_SESSION['Error_str'] = "member not found";
    header("location: ../index.php");
    exit();
  }else{
    //同じやつが見つかったのでユーザーデータを配列化して保存してからタイトルページに飛ばす
    $_SESSION['USERDATA'] = array(
      "NUMBER" => $result[storeNumber],
      "ID" => $result[storeID],
      "NAME" => $result[storeName],
      "adTITLE" => $result[adTitle],
      "adBODY" => $result[adBody],
      "PICPASS" => $result[picPass],
      "LAST_UPDATE" => $result[updated_at],
      "VISITOR_CHART" => $chart
    );
    header("location: titlepage.php");
    exit();
  }

  //////////////////////
  //関数定義
  //////////////////////

  //検索条件から、その条件の人数を返却する関数
  //$serchTerms:検索時間(24時間表記0〜24の整数)
  //$visitorSex:検索対象性別("men","women","both")
  function serchFromVisitorMen($serchTime, $targetID){
    //データベース接続開始
    $adress = 'xxxxxxxxx';
    $dbname = 'xxxxxxxxx';
    $charset = 'utf8';
    $forceUser = 'xxxxxxxx';
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
    $tableName = "visitor_" . $targetID;
    $beforeTime = date("Y-m-d ").$serchTime.":00:00";
    $afterTime = date("Y-m-d ").$serchTime .":59:59";
    $query = "SELECT * FROM `kokokuru`.`".$tableName."` WHERE `visited_at` BETWEEN '".$beforeTime."' AND '".$afterTime."'". "AND `visitorSex` = \"男性\"";
    //データ数を格納する変数
      $resultSumDataNum = 0;
    //来客者数をカウント
    foreach ($kokokuruDB->query($query) as $row) {
      $resultSumDataNum++ ;
    };
    return $resultSumDataNum;

  }

  function serchFromVisitorWomen($serchTime, $targetID){
    //データベース接続開始
    $adress = 'xxxxxxxxx';
    $dbname = 'xxxxxxxxx';
    $charset = 'utf8';
    $forceUser = 'xxxxxxxx';
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
    $tableName = "visitor_" . $targetID;
    $beforeTime = date("Y-m-d ").$serchTime.":00:00";
    $afterTime = date("Y-m-d ").$serchTime .":59:59";
    $query = "SELECT * FROM `kokokuru`.`".$tableName."` WHERE `visited_at` BETWEEN '".$beforeTime."' AND '".$afterTime."'". "AND `visitorSex` = \"女性\"";
    //データ数を格納する変数
      $resultSumDataNum = 0;
    //来客者数をカウント
    foreach ($kokokuruDB->query($query) as $row) {
      $resultSumDataNum++ ;
    };
    return $resultSumDataNum;

  }

?>

</body>
</html>
