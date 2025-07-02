use pulldown_cmark::{Options, Parser, html};

pub fn to_html(markdown: &str) -> String {
    let mut options = Options::all();
    options.insert(Options::ENABLE_TABLES);
    options.insert(Options::ENABLE_TASKLISTS);
    options.insert(Options::ENABLE_STRIKETHROUGH);

    let parser = Parser::new_ext(markdown, options);
    let mut html_output = String::new();

    html::push_html(&mut html_output, parser);

    html_output
}
