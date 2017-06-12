 玩家自己的手牌组件需要实现哪些功能：
  首先定义一些可用到的属性列表：
 var MyCardCompoment = cc.Node.extend({
	m_uiGameRoot: null,  	//挂载节点
	//
	m_arrCardList: [],
	m_dCurrentCardNum: 0,  	//当前手牌张数
	m_dOffsetX: -2,			//x轴间距
	m_dOffsetY: 0,			//牌高
	m_bIsHasNull: false, 	//最后一张是否需要空隙
	m_dNullDis: 30, 		//空隙是多少
	m_bDarkFrame: null,		//手牌暗牌纹理
	m_bNeedUpAction: true, 	//是否需要上牌动画
	m_bUpActionTime: 0.25, 	//上牌动画时间

	//touch
	m_bIsSelected: false, 	//当前有选中
	m_dCurrentIdx: -1,		//当前选中牌的sortid
	m_bIsMoveRange: false,	//有牌在被拖拽着
	m_bIsActive: false, 	//手牌处于活动状态，可打出手牌
	m_dMoveHeight: 15, 		//选中牌向上移动15
	m_dTouchIdx: 0,			//标记牌被点选中了几次
	//observer
	m_dOutCardObserver: null,					//设置出牌的listen
	m_dChangeOutCardsColorObserver: null,		//改变 打出牌与选中牌牌值相同的牌 的颜色
	m_dChangeOperatorCardsColorObserver: null, 	//改变 操作牌与选中牌牌值相同的牌 的颜色
	ctor: function(gameRoot)
	{
		this._super();

		this.m_uiGameRoot = gameRoot;
		this.m_bDarkFrame = cc.formatStr(MJ.OutCardTypeEm[MJ.PlayerType.bottom], 0);
	},
}
1)首先提供以一个函数接口将接受外来的手牌的数据, 内部函数以"_"下划线开头;
 	addInitCards: function(cardArr)
	{
		for (var i = 0; i < cardArr.length; i++) {
			if  (cardArr[i] > 0) {
				this._createMjCard(cardArr[i], this.m_dSordIdx++);
			}
		}
	}
	在这个函数中,没有将数据排序排列，只根据数据创建出麻将牌即可, 后续需要发牌动画，在发完所有手牌之前不整理手牌，
	这里每添加一次手牌数需要调用一次"_resetCardListPosition"来给已经初始化出来的麻将手牌按初始化位排位置。
	//所有的牌复位
	_resetCardListPosition: function()
	{
		for(var i = 0; i < this.m_arrCardList.length; i++){
			this._setCardPointBySortId(i);
			this.m_arrCardList[i].m_dSortId = i;
		}
		this.m_bIsHasNull = false;
	}

	//根据sordid取坐标
	_setCardPointBySortId: function(idx)
	{	
		if (this.m_arrCardList[idx]) 
			this.m_arrCardList[idx].setPosition(cc.p((idx + 0.5) * this.m_dOffsetX, 0));
	}
	在<addInitCards>函数中有<_createMjCard>函数，用于创建单张麻将牌,在其中初始化m_dOffsetX、
	m_dItemWidth、m_dItemHeight、m_dOffsetY等值；上牌动画部分可单独罗列除去。
	_createMjCard: function(cData, idx)
	{
		var card = new MjCard();
		this.addChild(card);
		card.setCardValue(cData);
		
		var cardFrame = cc.formatStr(MJ.MyHandResEm, cData);
		card.setJSpriteFrame(cardFrame);
		card.m_dSordId = idx;
		this.m_dOffsetX = card.m_dItemWidth - 2;
		this.m_dItemWidth = card.m_dItemWidth;
		this.m_dOffsetY = card.m_dItemHeight;
		this.m_dItemHeight = card.m_dItemHeight;
		this.m_dCurrentCardNum++;
		this.m_arrCardList.push(card);

		//需要做动画
		if(this.m_bNeedUpAction) {
			card.setJSpriteFrame(this.m_bDarkFrame);
			card.runAction(cc.sequence(cc.delayTime(this.m_bUpActionTime), cc.callFunc(function(){
				card.setJSpriteFrame(cardFrame);
			}.bind(this))));
		}
	},
	发完所有手牌数据并初始化完成之后, 对手牌数据排序且整理手牌顺序。
	//排序
sortCardList: function()
{
	this.m_arrCardList.sort(function(a, b){ return a.m_dValue > b.m_dValue; });
	for (var i = 0; i < this.m_arrCardList.length; i++) {
		var card = this.m_arrCardList[i];
		card.m_dSordId = i;
		this._setCardPointBySortId(i);
	}
	this.m_bIsHasNull = false;
}
2)在其上有个属性 "m_bIsHasNull", 表示手牌列表最后一张是否有空隙，在打牌过程中，上牌、碰、吃之后，也就是轮到自己
 	出牌时，最后一张牌总是会有一定空隙的，这个属性则表示当前有无空隙。
