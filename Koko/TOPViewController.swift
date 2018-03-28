import UIKit
import CoreLocation
import UserNotifications
import QuartzCore

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var beaconUuids: NSMutableArray!
    var beaconDetails: NSMutableArray!
    //サーバーにデータを送信できたらtrue
    var serverSendResultFlag: Bool!
    
    //ユーザーデータ
    let userData = UserDefaults.standard
    
    //ここには検知するUUIDを入力します
    var UUIDList = [
        "ffb78ef9-bd0e-4c1b-ba22-1bcb335dc2c0"
    ]
    
    //view定義
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var adTitleLabel: UILabel!
    @IBOutlet weak var adBodyLabel: UILabel!
    @IBOutlet weak var picPassLabel: UILabel!
    @IBOutlet weak var APISendStatusLabel: UILabel!
    @IBOutlet weak var serverSendSwitch: UISwitch!
    @IBOutlet weak var adPictureView: UIImageView!
    
    
    //delegateのアダプタ
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func goBack(_ segue:UIStoryboardSegue){}
    
    //受け取ったJSONを格納する変数
    var getJSON: String!
    //前回受信したJSONを格納する変数
    var lastGetJSON: String!
    //送信JSON文字列を格納する変数
    var jsonStr: String!
    //パースしたJSONから代入する変数たち
    //通信ステータス
    var statusFromAPI: String!
    //お店の識別ID
    var storeID: String!
    //お店の名前
    var storeName: String!
    //広告タイトル
    var adTitle: String!
    //広告本文
    var adBody: String!
    //添付画像のURL
    var picPass: String!
    //広告の最終更新日
    var updatedAt: String!
    
    //Viewの読み込み完了後に呼び出されるメソッド
    override func viewDidLoad() {
        super.viewDidLoad()
        //色の定義
        let LabelColor = UIColor(red: 80/255, green: 184/255, blue: 255/255, alpha: 1.0)
        //textlabelの表示処理
        storeNameLabel.sizeToFit()
        adTitleLabel.sizeToFit()
        adTitleLabel.layer.borderColor = LabelColor.cgColor
        adBodyLabel.sizeToFit()
        adBodyLabel.numberOfLines = 0
        
        //まず画面の表示内容を初期化
        statusLabelReset()
        
        //通知表示の許可
        pushNotificationArrowDialog()
        
        // ロケーションマネージャの作成.
        myLocationManager = CLLocationManager()
        // デリゲートを自身に設定.
        myLocationManager.delegate = self
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.(1mごとに位置情報取得)
        myLocationManager.distanceFilter = 1
        //バックグラウンド更新を許可？
        myLocationManager.allowsBackgroundLocationUpdates = true
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        print("CLAuthorizedStatus: \(status.rawValue)");
        // まだ認証が得られていない場合は、認証ダイアログを表示
        if(status == .notDetermined) {
            // [認証手順1] まだ承認が得られていない場合は、認証ダイアログを表示.
            // [認証手順2] が呼び出される
            myLocationManager.requestAlwaysAuthorization()
        }
        
        // 配列をリセット
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        
        
        // アプリがバックグラウンド状態の場合は位置情報のバックグラウンド更新をする
        // これをしないとiBeaconの範囲に入ったか入っていないか検知してくれない
        let appStatus = UIApplication.shared.applicationState
        let isBackground = appStatus == .background || appStatus == .inactive
        if isBackground {
            myLocationManager.startUpdatingLocation()
        }
        
    }
    
    //位置情報のステータスが変更された時に呼ばれるメソッド
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus");
        //認証ステータスのチェック
        switch (status) {
        case .notDetermined:
            print("not determined")
            break
        case .restricted:
            print("restricted")
            break
        case .denied:
            print("denied")
            break
        case .authorizedAlways:
            print("authorizedAlways")
            startMyMonitoring()
            break
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            startMyMonitoring()
            break
        }
        
    }
    
    /*
     CoreLocationの利用許可が取れたらiBeaconの検出を開始する.
     */
    private func startMyMonitoring() {
        
        // UUIDListのUUIDを設定して、反応するようにする
        for i in 0 ..< UUIDList.count {
            // BeaconのUUIDを設定.
            let uuid: NSUUID! = NSUUID(uuidString: "\(UUIDList[i].lowercased())")
            // BeaconのIfentifierを設定.
            let identifierStr: String = "identifierNo\(i)"
            
            // リージョンを作成.
            myBeaconRegion = CLBeaconRegion(proximityUUID: uuid as UUID, identifier: identifierStr)
            // ディスプレイがOffでもイベントが通知されるように設定(trueにするとディスプレイがOnの時だけ反応).
            myBeaconRegion.notifyEntryStateOnDisplay = false
            // 入域通知の設定.
            myBeaconRegion.notifyOnEntry = true
            // 退域通知の設定.
            myBeaconRegion.notifyOnExit = false
            
            //通知を送信
            //sendLocalPushNotification()
            
            // [iBeacon 手順1] iBeaconのモニタリング開始([iBeacon 手順2]がDelegateで呼び出される).
            myLocationManager.startMonitoring(for: myBeaconRegion)
            
            
        }
    }
    
    //iBeaconの観測に成功すると呼ばれるメソッド
    /*
     [iBeacon 手順2]  startMyMonitoring()内のでstartMonitoringForRegionが正常に開始されると呼び出される。
     */
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        print("[iBeacon 手順2] didStartMonitoringForRegion");
        
        // [iBeacon 手順3] この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        // [iBeacon 手順4] がDelegateで呼び出される.
        manager.requestState(for: region);
    }
    
    /*
     [iBeacon 手順4] 現在リージョン内にiBeaconが存在するかどうかの通知を受け取る.
     */
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        print("[iBeacon 手順4] locationManager: didDetermineState \(state)")
        
        switch (state) {
            
        case .inside: // リージョン内にiBeaconが存在いる
            print("iBeaconが存在!");
            
            // iBeaconがなくなったら、Rangingを停止する
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            break;
            
        case .outside:
            print("iBeaconが圏外!")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .unknown:
            print("iBeaconが圏外もしくは不明な状態!")
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        }
    }
    
    //iBeaconを検出していなくても1秒ごとに呼ばれる.
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        // 配列をリセット
        beaconUuids = NSMutableArray()
        beaconDetails = NSMutableArray()
        
        // 範囲内で検知されたビーコンはこのbeaconsにCLBeaconオブジェクトとして格納される
        // rangingが開始されると１秒毎に呼ばれるため、beaconがある場合のみ処理をするようにすること.
        if(beacons.count > 0){
            // 発見したBeaconの数だけLoopをまわす
            for i in 0 ..< beacons.count {
                
                let beacon = beacons[i]
                
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                
                //print("UUID: \(beaconUUID.UUIDString) minorID: \(minorID) majorID: \(majorID)");
                
                var proximity = ""
                
                switch (beacon.proximity) {
                    
                case CLProximity.unknown :
                    print("Proximity: Unknown");
                    proximity = "Unknown"
                    //ラベルをリセット
                    statusLabelReset()
                    break
                    
                case CLProximity.far:
                    print("Proximity: Far");
                    proximity = "Far"
                    //サーバーにデータを送信
                    sendVisitData(
                        majorID: CLBeaconMajorValue(truncating: majorID),
                        minorID: CLBeaconMinorValue(truncating: minorID),
                        proximity: proximity)
                    
                    break
                    
                case CLProximity.near:
                    print("Proximity: Near");
                    proximity = "Near"
                    //サーバーにデータを送信
                    sendVisitData(
                        majorID: CLBeaconMajorValue(truncating: majorID),
                        minorID: CLBeaconMinorValue(truncating: minorID),
                        proximity: proximity)
                    
                    break
                    
                case CLProximity.immediate:
                    print("Proximity: Immediate");
                    proximity = "Immediate"
                    //サーバーにデータを送信
                    sendVisitData(
                        majorID: CLBeaconMajorValue(truncating: majorID),
                        minorID: CLBeaconMinorValue(truncating: minorID),
                        proximity: proximity)
                    
                    break
                }
                
                beaconUuids.add(beaconUUID.uuidString)
                
                var myBeaconDetails = "Major: \(majorID) "
                myBeaconDetails += "Minor: \(minorID) "
                myBeaconDetails += "Proximity:\(proximity) "
                myBeaconDetails += "RSSI:\(rssi)"
                print(myBeaconDetails)
                beaconDetails.add(myBeaconDetails)
                
                
            }
        }
    }
    
    
    //iBeaconを検出した際に呼ばれる.
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion: iBeaconが圏内に発見されました。");
        //通知を送信
        sendLocalPushNotification()
        
        
        // Rangingを始める (Ranginghあ1秒ごとに呼ばれるので、検出中のiBeaconがなくなったら止める)
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    iBeaconを喪失した際に呼ばれる. 喪失後 30秒ぐらいあとに呼び出される.
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion: iBeaconが圏外に喪失されました。");
        
        // 検出中のiBeaconが存在しないのなら、iBeaconのモニタリングを終了する.
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
    
    
    //サーバーとの通信を確認する
    func serverConnectionCheck() {
        //http通信のリクエストを作成する
        let urlString = "http://aoking21.softether.net/cocokuru/api/apiSendTest.php"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "POST"
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
            let resultData = String(data: data!, encoding: .utf8)!
            print("\(resultData)")
            //print("response:\(String(describing: response))")
            self.serverSendResultFlag = true
        })
        task.resume()

    }
    
    /*
    //来客情報を送信する関数
     引数: majorID -> iBeaconのMajor, minorID -> iBeaconのMinor,
          proximity -> iBeaconとの距離
    */
    //JSONを作って指定サーバーのプログラムに送信
    func sendVisitData(majorID: CLBeaconMajorValue, minorID:CLBeaconMinorValue, proximity:String){
        print("Begin visitng data send...");
        print("MajorID: \(majorID)  MinorID: \(minorID)");

        //ユーザーデータのオブジェクトを作成
        var userData = Dictionary<String,Any>()
        userData["sex"] = self.delegate.userDefault.string(forKey: "sex")
        userData["birthYear"] = self.delegate.userDefault.string(forKey: "birthYear")
        userData["interest"] = self.delegate.userDefault.string(forKey: "interest")
        //送信するJSON(Dictionaly型)を作成
        var jsonDict = Dictionary<String,Any>()
        jsonDict["regist"] = judgeResist(proximity: proximity)         //登録するならyesしないならno
        jsonDict["majorID"] = majorID
        jsonDict["minorID"] = minorID
        jsonDict["userData"] = userData
        
        //http通信のリクエストを作成する
        let urlString = "http://aoking21.softether.net/cocokuru/api/visitorDataReceiver.php"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
            
            let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
                let resultData = String(data: data!, encoding: .utf8)
                // dataをJSONパースし、グローバル変数"getJson"に格納
                if(resultData?.isEmpty == false){
                    self.lastGetJSON = self.getJSON
                    self.getJSON = resultData
                    print("result:\(self.getJSON)")
                }
            })
            
            task.resume()
            //JSONをパースしてグローバル変数に代入する
            if (self.getJSON != nil) && (self.getJSON != self.lastGetJSON) {
                jsonPerse(jsonStr: self.getJSON)
                //ラベルに表示
                statusLabelSet()
                //画像をダウンロード
                getAdPicture(picPass: self.picPass)
            }else {
                print("失敗")
            }
            
        }catch{
            print("Error\(error)")
            return
        
        }
        
    }
    
    
    //プッシュ通知の確認を取る関数
    func pushNotificationArrowDialog(){
        if #available(iOS 10.0, *) {
            // iOS 10
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert], completionHandler: { (granted, error) in
                if error != nil {
                    return
                }
                
                if granted {
                    print("通知許可")
                    
                    let center = UNUserNotificationCenter.current()
                    center.delegate = self as? UNUserNotificationCenterDelegate
                    
                } else {
                    print("通知拒否")
                }
            })
            
        } else {
            // iOS 9以下
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
    
    /*
    //JSONをパースしてグローバル変数に代入するメソッド
     引数: jsonStr -> JSON形式の文字列
    */
    func jsonPerse(jsonStr: String){
        do {
            let jsonData: Data = jsonStr.data(using: String.Encoding.utf8)!
            // JSONパース
            let json = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary// JSONパース
            self.statusFromAPI = (json["status"] as? String)!
            self.storeName = (json["storeName"] as? String)!
            self.adTitle = (json["adTitle"] as? String)!
            self.adBody = (json["adBody"] as? String)!
            self.picPass = (json["picPass"] as? String)!
            self.updatedAt = (json["updated_at"] as? String)!
            //print(self.adTitle)
        } catch {
            print(error) // パースに失敗したときにエラーを表示
            
        }
    }
    
    /*
    //プッシュ通知を表示する関数
    */
    func sendLocalPushNotification(){
        print("ローカルプッシュ通知を作成した")
        let content = UNMutableNotificationContent()
        content.title = "広告を受信しました"
        content.body = "開いて広告を確認"
        content.sound = UNNotificationSound.default()
        
        //regionをトリガーにしたやつ
        let trigger: UNLocationNotificationTrigger
        trigger = UNLocationNotificationTrigger.init(region: myBeaconRegion, repeats: false)
        
        //通知登録からの時間をtriggerとしたやつ
        //var trigger: UNTimeIntervalNotificationTrigger
        //trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        // 通知の登録
        let request = UNNotificationRequest(identifier: "receive",
                                            content: content,
                                            trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.delegate = self as? UNUserNotificationCenterDelegate
        center.add(request, withCompletionHandler: nil)
    }

    /*
    //ラベルの内容をリセットする関数
    */
    func statusLabelReset(){
        self.storeNameLabel.text = "店舗検索中...."
        self.storeNameLabel.sizeToFit()
        self.adTitleLabel.text = ""
        self.adTitleLabel.sizeToFit()
        self.adBodyLabel.text = ""
        self.adBodyLabel.sizeToFit()
        //self.picPassLabel.text = ""
        //self.APISendStatusLabel.text = ""
    }
    
    /*
    //ラベルの内容をセットする関数
    */
    func statusLabelSet(){
        if self.getJSON != nil{
            jsonPerse(jsonStr: self.getJSON)
        }
        self.storeNameLabel.text = self.storeName + "からのお知らせ"
        self.storeNameLabel.sizeToFit()
        self.adTitleLabel.text = self.adTitle
        self.adTitleLabel.sizeToFit()
        self.adBodyLabel.text = self.adBody
        self.adBodyLabel.sizeToFit()
        //self.picPassLabel.text = self.picPass
        //self.APISendStatusLabel.text = self.statusFromAPI
    }
    
    /*
    //来客情報を登録するか決める関数
     proximity(String): "far" -> 来客情報を登録する
     返却値(String): "yes" -> 来客情報を登録する
                    "no"  -> 来客情報を登録しない
    */
    func judgeResist(proximity: String) -> String{
        if proximity == "Far" {
         return "no"
        }else if self.lastGetJSON == self.getJSON{
            return "no"
        } else if self.lastGetJSON != self.getJSON{
            return "yes"
        }
        return "no"
    }
    
    /*
    //画像を取得する関数
      picPass -> APIから受け取った写真のファイル名
     */
    func getAdPicture(picPass: String){
        let picUrlString: String = "http://aoking21.softether.net/cocokuru/img/"+picPass;
        let picURL = URL(string: picUrlString)
        let imageData = try? Data(contentsOf: picURL!)
        let image = UIImage(data: imageData!)
        self.adPictureView.contentMode = UIViewContentMode.scaleAspectFit
        self.adPictureView.image = image
    }
}

    

