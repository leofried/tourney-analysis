exception ImplementationError
let error () = raise ImplementationError

let line () = print_endline "";;

let time (f : unit -> 'a) : 'a * float =
  let time_start = Unix.gettimeofday () in
  let value = f () in
  let time_end = Unix.gettimeofday () in
  value, (time_end -. time_start)
;;

let surround f x = 
  print_endline "surround_before";
  let y = f x in
  print_endline "surround_after";
  y
;;