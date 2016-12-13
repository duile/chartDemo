//
//  CurrentChartHomeViewController.swift
//  daodaokefu
//
//  Created by HelloMac on 16/8/23.
//  Copyright © 2016年 吴亚楠. All rights reserved.
//

import UIKit

class CurrentChartHomeViewController: UIViewController, ChatDataSource,UITextFieldDelegate {
    
    //MARK:属性成员
    lazy var Chats:NSMutableArray = NSMutableArray()
    lazy var tableView:TableView = { [unowned self] in
        
        let tableView = TableView(frame:CGRectMake(0, 64, SCREENW, SCREENH - SENDHEIGHT - 64), style: .Plain)
        let tvGesture = UITapGestureRecognizer.init(target: self, action: #selector(cancleKeyBoard))
        tvGesture.numberOfTapsRequired = 1
        tvGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tvGesture)
        
        //创建一个重用的单元格
        tableView.registerClass(TableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.chatDataSource = self
        tableView.userInteractionEnabled = true
        
        return tableView
    }()

    lazy var sendView:UIView! = { [unowned self] in
        let view = UIView.init(frame: CGRectMake(0,self.view.frame.size.height - SENDHEIGHT,SCREENW,SENDHEIGHT))
       // view.backgroundColor=UIColor.lightGrayColor()
       view.backgroundColor = UIColor(white: 0, alpha: 0.1)
       // view.alpha=0.9
        return view
    }()
    lazy var txtMsg:UITextView! = { [unowned self] in
        let  txtMsg = UITextView(frame:CGRectMake(84, 6,SCREENW - 132,44))
        txtMsg.editable = true
        txtMsg.returnKeyType = UIReturnKeyType.Default
        txtMsg.delegate = self
        txtMsg.backgroundColor = UIColor.whiteColor()
        txtMsg.textColor=UIColor.blackColor()
        txtMsg.font=UIFont.boldSystemFontOfSize(13)
        txtMsg.layer.cornerRadius = 10.0

        return txtMsg
        }()
    lazy var emojiButton:UILabel! = { [unowned self] in
        //弹出表情键盘按钮
        let lable:UILabel = UILabel.init(frame: CGRectMake(4,self.sendView.height - 10 - THREEBUTTONH,THREEBUTTONH,THREEBUTTONH))
        lable.font = UIFont.init(name: "iconfont", size: 24)
        lable.text = "\u{0000e611}"
        lable.textColor = UIColor.grayColor()
        lable.userInteractionEnabled = true
        lable.textAlignment = NSTextAlignment.Center
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CurrentChartHomeViewController.handleEmojiKeyboard))
        lable.addGestureRecognizer(tap)
        return lable
        }()
    lazy var sendButton:UILabel! = { [unowned self] in
        //更多按钮
        let lable:UILabel = UILabel.init(frame:CGRectMake(SCREENW - 42,self.sendView.height - 10 - THREEBUTTONH,THREEBUTTONH,THREEBUTTONH))
        lable.font = UIFont.init(name: "iconfont", size: 26)
        lable.text = "\u{0000e68c}"
        lable.textColor = UIColor.grayColor()
        lable.userInteractionEnabled = true
        lable.textAlignment = NSTextAlignment.Center
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CurrentChartHomeViewController.sendMessage))
        lable.addGestureRecognizer(tap)
        
        return lable
        }()
    lazy var moreButton:UILabel! = { [unowned self] in
        //图片按钮
        let lable:UILabel = UILabel.init(frame: CGRectMake(44,self.sendView.height - 10 - THREEBUTTONH,THREEBUTTONH,THREEBUTTONH))
        lable.font = UIFont.init(name: "iconfont", size: 24)
        lable.text = "\u{0000e6a6}"
        lable.textColor = UIColor.grayColor()
        lable.userInteractionEnabled = true
        lable.textAlignment = NSTextAlignment.Center
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(CurrentChartHomeViewController.selectorPhotoes))
        lable.addGestureRecognizer(tap)
    
        return lable
        }()
    lazy var button:UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem.init(title: "客户资料", style: .Done, target: self, action: #selector(chackCustomInfo))
        button.setTitleTextAttributes([NSFontAttributeName:(UIFont.systemFontOfSize(14))], forState: UIControlState.Normal)
        return button
        }()
    lazy var backButton:UIBarButtonItem = {[unowned self] in
        let backButton = UIBarButtonItem(title: "返回",style: .Plain,target: self,action: nil)
        return backButton
        }()
    
    var youImageUrl:String!
    var youName:String!
    var curNumLine:Int = 2
    
    // var isMoreView:Bool = false
    
    var oldRect: CGRect!
    var isShow:Bool = false
    
    var keyBoardHeight:CGFloat!
    
    var lastSize:CGSize = CGSizeMake(0, 0)
    var isDelete:Bool = false
    var emojiView:EmojiKeyBoardView!
    
    //数据请求的会话id
    var sessionId:Int?
    //请求数据
    var requestManager:NetworkingManager!
    
    //开启一个定时器
    var timer:NSTimer?
    
