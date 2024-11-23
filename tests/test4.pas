program passRef(input, output);
    var k, l: integer;
    function q(n: integer; var m: integer): integer;
        var t, u: integer;
    begin
        read(t);
        read(n);
        read(m);
        read(q);

        q := 5;
    end;
begin
    k := 0;
    write(k);
    write(k * 2 + k);
    write(q(10, k));
end.