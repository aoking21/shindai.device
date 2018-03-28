//
//  ThirdTutorialViewController.swift
//  Koko
//
//  Created by 青木佑弥 on 2017/12/27.
//  Copyright © 2017年 青木佑弥. All rights reserved.
//

import UIKit

class ThirdTutorialViewController: UIViewController {
    
    //delegateのアダプタ
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //ボタンの定義
    @IBAction func BeginCocokuruButton(_ sender: Any) {
        //初期状態の保存
        setUserData()
        //MainのViewに遷移する
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController()
        present(nextView!, animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserData(){
        //初回起動終了時にdelegateのuserDefaultに、
        //ユーザー情報を記録する
        let dict: [String: Any] = [
            "firstLaunchFlag" : true,     //起動済みか確認するtrueは起動済
            "birthYear" : self.delegate.userDefault.string(forKey: "birthYear") as String!,              //ユーザーの生年
            "sex": self.delegate.userDefault.string(forKey: "sex") as String!,                    //ユーザーの性別
            "interest": self.delegate.userDefault.string(forKey: "interest") as String!                //ユーザーの興味
        ]
        //初期値の登録をする
        self.delegate.userDefault.register(defaults: dict)
        self.delegate.userDefault.set(true, forKey: "firstLaunchFlag")
        self.delegate.userDefault.set(self.delegate.userDefault.string(forKey: "birthyear"), forKey: "birthYear")
        self.delegate.userDefault.set(self.delegate.userDefault.string(forKey: "sex"), forKey: "sex")
        self.delegate.userDefault.set(self.delegate.userDefault.string(forKey: "interest"), forKey: "interest")
        self.delegate.userDefault.synchronize()
        print("ユーザー情報作成完了")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
