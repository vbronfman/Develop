package com.company.jaxws.stockquote.service;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.LinkedList;
import java.util.List;

import javax.xml.ws.Binding;
import javax.xml.ws.Endpoint;
import javax.xml.ws.handler.Handler;

import com.sun.net.httpserver.HttpContext;
import com.sun.net.httpserver.HttpServer;

public class StockQuoteService {
	private Endpoint endpoint = null;

	private TimingThreadPool executor = new TimingThreadPool();

	private HttpServer server = null;
	private HttpContext context = null;

	public StockQuoteService() {
		endpoint = Endpoint.create(new StockQuoteImpl());
	}

	private void server() throws IOException {
		server = HttpServer.create(new InetSocketAddress(1970), 5);
		//server.setExecutor(executor);
		server.start();

		context = server.createContext("/StockQuote/StockQuoteService");
		context.setAuthenticator(new TestBasicAuthenticator("test"));
		endpoint.publish(context);
	}

	private void publish() {
//		endpoint.setExecutor(executor);
		Binding binding = endpoint.getBinding();
		List<Handler> handlerChain = new LinkedList<Handler>();
		handlerChain.add(new EnvelopeLoggingSOAPHandler());
		binding.setHandlerChain(handlerChain);
		endpoint.publish("http://localhost:1970/StockQuote/StockQuoteService");
	}

	private void stop() {
		endpoint.stop();
	}

	private void shutdown() {
		endpoint.stop();
		server.stop(1);
	}

	public static void main(String[] args) {
		StockQuoteService sqs = new StockQuoteService();
		if (args.length != 1) {
			System.out
					.println("Please specify the action intended!");
			System.exit(0);
		} else if (args[0].equalsIgnoreCase("server")) {
			try {
				sqs.server();
			} catch (IOException e) {
				e.printStackTrace();
			}
			System.out
					.println("StockQuoteService is open for business at http://localhost:1970/StockQuote/StockQuoteService!");
		} else if (args[0].equalsIgnoreCase("shutdown")) {
			sqs.shutdown();
			System.out
					.println("StockQuoteService at http://localhost:1970/StockQuote/StockQuoteService has been shutdown!");
		} else if (args[0].equalsIgnoreCase("publish")) {
			sqs.publish();
			System.out
					.println("StockQuoteService is open for business at http://localhost:1970/StockQuote/StockQuoteService!");
		} else if (args[0].equalsIgnoreCase("stop")) {
			sqs.stop();
			System.out
					.println("StockQuoteService at http://localhost:1970/StockQuote/StockQuoteService has been stopped!");
		} else {
			System.out
					.println("Wrong argument, use: server, shutdown, publish or stop!");
			System.exit(0);
		}
	}
}
