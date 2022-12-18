open Util;;
open Struct;;

let calculate_imbalance (data : Data.t) (fair_to_zero : bool) : float =
  if fair_to_zero && data.scheme.is_fair then 0. else Stats.normed_stdev (List.map Int.to_float data.seed_wins)
;;

let get_pareto_list ~(luck : float) ~(number_of_teams : int) ~(max_games : int) : (Scheme.t * float * float) list=
  Data.read ~luck ~number_of_teams ~max_games true
  |> List.map (fun (data : Data.t) -> data.scheme, data.decay, calculate_imbalance data true)
  |> Lists.pareto
;;

let pareto ~(luck : float) ~(number_of_teams : int) ~(max_games : int) : unit =
  List.iter
    (fun (scheme, decay, imbalance) -> 
      print_endline @@ "(" ^ Math.to_pct ~digits:2 decay ^ ", " ^ Math.to_pct ~digits:2 imbalance ^ "): " ^ scheme.Scheme.name
    )
    (get_pareto_list ~luck ~number_of_teams ~max_games)
;;

let all ~(luck : float) ~(number_of_teams : int) ~(max_games : int) : unit =
  List.iter
    (fun (data : Data.t) -> 
      print_endline @@
      "(" ^ 
      Math.to_pct ~digits:2 data.decay ^
      " [" ^
      Math.to_pct ~digits:2 data.margin ^
      "], " ^
      Math.to_pct ~digits:2 (calculate_imbalance data false) ^
      " [" ^
      Bool.to_string data.scheme.is_fair ^
      "]) in " ^
      Int.to_string data.iters ^
      " iters : " ^
      data.scheme.name
    )
    (List.sort
      (fun (d1 : Data.t) (d2 : Data.t) -> Float.compare d2.decay d1.decay)
      (Data.read ~luck ~number_of_teams ~max_games true)
    )
;;
