pub fn not_found() -> crate::pages::Page {
    let mut layout = magik::get("./pages/reader/layout.html");
    let not_found = magik::get("./pages/404.html");

    layout.set("body", &not_found);

    layout.into()
}
