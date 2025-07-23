use std::{collections::HashMap, rc::Rc};

use crate::{parser::Parser, renderable::Renderable};

#[derive(Debug, PartialEq, Clone)]
pub enum TemplateData {
    // Pure HTML data
    Html(String),
    // Key of the template to be replaced
    Key(String),
}

#[derive(Debug, Clone)]
pub struct Template {
    data: Rc<Vec<TemplateData>>,
    values: HashMap<String, String>,
}

impl Template {
    pub fn new() -> Self {
        Template {
            data: Rc::new(Vec::new()),
            values: HashMap::new(),
        }
    }

    pub fn from_string(input: &str) -> Result<Self, String> {
        let mut data = Vec::new();
        let mut parser = Parser::new(input);

        while let Some(template_data) = parser.next() {
            data.push(template_data);
        }

        Ok(Template {
            data: Rc::new(data),
            values: HashMap::new(),
        })
    }

    pub fn from_file(path: &str) -> Result<Self, String> {
        let content = std::fs::read_to_string(path).map_err(|e| e.to_string())?;

        Template::from_string(&content)
    }

    pub fn render(&self) -> String {
        self.data.iter().fold(String::new(), |mut acc, item| {
            match item {
                TemplateData::Html(html) => acc.push_str(html),
                TemplateData::Key(key) => {
                    acc.push_str(self.values.get(key).unwrap_or(&format!("{{{{{}}}}}", key)))
                }
            }
            acc
        })
    }

    pub fn set<T: Renderable>(&mut self, key: &str, value: &T) {
        self.values.insert(key.to_string(), value.render());
    }

    pub fn with_data<T: Renderable>(&self, data: &[(&str, &T)]) -> Result<Self, String> {
        let mut new_template = Template {
            data: self.data.clone(),
            values: HashMap::with_capacity(data.len()),
        };

        let data_map: HashMap<&str, &T> = data.iter().copied().collect();

        let mut missing_keys = Vec::new();

        for item in self.data.as_ref() {
            if let TemplateData::Key(key) = item {
                match data_map.get(key.as_str()) {
                    Some(value) => {
                        new_template.values.insert(key.clone(), (*value).render());
                    }
                    None => {
                        missing_keys.push(key.clone());
                    }
                }
            }
        }

        if !missing_keys.is_empty() {
            return Err(format!("Missing keys for template: {:?}", missing_keys));
        }

        Ok(new_template)
    }
}
