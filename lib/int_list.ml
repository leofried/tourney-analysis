let inc (r : int ref) : unit = r := !r + 1;;

let divide (x : int) (y : int) : float = Int.to_float x /. Int.to_float y;;

let rec pow a = function
| 0 -> 1
| 1 -> a
| n -> 
  let b = pow a (n / 2) in
  b * b * (if n mod 2 = 0 then 1 else a)
;;

let is_not_empty lst = lst <> [];;

let rec sum_one_list = function
  | [] -> 0
  | hd :: tl -> hd + sum_one_list tl
;;

let rec sum_two_lists (l1 : int list) (l2 : int list) : int list =
  match l1, l2 with
  | _, [] -> l1
  | [], _ -> l2
  | h1 :: t1, h2 :: t2 -> h1 + h2 :: sum_two_lists t1 t2
;;

let to_string (stringify : 'a -> string) = function
  | [] -> "[]"
  | [i] -> "[" ^ (stringify i) ^ "]"
  | hd :: tl ->
    let rec f = function
    | [] -> "]"
    | hd :: tl -> ", " ^ (stringify hd) ^ f tl
    in "[" ^ (stringify hd) ^ f tl
;;