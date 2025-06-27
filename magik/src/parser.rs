use crate::template::TemplateData;

pub struct Parser<'a> {
    iter: std::str::Chars<'a>,
    start: usize,
    end: usize,
}

impl<'a> Parser<'a> {
    pub fn new(input: &'a str) -> Self {
        Parser {
            iter: input.chars(),
            start: 0,
            end: 0,
        }
    }

    pub fn next(&mut self) -> Option<TemplateData> {
        let pos = self.iter.position(|c| c == '{');

        if let Some(pos) = pos {
            if pos > self.start {
                let html_content = self.iter.as_str()[self.start..pos].to_string();
                self.start = pos + 1;
                return Some(TemplateData::Html(html_content));
            }
        } else {
            // If no '{' found, return the remaining content as HTML
            let html_content = self.iter.as_str()[self.start..].to_string();

            println!("Returning remaining HTML content: {}", self.iter.as_str());
            if !html_content.is_empty() {
                self.start = self.iter.as_str().len();
                return Some(TemplateData::Html(html_content));
            }
        }

        None
    }
}
