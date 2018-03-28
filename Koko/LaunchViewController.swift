//
//  LaunchViewController.swift
//  Koko
//
//  Created by 青木佑弥 on 2017/12/26.
//  Copyright © 2017年 青木佑弥. All rights reserved.
//  起動画面についての定義
//

import UIKit

class LaunchViewController: UIViewController {
    
    //サーバーと通信できたかを格納する変数
    //trueは成功
    var serverConnectFlag: Bool!
    
    //imageViewの定義
    @IBOutlet weak var imageView: UIImageView!
    let image = UIImage(named: "appstore")
    
    //delegateのアダプタ
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imageViewに写真を登録
        imageView.image = image
        
        if (self.delegate.userDefault.bool(forKey: "firstLaunchFlag")) {
            print("firsrLaunchFlagはtrueなんだ！！")
        }else{
            print("そんなものはない。")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        //初回起動か判断する部分
        //未起動だったらuserDefaultの中身は何も無いから、
        //firstLaunchFlagの存在の有無で判断する
        if (self.delegate.firstLaunchFlag == true){
            //firstLaunchFlagが存在する場合、
            //つまり起動済みだったら、Main.storybordを表示させる
            print("TOPを起動")
            launchTOPView()
            //launchTutorialView()
        }else{
            //チュートリアル画面を表示
            print("チュートリアルを表示")
            launchTutorialView()
            //launchTOPView()
        }
    }
    
    
    //通常のトップ画面を起動するメソッド
    func launchTOPView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        present(nextView!, animated: true, completion: nil)
    }
    
    //チュートリアル画面を起動するメソッド
    private func launchTutorialView(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        present(nextView!, animated: true, completion: nil)
    }
    
    
    //サーバーとの通信を確認する
    private func serverConnectionCheck() -> Bool{
        //http通信のリクエストを作成する
        let urlString = "http://aoking21.softether.net/kokokuru/api/apiSendTest.php"
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = "POST"
        
        let task:URLSessionDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {(data,response,error) -> Void in
            let resultData = String(data: data!, encoding: .utf8)!
            //print("\(resultData)")
            if resultData == "Success"{
                self.serverConnectFlag = true
            }else{
                self.serverConnectFlag = false
            }
        })
        task.resume()
        
        if self.serverConnectFlag {
            return true
        }else{
            return false
        }
    }
    
}
