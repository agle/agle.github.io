open CalendarLib

let parsedate d = CalendarLib.Printer.Date.from_fstring "%F" d
let today = Calendar.now ()

let () =
  print_endline "Supported hl langs:";
  Hilite.Md.langs |> String.concat ", " |> print_endline;
  print_endline ""

type meta = {
  filename : string;
  name : string;
  date : Date.t option;
  content : unit -> [ `Text of string | `MDHtml of string | `Xml of Cow.Xml.t ];
  template : [ `Default | `Fname of string ];
  toc : string option;
}

module M = Map.Make (String)

let url = ref "http://localhost:8000/"
let site_title = ref "site title"

let inject_template (temp : string) (m : meta) =
  let tag_re =
    Str.regexp
      {|%%\(CONTENTBODY\|CONTENTDATE\|CONTENTTITLE\|URL\|SITETITLE\|TOC\|GENTIME\)%%|}
  in
  let body =
    lazy
      ( m.content () |> function
        | `Text s -> s
        | `Xml s -> Cow.Xml.to_string s
        | `MDHtml s -> s )
  in
  let date =
    lazy
      ( Option.map (fun d -> CalendarLib.Printer.Date.sprint "%d %B %Y" d) m.date
      |> function
        | Some x -> x
        | None -> "" )
  in
  Str.global_substitute tag_re
    (fun x ->
      match Str.matched_string x with
      | "%%URL%%" -> !url ^ "/" ^ m.filename ^ ".html"
      | "%%TOC%%" -> ( match m.toc with Some x -> x | None -> "")
      | "%%GENTIME%%" -> today |> CalendarLib.Printer.Calendar.sprint "%c"
      | "%%CONTENTBODY%%" -> Lazy.force body
      | "%%CONTENTDATE%%" -> Lazy.force date
      | "%%CONTENTTITLE%%" -> m.name
      | "%%SITETITLE%%" -> !site_title
      | x -> failwith x)
    temp

let make_list_item item_template (ms : meta list) =
  List.map (inject_template item_template) ms |> String.concat "\n"

let read_file ic =
  let res = ref "" in
  let rec read (c : in_channel) : string =
    try
      res := !res ^ input_line c ^ "\n";
      read c
    with End_of_file -> !res
  in
  read ic

let sub_list (temp : string) (ms : meta list M.t) : string =
  let delim = Str.regexp {|%%BEGINLIST%%\([^%]+\)%%\|%%ENDLIST%%|} in
  let bgdeli = Str.regexp {|%%BEGINLIST%%\([^%]+\)%%|} in
  let n = Str.full_split delim temp in

  let rec unpack acc xs =
    match xs with
    | Str.Delim bg :: Str.Text t :: rest when Str.string_match bgdeli bg 0 ->
        let r = Str.search_forward bgdeli bg 0 in
        let folder = "./" ^ Str.matched_group 1 bg in
        print_endline folder;
        let met = M.find folder ms in
        let default_date x =
          match x with Some d -> d | None -> parsedate "1970-01-01"
        in
        let met =
          met
          |> List.sort (fun mi mj ->
                 Calendar.Date.compare (default_date mi.date)
                   (default_date mj.date))
          |> List.rev
        in
        unpack (acc ^ make_list_item t met) rest
    | Str.Text b :: rest -> unpack (acc ^ b) rest
    | [] -> acc
    | Str.Delim "%%ENDLIST%%" :: rest -> unpack acc rest
    | Str.Delim x :: _ -> failwith ("unexpec " ^ x)
  in
  unpack "" n

let extension s : string = String.split_on_char '.' s |> List.rev |> List.hd

let drop_exn s : string =
  String.split_on_char '.' s |> List.rev |> List.tl |> List.rev
  |> String.concat "."

let parse_m fs f =
  let ls = ref [] in
  let n = ref "" in
  while
    (n := input_line f;
     !n)
    <> "---"
  do
    ls := !n :: !ls
  done;
  let ls = !ls in
  let separate s =
    s
    |> String.map (function '\t' -> ' ' | o -> o)
    |> String.split_on_char ':'
    |> function
    | key :: values -> (String.trim key, String.trim (String.concat ":" values))
    | x -> failwith ("Bad " ^ String.concat " ^ " x)
  in
  let m = List.map separate ls |> M.of_list in
  let content = read_file f in
  close_in f;
  let toc =
    match extension fs with
    | "md" -> Some (Omd.toc ~depth:8 (Omd.of_string content) |> Omd.to_html)
    | _ -> None
  in
  let do_md str =
    Cmarkit.Doc.of_string ~strict:false str
    |> Hilite.Md.transform
    |> Cmarkit_html.of_doc ~safe:false
  in
  let content () =
    match extension fs with
    | "md" -> `MDHtml (do_md content)
    | "markdown" -> `MDHtml (do_md content)
    | "html" -> `Xml (Cow.Html.of_string content)
    | _ -> `Text content
  in
  let filename = drop_exn fs in
  let template =
    M.find_opt "template" m |> function Some x -> `Fname x | None -> `Default
  in
  {
    name = M.find "title" m;
    date = M.find_opt "date" m |> Option.map parsedate;
    content;
    template;
    filename;
    toc;
  }

let build fs =
  let f = open_in fs in
  let n = ref (input_line f) in
  let filename = fs in
  if !n = "---" then parse_m fs f
  else (
    (* Meta that encodes direct copy *)
    close_in f;
    let fs = Unix.realpath fs in
    let content _ =
      let f = open_in fs in
      let r = read_file f in
      close_in f;
      `Text r
    in
    {
      name = fs;
      filename;
      content;
      date = None;
      template = `Default;
      toc = None;
    })

