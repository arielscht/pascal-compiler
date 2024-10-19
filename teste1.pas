program exemplo75 (input, output);
    var m, n, o:  integer;
    procedure p(t, u: integer);
        var a, b: integer;
    begin
        a := t + u;
    end;
    procedure q;
        var c, d: integer;
    begin
    end;
begin    
    m := 5 * 1 + 2;
    n := 10;
    if (m > 5) then
    begin
        if (n > 2) then 
            n := n - 1;
    end;
    p(m, n);
    q;
end.