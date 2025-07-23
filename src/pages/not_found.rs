pub fn not_found() -> crate::pages::Page {
    let mut layout = magik_old::get("./pages/reader/layout.html");
    let not_found = magik_old::get("./pages/404.html");

    layout.set("main_story", &());
    layout.set("body", &not_found);

    layout.into()
}
