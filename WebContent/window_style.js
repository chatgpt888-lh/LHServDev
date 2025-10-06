function openIT(u,W,H,X,Y,n,b,x,m,r) {
	var cU  ='img/close_up.gif'
	var cO  ='img/close_ovr.gif'
	var cL  ='img/clock.gif'
	var mU  ='img/min_up.gif'
	var mO  ='img/min_ovr.gif'
	var xU  ='img/max_up.gif'
	var xO  ='img/max_ovr.gif'
	var rU  ='img/res_up.gif'
	var rO  ='img/res_ovr.gif'
	var tH  ='<font face=verdana color=#0066FF size=1>&nbsp;&nbsp;รายละเอียดผู้วางเงินค้ำประกันฯ</font>'
	var tW  =''
	var wB  ='#FFFFFF'
	var wBs ='#FFFFFF'
	var wBG ='rgb(180,210,255)'
	var wBGs='rgb(160,200,255)'
	var wNS ='toolbar=0,location=0,directories=0,status=0,menubar=0,scrollbars=0,resizable=0'
	var fSO ='scrolling=no noresize'
	var brd =b||0;
	var max =x||false;
	var min =m||false;
	var res =r||false;
	var tsz =20;
	var CWIN = chromeless(u,n,W,H,X,Y,cU,cO,cL,mU,mO,xU,xO,rU,rO,tH,tW,wB,wBs,wBG,wBGs,wNS,fSO,brd,max,min,res,tsz);

	return CWIN;
}
