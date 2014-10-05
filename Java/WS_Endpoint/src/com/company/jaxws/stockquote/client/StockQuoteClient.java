package com.company.jaxws.stockquote.client;

import java.rmi.RemoteException;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import javax.xml.ws.BindingProvider;

public class StockQuoteClient {
	public static void main(String[] args) {
		try {
			StockQuote port = new StockQuoteService().getStockQuotePort();			
			System.out.println("\nInvoking getQuote():");
			
			//client code for service published with the default HTTP server
//			String ticker1 = "MHP";
//			double result1 = port.getQuote(ticker1);
//			System.out.printf("The stock price of %s is $%f.\n", ticker1, result1);
			
			//client code for service published with service instantiated HTTP server
			BindingProvider bp = (BindingProvider)port;
			Map<String,Object> map = bp.getRequestContext();
			map.put(BindingProvider.USERNAME_PROPERTY, "yyang");
			map.put(BindingProvider.PASSWORD_PROPERTY,"#$$1x5Y7z");
			//map.put(BindingProvider.PASSWORD_PROPERTY,"password");			
			String ticker2 = "IBM";
			double result2 = port.getQuote(ticker2);
			System.out.printf("The stock price of %s is $%f.\n", ticker2, result2);			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
