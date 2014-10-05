package com.company.jaxws.stockquote.service;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;

public class TimingThreadPool extends ThreadPoolExecutor {

		public TimingThreadPool() {
			super(1, 1, 0L, TimeUnit.SECONDS, new ArrayBlockingQueue<Runnable>(
					10));
		}

		private final ThreadLocal<Long> startTime = new ThreadLocal<Long>();

		private final AtomicLong numTasks = new AtomicLong();

		private final AtomicLong totalTime = new AtomicLong();

		protected void beforeExecute(Thread t, Runnable r) {
			super.beforeExecute(t, r);

			System.out.printf("$$$$$$$$$$$$$$$ Runnable %s starts in %s. \n",
					r, t);
			startTime.set(System.nanoTime());
		}

		protected void afterExecute(Runnable r, Throwable t) {
			try {
				long endTime = System.nanoTime();
				long taskTime = endTime - startTime.get();
				numTasks.incrementAndGet();
				totalTime.addAndGet(taskTime);
				System.out.printf(
						"$$$$$$$$$$$$$$$ Runnable %s ends after %dns. \n", r,
						taskTime);
				if (t != null) {
					t.getCause().printStackTrace();
				}
			} finally {
				super.afterExecute(r, t);
			}
		}

		protected void terminated() {
			try {
				System.out.printf(
						"$$$$$$$$$$$$$$$ Terminated: avg time=%dns. \n",
						totalTime.get() / numTasks.get());
			} finally {
				super.terminated();
			}
		}
	}