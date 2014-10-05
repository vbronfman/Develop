package com.company.jaxws.stockquote.service;

import com.sun.net.httpserver.BasicAuthenticator;

public class TestBasicAuthenticator extends BasicAuthenticator{

	public TestBasicAuthenticator(String realm) {
		super(realm);
	}

	@Override
	public boolean checkCredentials(String username, String password) {
		if (username.equals("yyang") && password.equals("#$$1x5Y7z")){
			return true;
		}
		return false;
	}

}