let list_directory dir =
  if Sys.file_exists dir && Sys.is_directory dir then
    let file_array = Sys.readdir dir in
    file_array |> Array.to_list
    |> List.filter (fun f -> Sys.is_regular_file (dir ^ "/" ^ f))
    (*|> List.filter (compose not (String.starts_with ~prefix:".")) *)
  else []

let templates_dir = ref "templates"
let source_dir = ref "src"
let build_dir = ref "build"

let speclist =
  [
    ( "-i",
      Arg.Set_string source_dir,
      "set input directory, default: " ^ !source_dir );
    ( "-o",
      Arg.Set_string build_dir,
      "set output directory, default: " ^ !build_dir );
    ( "--templates",
      Arg.Set_string templates_dir,
      "set templates directory, default: " ^ !templates_dir );
    ("--url", Arg.Set_string url, "set site public url, default: " ^ !url);
    ( "--title",
      Arg.Set_string site_title,
      "set site name title, default: " ^ !site_title );
  ]

let load_templs dir =
  list_directory dir
  |> List.map (fun f ->
         let fn = dir ^ "/" ^ f in
         let r = open_in fn in
         let t = read_file r in
         close_in r;
         (f, t))
  |> M.of_list

let rec list_directory_rec_build dir : (string * meta list) list =
  print_endline ("dir " ^ dir);
  if Sys.file_exists dir && Sys.is_directory dir then (
    let file_array =
      Sys.readdir dir |> Array.to_list |> List.map (fun i -> dir ^ "/" ^ i)
    in
    List.iter print_endline file_array;
    let files =
      file_array
      |> List.filter Sys.is_regular_file
      (*|> List.filter (compose not (String.starts_with ~prefix:".")) *)
      |> List.map build
    in
    let dires = file_array |> List.filter Sys.is_directory in
    List.iter print_endline dires;
    let dirs = List.concat_map (fun d -> list_directory_rec_build d) dires in
    (dir, files) :: dirs)
  else []

let process_dir temps indir outdir =
  let cd = Sys.getcwd () in
  let temps = load_templs temps in
  M.iter (fun i _ -> print_endline ("template " ^ i)) temps;
  print_endline "";
  Sys.chdir indir;
  let built = list_directory_rec_build "." in
  let bm = built |> M.of_list in
  print_endline "";
  print_endline "done build, outputting:";
  List.iter
    (fun (i, k) ->
      print_endline i;
      List.iter (fun x -> print_endline x.filename) k)
    built;
  let templated l =
    List.map
      (fun m ->
        let templ, fname =
          match m.template with
          | `Default -> (m.content (), m.filename)
          | `Fname f ->
              let t = M.find f temps in
              let s = sub_list t bm in
              let s = inject_template s m in
              (`Text s, m.filename ^ ".html")
        in
        (m, fname, templ))
      l
  in
  Sys.chdir cd;
  Sys.chdir outdir;
  let writeout (d, ms) =
    if not (Sys.file_exists d) then Sys.mkdir d 0o740;
    templated ms
    |> List.iter (function m, fname, c ->
           let cont =
             match c with
             | `Text t -> t
             | `Xml x -> Cow.Xml.to_string x
             | `MDHtml x -> x
           in
           print_endline "output";
           print_endline fname;
           let os = open_out fname in
           output_string os cont;
           close_out os)
  in
  List.iter writeout built

let usage_msg = "sb [ optional args ]"

let () =
  Arg.parse speclist (fun f -> ()) usage_msg;
  process_dir !templates_dir !source_dir !build_dir
