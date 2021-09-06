# This scripts rewrites MD links from [CSS::Foo](CSS::Foo) to [CSS::Foo](doc-url)

constant DocRoot = "https://css-raku.github.io";

multi sub resolve-class('LibXML') { :repo<https://libxml-raku.github.io/LibXML-raku/> }

multi sub resolve-class(*@path ('CSS', 'Font', 'Resources', *@)) {
    %( :repo<CSS-Font-Resources-raku>, :@path );
}

# CSS::Properties has several other CSS::Xxx namespaces
subset Properties-path of Str where 'Properties'|'Box'|'Units'|'Font'|'PageBox';
multi sub resolve-class(*@path ('CSS', Properties-path, *@)) {
    %( :repo<CSS-Properties-raku>, :@path );
}

# CSS::Stylesheet has several other CSS::Xxx namespaces
subset Stylesheet-path of Str where 'Media'|'Stylesheet'|'Ruleset'|'Selectors'|'AtPageRule'|'MediaQuery';
multi sub resolve-class(*@path ('CSS', Stylesheet-path, *@)) {
    %( :repo<CSS-Stylesheet-raku>, :@path );
}

multi sub resolve-class(*@p ('CSS', 'Selector', 'To', 'XPath')) {
    my $repo = @p.join('-') ~ '-raku';
    %( :$repo, :path[] );
}

# These have a README only and could possibly do with more doco
subset README-only-path of Str where 'Grammar'|'Module'|'Specification';
multi sub resolve-class( 'CSS', README-only-path $module, *@) {
    %( :repo("CSS-{$module}-raku"), :path[] );
}

multi sub resolve-class('CSS') {
    %( :repo<CSS-raku>, :path[] );
}

multi sub resolve-class(*@path ('CSS', 'TagSet', *@)) {
    %( :repo<CSS-TagSet-raku>, :@path );
}

multi sub resolve-class(*@path) {
    die "unable to resolve class {@path.join: '::'}";
}

sub link-to-url(Str() $class-name) {
    my %info = resolve-class(|$class-name.split('::'));
    my @path = DocRoot;
    @path.push: %info<repo>;
    @path.append(.list) with %info<path>;
    @path.join: '/';
}

sub breadcrumb(Str $url is copy, @path, UInt $n = +@path, :$top) {
    my $name = $top ?? @path[0 ..^ $n].join('::') !! @path[$n-1];
    $url ~= '/' ~ @path[0..^ $n].join('/');
    my $sep = $top ?? '/' !! '::';
    say " $sep [$name]($url)";
}

INIT {
    with %*ENV<TRAIL> {
        # build a simple breadcrumb trail
        my $url = DocRoot;
        say "[[Raku CSS Project]]({$url})";
        my %info = resolve-class(|.split('/'));
        my $repo = %info<repo>;
        $url ~= '/' ~ $repo;

        my @mod = $repo.split('-');
        @mod.pop if @mod.tail ~~ 'raku';
        my $mod = @mod.join: '-';
        say " / [[$mod]]({$url})";

        with %info<path> {
            my @path = .list;
            if @path {
                my $n = 2;
                breadcrumb($url, @path, $n, :top);
                breadcrumb($url, @path, $_)
                    for $n ^.. @path;
            }
        }
        say '';
    }
}

s:g:s/ '](' (['CSS'|'LibXML']['::'*%%<ident>]) ')'/{'](' ~ link-to-url(~$0) ~ ')'}/;
