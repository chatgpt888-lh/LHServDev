<!--
function validateMeter(meterNo) {
	if ((meterNo.indexOf(" ") != -1) || (meterNo.indexOf("#") != -1)) {
		return false;
	}
	return true;
}

function commaSplit(srcNumber) {
var txtNumber = '' + srcNumber;
if (isNaN(txtNumber) || txtNumber == "") {
alert("Oops!  That does not appear to be a valid number.  Please try again.");
fieldName.select();
fieldName.focus();
}
else {
var rxSplit = new RegExp('([0-9])([0-9][0-9][0-9][,.])');
var arrNumber = txtNumber.split('.');
arrNumber[0] += '.';
do {
arrNumber[0] = arrNumber[0].replace(rxSplit, '$1,$2');
} while (rxSplit.test(arrNumber[0]));
if (arrNumber.length > 1) {
return arrNumber.join('');
}
else {
return arrNumber[0].split('.')[0];
      }
   }
}

function formatCurrency(num) {
	s = "";
	if (num < 0)
	{
		s = "-";
	}
	num = num.toString().replace(/\$|\,/g,'');

	if(isNaN(num))
		num = "0";
	sign = (num == (num = Math.abs(num)));
	num = Math.floor(num*100+0.50000000001);
	cents = num%100;
	num = Math.floor(num/100).toString();
	if(cents<10)
		cents = "0" + cents;
	return(s+num+'.'+cents)
}

function formatCurrencyNoRound(num) {
	s = "";
	if (num < 0)
	{
		s = "-";
	}
	num = num.toString().replace(/\$|\,/g,'');

	idx = num.indexOf('.');
	if (idx > -1) {
		cents = num.substring(idx+1, num.length);
		if (cents.length == 1) {
			cents = cents+"0";
		} else {
			cents = cents.substring(0, 2);
		}
		cents = "."+cents;
		num = num.substring(0, idx);
	} else {
		cents = "";
	}	
	return(s+num+cents)
}

function checkDecimals(fieldValue) {
	var valid = 0;
	decallowed = 2;  // how many decimals are allowed?
	if (isNaN(fieldValue) || fieldValue == "") {
		alert("â»Ã´ÃĞºØ¨Ó¹Ç¹à§Ô¹");
	} else {
		if (fieldValue.indexOf('.') == -1) fieldValue += ".";
		dectext = fieldValue.substring(fieldValue.indexOf('.')+1, fieldValue.length);
		if (dectext.length > decallowed) {
			alert ("¨Ó¹Ç¹·È¹ÔÂÁ¼Ô´¾ÅÒ´");
		} else {
			valid = 1;
		}
	}
	return valid;
}
//-->


