#!/usr/bin/perl
#get array of sql files to run in parallel , if found error ask: If the user want to skip error
#if pressed Skip or the SQL run successfully - return 0
#if pressed no the function return 1, it will always run all the files in current layer - DDL, DML or packages 
#And manage fill structure filename => 0/1 - that used in the parent program .

sub run_parallel {
    
	my $flag = 0;
	my @run_files =@_;
    my $LOG_dir = "$LOGDIR/";
	
	foreach $child ( 0 .. $#run_files)
	
	{
		print "\nSource numbr $child \n",$run_files[$child] , "####\n";
			chomp($run_files[$child]);
			($sec,$connection,$run_sql) = split('\|',$run_files[$child]);
		$run_sql =~ s/ /\\ /g;
		### Get name of SQL script to $2 path to $1
		$_ = $run_sql;
		/(.*)\/(.+)(\.sql)$/i;
		$paths=$1;
		$file=$2;
		
		$logfile=$LOG_dir.$file.".log";
		$runfile=$file.$3;
		$file = "FILE$child";
		$run_sql = "@".$runfile;
		($Project_conf_obj, @stam) = parse_ini_files ( $Projects_view );
	
		foreach $sec1 ($Project_conf_obj->Sections)
		{
	
		
			if ($sec1 eq $sec) {
			$mail_address = $Project_conf_obj->val( $sec, 'mail_addresses');
			print $mail_address;
			}
		}
	
		#print "Path $run_sql, logfile $logfile \n";
		#this redirection written for bash :$PID = open($file, "cd $paths; sqlplus $connection <<Exitf> $logfile 2>&1
		print "\nRUN SQL proc number $child\n Path - $paths; SqlConnect - $connection; SqlScr - $run_sql; LogFile - $logfile\n";
	
# DON't touch or move EOF from this place ! - it works only whithout any simbols before it !
	$PID = open($file, "cd $paths; sqlplus $connection >& $logfile <<EOF
	$run_sql
EOF
	|");
	
		### Save script name in array, where array index - name of file descriptor
		$run_proc[$child] = $runfile;
		$proc[$child]=$logfile;
		$mail_addr[$child]=$mail_address;
	#	print "Started $PID logged to $logfile \n";
	}
	
	foreach $child ( 0 .. $#run_files)
	{
		$file = "FILE$child";
		$PID = close($file);
		#print "Finished $PID - $proc[$child] \n";
		$COM = "grep -i ERROR $proc[$child]";
		$stat = system ($COM);
		#added for new structure-------------------------------------
		 #   print $run_files[$child] , "\n";
			chomp($run_files[$child]);
			($sec,$connection,$run_sql) = split('\|',$run_files[$child]);
	        $run_sql =~ s/ /\\ /g;
			# $_ = $proc[$child];
			# /(.*)\/(.+)\.log$/;
			#$f_name =$2.".sql";
			$f_name =$run_proc[$child];
		#If where is error -------------------------------------
		if ($stat == 0) 
		{
		    
			print OUT "Found error in file $f_name, logfile $proc[$child] \n";
			
			$COM1 = "mailx -s \"Errorlog $f_name\" $mail_addr[$child] < $proc[$child]"; 
			$status = system ($COM1);
			if ( $status != 0 )
			{
				print OUT "Can't send errorlog $proc[$child] to  $mail_addr[$child] :\n";
			}
			while (1) 
			{
              print "Error in $f_name - Skip this error? Say yes or no: ";
              $rd=<STDIN>;
              print "- $rd";
              if ( $rd =~ /y|yes|n|no/ ) { print "YES|NO"; last; }
            }

            print " Pressed - $rd \n";
          			 
		
            if ( $rd =~ /n|no/ ) 
              {
			    $run_success {$run_sql} = 0 ;
				$flag = 1;
			   }
            else #if pressed Skip 
              {
				if ( $rd =~ /y|yes/ )
					{
						print OUT "Skiped $f_name , logfile $proc[$child] \n";
						$run_success {$run_sql} = 1 ;
					}
				
			  }			  
		}
		else #the SQL run successfully
				{ 
					print  "Run successfully $f_name, logfile $proc[$child] \n";
					print OUT "Run successfully $f_name, logfile $proc[$child] \n";
					$run_success {$run_sql} = 1 ;
			    }
	}
	return $flag;
}
