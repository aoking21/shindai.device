<?php
  //require_once('GoogChart.class.php');
  //外部ライブラリ
  include('GoogleCharts.class.php');
  $GoogleCharts = new GoogleCharts;

  //セッション開始
  session_start();
  //外部ライブラリ
  //include('GoogChart.class.php');
/////////////////////////////////////
//ログイン成功後に表示されるタイトルページ
////////////////////////////////////

  //ログアウトボタンが押された時の処理
  if(isset($_POST["logout"])){
    header("location: logout.php");
    exit();
  }
  //広告編集のボタンが押された時の処理
  if(isset($_POST["adManager"])){
    header("location: adManageForm.php");
    exit();
  }
  //来客情報更新のボタンが押された時の処理
  if(isset($_POST["visitorData"])){
    $data = array(
	Array('時間', '男性', '女性'),
	Array('10時',  serchFromVisitorMen(10, 'aoki02'),serchFromVisitorWomen(10, 'aoki02')),
  Array('11時',  serchFromVisitorMen(11, 'aoki02'),serchFromVisitorWomen(11, 'aoki02')),
	Array('12時',  serchFromVisitorMen(12, 'aoki02'),serchFromVisitorWomen(12, 'aoki02')),
	Array('13時',  serchFromVisitorMen(13, 'aoki02'),serchFromVisitorWomen(13, 'aoki02')),
	Array('14時',  serchFromVisitorMen(14, 'aoki02'),serchFromVisitorWomen(14, 'aoki02')),
	Array('15時',  serchFromVisitorMen(15, 'aoki02'),serchFromVisitorWomen(15, 'aoki02')),
	Array('16時',  serchFromVisitorMen(16, 'aoki02'),serchFromVisitorWomen(16, 'aoki02')),
	Array('17時',  serchFromVisitorMen(17, 'aoki02'),serchFromVisitorWomen(17, 'aoki02')),
	Array('18時',  serchFromVisitorMen(18, 'aoki02'),serchFromVisitorWomen(18, 'aoki02')),
	Array('19時',  serchFromVisitorMen(19, 'aoki02'),serchFromVisitorWomen(19, 'aoki02')),
	Array('20時',  serchFromVisitorMen(20, 'aoki02'),serchFromVisitorWomen(20, 'aoki02')),
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

    //グラフデータを更新してからタイトルページに飛ばす
    $_SESSION['USERDATA']['VISITOR_CHART'] = $chart;
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

<html>
<head>

  <meta lang="ja">
  <meta charset="utf-8">

  <title>マイページ</title>
</head>
<meta name="description" content="Description" />
<link rel="stylesheet" type="text/css" href="../cocokuru_stylesheet.css" >

<table width="120px" height="50px">
	<tr><td>
    <a href="./titlepage.php">
      <img src="../src/CoCoKuRu_logo.png"alt="タイトルページへ">
    </a>
  </td></tr>
</table>

<div style="float:right">
  <form action=" " method="POST">
  <input type="submit" value="ログアウト" name="logout">
</form>
</div>

<div style="width:100%;align:center">
  <div style="width:45%;align-content:center;text-align:center;background:#535353;margin-left:auto;margin-right:auto;">
    <h3 style="color:#FFFFFF"><?php echo $_SESSION['USERDATA']['NAME']. "　マイページ"; ?></h3>
  </div>
</div>

<body>
<table align="center" width="95%" height="500px" cellspacing="15">

  <tr align="left" valign="bottom">
    <th height="30px" class="div-section-header-style">
      <div style="width:100%">
        <div style="margin-left:25px;align-items:left">
          <font size="6">
            <form action=" " method="POST">
              表示中の広告
              <input type="submit" class="submit-button" name="adManager" value="編集"></font><br>
            </form>
        </div>
      </div>
    </th>

    <th height="30px" class="div-section-header-style">
      <div style="width:100%">
        <div style="margin-left:25px;align-items:left">
          <font size="6">
            <form action=" " method="POST">
            来客情報
            <input type="submit"class="submit-button" name="visitorData" value="更新"></font><br>
            </form>
        </div>
      </div>
    </th>
  </tr>

  <tr >
    <td class="div-section-body-style" style="text-align:center">
        <div style="border-top: 3px solid;">
        <font color="#6f6f6f">タイトル</font>
        </div>
        <div class="div-section-adtitle-style">
        <?php echo $_SESSION['USERDATA']['adTITLE']?>
        </div>
        <font color="#6f6f6f">本文</font>
        <div class="div-section-adbody-style">
          <div style="margin-left:20%;margin-right:20%">
            <pre style="font-family:sans-serif"><?php echo $_SESSION['USERDATA']['adBODY']?></pre>
          </div>
        </div>
        <img src=<?php echo "\"../img/".$_SESSION['USERDATA']['PICPASS']."\""?>
        alt="設定中の画像" class="img-content-style"><br>
        最終更新:<?php echo $_SESSION['USERDATA']['LAST_UPDATE']?><br>

    </td>
    <td class="div-section-body-style">
      <div id="chart_div" align="center" style="float:center;margin-left:25px;margin-right:25px" width="90%">
      </div>
    </td>
  </tr>
</table>
<!-- Javascript -->
		<script type="text/javascript" src="https://www.google.com/jsapi"></script>
		<script type="text/javascript">
			<?php echo $_SESSION['USERDATA']['VISITOR_CHART'];?>
		</script>
</body>
</html>
