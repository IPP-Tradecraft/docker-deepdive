#!/usr/bin/perl
#  
# Help display script for Makefile
# This script will display content of a file between
# @@help [<tag>] and @@end-help
# 


my $insideHelpBlock = undef;

while(<>) {
	/^#?\s*\@\@help(?:\s+(?<block>\w+))?/ && do {
		$insideHelpBlock = ($+{block} || "help");
		print "\n", ucfirst($insideHelpBlock), "\n", "=" x length($insideHelpBlock), "\n";
		next;
	};
	/^#?\s*\@\@end-help(?:(?:[ \t]+)(\w+))?/ && do { $insideHelpBlock = undef; next; };
	if($insideHelpBlock) {
		s/^#?\s?//;
		s/\s*$//;
		printf " %s\n", $_;
	}
}

1;
