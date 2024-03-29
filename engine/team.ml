open Util;;

type t = {name : string; skill : float; mutable games : int};;

let team_index = ref 0;;

let get_next_team_name () = "Team " ^ (team_index := !team_index + 1; Int.to_string !team_index);;

let make ?(name = get_next_team_name()) ?(skill = Rand.get_gaussian()) () : t = {name; skill; games = 0}

let make_n (_ : float) (n : int) = 
  List.init n (fun _ -> make ())
(*  |> List.map (fun x -> x, Rand.get_gaussian () *. (1. -. fidel) -. x.skill *. fidel) 
  |> List.sort (Tuple.compare ~right:Float.compare)
  |> List.split
  |> Tuple.left *)
;;


let luck = ref 1.;;

let set_luck (lck : float) = (luck := lck);;


let play_game (is_bracket : bool) (t1 : t) (t2 : t) : t * t =
  if is_bracket then begin
    let new_games = 1 + max t1.games t2.games in
    t1.games <- new_games;
    t2.games <- new_games;
  end else begin
    t1.games <- t1.games + 1;
    t2.games <- t2.games + 1;
  end;

  let debug = false in
  let t1p = t1.skill +. Rand.get_gaussian() *. !luck in
  let t2p = t2.skill +. Rand.get_gaussian() *. !luck in
  let cmp = compare t1p t2p in
  let flp = Rand.get_gaussian() > 0. in
  match cmp > 0 || (cmp == 0 && flp) with
    | true -> if debug then print_endline (t1.name ^ " beat " ^ t2.name) else (); t1, t2
    | false -> if debug then print_endline (t2.name ^ " beat " ^ t1.name) else (); t2, t1
;;