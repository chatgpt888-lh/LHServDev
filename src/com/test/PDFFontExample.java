package com.test;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.OutputStream;
 
import com.lowagie.text.Chunk;
import com.lowagie.text.Document;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Font;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfWriter;
 
public class PDFFontExample {
	
    public static void main(String[] args) throws FileNotFoundException, DocumentException {
 
        // Create new PDF document
        Document document = new Document();
        // Create an output stream of PDF file.
        OutputStream out = new FileOutputStream("d:\\PDF_Font_Example.pdf");
        // Get a PdfWriter instance to write in PDF document.
        PdfWriter.getInstance(document, out);
        // Open the PDF document
        document.open();
       
        
        
        
        // Create the Fonts
       /* Font normalFont = new Font(Font.NORMAL, 12);
        Font normalBoldFont = new Font(Font.NORMAL, 12, Font.BOLD);
        Font courierFontItalic = new Font(Font.COURIER, 10, Font.ITALIC);
        Font courierFontUnderline = new Font(Font.COURIER, 10, Font.UNDERLINE);
        Font timesRomanItalic = new Font(Font.TIMES_NEW_ROMAN, 20, Font.ITALIC);
        Font timesRomanUnderline = new Font(Font.TIMES_NEW_ROMAN, 20, Font.UNDERLINE);
        // Apply the created fonts to Chunks, Phrases and Paragraphs.
        document.add(new Chunk("This is Normal text. ", normalFont));
        document.add(new Chunk("This is Normal Bold text.  ", normalBoldFont));
        document.add(new Phrase("This is Courier Italic text.  ", courierFontItalic));
        document.add(new Phrase("This is Courier Underline text.  ", courierFontUnderline));
        document.add(new Paragraph("This is Times Roman Italic text.  ", timesRomanItalic));
        document.add(new Paragraph("This is Times Roman Underline text.  ", timesRomanUnderline));
       */
        
        
        
        // Close the document after use.
        document.close();
    }
 
}