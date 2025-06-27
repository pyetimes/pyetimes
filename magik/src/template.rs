use crate::parser::Parser;

pub enum TemplateData {
    // Pure HTML data
    Html(String),
    // Key of the template to be replaced
    Key(String),
}

pub struct Template {
    data: Vec<TemplateData>,
}

impl Template {
    pub fn new() -> Self {
        Template { data: Vec::new() }
    }

    pub fn from_string(input: &str) -> Result<Self, String> {
        let mut data = Vec::new();
        let mut parser = Parser::new(input);

        while let Some(template_data) = parser.next() {
            data.push(template_data);
        }

        Ok(Template { data })
    }

    pub fn from_file(path: &str) -> Result<Self, String> {
        let content = std::fs::read_to_string(path).map_err(|e| e.to_string())?;

        Template::from_string(&content)
    }

    pub fn render(&self) -> String {
        self.data.iter().fold(String::new(), |mut acc, item| {
            match item {
                TemplateData::Html(html) => acc.push_str(html),
                TemplateData::Key(key) => acc.push_str(&format!("TemplateData::Key({})", key)),
            }
            acc
        })
    }
}
