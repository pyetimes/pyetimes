use crate::pages::Page;

pub fn editor() -> Page {
    let mut layout = magik::get("./pages/editor/layout.html");

    layout.set("body", &());

    layout.into()
}
