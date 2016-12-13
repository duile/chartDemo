import UIKit

class TableViewCell:UITableViewCell
{
    var customView:UIView!
    var bubbleImage:UIImageView!
    var avatarImage:UIImageView!
    var msgItem:MessageItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //- (void) setupInternalData
    init(data:MessageItem, reuseIdentifier cellId:String)
    {
        self.msgItem = data
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier:cellId)
        rebuildUserInterface()
    }
    
    func rebuildUserInterface()
    {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        if (self.bubbleImage == nil)
        {
            self.bubbleImage = UIImageView()
            self.addSubview(self.bubbleImage)
        }
        
        ///信息类型
        let type =  self.msgItem.mtype
        
        ///消息内容  宽 和 高
        let width =  self.msgItem.view.frame.size.width
        let height =  self.msgItem.view.frame.size.height
        
        /// x:坐标
        var x =  (type == ChatType.Someone) ? 0 : self.frame.size.width - width - self.msgItem.insets.left - self.msgItem.insets.right
        
        var y:CGFloat =  0
        
        if (self.msgItem.user.username != "")
        {
            ///用户信息
            let thisUser =  self.msgItem.user
            self.avatarImage = UIImageView(image:UIImage(named:(thisUser.avatar != "" ? thisUser.avatar! : "noAvatar.png")))
            
            if thisUser.avatar!.hasPrefix("http://"){
                self.avatarImage.sd_setImageWithURL(NSURL.init(string: thisUser.avatar!))
            }
            
            self.avatarImage.layer.cornerRadius = 9.0
            self.avatarImage.layer.masksToBounds = true
            self.avatarImage.layer.borderColor = UIColor(white:0.0 ,alpha:0.2).CGColor
            self.avatarImage.layer.borderWidth = 1.0
            //calculate the x position
            
            //头像 的 x ：坐标
            let avatarX =  (type == ChatType.Someone) ? 2 : self.frame.size.width - 52
            
           //头像 y值
            var avatarY =  height
            
            if "\(self.msgItem.view.classForCoder)" == "UIImageView"{
                avatarY = height - 16
            }
            //set the frame correctly
            self.avatarImage.frame = CGRectMake(avatarX, avatarY, 50, 50)
            self.addSubview(self.avatarImage)
            
            let delta =  self.frame.size.height - (self.msgItem.insets.top + self.msgItem.insets.bottom + self.msgItem.view.frame.size.height)
           
            if (delta > 0)
            {
                y = delta
            }
            
            if (type == ChatType.Someone)
            {
                x += 60
                
                if "\(self.msgItem.view.classForCoder)" == "UIImageView"{
                    x += 9
                }
            }
            if (type == ChatType.Mine)
            {
                
                // x -= 54
                x -= 50
                if "\(self.msgItem.view.classForCoder)" == "UIImageView"{
                    x -= 10
                }
            }
        }
    
        ///显示信息的view
        self.customView = self.msgItem.view
        
        self.customView.frame = CGRectMake(x + self.msgItem.insets.left, y + self.msgItem.insets.top, width, height)
        self.addSubview(self.customView)

        //depending on the ChatType a bubble image on the left or right
        if (type == ChatType.Someone)
        {
            self.bubbleImage.image = UIImage(named:("bubble-gray-1.png"))!.stretchableImageWithLeftCapWidth(21,topCapHeight:14)
        }
        else {
            self.bubbleImage.image = UIImage(named:"bubble-blue-1.png")!.stretchableImageWithLeftCapWidth(15, topCapHeight:14)
        }
        //+ self.msgItem.insets.right   + self.msgItem.insets.left
        if type == ChatType.Mine{
            self.bubbleImage.frame = CGRectMake(x, y, width + self.msgItem.insets.right, height + self.msgItem.insets.top + self.msgItem.insets.bottom)
            
        }else{
            
            self.bubbleImage.frame = CGRectMake(x, y, width + self.msgItem.insets.left + self.msgItem.insets.right, height + self.msgItem.insets.top + self.msgItem.insets.bottom)
        }
    }
    
    //让单元格宽度始终为屏幕宽
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.size.width = UIScreen.mainScreen().bounds.width
            super.frame = frame
        }
    }
}
