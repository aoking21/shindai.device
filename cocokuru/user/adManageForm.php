<?php
////////////////////////////
//広告情報を編集するページ
///////////////////////////
  session_start();

  //ログアウトボタンが押された時の処理
  if(isset($_POST["logout"])){
    header("location: logout.php");
    exit();
  }
?>

<html>
<head>

  <meta lang="ja">
  <meta charset="utf-8">

  <title>編集ページ</title>
  </head>

  <link rel="stylesheet" type="text/css" href="../cocokuru_stylesheet.css">
  </style>

  <table width="120px" height="50px">
  	<tr><td>
      <a href="./titlepage.php">
        <img src="../src/CoCoKuRu_logo.png"alt="マイページへ">
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
      <h3 style="color:#FFFFFF"><?php echo $_SESSION['USERDATA']['NAME']. "　広告編集ページ"; ?></h3>
    </div>
  </div>

  <body >
  <table align="center" width="95%" height="500px"cellspacing="15">

    <tr align="left" valign="bottom" width="50%">
      <th height="30px" class="div-section-header-style">
        <font size="6">
          表示中の広告
        </font>
      </th>
      <th>

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
      <td class="div-section-body-style" style="vertical-align:top">
        <div style="margin-left:25px;margin-right:25px" width="90%">
          <form action="adManager.php" method="post" enctype="multipart/form-data" class="form-input-ad-style">
            <br>
            <label class="label-adtitle-style">タイトル</label>
            <input type="text" name="adTitle" value="" class="input-adtitle-style">
            <br>
            <label class="label-adbody-style">本文</label>
            <textarea type="text" name="adBody" class="textarea-adbody-style"></textarea>
            <br>
          	<input type="file" name="upfile" size="7000000" id="upload" class="input-upfile-style">
            <br>
            <input type='submit' name="send" value="更新" class="input-submit-style">
          </form>

        </div>
      </td>
    </tr>
  </table>
  </body>

</html>
