#! usr/local/bin/perl
use strict;
use warnings;
use experimental 'smartmatch';

# Amer Haj Ahmad
# Class: CMSC416
# ID: V00897230

# the following program is designed to learn an Ngram language model from an arbitrary number of plain files that will constitute
# to the overall corpse.

#example of some sentences generated from different files that include but not restricted to the following books:
# a tale of two cities for Charles Dickens
# The Odyssey for Homer
# War and peace for Leo Tolstoy 

# the following 10 sentences are based on a quad-gram model:

#the grindstone had a double handle, and, with open mouth and dropped jaw, looked stricken.

#that night another wounded man was prince andrew nski.

#that just it, interrupted dolgor quickly, laughing.

#rou!

#let him that hath shall be given, and would know no scruple as to means.

#it seemed to him that the complete freedom of which he has so often looked at me with such surprise.

#before their cells were quit of them, as if he were saying now go through your performance.

#pierre well remembered this small circular drawing room with a mysterious air.

#from the palace of olympian jove, and stress, like the yelp of a dog when it rapidly but feebly wags its mon dieu, mon dieu!

#what troubles one has with these girls without their mother!	

# **************************************************************************************************************************************************

# Description for the algorithm used.
# first, I will handle each file on its own, the most difficult or tricky part is the parsing part, how to differentiate between tokens?
# the rules that were followed in parsing the text by using regular expression are as following:
# first n-1 start tags are added to the start of every new sentence.
# apostrophes are handled on their own so that words like don't or won't will be handled properly
# all types of brackets are discarded as there could appear a "(" in the generated sentences without its matching bracket
# any kind of weird chars (uncommon chars) are discarded.

# then calculating the probability of the next coming word is easy as we maintain two hash tables one for the frequency last n-1 tokens and every other word that follows
# and another one is for only the frequency of the last n-1 words

# last but not least, generating the sentences is done by randomly choosing the next word considering the probability of it appearing next.

my $start = "<s>";
my $end = "<e>";

my @sentence = ();
my %hash1;
my %hash2;  
my $n;
my $m;
my $num_of_words_in_corpse=0;
my $apostrophe = '\'';


