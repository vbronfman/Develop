package com.company.jaxws.stockquote.service;

import java.io.PrintStream;
import java.util.Set;

import javax.xml.namespace.QName;
import javax.xml.soap.SOAPMessage;
import javax.xml.ws.handler.MessageContext;
import javax.xml.ws.handler.soap.SOAPHandler;
import javax.xml.ws.handler.soap.SOAPMessageContext;

/*
 * Log the whole SOAP message
 */
public class EnvelopeLoggingSOAPHandler extends BaseHandler<SOAPMessageContext> implements SOAPHandler<SOAPMessageContext> {
    
    private static PrintStream out = System.out;
	private static final String HANDLER_NAME = "EnvelopeLoggingSOAPHandler";
     
    public EnvelopeLoggingSOAPHandler(){
		super();
		super.setHandlerName(HANDLER_NAME);		
    }
    
    public boolean handleMessage(SOAPMessageContext smc) {
		out.println("------------------------------------");
		out.println("In SOAPHandler " + HandlerName + ":handleMessage()");
		logToSystemOut(smc);
		out.println("Exiting SOAPHandler " + HandlerName + ":handleMessage()");
		out.println("------------------------------------");    	
        return true;
    }

    private void logToSystemOut(SOAPMessageContext smc) {
        Boolean outboundProperty = (Boolean)
            smc.get(MessageContext.MESSAGE_OUTBOUND_PROPERTY);
        
        if (outboundProperty.booleanValue()) {
            out.println("\ndirection = outbound ");
        } else {
            out.println("\ndirection = inbound ");
        }
        
        SOAPMessage message = smc.getMessage();
        try {
        	out.println("");   
        	message.writeTo(out);
            out.println("");   
        } catch (Exception e) {
            out.println("Exception in SOAP Handler: " + e);
        }
    }

	public Set<QName> getHeaders() {
		return null;
	}
}
