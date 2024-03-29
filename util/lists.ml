open Infix;;

type 'a t = 'a list;;

(*CLean (comparer?)*)

let rec unwind = function
  | [] -> []
  | lst -> 
    lst
    |> List.filter ((<>) [])
    |> List.map (Tuple.apply (List.hd, List.tl))
    |> List.split
    |> Tuple.map_right unwind
    |> Tuple.uncurry List.append
;;

let rec top_of_list n lst = 
  if n = 0 then [], lst else
    match lst with
    | [] -> invalid_arg "Lists.top_of_list"
    | hd :: tl -> 
      let top, bot = top_of_list (n-1) tl in
      hd :: top, bot
;;

let top_of_list_rev n lst = 
  let rec f n top lst =
    if n = 0 then top, lst else
      match lst with
      | [] -> invalid_arg "Lists.top_of_list_rev"
      | hd :: tl -> 
        f (n-1) (hd :: top) tl
  in f n [] lst
;;

let rec find x lst =
  match lst with
  | [] -> 0
  | h :: t -> if x = h then 0 else 1 + find x t
;;

let fold f ?def lst=
  match lst with
  | [] -> begin match def with 
    | None -> invalid_arg "Lists.fold"
    | Some x -> x
  end
  | [x] -> x
  | hd :: tl -> List.fold_left (fun a x -> f a x) hd tl
;;

let fold_left_i f acc =
  List.mapi (fun i x -> x, i)
  >> List.fold_left (fun acc x -> f acc x) acc
;;


let to_string ?(new_line : bool = false) (stringify : 'a -> string) = function
  | [] -> "[]"
  | [i] -> "[" ^ (stringify i) ^ "]"
  | hd :: tl ->
    let rec f = function
    | [] -> "]"
    | hd :: tl -> (if new_line then "\n" else "") ^ "; " ^ (stringify hd) ^ f tl
    in "[ " ^ (stringify hd) ^ f tl
;;
       
let pareto (lst : ('a * float * float) list) : ('a * float * float) list =
  let rec pareto (best : float) (lst : ('a * float * float) list) : ('a * float * float) list = 
    match lst with
    | [] -> []
    | (str, one, two) :: lst ->
        if compare two best < 0 then
          (str, one, two) :: pareto two lst
        else
          pareto best lst
  in
  lst
  |> List.sort (fun (_, x, _) (_, y, _) -> Float.compare x y)
  |> pareto Float.max_float
;;

let rec pair_offset = function
  | [] -> []
  | [_] -> []
  | a :: (b :: _ as lst) -> (a, b) :: pair_offset lst
;;

let group_by lst =
  let rec f = function
    | [] -> []
    | (tag, ele) :: tl ->
      let assoc = f tl in
      if List.mem_assoc tag assoc then
        List.map (fun (tg, lst) -> tg, if tg = tag then ele :: lst else lst) assoc
      else
        (tag, [ele]) :: assoc
  in
  lst
  |> List.rev
  |> f
  |> List.rev
  |> List.map (Tuple.map_right List.rev)
;;

let stable_sort_dec compare = List.stable_sort (fun a b -> ~- (compare a b));;

let rec count = function
  | [] -> []
  | hd :: tl ->
    let counts = count tl in
    if List.mem_assoc hd counts then
      List.map (fun (tag, n) -> tag, if tag = hd then n + 1 else n) counts
    else
      (hd, 1) :: counts
;;

let count_int (lst : int t) =
  let rec f counts = function
    | [] -> counts
    | hd :: tl ->
        f (List.mapi (fun i n -> if hd = i then n + 1 else n) counts) tl
  in f (List.init (1 + fold Int.max lst) (fun _ -> 0)) lst
;;

let rec combos = function
  | [] -> [[]]
  | hd :: tl -> 
    let rest = combos tl in
    List.flatten (List.map (fun x -> (List.map (List.cons x) rest)) hd)
  ;;

let rec pop_all = function
  | [] -> []
  | [x] -> [x, []]
  | hd :: tl -> (hd, tl) :: (List.map (Tuple.map_right (List.cons hd)) (pop_all tl))
;;

let rec inner_shuffle = function
| [] -> [[]]
| [] :: tl -> inner_shuffle tl
| hd :: tl ->
  hd
  |> pop_all
  |> List.map (fun (i, hd) -> List.map (List.cons i) (inner_shuffle (hd :: tl)))
  |> List.flatten
;;