open CalendarLib
open Containers

let parsedate d = CalendarLib.Printer.Date.from_fstring "%F" d
let today = Calendar.now ()

let () =
  print_endline "Supported hl langs:";
  Hilite.langs |> String.concat ", " |> print_endline;
  print_endline ""

type meta = {
  filename : string;
  name : string;
  date : Date.t option;
  content : unit -> [ `Text of string | `MDHtml of string | `Xml of Cow.Xml.t ];
  template : [ `Default | `Fname of string | `Rss ];
  toc : string option;
}

module M = Map.Make (String)

type site_cfg = { url : string; title : string }

let body m =
  m.content () |> function
  | `Text s -> s
  | `Xml s -> Cow.Xml.to_string s
  | `MDHtml s -> s

let date m =
  Option.map (fun d -> CalendarLib.Printer.Date.sprint "%d %B %Y" d) m.date
  |> function
  | Some x -> x
  | None -> ""

let to_item cfg m =
  let pubdate : Ptime.t option =
    let d = m.date |> Option.map Date.to_unixfloat in
    Option.bind d Ptime.of_float_s
  in
  let link =
    Uri.canonicalize
    @@ Uri.of_string (Filename.concat cfg.url (m.filename ^ ".html"))
  in
  let guid = Rss.Guid_permalink link in
  Rss.item ~title:m.name ~data:body ?pubdate ~link ~guid ()

let gen_rss cfg (m : meta) (ms : meta list) =
  let default_date x =
    match x with Some d -> d | None -> parsedate "1970-01-01"
  in
  let link =
    Uri.canonicalize @@ Uri.of_string
    @@ Filename.concat cfg.url (m.filename ^ ".xml")
  in
  let met =
    ms
    |> List.filter (fun m -> not (Equal.poly m.template `Rss))
    |> List.sort (fun mi mj ->
        Calendar.Date.compare (default_date mi.date) (default_date mj.date))
    |> List.rev
    |> List.map (to_item cfg)
  in
  let now = today |> CalendarLib.Printer.Calendar.sprint "%c" in

  let channel = Rss.channel ~title:m.name ~desc:(body m) ~link met in
  let b = Buffer.create 1024 in
  let f = Format.formatter_of_buffer b in
  Rss.print_channel f channel;
  Buffer.to_bytes b |> Bytes.to_string

let inject_template cfg (temp : string) (m : meta) =
  let tag_re =
    Str.regexp
      {|%%\(CONTENTBODY\|CONTENTDATE\|CONTENTTITLE\|URL\|SITETITLE\|TOC\|GENTIME\|SITEURL\)%%|}
  in
  Str.global_substitute tag_re
    (fun x ->
      match Str.matched_string x with
      | "%%SITEURL%%" -> cfg.url
      | "%%URL%%" -> Filename.concat cfg.url (m.filename ^ ".html")
      | "%%TOC%%" -> ( match m.toc with Some x -> x | None -> "")
      | "%%GENTIME%%" -> today |> CalendarLib.Printer.Calendar.sprint "%c"
      | "%%CONTENTBODY%%" -> body m
      | "%%CONTENTDATE%%" -> date m
      | "%%CONTENTTITLE%%" -> m.name
      | "%%SITETITLE%%" -> cfg.title
      | x -> failwith x)
    temp

let make_list_item cfg item_template (ms : meta list) =
  List.map (inject_template cfg item_template) ms |> String.concat "\n"

let read_file ic =
  let res = ref "" in
  let rec read (c : in_channel) : string =
    try
      res := !res ^ input_line c ^ "\n";
      read c
    with End_of_file -> !res
  in
  read ic

