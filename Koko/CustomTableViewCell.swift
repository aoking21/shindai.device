//
//  TableViewCell.swift
//  Koko
//
//  Created by 青木佑弥 on 2017/12/30.
//  Copyright © 2017年 青木佑弥. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    public var rightLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        rightLabel = UILabel()
        rightLabel.frame = CGRect(x:self.frame.width / 2,y:0,width:self.frame.width / 2,height:self.frame.height)
        rightLabel.textAlignment = .center
        
        //セルのアクセサリービューにラベルを設定
        self.accessoryView = rightLabel
    }
    
}
