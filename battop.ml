(*
 * Top - An interpreted preambule for the toplevel
 * Copyright (C) 2009 David Rajchenbach-Teller, LIFO, Universite d'Orleans
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(**
   This file is meant to be invoked by a toplevel and performs initialization
   of OCaml Batteries Included and its libraries.

   Initialization consists of
   - loading Findlib
   - loading dependencies
   - loading the contents of the on-line help system
   - printing a welcome message

   This file is loaded by the magic line in the ocamlinit file.
*)

(* Set the below to false to disable use of syntax extensions in toplevel *)
let ext_syntax = true;;


(* END CONFIGURATION *)

(* MUST BE ALREADY HANDLED BY .ocamlinit
#use "topfind";;
*)
#thread;;
#require "batteries";;


if !Sys.interactive then (*Only initialize help and display welcome if we're in interactive mode.*)
begin
  BatteriesHelp.init ();
  print_endline "      _________________________";
  print_endline "    [| +   | |   Batteries   - |";
  print_endline "     |_____|_|_________________|";
  print_endline "      _________________________";
  print_endline "     | -  Type '#help;;' | | + |]";
  print_endline "     |___________________|_|___|";
  print_newline ();
  print_newline ();
  flush_all ()
end;;

open Batteries;;

let eval_string str =
  Lexing.from_string str |> !Toploop.parse_toplevel_phrase
    |> Toploop.execute_phrase false Format.err_formatter;;

let rec install_printers = function
  | [] -> true
  | printer :: printers ->
    let cmd = Printf.sprintf "#install_printer %s;;" printer in
    eval_string cmd && install_printers printers;;

install_printers !BatteriesPrint.printers;;

if ext_syntax then begin
  if !Sys.interactive then
    print_endline "Loading syntax extensions...";
  Topfind.standard_syntax();
  Topfind.load_deeply ["dynlink"; "camlp4"; "batteries.pa_string.syntax";
   		       "batteries.pa_comprehension.syntax"];
end else
  if !Sys.interactive then
    print_endline "Batteries Syntax extensions disabled.";
;;