let sub_list cfg (temp : string) (ms : meta list M.t) : string =
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
          |> List.filter (fun m -> not (Equal.poly m.template `Rss))
          |> List.sort (fun mi mj ->
              Calendar.Date.compare (default_date mi.date)
                (default_date mj.date))
          |> List.rev
        in
        unpack (acc ^ make_list_item cfg t met) rest
    | Str.Text b :: rest -> unpack (acc ^ b) rest
    | [] -> acc
    | Str.Delim "%%ENDLIST%%" :: rest -> unpack acc rest
    | Str.Delim x :: _ -> failwith ("unexpec " ^ x)
  in
  unpack "" n

let extension s : string =
  Filename.extension s |> fun e ->
  Option.get_or ~default:e @@ String.chop_prefix ~pre:"." e

let drop_exn s : string =
  String.split_on_char '.' s |> List.rev |> List.tl |> List.rev
  |> String.concat "."

let parse_m fs f =
  let ls = ref [] in
  let n = ref "" in
  while
    not
    @@ String.equal
         (n := input_line f;
          !n)
         "---"
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
    Cmarkit.Doc.of_string ~heading_auto_ids:true ~strict:false str
    |> Hilite_markdown.transform
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
    M.find_opt "template" m |> function
    | Some "rss" -> `Rss
    | Some x -> `Fname x
    | None -> `Default
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
  if String.equal !n "---" then parse_m fs f
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
    |> List.filter (fun f -> Sys.is_regular_file (Filename.concat dir f))
    (*|> List.filter (compose not (String.starts_with ~prefix:".")) *)
  else []

let templates_dir = ref "templates"
let source_dir = ref "src"
let build_dir = ref "build"

let load_templs dir =
  list_directory dir
  |> List.map (fun f ->
      let fn = Filename.concat dir f in
      let r = open_in fn in
      let t = read_file r in
      close_in r;
      (f, t))
  |> M.of_list

let rec list_directory_rec_build dir : (string * meta list) list =
  print_endline ("dir " ^ dir);
  if Sys.file_exists dir && Sys.is_directory dir then (
    let file_array =
      Sys.readdir dir |> Array.to_list
      |> List.map (fun i -> Filename.concat dir i)
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

let rmdirrec odir =
  let files =
    CCIO.File.walk_l odir
    |> List.filter_map (function `File, e -> Some e | _ -> None)
  in
  files |> List.iter CCIO.File.remove_noerr

let process_dir cfg temps indir outdir =
  rmdirrec outdir;
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
              let s = sub_list cfg t bm in
              let s = inject_template cfg s m in
              (`Text s, m.filename ^ ".html")
          | `Rss ->
              let u = Filename.dirname m.filename in
              let s = gen_rss cfg m (M.find u bm) in
              (`Text s, m.filename ^ ".xml")
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
  List.iter writeout built;
  Sys.chdir cd

let usage_msg = "sb [ optional args ]"

let serve ~config ~timeout (dir : string) addr port j : _ result =
  let module S = Tiny_httpd in
  let server = S.create ~max_connections:j ~addr ~port ~timeout () in
  let after_init () =
    Printf.printf "serve directory %s on http://%(%s%):%d\n%!" dir
      (if S.is_ipv6 server then "[%s]" else "%s")
      addr (S.port server)
  in
  Tiny_httpd.Dir.add_dir_path ~config ~dir ~prefix:"" server;
  S.run ~after_init server

let poll_dir dir callback =
  let selectors =
    Inotify.[ S_Modify; S_Delete; S_Move; S_Create; S_Close_write ]
  in
  let p = Inotify.create () in
  CCIO.File.walk_l dir
  |> List.iter (function
    | `File, e -> ignore @@ Inotify.add_watch p e selectors
    | `Dir, d -> ignore @@ Inotify.add_watch p d selectors);
  let rec update () : unit =
    let ev = Inotify.read p in
    let do_update = true in
    ev
    |> List.iter (fun ((watch, ek, c, path) : Inotify.event) ->
        List.map
          (function
            | Inotify.Create ->
                Option.iter
                  (fun e -> ignore @@ Inotify.add_watch p e selectors)
                  path
            | Inotify.Delete -> Inotify.rm_watch p watch
            | _ -> ())
          ek
        |> ignore;
        ());
    if do_update then callback ();
    update ()
  in
  update ()

let httpd site_cfg port () =
  let odir = Filename.temp_dir "preview" "d" in
  if not @@ CCIO.File.is_directory odir then Sys.mkdir odir 0o755;

  let config = Tiny_httpd.Dir.config ~dir_behavior:Index () in
  let addr = "127.0.0.1" in
  let port = port |> Int.of_string |> Option.get_exn_or "port not an int" in
  let url = Printf.sprintf "http://%s:%d" addr port in
  let callback =
   fun () -> process_dir { site_cfg with url } !templates_dir !source_dir odir
  in
  callback ();
  let timeout = 30. in
  let serve_thread =
    Thread.create
      (fun () ->
        serve ~config ~timeout odir addr port 2 |> function
        | Ok _ -> ()
        | Error e -> raise e)
      ()
  in
  let poll_thread =
    Thread.create (fun () -> poll_dir !source_dir callback) ()
  in
  Thread.join serve_thread;
  Thread.join poll_thread;
  rmdirrec odir;
  ()

let () =
  let url = ref "http://localhost:8000/" in
  let site_title = ref "site title" in
  let preview = ref None in
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
      ( "--preview",
        Arg.String (fun (u : string) -> preview := Some u),
        "preview site port, default: disabled" );
      ( "--title",
        Arg.Set_string site_title,
        "set site name title, default: " ^ !site_title );
    ]
  in
  let cfg : site_cfg = { url = !url; title = !site_title } in
  Arg.parse speclist (fun f -> ()) usage_msg;
  !preview |> Option.iter (fun p -> httpd cfg p ());
  process_dir cfg !templates_dir !source_dir !build_dir