//最后一张需要空隙
_lastCardNeedNullX: function()
{
	this.m_bIsHasNull = true;
	//因为可能在上牌或者是刚碰完等，最后一张需要特殊设置。
	var length = this.m_arrCardList.length;
	var lfag = length - 1;
	this.m_arrCardList[lfag].setPositionX(this.m_dOffsetX * (lfag+0.5) + this.m_dNullDis); // 30 是间隔可设置
}

//最后一张不需要空隙
_lastCardNotNeedNullX: function()
{
	this.m_bIsHasNull = false;
	var length = this.m_arrCardList.length;
	var lfag = length - 1;
	this.m_arrCardList[lfag].setPositionX(this.m_dOffsetX * (lfag+0.5));
}
	提供两个方法对手牌列表最后一张牌进行控制, 设置一张牌与的间距；
3)对手牌的touch事件的整理，目前需要实现两步，第一：双击出牌，设置一个累计
 	参数，每当选牌切换时重置！第二次点击的是同一张牌并且手牌组件在活动状态active == true(也就是在属于自己的出牌
 	阶段时)打出； 第二：手牌单张点击拖动，实现对手牌拖拽，可拖拽至整个手牌组件的上方，拖回组件区域则放回，在组件
 	外区域释放{1.处于活动状态，打出； 2.非活动状态，重置回来}
 	1.首先提供外部函数<switchTouchPointToIndex>传入event状态，其中对于当前的触摸变量进行判断和控制，began、moved
 	和ended状态。保证当前触摸的区域是否是手牌组件的区域，提供一个函数进行排除操作，判断当前触摸的点是否处于组件的
 	范围之中；
_ignoreNotCardRect: function(pos)
{
		var length = this.m_arrCardList.length;
		var twidth = X(this) + this.m_dOffsetX * length;
		if (this.m_bIsHasNull)
			twidth += this.m_dNullDis;
		//去掉组件上下左右区域
		if (pos.x < X(this) || pos.x > twidth  || pos.y < Y(this)-this.m_dOffsetY / 2 || pos.y > Y(this)+this.m_dOffsetY/3){
			return true;
		}
		//如果是上牌等有空隙的阶段，还要去除中空地带
		var noNullWidth = X(this) + this.m_dOffsetX * (length-1);
		if (this.m_bIsHasNull && (pos.x > noNullWidth && pos.x < noNullWidth + this.m_dNullDis)){
			return true;
		}
		return false;
}
	2.在began中换入触摸点，如果点击在组件区域，那应将当前触摸的点转换为对应手牌的sordId，
_changePointToIdx: function(pos)
{
	var _x = pos.x - X(this);
	var idx = Math.floor(_x / this.m_dOffsetX);
	return idx;
},
	获得了当前触摸的手牌id之后，对其做一些设置操作，向上弹起、触摸次数+1等等；
