constant DocRoot = "https://css-raku.github.io";

multi sub resolve-class('LibXML') { :repo<https://libxml-raku.github.io/LibXML-raku/> }

subset Properties-path of Str where 'Properties'|'Box'|'Units'|'Font'|'PageBox';
multi sub resolve-class( 'CSS', *@path (Properties-path, *@)) {
    %( :repo<CSS-Properties-raku>, :@path );
}

subset Stylesheet-path of Str where 'Media'|'Stylesheet'|'Ruleset';
multi sub resolve-class( 'CSS', *@path (Stylesheet-path, *@)) {
    %( :repo<CSS-Selectors-raku>, :@path );
}

subset Module-path of Str where 'Grammar'|'Module'|'Specification';
multi sub resolve-class( 'CSS', Module-path $module, *@) {
    %( :repo("CSS-{$module}-raku"), :path[] );
}

multi sub resolve-class('CSS') {
    %( :repo<CSS-raku>, :path[] );
}
multi sub resolve-class('CSS', 'TagSet', *@) {
    %( :repo<CSS-raku>, :path[] );
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

s:g:s/ '](' (['CSS'|'LibXML']['::'*%%<ident>]) ')'/{'](' ~ link-to-url(~$0) ~ ')'}/;
