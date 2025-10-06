function addCommas(nStr){
	nStr = delCommas(nStr);
	nStr += '';
	x = nStr.split('.');
	x1 = x[0];
	x2 = x.length > 1 ? '.' + x[1] : '';
	var rgx = /(\d+)(\d{3})/;
	while (rgx.test(x1)) {
		x1 = x1.replace(rgx, '$1' + ',' + '$2');
	}
	return x1 + x2;
}
function delCommas(nStr){
	nStr += '';
	x = nStr.split(',');
	rStr = '';
	for(i = 0 ; i < x.length ; i++){
		rStr += x[i];
	}
	return rStr;
}
function Trim( str ) {
	var resultStr = "";
	resultStr = TrimLeft(str);
	resultStr = TrimRight(resultStr);
	return resultStr;
}
function TrimLeft( str ) {
	var resultStr = "";
	var i = len = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";

	if (str.length == 0) 
		resultStr = "";
	else {	
  		// Loop through string starting at the beginning as long as there
  		// are spaces.
		//	  	len = str.length - 1;
		len = str.length;
					
  		while ((i <= len) && (str.charAt(i) == " "))
			i++;
	
   	// When the loop is done, we're sitting at the first non-space char,
 		// so return that char plus the remaining chars of the string.
  		resultStr = str.substring(i, len);
  	}
			
  	return resultStr;
} // end TrimLeft
			
function TrimRight( str ) {
	var resultStr = "";
	var i = 0;
	
	// Return immediately if an invalid value was passed in
	if (str+"" == "undefined" || str == null)	
		return null;

	// Make sure the argument is a string
	str += "";
		
	if (str.length == 0) 
		resultStr = "";
	else {
  		i = str.length - 1;
  		while ((i >= 0) && (str.charAt(i) == " "))
 			i--;
	  		resultStr = str.substring(0, i + 1);
	  	}
	  	return resultStr;  	
}

function checkNum(evt) {  //onkeypress="checkNum(event)"
  var theEvent = evt || window.event;
  var key = theEvent.keyCode || theEvent.which;
  key = String.fromCharCode( key );
  var regex = /[0-9]|\./;
  if( !regex.test(key) ) {
    theEvent.returnValue = false;
    if(theEvent.preventDefault) theEvent.preventDefault();
  }
}