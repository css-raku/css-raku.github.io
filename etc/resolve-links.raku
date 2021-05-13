constant DocRoot = "https://css-raku.github.io";

multi sub resolve-class('LibXML') { :repo<https://libxml-raku.github.io/LibXML-raku/> }

subset Properties-path of Str where 'Properties'|'Box'|'Units'|'Font'|'PageBox';
multi sub resolve-class(*@path ('CSS', Properties-path, *@)) {
    %( :repo<CSS-Properties-raku>, :@path );
}

subset Stylesheet-path of Str where 'Media'|'Stylesheet'|'Ruleset'|'Selectors';
multi sub resolve-class(*@path ('CSS', Stylesheet-path, *@)) {
    %( :repo<CSS-Stylesheet-raku>, :@path );
}

subset Module-path of Str where 'Grammar'|'Module'|'Specification';
multi sub resolve-class( 'CSS', Module-path $module, *@) {
    %( :repo("CSS-{$module}-raku"), :path[] );
}

multi sub resolve-class('CSS') {
    %( :repo<CSS-raku>, :path[] );
}
multi sub resolve-class(*@path ('CSS', 'TagSet', *@)) {
    %( :repo<CSS-raku>, :@path );
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
        say " / [[$mod Module]]({$url})";

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
