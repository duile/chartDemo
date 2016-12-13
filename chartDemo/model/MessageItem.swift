import UIKit

enum ChatType
{
    case Mine
    case Someone
}

class MessageItem
{
    ///用户信息
    var user:UserInfo
    ///日期
    var date:NSDate
    ///类型
    var mtype:ChatType
    var view:UIView
    ///四周边界
    var insets:UIEdgeInsets
    
    class func getTextInsetsMine() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:10, bottom:11, right:25)
    }
    
    class func getTextInsetsSomeone() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:5, left:15, bottom:11, right:10)
    }
    class func getImageInsetsMine() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:0.5, left:0.5, bottom:0.5, right:7.5)
    }
    class func getImageInsetsSomeone() -> UIEdgeInsets
    {
        return UIEdgeInsets(top:0.5, left:7.5, bottom:0.5, right:0.5)
    }
    
    init(user:UserInfo, date:NSDate, mtype:ChatType, view:UIView, insets:UIEdgeInsets)
    {
        self.view = view
        self.user = user
        self.date = date
        self.mtype = mtype
        self.insets = insets
    }
    
    convenience init(body:NSString, user:UserInfo, date:NSDate, mtype:ChatType)
    {
        let font =  UIFont.boldSystemFontOfSize(16)
        let width =  SCREENW, height = 20000.0
        let atts =  [NSFontAttributeName: font]
        //UsesLineFragmentOrigin
        let size =  body.boundingRectWithSize(CGSizeMake(CGFloat(width), CGFloat(height))  ,     options:NSStringDrawingOptions.UsesFontLeading, attributes:atts ,     context:nil)
        
        let label =  UILabel(frame:CGRectMake(0, 0, size.width, size.height))
       //计算label高度
        if size.width > SCREENW - 90{
            label.width = SCREENW - 90
            label.height = size.width/(SCREENW - 90) * size.height
        }
        //.ByWordWrapping
        label.getEmoji(body as String)
        label.font = font
        label.backgroundColor = UIColor.clearColor()
        
        if mtype == ChatType.Mine{
            label.textColor = UIColor.whiteColor()
        }
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.sizeToFit()
        
        let insets:UIEdgeInsets =  (mtype == ChatType.Mine ? MessageItem.getTextInsetsMine() : MessageItem.getTextInsetsSomeone())

        self.init(user:user, date:date, mtype:mtype, view:label, insets:insets)
    }
    
    //图片类型消息
    convenience init(image:UIImage, user:UserInfo,  date:NSDate, mtype:ChatType)
    {
        var size = image.size
        
        //等比缩放
        if (size.width > 220)
        {
            size.height /= (size.width / 220);
            size.width = 220;
        }
        
        let imageView = UIImageView(frame:CGRectMake(0, 0, size.width, size.height))
        imageView.image = image
        imageView.layer.cornerRadius = 18
        imageView.layer.masksToBounds = true
        
        let insets:UIEdgeInsets =  (mtype == ChatType.Mine ? MessageItem.getImageInsetsMine() : MessageItem.getImageInsetsSomeone())
        
        self.init(user:user,  date:date, mtype:mtype, view:imageView, insets:insets)
    }
}