# this sub routine is to maintain the hash tables for the last n-1 gram.
sub process_ngram ()
{
	my ($token) = $_[0];
	#print( "$token!!!\n" );
	if ( $#sentence < $n-2 ) 
	{
		push( @sentence , $token );
	}
	else
	{
		my $history = join ' ',@sentence;
		#print("$history - $token\n");
		$hash1{$history}{$token}++;
		$hash2{$history}++;
		shift(@sentence);
		push(@sentence, $token);
	}
}

# this sub routine is to add n-1 start tags before the start of every sentence
sub startNgram()
{
	for ( my $i=1 ; $i<$n ; $i++)
	{
		&process_ngram($start);
	}
}

# this sub routine is to handle files (to parse the text in files)
sub filehandler()
{
	my ($file) = $_[0];
	my @tmp = ();
	my @text = ();
	open(FILE, "<", $file) or die "could not open file: $file\n";
	startNgram();
	my $x=0;
	while( <FILE> )
	{
		chomp;
		@text = split (/\s+/, $_);
		#splitting the words in every line on white spaces
		$x += scalar (@text);
		if ( scalar (@text)>=$n ){
			foreach my $token (@text)
			{
				$token = lc($token);
				#print( "this is a token: $token\n" );
				#handling all the cases while parsing
				#handling words that end with a terminating chars
				if ( $token=~m/(\w+)([.?!])/ )
				{
					&process_ngram($1);
					&process_ngram($2);
					&startNgram();
				}
				
				# handling words that end with chars that could not be recognized
				elsif ( $token=~m/(\w+)([^A-Za-z0-9\.!?;,\s+"])/ )
				{
					if ( length $2>0 && $2 eq $apostrophe )
					{ &process_ngram($token); next; }
					&process_ngram($1);
				}
				
				# handling words that end with a punctuation
				elsif ( $token=~m/(\w+)([,;-_:])/ )
				{
					if ( length $1 > 0 ){
					&process_ngram($1);
					}
					&process_ngram($2);
				}
				
				# handling words that start with a punctuation
				elsif ( $token=~m/([,;-_:])(\w+)/ )
				{
					&process_ngram($1);
					if ( length $2 > 0 ){
					&process_ngram($2);
					}
				}
				
				# handing words that start with unrecognizable chars.
				elsif ( $token=~m/([^A-Za-z0-9\.!?;,\s+"])(\w+)/ )
				{
					if ( length $2 > 0 ){
					&process_ngram($2);
					}
				}
				# handling normals words
				else
				{
					&process_ngram($token);
				}
			}
		}
	}
	# just to check that the corpse has more than a million token
	$num_of_words_in_corpse += $x;
	close(FILE);
}

# this sub routine is to calculate the probability for words to occur after a given history that is passed as a parameter
# and then choosing one word randomly based on its probability to occur after that history.
# note: the history will always be n-1 tokens
sub calculate()
{
	my ($target) = $_[0];
	#print("$target\n");
	
	# calculating the probability for every word that could follow the last n-1 words
	my %probability = ();
	
	
	foreach my $tmp ( keys %{$hash1{$target}} )
	{
		if ( $hash2{$target} ne 0 ){
		$probability{$tmp} = $hash1{$target}{$tmp}/$hash2{$target};
		#print( "$target --- > $tmp  -- $probability{$tmp}\n" );
		}
	}

	
	my $random = rand();
	my $sum = 0;
	
	# choosing the word to follow the history after calculating the probability array for every that could follow the last n-1 words
	foreach my $tmp ( values %probability )
	{
		$sum += $tmp;
		if ( $sum > $random )
		{
			foreach my $ret ( keys %probability )
			{
				if ( $tmp eq $probability{$ret} )
				{
					return $ret;
				}
			}
		}
	}
}


#sub special_case()
#{
#	my %probability = ();
#	foreach my $tmp ( keys %hash2 )
#	{
#		if ( $hash2{$tmp} ne 0 ){
#		$probability{$tmp} = $hash2{$tmp}/$num_of_words_in_corpse;
#		}
#	}
#	return %probability;
#}


# this subroutine is to generate the ngram
sub generate()
{
	my @ngram = ();
	for ( my $i=1 ; $i<$n ; $i++ ) { push( @ngram , $start ); }
	my $ret = join " ", @ngram;
	my $sol = "";
	my $length=0;
	my %prob = ();
	while(1)
	{
		my $generated = "";
		$generated = &calculate($ret);
		push( @ngram , $generated );
		shift( @ngram );
		$ret = join " ", @ngram;
		# if the generated word is a terminating token or if the length of the sentence is more than 100 then just return the sentence.
		if ( $generated=~m/([!?.]|$end)/ or $length>100 )
		{	
			chop($sol);
			if ( $generated=~m/[!?.]/ ){
			$sol = $sol.$generated." ";
			}
			return (split(/\s+/, $sol));
		}
		if ( $generated =~m/([,;-_:])/ )
		{
			chop($sol);
		}
		$sol = $sol.$generated." ";
		$length++;
	}
}


# *********** here is the start of the program *************


$n = $ARGV[0];
$m = $ARGV[1];

# looping over the files and handling them.
for (my $i=2 ; $i<scalar(@ARGV) ; $i++ )
{
	&filehandler($ARGV[$i]);
}

print("This program generates random sentences based on an Ngram model.\n");
print("Command line settings : ngram.pl $n $m\n\n");

#generating m sentences based on the n gram model.
for ( my $i=0 ; $i<$m ; $i++ )
{
	my @ngram = &generate();
	while( $ngram[0] eq $start ) { shift(@ngram); }
	my $output = join " ",@ngram;
	print("$output\n\n");
}
#print("$num_of_words_in_corpse\n");

