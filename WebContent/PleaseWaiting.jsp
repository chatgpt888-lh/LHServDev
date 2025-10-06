<!-- ##########################################  rgb(255,120,0) rgb(246,246,246)-->
<style>
.pleaseWaiting{
  border-color: rgb(222,222,222);
  border-style:solid;
  CELLPADDING : 0;
  CELLSPACING : 0;
  HEIGHT : 125px;
  WIDTH : 265px;
  background-color:#ffffff; 
}
</style>
 
<DIV ID="pleasewaitScreen" STYLE="position: absolute; z-index: 0; top: 30%; left: 42%; display: none;">
<div class="row pleaseWaiting" ID="Table1" >
    <div style="text-align: center;">&nbsp;</div>
    <div style="text-align: center; font-family:Tahoma,Arial,sans-serif; color:rgb(112,112,112); font-size:1.2em;">
    Loading... Please wait
    </div>
    <div style="text-align: center; margin-top:30px;" id="img1">&nbsp;
     <img src="<%=request.getContextPath()%>/images/progressBar2.gif" >
    </div>
</div>

</DIV>
<!-- ########################################## -->