import UIKit

class TableHeaderViewCell:UITableViewCell
{
    var height1:CGFloat = 30.0
    var label:UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(reuseIdentifier cellId:String)
    {
        super.init(style: UITableViewCellStyle.Default, reuseIdentifier:cellId)
    }
    
    class func getHeight() -> CGFloat
    {
        return 30.0
    }
    
    func setDate(value:NSDate)
    {
        self.height  = 30.0
        
        let currentDate = NSDate()
        let timeInterval = currentDate.timeIntervalSinceDate(value)

        let dateFormatter =  NSDateFormatter()
        if timeInterval/60 * 60 < 24 * 60{
            dateFormatter.dateFormat = "HH:mm"
        }else{
            dateFormatter.dateFormat = "yyyy年MM月dd日"
        }
        let text =  dateFormatter.stringFromDate(value)
        
        if (self.label != nil)
        {
            self.label.text = text
            return
        }
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.label = UILabel(frame:CGRectMake(CGFloat(0), CGFloat(0), self.frame.size.width, height))
        
        self.label.text = text
        self.label.font = UIFont.boldSystemFontOfSize(12)
        
        self.label.textAlignment = NSTextAlignment.Center
        self.label.shadowOffset = CGSizeMake(0, 1)
        self.label.shadowColor = UIColor.whiteColor()
        
        self.label.textColor = UIColor.darkGrayColor()
        self.label.backgroundColor = UIColor.clearColor()
        
        self.addSubview(self.label)
    }
}
