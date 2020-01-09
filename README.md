# Ngrams

the following program is designed to learn an Ngram language model from an arbitrary number of plain files that will constitute
to the overall corpse.

### example of some sentences generated from different files that include but not restricted to the following books:
* a tale of two cities for Charles Dickens
* The Odyssey for Homer
* War and peace for Leo Tolstoy 

### the following 10 sentences are based on a quad-gram model:

* the grindstone had a double handle, and, with open mouth and dropped jaw, looked stricken.

* that night another wounded man was prince andrew nski.

* that just it, interrupted dolgor quickly, laughing.

* rou!

* let him that hath shall be given, and would know no scruple as to means.

* it seemed to him that the complete freedom of which he has so often looked at me with such surprise.

* before their cells were quit of them, as if he were saying now go through your performance.

* pierre well remembered this small circular drawing room with a mysterious air.

* from the palace of olympian jove, and stress, like the yelp of a dog when it rapidly but feebly wags its mon dieu, mon dieu!

* what troubles one has with these girls without their mother!	

each file that constitute to the overall corpus is handled on its own, the most difficult or tricky part is the parsing part, how to differentiate between tokens?
the rules that were followed in parsing the text by using regular expression are as following:
** first n-1 start tags are added to the start of every new sentence.
** apostrophes are handled on their own so that words like don't or won't will be handled properly
** all types of brackets are discarded as there could appear a "(" in the generated sentences without its matching bracket
** any kind of weird chars (uncommon chars) are discarded.

then calculating the probability of the next coming word is easy as we maintain two hash tables one for the frequency last n-1 tokens and every other word that follows
and another one is for only the frequency of the last n-1 words

last but not least, generating the sentences is done by randomly choosing the next word considering the probability of it appearing next.

## usage
the N-gram language model, the number of sentences to generate, and the files are passed as arguments in the command line respectively.
#### example: perl ngram.pl 4 10 1497.txt 98-0.txt

## fun fact
some of the answers in the famous card game 'Cards against humanity' were generated using N-grams. you can try to generate your own, just be careful when choosing the files that constitute to your corpus.