//    //常用术语DataSource
//    lazy var commonTermsDataSource:NSMutableArray = NSMutableArray()
//    //转接时，在线客服数
//    lazy var onLineDataSource:NSMutableArray = NSMutableArray()
    
    lazy var selectedArray:NSMutableArray = NSMutableArray()

    
    let imagePickerController:UIImagePickerController = UIImagePickerController()
    
    //MARK:系统方法
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.automaticallyAdjustsScrollViewInsets = true
        
        self.view.backgroundColor = UIColor.whiteColor()

        view.addSubview(self.tableView)
        
        createEmojiKeyBoard()
        setupSendPanel()
        createNavRightButton()
    }
    ///刷新数据
    func refreshData() {
        self.getChatMsg()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        changeCurrentSessionRequestData()
        cancleKeyBoard()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CurrentChartHomeViewController.keyBoardhandle(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CurrentChartHomeViewController.keyBoardhandle(_:)), name: UIKeyboardWillHideNotification, object: nil)
        var rect = emojiView.frame
        
        rect.origin.y = SCREENH - rect.height
        oldRect = rect
        rect.origin.y = UIScreen.mainScreen().bounds.height
        emojiView.frame = rect
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true) as NSTimer
        timer?.fire()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.txtMsg.isFirstResponder(){
            self.txtMsg.resignFirstResponder()
        }
        
        guard let timer = self.timer
            else {return}
        timer.invalidate()
    }

    init(){
        requestManager = NetworkingManager()
        super.init(nibName:nil,bundle:nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

//MARK:设置UI
extension CurrentChartHomeViewController{
    
    func createEmojiKeyBoard() {
        emojiView = EmojiKeyBoardView()
        emojiView.emojiDidSelected { [unowned self](emojiKeyBoardView, emoji) -> Void in
            if emoji.deleteBtn {
                self.deleteAction()
            }else{
                self.selectedArray.addObject(emoji.cht!)
                self.inputTextAction()
            }
            self.txtMsg.insertEmoji(emoji, selectedArray: self.selectedArray)
        }
        view.addSubview(emojiView)
    }
    
    //创建三个按钮
    func setupSendPanel()
    {
        sendView.addSubview(emojiButton)
        sendView.addSubview(moreButton)
        sendView.addSubview(sendButton)
        sendView.addSubview(txtMsg)
        self.view.addSubview(sendView)
    }
    
    ///图片选择
    func selectorPhotoes() {
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = true
        
        let actionSheet = UIAlertController(title:nil,message: nil,preferredStyle: .ActionSheet)
        let takePhotoes = UIAlertAction(title:"拍照",style: .Default,handler: { (alert:UIAlertAction!) -> Void in
            //判断是否支持相机
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                self.imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(self.imagePickerController, animated: true, completion: nil)
            }else{
                AlertViewTool.alertView("当前设备，摄像头不可用！", controller: self)
            }
        })
        let photoesAlbum = UIAlertAction(title:"照片图库",style: .Default,handler: {(alert:UIAlertAction!) -> Void in
            self.imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(self.imagePickerController, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title:"取消",style: .Cancel,handler: {(alert:UIAlertAction!) -> Void in
        })
        
        actionSheet.addAction(takePhotoes)
        actionSheet.addAction(photoesAlbum)
        actionSheet.addAction(cancelAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    ///点击表情，弹出自定义表情键盘
    func handleEmojiKeyboard() {
        
        self.view.frame = UIScreen.mainScreen().bounds
        view.endEditing(true)

        emojiKeyBoardAnimate(0)
    }
    
    ///发送消息
    func sendMessage()
    {
        let sender = txtMsg
        ///这个传给后台
        let text = sender.emojiText()
        
        //发送文本消息
        sendTxtMessageRequest(text)
        
        self.txtMsg.resignFirstResponder()
    }
    
    //MARK:监听键盘，弹出，收起
    ///监听键盘收起
    func cancleKeyBoard() {
        
        self.txtMsg.resignFirstResponder()
        self.isShow = true
        emojiKeyBoardAnimate(0)
        // isShow = false
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.tableView.frame = CGRectMake(0, 64, SCREENW, SCREENH - 120)
    }
    
    ///恢复更多页面偏移量
    func changeContentSize() {
       // self.moreView.frame.origin.y += MOREHEIGHT
        self.tableView.frame.size.height += MOREHEIGHT
        self.sendView.frame.origin.y += MOREHEIGHT
       // isMoreView = false
    }
    
    ///设置导航
    func createNavRightButton() {
        self.navigationItem.rightBarButtonItem = button
        self.navigationItem.backBarButtonItem = backButton
    }
    
    ///查看客户资料
    func chackCustomInfo() {
        let customInfoVC = CustomerInforViewController()
        customInfoVC.title = "客户资料"
        self.navigationController?.pushViewController(customInfoVC, animated: true)
    }
    
    //MARK:chatDataSource协议方法
    func rowsForChatTable(tableView:TableView) -> Int
    {
        return self.Chats.count
    }
    
    func chatTableView(tableView:TableView, dataForRow row:Int) -> MessageItem
    {
        return Chats[row] as! MessageItem
    }
    
    ///textView改变高度时，设置三个button的origin
    func changeThreeBtn(height:CGFloat,txtMesgHeight:CGFloat) {
        
        self.sendView.frame = CGRectMake(0, SCREENH - (height) - self.keyBoardHeight, SCREENH, height)
        
        self.tableView.frame.size.height = SCREENH - self.keyBoardHeight - height - 64
        
        self.txtMsg.frame.size.height = txtMesgHeight
        self.emojiButton.frame.origin.y = height - 10 - THREEBUTTONH
        self.moreButton.frame.origin.y = height - 10 - THREEBUTTONH
        self.sendButton.frame.origin.y = height - 10 - THREEBUTTONH
    }
    
    ///删除操作，设置textView高度
    func deleteAction() {
        let frame = self.txtMsg.frame
        let size =  self.txtMsg.attributedText.size()
        let numLine:Int = Int(size.width / frame.width)
        if curNumLine - numLine == 2 && curNumLine > 2{
            let sendFrame = self.sendView.frame
            //改变后的sendview高度
            let height = sendFrame.size.height - 15
            let txtHeight = frame.size.height - 15
            changeThreeBtn(height, txtMesgHeight: txtHeight)
            curNumLine -= 1
            
            self.lastSize = size
        }
        isDelete = true
    }
    
    ///输入操作，判断设置textView高度
    func inputTextAction() {
        let frame = self.txtMsg.frame
        let size =  self.txtMsg.attributedText.size()
        let numLine:Int = Int((size.width + CGFloat(curNumLine * 2)) / frame.width)
        if !isDelete{
            if numLine >= curNumLine{
                var sendFrame = self.sendView.frame
                //改变后的sendview高度
                let height = sendFrame.size.height + 15
                sendFrame.origin.y = sendFrame.origin.y - 15
                
                let txtHeight = frame.size.height + 15
                changeThreeBtn(height, txtMesgHeight: txtHeight)
                curNumLine += 1
            }
        }
    }
    
    /// 键盘显示时回调
    func keyBoardhandle(noti:NSNotification) {
        let usetInfo:NSDictionary = noti.userInfo!
        let dic = usetInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)
        let keyboardRec = dic!.CGRectValue
        let keyBoardHeight:CGFloat = keyboardRec.size.height
        self.keyBoardHeight = keyBoardHeight
        
        self.isShow = true
        emojiKeyBoardAnimate(keyBoardHeight)
    }
    
    /// 表情键盘是否出现时的动画
    func emojiKeyBoardAnimate(keyboard:CGFloat) {
        UIView.animateWithDuration(0.3) { [unowned self]() -> Void in
            var rect = self.emojiView.frame
            if self.isShow {
                rect.origin.y = SCREENH
                
                self.tableView.frame.size.height = SCREENH - keyboard - SENDHEIGHT - 64
                self.sendView.frame.origin.y = SCREENH - keyboard - SENDHEIGHT
    
            } else {
                if keyboard == 0{
                    self.tableView.frame.size.height = SCREENH - self.oldRect.height - SENDHEIGHT - 64
                    self.sendView.frame.origin.y = SCREENH - self.oldRect.height - SENDHEIGHT
                    
                }else{
                    self.tableView.frame.size.height = SCREENH - keyboard - SENDHEIGHT
                    self.sendView.frame.origin.y = SCREENH - keyboard - SENDHEIGHT
                }
                
                self.tableView.slidIndexLast()
                rect = self.oldRect
            }
            self.isShow = !self.isShow
            self.emojiView.frame = rect
        }
    }
}

//MARK:选择图片
extension CurrentChartHomeViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    //实现Imagepicker  delegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let imageData:NSData = UIImageJPEGRepresentation((info["UIImagePickerControllerOriginalImage"] as? UIImage)!, 0.5)!
        let dat = NSDate.init(timeIntervalSinceNow: 0)
        let a = dat.timeIntervalSince1970 * 1000
        let timeString = "\(a)"
        let imagePath = "\(timeString).jpg"
        self.sendImage(imagePath, imageData: imageData)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK:数据请求
extension CurrentChartHomeViewController{
    ///当前会话信息
    func changeCurrentSessionRequestData() {
        let url:String = SDChatChangeUrl
        var dic = [String:AnyObject]()
        dic["sessionId"] = self.sessionId
        let myQueue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(myQueue,{[unowned self] () -> Void in
            
            self.requestManager.customerServiceOfRequestData(url, param: dic,type:SDChatChangeType,success: {[unowned self] (json) -> Void in
                let  store = ModelStore.sharedInstance
                self.Chats.removeAllObjects()
                if json["code"] == 0{
                    if json["data"] != nil{
                        let chtInfoM = store.chatChangeArray[0] as! chatInfoModel
                        
                        for cnt in chtInfoM.chatLog!{
                            self.Chats.addObject(self.changeToMessageItem(cnt))
                        }
                        self.tableView.reloadData()
                    }
                }
                
            }) {
                
            }
            })
    }
    
    ///将数据信息转换为气泡模型model展示
    func changeToMessageItem(chatLog:ChatLog) -> MessageItem {
        
        let mItem:MessageItem?
        let  users:UserInfo!
        
        let timetool = timeTool.sharedInstance
        let logTime:NSDate = timetool.changeTime(chatLog.logTime!)
        
        let chatType:ChatType?
        if chatLog.isReply == true {
            chatType = ChatType.Mine
            users = UserInfo(name:"Xiaoming" ,logo:("xiaoming.png"))
        }else{
            chatType = ChatType.Someone
            if self.youImageUrl != nil{
                users = UserInfo(name:self.youName,logo: self.youImageUrl)
            }else{
                users = UserInfo(name:self.youName,logo: ("headerPlaceHolder.png"))
            }
        }
        
        //判断消息类型
        if chatLog.chatType == 1{
            //图片信息
            //拼接图片URL
            let imageUrl:String = SDImageUrl + chatLog.imageUrl!
            let url = NSURL.init(string: imageUrl)
            let data:NSData = NSData.init(contentsOfURL: url!)!
            let image = UIImage.sd_imageWithData(data)
            mItem = MessageItem(image:image, user:users,  date:logTime, mtype:chatType!)
            
            return mItem!
        }
        
        mItem = MessageItem(body:chatLog.content!, user:users,  date:logTime, mtype:chatType!)
        
        return mItem!
    }
    
    ///发送消息
    func sendTxtMessageRequest(msg:String) {
        let url:String = SDSendChatUrl
        var dic = [String:AnyObject]()
        dic["msg"] = msg
        let myQueue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(myQueue,{ () -> Void in
            
            self.requestManager.customerServiceOfRequestData(url, param: dic,type:SDSendChatType,success: {[unowned self] (json) -> Void in
                                
                if json["code"] == 0{
                    self.txtMsg.text = ""
                    self.getChatMsg()
                }else if json["code"] == 302{
                    AlertViewTool.alertView("微信发送消息失败!", controller: self)
                }
            }) {
                //AlertViewTool.alertView("消息发送失败！", controller: self)
            }
        })
    }
    
    ///将消息模型添加到数据中
    func sendSuccessAddChatsData(thisChat:MessageItem) {
        ///添加聊天数据
        self.Chats.addObject(thisChat)
        self.tableView.chatDataSource = self
        self.tableView.reloadData()
        self.txtMsg.resignFirstResponder()
        self.isShow = false
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        self.changeThreeBtn(SENDHEIGHT, txtMesgHeight: 40)
    }
    
    ///发送图片
    func sendImage(ImagePath:String,imageData:NSData) {
        let url = SDSendPictureUrl
        let dic = [String:AnyObject]()
        
        //上传图片
        requestManager.uploadImage(url, param: dic, type: SDSendPictureType, imagePath: ImagePath, imageData: imageData,success:{[unowned self] (json) -> Void in
            if json["code"] == 0{
                self.getChatMsg()
            }else if json["code"] == 1{
                AlertViewTool.alertView("图片发送失败,请重新发送！", controller: self)
            }else if json["code"] == 302{
                AlertViewTool.alertView("图片向微信发送失败！", controller: self)
            }
            
        }) {
            AlertViewTool.alertView("图片发送失败！", controller: self)
        }
    }
    
    ///发送消息后，立刻请求聊天记录数据，实现收信息的功能。使用定时器设置时间轮回实现数据刷新   前端发送消息后不再界面更新，立刻进行数据请求
    func getChatMsg() {
        let url:String = SDChatMsgUrl
        var dic = [String:AnyObject]()
        dic["delta"] = true
        let myQueue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(myQueue,{ () -> Void in
            self.requestManager.customerServiceOfRequestData(url, param: dic,type:SDChatMsgType,success: { [unowned self](json) -> Void in
                
                if json["code"] == 0{
                    let  store = ModelStore.sharedInstance
                    let chtInfoM = store.chatChangeArray[0] as! chatInfoModel
                    for cnt in chtInfoM.chatLog!{
                        self.Chats.addObject(self.changeToMessageItem(cnt))
                    }
                }else{
                    AlertViewTool.alertView("信息发送失败！", controller: self)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.tableView.reloadData()
                })
                
            }) {
                
            }
        })
    }
    
    
    ///获取会话类型
    func getSessionType() {
        let url:String = SDGetSessionTypeUrl
        let dic = [String:AnyObject]()
        let myQueue:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(myQueue,{ () -> Void in
            
            self.requestManager.customerServiceOfRequestData(url, param: dic,type:SDGetSessionTypeType,success: { (json) -> Void in
                
                if json["code"] == 0{
                }
                
            }) {
                //  AlertViewTool.alertView("网络链接失败，请重试")
            }
        })
    }
    
}

//MARK:textView代理方法
extension CurrentChartHomeViewController:UITextViewDelegate{
    
    func textViewDidBeginEditing(textView: UITextView) {

    }
    
    func textViewDidChange(textView: UITextView) {
        self.inputTextAction()
    }
    
    ///判断是否是删除按钮键入
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == ""{
            deleteAction()
        }else{
            isDelete = false
            //发送消息
        }
        return true
    }
}
