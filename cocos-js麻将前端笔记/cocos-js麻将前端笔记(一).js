<1>麻将开发准备，分割模块；
{
	1.手牌组件 {1.玩家自己手牌 2.其他人手牌}
	2.出牌组件
	3.吃、碰、杠牌组件
	4.桌面初始牌组件
	5.音效类
	6.动画控制类
	7.其他独立节点[吃碰杠操作,结算等]；
}

预备文件：
	1.src/common/GlbalFunc.js 
		先新建这个文件是在其中定义一些全局函数，方便以后操作进行，可随时在其中进行改动操作；
	2.src/mj/LoadRes.js.js 
		资源管理文件，存放麻将所有资源的管理
	3.src/mj/MjConst.js 
		定义一些常亮和枚举

GlbalFunc文件实现,暂时先使用位置大小的快捷获取文件和注册触摸函数
代码段：
	var gl = gl || {}

//都当成有contentsize的处理吧
SIZE = function(node){
    if (node == null) return null;
    var size = node.getContentSize();
    // if (size.width == 0 && size.height == 0){
    //     var size_ = node.getLayoutSize();
    //     return size_;
    // } else{
    //     return size;
    // }
    return size;
}
//获取坐标位置函数
X = function(node) {
    if (node == null)
        return null;
    return node.getPositionX();
}

Y = function(node) {
    if (node == null)
        return null;
    return node.getPositionY();
}

W = function(node) {
    if (node == null)
        return null;
    return SIZE(node).width;
}

H = function(node) {
    if (node == null)
        return null;
    return SIZE(node).height;
}

gl.addNodeTouchEventListener = function(node, listener_){
    var listener = cc.EventListenerTouchOneByOne.create();
    listener.setSwallowTouches(true);
    var checkListener = function(touch, event){
        if (listener_ && typeof(listener_) == "function"){
            var location = touch.getLocation();
            event.x = location.x;
            event.y = location.y;
            event.location = location;
            event.node = node;
            var ret = listener_(touch, event);
            return ret;
        }
    }
    listener.onTouchBegan = function (touch, event){   
        event.name = "began";
        var ret = checkListener(touch, event);
        if (ret == null)
            ret = true;
        return ret;
    };
    listener.onTouchMoved = function (touch, event){   
        event.name = "moved";
        checkListener(touch, event);
    };
    listener.onTouchEnded = function (touch, event){   
        event.name = "ended";
        checkListener(touch, event);
    };
    cc.eventManager.addListener(listener, node);
    return listener;
}

MjLoadRes文件实现，先将麻将的合图资源拿进来加载
/*加载麻将合图资源*/
var MjRes = {};
var MjPath = "res/mj/"
MjRes.myPlist = {plist: MjPath + "my.plist", image: MjPath + "my.png"};
MjRes.stPlist = {plist: MjPath + "st.plist", image: MjPath + "st.png"}; // top
MjRes.ytPlist = {plist: MjPath + "yt.plist", image: MjPath + "yt.png"}; // right
MjRes.ztPlist = {plist: MjPath + "zt.plist", image: MjPath + "zt.png"}; // left
MjRes.xtPlist = {plist: MjPath + "xt.plist", image: MjPath + "xt.png"}; // bottom
MjRes.operatorPlist = {plist: MjPath + "operator_ui.plist", image: MjPath + "operator_ui.png"}; // operator_ui

var MjLoadRes = function()
{
	var sPlists = [MjRes.myPlist, MjRes.stPlist, MjRes.ytPlist, MjRes.ztPlist, MjRes.xtPlist, MjRes.operatorPlist];
	for (var i = 0; i < sPlists.length; i++) {
		var Res = sPlists[i];
		cc.spriteFrameCache.addSpriteFrames(Res.plist, Res.image);
	}
	
}


//其他玩家手牌缓存资源名
MjRes.OtherHandRes = [];
MjRes.OtherHandRes[MJ.PlayerType.left] = "zl.png";
MjRes.OtherHandRes[MJ.PlayerType.top] = "sl.png";
MjRes.OtherHandRes[MJ.PlayerType.right] = "zl.png";

