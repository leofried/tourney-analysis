open Util;;

(*SMART SIM TEMPERATURE, LOTS OF OPTIONALITY HERE*)

module M (Scheme : S.SCHEME) = struct

  module Data = Data.M (Scheme);;

  let run_one_sim (specs : Specs.t) (scheme : Scheme.t) : float =
    let teams = Team.make_n specs.fidel specs.number_of_teams  in

    let results = Scheme.run scheme teams in

    let real =
      results
      |> List.map (fun t -> t.Team.skill)
      |> Lists.top_of_list specs.number_advance
      |> Tuple.left
      |> Lists.fold (+.)
    in

    let best =
      teams
      |> List.map (fun t -> t.Team.skill)
      |> List.sort (Fun.flip compare)
      |> Lists.top_of_list specs.number_advance
      |> Tuple.left
      |> Lists.fold (+.)
    in

    best -. real
  ;;

  let simulate_scheme (specs : Specs.t) (iters : int) (scheme : Scheme.t) : Stats.t =
    Team.set_luck specs.luck;
    Stats.of_list (List.init iters (fun _ -> run_one_sim specs scheme))
  ;;

  let simulate_schemes (specs : Specs.t) (iters : int) (schemes : Scheme.t list) : unit =
    schemes
    |> List.map (fun scheme -> scheme, simulate_scheme specs iters scheme)
    |> Data.write specs
  ;;

  let simulate_smart (specs : Specs.t) (iters : int) (data : Data.t list) : Data.t list =
    let best =
      data
      |> List.map (fun (_, stats) -> Stats.mean stats)
      |> Lists.fold min
    in
    let shares =
      data
      |> List.map (Tuple.map_right (fun stats -> (Stats.mean stats -. best) /. Stats.stderr stats))
      |> List.map (Tuple.map_right (fun i -> 1. /. (2. ** i)))
    in
    let total =
      shares
      |> List.map Tuple.right
      |> Lists.fold (+.)
    in
    shares
    |> List.map (Tuple.map_right (fun i -> int_of_float (i /. total *. (float_of_int iters))))
    |> List.map (fun (scheme, i) -> (scheme, simulate_scheme specs i scheme))
  ;;

  let simulate_smart_looped ?(schemes : Scheme.t list = []) (specs : Specs.t) (iters : int) =
    simulate_schemes specs 1000 schemes;
    
    Debug.loop (fun () ->
      print_endline "cycle complete";
      Data.read specs
      |> simulate_smart specs iters
      |> Data.write specs
    )
  ;;
end