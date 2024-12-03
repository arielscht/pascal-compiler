program testforward;  
    procedure First (n : longint); forward;  
    function Third(n: longint): longint ; forward;
    procedure Second;  
    begin  
        WriteLn ('In second. Calling first...');  
        First (1);  
    end;  
    procedure First (n : longint);  
        procedure Forth(n: longint); forward;
        procedure Forth(n: longint);
        begin
        end;
    begin  
        WriteLn ('First received : ',n);  
        n := Third(n);
    end;
    function Third(n: longint): longint;
    begin
        Third := n * 10;
    end;
begin  
  Second;  
end.