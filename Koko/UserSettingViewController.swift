import UIKit

extension Array {
    func findIndex(includeElement: (Element) -> Bool) -> [Int] {
        var indexArray:[Int] = []
        for (index, element) in enumerated() {
            if includeElement(element) {
                indexArray.append(index)
            }
        }
        return indexArray
    }
}

class UserSettingViewController: UIViewController , UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource{
    
    //delegateのアダプタ
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    //テーブルビュー
    private var tableView:UITableView!
    
    //ピッカービュー
    private var pickerView:UIPickerView!
    private let pickerViewHeight:CGFloat = 160
    
    //pickerViewの上にのせるtoolbar
    private var pickerToolbar:UIToolbar!
    private let toolbarHeight:CGFloat = 40.0
    
    //セクションのタイトル名の配列
    let sectionTitleArray = [
        "生年",
        "性別",
        "好きなもの"
    ]
    
    //生年月日のリスト
    var BirthYearArray :Array<String> = []

    //性別のリスト
    let userSexArray :Array<String> = ["男性","女性","その他"]
    
    //興味のリスト
    let InterestArray = [
        "無し","ファッション","雑貨","家具","化粧品","ペット",
        "DIY・リノベーション","食事","輸入品","家電製品","パソコン","スポーツ",
        "車・バイク","おもちゃ","ゲーム","楽器","音楽","本・雑誌","お土産・地場物産",
        "骨董品","コレクターグッズ","お酒"]
    
    //stausBarの高さ
    // ステータスバーの高さ
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    
    //ピッカービューに渡すIndexPath
    private var pickerIndexPath:IndexPath!
    
    //現在の値
    private var currentBirthYear:String!
    private var currentSex:String!
    private var currentInterest:String!
    
    
    //ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("userDefaultの確認")
        print(self.delegate.userDefault.string(forKey: "sex")!)
        
        
        //まず誕生年の配列を作成
        for year in 1960...2018{
            BirthYearArray.append(String(year))
        }
        
        //userDefaultの更新
        self.delegate.userDefault.synchronize()
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        //初期値
        currentBirthYear = String(self.delegate.userDefault.integer(forKey: "birthYear"))
        currentSex = self.delegate.userDefault.string(forKey: "sex")
        currentInterest = self.delegate.userDefault.string(forKey: "interest")
        
        //tableView
        tableView = UITableView(frame: CGRect(x:0,y:50,width:width,height:height - 50))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        //pickerView
        pickerView = UIPickerView(frame:CGRect(x:0,y:height + toolbarHeight,
                                               width:width,height:pickerViewHeight))
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.black
        self.view.addSubview(pickerView)
        
        //pickerToolbar
        pickerToolbar = UIToolbar(frame:CGRect(x:0,y:height,width:width,height:toolbarHeight))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.doneTapped))
        pickerToolbar.items = [flexible,doneBtn]
        self.view.addSubview(pickerToolbar)
        
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func doneTapped(){
        UIView.animate(withDuration: 0.2){
            self.pickerToolbar.frame = CGRect(x:0,y:self.view.frame.height,
                                              width:self.view.frame.width,height:self.toolbarHeight)
            self.pickerView.frame = CGRect(x:0,y:self.view.frame.height + self.toolbarHeight,
                                           width:self.view.frame.width,height:self.pickerViewHeight)
            self.tableView.contentOffset.y = 0
        }
        self.tableView.deselectRow(at: pickerIndexPath, animated: true)
    }
    
    /********************** TableView **********************/
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.textLabel?.text = sectionTitleArray[indexPath.row]
        
        print(indexPath.row)
        //初期値
        switch(indexPath.row){
        case 0:
            cell.rightLabel.text = String(self.delegate.userDefault.integer(forKey: "birthYear"))
        case 1:
            cell.rightLabel.text = self.delegate.userDefault.string(forKey: "sex")
        case 2:
            cell.rightLabel.text = self.delegate.userDefault.string(forKey: "interest")
        default:
            cell.rightLabel.text = ""
            
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //ピッカービューとセルがかぶる時はスクロール
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        let cellLimit:CGFloat = cell.frame.origin.y + cell.frame.height
        let pickerViewLimit:CGFloat = pickerView.frame.height + toolbarHeight
        if(cellLimit >= pickerViewLimit){
            print("位置変えたい")
            UIView.animate(withDuration: 0.2) {
                tableView.contentOffset.y = cellLimit - pickerViewLimit
            }
        }
        
        switch(indexPath.row){
        case 0:
            let index = BirthYearArray.findIndex{$0 == cell.rightLabel.text}
            if(index.count != 0){
                pickerView.selectRow(index[0],inComponent:0,animated:false)
            }
        case 1:
            let index = userSexArray.findIndex{$0 == cell.rightLabel.text}
            if(index.count != 0){
                pickerView.selectRow(index[0],inComponent:0,animated:false)
            }
        case 2:
            let index = InterestArray.findIndex{$0 == cell.rightLabel.text}
            if(index.count != 0){
                pickerView.selectRow(index[0],inComponent:0,animated:false)
            }
        default:
            pickerView.selectRow(0, inComponent: 0, animated: false)
            
        }
        
        
        pickerIndexPath = indexPath
        
        //ピッカービューをリロード
        pickerView.reloadAllComponents()
        //ピッカービューを表示
        UIView.animate(withDuration: 0.2) {
            self.pickerToolbar.frame = CGRect(x:0,y:self.view.frame.height - self.pickerViewHeight - self.toolbarHeight,
                                              width:self.view.frame.width,height:self.toolbarHeight)
            self.pickerView.frame = CGRect(x:0,y:self.view.frame.height - self.pickerViewHeight,
                                           width:self.view.frame.width,height:self.pickerViewHeight)
        }
    }
    
    /********************* PickerView ***********************/
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerIndexPath != nil){
            switch (pickerIndexPath.row){
            case 0:
                return BirthYearArray.count
            case 1:
                return userSexArray.count
            case 2:
                return InterestArray.count
            default:
                return 0
            }
        }else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        switch(pickerIndexPath.row){
        case 0:
            label.text = BirthYearArray[row]
        case 1:
            label.text = userSexArray[row]
        case 2:
            label.text = InterestArray[row]

        default:
            print("なし")
            
        }
        return label
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let cell = tableView.cellForRow(at:pickerIndexPath) as! TableViewCell
        switch(pickerIndexPath.row){
        case 0:
            cell.rightLabel.text = BirthYearArray[row]
            currentBirthYear = BirthYearArray[row]
            setUserDefaultDict()
        case 1:
            cell.rightLabel.text = userSexArray[row]
            currentSex = userSexArray[row]
            setUserDefaultDict()
        case 2:
            cell.rightLabel.text = InterestArray[row]
            currentInterest = InterestArray[row]
            setUserDefaultDict()
        default:
            print("何もなし")
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //userDefaultにデータを保存する関数
    private func setUserDefaultDict() {
        let dict:[String : Any] = [
            "firstLaunchFlag" : true,
            "birthYear" : currentBirthYear,
            "sex" : currentSex,
            "interest" : currentInterest
        ]
        //userDefaultにデータを保存
        self.delegate.userDefault.register(defaults: dict)
        self.delegate.userDefault.set(currentBirthYear, forKey: "birthYear")
        self.delegate.userDefault.set(currentSex, forKey: "sex")
        self.delegate.userDefault.set(currentInterest, forKey: "interest")
        self.delegate.userDefault.synchronize()
    }
}
