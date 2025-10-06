package serv.common;
import com.lh.util.doString;
import java.io.*;
import java.util.*;
import java.text.*;
import java.math.BigDecimal;
public class NumberUtil {
public static final NumberFormat DEFAULT_DECIMAL_FORMAT = new DecimalFormat("#.0#################");
public static final BigDecimal ZERO = new BigDecimal("0");
public static BigDecimal add(double a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(a);
    BigDecimal bd = new BigDecimal (s);
    return add (bd, b);
}

public static BigDecimal add(BigDecimal a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(b);
    BigDecimal bd = new BigDecimal (s);
    return add (a, bd);
}

public static BigDecimal add(BigDecimal a, BigDecimal b) {
    if (a == null) return (b == null) ? ZERO : b;
    return a.add (b);
}


public static BigDecimal subtract(double a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(a);
    BigDecimal bd = new BigDecimal (s);
    return subtract (bd, b);
}

public static BigDecimal subtract(BigDecimal a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(b);
    BigDecimal bd = new BigDecimal (s);
    return subtract (a, bd);
}

public static BigDecimal subtract(BigDecimal a, BigDecimal b) {
    if (a == null) return (b == null) ? ZERO : b;
    return a.subtract (b);
}

public static BigDecimal multiply(double a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(a);
    BigDecimal bd = new BigDecimal (s);
    return multiply (bd, b);
}

public static BigDecimal multiply(BigDecimal a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(b);
    BigDecimal bd = new BigDecimal (s);
    return multiply (a, bd);
}

public static BigDecimal multiply(BigDecimal a, BigDecimal b) {
    if (a == null) return (b == null) ? ZERO : b;
    return a.multiply(b);
}

public static BigDecimal divide(double a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(a);
    BigDecimal bd = new BigDecimal (s);
    return divide (bd, b);
}

public static BigDecimal divide(BigDecimal a, double b) {
    String s = DEFAULT_DECIMAL_FORMAT.format(b);
    BigDecimal bd = new BigDecimal (s);
    return divide (a, bd);
}

public static BigDecimal divide(BigDecimal a, BigDecimal b) {
    if (a == null) return (b == null) ? ZERO : b;
    return a.divide(b, 2, BigDecimal.ROUND_HALF_UP);
}

static public String displayNumber(String format, double getdouble) {
	String conmoney = null;
	BigDecimal getmoney = new BigDecimal(DEFAULT_DECIMAL_FORMAT.format(getdouble));
	getmoney = getmoney.setScale(2,BigDecimal.ROUND_HALF_UP);
	conmoney = doString.displayNumber(format, getmoney.doubleValue());
	return conmoney;
}  
static public double toNumber(String format, double getdouble) {
	String conmoney = null;
	BigDecimal getmoney = new BigDecimal(DEFAULT_DECIMAL_FORMAT.format(getdouble));
	getmoney = getmoney.setScale(2,BigDecimal.ROUND_HALF_UP);
	return Double.parseDouble(doString.displayNumber(format, getmoney.doubleValue()));
}	

}