program passRef(input, output);
    var k: integer;
    procedure p(n: integer; var g: integer);
        var h: integer;
    begin
        if (n < 2) then
            g := g + 1
        else
        begin
            p(n - 1, h);
            g := h;
            p(n - 2, g);
        end;
    end;
    function q: integer;
        var t, u: integer;
    begin
    end;
begin
    k := 0;
    p(3, k);
    q;
end.