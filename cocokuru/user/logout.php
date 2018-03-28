<?php
  session_start();

  //ログアウトボタンが押されたら
  //セッション配列の初期化
  $_SESSION = array();
  //セッションIDの削除
  session_destroy();
  //ログイン情報入力ページに飛ぶ
  header("location: ../index.php");
  exit();

?>

<!--DOCTYPE html-->
<html lang="jp">
<head>
  <meta charset="utf-8">
  <title>logout</title>
</head>
<body>

</body>
</html>