//更改当前选中的Idx值
_changeCurrentIdx: function(idx)
{
	idx = this._idxChcek(idx);
	if (this.m_dCurrentIdx != idx){
		//换了一张牌
		if (this.m_dCurrentIdx != -1){
			this._setCurrentIdxNotSelected();
		
		this.m_dCurrentIdx = idx;
		this._setCurrentIdxSelected();
	} else {
		//同一张牌
		this._addTouchIdx();
	}
}
	<_idxChcek>函数用于内部检测idx值是否合法，如果不合法将其重置为合法值；
_idxChcek: function(idx)
{
	if (this.m_dCurrentCardNum > 14) {
		this.m_dCurrentCardNum = 14;
	}
	if (idx > this.m_dCurrentCardNum - 1){
		idx = this.m_dCurrentCardNum - 1;
	}
	if (idx > 14) {
		idx = 13;
	}
	return idx;
},	
	当 if (this.m_dCurrentIdx != -1) 时，也就表明当前没有选中任何idx，那么相应的检测当前是否有选中的牌，
	也就是弹起的牌，如果有将其重置回来。
_setCurrentIdxNotSelected: function()
{
	if (this.m_arrCardList[this.m_dCurrentIdx]) {
		this.m_arrCardList[this.m_dCurrentIdx].setPositionY(0);
		this._resetChangeCardsColor(false);
	}
}
	<_setCurrentIdxSelected>与上面函数相反，将选中的idx值对应的手牌弹起，置为选中状态。
_setCurrentIdxSelected: function()
{
	this.m_dCurrentIdx = this._idxChcek(this.m_dCurrentIdx);
	if(this.m_arrCardList[this.m_dCurrentIdx]) {
		this.m_bIsSelected = true;
		this._resetChangeCardsColor(true);
		this.m_arrCardList[this.m_dCurrentIdx].setPositionY(this.m_dMoveHeight);
		this.m_dTouchIdx = 1;
	}
}
	如果再次点击的是同一张牌，拿将执行<_addTouchIdx>函数，点击同一张到两次，如果是活动状态将打出这张牌，
	重置对应属性!
_addTouchIdx: function()
{
	this.m_dTouchIdx++;
	if (this.m_dTouchIdx == 2) {
		this._onOutCurrentCard();
	}
},
	在函数<_setCurrentIdxNotSelected>,<_setCurrentIdxSelected>中都调有<_resetChangeCardsColor>函数，
_resetChangeCardsColor: function(ret)
{
	if (this.m_arrCardList[this.m_dCurrentIdx] && this.m_dChangeOutCardsColorObserver && this.m_dChangeOperatorCardsColorObserver) {
		this.m_dChangeOutCardsColorObserver(this.m_arrCardList[this.m_dCurrentIdx].m_dValue, ret);
		this.m_dChangeOperatorCardsColorObserver(this.m_arrCardList[this.m_dCurrentIdx].m_dValue, ret);
	}
}
	函数内部是两个外部传进来的listener,当选中一张牌时，对应得如果出牌区域和操作牌区域(吃、碰、杠的牌)中有和其
	相同的牌, 改变其颜色以便于看到当前选中牌已出现几张。

	3.继续在<switchTouchPointToIndex>函数中，对moved状态做判断，当moved的时候如果是选中牌了并且moved的区域在
	组件区域之外，那么将当前选中的牌做特殊处理，实现对选中牌进行拖拽。
//飞出去的牌
_moveOffCardRect: function(pos)
{
	if (this.m_arrCardList[this.m_dCurrentIdx]) {
		if (pos.y > Y(this) + this.m_dOffsetY*1.1){
			var card = this.m_arrCardList[this.m_dCurrentIdx];
			card.setPosition(cc.p(pos.x - card.m_dItemWidth * 1.5, pos.y - card.m_dItemHeight / 2 - 20));
			card.setScale(1.1);
			card.setOpacity(180);
			this.setLocalZOrder(19);
		} else {
			//回来重置
			this._moveBackCardRect();
		}
	}
}
当moved的区域返回到手牌组件区域的时候, 那么此时将拖拽除去的手牌重置回来。
//飞出去的牌收回来
_moveBackCardRect: function()
{
	if (this.m_arrCardList[this.m_dCurrentIdx]){
		this._setCardPointBySortId(this.m_dCurrentIdx);
		this.m_arrCardList[this.m_dCurrentIdx].setScale(1);
		this.m_arrCardList[this.m_dCurrentIdx].setOpacity(255);
		this._setCurrentIdxSelected();
		this.setLocalZOrder(0);
		if (this.m_bIsHasNull){
			this._lastCardNeedNullX();
		}
	}
}
	4.对其ended状态的处理，这里只需判断两个状态，第一是否是有手牌move出去的状态，第二是否是活动状态；首先，
	如果m_bIsMoveRange == true时，说明有手牌呗moved出去了，放开执行end的时候要去判断当前是否是活动状态，
	如果m_bIsActive == true, 那么将直接打出这张牌了，如果是false，那就正常的将拖拽除去的手牌收回。
//打出当前选中的牌
_onOutCurrentCard: function()
{
	cc.log("MyCardCompoment .. out current card!", this.m_bIsActive);
	if (this.m_bIsActive){
		if(this.m_dOutCardObserver) {
			this.m_dOutCardObserver(this.m_arrCardList[this.m_dCurrentIdx].m_dValue);
		}
		//先隐藏，如果出牌不成功应该恢复
		//this.m_arrCardList[this.m_dCurrentIdx].setVisible(false);
		this.m_bIsSelected = false;
		this.m_bIsActive = false;
		this.m_bIsHasNull = false;
		this.m_dTouchIdx = 0;

		this._resetChangeCardsColor(false);
	}
}
	<_onOutCurrentCard>函数内将打出选中的麻将牌，并重置相关属性。

	touch处理函数代码：
	switchTouchPointToIndex: function(event){
		var pos = event.location;
		if (event.name == "began"){
			var ret = this._ignoreNotCardRect(pos);
			if (ret == false){
				if (!this.m_bIsSelected) 
					this.m_dCurrentIdx = -1;
				var idx = this._changePointToIdx(pos);
				this._changeCurrentIdx(idx);
			} else {
				if (this.m_bIsSelected){
					//如果本来就是选中状态, 点击到手牌之外的区域，重置回来
					this._resetCurrentIdx();
				}
			}
		} else if (event.name == "moved"){
			//第一下began，必须是选中牌的状态
			//若是一开始是点击其他地方，暂时不予以任何反应
			if (this.m_bIsSelected){
				var ret = this._ignoreNotCardRect(pos);
				if (ret){
					//出了手牌区域
					//将当前选中这个牌做一定处理
					this.m_bIsMoveRange = true;
					this._moveOffCardRect(pos);
				} else {
					//没有出手牌区域,这时变换选中的牌
					if (this.m_bIsMoveRange){
						this._moveBackCardRect();
					}
					this.m_bIsMoveRange = false;
				}
			}		
		} else if (event.name == "ended"){
			if (this.m_bIsMoveRange){
				if (this.m_bIsActive) {
					//这种状态肯定是选中牌,并且将牌移动到手牌区之外(结果：打出)；
					this._onOutCurrentCard();
				} else {
					this._moveBackCardRect();
				}
				
			}
			this.m_bIsMoveRange = false;			
		}
	},

5)摸牌时候的处理：最后一张肯定是要设置空隙的，上牌的时候不能马上进行排序，只是放到最后一张，出牌成功后才做
 相应得手牌列表整理，也可加入插牌动画。
 //上牌