MjLoadRes();

============================================================================================
完成步骤之后开始界面的逻辑编写：
  抽取组件中相同的部分，新建文件MjCard.js文件，在这个类中处理类单张麻将的构成和变化处理;
 var MjCard = cc.Node.extend({
	ctor: function()
	{
		this._super();
	}
});
使用Node实现这个单张麻将的实现，考虑可能单张牌也是由多个部分整合而成，而组合成的各个节点间最好是保持独立的。
1.先大致考虑到这个类需要用到的属性和方法
2.牌值、类型(万条筒)、是否被选中、牌节点宽高、在手牌组件中的位置、纹理(界面相关)
var MjCard = cc.Node.extend({
	m_dValue: 0,			//牌值
	m_dType: 0,				//牌类型
	m_bSelect: false, 		//是否选中
	m_dItemWidth: 0, 		//牌宽
	m_dItemHeight: 0, 		//牌高
	m_dSortId: -1, 			//在手牌组件中的序号
	//ui
	m_uiSprite: null, 		//纹理
	ctor: function()
	{
		this._super();
	}
});
3.实现可能需要用到的方法，在此之前还需在MjConst中去定义牌的牌值和类型配置;
var MJ = MJ || {}

MJ.my_seat = 0;  //本家位置 与下PlayerType对应
MJ.GamePlayer = 4;  //游戏人数

MJ.MjType = {
	wan: 0,
	tiao: 1,
	tong: 2,
	feng: 3,
	hua: 4
}

MJ.PlayerType = {
	bottom: 0,
	right: 1,
	top: 2,
	left: 3
}

MJ.OperatorType = {
	chi: 0,
	peng: 1,
	mgang: 3,
	agang: 4,
	xgang: 5,
	hu: 6
}

// 0 牌背 1-9 万; 11-19 条; 21-29 筒; 31-37 风; 35-42 花

//牌类型对应资源键值
MJ.MyHandResEm = "xl%d.png";
MJ.CardTypeEm = ["xt%d.png", "yt%d.png", "st%d.png", "zt%d.png"];
4.实现方法
	1)灰图效果(主要用于查看选中牌在桌面出现有几张)
	2)单张帧图的设置
	3)单张散图的设置
	4)设置牌值、类型、是否选中等等
var MjCard = cc.Node.extend({
	m_dValue: 0,			//牌值
	m_dType: 0,				//牌类型
	m_bSelect: false, 		//是否选中
	m_dItemWidth: 0, 		//牌宽
	m_dItemHeight: 0, 		//牌高
	m_dSortId: -1, 			//在手牌组件中的序号
	//ui
	m_uiSprite: null, 		//纹理
	ctor: function()
	{
		this._super();
		
		this.m_uiSprite = new cc.Sprite();
		this.addChild(this.m_uiSprite);
	},

	//展示灰牌（与手牌选中同值）
	setValueEqualColor: function(ret)	
	{	
		if (ret){
			this.m_uiSprite.setColor(cc.color(108, 108, 108));
		} else {
			this.m_uiSprite.setColor(cc.color(255, 255, 255));
		}
	},

	//单张帧图
	setJSpriteFrame: function(sprite_frame)
	{
		this.m_uiSprite.setSpriteFrame(sprite_frame);
		this.m_dItemWidth = W(this.m_uiSprite);
		this.m_dItemHeight = H(this.m_uiSprite);
	},

	//单张散图
	setJSpriteTexture: function(sprite_texture)
	{
		this.m_uiSprite.setTexture(sprite_texture);
		this.m_dItemWidth = W(this.m_uiSprite);
		this.m_dItemHeight = H(this.m_uiSprite);
	},

	setCardValue: function(value)
	{
		this.m_dValue = value;
		this.m_dType = Math.floor((value-1) / 9);
	}
});
如果统一命名规范可以不写get/set函数去调用属性,这样就暂时写完MjCard的内容，之后的东西再完善，
接下来先把玩家自己的手牌组件完善。