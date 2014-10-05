package com.company.jaxws.stockquote.service;

import javax.jws.WebMethod;
import javax.jws.WebService;

@WebService(name = "StockQuote", serviceName = "StockQuoteService")
public class StockQuoteImpl {
	@WebMethod(operationName = "getQuote")
	public double getQuote(String ticker) {
		double result = 0.0;
		if (ticker.equals("MHP")) {
			result = 50.0;
		} else if (ticker.equals("IBM")) {
			result = 83.0;
		}
		return result;
	}
}
