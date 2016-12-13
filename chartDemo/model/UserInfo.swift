import Foundation

/*
 用户信息类
*/
class UserInfo:NSObject
{
    //用户名和头像
    var username:String?
    var avatar:String?
    
    init(name:String?, logo:String?)
    {
        self.username = name
        self.avatar = logo
    }
}
