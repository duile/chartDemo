//
//  UILabelExtension.swift
//  EmojiKeyBoardDemo
//
//  Created by Chakery on 16/3/5.
//  Copyright © 2016年 Chakery. All rights reserved.
//

import UIKit

extension UILabel {
	/// 给label设置带表情的字符串
	///
	/// - parameter string: 带表情的字符串
	func setEmojiTextWithString(string: String) {
		let attritube = NSMutableAttributedString(string: string)
        
		while let property = attritube.string.between("[", "]") {
            
			guard let emojiModel = EmojiPackageManager.verificationEmojiWithString(property.value) else { continue }

			let attachment = NSTextAttachment()
			attachment.image = emojiModel.pngImage
			attachment.bounds = CGRect(x: 0, y: -4, width: font!.lineHeight, height: font!.lineHeight)
			let attributeString = NSAttributedString(attachment: attachment)
			attritube.replaceCharactersInRange(property.range, withAttributedString: attributeString)
		}
		self.attributedText = attritube
	}
    
    ///传入一个数组
    func setEmojiText(string: NSMutableArray) {
        let attritube = NSMutableAttributedString()
        
        for cnt in string {
            let str = "\""+(cnt as! String)+"\""
            
            ///根据字符串查找对应的表情对象
            let emojiModel = EmojiPackageManager.verificationEmojiWithString(str)
            
            if emojiModel == nil{
                
                /*  //设置特定字符串的属性  链接、下划线、删除线等
                 let attributeString = NSMutableAttributedString.init(string: cnt as! String)
                 //  attritube.insertAttributedString(attributeString, atIndex: index)
                 let range = (cnt as! NSString).rangeOfString("love you")
                 attributeString.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(int:1), range: range)
                 
                 attritube.appendAttributedString(attributeString)
                 */
                
                
                let attributeString = NSAttributedString.init(string: cnt as! String)
                //  attritube.insertAttributedString(attributeString, atIndex: index)
                attritube.appendAttributedString(attributeString)
                
            }else{
                let attachment = NSTextAttachment()
                attachment.bounds = CGRect(x: 0, y: -4, width: font!.lineHeight, height: font!.lineHeight)
                attachment.image = emojiModel!.pngImage
                let attributeString = NSAttributedString(attachment: attachment)
               // attritube.insertAttributedString(attributeString, atIndex: index)
                attritube.appendAttributedString(attributeString)
            }
        }
        self.attributedText = attritube
    }
    
    func getEmoji(str:String) {
        
        self.font = UIFont.systemFontOfSize(16)
        let strM = NSMutableAttributedString(string: str)
        
        do{
            //{2,4}  *+  :()+\\-*~<>!$&@',?[^A-Z][^a-z][^0-9]
            //   /\/:[\w:|()+\-*~<>!$&@',?]+/g
            //"/:([^/]{2,8})"
            
            let pattern = "(/:[[\\w]|:|()+\\-*~<>!$&@',?][[a-zA-Z_]|()+\\-*~<>!$&@',?]{1,7})|/:v"
            
            let regex = try NSRegularExpression(pattern: pattern,options: NSRegularExpressionOptions.CaseInsensitive)
            let res = regex.matchesInString(str, options: NSMatchingOptions(rawValue:0), range: NSMakeRange(0, str.characters.count))
            var count = res.count
            //反向取出表情
            while count > 0 {
                count -= 1
                let checkingRes = res[count]
                let tempStr:String = (str as NSString).substringWithRange(checkingRes.range)
                //转换字符串到表情
                if let emojiModel = EmojiPackageManager.verificationEmojiWithString(tempStr){
                    let attachment = NSTextAttachment()
                    attachment.bounds = CGRect(x: 0, y: -5, width: font!.lineHeight, height: font!.lineHeight)
//                    attachment.image = emojiModel.pngImage
                    attachment.image = UIImage.gifWithName(emojiModel.gif!)
                    let attributeString = NSAttributedString(attachment: attachment)
                    strM.replaceCharactersInRange(checkingRes.range, withAttributedString: attributeString)
                }
            }
            self.attributedText = strM
        }catch{
            print(error)
        }
    }
}
