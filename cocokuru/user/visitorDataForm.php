<?php
  session_start();

/////////////////////////////////////
//入店者情報を表示するページ
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
  //来客情報詳細のボタンが押された時の処理


?>

<html>
<head>

  <meta lang="ja">
  <meta charset="utf-8">

  <title>来客情報ページ</title>
  </head>

<link rel="stylesheet" type="text/css" href="../cocokuru_stylesheet.css" >

<table width="120px" height="50px" border="1">
	<tr><td>
    <a href="http://aoking21.softether.net/cocokuru">
      <font size="5">ここくる</font></a><br>
  </td></tr>
</table>

<div style="float:right">
  <form action=" " method="POST">
  <input type="submit" value="ログアウト" name="logout">
</form>
</div>

<body>
<table align="center" width="95%" height="500px" >
  <h3><?php echo "[" . $_SESSION['USERDATA']['NAME']. "]"; ?></h3>
  <tr align="left" valign="bottom">
    <th height="30px" class="div-section-header-style">
      <font size="6">
      <form action=" " method="POST">
        来客情報
      <input type="submit" name="adManager" value="更新"></font><br>
      </form>
    </th>
    <th height="30px">

    </th>
  </tr>

  <tr >
    <td class="div-section-body-style">
      来客情報

      </div>
    </td>
    <td class="div-section-body-style">
      <div align="center" style="float:center;margin-left:25px;margin-right:25px" width="90%">
        絞り込み条件を設定するところ。

      </div>
    </td>
  </tr>
</table>
</body>
</html>
