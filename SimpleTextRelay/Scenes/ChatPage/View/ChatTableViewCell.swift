//
//  ChatTableViewCell.swift
//  SimpleTextRelay
//
//  Created by Ronald Chester Whigan on 7/10/23.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            self.widthAnchor.constraint(equalTo: self.textLabel!.widthAnchor),
//            self.heightAnchor.constraint(equalTo: self.textLabel!.heightAnchor)
//        ])
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
