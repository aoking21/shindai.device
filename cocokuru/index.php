<?php

/////////////////////////////////
//ログイン情報を入力するページ
////////////////////////////////

session_start();

if (isset($_POST["storeID"])){
  $storeID = $_POST["storeID"];
}
if (isset($_POST["password"])){
  $password = $_POST["password"];
}

//$storeID = $_POST["storeID"];
//$password = $_POST["password"];

if(isset($_POST["storeID"]) && isset($_POST["password"])){
  $keyhash = hash('sha256', $storeID . $password);
}
//$keyhash = hash('sha256', $storeID . $password);

if(isset($_SESSION['Error_str'])){
  switch($_SESSION['Error_str']){
    case "Form not enough":
    $errorDeteal_form = "空欄の項目があります<br>";
    $_SESSION['Error_str'] = NULL;
    break;

    case "member not found":
    $errorDeteal_form = "IDまたはパスワードが間違っています<br>";
    $_SESSION['Error_str'] = NULL;
    break;

    default:
    $errorDeteal_form = "<br>";
  }
}


if(isset($storeID) && isset($password)){
  $_SESSION['storeID'] = $storeID;
  $_SESSION['password'] = $password;
  $_SESSION['keyhash'] = $keyhash;

  //ログインプログラムを走らせる
  header("location: user/login.php");
  exit();
}
?>

<html>
<head>

  <meta lang="ja">
  <meta charset="utf-8">

  <title>ここくる</title>
  </head>

  <link rel="stylesheet" type="text/css" href="cocokuru_stylesheet.css" >

<body>
  <table width="120px" height="50px">
  	<tr><td>
      <img src="./src/CoCoKuRu_logo.png"alt="タイトルページへ">
    </td></tr>
  </table>

  <table align="center" width="95%" height="500px"cellspacing="15">
    <tr align="left" valign="bottom">
      <th height="30px">

      </th>
      <th>

      </th>
    </tr>

	   <tr>
       <td class="div-section-body-style" style="margin-left:25px;margin-right:25px">
         <div align="center" style="float:center;margin-left:25px;margin-right:25px" width="90%">
           <h1 style="width:100%;text-align:left;font-size:50px;margin-left:30px;margin-bottom:5px;margin-top:5px;">
             Welcome to
           </h1>
           <h1 style="width:100%;text-align:right;font-size:50px;margin-right:30px;margin-top:5px;margin-bottom:5px;">
             CoCoKuRu
           </h1>
           <p style="width:100%;margin-top:50px;font-size:25px">お客様とお店を繋ぐ新しい広告のカタチ</p>
           <p>ここくるは店舗の近くを通るお客様のスマートフォンに、リアルタイムで広告を送信するサービスです。</p>
           <p>お客様は今まで興味を持たなかった店舗に、きっと興味を持つでしょう。</p>
           <p>店舗とお客様の交流をより活発にする宣伝ツール。</p>
           <p>ここくるで、新しい広告をしましょう。</p>
         </div>
      </td>

      <td class="div-section-body-style">
        <div align="center" style="float:center;margin-left:25px;margin-right:25px" width="90%">
         <?php if(isset($errorDeteal_form)) echo $errorDeteal_form; ?>
         <form action=" " method="post" class="form-container">
           <div class="form-title"><h2>ログイン</h2></div>
           <div class="form-title">storeID</div>
           <input class="form-field" type = "text" name = "storeID">
           <br>
           <div class="form-title">パスワード</div>
           <input class="form-field" type = "password" name = "password">
           <br>
           <input style="align:right"class="submit-button" type = "submit" name = "login" value="ログイン">
         </form>
        </div>
      </td>

      </tr>

  </table>
</body>



</html>