uploadCard: function(cardData)
{
	//如果本身是拖出去的状态, 先重置
	if (this.m_bIsMoveRange) {
		this._moveBackCardRect();
		this.m_bIsMoveRange = false;
	}

	//this.m_bIsActive = true;
	if (cardData){
		//一张 新创建的 默认最后位置 未排序
		this._createMjCard(cardData, this.m_arrCardList.length);
	}
	this._lastCardNeedNullX();
}
6)出牌时，找到对应的那种牌给他移除就好了, 然后播放出牌动画。这里传入了<m_dShowOutCardObserver>
 这个属性，该方法是从外部设置进来的用于创建出牌精灵的方法, 出牌组件还没写，预留个位置。包括
 m_dCheckMineTingObserver检测是否听牌的listener
 //出牌
outPlayCard: function(cardData)
{
	//简单处理 直接排序刷新
	var sort_id = -1;
	if (this.m_dCurrentIdx != -1) {
		sort_id = this.m_arrCardList[this.m_dCurrentIdx].m_dSortId;
	} else {
		sort_id = this._findCardSortIdInCardList(cardData);
	}
	//现在是直接删除
	//这个arr是出牌组件的出牌精灵
	var arr = this.m_dShowOutCardObserver(cardData, MJ.my_seat);
	arr[0].setVisible(false);
	var callback = function(){
		arr[0].setVisible(true);
		this.m_arrCardList[sort_id].removeFromParent();
		this.m_arrCardList.splice(sort_id, 1);
		this.m_dCurrentCardNum--;
		this.m_arrCardList.sort(function(a, b){ return a.m_dValue > b.m_dValue});
		this._resetCardListPosition();
		this.m_dCheckMineTingObserver();
	}
		
	var card = this.m_arrCardList[sort_id];
	var point = cc.p(arr[1].x-this.m_beganPoint.x + this.m_dItemWidth/2, arr[1].y-this.m_beganPoint.y);
	var callfunc = cc.callFunc(callback.bind(this));
	card.runAction(cc.sequence(cc.moveTo(0.2, point), callfunc));
}

_findCardSortIdInCardList: function(cardData)
{
	for (var i = 0; i < this.m_arrCardList.length; i++) {
		var card = this.m_arrCardList[i];
		if (card.m_dValue == cardData) 
			return i;
	}
}

_resetCurrentIdx: function()
{
	this.m_dCurrentIdx = this._idxChcek(this.m_dCurrentIdx);
	if (this.m_dCurrentIdx != -1){
		this._setCurrentIdxNotSelected();
		this.m_dCurrentIdx = -1;
		this.m_dTouchIdx = 0;
	}
}

//清空所有手牌
removeAllCards: function()
{
	this.removeAllChildren();
	this.m_arrCardList = [];
	this.m_dSordIdx = 0;
	this.setPositionX(this.m_dBeganPoint.x);
}

一些set方法
setOutCardObserver: function(observer)
{
	this.m_dOutCardObserver = observer;
}

setChangeOutCardsColorObserver: function(observer)
{
	this.m_dChangeOutCardsColorObserver = observer;
}

setChangeOperatorCardsColorObserver: function(observer)
{
	this.m_dChangeOperatorCardsColorObserver = observer;
}

setCheckMineTingObserver: function(observer)
{
	this.m_dCheckMineTingObserver = observer;
}

setShowOutCardObserver: function(observer)
{
	this.m_dShowOutCardObserver = observer;
}

setBeganPoint: function(point)
{
	this.m_m_dBeganPoint = point;
}