program LISTE1;

        type   ELPTR = ^ELEMENT;
               ELEMENT = record
                               value : String;
                               next : ELPTR;
                         end;

        var top : ELPTR;
        var input, command : String;

        (* Writes list elements to console *)
        procedure PrintList;
        var current : ELPTR;
        begin
             if top = NIL then
             begin
                  writeln('Liste ist leer.');
             end
             else
             begin
                 current := top;
                 repeat
                       writeln(current^.value);
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if(current <> top) then writeln(current^.value);
             end;
        end;

        (* Adds value to end of list *)
        procedure AddValue(value : String);
        var current : ELPTR;
        var element : ELPTR;
        begin
             New(element);
             element^.value := value;
             element^.next := NIL;

             if top = NIL then
             begin
                  top := element;
             end
             else
             begin
                  current := top;
                  while current^.next <> NIL do
                  begin
                       current := current^.next;
                  end;
                  current^.next := element;
             end;
        end;

        (* Pushes value at the begin of list *)
        procedure PushValue(value : String);
        var element : ELPTR;
        begin
             New(element);
             element^.value := value;
             element^.next := top;
             top := element;
        end;

        (* Delete Value or values from list *)
        procedure DeleteValue(value : String);
        var current : ELPTR;
        var pre : ELPTR;
        var free : ELPTR;
        begin
             pre := NIL;
             if top <> NIL then
             begin
                current := top;
                repeat
                      if current^.value = value then
                      begin
                           if pre <> NIL then pre^.next := current^.next;
                           free := current;
                           current := current^.next;
                           if free = top then top := current;
                           Dispose(free);
                      end
                      else
                      begin
                           pre := current;
                           current := current^.next;
                      end;
                until current^.next = NIL;

                if current^.value = value then
                begin
                     pre^.next := NIL;
                     Dispose(current);
                end;

             end;
        end;

        (* Main routine *)
        begin
             top := NIL;
             repeat
                   PrintList;
                   write('Command (add/push/delete/exit): ');
                   readln(command);
                   if command = 'add' then
                   begin
                        write('Value to add: ');
                        readln(input);
                        AddValue(input);
                   end
                   else if command = 'push' then
                   begin
                        write('Value to push: ');
                        readln(input);
                        PushValue(input);
                   end
                   else if command = 'delete' then
                   begin
                        write('Value to delete: ');
                        readln(input);
                        DeleteValue(input);
                   end
             until command = 'exit';
        end.
end.