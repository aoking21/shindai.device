<!--DOCTYPE html-->
<html lang="ja">
  <head>
    <meta charset="UTF-8">
    <title>adManager</title>
  </head>
<body>

<?php

session_start();

//////////////////////////////////////////////
//入力された広告情報をデータベースに登録するプログラム
//////////////////////////////////////////////

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

//次にアップされたファイルの拡張子を取得
$ext = substr($_FILES["upfile"]["name"], strrpos($_FILES["upfile"]["name"], '.') + 1);
//ファイル名(_[storeID]_[His].[拡張子])とする
if($ext == "" || $ext == null){
  $filename = "";
}else{
  unlink("../img/".$_SESSION['USERDATA']['PICPASS']);
  $date = date("His");
  $filename = "_".$_SESSION['USERDATA']['ID']."_".$date.".".$ext;

}


//まず最初に画像をサーバーに保存
$picPass = $_SERVER["DOCUMENT_ROOT"]."/cocokuru/img/" .$filename;
if (is_uploaded_file($_FILES["upfile"]["tmp_name"])) {
  //unlink($_SERVER["DOCUMENT_ROOT"]."cocokuru/img/".$_SESSION['USERDATA']['PICPASS']);
	if (move_uploaded_file ($_FILES["upfile"]["tmp_name"], $picPass)) {
	chmod("../img/".$filename, 0777);
	echo $filename . "としてアップロードしました。";
	}else{
	echo "アップロードできませんでした。";
	}
}else{
	echo "ファイルが選択されていません。";
}


//作成者(青木)は頭が悪いので何度もクエリを叩く
//titleをUPDATE
//POSTされたタイトルをデータベースに代入
//UPDATEするレコードはstoreNumberで挿入
//多分storeIDでもいけるけどそんなに大差ないから帰る必要はないかと。
$query = 'UPDATE `storeList` SET `adTitle` = \''.$_POST['adTitle'].'\' WHERE `storeList`.`storeNumber` ='.$_SESSION['USERDATA']['NUMBER'];
if($kokokuruDB -> query($query))
{
  $_SESSION['USERDATA']['adTITLE'] = $_POST['adTitle'];
	echo "タイトルOK";
}

//bodyをUPDATE
//POSTされた広告本文をデータベースに挿入
$query = 'UPDATE `storeList` SET `adBody` = \''.$_POST['adBody'].'\' WHERE `storeList`.`storeNumber` ='.$_SESSION['USERDATA']['NUMBER'];
if($kokokuruDB -> query($query))
{
  $_SESSION['USERDATA']['adBODY']  = $_POST['adBody'];
	echo "本文OK";
}

//picNameをUPDATE
$query = 'UPDATE `storeList` SET `picPass` = \''.$filename.'\' WHERE `storeList`.`storeNumber` ='.$_SESSION['USERDATA']['NUMBER'];
if($kokokuruDB -> query($query))
{
  $_SESSION['USERDATA']['PICPASS'] = $filename;
	echo "パスOK";
}

$query = 'UPDATE `storeList` SET `updated_at` = CURRENT_TIMESTAMP WHERE `storeList`.`storeNumber` ='.$_SESSION['USERDATA']['NUMBER'];
if($kokokuruDB -> query($query))
{
  $subquery = 'SELECT * FROM `storeList` WHERE `storeID` LIKE :storeID';
  $standby = $kokokuruDB -> prepare($subquery);
  $standby -> bindParam(':storeID', $_SESSION['USERDATA']['ID']);
  $standby -> execute();
  //ここでselectして出てきた結果を配列として格納してる
  $result = $standby -> fetch(PDO::FETCH_ASSOC);
  //今回欲しいのはkeyhashの結果なので$result[keyhash]の結果を代入する
  //なかったらboolean型のFALSEが入ってます
  $_SESSION['USERDATA']['LAST_UPDATE'] = $result['updated_at'];
	echo "アップデートOK";
}

$_SESSION['STATUS'] = "登録完了";
header("location: adManageForm.php");
exit();

?>


</body>
</html>
