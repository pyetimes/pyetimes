use std::path;

pub use crate::template::Template;

pub use content_builder::ContentBuilder;

pub use renderable::Renderable;

mod content_builder;
mod parser;
mod renderable;
mod template;

pub fn from_string(input: &str) -> Template {
    Template::from_string(input)
        .map_err(|e| format!("Failed to load template from string: {}", e))
        .unwrap()
}

pub fn get(path: &str) -> Template {
    Template::from_file(path)
        .map_err(|e| format!("Failed to load template from '{}': {}", path, e))
        .unwrap()
}

pub fn build(path: &str) -> Result<(), String> {
    let template_path = path::Path::new(path);
    if !template_path.exists() {
        return Err(format!("Template path '{}' does not exist", path));
    }
    Ok(())
}

#[cfg(test)]
mod test {
    use super::from_string;

    #[test]
    fn test_from_str() {
        let mut template = from_string("<h1>{{ greet }}, {{ place }}!</h1>");

        template.set("greet", &"Hello");
        template.set("place", &"World");

        println!("Result: {}", template.render());
        assert!(template.render() == "<h1>Hello, World!</h1>");
    }
}
