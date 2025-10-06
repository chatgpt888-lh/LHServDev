package com.test;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import com.svc.call.utilize.Utilizer;

public class UtilizerTest {

    @Test
    public void testGenNextID4Digit() {
        assertEquals("0001", Utilizer.GenNextID4Digit(1));
        assertEquals("0012", Utilizer.GenNextID4Digit(12));
        assertEquals("0123", Utilizer.GenNextID4Digit(123));
        assertEquals("1234", Utilizer.GenNextID4Digit(1234));
    }
}