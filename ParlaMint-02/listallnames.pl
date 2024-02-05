## we will store all names in this hash table (along with counts)
my %names;

## read each file retrieving names and storing them in %names
foreach (@ARGV){
    open(FI,$_) or die "Error opening file $_: $!";
    while (<FI>){
        $names{$1}++
            if /<name>(.+?)<\/name>/g;
    }
    close FI;
}
## printed sorted list of unique names occurring in all files in @ARGV
foreach (sort {cmpnames($a,$b)} keys %names ){
    print "'$_'    ".$names{$_}." occurrences\n";
}


sub cmpnames{
    my $na = lc(shift); ## lowercase everything
    my $nb = lc(shift);
  
    ## remove spaces
    $na =~ s/\s+//g;
    $nb =~ s/\s+//g;

    ## compare resulting strings as normal
    return $na cmp $nb;
}
